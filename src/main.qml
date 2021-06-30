import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.3 as Maui

import org.maui.buho 1.0 as Buho

import "widgets"
import "views/notes"

Maui.ApplicationWindow
{
    id: root
    title: i18n("Buho")

    readonly property font defaultFont:
    {
        family: "Noto Sans Mono"
        pointSize: Maui.Style.fontSizes.huge
    }

    altHeader: Kirigami.Settings.isMobile
    headBar.visible: !notesView.editing

    mainMenu: [
        MenuItem
        {
            text: i18n("Settings")
            icon.name: "settings-configure"
            onTriggered: _settingsDialog.open()
        },

        MenuItem
        {
            text: i18n("About")
            icon.name: "documentinfo"
            onTriggered: root.about()
        }
    ]

    /***** COMPONENTS *****/
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

    headBar.rightContent: ToolButton
    {
        icon.name: "list-add"
        onClicked: notesView.newNote()
    }

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        Layout.maximumWidth: 500
        placeholderText: i18n("Search ") + notesView.list.count + " " + i18n("notes")
        onAccepted: notesView.model.filter = text
        onCleared: notesView.model.filter = ""
    }

    NotesView
    {
        id: notesView
        anchors.fill: parent
    }

    Component.onCompleted:
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor(headBar.Kirigami.Theme.backgroundColor, false)
            Maui.Android.navBarColor(headBar.visible ? headBar.Kirigami.Theme.backgroundColor : Kirigami.Theme.backgroundColor, false)
        }
    }
}
