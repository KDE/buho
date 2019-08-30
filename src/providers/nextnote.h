#ifndef NEXTNOTE_H
#define NEXTNOTE_H

#include <QObject>
#include <QString>
#include "abstractnotesprovider.h"
#include<functional>
/**
 * @brief The NextNote class follows the NextCloud API specification
 *  for syncing notes.
 */

class NextNote : public AbstractNotesProvider
{
    Q_OBJECT
public:
    explicit NextNote(QObject *parent = nullptr);
    ~NextNote() override final;
    void getNote(const QString &id) override final;
    void getBooklet(const QString &id) override final;

    void getNotes() override final;
    void getBooklets() override final;

    void insertNote(const FMH::MODEL &note) override final;
    void insertBooklet(const FMH::MODEL &booklet) override final;

    void updateNote(const QString &id, const FMH::MODEL &note) override final;
    void updateBooklet(const QString &id, const FMH::MODEL &booklet) override final;

    void removeNote(const QString &id) override final;
    void removeBooklet(const QString &id) override final;

private:
    const static QString API;
    static const QString formatUrl(const QString &user, const QString &password, const QString &provider);
    static const FMH::MODEL_LIST parseNotes(const QByteArray &array);

//    template<typename T>
//    void request(const QString &url, const QMap<QString, QString> &header, T cb);
//    void request(const QString &url, const QMap<QString, QString> &header,  std::function<void (QByteArray)>cb);

signals:

public slots:
    void sendNotes(QByteArray array);
};

#endif // NEXTNOTE_H
