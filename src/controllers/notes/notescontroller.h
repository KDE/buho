#ifndef NOTESCONTROLLER_H
#define NOTESCONTROLLER_H

#include <QObject>
#include <QThread>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

class NotesLoader : public QObject
{
    Q_OBJECT
public:
    void fetchNotes(const QUrl &url);

signals:
    void noteReady(FMH::MODEL note);
    void notesReady(FMH::MODEL_LIST notes);
};

class NotesController : public QObject
{
    Q_OBJECT
public:
    explicit NotesController(QObject *parent = nullptr);
    ~NotesController();

public slots:
    /**
     * @brief insertNote
     * performs the insertion of a new note in the local storage
     * @param note
     * note to be inserted
     * @param url
     * url where to save the note
     * @return bool
     * true if the note was inserted sucessfully in the local storage
     */
    bool insertNote(const FMH::MODEL &note, const QUrl &url);

    void getNotes(const QUrl &url);

private:
    QThread m_worker;
    static inline const QUrl saveNoteFile(const QUrl &url, const FMH::MODEL &data);

signals:
    void noteReady(FMH::MODEL note);
    void notesReady(FMH::MODEL_LIST notes);
    void noteInserted(FMH::MODEL note);

    void fetchNotes(QUrl url);

};

#endif // NOTESCONTROLLER_H
