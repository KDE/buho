import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.maui 1.0 as Maui

import "src/widgets"
import "src/views/notes"
import "src/views/links"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Buho")

    /***** PROPS *****/

    property var views : ({
                              notes: 0,
                              links: 1,
                              books: 2
                          })

    headBar.middleContent: Row
    {
        spacing: space.medium
        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "draw-text"
            text: qsTr("Notes")
        }

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "link"
            text: qsTr("Links")
        }

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly

            iconName: "document-new"
            text: qsTr("Books")
        }
    }

    footBar.middleContent: Maui.PieButton
    {
        id: addButton
        iconName: "list-add"

        model: ListModel
        {
            ListElement {iconName: "document-new"; mid: "page"}
            ListElement {iconName: "link"; mid: "link"}
            ListElement {iconName: "draw-text"; mid: "note"}
        }

        onItemClicked:
        {
            if(item.mid === "note")
                newNoteDialog.open()
            else if(item.mid === "link")
                newLinkDialog.open()
        }
    }

    footBar.leftContent: Maui.ToolButton
    {
        iconName: "document-share"
    }

    footBar.rightContent: Maui.ToolButton
    {
        iconName: "archive-remove"
    }

    /***** COMPONENTS *****/

    Connections
    {
        target: owl
        onNoteInserted: notesView.append(note)
    }

    NewNoteDialog
    {
        id: newNoteDialog
        onNoteSaved: owl.insertNote(note.title, note.body, note.color, note.tags)
    }

    NewNoteDialog
    {
        id: editNote
        onNoteSaved:
        {
            if(owl.updateNote(notesView.currentNote.id, note.title, note.body, note.color, note.tags))
                notesView.cardsView.currentItem.update(note)
        }
    }


    NewLinkDialog
    {
        id: newLinkDialog
    }

    /***** VIEWS *****/

    SwipeView
    {
        anchors.fill: parent
        currentIndex: views.notes

        NotesView
        {
            id: notesView
            onNoteClicked: setNote(note)
        }

        LinksView
        {
            id: linksView
        }

    }

    Component.onCompleted:
    {
        notesView.populate()
    }

    function setNote(note)
    {
        notesView.currentNote = note
        editNote.fill(note)
    }
}
