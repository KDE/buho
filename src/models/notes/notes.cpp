#include "notes.h"
#include "notessyncer.h"
#include "nextnote.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#include "fm.h"
#include "mauiaccounts.h"
#include "mauiapp.h"
#else
#include <MauiKit/tagging.h>
#include <MauiKit/fm.h>
#include <MauiKit/mauiaccounts.h>
#endif

#include <algorithm>

Notes::Notes(QObject *parent) : MauiList(parent),
	syncer(new NotesSyncer(this))
{
	qDebug()<< "CREATING NOTES LIST";
    qRegisterMetaType<FMH::MODEL>("FMH::MODEL");
    qRegisterMetaType<FMH::MODEL_LIST>("FMH::MODEL_LIST");

	this->syncer->setProvider(new NextNote); //Syncer takes ownership of NextNote or the provider

	connect(syncer, &NotesSyncer::noteInserted, [&](FMH::MODEL note, STATE state)
	{
		if(state.type == STATE::TYPE::LOCAL)
			this->appendNote(note);
	});

	connect(syncer, &NotesSyncer::noteUpdated, [&](FMH::MODEL note, STATE state)
	{
		if(state.type == STATE::TYPE::LOCAL)
		{
            const auto mappedIndex = this->mappedIndex(this->indexOf (FMH::MODEL_KEY::ID, note[FMH::MODEL_KEY::ID]));
            if(mappedIndex >= 0)
			{
                qDebug() << note[FMH::MODEL_KEY::MODIFIED];
                note.insert(FMH::getFileInfoModel (note[FMH::MODEL_KEY::URL]));
                qDebug() << note[FMH::MODEL_KEY::MODIFIED];
                this->notes[mappedIndex] = note;
                this->updateModel (mappedIndex, {});
			}
		}
	});

	connect(syncer, &NotesSyncer::noteReady, this, &Notes::appendNote);

	this->syncer->getNotes();
}

void Notes::appendNote(FMH::MODEL note)
{
	qDebug() << "APPEND NOTE <<" << note[FMH::MODEL_KEY::ID];
	note[FMH::MODEL_KEY::TITLE] = [&]()
	{
	  const auto lines = note[FMH::MODEL_KEY::CONTENT].split("\n");
	  return lines.isEmpty() ?  QString() : lines.first().trimmed();
	}();
    note.insert(FMH::getFileInfoModel (note[FMH::MODEL_KEY::URL]));
	emit this->preItemAppended ();
	this->notes << note;
	emit this->postItemAppended ();
}

FMH::MODEL_LIST Notes::items() const
{
	return this->notes;
}

bool Notes::insert(const QVariantMap &note)
{
    qDebug() << "Inserting new note" << note;
	auto __note = FMH::toModel(note);
	this->syncer->insertNote(__note);

	return true;
}

bool Notes::update(const QVariantMap &data, const int &index)
{
	if(index < 0 || index >= this->notes.size())
		return false;

    const auto index_ = this->mappedIndex(index);

    auto note = this->notes[index_];
    note.insert(FMH::toModel(data));
    this->syncer->updateNote(note[FMH::MODEL_KEY::ID], note);
	return true;
}

bool Notes::remove(const int &index)
{
	if(index < 0 || index >= this->notes.size())
		return false;

    const auto index_ = this->mappedIndex(index);

    emit this->preItemRemoved(index_);
    this->syncer->removeNote(this->notes.takeAt(index_)[FMH::MODEL_KEY::ID]);
	emit this->postItemRemoved();
    return true;
}

int Notes::indexOfNote(const QUrl &url)
{
    return this->indexOf(FMH::MODEL_KEY::PATH, url.toString());
}

QVariantMap Notes::get(const int &index) const
{
	if(index >= this->notes.size() || index < 0)
		return QVariantMap();
    return FMH::toMap(this->notes.at(this->mappedIndex ( index )));
}
