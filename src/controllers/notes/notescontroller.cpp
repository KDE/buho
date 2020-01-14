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
		qWarning() << "the note is empty, therefore it could not be saved into a file";
		return QUrl();
	}

	QFile file(url.toLocalFile()+data[FMH::MODEL_KEY::TITLE]+QStringLiteral(".txt"));
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

bool NotesController::insertNote(const FMH::MODEL &note, const QUrl &url)
{
	if(note.isEmpty())
	{
		qWarning()<< "Could not insert note locally. The note is empty. NotesController::insertNote.";
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

	if(QColor::isValidColor (note[FMH::MODEL_KEY::COLOR]))
		Tagging::getInstance()->tagUrl(__notePath.toString(), "notes"+ QString(note[FMH::MODEL_KEY::COLOR]).replace("#", "-"), note[FMH::MODEL_KEY::COLOR]);

	return true;
}

void NotesController::getNotes(const QUrl &url)
{
	emit this->fetchNotes(url);
}

void NotesLoader::fetchNotes(const QUrl &url)
{
	FMH::MODEL_LIST notes;
	QDirIterator it(url.toLocalFile (), FMH::FILTER_LIST[FMH::FILTER_TYPE::TEXT], QDir::Filter::Files | QDir::Filter::Readable | QDir::Filter::Writable | QDir::Filter::NoDotAndDotDot, QDirIterator::IteratorFlag::Subdirectories);

	while(it.hasNext ())
	{
		const auto url = QUrl::fromLocalFile (it.next ());
		qDebug() << "Fetching URLS" << url;
		auto item =FMH::getFileInfoModel (url);
		item[FMH::MODEL_KEY::URL] = item[FMH::MODEL_KEY::PATH];
		item[FMH::MODEL_KEY::TITLE] = item[FMH::MODEL_KEY::NAME];
//		item[FMH::MODEL_KEY::FAV] = FMStatic::isFav (url);
		item[FMH::MODEL_KEY::CONTENT] = NotesLoader::fileContentPreview (url);
		notes << item;
		emit this->noteReady (item);
	}

	qDebug()<< "FINISHED FETCHING URLS";
	emit this->notesReady (notes);
}
