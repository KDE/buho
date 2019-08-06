#ifndef ABSTRACTNOTESYNCER_H
#define ABSTRACTNOTESYNCER_H

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

class AbstractNotesSyncer : public QObject
{
    Q_OBJECT

public:
    AbstractNotesSyncer(QObject *parent) : QObject(parent) {};
    virtual ~AbstractNotesSyncer() {};

    virtual void setCredentials(const QString &user, const QString &password, const QString &provider) final
    {
        this->m_user = user;
        this->m_password = password;
        this->m_provider = provider;
    }

    /**
     * @brief getNote
     * gets a note identified by an ID
     * @param id
     * When the process is done it shoudl emit the noteReady(FMH::MODEL) signal
     */
//    virtual FMH::MODEL getNote(const QString &id) = 0;
    virtual void getNote(const QString &id) const = 0;

    /**
     * @brief getNotes
     * returns all the notes or queried notes
     *  When the process is done it shoudl emit the notesReady(FMH::MODEL_LIST) signal
     */
    virtual void getNotes() {}
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
    virtual void insertNote(const FMH::MODEL &note) const = 0;

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
    virtual void updateNote(const QString &id, const FMH::MODEL &note) const = 0;

    /**
     * @brief removeNote
     * removes a note from the server
     * @param id
     * ID of the note to be removed
     * When the process is done it shoudl emit the noteRemoved(FMH::MODEL) signal
     */
//    virtual bool removeNote(const QString &id) = 0;
    virtual void removeNote(const QString &id) const = 0;

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


#endif // ABSTRACTNOTESYNCER_H


