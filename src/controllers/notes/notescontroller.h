#pragma once

#include <QObject>
#include <QThread>

#include <MauiKit4/Core/fmh.h>

#include "owl.h"

class DB;
class NotesLoader : public QObject
{
    Q_OBJECT
public:
    void fetchNotes(FMH::MODEL_LIST notes);

Q_SIGNALS:
    void noteReady(FMH::MODEL note);
    void notesReady(FMH::MODEL_LIST notes);
};

class NotesController : public QObject
{
    Q_OBJECT
public:
    explicit NotesController(QObject *parent = nullptr);
    ~NotesController();

public Q_SLOTS:
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
    bool insertNote(FMH::MODEL &note);
    bool updateNote(FMH::MODEL &note, QString id);
    bool removeNote(const QString &id);

    void getNotes();

private:
    QThread m_worker;
    DB *m_db;

Q_SIGNALS:
    void noteReady(FMH::MODEL note);
    void notesReady(FMH::MODEL_LIST notes);
    void noteInserted(FMH::MODEL note);
    void noteUpdated(FMH::MODEL note);
    void fetchNotes(FMH::MODEL_LIST notes);
};
