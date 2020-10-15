import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui

import "widgets"
import "views/notes"
import "views/books"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Buho")

    readonly property font defaultFont:
    {
        family: "Noto Sans Mono"
        pointSize: Maui.Style.fontSizes.huge
    }

    readonly property var views : ({
                                       notes: 0,
                                       books: 1
                                   })

    altHeader: Kirigami.Settings.isMobile
//    autoHideHeader: swipeView.currentItem.editing
    headBar.visible: !swipeView.currentItem.editing

    mainMenu: Action
    {
        text: qsTr("Settings")
        icon.name: "settings-configure"
        onTriggered: _settingsDialog.open()
    }
 //    /***** COMPONENTS *****/
    Settings
    {
        id: settings
        category: "General"
        property bool autoSync : true
        property bool autoSave: true
        property bool autoReload: true
        property bool lineNumbers: true

        property string sortBy:  "modified"
        property int sortOrder : Qt.DescendingOrder

        property font font : defaultFont
    }


    SettingsDialog
    {
        id: _settingsDialog
    }

    NewBookDialog
    {
        id: newBookDialog
        onBookSaved:
        {
            //            if(title && title.length)
            booksView.list.insert({title: title, count: 0})
        }
    }

    //    /***** VIEWS *****/
    Maui.AppViews
    {
        id: swipeView
        anchors.fill: parent

        NotesView
        {
            id: notesView

            Maui.AppView.iconName: "view-pim-notes"
            Maui.AppView.title: qsTr("Notes")
        }

        BooksView
        {
            id: booksView
            Maui.AppView.iconName: "view-pim-journal"
            Maui.AppView.title: qsTr("Books")
        }
    }

    function newBook()
    {
        swipeView.currentIndex = views.books
        newBookDialog.open()
    }

}
