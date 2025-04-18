#include <QCommandLineParser>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>

#include <KLocalizedString>

#include <MauiKit4/Core/mauiapp.h>
#include <MauiKit4/TextEditor/moduleinfo.h>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#include <MauiKit4/Core/mauiandroid.h>
#else
#include <QApplication>
#endif

#include "../buho_version.h"

#include "owl.h"
#include "models/notes/notes.h"
#include "utils/server.h"

#define BUHO_URI "org.maui.buho"

/**
 * @brief setFolders Creates the directory where to save the note as text files
 */
static void setFolders()
{
    QDir notes_path(OWL::NotesPath.toLocalFile());
    if (!notes_path.exists())
        notes_path.mkpath(".");
}

int Q_DECL_EXPORT main(int argc, char *argv[])
{
#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
#else
    QApplication app(argc, argv);
#endif

    setFolders ();

    app.setOrganizationName(QStringLiteral("Maui"));
    app.setWindowIcon(QIcon(":/buho.png"));

    KLocalizedString::setApplicationDomain("buho");
    KAboutData about(QStringLiteral("buho"),
                     QStringLiteral("Buho"),
                     BUHO_VERSION_STRING,
                     i18n("Create and organize your notes."),
                     KAboutLicense::LGPL_V3,
                     APP_COPYRIGHT_NOTICE,
                     QString(GIT_BRANCH) + "/" + QString(GIT_COMMIT_HASH));

    about.addAuthor(QStringLiteral("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
    about.setHomepage("https://mauikit.org");
    about.setProductName("maui/buho");
    about.setBugAddress("https://invent.kde.org/maui/buho/-/issues");
    about.setOrganizationDomain(BUHO_URI);
    about.setProgramLogo(app.windowIcon());

    const auto FBData = MauiKitTextEditor::aboutData();
    about.addComponent(FBData.name(), MauiKitTextEditor::buildVersion(), FBData.version(), FBData.webAddress());

    KAboutData::setApplicationData(about);
    MauiApp::instance()->setIconName("qrc:/buho.svg");

    QCommandLineOption newNoteOption(QStringList() << "n" << "new", "Create a new note.");
    QCommandLineOption newNoteContent(QStringList() << "c" << "content", "new note contents.", "content");

    QCommandLineParser parser;

    parser.addOption(newNoteOption);
    parser.addOption(newNoteContent);

    about.setupCommandLine(&parser);
    parser.process(app);

    about.processCommandLine(&parser);

    bool newNote = parser.isSet(newNoteOption);
    QString noteContent;

#if (defined Q_OS_LINUX || defined Q_OS_FREEBSD) && !defined Q_OS_ANDROID    
    if(newNote)
    {
        if(parser.isSet(newNoteContent))
        {
            noteContent = parser.value(newNoteContent);
        }
    }

    if (AppInstance::attachToExistingInstance(newNote, noteContent))
    {
        // Successfully attached to existing instance of Nota
        return 0;
    }

    AppInstance::registerService();
#endif

    auto server = std::make_unique<Server>();

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/app/maui/buho/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url, newNote, noteContent, &server](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);

            server->setQmlObject(obj);
            if(newNote)
            {
                server->newNote(noteContent);
            }
        },
        Qt::QueuedConnection);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    qmlRegisterType<Notes>(BUHO_URI, 1, 0, "Notes");

    engine.load(url);
    return app.exec();
}
