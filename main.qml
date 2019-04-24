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
//    altToolBars: false

    /**** BRANDING COLORS ****/
    menuButton.colorScheme.highlightColor: accentColor
    searchButton.colorScheme.highlightColor: accentColor
    headBarBGColor: viewBackgroundColor
    headBarFGColor: textColor
    accentColor : "#ff9494"
    //    highlightColor: accentColor

    altColorText : "white"/*Qt.darker(accentColor, 2.5)*/

    about.appDescription: qsTr("Buho allows you to take quick notes, collect links and take long notes organized by chapters.")
    about.appIcon: "qrc:/buho.svg"

    property int currentView : views.notes
    readonly property var views : ({
                                       notes: 0,
                                       links: 1,
                                       books: 2,
                                       tags: 3,
                                       search: 4
                                   })
    property color headBarTint : Qt.lighter(headBarBGColor, 1.25)

    headBar.middleContent: [
        Maui.ToolButton
        {
            onClicked: currentView = views.notes
            iconColor: currentView === views.notes? accentColor : textColor
            colorScheme.highlightColor: accentColor
            iconName: "view-notes"
            text: qsTr("Notes")
        },

        Maui.ToolButton
        {
            onClicked: currentView = views.links
            iconColor: currentView === views.links? accentColor : textColor
            colorScheme.highlightColor: accentColor
            iconName: "view-links"
            text: qsTr("Links")
        },

        Maui.ToolButton
        {
            onClicked: currentView = views.books
            iconColor: currentView === views.books?  accentColor : textColor
            colorScheme.highlightColor: accentColor
            iconName: "view-books"
            text: qsTr("Books")
        },

        Maui.ToolButton
        {
            iconColor: currentView === views.tags? accentColor : textColor
            colorScheme.highlightColor: accentColor
            iconName: "tag"
            text: qsTr("Tags")
        }
    ]

    //    headBar.colorScheme.borderColor: Qt.darker(accentColor, 1.4)
    headBar.drawBorder: false
    headBar.implicitHeight: toolBarHeight * 1.5
    footBar.colorScheme.backgroundColor: accentColor
    footBar.colorScheme.borderColor: Qt.darker(accentColor, 1.4)
    footBarMargins: space.huge
    footBarAligment: Qt.AlignRight
    footBar.middleContent: [

        Maui.PieButton
        {
            id: addButton
            iconName: "list-add"
            iconColor: altColorText
            barHeight: footBar.height
            alignment: Qt.AlignLeft
            content: [
                Maui.ToolButton
                {
                    iconName: "view-notes"
                    onClicked: newNote()
                },
                Maui.ToolButton
                {
                    iconName: "view-links"
                    onClicked: newLink()
                },
                Maui.ToolButton
                {
                    iconName: "view-books"
                }
            ]
        }
    ]


    Maui.SyncDialog
    {
        id: syncDialog

    }

    mainMenu: [
        Maui.MenuItem
        {
            text: qsTr("Syncing")
            onTriggered: syncDialog.open()
        }
    ]

    //    /***** COMPONENTS *****/

    NewNoteDialog
    {
        id: newNoteDialog
        onNoteSaved: notesView.list.insert(note)
    }

    NewNoteDialog
    {
        id: editNote
        onNoteSaved: notesView.list.update(note, notesView.currentIndex)
    }

    NewLinkDialog
    {
        id: newLinkDialog
        onLinkSaved: linksView.list.insert(link)
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
        var tags = notesView.list.getTags(notesView.currentIndex)
        note.tags = tags
        notesView.currentNote = note
        editNote.fill(note)
    }

    function previewLink(link)
    {
        var tags = linksView.list.getTags(linksView.currentIndex)
        link.tags = tags

        linksView.previewer.show(link)
    }
}
