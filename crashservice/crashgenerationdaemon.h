#pragma once
/*!
* 崩溃信息收集服务器
*
*/
#include <QObject>
#include <QMap>
namespace google_breakpad{
	class CrashGenerationServer;
	class ClientInfo;
}
class CrashGenerationDaemon:public QObject
{
	Q_OBJECT
public:
	CrashGenerationDaemon(bool bService, QObject *parent = Q_NULLPTR);
	~CrashGenerationDaemon();

	bool CrashServerStart();
	void CrashServerStop();

	void cacheAppDumpFile(const QString& appName, const QString& dumpFile);

	void startCrashReporter(const ClientInfo* client_info);
private:
	bool									m_bService;						// 是否是服务模式	
	google_breakpad::CrashGenerationServer	*m_pCrashSvr;					// 崩溃收集服务器
	QMap<QString, QString>					m_mapAppForDumpFile;			// 应用程序对应的dump文件
};
