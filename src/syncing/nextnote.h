#ifndef NEXTNOTE_H
#define NEXTNOTE_H

#include <QObject>
#include <QString>
#include "abstractnotessyncer.h"

/**
 * @brief The NextNote class follows the NextCloud API specification
 *  for syncing notes.
 */

class NextNote : public AbstractNotesSyncer
{
    Q_OBJECT
public:
    explicit NextNote(QObject *parent = nullptr);
    ~NextNote();
    void getNote(const QString &id) const override final;
    void getNotes() override final;
    void insertNote(const FMH::MODEL &note) const override final;
    void updateNote(const QString &id, const FMH::MODEL &note) const override final;
    void removeNote(const QString &id) const override final;

private:
    static QString API;
    static QString formatUrl(const QString &user, const QString &password, const QString &provider);


signals:

public slots:
};

#endif // NEXTNOTE_H
