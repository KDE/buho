#include "books.h"
#include "syncer.h"
#include "nextnote.h"

Books::Books(QObject *parent) : MauiList(parent),
    syncer(new Syncer(this))
{
    this->syncer->setProvider(new NextNote);

    this->syncer->getBooks();
}

FMH::MODEL_LIST Books::items() const
{
    return this->m_list;
}
