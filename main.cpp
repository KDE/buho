#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>


#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QIcon>
#else
#include <QApplication>
#endif

#include "mauikit/src/mauikit.h"
#include "src/buho.h"
#include "src/documenthandler.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QIcon::setThemeName("Luv");
    QQuickStyle::setStyle("material");
#else
    QApplication app(argc, argv);
#endif

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef MAUI_APP
    MauiKit::getInstance().registerTypes();
#endif

    Buho owl;

    QQmlApplicationEngine engine;
    auto context = engine.rootContext();
    context->setContextProperty("owl", &owl);

    qmlRegisterType<DocumentHandler>("org.buho.editor", 1, 0, "DocumentHandler");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
