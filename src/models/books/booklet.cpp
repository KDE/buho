#include "booklet.h"

Booklet::Booklet(QObject *parent) : MauiList(parent)
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

void Booklet::sortList()
{

}
