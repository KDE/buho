#include "buho.h"
#include "owl.h"

Buho::Buho(QObject *parent)
    : QObject(parent)
{
    this->setFolders();
}

void Buho::setFolders()
{
    QDir notes_path(OWL::NotesPath.toLocalFile());
    if (!notes_path.exists())
        notes_path.mkpath(".");

    QDir books_path(OWL::BooksPath.toLocalFile());
    if (!books_path.exists())
        books_path.mkpath(".");
}
