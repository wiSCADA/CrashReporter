/* 
 * wiSCADA Crash Services
 */

#include "version.h"
#include "crashserviceapp.h"
#include <QApplication>
#include <QMessageBox>
#include <QUrl>
#include <QDebug>
#include <QTimer>
#include <QFile>
#include <QMutex>
#include <QMutexLocker>
#include <QTime>
#include <QChar>

#if defined(Q_OS_WIN32)
#include <qt_windows.h>
#else
#include <unistd.h>
#include <stdlib.h>
#endif

static QFile* f = 0;

static void qtServiceCloseDebugLog()
{
	if (!f)
		return;
	f->write(QTime::currentTime().toString("HH:mm:ss.zzz").toLatin1());
	f->write(" --- DEBUG LOG CLOSED ---\n\n");
	f->flush();
	f->close();
	delete f;
	f = 0;
}

#if QT_VERSION >= 0x050000
void crashServiceLogDebug(QtMsgType type, const QMessageLogContext &context, const QString &msg)
#else
void crashServiceLogDebug(QtMsgType type, const char* msg)
#endif
{
	static QMutex mutex;
	QMutexLocker locker(&mutex);
#if defined(Q_OS_WIN32)
	const qulonglong processId = GetCurrentProcessId();
#else
	const qulonglong processId = getpid();
#endif
	QString console_msg;
	QByteArray s(QTime::currentTime().toString("HH:mm:ss.zzz").toLatin1());
	s += " [";
	s += QByteArray::number(processId);
	s += "] ";
	
	console_msg.append(s);

	if (!f) {
#if defined(Q_OS_WIN32)
		f = new QFile("./logs/service-debuglog.txt");
#else
		f = new QFile("./logs/service-debuglog.txt");
#endif
		if (!f->open(QIODevice::WriteOnly | QIODevice::Append)) {
			delete f;
			f = 0;
			return;
		}
		QByteArray ps('\n' + s + "--- DEBUG LOG OPENED ---\n");
		f->write(ps);
	}

	switch (type) {
	case QtWarningMsg:
		s += "WARNING: ";
		console_msg += "WARNING: ";
		break;
	case QtCriticalMsg:
		s += "CRITICAL: ";
		console_msg += "CRITICAL: ";
		break;
	case QtFatalMsg:
		s += "FATAL: ";
		console_msg += "FATAL: ";
		break;
	case QtDebugMsg:
		s += "DEBUG: ";
		console_msg += "DEBUG: ";
		break;
	default:
		// Nothing
		break;
	}	

#if QT_VERSION >= 0x050400
	s += qFormatLogMessage(type, context, msg).toLocal8Bit();
	console_msg += qFormatLogMessage(type, context, msg).toLocal8Bit();
#elif QT_VERSION >= 0x050000
	s += msg.toLocal8Bit();
	console_msg += msg->toLocal8Bit();
	Q_UNUSED(context)
#else
	s += msg;
	console_msg += msg;
#endif
	s += '\n';	
	f->write(s);
	f->flush();

	qDebug() << console_msg;
	if (type == QtFatalMsg) {
		qtServiceCloseDebugLog();
		exit(1);
	}
}

int main( int argc, char* argv[] )
{

#  if QT_VERSION >= 0x050000
	qInstallMessageHandler(crashServiceLogDebug);
#  else
	qInstallMsgHandler(crashServiceLogDebug);
#  endif

#if !defined(Q_OS_WIN)
	// QtService stores service settings in SystemScope, which normally require root privileges.
	// To allow testing this example as non-root, we change the directory of the SystemScope settings file.
	QSettings::setPath(QSettings::NativeFormat, QSettings::SystemScope, QDir::tempPath());
	qWarning("(Example uses dummy settings file: %s/QtSoftware.conf)", QDir::tempPath().toLatin1().constData());
#endif
	CrashServiceApp service(argc, argv);
	return service.exec();
}
