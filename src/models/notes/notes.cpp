#include "notes.h"
#include "nextnote.h"
#include "notessyncer.h"

#include <QDebug>

#include <MauiKit4/FileBrowsing/fm.h>
#include <MauiKit4/Accounts/mauiaccounts.h>

#include <algorithm>

Notes::Notes(QObject *parent)
    : MauiList(parent)
    , syncer(new NotesSyncer(this))
{
    qDebug() << "CREATING NOTES LIST";
    qRegisterMetaType<FMH::MODEL>("FMH::MODEL");
    qRegisterMetaType<FMH::MODEL_LIST>("FMH::MODEL_LIST");

    this->syncer->setProvider(new NextNote); // Syncer takes ownership of NextNote or the provider

    connect(syncer, &NotesSyncer::noteInserted, [&](FMH::MODEL note, STATE state) {

        qDebug() << "Insertint new note" << note;
        if (state.type == STATE::TYPE::LOCAL)
            this->appendNote(note);
    });

    connect(syncer, &NotesSyncer::noteUpdated, [&](FMH::MODEL note, STATE state) {
        if (state.type == STATE::TYPE::LOCAL) {
            const auto index = this->indexOf(FMH::MODEL_KEY::ID, note[FMH::MODEL_KEY::ID]);
            if (index >= 0) {
                qDebug() << note[FMH::MODEL_KEY::MODIFIED] << index;
                note.insert(FMStatic::getFileInfoModel(QUrl(note[FMH::MODEL_KEY::URL])));
                qDebug() << note[FMH::MODEL_KEY::MODIFIED];
                this->notes[index] = note;
                Q_EMIT this->updateModel(index, {});
            }
        }
    });

    connect(syncer, &NotesSyncer::noteReady, this, &Notes::appendNote);
}

void Notes::appendNote(FMH::MODEL note)
{
    qDebug() << "APPEND NOTE <<" << note[FMH::MODEL_KEY::ID];
    note[FMH::MODEL_KEY::TITLE] = [&]() {
        const auto lines = note[FMH::MODEL_KEY::CONTENT].split("\n");
        return lines.isEmpty() ? QString() : lines.first().trimmed();
    }();
    note.insert(FMStatic::getFileInfoModel(QUrl(note[FMH::MODEL_KEY::URL])));
    Q_EMIT this->preItemAppended();
    this->notes << note;
    Q_EMIT this->postItemAppended();
    Q_EMIT this->countChanged();
}

const FMH::MODEL_LIST &Notes::items() const
{
    return this->notes;
}

QVariantMap Notes::insert(const QVariantMap &note)
{
    qDebug() << "Inserting new note" << note;
    auto __note = FMH::toModel(note);
    this->syncer->insertNote(__note);

    return FMH::toMap(__note);
}

bool Notes::update(const QVariantMap &data, const int &index)
{
    if (index < 0 || index >= this->notes.size())
        return false;


    auto note = this->notes[index];
    //    if(note[FMH::MODEL_KEY::CONTENT] == data.value("content").toString())
    //    {
    //        return false;
    //    }

    qDebug() << "UDPATE MODEL ITEM AT "<< index << note[FMH::MODEL_KEY::TITLE];
    note.insert(FMH::toModel(data));

    note[FMH::MODEL_KEY::TITLE] = [&]() {
        const auto lines = note[FMH::MODEL_KEY::CONTENT].split("\n");
        return lines.isEmpty() ? QString() : lines.first().trimmed();
    }();
    this->syncer->updateNote(note[FMH::MODEL_KEY::ID], note);
    return true;
}

bool Notes::remove(const int &index)
{
    if (index < 0 || index >= this->notes.size())
        return false;

    Q_EMIT this->preItemRemoved(index);
    this->syncer->removeNote(this->notes.takeAt(index).value(FMH::MODEL_KEY::ID));
    Q_EMIT this->postItemRemoved();
    Q_EMIT this->countChanged();

    return true;
}

int Notes::indexOfNote(const QUrl &url)
{
    return this->indexOf(FMH::MODEL_KEY::PATH, url.toString());
}

int Notes::indexOfName(const QString &query)
{
    const auto it = std::find_if(this->items().constBegin(), this->items().constEnd(), [&](const FMH::MODEL &item) -> bool {
        return item[FMH::MODEL_KEY::TITLE].startsWith(query, Qt::CaseInsensitive);
    });

    if (it != this->items().constEnd())
        return std::distance(this->items().constBegin(), it);
    else
        return -1;
}

void Notes::componentComplete()
{
    setList();
}


void Notes::setList()
{
    this->syncer->getNotes();
}
