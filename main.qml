import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.4 as Kirigami
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
    accentColor : "#ff9494"
    property color headBarTint : Qt.lighter(headBarBGColor, 1.25)
    altColorText : "white"/*Qt.darker(accentColor, 2.5)*/

    about.appDescription: qsTr("Buho allows you to take quick notes, collect links and take long notes organized by chapters.")
    about.appIcon: "qrc:/buho.svg"
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
            onClicked: currentView = views.notes
            iconColor: currentView === views.notes? altColorText : headBarTint
            iconName: "view-notes"
            text: qsTr("Notes")
        },

        Maui.ToolButton
        {
            onClicked: currentView = views.links
            iconColor: currentView === views.links? altColorText : headBarTint
            iconName: "view-links"
            text: qsTr("Links")
        },

        Maui.ToolButton
        {
            onClicked: currentView = views.books
            iconColor: currentView === views.books? altColorText : headBarTint
            iconName: "view-books"
            text: qsTr("Books")
        },

        Maui.ToolButton
        {
            iconColor: currentView === views.tags? altColorText : headBarTint
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
            iconColor: altColorText

            model: ListModel
            {
                ListElement {iconName: "view-notes"; mid: "note"}
                ListElement {iconName: "view-links"; mid: "link"}
                ListElement {iconName: "view-books"; mid: "page"}
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


//    /***** COMPONENTS *****/

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

//    /***** VIEWS *****/

    SwipeView
    {
        id: swipeView
        anchors.fill: parent
        currentIndex: currentView
        onCurrentIndexChanged:
        {
            currentView = currentIndex

            if(currentView === views.notes)
                accentColor = "#ff9494"
            else if(currentView === views.links)
                accentColor = "#25affb"
            else if(currentView === views.books)
                accentColor = "#6bc5a5"
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
