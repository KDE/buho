#ifndef NEXTNOTE_H
#define NEXTNOTE_H

#include <QObject>
#include <QString>
#include "abstractnotessyncer.h"
#include<functional>
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
    static FMH::MODEL_LIST parseNotes(const QByteArray &array);

//    template<typename T>
//    void request(const QString &url, const QMap<QString, QString> &header, T cb);
//    void request(const QString &url, const QMap<QString, QString> &header,  std::function<void (QByteArray)>cb);

signals:

public slots:
    void sendNotes(QByteArray array);
};

#endif // NEXTNOTE_H
