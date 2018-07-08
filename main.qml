import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.maui 1.0 as Maui

import "src/widgets"
import "src/views/notes"

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

    NewNoteDialog
    {
        id: newNoteDialog
        onNoteSaved:
        {
            if(owl.insertNote(note.title, note.body, note.color, note.tags))
                notesView.append(note)
        }
    }

    NewNoteDialog
    {
        id: editNote
        onNoteSaved:
        {
            owl.updateNote(notesView.currentNote.id, note.title, note.body, note.color, note.tags)
        }
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
