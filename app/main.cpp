#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <vendor.h>

#include "nodewrapper.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<NodeWrapper>("ShaderNodesApp", 1, 0, "NodeWrapper");

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    qpm::init(app, engine);

    engine.load(QUrl(QLatin1String("qrc:/main.qml")));

    return app.exec();
}
