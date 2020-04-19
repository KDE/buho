import QtQuick 2.9
import QtQuick.Controls 2.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
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
    Maui.App.enableCSD: true

    readonly property var views : ({
                                       notes: 0,
                                       links: 1,
                                       books: 2
                                   })

    mainMenu: MenuItem
    {
        text: qsTr("Settings")
        icon.name: "settings-configure"
        onTriggered: _settingsDialog.open()
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

    MauiLab.SettingsDialog
    {
        id: _settingsDialog
        MauiLab.SettingsSection
        {
            title: qsTr("Syncing")
            description: qsTr("Configure the syncing options.")

            Switch
            {
                checkable: true
                Kirigami.FormData.label: qsTr("Auto Fetch on Start Up")
                Layout.fillWidth: true
            }
        }

        MauiLab.SettingsSection
        {
            title: qsTr("Notes")
            description: qsTr("Configure the notes view behavior.")

            Switch
            {
                checkable: true
                Kirigami.FormData.label: qsTr("Rich Text Formating")
                Layout.fillWidth: true
            }
        }

        MauiLab.SettingsSection
        {
            title: qsTr("Links")
            description: qsTr("Configure the app plugins and behavior.")

            Switch
            {
                checkable: true
                Kirigami.FormData.label: qsTr("Cached")
                Layout.fillWidth: true
            }
        }

        MauiLab.SettingsSection
        {
            title: qsTr("Books")
            description: qsTr("Configure the app plugins and behavior.")

            Item
            {
                Kirigami.FormData.label: qsTr("Editor")
                Kirigami.FormData.isSection: true
            }

            Switch
            {
                checkable: true
                Kirigami.FormData.label: qsTr("Show Line Numbers")
                Layout.fillWidth: true
            }

            Switch
            {
                checkable: true
                Kirigami.FormData.label: qsTr("Support Syntax Highlighting")
                Layout.fillWidth: true
            }

            Switch
            {
                checkable: true
                Kirigami.FormData.label: qsTr("Auto Save")
                Layout.fillWidth: true
            }
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
    MauiLab.AppViews
    {
        id: swipeView
        anchors.fill: parent

        NotesView
        {
            id: notesView
            onNoteClicked: setNote(note)
            MauiLab.AppView.iconName: "view-pim-notes"
            MauiLab.AppView.title: qsTr("Notes")
        }

        LinksView
        {
            MauiLab.AppView.iconName: "view-pim-news"
            MauiLab.AppView.title: qsTr("Links")
            id: linksView
            onLinkClicked: setLink(link)
        }

        BooksView
        {
            id: booksView
            MauiLab.AppView.iconName: "view-pim-journal"
            MauiLab.AppView.title: qsTr("Books")
        }
    }

    function newNote()
    {
        swipeView.currentIndex = views.notes
        newNoteDialog.open()
    }

    function newLink()
    {
        swipeView.currentIndex = views.links
        newLinkDialog.open()
    }

    function newBook()
    {
        swipeView.currentIndex = views.books
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
