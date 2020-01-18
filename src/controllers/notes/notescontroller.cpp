#include "notescontroller.h"
#include "owl.h"
#include "db/db.h"
#include <QStringRef>

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

Q_DECLARE_METATYPE (FMH::MODEL_LIST)
Q_DECLARE_METATYPE (FMH::MODEL)

NotesController::NotesController(QObject *parent) : QObject(parent)
  ,m_db(DB::getInstance())
{
	qRegisterMetaType<FMH::MODEL_LIST>("MODEL_LIST");
	qRegisterMetaType<FMH::MODEL>("MODEL");

	auto m_loader = new NotesLoader;
	m_loader->moveToThread(&m_worker);

	connect(&m_worker, &QThread::finished, m_loader, &QObject::deleteLater);
	connect(this, &NotesController::fetchNotes, m_loader, &NotesLoader::fetchNotes);

	connect(m_loader, &NotesLoader::noteReady, this, &NotesController::noteReady);
	connect(m_loader, &NotesLoader::notesReady, this, &NotesController::notesReady);

	m_worker.start();
}

NotesController::~NotesController()
{
	m_worker.quit();
	m_worker.wait();
}

bool NotesController::insertNote(FMH::MODEL &note)
{
	if(note.isEmpty())
	{
		qWarning()<< "Could not insert note locally. The note is empty. NotesController::insertNote.";
        return false;
	}

    if((OWL::NotesPath.isLocalFile() && !FMH::fileExists(OWL::NotesPath)) || OWL::NotesPath.isEmpty() || !OWL::NotesPath.isValid())
	{
        qWarning() << "The url destination is not valid or does not exists, therefore it could not be saved into a file" << OWL::NotesPath;
		qWarning()<< "File could not be saved. NotesController::insertNote.";
        return false;
	}

    note[FMH::MODEL_KEY::ID] = OWL::createId();
    const auto url_ = QUrl(OWL::NotesPath.toString()+note[FMH::MODEL_KEY::ID]+note[FMH::MODEL_KEY::FORMAT]);
    if(!OWL::saveNoteFile(url_, note[FMH::MODEL_KEY::CONTENT].toUtf8()))
        return false;

    note[FMH::MODEL_KEY::URL] = url_.toString();

    for(const auto &tg : note[FMH::MODEL_KEY::TAG].split(",", QString::SplitBehavior::SkipEmptyParts))
        Tagging::getInstance()->tagUrl(url_.toString(), tg, note[FMH::MODEL_KEY::COLOR]);

    return(this->m_db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES],
           FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::URL,
                                              FMH::MODEL_KEY::ID,
                                              FMH::MODEL_KEY::COLOR,
                                              FMH::MODEL_KEY::PIN}))));
}

bool NotesController::updateNote(FMH::MODEL &note, QString id)
{
    if(note.isEmpty())
        return false;

	if(!note[FMH::MODEL_KEY::TAG].isEmpty ())
        Tagging::getInstance ()->updateUrlTags (note[FMH::MODEL_KEY::URL],  note[FMH::MODEL_KEY::TAG].split (","));

    if(note[FMH::MODEL_KEY::URL].isEmpty())
        note[FMH::MODEL_KEY::URL] = [&]() -> const QString {
                const auto data = DB::getInstance ()->getDBData(QString("select url from notes where id = '%1'").arg(id));
                return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::URL];
            }();

    if(note[FMH::MODEL_KEY::URL].isEmpty())
        return false;

    if(!OWL::saveNoteFile(note[FMH::MODEL_KEY::URL], note[FMH::MODEL_KEY::CONTENT].toUtf8()))
        return false;

    const auto f_note = FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::COLOR,
                                                           FMH::MODEL_KEY::PIN}));
    if(f_note.isEmpty())
        return true;

	return this->m_db->update(OWL::TABLEMAP[OWL::TABLE::NOTES],
            f_note, QVariantMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}});
}

bool NotesController::removeNote(const QString &id)
{

    const auto url = QUrl([&]() -> const QString {
            const auto data = DB::getInstance ()->getDBData(QString("select url from notes where id = '%1'").arg(id));
            return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::URL];
        }());

    this->m_db->remove(OWL::TABLEMAP[OWL::TABLE::NOTES_SYNC], {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}});

    FMStatic::removeFile(url);

    return this->m_db->remove(OWL::TABLEMAP[OWL::TABLE::NOTES], {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}});
}

void NotesController::getNotes()
{
    emit this->fetchNotes(this->m_db->getDBData("select * from notes"));
}

void NotesLoader::fetchNotes(FMH::MODEL_LIST notes)
{
	for(auto &note : notes)
	{
		const auto url = QUrl(note[FMH::MODEL_KEY::URL]);
        const auto contentPreview =  OWL::fileContentPreview (url);
        note[FMH::MODEL_KEY::CONTENT] = contentPreview;
		emit this->noteReady (note);
	}

	qDebug()<< "FINISHED FETCHING URLS";
    emit this->notesReady (notes);
}
