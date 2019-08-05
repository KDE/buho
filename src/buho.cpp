#include "buho.h"
#include "owl.h"

Buho::Buho(QObject *parent) : QObject(parent)
{
    this->setFolders();
}

void Buho::setFolders()
{
    QDir notes_path(OWL::NotesPath);
    if (!notes_path.exists())
        notes_path.mkpath(".");

    QDir links_path(OWL::LinksPath);
    if (!links_path.exists())
        links_path.mkpath(".");

    QDir books_path(OWL::BooksPath);
    if (!books_path.exists())
        books_path.mkpath(".");
}
