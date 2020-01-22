import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

import "widgets"
import "views/notes"
import "views/links"
import "views/books"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Buho")

    Maui.App.handleAccounts: true
    Maui.App.description: qsTr("Buho allows you to take quick notes, collect links and organize notes as books.")
    Maui.App.iconName: "qrc:/buho.svg"

    property int currentView : views.notes
    readonly property var views : ({
                                       notes: 0,
                                       links: 1,
                                       books: 2
                                   })

    rightIcon.visible: false
    headBar.middleContent: Maui.ActionGroup
    {
        id: _actionGroup
        Layout.fillHeight: true
        Layout.minimumWidth: implicitWidth
        currentIndex : swipeView.currentIndex
        onCurrentIndexChanged: swipeView.currentIndex = currentIndex

        Action
        {
            icon.name: "view-pim-notes"
            text: qsTr("Notes")
        }

        Action
        {
            icon.name: "view-pim-news"
            text: qsTr("Links")
        }

        Action
        {
            icon.name: "view-pim-journal"
            text: qsTr("Books")
        }
    }

    Maui.PieButton
    {
        id: addButton
        z: 999
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: height
        height: Maui.Style.toolBarHeight

        icon.name: "list-add"
        icon.color: Kirigami.Theme.highlightedTextColor
        alignment: Qt.AlignLeft

        Action
        {
            icon.name: "view-pim-notes"
            onTriggered: newNote()
        }
        Action
        {
            icon.name: "view-pim-news"
            onTriggered: newLink()
        }
        Action
        {
            icon.name: "view-pim-journal"
            onTriggered: newBook()
        }
    }

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

    NewLinkDialog
    {
        id: editLinkDialog
        onLinkSaved: linksView.list.update(link, linksView.currentIndex)
    }

    NewBookDialog
    {
        id: newBookDialog
        onBookSaved:
        {
            if(title && title.length)
                booksView.list.insert({title: title, count: 0})
        }
    }

    //    /***** VIEWS *****/

    SwipeView
    {
        id: swipeView
        anchors.fill: parent
        currentIndex: _actionGroup.currentIndex
        onCurrentIndexChanged: _actionGroup.currentIndex = currentIndex
        interactive: Maui.Handy.isTouch

        NotesView
        {
            id: notesView
            onNoteClicked: setNote(note)
        }

        LinksView
        {
            id: linksView
            onLinkClicked: setLink(link)
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

    function newBook()
    {
        currentView = views.books
        newBookDialog.open()
    }

    function setNote(note)
    {
        notesView.currentNote = note
        editNote.fill(note)
        editNote.open()
    }

    function setLink(link)
    {
        linksView.currentLink = link
        editLinkDialog.fill(link)
        editLinkDialog.open()
    }
}
