import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.buho 1.0 as Buho

import "widgets"
import "views/notes"

Maui.ApplicationWindow
{
    id: root
    title: i18n("Buho")
    headBar.visible: false

    property font defaultFont : Qt.font({family: "Noto Sans Mono", pointSize: Maui.Style.fontSizes.huge})


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

    sideBar: Maui.SideBar
    {
        id: _sidebar
        collapsible: true
        collapsed : root.width < preferredWidth * 2
        preferredWidth: Kirigami.Units.gridUnit * 22

        NotesView
        {
            id: notesView
            anchors.fill: parent
        }
    }

    NewNoteDialog
    {
        id: editorView
        anchors.fill: parent

        onNoteSaved:
        {
            if(!FB.FM.fileExists(editorView.document.fileUrl))
            {
                notesView.saveNote(note)
            }else
            {
                notesView.updateNote(note, noteIndex)
            }
        }

        function setNote(note)
        {
            editorView.note = note
            editorView.editor.body.forceActiveFocus()
            editorView.noteIndex = notesView.currentIndex
        }

        function newNote()
        {
            control.currentItem.editor.body.forceActiveFocus()
        }
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
