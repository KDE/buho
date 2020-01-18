#include "booklet.h"
#include "bookssyncer.h"
#include "nextnote.h"

Booklet::Booklet(BooksSyncer *_syncer,  QObject *parent) : MauiList(parent),
    syncer(_syncer)
{

    connect(this->syncer, &BooksSyncer::bookletReady,this, &Booklet::appendBooklet);
    connect(this->syncer, &BooksSyncer::bookletInserted,this, &Booklet::appendBooklet);
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

QString Booklet::getBook() const
{
    return m_book;
}

void Booklet::setBook(const QString &book) //book id title
{
    if (m_book == book)
        return;

    this->setBookTitle(book);
    m_book = book;

    this->clear();
    this->syncer->getBooklets(this->m_book);

    emit bookChanged(m_book);
}

void Booklet::insert(const QVariantMap &data)
{
    auto booklet = FMH::toModel(data);
    this->syncer->insertBooklet(this->m_book, booklet);
}

void Booklet::update(const QVariantMap &data, const int &index)
{
    qDebug()<< "Trying to udpate a booklet" << data << index;

    if(index < 0 || index >= this->m_list.size())
        return;

    auto newData = this->m_list[index];
    QVector<int> roles;
    for(const auto &key : data.keys())
        if(newData[FMH::MODEL_NAME_KEY[key]] != data[key].toString())
        {
            newData[FMH::MODEL_NAME_KEY[key]] = data[key].toString();
            roles << FMH::MODEL_NAME_KEY[key];
        }

    this->m_list[index] = newData;

    newData[FMH::MODEL_KEY::MODIFIED] = QDateTime::currentDateTime().toString(Qt::TextDate);
//    this->syncer->updateBooklet(newData[FMH::MODEL_KEY::ID], this->m_book, newData);

    emit this->updateModel(index, roles);
}

void Booklet::remove(const int &index)
{

}

void Booklet::clear()
{
    emit this->preListChanged();
    this->m_list.clear();
    emit this->postListChanged();
}

void Booklet::sortList()
{

}

void Booklet::appendBooklet(FMH::MODEL booklet)
{
    emit this->preItemAppended();
    booklet = booklet.unite(FMH::getFileInfoModel(booklet[FMH::MODEL_KEY::URL]));
    booklet[FMH::MODEL_KEY::TITLE] = [&]()
    {
      const auto lines = booklet[FMH::MODEL_KEY::CONTENT].split("\n");
      return lines.isEmpty() ?  QString() : lines.first().trimmed();
    }();

    this->m_list << booklet;
    emit this->preItemAppended();
}

void Booklet::setBookTitle(const QString &title)
{
    if (m_bookTitle == title)
        return;

    m_bookTitle = title;
    emit bookTitleChanged(m_bookTitle);
}

QVariantMap Booklet::get(const int &index) const
{
    if(index >= this->m_list.size() || index < 0)
        return QVariantMap();

    return FMH::toMap(this->m_list.at(index));
}
