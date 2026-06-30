#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend/POSController.hpp"
#include "backend/InventorySystem.hpp"
#include "backend/SettingsManager.hpp"
#include "backend/DatabaseManager.hpp"
#include <QFontDatabase>
#include <QFont>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <iostream>

void myMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QFile outFile("vamp9pos_debug_log.txt");
    if (outFile.open(QIODevice::WriteOnly | QIODevice::Append | QIODevice::Text)) {
        QTextStream ts(&outFile);
        QString typeStr;
        switch (type) {
        case QtDebugMsg: typeStr = "DEBUG"; break;
        case QtInfoMsg: typeStr = "INFO"; break;
        case QtWarningMsg: typeStr = "WARNING"; break;
        case QtCriticalMsg: typeStr = "CRITICAL"; break;
        case QtFatalMsg: typeStr = "FATAL"; break;
        }
        ts << QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz")
           << " [" << typeStr << "] " << msg << "\n";
    }
}

int main(int argc, char *argv[])
{
    // Force Basic style to allow text field backgrounds and borders to customize correctly
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    // Clean log file for the new session
    QFile::remove("vamp9pos_debug_log.txt");

    qInstallMessageHandler(myMessageHandler);

    QGuiApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/vamp9/Vamp9POS/src/assets/fonts/Inter-Regular.ttf");
    QFontDatabase::addApplicationFont(":/vamp9/Vamp9POS/src/assets/fonts/Inter-Bold.ttf");
    QFontDatabase::addApplicationFont(":/vamp9/Vamp9POS/src/assets/fonts/Inter-SemiBold.ttf");
    QFont defaultFont("Inter");
    QGuiApplication::setFont(defaultFont);

    // Initialize database connection first
    DatabaseManager::instance();

    POSController posController;
    InventorySystem inventorySystem;
    SettingsManager settingsManager;
    settingsManager.loadSettings(); // load from sqlite

    QQmlApplicationEngine engine;
    
    engine.rootContext()->setContextProperty("posController", &posController);
    engine.rootContext()->setContextProperty("inventorySystem", &inventorySystem);
    engine.rootContext()->setContextProperty("settingsManager", &settingsManager);

    const QUrl url(u"qrc:/vamp9/Vamp9POS/src/frontend/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
