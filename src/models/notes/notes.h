#ifndef NOTES_H
#define NOTES_H

#include "owl.h"
#include <QObject>

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class NotesSyncer;
class Notes : public MauiList
{
    Q_OBJECT

public:
    explicit Notes(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override final;

private:
    NotesSyncer *syncer;

    FMH::MODEL_LIST notes;
    QVariantMap m_account;

    void sortList();

    void appendNote(FMH::MODEL note);

public slots:
    QVariantMap get(const int &index) const;
    bool insert(const QVariantMap &note);
    bool update(const QVariantMap &data, const int &index);
    bool remove(const int &index);
    int indexOfNote(const QUrl &url);
};

#endif // NOTES_H
