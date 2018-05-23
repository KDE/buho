/***
Buho  Copyright (C) 2018  Camilo Higuita
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

#ifndef DBACTIONS_H
#define DBACTIONS_H

#include <QObject>
#include "db.h"

class DBActions : public DB
{
    Q_OBJECT
public:
    explicit DBActions(QObject *parent = nullptr);
    ~DBActions();

    Q_INVOKABLE QVariantList get(const QString &queryTxt);

    /*main actions*/
    Q_INVOKABLE bool insertNote(const QString &title, const QString &body, const QString &color = QString(), const QString &tags = QString());

protected:
    OWL::DB_LIST getDBData(const QString &queryTxt);
    bool execQuery(const QString &queryTxt);


signals:
    void tagAdded(QString tag);
};

#endif // DBACTIONS_H
