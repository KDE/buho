/***
Pix  Copyright (C) 2018  Camilo Higuita
This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
This is free software, and you are welcome to redistribute it
under certain conditions; type `show c' for details.

 This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***/

#include "db.h"
#include <QCoreApplication>
#include <QSqlQuery>
#include <QString>
#include <QStringList>
#include <QUuid>

DB::DB()
    : QObject(nullptr)
{
    QDir collectionDBPath_dir(OWL::CollectionDBPath.toLocalFile());
    if (!collectionDBPath_dir.exists())
        collectionDBPath_dir.mkpath(".");

    this->name = QUuid::createUuid().toString();
    if (!FMH::fileExists(QUrl(OWL::CollectionDBPath.toString() + OWL::DBName))) {
        this->openDB(this->name);
        qDebug() << "Collection doesn't exists, trying to create it" << OWL::CollectionDBPath.toString() + OWL::DBName;
        this->prepareCollectionDB();
    } else
        this->openDB(this->name);
}

DB::~DB()
{
    qDebug() << "DELETING LOCAL DB";
    this->m_db.close();
}

void DB::openDB(const QString &name)
{
    if (!QSqlDatabase::contains(name)) {
        this->m_db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"), name);
        this->m_db.setDatabaseName(OWL::CollectionDBPath.toLocalFile() + OWL::DBName);
    }

    if (!this->m_db.isOpen()) {
        if (!this->m_db.open())
            qDebug() << "ERROR OPENING DB" << this->m_db.lastError().text() << m_db.connectionName();
    }
    auto query = this->getQuery("PRAGMA synchronous=OFF");
    query.exec();
}

void DB::prepareCollectionDB() const
{
    QSqlQuery query(this->m_db);

    QFile file(":/db/script.sql");

    if (!file.exists()) {
        QString log = QStringLiteral("Fatal error on build database. The file '");
        log.append(file.fileName() + QStringLiteral("' for database and tables creation query cannot be not found!"));
        qDebug() << log;
        return;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << QStringLiteral("Fatal error on try to create database! The file with sql queries for database creation cannot be opened!");
        return;
    }

    bool hasText;
    QString line;
    QByteArray readLine;
    QString cleanedLine;
    QStringList strings;

    while (!file.atEnd()) {
        hasText = false;
        line = "";
        readLine = "";
        cleanedLine = "";
        strings.clear();
        while (!hasText) {
            readLine = file.readLine();
            cleanedLine = readLine.trimmed();
            strings = cleanedLine.split("--");
            cleanedLine = strings.at(0);
            if (!cleanedLine.startsWith("--") && !cleanedLine.startsWith("DROP") && !cleanedLine.isEmpty())
                line += cleanedLine;
            if (cleanedLine.endsWith(";"))
                break;
            if (cleanedLine.startsWith("COMMIT"))
                hasText = true;
        }
        if (!line.isEmpty()) {
            if (!query.exec(line)) {
                qDebug() << "exec failed" << query.lastQuery() << query.lastError();
            }

        } else
            qDebug() << "exec wrong" << query.lastError();
    }
    file.close();
}

bool DB::checkExistance(const QString &tableName, const QString &searchId, const QString &search)
{
    auto queryStr = QString("SELECT %1 FROM %2 WHERE %3 = \"%4\"").arg(searchId, tableName, searchId, search);
    auto query = this->getQuery(queryStr);

    if (query.exec()) {
        if (query.next())
            return true;
    } else
        qDebug() << query.lastError().text();

    return false;
}

const FMH::MODEL_LIST DB::getDBData(const QString &queryTxt)
{
    FMH::MODEL_LIST mapList;

    auto query = this->getQuery(queryTxt);

    if (query.exec()) {
        const auto keys = FMH::MODEL_NAME.keys();
        while (query.next()) {
            FMH::MODEL data;

            for (const auto &key : keys)
            {
                if (query.record().indexOf(FMH::MODEL_NAME[key]) > -1)
                {
                    data.insert(key, query.value(FMH::MODEL_NAME[key]).toString());
                }
            }

            mapList << data;
        }

    } else
        qDebug() << query.lastError() << query.lastQuery();

    return mapList;
}

QSqlQuery DB::getQuery(const QString &queryTxt)
{
    QSqlQuery query(queryTxt, this->m_db);
    return query;
}

bool DB::insert(const QString &tableName, const QVariantMap &insertData)
{
    qDebug() << "TRY TO ISNERT NOTE TO DB" << insertData;
    if (tableName.isEmpty()) {
        qDebug() << QStringLiteral("Fatal error on insert! The table name is empty!");
        return false;

    } else if (insertData.isEmpty()) {
        qDebug() << QStringLiteral("Fatal error on insert! The insertData is empty!");
        return false;
    }

    QStringList strValues;
    QStringList fields = insertData.keys();
    QVariantList values = insertData.values();
    int totalFields = fields.size();
    for (int i = 0; i < totalFields; ++i)
        strValues.append("?");

    QString sqlQueryString = "INSERT INTO " + tableName + " (" + QString(fields.join(",")) + ") VALUES(" + QString(strValues.join(",")) + ")";
    QSqlQuery query(this->m_db);
    query.prepare(sqlQueryString);

    int k = 0;
    for(const QVariant &value : values)
        query.bindValue(k++, value);

    return query.exec();
}

bool DB::update(const QString &tableName, const QVariantMap &updateData, const QVariantMap &where)
{
    if (tableName.isEmpty()) {
        qDebug() << QStringLiteral("Fatal error on insert! The table name is empty!");
        return false;
    } else if (updateData.isEmpty()) {
        qDebug() << QStringLiteral("Fatal error on insert! The insertData is empty!");
        return false;
    }

    QStringList set;
    const auto updateKeys = updateData.keys();
    for (const auto &key : updateKeys)
    {
        set.append(key + " = ?");
    }

    QStringList condition;
    const auto whereKeys = where.keys();
    for (const auto &key : whereKeys)
    {
        condition.append(key + " = '" + where[key].toString() + "'");
    }

    QString sqlQueryString = "UPDATE " + tableName + " SET " + QString(set.join(",")) + " WHERE " + QString(condition.join(" AND "));
    auto query = this->getQuery(sqlQueryString);

    QVariantList values = updateData.values();
    int k = 0;
    for(const QVariant &value : values)
    {
        query.bindValue(k++, value);
    }

    qDebug() << query.lastQuery();
    return query.exec();
}

bool DB::update(const QString &table, const QString &column, const QVariant &newValue, const QVariant &op, const QString &id)
{
    auto queryStr = QString("UPDATE %1 SET %2 = \"%3\" WHERE %4 = \"%5\"").arg(table, column, newValue.toString().replace("\"", "\"\""), op.toString(), id);
    auto query = this->getQuery(queryStr);
    return query.exec();
}

bool DB::remove(const QString &tableName, const QVariantMap &removeData)
{
    if (tableName.isEmpty()) {
        qDebug() << QStringLiteral("Fatal error on removing! The table name is empty!");
        return false;

    } else if (removeData.isEmpty()) {
        qDebug() << QStringLiteral("Fatal error on insert! The removeData is empty!");
        return false;
    }

    QStringList set;
    const auto removeKeys = removeData.keys();
    for (const auto &key : removeKeys)
    {
        set.append(key + " = ?");
    }

    QString sqlQueryString = "DELETE FROM " + tableName + " WHERE " + QString(set.join(" AND "));
    qDebug() << sqlQueryString;

    auto query = this->getQuery(sqlQueryString);

    QVariantList values = removeData.values();

    int k = 0;
    for(const QVariant &value : values)
        query.bindValue(k++, value);

    return query.exec();
}
