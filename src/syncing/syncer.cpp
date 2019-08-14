#include "syncer.h"
#include "db/db.h"
#include "nextnote.h"

#include <QUuid>

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#include "fm.h"
#else
#include <MauiKit/tagging.h>
#include <MauiKit/fm.h>
#endif

Syncer::Syncer(QObject *parent) : QObject(parent),
    tag(Tagging::getInstance()),
    db(DB::getInstance()),
    provider(new NextNote(this))
{}

void Syncer::insertNote(FMH::MODEL &note)
{
    qDebug()<<"TAGS"<< note[FMH::MODEL_KEY::TAG];

    Syncer::stampNote(note);
    const auto __noteMap = FM::toMap(Syncer::packNote(note));

    if(this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES], __noteMap))
    {
        for(const auto &tg : note[FMH::MODEL_KEY::TAG].split(",", QString::SplitBehavior::SkipEmptyParts))
            this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], note[FMH::MODEL_KEY::ID], note[FMH::MODEL_KEY::COLOR]);

//        this->provider->insertNote(note);
    }

}

void Syncer::stampNote(FMH::MODEL &note)
{
    const auto id = QUuid::createUuid().toString();
    note[FMH::MODEL_KEY::ID] = id;
}

FMH::MODEL Syncer::packNote(const FMH::MODEL &note)
{
    return FMH::MODEL {
    {FMH::MODEL_KEY::ID, note[FMH::MODEL_KEY::ID]},
    {FMH::MODEL_KEY::TITLE, note[FMH::MODEL_KEY::TITLE]},
    {FMH::MODEL_KEY::CONTENT, note[FMH::MODEL_KEY::CONTENT]},
    {FMH::MODEL_KEY::COLOR, note[FMH::MODEL_KEY::COLOR]},
    {FMH::MODEL_KEY::PIN, note[FMH::MODEL_KEY::PIN]},
    {FMH::MODEL_KEY::FAVORITE, note[FMH::MODEL_KEY::FAVORITE]},
    {FMH::MODEL_KEY::MODIFIED, note[FMH::MODEL_KEY::MODIFIED]},
    {FMH::MODEL_KEY::ADDDATE, note[FMH::MODEL_KEY::ADDDATE]}
    };
}
