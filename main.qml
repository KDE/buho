import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.maui 1.0 as Maui

import "src/widgets"
import "src/views/notes"
import "src/views/links"
import "src/views/books"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Buho")

    /***** PROPS *****/
    floatingBar: true
    property string accentColor : highlightColor

    property int currentView : views.notes
    property var views : ({
                              notes: 0,
                              links: 1,
                              books: 2,
                              tags: 3,
                              search: 4
                          })

    headBar.middleContent: [
        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
            onClicked: currentView = views.notes
            iconColor: currentView === views.notes? accentColor : textColor
            iconName: "draw-text"
            text: qsTr("Notes")
        },

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
            onClicked: currentView = views.links
            iconColor: currentView === views.links? accentColor : textColor
            iconName: "link"
            text: qsTr("Links")
        },

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
            iconColor: currentView === views.books? accentColor : textColor
            iconName: "document-new"
            text: qsTr("Books")
        },

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
            iconColor: currentView === views.tags? accentColor : textColor
            iconName: "tag"
            text: qsTr("Tags")
        }
    ]

    footBar.middleContent: [

        Maui.ToolButton
        {
            iconName:  swipeView.currentItem.cardsView.gridView ? "view-list-icons" : "view-list-details"
            onClicked:
            {
                switch(currentView)
                {
                    case views.notes:
                    notesView.cardsView.gridView = !notesView.cardsView.gridView
                    notesView.cardsView.refresh()
                    break

                    case views.links:
                    linksView.cardsView.gridView = !linksView.cardsView.gridView
                    linksView.cardsView.refresh()
                    break
                }

            }
        },

        Maui.PieButton
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
                {
                    currentView = views.notes
                    newNoteDialog.open()
                }
                else if(item.mid === "link")
                {
                    currentView = views.links
                    newLinkDialog.open()
                }
            }
        }
    ]

    /***** COMPONENTS *****/

    Connections
    {
        target: owl
        onNoteInserted: notesView.append(note)
        onLinkInserted: linksView.append(link)
    }

    NewNoteDialog
    {
        id: newNoteDialog
        onNoteSaved: owl.insertNote(note.title.trim(), note.body, note.color, note.tags)
    }

    NewNoteDialog
    {
        id: editNote
        onNoteSaved:
        {
            if(owl.updateNote(notesView.currentNote.id, note.title.trim(), note.body, note.color, note.tags))
                notesView.cardsView.currentItem.update(note)
        }
    }


    NewLinkDialog
    {
        id: newLinkDialog
        onLinkSaved: owl.insertLink(note.link, note.title.trim(), note.preview, note.color, note.tags)
    }

    /***** VIEWS *****/

    SwipeView
    {
        id: swipeView
        anchors.fill: parent
        currentIndex: currentView
        onCurrentIndexChanged: currentView = currentIndex

        NotesView
        {
            id: notesView
            onNoteClicked: setNote(note)
        }

        LinksView
        {
            id: linksView
            onLinkClicked: previewLink(link)
        }

        BooksView
        {
            id: booksView

        }

    }

    Component.onCompleted:
    {
        notesView.populate()
        linksView.populate()
    }

    function setNote(note)
    {
        var tags = owl.getNoteTags(note.id)
        note.tags = tags
        notesView.currentNote = note
        editNote.fill(note)
    }

    function previewLink(link)
    {
        var tags = owl.getLinkTags(link.link)
        link.tags = tags
        linksView.previewer.show(link)
    }
}
