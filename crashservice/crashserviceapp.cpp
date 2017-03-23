#include "crashserviceapp.h"
#include "crashgenerationdaemon.h"
#include <QDateTime>
#include <QDebug>
CrashServiceApp::CrashServiceApp(int argc, char **argv)
	:QtService<QCoreApplication>(argc, argv,"wiSCADA Crash Daemon")
	, m_pCrashGenSvr(Q_NULLPTR)
	,m_bService(true)
{
	setServiceDescription(QObject::tr("wiSCADA Crash Daemon."));	
}

CrashServiceApp::~CrashServiceApp()
{

}

void CrashServiceApp::start()
{
	QCoreApplication *app = application();	
#if QT_VERSION < 0x040100
	if (app->argc() >= 2)
	{
		std::string arg1(app->argv()[1]);
		if (arg1 == std::string("-e") || arg1 == std::string("-exec"))
			m_bService = false;
	}
#else
	const QStringList arguments = QCoreApplication::arguments();
	if (arguments.size() >= 2) 
	{
		if (arguments[1] == QLatin1String("-e") || arguments[1] == QLatin1String("-exec"))
			m_bService = false;
	}
#endif
	m_pCrashGenSvr = new CrashGenerationDaemon(m_bService, app);
	m_pCrashGenSvr->CrashServerStart();
}

void CrashServiceApp::stop()
{
	m_pCrashGenSvr->CrashServerStop();
	delete m_pCrashGenSvr;
	m_pCrashGenSvr = Q_NULLPTR;
}