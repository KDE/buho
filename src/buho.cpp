#include "buho.h"

Buho::Buho(QObject *parent) : DBActions(parent)
{
    this->setFolders();
}

Tagging *Buho::getTagging()
{
    return this->tag;
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
