#include "crashgenerationdaemon.h"
#include "qtservice.h"
#if defined(Q_OS_LINUX)
#include "client/linux/crash_generation/crash_generation_server.h"
#elif defined(Q_OS_WIN32)
#include "client/windows/crash_generation/client_info.h"
#include "client/windows/crash_generation/crash_generation_server.h"
const wchar_t kPipeName[] = L"\\\\.\\pipe\\wiSCADACrashService\\CrashGenerationDaemon";
#elif defined(Q_OS_MAC)
#include "client/mac/crash_generation/crash_generation_server.h"
#endif

#include <QDebug>
#include <QFileInfo>
#include <QProcess>
using namespace google_breakpad;
////////////////////////////////////////////////////////////////////////////

static void OnClientConnected(void* context,
	const ClientInfo* client_info) 
{	
	qInfo() << CrashGenerationDaemon::tr("Client connected:%1").arg(client_info->pid());
}

static void OnClientDumpRequest(void* context,
	const ClientInfo* client_info,
	const wstring* dump_path) 
{
	qInfo() << CrashGenerationDaemon::tr("Client requested dump:%1").arg(client_info->pid());

	CustomClientInfo &custom_info = client_info->GetCustomInfo();
	if (custom_info.count <= 0) {
		return;
	}
	// 应用程序名称
	QString appname = QString::fromWCharArray(client_info->GetCustomInfo().entries[0].value);
	// 加入Map中
	((CrashGenerationDaemon*)context)->cacheAppDumpFile(appname, QString::fromStdWString(std::wstring(*dump_path)));
}

static void OnClientExited(void* context,
	const ClientInfo* client_info)
{
	qInfo() << CrashGenerationDaemon::tr("Client exited:%1").arg(client_info->pid());
	CustomClientInfo &custom_info = client_info->GetCustomInfo();

	// 启动dump 文件发送进程
	((CrashGenerationDaemon*)context)->startCrashReporter(client_info);
}
////////////////////////////////////////////////////////////////////////////
CrashGenerationDaemon::CrashGenerationDaemon(
	bool bService,
	QObject *parent)
	:QObject(parent)
	, m_bService(bService)
	, m_pCrashSvr(Q_NULLPTR)
{

}


CrashGenerationDaemon::~CrashGenerationDaemon()
{

}

bool CrashGenerationDaemon::CrashServerStart()
{
	bool bRet = false;
	std::wstring dump_path = qApp->applicationDirPath().toStdWString() + L"/Dumps";
	// Do not create another instance of the server.
	if (m_pCrashSvr) {
		bRet = true;
		goto LBL_RETRURN;
	}
#if defined(Q_OS_WIN32)	
	if (_wmkdir(dump_path.c_str()) && (errno != EEXIST)) {
		qWarning() << "Unable to create dump directory";
		bRet = false;
		goto LBL_RETRURN;
	}

	m_pCrashSvr = new CrashGenerationServer(
		kPipeName,
		NULL,
		OnClientConnected,
		this,
		OnClientDumpRequest,
		this,
		OnClientExited,
		this,
		NULL,
		NULL,
		true,
		&dump_path);
#endif
	if (m_pCrashSvr && !m_pCrashSvr->Start()) {
		qWarning() << "Unable to start server";
		delete m_pCrashSvr;
		m_pCrashSvr = Q_NULLPTR;
		bRet = false;
		goto LBL_RETRURN;
	}
	bRet = true;

	qInfo() <<CrashGenerationDaemon::tr("Servcie [ %1 ] started!").arg(QtServiceBase::instance()->serviceName());
LBL_RETRURN:
	return bRet;
}

void CrashGenerationDaemon::CrashServerStop()
{
	qInfo() << CrashGenerationDaemon::tr("Servcie [ %1 ] stop!").arg(QtServiceBase::instance()->serviceName());

	delete m_pCrashSvr;
	m_pCrashSvr = Q_NULLPTR;
}

void CrashGenerationDaemon::cacheAppDumpFile(const QString& appName, const QString& dumpFile)
{
	m_mapAppForDumpFile.insert(appName, dumpFile);
}

void CrashGenerationDaemon::startCrashReporter(const ClientInfo* client_info)
{
	CustomClientInfo &custom_info = client_info->GetCustomInfo();
	if (custom_info.count <= 0) {
		return;
	}
	// 应用程序名称
	QString appname = QString::fromWCharArray(client_info->GetCustomInfo().entries[0].value);
	if (m_mapAppForDumpFile.contains(appname))
		;
	QStringList arguments;
	QProcess::startDetached(qApp->applicationDirPath() + "/crashreporter",
		arguments,
		qApp->applicationDirPath());
}