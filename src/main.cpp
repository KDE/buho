#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDate>

#include <KI18n/KLocalizedString>

#include <MauiKit/Core/mauiapp.h>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#include "../buho_version.h"

#include "buho.h"
#include "models/books/booklet.h"
#include "models/books/books.h"
#include "models/notes/notes.h"

//#include "doodle/doodlehanlder.h"

#define BUHO_URI "org.maui.buho"

int Q_DECL_EXPORT main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
    QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
    QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/buho.png"));

    MauiApp::instance()->setIconName("qrc:/buho.svg");
    MauiApp::instance()->setHandleAccounts(true);

    KLocalizedString::setApplicationDomain("buho");
    KAboutData about(QStringLiteral("buho"), i18n("Buho"), BUHO_VERSION_STRING, i18n("Buho allows you to take quick notes and organize notebooks."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
    about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/buho");
    about.setBugAddress("https://invent.kde.org/maui/buho/-/issues");
    about.setOrganizationDomain(BUHO_URI);
    about.setProgramLogo(app.windowIcon());

    KAboutData::setApplicationData(about);

    QCommandLineParser parser;
    parser.process(app);

    about.setupCommandLine(&parser);
    about.processCommandLine(&parser);

    Buho buho;

    QQmlApplicationEngine engine;

    qmlRegisterAnonymousType<Booklet>(BUHO_URI, 1);
    qmlRegisterType<Notes>(BUHO_URI, 1, 0, "Notes");
    qmlRegisterType<Books>(BUHO_URI, 1, 0, "Books");
    //    qmlRegisterType<DoodleHanlder>(BUHO_URI, 1, 0, "Doodle");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
