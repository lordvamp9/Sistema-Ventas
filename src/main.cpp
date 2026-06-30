#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend/POSController.hpp"
#include "backend/InventorySystem.hpp"
#include "backend/SettingsManager.hpp"
#include <QFontDatabase>
#include <QFont>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QFontDatabase::addApplicationFont(":/vamp9/Vamp9POS/src/assets/fonts/Inter-Regular.ttf");
    QFontDatabase::addApplicationFont(":/vamp9/Vamp9POS/src/assets/fonts/Inter-Bold.ttf");
    QFontDatabase::addApplicationFont(":/vamp9/Vamp9POS/src/assets/fonts/Inter-SemiBold.ttf");
    QFont defaultFont("Inter");
    QGuiApplication::setFont(defaultFont);

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
