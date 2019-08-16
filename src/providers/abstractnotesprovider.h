#ifndef ABSTRACTNOTESPROVIDER_H
#define ABSTRACTNOTESPROVIDER_H

#include <QObject>
#include <functional>
#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif
/**
 * @brief The AbstractNoteSyncer class
 * is an abstraction for different services backend to sync notes.
 * Different services to be added to Buho are expected to derived from this.
 */

class AbstractNotesProvider : public QObject
{
    Q_OBJECT

public:
    AbstractNotesProvider(QObject *parent) : QObject(parent) {}
    virtual ~AbstractNotesProvider() {}

    /**
     * @brief setCredentials
     * sets the credential to authenticate to the provider server
     * @param account
     * the account data is represented by FMH::MODEL
     */
    virtual void setCredentials(const FMH::MODEL &account) final
    {
        this->m_user = account[FMH::MODEL_KEY::USER];
        this->m_password = account[FMH::MODEL_KEY::PASSWORD];
        this->m_provider = QUrl(account[FMH::MODEL_KEY::SERVER]).host();
    }

    virtual QString user() final { return this->m_user; }
    virtual QString provider() final { return this->m_provider; }

    /**
     * @brief isValid
     * check if the account acredentials are valid
     * by checking they are not empty or null
     * @return
     * true if the credentials are all set or false is somethign is missing
     */
    virtual bool isValid()
    {
        return !(this->m_user.isEmpty() || this->m_user.isNull()
                 || this->m_provider.isEmpty() || this->m_provider.isNull()
                 || this->m_password.isEmpty() || this->m_password.isNull());
    }

    /**
     * @brief getNote
     * gets a note identified by an ID
     * @param id
     * When the process is done it shoudl emit the noteReady(FMH::MODEL) signal
     */
//    virtual FMH::MODEL getNote(const QString &id) = 0;
    virtual void getNote(const QString &id) = 0;

    /**
     * @brief getNotes
     * returns all the notes or queried notes
     *  When the process is done it shoudl emit the notesReady(FMH::MODEL_LIST) signal
     */
    virtual void getNotes() = 0;
//    virtual void getNotes() const {}
//    virtual FMH::MODEL_LIST getNotes(const QString &query = QString()) = 0;
//    virtual FMH::MODEL_LIST getNotes(const QString &query = QString()) const = 0;


    /**
     * @brief insertNote
     * inserts a new note to the server
     * @param note
     * takes the new note to be inserted represented as FMH::MODEL
     * When the process is done it shoudl emit the noteInserted(FMH::MODEL) signal
     */
//    virtual bool insertNote(const FMH::MODEL &note) = 0;
    virtual void insertNote(const FMH::MODEL &note) = 0;

    /**
     * @brief updateNote
     * allows to update a note in the server, it takes an ID and the updated note
     * @param id
     * id of the note to be updated
     * @param note
     * the note prepresented as FMH::MODEL contening the up-to-date values
     * When the process is done it shoudl emit the noteUpdated(FMH::MODEL) signal
     */
//    virtual bool updateNote(const QString &id, const FMH::MODEL &note) = 0;
    virtual void updateNote(const QString &id, const FMH::MODEL &note) = 0;

    /**
     * @brief removeNote
     * removes a note from the server
     * @param id
     * ID of the note to be removed
     * When the process is done it shoudl emit the noteRemoved(FMH::MODEL) signal
     */
//    virtual bool removeNote(const QString &id) = 0;
    virtual void removeNote(const QString &id) = 0;

protected:
    QString m_user = "";
    QString m_password = "";
    QString m_provider = "";

    template<typename T>
     void request(const QString &url, const QMap<QString, QString> &header, T cb)
//    inline void request(const QString &url, const QMap<QString, QString> &header, std::function<void (QByteArray)>cb)
    {
        auto downloader = new FMH::Downloader;
        connect(downloader, &FMH::Downloader::dataReady, [&, downloader = std::move(downloader)](const QByteArray &array)
        {
//            if(cb != nullptr)
                cb(array);
            downloader->deleteLater();
        });

        downloader->getArray(url, header);
    }

signals:
    void noteReady(FMH::MODEL note);
    void notesReady(FMH::MODEL_LIST notes);
    void noteInserted(FMH::MODEL note);
    void noteUpdated(FMH::MODEL note);
    void noteRemoved(FMH::MODEL note);

    /**
     * @brief responseReady
     * gets emitted when the data is ready after requesting the array
     * with &Downloader::getArray()
     */
    void responseReady(QByteArray array);

    /**
     * @brief responseError
     * emitted if there's an error when trying to get the array
     */
    void responseError(QString);

};


#endif // ABSTRACTNOTESPROVIDER_H


