#include "bookssyncer.h"
#include "controllers/books/bookscontroller.h"
#include "db/db.h"

#include <MauiKit/FileBrowsing/fmstatic.h>
#include <MauiKit/FileBrowsing/tagging.h>

#include <MauiKit/Core/mauiaccounts.h>

BooksSyncer::BooksSyncer(QObject *parent)
    : Syncer(parent)
    , tag(Tagging::getInstance())
    , db(DB::getInstance())
    , m_booksController(new BooksController(this)) // local handler for notes
{
    connect(MauiAccounts::instance(), &MauiAccounts::currentAccountChanged, [&](QVariantMap) {
        this->getRemoteBooks();
    });

    connect(this->m_booksController, &BooksController::bookReady, this, &BooksSyncer::bookReady);
    connect(this->m_booksController, &BooksController::bookInserted, [this](FMH::MODEL book) {
        emit this->bookInserted(book, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Book inserted locally sucessfully"});
    });

    connect(this->m_booksController, &BooksController::bookletReady, this, &BooksSyncer::bookletReady);
}

void BooksSyncer::getBooks()
{
    this->getLocalBooks();
    this->getRemoteBooks();
}

void BooksSyncer::getRemoteBooks()
{
    if (this->validProvider())
        this->getProvider().getBooklets();
    else
        qWarning() << "Credentials are missing to get booklets or the provider has not been set";
}

void BooksSyncer::getLocalBooks()
{
    this->m_booksController->getBooks();
}

void BooksSyncer::insertBook(FMH::MODEL &book)
{
    if (!this->m_booksController->insertBook(book)) {
        qWarning() << "Could not insert Book, BooksSyncer::insertBook";
        return;
    }
}

void BooksSyncer::getBooklet(const QString &id)
{
    this->m_booksController->getBooklet(id);
}

void BooksSyncer::getBooklets(const QString &book)
{
    this->m_booksController->getBooklets(book);
}

void BooksSyncer::updateBooklet(const QString &id, const QString &bookId, FMH::MODEL &booklet)
{
    if (!this->m_booksController->updateBooklet(booklet, id)) {
        qWarning() << "The booklet could not be updated locally, "
                      "therefore it was not attempted to update it on the remote server provider, "
                      "even if it existed.";
        return;
    }

    // to update remote booklet we need to pass the stamp as the id
    const auto stamp = BooksSyncer::bookletStampFromId(id);
    qDebug() << "booklet stamp from id" << stamp;

    if (!stamp.isEmpty()) {
        booklet[FMH::MODEL_KEY::CATEGORY] = bookId;
        if (this->validProvider())
            this->getProvider().updateBooklet(stamp, booklet);
    }

    emit this->bookletUpdated(booklet, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Booklet updated locally on the DB"});
}

void BooksSyncer::removeBooklet(const QString &id)
{
    // to remove the remote booklet we need to pass the stamp as the id,
    // and before removing the note locally we need to retireved first

    const auto stamp = BooksSyncer::bookletStampFromId(id);
    if (!this->m_booksController->removeBooklet(id)) {
        qWarning() << "The note could not be inserted locally, "
                      "therefore it was not attempted to insert it to the remote provider server, "
                      "even if it existed.";
        return;
    }

    if (!stamp.isEmpty()) {
        if (this->validProvider())
            this->getProvider().removeBooklet(stamp);
    }

    emit this->bookletRemoved(FMH::MODEL(), {STATE::TYPE::LOCAL, STATE::STATUS::OK, "The booklet has been removed from the local DB"});
}

void BooksSyncer::insertBooklet(const QString &bookId, FMH::MODEL &booklet)
{
    if (!m_booksController->insertBooklet(bookId, booklet)) {
        qWarning() << "Could not insert Booklet, BooksSyncer::insertBooklet";
        return;
    }

    booklet[FMH::MODEL_KEY::CATEGORY] = bookId;
    if (this->validProvider())
        this->getProvider().insertBooklet(booklet);

    emit this->bookletInserted(booklet, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Booklet inserted locally sucessfully"});
}

const QString BooksSyncer::bookletIdFromStamp(const QString &provider, const QString &stamp)
{
    return [&]() -> const QString {
        const auto data = DB::getInstance()->getDBData(QString("select id from booklets_sync where server = '%1' AND stamp = '%2'").arg(provider, stamp));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::ID];
    }();
}

const QString BooksSyncer::bookletStampFromId(const QString &id)
{
    return [&]() -> const QString {
        const auto data = DB::getInstance()->getDBData(QString("select stamp from booklets_sync where id = '%1'").arg(id));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::STAMP];
    }();
}

void BooksSyncer::setConections()
{
    connect(&this->getProvider(), &AbstractNotesProvider::bookletInserted, [&](FMH::MODEL booklet) {
        qDebug() << "STAMP OF THE NEWLY INSERTED BOOKLET" << booklet[FMH::MODEL_KEY::ID] << booklet[FMH::MODEL_KEY::STAMP] << booklet;
        this->db->insert(OWL::TABLEMAP[OWL::TABLE::BOOKLETS_SYNC], FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::ID, FMH::MODEL_KEY::STAMP, FMH::MODEL_KEY::USER, FMH::MODEL_KEY::SERVER})));
        emit this->bookletInserted(booklet, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Booklet inserted on server provider"});
    });

    connect(&this->getProvider(), &AbstractNotesProvider::bookletsReady, [&](FMH::MODEL_LIST booklets) {
        //        qDebug()<< "SERVER NOETS READY "<< notes;

        // if there are no notes in the provider server, then just return
        if (booklets.isEmpty())
            return;

        // there might be two case scenarios:
        // the booklet exists locally in the db, so it needs to be updated with the server version
        // the booklet does not exists locally, so it needs to be inserted into the db
        for (auto &booklet : booklets) {
            qDebug() << "Booklets READY << " << booklet[FMH::MODEL_KEY::TITLE] << booklet[FMH::MODEL_KEY::CATEGORY];

            const auto id = BooksSyncer::bookletIdFromStamp(this->getProvider().provider(), booklet[FMH::MODEL_KEY::STAMP]); // the id is actually the stamp id
            booklet[FMH::MODEL_KEY::ID] = id;

            // if the title is empty then the booklet does not exists, so insert the booklet into the local db
            if (id.isEmpty()) {
                // here insert the note into the db
                if (!this->m_booksController->insertBooklet(booklet[FMH::MODEL_KEY::CATEGORY], booklet)) {
                    qWarning() << "Remote booklet could not be inserted to the local storage";
                    continue;
                }

                this->db->insert(OWL::TABLEMAP[OWL::TABLE::BOOKLETS_SYNC], FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::ID, FMH::MODEL_KEY::STAMP, FMH::MODEL_KEY::USER, FMH::MODEL_KEY::SERVER})));
                emit this->bookletInserted(booklet, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Booklet inserted on local db, from the server provider"});

            } else {
                // the booklet exists in the db locally, so update it
                booklet[FMH::MODEL_KEY::BOOK] = booklet[FMH::MODEL_KEY::CATEGORY];
                booklet[FMH::MODEL_KEY::URL] = [&]() -> QString {
                    const auto data = this->db->getDBData(QString("select url from booklets where id = '%1'").arg(id));
                    return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::URL];
                }();

                qDebug() << " trying to update local booklets with url" << booklet[FMH::MODEL_KEY::URL] << booklet[FMH::MODEL_KEY::BOOK] << booklet[FMH::MODEL_KEY::CONTENT];

//                auto remoteDate = QDateTime::fromSecsSinceEpoch(booklet[FMH::MODEL_KEY::MODIFIED].toInt());
//                auto localDate = QFileInfo(QUrl(booklet[FMH::MODEL_KEY::URL]).toLocalFile()).lastModified();

                //                if(remoteDate <= localDate)
                //                    continue;

                if (!this->m_booksController->updateBooklet(booklet, id))
                    continue;

                emit this->bookletUpdated(booklet, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Booklet updated on local db, from the server provider"});
            }
        }

        emit this->booksReady(this->collectAllBooks()); //???
    });

    connect(&this->getProvider(), &AbstractNotesProvider::bookletUpdated, [&](FMH::MODEL booklet) {
        const auto id = BooksSyncer::bookletIdFromStamp(this->getProvider().provider(), booklet[FMH::MODEL_KEY::ID]);
        if (!booklet.isEmpty()) {
            booklet[FMH::MODEL_KEY::ID] = id;
            booklet[FMH::MODEL_KEY::BOOK] = booklet[FMH::MODEL_KEY::CATEGORY];
            booklet[FMH::MODEL_KEY::URL] = [&]() -> QString {
                const auto data = this->db->getDBData(QString("select url from booklets where id = '%1'").arg(id));
                return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::URL];
            }();
            this->m_booksController->updateBooklet(booklet, id);
        }

        emit this->bookletUpdated(booklet, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Booklet updated on server provider"});
    });
}

const FMH::MODEL_LIST BooksSyncer::collectAllBooks()
{
    //    return this->db->getDBData("select b.*, count(distinct bl.id) as count from books b inner join booklets bl on bl.book = b.id");
    return this->db->getDBData("select * from books");
}
