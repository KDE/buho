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

bool Books::insert(const QVariantMap &book)
{
    emit this->preItemAppended();

    auto __book = FMH::toModel(book);
    __book[FMH::MODEL_KEY::MODIFIED] = QDateTime::currentDateTime().toString(Qt::TextDate);
    __book[FMH::MODEL_KEY::ADDDATE] = QDateTime::currentDateTime().toString(Qt::TextDate);

    this->syncer->insertNote(__book);

    this->m_list << __book;

    emit this->postItemAppended();
    return true;
}
