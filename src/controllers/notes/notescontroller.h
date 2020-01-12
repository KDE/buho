#ifndef NOTESCONTROLLER_H
#define NOTESCONTROLLER_H

#include <QObject>

class NotesController : public QObject
{
    Q_OBJECT
public:
    explicit NotesController(QObject *parent = nullptr);

signals:

};

#endif // NOTESCONTROLLER_H
