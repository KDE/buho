#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QQmlContext>
#include <QIcon>

#if defined Q_OS_MACOS || defined Q_OS_WIN
#include <KF5/KI18n/KLocalizedString>
#else
#include <KI18n/KLocalizedString>
#endif

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#include "mauiapp.h"
#else
#include <MauiKit/mauiapp.h>
#endif

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <QIcon>
#else
#include <QApplication>
#endif

#ifndef STATIC_MAUIKIT
#include "../buho_version.h"
#endif

#include "buho.h"

#include "models/books/booklet.h"
#include "models/books/books.h"
#include "models/notes/notes.h"

#include "doodle/doodlehanlder.h"

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

    MauiApp::instance ()->setIconName ("qrc:/buho.svg");
    MauiApp::instance ()->setHandleAccounts (true);

    KLocalizedString::setApplicationDomain("buho");
    KAboutData about(QStringLiteral("buho"), i18n("Buho"), BUHO_VERSION_STRING, i18n("Buho allows you to take quick notes and organize notebooks."),
                     KAboutLicense::LGPL_V3, i18n("© 2019-2020 Nitrux Development Team"));
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
    qmlRegisterType<DoodleHanlder>(BUHO_URI, 1, 0, "Doodle");

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes(&engine);
#endif

	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	return app.exec();
}
