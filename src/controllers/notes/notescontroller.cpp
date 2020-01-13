#include "notescontroller.h"
#include "owl.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#include "fm.h"
#include "mauiaccounts.h"
#else
#include <MauiKit/tagging.h>
#include <MauiKit/fm.h>
#include <MauiKit/fmstatic.h>
#include <MauiKit/mauiaccounts.h>
#endif

NotesController::NotesController(QObject *parent) : QObject(parent)
{
    auto m_loader = new NotesLoader;
    m_loader->moveToThread(&m_worker);

    connect(&m_worker, &QThread::finished, m_loader, &QObject::deleteLater);
    connect(this, &NotesController::fetchNotes, m_loader, &NotesLoader::fetchNotes);

    connect(m_loader, &NotesLoader::noteReady, this, &NotesController::noteReady);

    m_worker.start();
}

NotesController::~NotesController()
{
    m_worker.wait();
    m_worker.quit();
}

const QUrl NotesController::saveNoteFile(const QUrl &url, const FMH::MODEL &data)
{
    if(data.isEmpty() /*|| !data.contains(FMH::MODEL_KEY::CONTENT)*/)
    {
        qWarning() << "the note is empty, therefore it could not be saved into a file";
        return QUrl();
    }

    qDebug() << "SVAE NOTES TO" << url.toLocalFile();
    QFile file(url.toLocalFile()+data[FMH::MODEL_KEY::TITLE]+QStringLiteral(".txt"));
    file.open(QFile::WriteOnly);
    file.write(data[FMH::MODEL_KEY::CONTENT].toUtf8());
    file.close();
    return QUrl::fromLocalFile(file.fileName());
}

bool NotesController::insertNote(const FMH::MODEL &note, const QUrl &url)
{
    if(note.isEmpty())
    {
        qWarning()<< "Could not insert note locally. The note is empty";
        return false;
    }

    if(url.isEmpty() && !url.isValid())
    {
        qWarning()<< "File could not be saved. NotesController::insertNote.";
        return false;
    }

    const auto __notePath = NotesController::saveNoteFile(url, note);
    if(!FMH::fileExists(__notePath))
        return false;

    auto m_note = note;
    m_note[FMH::MODEL_KEY::URL] = __notePath.toString();
    qDebug()<< "note saved to <<" << __notePath << m_note[FMH::MODEL_KEY::TAG];

    for(const auto &tg : m_note[FMH::MODEL_KEY::TAG].split(",", QString::SplitBehavior::SkipEmptyParts))
        Tagging::getInstance()->tagUrl(__notePath.toString(), tg, note[FMH::MODEL_KEY::COLOR]);

    return true;
}

void NotesController::getNotes(const QUrl &url)
{
    emit this->fetchNotes(url);
}

void NotesLoader::fetchNotes(const QUrl &url)
{
//    QDirIterator it(OWL::NotesPath.toLocalFile(), )
}
