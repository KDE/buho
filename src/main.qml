import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

import org.mauikit.controls 1.3 as Maui

import org.maui.buho 1.0 as Buho

import "widgets"
import "views/notes"

Maui.ApplicationWindow
{
    id: root
    title: i18n("Buho")
//    Maui.Style.styleType: settings.darkMode

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
        property bool darkMode : true

        property font font : defaultFont
    }

    SettingsDialog
    {
        id: _settingsDialog
    }

    NotesView
    {
        id: notesView
        anchors.fill: parent
        cardsView.showCSDControls: true
    }

    Component.onCompleted:
    {
        setAndroidStatusBarColor()
    }

    function setAndroidStatusBarColor()
    {
        if(Maui.Handy.isAndroid)
        {
            Maui.Android.statusbarColor( Maui.Theme.backgroundColor, !Maui.App.darkMode)
            Maui.Android.navBarColor(headBar.visible ? headBar.Maui.Theme.backgroundColor : Maui.Theme.backgroundColor, !Maui.App.darkMode)
        }
    }
}
