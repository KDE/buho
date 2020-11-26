#include "booklet.h"
#include "bookssyncer.h"
#include "nextnote.h"

Booklet::Booklet(BooksSyncer *_syncer,  QObject *parent) : MauiList(parent),
	syncer(_syncer)
{

	connect(this->syncer, &BooksSyncer::bookletReady,this, &Booklet::appendBooklet);
	connect(this->syncer, &BooksSyncer::bookletInserted,[&](FMH::MODEL item, STATE state)
	{
		if(state.type == STATE::TYPE::LOCAL)
			this->appendBooklet(item);
	});
}

const FMH::MODEL_LIST &Booklet::items() const
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

	this->m_list[index] = this->m_list[index].unite(FMH::toModel(data));
	emit updateModel (index, {FMH::MODEL_KEY::CONTENT});
	this->syncer->updateBooklet(this->m_list[index][FMH::MODEL_KEY::ID], this->m_book, this->m_list[index]);
}

void Booklet::remove(const int &index)
{
	qDebug()<< "Trying to remove a booklet" << index;
	if(index < 0 || index >= this->m_list.size())
		return;

	emit this->preItemRemoved(index);
	this->syncer->removeBooklet(this->m_list.takeAt(index)[FMH::MODEL_KEY::ID]);
	emit this->postItemRemoved();
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
	emit this->postItemAppended();
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
