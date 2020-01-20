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

    this->syncer->setProvider(new NextNote); //Syncer takes ownership of NextNote or the provider

    connect(this, &Notes::sortByChanged, this, &Notes::sortList);
    connect(this, &Notes::orderChanged, this, &Notes::sortList);

    connect(syncer, &NotesSyncer::noteInserted, [&](FMH::MODEL note, STATE state)
    {
        if(state.type == STATE::TYPE::LOCAL)
            this->appendNote(note);
    });

    connect(syncer, &NotesSyncer::noteUpdated, [&](FMH::MODEL note, STATE state)
    {
        if(state.type == STATE::TYPE::LOCAL)
        {
            const auto index = this->indexOf (FMH::MODEL_KEY::ID, note[FMH::MODEL_KEY::ID]);
            if(index >= 0)
            {
                note.unite(FMH::getFileInfoModel (note[FMH::MODEL_KEY::URL]));
                this->notes[index] = note;
                this->updateModel (index, FMH::modelRoles(note));
            }
        }
    });

    connect(syncer, &NotesSyncer::noteReady, this, &Notes::appendNote);

    this->syncer->getNotes();
}

void Notes::sortList()
{
    emit this->preListChanged();
    const auto key = static_cast<FMH::MODEL_KEY>(this->sort);
    qDebug()<< "SORTING LIST BY"<< this->sort;
    std::sort(this->notes.begin(), this->notes.end(), [&](const FMH::MODEL &e1, const FMH::MODEL &e2) -> bool
    {
        switch(key)
        {
            case FMH::MODEL_KEY::FAVORITE:
            {
                return e1[key] == "1";
            }

            case FMH::MODEL_KEY::DATE:
            case FMH::MODEL_KEY::MODIFIED:
            {
                const auto date1 = QDateTime::fromString(e1[key], Qt::TextDate);
                const auto date2 = QDateTime::fromString(e2[key], Qt::TextDate);

                if(this->order == Notes::ORDER::ASC)
                {
                    if(date1.secsTo(QDateTime::currentDateTime()) >  date2.secsTo(QDateTime::currentDateTime()))
                        return true;
                }

                if(this->order == Notes::ORDER::DESC)
                {
                    if(date1.secsTo(QDateTime::currentDateTime()) <  date2.secsTo(QDateTime::currentDateTime()))
                        return true;
                }

                break;
            }

            case FMH::MODEL_KEY::TITLE:
            case FMH::MODEL_KEY::COLOR:
            {
                const auto str1 = QString(e1[key]).toLower();
                const auto str2 = QString(e2[key]).toLower();

                if(this->order == Notes::ORDER::ASC)
                {
                    if(str1 < str2)
                        return true;
                }

                if(this->order == Notes::ORDER::DESC)
                {
                    if(str1 > str2)
                        return true;
                }

                break;
            }

            default:
                if(e1[key] < e2[key])
                    return true;
        }

        return false;
    });
    emit this->postListChanged();
}

void Notes::appendNote(FMH::MODEL note)
{
    qDebug() << "APPEND NOTE <<" << note[FMH::MODEL_KEY::ID];
    note[FMH::MODEL_KEY::FAVORITE] = FMStatic::isFav (note[FMH::MODEL_KEY::URL]) ? "1" : "0";
    note[FMH::MODEL_KEY::TITLE] = [&]()
    {
      const auto lines = note[FMH::MODEL_KEY::CONTENT].split("\n");
      return lines.isEmpty() ?  QString() : lines.first().trimmed();
    }();
    note.unite(FMH::getFileInfoModel (note[FMH::MODEL_KEY::URL]));
    emit this->preItemAppended ();
    this->notes << note;
    emit this->postItemAppended ();
}

FMH::MODEL_LIST Notes::items() const
{
    return this->notes;
}

void Notes::setSortBy(const Notes::SORTBY &sort)
{
    if(this->sort == sort)
        return;

    this->sort = sort;
    emit this->sortByChanged();
}

Notes::SORTBY Notes::getSortBy() const
{
    return this->sort;
}

void Notes::setOrder(const Notes::ORDER &order)
{
    if(this->order == order)
        return;

    this->order = order;
    emit this->orderChanged();
}

Notes::ORDER Notes::getOrder() const
{
    return this->order;
}

bool Notes::insert(const QVariantMap &note)
{
    auto __note = FMH::toModel(note);
    this->syncer->insertNote(__note);

    return true;
}

bool Notes::update(const QVariantMap &data, const int &index)
{
    if(index < 0 || index >= this->notes.size())
        return false;

    this->notes[index] = this->notes[index].unite(FMH::toModel(data));
    this->syncer->updateNote(this->notes[index][FMH::MODEL_KEY::ID], this->notes[index]);
    return true;
}

bool Notes::remove(const int &index)
{
    if(index < 0 || index >= this->notes.size())
        return false;

    emit this->preItemRemoved(index);
    this->syncer->removeNote(this->notes.takeAt(index)[FMH::MODEL_KEY::ID]);
    emit this->postItemRemoved();
    return true;
}

QVariantMap Notes::get(const int &index) const
{
    if(index >= this->notes.size() || index < 0)
        return QVariantMap();
    return FMH::toMap(this->notes.at(index));
}
