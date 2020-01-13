#include "syncer.h"
#include "db/db.h"
#include "abstractnotesprovider.h"
#include "controllers/notes/notescontroller.h"

#include <QUuid>

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#include "fm.h"
#include "mauiaccounts.h"
#else
#include <MauiKit/tagging.h>
#include <MauiKit/fm.h>
#include <MauiKit/fmstatic.h>
#include <MauiKit/mauiaccounts.h>
#endif

Syncer::Syncer(QObject *parent) : QObject(parent),
    tag(Tagging::getInstance()),
    db(DB::getInstance()),
    m_provider(nullptr), //online service handler
    m_notesController(new NotesController(this)) //local handler
{
    connect(MauiAccounts::instance(), &MauiAccounts::currentAccountChanged, [&](QVariantMap currentAccount)
    {
        this->setAccount(FMH::toModel(currentAccount));
    });
}

void Syncer::setAccount(const FMH::MODEL &account)
{
    if(this->m_provider)
        this->m_provider->setCredentials(account);
}

void Syncer::setProvider(AbstractNotesProvider *provider)
{
    this->m_provider = std::move(provider);
    this->m_provider->setParent(this);
    this->m_provider->disconnect();
    this->setConections();
}

void Syncer::insertNote(FMH::MODEL &note)
{
    if(!this->m_notesController->insertNote(note, this->localStoragePath(OWL::NotesPath)))
    {
        qWarning()<< "The note could not be inserted locally, "
                     "therefore it was not attempted to insert it to the remote provider server, "
                     "even if it existed.";
        return;
    }

    if(this->m_provider && this->m_provider->isValid())
        this->m_provider->insertNote(note);

    emit this->noteInserted(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note saved locally"});
}

void Syncer::updateNote(const QString &id, const FMH::MODEL &note)
{
    if(!this->updateNoteLocal(id, note))
    {
        qWarning()<< "The note could not be updated locally, "
                     "therefore it was not attempted to update it on the remote server provider, "
                     "even if it existed.";
        return;
    }

    //to update remote note we need to pass the stamp as the id
    const auto stamp = Syncer::noteStampFromId(this->db, id);
    if(!stamp.isEmpty())
        this->updateNoteRemote(stamp, note);

    emit this->noteUpdated(note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note updated on the DB locally"});
}

void Syncer::removeNote(const QString &id)
{
    //to remove the remote note we need to pass the stamp as the id,
    //and before removing the note locally we need to retireved first

    const auto stamp = Syncer::noteStampFromId(this->db, id);
    if(!this->removeNoteLocal(id))
    {
        qWarning()<< "The note could not be inserted locally, "
                     "therefore it was not attempted to insert it to the remote provider server, "
                     "even if it existed.";
        return;
    }

    if(!stamp.isEmpty())
        this->removeNoteRemote(stamp);

    emit this->noteRemoved(FMH::MODEL(), {STATE::TYPE::LOCAL, STATE::STATUS::OK, "The note has been removed from the local DB"});
}

void Syncer::getNotes()
{
    this->collectAllNotes();
    if(this->m_provider && this->m_provider->isValid())
        this->m_provider->getNotes();
    else
        qWarning()<< "Failed to fetch online notes. Credentials are missing  or the provider has not been set";
}

void Syncer::getBooks()
{
    const auto books = this->collectAllBooks();

        if(this->m_provider && this->m_provider->isValid())
            this->m_provider->getBooklets();
        else
            qWarning()<< "Credentials are missing to get notes or the provider has not been set";

    emit this->booksReady(books);
}

void Syncer::insertBook(FMH::MODEL &book)
{
    if(!this->insertBookLocal(book))
    {
        qWarning()<< "Could not insert Book, Syncer::insertBook";
        return;
    }

    emit this->bookInserted(book, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Book inserted locally sucessfully"});
}

void Syncer::getBooklet(const QString &bookId)
{
    const auto res = this->db->getDBData(QString("select * from booklets where book = '%1'").arg(bookId));

    emit this->bookletReady(res);
}


void Syncer::updateBooklet(const QString &id, const QString &bookId, FMH::MODEL &booklet)
{
    if(!this->updateBookletLocal(id, bookId, booklet))
    {
        qWarning()<< "The booklet could not be updated locally, "
                     "therefore it was not attempted to update it on the remote server provider, "
                     "even if it existed.";
        return;
    }

    // to update remote booklet we need to pass the stamp as the id
    const auto stamp = Syncer::bookletStampFromId(this->db, id);
    qDebug()<< "booklet stamp from id" << stamp;

    if(!stamp.isEmpty())
        this->updateBookletRemote(stamp, bookId, booklet);

    emit this->bookletUpdated(booklet, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Booklet updated locally on the DB"});
}

void Syncer::insertBooklet(const QString &bookId, FMH::MODEL &booklet)
{
    if(!this->insertBookletLocal(bookId, booklet))
    {
        qWarning()<< "Could not insert Booklet, Syncer::insertBooklet";
        return;
    }

    this->insertBookletRemote(bookId, booklet);
    emit this->bookletInserted(booklet, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Booklet inserted locally sucessfully"});
}

void Syncer::addId(FMH::MODEL &model)
{
    const auto id = QUuid::createUuid().toString();
    model[FMH::MODEL_KEY::ID] = id;
}


const QString Syncer::noteIdFromStamp(DB *_db, const QString &provider, const QString &stamp)
{
    return [&]() -> QString {
        const auto data = _db->getDBData(QString("select id from notes_sync where server = '%1' AND stamp = '%2'").arg(provider, stamp));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::ID];
    }();
}

const QString Syncer::noteStampFromId(DB *_db, const QString &id)
{
    return [&]() -> QString {
        const auto data = _db->getDBData(QString("select stamp from notes_sync where id = '%1'").arg(id));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::STAMP];
    }();
}

const QString Syncer::bookletIdFromStamp(DB *_db, const QString &provider, const QString &stamp)
{
    return [&]() -> QString {
        const auto data = _db->getDBData(QString("select id from booklets_sync where server = '%1' AND stamp = '%2'").arg(provider, stamp));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::ID];
    }();
}

const QString Syncer::bookletStampFromId(DB *_db, const QString &id)
{
    return [&]() -> QString {
        const auto data = _db->getDBData(QString("select stamp from booklets_sync where id = '%1'").arg(id));
        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::STAMP];
    }();
}

void Syncer::setConections()
{
    connect(this->m_provider, &AbstractNotesProvider::noteInserted, [&](FMH::MODEL note)
    {
        qDebug()<< "STAMP OF THE NEWLY INSERTED NOTE" << note[FMH::MODEL_KEY::ID] << note;
        this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES_SYNC], FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::ID,
                                                                                                   FMH::MODEL_KEY::STAMP,
                                                                                                   FMH::MODEL_KEY::USER,
                                                                                                   FMH::MODEL_KEY::SERVER})));
        emit this->noteInserted(note, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Note inserted on server provider"});
    });

    connect(this->m_provider, &AbstractNotesProvider::bookletInserted, [&](FMH::MODEL booklet)
    {
        qDebug()<< "STAMP OF THE NEWLY INSERTED BOOKLET" << booklet[FMH::MODEL_KEY::ID] << booklet;
        this->db->insert(OWL::TABLEMAP[OWL::TABLE::BOOKLETS_SYNC], FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::ID,
                                                                                                         FMH::MODEL_KEY::STAMP,
                                                                                                         FMH::MODEL_KEY::USER,
                                                                                                         FMH::MODEL_KEY::SERVER})));
        emit this->bookletInserted(booklet, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Booklet inserted on server provider"});
    });

    connect(this->m_provider, &AbstractNotesProvider::notesReady, [&](FMH::MODEL_LIST notes)
    {
        //        qDebug()<< "SERVER NOETS READY "<< notes;

        //if there are no notes in the provider server, then just return
        if(notes.isEmpty())
            return;

        qDebug()<< "NOETS READY << " << notes;
        // there might be two case scenarios:
        // the note exists locally in the db, so it needs to be updated with the server version
        // the note does not exists locally, so it needs to be inserted into the db
        for(const auto &note : notes)
        {
            const auto id = Syncer::noteIdFromStamp(this->db, this->m_provider->provider(), note[FMH::MODEL_KEY::ID]);

            // if the id is empty then the note does nto exists, so ithe note is inserted into the local db
            if(id.isEmpty())
            {
                //here insert the note into the db
                auto __note = FMH::filterModel(note, {FMH::MODEL_KEY::TITLE,
                                                      FMH::MODEL_KEY::CONTENT,
                                                      FMH::MODEL_KEY::FAVORITE,
                                                      FMH::MODEL_KEY::MODIFIED,
                                                      FMH::MODEL_KEY::ADDDATE});

                __note[FMH::MODEL_KEY::MODIFIED] = QDateTime::fromSecsSinceEpoch(note[FMH::MODEL_KEY::MODIFIED].toInt()).toString(Qt::TextDate);
                __note[FMH::MODEL_KEY::ADDDATE] = __note[FMH::MODEL_KEY::MODIFIED];

                if(!this->m_notesController->insertNote(__note, this->localStoragePath(OWL::NotesPath)))
                {
                    qWarning()<< "Remote note could not be inserted to the local storage";
                    continue;
                }

                __note[FMH::MODEL_KEY::STAMP] = note[FMH::MODEL_KEY::ID];
                __note[FMH::MODEL_KEY::USER] = this->m_provider->user();
                __note[FMH::MODEL_KEY::SERVER] = this->m_provider->provider();


                this->db->insert(OWL::TABLEMAP[OWL::TABLE::NOTES_SYNC], FMH::toMap(FMH::filterModel(__note, {FMH::MODEL_KEY::ID,
                                                                                                             FMH::MODEL_KEY::STAMP,
                                                                                                             FMH::MODEL_KEY::USER,
                                                                                                             FMH::MODEL_KEY::SERVER})));
                emit this->noteInserted(__note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note inserted on local db, from the server provider"});


            }else
            {
                //the note exists in the db locally, so update it
                auto __note = FMH::filterModel(note, {FMH::MODEL_KEY::TITLE,
                                                      FMH::MODEL_KEY::CONTENT,
                                                      FMH::MODEL_KEY::MODIFIED,
                                                      FMH::MODEL_KEY::FAVORITE});
                __note[FMH::MODEL_KEY::MODIFIED] = QDateTime::fromSecsSinceEpoch(note[FMH::MODEL_KEY::MODIFIED].toInt()).toString(Qt::TextDate);
                this->updateNoteLocal(id, __note);
                emit this->noteUpdated(__note, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Note updated on local db, from the server provider"});
            }
        }

        this->collectAllNotes();
    });

    connect(this->m_provider, &AbstractNotesProvider::bookletsReady, [&](FMH::MODEL_LIST booklets)
    {
        //        qDebug()<< "SERVER NOETS READY "<< notes;

        //if there are no notes in the provider server, then just return
        if(booklets.isEmpty())
            return;

        qDebug()<< "Booklets READY << " << booklets;
        // there might be two case scenarios:
        // the booklet exists locally in the db, so it needs to be updated with the server version
        // the booklet does not exists locally, so it needs to be inserted into the db
        for(const auto &booklet : booklets)
        {
            const auto id = Syncer::bookletIdFromStamp(this->db, this->m_provider->provider(), booklet[FMH::MODEL_KEY::ID]); //the id is actually the stamp id

            // if the id is empty then the booklet does not exists, so insert the booklet into the local db
            if(id.isEmpty())
            {
                //here insert the note into the db
                auto __booklet = FMH::filterModel(booklet, {FMH::MODEL_KEY::TITLE,
                                                      FMH::MODEL_KEY::CONTENT,
                                                      FMH::MODEL_KEY::MODIFIED,
                                                      FMH::MODEL_KEY::ADDDATE});

                __booklet[FMH::MODEL_KEY::MODIFIED] = QDateTime::fromSecsSinceEpoch(booklet[FMH::MODEL_KEY::MODIFIED].toInt()).toString(Qt::TextDate);
                __booklet[FMH::MODEL_KEY::ADDDATE] = __booklet[FMH::MODEL_KEY::MODIFIED];

                if(!this->insertBookletLocal(booklet[FMH::MODEL_KEY::CATEGORY], __booklet))
                {
                    qWarning()<< "Remote booklet could not be inserted to the local storage";
                    continue;
                }

                __booklet[FMH::MODEL_KEY::STAMP] = booklet[FMH::MODEL_KEY::ID];
                __booklet[FMH::MODEL_KEY::USER] = this->m_provider->user();
                __booklet[FMH::MODEL_KEY::SERVER] = this->m_provider->provider();


                this->db->insert(OWL::TABLEMAP[OWL::TABLE::BOOKLETS_SYNC], FMH::toMap(FMH::filterModel(__booklet, {FMH::MODEL_KEY::ID,
                                                                                                             FMH::MODEL_KEY::STAMP,
                                                                                                             FMH::MODEL_KEY::USER,
                                                                                                             FMH::MODEL_KEY::SERVER})));
                emit this->bookletInserted(__booklet, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Booklet inserted on local db, from the server provider"});

            }else
            {
                //the booklet exists in the db locally, so update it
                auto __booklet = FMH::filterModel(booklet, {FMH::MODEL_KEY::TITLE,
                                                      FMH::MODEL_KEY::CONTENT,
                                                      FMH::MODEL_KEY::MODIFIED,
                                                      FMH::MODEL_KEY::FAVORITE});

                __booklet[FMH::MODEL_KEY::ID] = id;
                __booklet[FMH::MODEL_KEY::BOOK] = booklet[FMH::MODEL_KEY::CATEGORY];
                __booklet[FMH::MODEL_KEY::URL] = [&]()-> QString {
                        const auto data = this->db->getDBData(QString("select url from booklets where id = '%1'").arg(id));
                        return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::URL]; }();

                qDebug()<< " trying to update local booklets with url" <<  __booklet[FMH::MODEL_KEY::URL] << __booklet[FMH::MODEL_KEY::BOOK] << __booklet[FMH::MODEL_KEY::CONTENT]  ;
                __booklet[FMH::MODEL_KEY::MODIFIED] = QDateTime::fromSecsSinceEpoch(booklet[FMH::MODEL_KEY::MODIFIED].toInt()).toString(Qt::TextDate);
                this->updateBookletLocal(id, __booklet[FMH::MODEL_KEY::BOOK], __booklet);
                emit this->bookletUpdated(__booklet, {STATE::TYPE::LOCAL, STATE::STATUS::OK, "Booklet updated on local db, from the server provider"});
            }
        }

        emit this->booksReady(this->collectAllBooks()); //???
    });

    connect(this->m_provider, &AbstractNotesProvider::noteUpdated, [&](FMH::MODEL note)
    {
        const auto id = Syncer::noteIdFromStamp(this->db, this->m_provider->provider(), note[FMH::MODEL_KEY::ID]);
        if(!note.isEmpty())
            this->updateNoteLocal(id, FMH::filterModel(note, {FMH::MODEL_KEY::TITLE}));
        emit this->noteUpdated(note, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Note updated on server provider"});
    });

    connect(this->m_provider, &AbstractNotesProvider::bookletUpdated, [&](FMH::MODEL booklet)
    {
        const auto id = Syncer::bookletIdFromStamp(this->db, this->m_provider->provider(), booklet[FMH::MODEL_KEY::ID]);
        if(!booklet.isEmpty())
        {
            booklet[FMH::MODEL_KEY::ID] = id;
            booklet[FMH::MODEL_KEY::BOOK] = booklet[FMH::MODEL_KEY::CATEGORY];
            booklet[FMH::MODEL_KEY::URL] = [&]()-> QString {
                    const auto data = this->db->getDBData(QString("select url from booklets where id = '%1'").arg(id));
                    return data.isEmpty() ? QString() : data.first()[FMH::MODEL_KEY::URL]; }();
            this->updateBookletLocal(id, booklet[FMH::MODEL_KEY::BOOK], FMH::filterModel(booklet, {FMH::MODEL_KEY::TITLE}));
        }

        emit this->bookletUpdated(booklet, {STATE::TYPE::REMOTE, STATE::STATUS::OK, "Booklet updated on server provider"});
    });

    connect(this->m_provider, &AbstractNotesProvider::noteRemoved, [&]()
    {
        emit this->noteRemoved(FMH::MODEL(), {STATE::TYPE::REMOTE, STATE::STATUS::OK, "The note has been removed from the remove server provider"});
    });
}



bool Syncer::updateNoteLocal(const QString &id, const FMH::MODEL &note)
{
    for(const auto &tg : note[FMH::MODEL_KEY::TAG])
        this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id);

//    this->saveNoteFile(OWL::NotesPath, note);

    return this->db->update(OWL::TABLEMAP[OWL::TABLE::NOTES],
            FMH::toMap(FMH::filterModel(note, {FMH::MODEL_KEY::TITLE,
                                               FMH::MODEL_KEY::COLOR,
                                               FMH::MODEL_KEY::PIN,
                                               FMH::MODEL_KEY::MODIFIED,
                                               FMH::MODEL_KEY::FAVORITE})), QVariantMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}});
}

void Syncer::updateNoteRemote(const QString &id, const FMH::MODEL &note)
{
    if(this->m_provider && this->m_provider->isValid())
        this->m_provider->updateNote(id, note);
}

bool Syncer::removeNoteLocal(const QString &id)
{
    this->db->remove(OWL::TABLEMAP[OWL::TABLE::NOTES_SYNC], {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}});
    return this->db->remove(OWL::TABLEMAP[OWL::TABLE::NOTES], {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id}});
}

void Syncer::removeNoteRemote(const QString &id)
{
    if(this->m_provider && this->m_provider->isValid())
        this->m_provider->removeNote(id);
}

bool Syncer::insertBookLocal(FMH::MODEL &book)
{
    const auto __path = QUrl::fromLocalFile(OWL::BooksPath.toString()+book[FMH::MODEL_KEY::TITLE]);
    if(FMH::fileExists(__path))
    {
        qWarning()<< "The directory for the book already exists. Syncer::insertBookLocal" << book[FMH::MODEL_KEY::TITLE];
        return false;
    }

    if(!FMStatic::createDir(QUrl::fromLocalFile(OWL::BooksPath.toString()), book[FMH::MODEL_KEY::TITLE]))
    {
        qWarning() << "Could not create directory for the given book name. Syncer::insertBookLocal" << book[FMH::MODEL_KEY::TITLE];
        return false;
    }

    book[FMH::MODEL_KEY::URL] = __path.toString();

    return(this->db->insert(OWL::TABLEMAP[OWL::TABLE::BOOKS], FMH::toMap(FMH::filterModel(book,{FMH::MODEL_KEY::URL,
                                                                                                FMH::MODEL_KEY::TITLE,
                                                                                                FMH::MODEL_KEY::FAVORITE,
                                                                                                FMH::MODEL_KEY::ADDDATE,
                                                                                                FMH::MODEL_KEY::MODIFIED}
                                                                                          ))));
}

void Syncer::insertBookRemote(FMH::MODEL &book)
{

}

bool Syncer::updateBookLocal(const QString &id, const FMH::MODEL &book)
{
    return false;
}

void Syncer::updateBookRemote(const QString &id, const FMH::MODEL &book)
{

}

bool Syncer::removeBookLocal(const QString &id)
{

    return false;
}

void Syncer::removeBookRemote(const QString &id)
{

}

bool Syncer::insertBookletLocal(const QString &bookId, FMH::MODEL &booklet)
{
    qDebug()<< "trying to insert booklet" << booklet;
    if(bookId.isEmpty() || booklet.isEmpty())
    {
        qWarning()<< "Could not insert booklet. Reference to book id or booklet are empty";
        return false;
    }

    Syncer::addId(booklet); //adds a local id to the booklet

    if(!FMH::fileExists(QUrl::fromLocalFile(OWL::BooksPath.toString()+bookId)))
    {
        qWarning()<< "The book does not exists in the db or the directory is missing. Syncer::insertBookletLocal. "
                     "Creating a new book registry" << bookId;

        FMH::MODEL __book;
        __book[FMH::MODEL_KEY::TITLE] = bookId;
        this->insertBook(__book);
    }

//    const auto __bookletPath = Syncer::saveNoteFile(OWL::BooksPath.toString()+bookId+"/", booklet);

//    if(__bookletPath.isEmpty())
//    {
//        qWarning()<< "File could not be saved. Syncer::insertBookletLocal";
//        return false;
//    }

//    booklet[FMH::MODEL_KEY::URL] = __bookletPath.toString();
//    booklet[FMH::MODEL_KEY::BOOK] = bookId;
//    qDebug()<< "booklet saved to <<" << __bookletPath;

//    auto __bookletMap = FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::ID,
//                                                              FMH::MODEL_KEY::BOOK,
//                                                              FMH::MODEL_KEY::TITLE,
//                                                              FMH::MODEL_KEY::URL,
//                                                              FMH::MODEL_KEY::MODIFIED,
//                                                              FMH::MODEL_KEY::ADDDATE}));


//    if(this->db->insert(OWL::TABLEMAP[OWL::TABLE::BOOKLETS], __bookletMap))
//    {
//        //        for(const auto &tg : booklet[FMH::MODEL_KEY::TAG].split(",", QString::SplitBehavior::SkipEmptyParts))
//        //            this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], booklet[FMH::MODEL_KEY::ID], booklet[FMH::MODEL_KEY::COLOR]);

//        return true;
//    }

    return false;
}

void Syncer::insertBookletRemote(const QString &bookId, FMH::MODEL &booklet)
{
    qDebug()<< "trying to insert booklet remotely" << (this->m_provider ? "provider exists" : "failed provider") << this->m_provider->isValid();
    booklet[FMH::MODEL_KEY::CATEGORY] = bookId;
    if(this->m_provider && this->m_provider->isValid())
        this->m_provider->insertBooklet(booklet);
}

bool Syncer::updateBookletLocal(const QString &id, const QString &bookId, const FMH::MODEL &booklet)
{
    //    for(const auto &tg : booklet[FMH::MODEL_KEY::TAG])
    //        this->tag->tagAbstract(tg, OWL::TABLEMAP[OWL::TABLE::NOTES], id);

    const QUrl __path = QFileInfo(booklet[FMH::MODEL_KEY::URL]).dir().path();
//    const auto __bookletPath = Syncer::saveNoteFile(__path.toLocalFile()+"/", booklet);
//    qDebug()<< "Updating local txt file as"<< __path.toLocalFile() << __bookletPath;

//    if(__bookletPath.isEmpty())
//    {
//        qWarning()<< "File could not be saved. Syncer::insertBookletLocal";
//        return false;
//    }

    return this->db->update(OWL::TABLEMAP[OWL::TABLE::BOOKLETS],
            FMH::toMap(FMH::filterModel(booklet, {FMH::MODEL_KEY::TITLE,
                                                  FMH::MODEL_KEY::MODIFIED,
                                                  FMH::MODEL_KEY::FAVORITE})),
            QVariantMap {{FMH::MODEL_NAME[FMH::MODEL_KEY::ID], id},
        {FMH::MODEL_NAME[FMH::MODEL_KEY::BOOK], bookId}});

}

void Syncer::updateBookletRemote(const QString &id, const QString &bookId, FMH::MODEL &booklet)
{
    booklet[FMH::MODEL_KEY::CATEGORY] = bookId;
    if(this->m_provider && this->m_provider->isValid())
        this->m_provider->updateBooklet(id, booklet);
}

bool Syncer::removeBookletLocal(const QString &id)
{
    return false;
}

void Syncer::removeBookletRemote(const QString &id)
{

}

void Syncer::collectAllNotes()
{
    this->m_notesController->getNotes(OWL::NotesPath);
}

const FMH::MODEL_LIST Syncer::collectAllBooks()
{
    //    return this->db->getDBData("select b.*, count(distinct bl.id) as count from books b inner join booklets bl on bl.book = b.id");
    return this->db->getDBData("select * from books");
}

const QUrl Syncer::localStoragePath(const QUrl &pathHint)
{
    if(!this->m_provider || !this->m_provider->isValid())
    {
        qWarning()<< "There is not a Provider setup for saving the notes. Saving locally now  to " << pathHint;
        return pathHint;
    }

    QUrl res = pathHint.toString() + this->m_provider->provider()+"/"+this->m_provider->user()+"/";
    QDir dir(res.toLocalFile());
    if(!dir.exists())
    {
        if(dir.mkpath("."))
             return res;
        else return pathHint;

    }else return res;
}

const QString Syncer::noteFileContent(const QUrl &path)
{
    if(!path.isLocalFile())
    {
        qWarning()<< "Can not open note file, the url is not a local path";
        return QString();
    }
    QFile file(path.toLocalFile());
    file.open(QFile::ReadOnly);
    const auto content = file.readAll();
    file.close();

    return QString(content);
}
