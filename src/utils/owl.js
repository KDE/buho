function saveNote(title, body, color, tags)
{
    return owl.insertNote(title, body, color, tags)
}

function removeNote(note)
{
    var map = {id: note.id }
    return owl.removeNote(map)
}

function removeLink(link)
{
    var map = {link: link.link }
    return owl.removeLink(map)
}
