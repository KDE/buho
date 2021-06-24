#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDate>
#include <QDir>

#include <KI18n/KLocalizedString>

#include <MauiKit/Core/mauiapp.h>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include "../buho_version.h"

#include "owl.h"
#include "models/notes/notes.h"

#define BUHO_URI "org.maui.buho"

void setFolders()
{
    QDir notes_path(OWL::NotesPath.toLocalFile());
    if (!notes_path.exists())
        notes_path.mkpath(".");
}

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

    KLocalizedString::setApplicationDomain("buho");
    KAboutData about(QStringLiteral("buho"), i18n("Buho"), BUHO_VERSION_STRING, i18n("Create and organize your notes."), KAboutLicense::LGPL_V3, i18n("© 2019-%1 Nitrux Development Team", QString::number(QDate::currentDate().year())), QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));
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

    QQmlApplicationEngine engine;

    qmlRegisterType<Notes>(BUHO_URI, 1, 0, "Notes");

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
