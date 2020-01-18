#include "bookscontroller.h"
#include<MauiKit/fmstatic.h>
#include "db/db.h"
BooksController::BooksController(QObject *parent) : QObject(parent)
    ,m_db(DB::getInstance())
{

}

void BooksController::getBooklet(const QString &bookId)
{
    auto booklets = this->m_db->getDBData(QString("select * from booklets where id = '%1'").arg(bookId));
    for(auto &booklet : booklets)
        emit this->bookletReady(booklet);
}

bool BooksController::insertBooklet(QString bookId, FMH::MODEL &booklet)
{
    if(bookId.isEmpty() || booklet.isEmpty())
    {
        qWarning()<< "Could not insert booklet. Reference to book id or booklet are empty";
        return false;
    }

    FMH::MODEL book;
    book[FMH::MODEL_KEY::TITLE] =  bookId;
    if(!this->m_db->checkExistance(OWL::TABLEMAP[OWL::TABLE::BOOKS], "title", bookId))
    {
        qWarning()<< "The book does not exists in the db or the directory is missing. BooksSyncer::insertBookletLocal. "
                     "Creating a new book registry" << bookId;
        if(!this->insertBook(book))
            return false;
    }

    booklet[FMH::MODEL_KEY::ID] = OWL::createId();
    const auto url = QUrl(OWL::BooksPath.toString()+bookId+"/"+booklet[FMH::MODEL_KEY::ID]+booklet[FMH::MODEL_KEY::FORMAT]);

    qDebug()<< "trying to insert booklet" << booklet[FMH::MODEL_KEY::ID] << booklet[FMH::MODEL_KEY::CATEGORY] << url;

    if(!OWL::saveNoteFile(url, booklet[FMH::MODEL_KEY::CONTENT].toUtf8()))
    {
        qWarning()<< "File could not be saved. BooksSyncer::insertBookletLocal"  <<url;
        return false;
    }

    booklet[FMH::MODEL_KEY::URL] = url.toString();
    booklet[FMH::MODEL_KEY::BOOK] = bookId;
    qDebug()<< "booklet saved to <<" << url;

    const auto __bookletMap = FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::ID,
                                                              FMH::MODEL_KEY::BOOK,
                                                              FMH::MODEL_KEY::URL}));



    if(this->m_db->insert(OWL::TABLEMAP[OWL::TABLE::BOOKLETS], __bookletMap))
    {
        //        for(const auto &tg : booklet[FMH::MODEL_KEY::TAG].split(",", QString::SplitBehavior::SkipEmptyParts))
        //            this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], booklet[FMH::MODEL_KEY::ID], booklet[FMH::MODEL_KEY::COLOR]);

        return true;
    }

    return false;
}

bool BooksController::updateBooklet(FMH::MODEL &booklet, QString id)
{
    //    for(const auto &tg : booklet[FMH::MODEL_KEY::TAG])
    //        this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id);

    const QUrl __path = QFileInfo(booklet[FMH::MODEL_KEY::URL]).dir().path();
//    const auto __bookletPath = BooksSyncer::saveNoteFile(__path.toLocalFile()+"/", booklet);
//    qDebug()<< "Updating local txt file as"<< __path.toLocalFile() << __bookletPath;

//    if(__bookletPath.isEmpty())
//    {
//        qWarning()<< "File could not be saved. BooksSyncer::insertBookletLocal";
//        return false;
//    }

    return this->m_db->update(OWL::TABLEMAP[OWL::TABLE::BOOKLETS],
            FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::TITLE,
                                                  FMH::MODEL_KEY::MODIFIED,
                                                  FMH::MODEL_KEY::FAVORITE})),
            QVariantMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::BOOK], booklet[FMH::MODEL_KEY::BOOK]}});
}

bool BooksController::removeBooklet(const QString &id)
{
    return false;
}

void BooksController::getBooks()
{
    auto books = this->m_db->getDBData("select * from books");
    for(auto &book : books)
        emit this->bookReady(book);

    emit this->booksReady(books);
}

void BooksController::getBooklets(const QString &book)
{
    auto booklets = this->m_db->getDBData(QString("select * from booklets where book = '%1'").arg(book));
    for(auto &booklet : booklets)
        emit this->bookletReady(booklet);

    emit this->bookletsReady(booklets);
}

bool BooksController::insertBook(FMH::MODEL &book)
{
    const auto __path = QUrl(OWL::BooksPath.toString()+book[FMH::MODEL_KEY::TITLE]);
    if(FMH::fileExists(__path))
    {
        qWarning()<< "The directory for the book already exists. BooksSyncer::insertBookLocal" << book[FMH::MODEL_KEY::TITLE];
        return false;
    }

    const auto url = QUrl(OWL::BooksPath.toString()+ book[FMH::MODEL_KEY::TITLE]);
    QDir dir(url.toLocalFile());
    if(!dir.mkpath("."))
    {
        qWarning() << "Could not create directory for the given book name. BooksSyncer::insertBookLocal" << book[FMH::MODEL_KEY::TITLE];
        return false;
    }

    book[FMH::MODEL_KEY::URL] = url.toString();

    emit this->bookInserted(book);

    return(this->m_db->insert(OWL::TABLEMAP[OWL::TABLE::BOOKS], FMH::toMap(FMH::filterModel(book, {FMH::MODEL_KEY::TITLE, FMH::MODEL_KEY::URL}))));

}

bool BooksController::updateBook(const QString &id, const FMH::MODEL &book)
{
    return false;
}

