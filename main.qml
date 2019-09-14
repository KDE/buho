import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import QtQuick.Layouts 1.3

import "src/widgets"
import "src/views/notes"
import "src/views/links"
import "src/views/books"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Buho")


    /**** BRANDING COLORS ****/
    //    menuButton.colorScheme.highlightColor: accentColor
    //    searchButton.colorScheme.highlightColor: accentColor

    //    headBarBGColor: viewBackgroundColor
//    headBarFGColor: textColor
//    accentColor : "#ff9494"
    //    highlightColor: accentColor

//    altColorText : "white"/*Qt.darker(accentColor, 2.5)*/
    showAccounts: true
    Maui.App.description: qsTr("Buho allows you to take quick notes, collect links and take long notes organized by chapters.")
    Maui.App.iconName: "qrc:/buho.svg"

    property int currentView : views.notes
    readonly property var views : ({
                                       notes: 0,
                                       links: 1,
                                       books: 2,
                                       tags: 3,
                                       search: 4
                                   })
    property color headBarTint : Qt.lighter(headBarBGColor, 1.25)
//    headBarFGColor: "red"

//    headBar.position: ToolBar.Footer
    headBar.middleContent: Kirigami.ActionToolBar
    {
        display: isWide ? ToolButton.TextBesideIcon : ToolButton.IconOnly
        position: ToolBar.Header
        Layout.fillWidth: true

        actions: [
            Kirigami.Action
            {
                onTriggered: currentView = views.notes
                //                icon.color: checked ? accentColor : textColor
//                Kirigami.Theme.highlightColor: accentColor
//                Kirigami.Theme.textColor: accentColor
                icon.name: "view-pim-notes"
                text: qsTr("Notes")
                checked: currentView === views.notes
            },

            Kirigami.Action
            {
                onTriggered: currentView = views.links
//                icon.color: checked ? accentColor : textColor
//                Kirigami.Theme.highlightColor: accentColor
                icon.name: "view-pim-news"
                text: qsTr("Links")
                checked: currentView === views.links
            },

            Kirigami.Action
            {
                onTriggered: currentView = views.books
//                icon.color: checked?  accentColor : textColor
//                Kirigami.Theme.highlightColor: accentColor
                icon.name: "view-pim-journal"
                text: qsTr("Books")
                checked: currentView === views.books
            },

            Kirigami.Action
            {
//                icon.color: checked ? accentColor : textColor
//                Kirigami.Theme.highlightColor: accentColor
                icon.name: "tag"
                text: qsTr("Tags")
                checked: currentView === views.tags
            }
        ]
    }

    //    headBar.colorScheme.borderColor: Qt.darker(accentColor, 1.4)
    headBar.drawBorder: false
//    headBar.implicitHeight: toolBarHeight * 1.5

    Rectangle
    {
        z: 999
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: toolBarHeight
        anchors.bottomMargin: toolBarHeight
        height: toolBarHeight
        width: height

        color: Kirigami.Theme.highlightColor
        radius: radiusV

        Maui.PieButton
        {
            id: addButton
            anchors.fill : parent
            icon.name: "list-add"
            icon.color: Kirigami.Theme.highlightedTextColor
            barHeight: parent.height
            alignment: Qt.AlignLeft
            content: [
                ToolButton
                {
                    icon.name: "view-pim-notes"
                    onClicked: newNote()
                },
                ToolButton
                {
                    icon.name: "view-pim-news"
                    onClicked: newLink()
                },
                ToolButton
                {
                    icon.name: "view-pim-journal"
                    onClicked: newBook()
                }
            ]
        }
    }

    Maui.SyncDialog
    {
        id: syncDialog
    }

    mainMenu: [
        MenuItem
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
        currentIndex: currentView
        onCurrentIndexChanged:
        {
            currentView = currentIndex

//            if(currentView === views.notes)
//                accentColor = "#ff9494"
//            else if(currentView === views.links)
//                accentColor = "#25affb"
//            else if(currentView === views.books)
//                accentColor = "#6bc5a5"
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

    function newBook()
    {
        currentView = views.books
        newBookDialog.open()
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
