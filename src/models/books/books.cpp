#include "books.h"
#include "booklet.h"
#include "bookssyncer.h"
#include "nextnote.h"
#include <QColor>
#include <QRandomGenerator>

#include <MauiKit/FileBrowsing/fmstatic.h>

Books::Books(QObject *parent)
    : MauiList(parent)
    , syncer(new BooksSyncer(this))
    , m_booklet(new Booklet(syncer, this))
{
	this->syncer->setProvider(new NextNote);
	connect(this, &Books::currentBookChanged, this, &Books::openBook);
	connect(syncer, &BooksSyncer::bookReady, [&](FMH::MODEL book)
	{
		emit this->preItemAppended();
        auto book_data = FMStatic::getFileInfoModel(book[FMH::MODEL_KEY::URL]);
		book_data.insert (FMH::MODEL_KEY::COLOR, QColor::fromRgb(QRandomGenerator::global()->generate()).name());
        book.insert(book_data);
		this->m_list << book;
		emit this->postItemAppended();
	});

	connect(syncer, &BooksSyncer::bookInserted, [&](FMH::MODEL book)
	{
		emit this->preItemAppended();
        auto book_data = FMStatic::getFileInfoModel(book[FMH::MODEL_KEY::URL]);
		book_data.insert (FMH::MODEL_KEY::COLOR, QColor::fromRgb(QRandomGenerator::global()->generate()).name());
        book.insert(book_data);
		this->m_list << book;
		emit this->postItemAppended();
	});
	this->syncer->getBooks();
}

const FMH::MODEL_LIST &Books::items() const
{
    return this->m_list;
}

Booklet *Books::getBooklet() const
{
    return m_booklet;
}

int Books::getCurrentBook() const
{
    return m_currentBook;
}

bool Books::insert(const QVariantMap &book)
{
    auto __book = FMH::toModel(book);
    __book[FMH::MODEL_KEY::THUMBNAIL] = "qrc:/booklet.svg";
    __book[FMH::MODEL_KEY::LABEL] = __book[FMH::MODEL_KEY::TITLE];
    __book[FMH::MODEL_KEY::MODIFIED] = QDateTime::currentDateTime().toString(Qt::TextDate);
    __book[FMH::MODEL_KEY::ADDDATE] = QDateTime::currentDateTime().toString(Qt::TextDate);

    qDebug() << "Trying to add a book" << __book;
    this->syncer->insertBook(__book);
    return true;
}

bool Books::update(const QVariantMap &data, const int &index)
{
    Q_UNUSED(data)
    Q_UNUSED(index)

    return false;
}

bool Books::remove(const int &index)
{
    Q_UNUSED(index)
    
    return false;
}

void Books::openBook(const int &index)
{
    if (index >= this->m_list.size() || index < 0)
        return;

    this->m_booklet->setBook(this->m_list.at(index)[FMH::MODEL_KEY::TITLE]);
    this->m_booklet->setBookTitle(this->m_list.at(index)[FMH::MODEL_KEY::TITLE]);
}

void Books::setCurrentBook(int currentBook)
{
    if (this->m_currentBook == currentBook)
        return;

    this->m_currentBook = currentBook;
    emit this->currentBookChanged(m_currentBook);
}
