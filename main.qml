import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.mauikit 1.0 as Maui

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
    footBarOverlap: true
    allowRiseContent: false
    altToolBars: false

    /**** BRANDING COLORS ****/
    colorSchemeName: "buho"
    headBarBGColor: accentColor
    headBarFGColor: altColorText
    accentColor : "#8981d8"
    altColorText : Qt.darker(accentColor, 3)

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
            iconColor: currentView === views.notes? highlightColor : altColorText
            iconName: "draw-text"
            text: qsTr("Notes")
        },

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
            onClicked: currentView = views.links
            iconColor: currentView === views.links? highlightColor : altColorText
            iconName: "link"
            text: qsTr("Links")
        },

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
            iconColor: currentView === views.books? highlightColor : altColorText
            iconName: "document-new"
            text: qsTr("Books")
        },

        Maui.ToolButton
        {
            display: root.isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
            iconColor: currentView === views.tags? highlightColor : altColorText
            iconName: "tag"
            text: qsTr("Tags")
        }
    ]

    footBarMargins: space.huge
    footBarAligment: Qt.AlignRight
    footBar.middleContent: [

        Maui.PieButton
        {
            id: addButton
            iconName: "list-add"
            iconColor: "white"

            model: ListModel
            {
                ListElement {iconName: "document-new"; mid: "page"}
                ListElement {iconName: "link"; mid: "link"}
                ListElement {iconName: "draw-text"; mid: "note"}
            }

            onItemClicked:
            {
                if(item.mid === "note")
                newNote()
                else if(item.mid === "link")
                newLink()
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
        onNoteSaved: owl.insertNote(note)
    }

    NewNoteDialog
    {
        id: editNote
        onNoteSaved:
        {
            if(owl.updateNote(note))
                notesView.cardsView.currentItem.update(note)
        }
    }

    NewLinkDialog
    {
        id: newLinkDialog
        onLinkSaved: owl.insertLink(link)
    }

    /***** VIEWS *****/

    SwipeView
    {
        id: swipeView
        anchors.fill: parent
        currentIndex: currentView
        onCurrentIndexChanged:
        {

            currentView = currentIndex

            if(currentView === views.notes)
                accentColor = "#ffe355"
            else if(currentView === views.links)
                accentColor = "#8981d8"
        }

        interactive: isMobile


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

        if(!isAndroid)
            Maui.KDE.setColorScheme("buho", accentColor, altColorText)
    }


    function newNote()
    {
        currentView = views.notes
        newNoteDialog.open()
    }

    function newLink()
    {
        currentView = views.links
        newLinkDialog.open()
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
