#include "notescontroller.h"
#include "owl.h"
#include "db/db.h"

#include <QDirIterator>

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

const QUrl NotesController::saveNoteFile(const QUrl &url, const FMH::MODEL &data)
{
	if(data.isEmpty())
	{
		qWarning() << "the note is empty, therefore it could not be saved into a file" << url;
		return url;
	}

	if(url.isEmpty () || !url.isValid())
	{
		qWarning() << "the url is not valid or is empty, therefore it could not be saved into a file" << url;
		return url;
	}

	QFile file(url.toLocalFile());
	file.open(QFile::WriteOnly);
	file.write(data[FMH::MODEL_KEY::CONTENT].toUtf8());
	file.close();
	return QUrl::fromLocalFile(file.fileName());
}

const QString NotesLoader::fileContentPreview(const QUrl & path)
{
	if(!path.isLocalFile())
	{
		qWarning()<< "Can not open note file, the url is not a local path";
		return QString();
	}

	if(!FMH::fileExists (path))
		return QString();

	QFile file(path.toLocalFile());
	if(file.open(QFile::ReadOnly))
	{
		const auto content = file.read(512);
		file.close();
		return QString(content);
	}

	return QString();
}

QUrl NotesController::insertNote(const FMH::MODEL &note, const QUrl &url)
{
	if(note.isEmpty())
	{
		qWarning()<< "Could not insert note locally. The note is empty. NotesController::insertNote.";
		return QUrl();
	}

	if((url.isLocalFile() && !FMH::fileExists(url)) || url.isEmpty() || !url.isValid())
	{
		qWarning() << "The url destination is not valid or does not exists, therefore it could not be saved into a file" << url;
		qWarning()<< "File could not be saved. NotesController::insertNote.";
		return QUrl();
	}

	const auto url_ = QUrl(url.toString()+note[FMH::MODEL_KEY::TITLE]+note[FMH::MODEL_KEY::FORMAT]);

	const auto __notePath = NotesController::saveNoteFile(url_, note);
	if(!FMH::fileExists(__notePath))
		return QUrl();

	auto m_note = note;
	m_note[FMH::MODEL_KEY::URL] = __notePath.toString();

	for(const auto &tg : m_note[FMH::MODEL_KEY::TAG].split(",", QString::SplitBehavior::SkipEmptyParts))
		Tagging::getInstance()->tagUrl(__notePath.toString(), tg, note[FMH::MODEL_KEY::COLOR]);

	this->m_db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES],
			FMH::toMap(FMH::filterModel(m_note, {FMH::MODEL_KEY::COLOR,
												 FMH::MODEL_KEY::URL,
												 FMH::MODEL_KEY::PIN})));

	return __notePath;
}

bool NotesController::updateNote(const FMH::MODEL & note, const QUrl & url)
{
	if(!note[FMH::MODEL_KEY::TAG].isEmpty ())
		Tagging::getInstance ()->updateUrlTags (url.toString (),  note[FMH::MODEL_KEY::TAG].split (","));

	NotesController::saveNoteFile (url, note);

	return this->m_db->update(OWL::TABLEMAP[OWL::TABLE::NOTES],
			FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::COLOR,
											   FMH::MODEL_KEY::PIN})), QVariantMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::URL], url.toString ()}});
}

void NotesController::getNotes()
{
	emit this->fetchNotes();
}

void NotesLoader::fetchNotes()
{
	auto notes = DB::getInstance()->getDBData("select * from notes");

	for(auto &note : notes)
	{
		const auto url = QUrl(note[FMH::MODEL_KEY::URL]);
		qDebug() << "Fetching URLS" << url;
		note.unite(FMH::getFileInfoModel (url));
		note[FMH::MODEL_KEY::TITLE] = note[FMH::MODEL_KEY::NAME];
		note[FMH::MODEL_KEY::CONTENT] = NotesLoader::fileContentPreview (url);
		emit this->noteReady (note);
	}

	qDebug()<< "FINISHED FETCHING URLS";
	emit this->notesReady (notes);
}
