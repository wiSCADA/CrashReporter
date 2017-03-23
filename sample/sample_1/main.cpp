#include "breakpadtest.h"

#include "client/windows/handler/exception_handler.h"
#include "crashhandler/crashhandler.h"

#include <QApplication>
#include <QDebug>
#include <QFileInfo>
#include <QDir>

// 程序崩溃回调函数;
bool callback(const wchar_t *dump_path, const wchar_t *id,
	void *context, EXCEPTION_POINTERS *exinfo,
	MDRawAssertionInfo *assertion,
	bool succeeded)
{
	if (succeeded) 
	{
		qDebug() << "Create dump file success";
	}
	else
	{
		qDebug() << "Create dump file failed";
	}
	return succeeded;
}

int main(int argc, char *argv[])
{
	//google_breakpad::ExceptionHandler eh(
	//	L".", NULL, callback, NULL,
	//	google_breakpad::ExceptionHandler::HANDLER_ALL);

	QFileInfo appPath(QString::fromLocal8Bit(argv[0]));
	QString appDir(appPath.absoluteDir().path());
	QString crashReporterPath = QString("%1/crashreporter").arg(appDir.isEmpty() ? "." : appDir);
	CrashHandler::instance()->Init(QDir::homePath(), appDir, crashReporterPath);

	QApplication a(argc, argv);
	BreakPadTest w;
	w.show();
	return a.exec();
}
