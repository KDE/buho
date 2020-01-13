#ifndef OWL_H
#define OWL_H

#include <QString>
#include <QDebug>
#include <QStandardPaths>
#include <QImage>
#include <QUrl>

#ifndef STATIC_MAUIKIT
#include "../buho_version.h"
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

    const static inline QString CollectionDBPath = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)+"/buho/";
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
}


#endif // OWL_H
