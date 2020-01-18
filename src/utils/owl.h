#ifndef OWL_H
#define OWL_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QImage>
#include <QUrl>
#include <QUuid>

#ifndef STATIC_MAUIKIT
#include "../buho_version.h"
#endif

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#else
#include <MauiKit/fmh.h>
#endif

namespace OWL
{
Q_NAMESPACE
enum class TABLE : uint8_t
{
    NOTES,
    NOTES_SYNC,
    BOOKS,
    BOOKLETS,
    BOOKLETS_SYNC,
    LINKS,
    NONE
};

static const QMap<TABLE,QString> TABLEMAP =
{
    {TABLE::NOTES,"notes"},
    {TABLE::NOTES_SYNC,"notes_sync"},
    {TABLE::BOOKS,"books"},
    {TABLE::BOOKLETS,"booklets"},
    {TABLE::BOOKLETS_SYNC,"booklets_sync"},
    {TABLE::LINKS,"links"},
};

const static inline QUrl CollectionDBPath = QUrl::fromLocalFile (QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/");
const static inline  QUrl NotesPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/notes/");
const static inline  QUrl BooksPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/books/");
const static inline  QUrl LinksPath = QUrl::fromLocalFile(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/links/");

const static inline  QString App = "Buho";
const static inline  QString version = BUHO_VERSION_STRING;
const static inline  QString comment = "Notes taking and link collector manager";
const static inline  QString DBName = "collection.db";

inline QString saveImage(QByteArray array, const QString &path)
{
    if(!array.isNull()&&!array.isEmpty())
    {
        QImage img;
        img.loadFromData(array);
        QString name = path;
        name.replace("/", "-");
        name.replace("&", "-");
        QString format = "JPEG";
        if (img.save(path+".jpg", format.toLatin1(), 100))
            return path+".jpg";
        else  qDebug() << "couldn't save artwork";
    }else qDebug()<<"array is empty";

    return QString();
}

static inline  bool saveNoteFile(const QUrl &url, const QByteArray &data)
{
    if(data.isEmpty())
    {
        qWarning() << "the note is empty, therefore it could not be saved into a file" << url;
        return false;
    }

    if(url.isEmpty () || !url.isValid())
    {
        qWarning() << "the url is not valid or is empty, therefore it could not be saved into a file" << url;
        return false;
    }

    QFile file(url.toLocalFile());
    if(file.open(QFile::WriteOnly))
    {
        file.write(data);
        file.close();
        return true;
    }else qWarning() << "Couldn-t open file to writte the text "<< url;

    return false;
}
static inline const QString createId ()
{
    return QUuid::createUuid().toString();
}

static inline  const QString fileContentPreview(const QUrl & path)
{
    if(!path.isLocalFile())
    {
        qWarning()<< "Can not open note file, the url is not a local path";
        return QString();
    }

    if(!FMH::fileExists (path))
        return QString();

    QFile file(path.toLocalFile());
    if(file.open(QFile::ReadOnly))
    {
        const auto content = file.read(512);
        file.close();
        return QString(content);
    }

    return QString();
}
}



#endif // OWL_H
