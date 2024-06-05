import QtQuick
import QtCore
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

import org.maui.buho as Buho

import "widgets"
import "views/notes"

Maui.ApplicationWindow
{
    id: root
    title: i18n("Buho")

    readonly property font defaultFont : Maui.Style.defaultFont

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

        property bool spellcheckEnabled: true
    }

    SettingsDialog
    {
        id: _settingsDialog
    }

    NotesView
    {
        id: notesView
        anchors.fill: parent
    }

    function newNote(content : string)
    {
        notesView.newNote(content)
    }
}
