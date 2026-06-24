#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "backend/POSController.hpp"
#include "backend/InventorySystem.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    POSController posController;
    InventorySystem inventorySystem;

    QQmlApplicationEngine engine;
    
    engine.rootContext()->setContextProperty("posController", &posController);
    engine.rootContext()->setContextProperty("inventorySystem", &inventorySystem);

    const QUrl url(u"qrc:/vamp9/Multicosas/src/frontend/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
