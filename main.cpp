#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "mauikit/src/mauikit.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

#ifdef MAUI_APP
    MauiKit::getInstance().registerTypes();
#endif

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
