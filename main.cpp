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
#include "src/documenthandler.h"
#include "src/linker.h"

#include "models/notes/notesmodel.h"
#include "models/links/linksmodel.h"

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
    auto tag = owl.getTagging();

    context->setContextProperty("linker", &linker);
    context->setContextProperty("tag", tag);

    qmlRegisterType<DocumentHandler>("org.buho.editor", 1, 0, "DocumentHandler");

    qmlRegisterUncreatableMetaObject(OWL::staticMetaObject, "Owl", 1, 0, "KEY", "Error");

    qmlRegisterType<NotesModel>("Notes", 1, 0, "NotesModel");
    qmlRegisterType<LinksModel>("Links", 1, 0, "LinksModel");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
