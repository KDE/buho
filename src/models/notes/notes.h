#ifndef NOTES_H
#define NOTES_H

#include "owl.h"
#include <QObject>

#include <MauiKit/Core/fmh.h>
#include <MauiKit/Core/mauilist.h>

class NotesSyncer;
class Notes : public MauiList
{
    Q_OBJECT
    Q_PROPERTY(QString tag READ tag WRITE setTag NOTIFY tagChanged)

public:
    explicit Notes(QObject *parent = nullptr);
    const FMH::MODEL_LIST &items() const override final;
    void componentComplete() override final;

    QString tag() const;

private:
    NotesSyncer *syncer;

    FMH::MODEL_LIST notes;
    QVariantMap m_account;

    void setList();
    void sortList();

    void appendNote(FMH::MODEL note);

    QString m_tag;

public slots:
    bool insert(const QVariantMap &note);
    bool update(const QVariantMap &data, const int &index);
    bool remove(const int &index);
    int indexOfNote(const QUrl &url);

    int indexOfName(const QString &query);

    void setTag(QString tag);

signals:
    void tagChanged(QString tag);
};

#endif // NOTES_H
