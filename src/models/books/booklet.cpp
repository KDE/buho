#include "booklet.h"
#include "syncer.h"

Booklet::Booklet(Syncer *_syncer,  QObject *parent) : MauiList(parent),
    syncer(_syncer)
{

}

FMH::MODEL_LIST Booklet::items() const
{
    return this->m_list;
}

void Booklet::setSortBy(const Booklet::SORTBY &sort)
{

}

Booklet::SORTBY Booklet::getSortBy() const
{
    return this->sort;
}

void Booklet::setOrder(const Booklet::ORDER &order)
{

}

Booklet::ORDER Booklet::getOrder() const
{
    return this->order;
}

void Booklet::insert(const QVariantMap &data)
{
    emit this->preItemAppended();

    auto __booklet = FMH::toModel(data);
    __booklet[FMH::MODEL_KEY::MODIFIED] = QDateTime::currentDateTime().toString(Qt::TextDate);
    __booklet[FMH::MODEL_KEY::ADDDATE] = QDateTime::currentDateTime().toString(Qt::TextDate);

    this->syncer->insertBooklet(__booklet);

    this->m_list << __booklet;

    emit this->postItemAppended();
}

void Booklet::update(const QVariantMap &data, const int &index)
{

}

void Booklet::remove(const int &index)
{

}

void Booklet::sortList()
{

}
