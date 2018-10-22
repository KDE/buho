#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQmlContext>

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "./mauikit/src/mauikit.h"
#endif

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QtWebView/QtWebView>
#include <QIcon>
#else
#include <QApplication>
#include <QtWebEngine>
#endif

#include "src/buho.h"
#include "src/linker.h"

#include "models/basemodel.h"
#include "models/baselist.h"

#include "models/notes/notes.h"
#include "models/links/links.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    QtWebView::initialize();
#else
    QApplication app(argc, argv);
    //    QtWebEngine::initialize();
#endif

    app.setApplicationName(OWL::App);
    app.setApplicationVersion(OWL::version);
    app.setApplicationDisplayName(OWL::App);
    app.setWindowIcon(QIcon(":/buho.png"));

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes();
#endif

    Buho owl;

    QQmlApplicationEngine engine;
    auto context = engine.rootContext();

    context->setContextProperty("owl", &owl);

    Linker linker;
    context->setContextProperty("linker", &linker);

    qmlRegisterUncreatableMetaObject(OWL::staticMetaObject, "OWL", 1, 0, "KEY", "Error");
    qmlRegisterUncreatableType<BaseList>("BaseList", 1, 0, "BaseList", QStringLiteral("BaseList should not be created in QML"));

    qmlRegisterType<BaseModel>("BuhoModel", 1, 0, "BuhoModel");
    qmlRegisterType<Notes>("Notes", 1, 0, "Notes");
    qmlRegisterType<Links>("Links", 1, 0, "Links");


    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
