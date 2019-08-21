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

void Books::setSortBy(const Books::SORTBY &sort)
{

}

Books::SORTBY Books::getSortBy() const
{
    return this->sort;
}

void Books::setOrder(const Books::ORDER &order)
{

}

Books::ORDER Books::getOrder() const
{
    return this->order;
}

void Books::sortList()
{

}

QVariantMap Books::get(const int &index) const
{
    if(index >= this->m_list.size() || index < 0)
        return QVariantMap();

    return FMH::toMap(this->m_list.at(index));
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

bool Books::update(const QVariantMap &data, const int &index)
{
return false;
}

bool Books::remove(const int &index)
{
return false;
}
