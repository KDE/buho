import QtQuick 2.14
import QtQuick.Controls 2.14
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.2 as Maui
import QtQuick.Layouts 1.3

import "widgets"
import "views/notes"
import "views/books"

Maui.ApplicationWindow
{
    id: root
    title: qsTr("Buho")

    readonly property var views : ({
                                       notes: 0,
                                       books: 1
                                   })

    altHeader: Kirigami.Settings.isMobile
    autoHideHeader: swipeView.currentItem.editing

    mainMenu: Action
    {
        text: qsTr("Settings")
        icon.name: "settings-configure"
        onTriggered: _settingsDialog.open()
    }

    Maui.FloatingButton
    {
        z: 999
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: height
        height: Maui.Style.toolBarHeight

        icon.name: "list-add"
        icon.color: Kirigami.Theme.highlightedTextColor
        onClicked: _newNoteDialog.open()
    }

    Maui.Dialog
    {
        id: _newNoteDialog
        rejectButton.visible : true
        acceptButton.visible : false
        page.padding: 0
        spacing: 0
        onRejected: close()

        Maui.AlternateListItem
        {
            Layout.fillWidth: true
            implicitHeight: Maui.Style.rowHeight * 2
            alt: true

            Maui.ListItemTemplate
            {
                anchors.fill:parent
                hovered: parent.hovered
                iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                iconSource: "view-pim-notes"
                label1.text: i18n("New note")
                label2.text: i18n("Create a simple note")
            }

            onClicked:
            {
                notesView.newNote()
                _newNoteDialog.close()
            }
        }

        Maui.AlternateListItem
        {
            alt: false
            Layout.fillWidth: true
            implicitHeight: Maui.Style.rowHeight * 2

            Maui.ListItemTemplate
            {
                anchors.fill:parent
                hovered: parent.hovered
                iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                iconSource: "view-pim-journal"
                label1.text: i18n("New book")
                label2.text: i18n("Create a new book to organize notes")
            }

            onClicked:
            {
                newBook()
                _newNoteDialog.close()
            }
        }

        Maui.AlternateListItem
        {
            alt: true
            Layout.fillWidth: true
            implicitHeight: Maui.Style.rowHeight * 2

            Maui.ListItemTemplate
            {
                anchors.fill:parent
                hovered: parent.hovered
                iconSizeHint: Math.min(height, Maui.Style.iconSizes.big)
                iconSource: "view-pim-journal"
                label1.text: i18n("New book & chapters")
                label2.text: i18n("Create a new book and all the wanted chapters quickly")
            }

            onClicked:
            {
                newBook()
                _newNoteDialog.close()
            }
        }

    }

    Maui.SettingsDialog
    {
        id: _settingsDialog
        Maui.SettingsSection
        {
            title: qsTr("Syncing")
            description: qsTr("Configure the syncing options.")

            Maui.SettingTemplate
            {
                label1.text: qsTr("Auto Fetch on Start Up")
                label2.text: qsTr("Gathers album and artists artwoks from online services")

                Switch
                {
                    checkable: true
                }
            }
        }

        Maui.SettingsSection
        {
            title: qsTr("Notes")
            description: qsTr("Configure the notes view behavior.")
            Maui.SettingTemplate
            {
                label1.text: qsTr("Rich Text Formating")
                label2.text: qsTr("Gathers album and artists artwoks from online services")

                Switch
                {
                    checkable: true
                }
            }
        }

        Maui.SettingsSection
        {
            title: qsTr("Books")
            description: qsTr("Configure the app plugins and behavior.")

            Maui.SettingTemplate
            {
                label1.text: qsTr("Show Line Numbers")
                label2.text: qsTr("Gathers album and artists artwoks from online services")

                Switch
                {
                    checkable: true
                }
            }

            Maui.SettingTemplate
            {
                label1.text: qsTr("Support Syntax Highlighting")

                Switch
                {
                    checkable: true
                }
            }

            Maui.SettingTemplate
            {
                label1.text: qsTr("Auto Save")
                label2.text: qsTr("Gathers album and artists artwoks from online services")

                Switch
                {
                    checkable: true
                }
            }
        }
    }

    //    /***** COMPONENTS *****/

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
