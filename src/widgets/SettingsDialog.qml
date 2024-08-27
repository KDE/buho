import QtQuick

import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

Maui.SettingsDialog
{    
    id: control

    Component
    {
        id:_fontPageComponent

        Maui.SettingsPage
        {
            title: i18n("Font")

            Maui.FontPicker
            {
                Layout.fillWidth: true

                mfont: settings.font

                onFontModified:
                {
                    settings.font = font
                }
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Editor")
//        description: i18n("Configure the editor behaviour.")

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Spell Checker")
            label2.text: i18n("Check spelling and give suggestions.")
            Switch
            {
                checkable: true
                checked: settings.spellcheckEnabled
                onToggled: settings.spellcheckEnabled = !settings.spellcheckEnabled
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Auto Save")
            label2.text: i18n("Auto saves your file every few seconds")
            Switch
            {
                checkable: true
                checked: settings.autoSave
                onToggled: settings.autoSave = !settings.autoSave
            }
        }

        Maui.FlexSectionItem
        {
            label1.text:  i18n("Auto Reload")
            label2.text: i18n("Auto reload the text on external changes.")
            Switch
            {
                checkable: true
                checked: settings.autoReload
                onToggled: settings.autoReload = !settings.autoReload
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Line Numbers")
            label2.text: i18n("Display the line numbers on the left side.")

            Switch
            {
                checkable: true
                checked: settings.lineNumbers
                onToggled: settings.lineNumbers = !settings.lineNumbers

            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Font")
            label2.text: i18n("Font family and size.")

            ToolButton
            {
                checkable: true
                icon.name: "go-next"
                onToggled: control.addPage(_fontPageComponent)
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Syncing")
//        description: i18n("Configure the syncing of notes and books.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Auto sync")
            label2.text: i18n("Sync notes on start up.")

            Switch
            {
                checkable: true
//                checked:  settings.showThumbnails
//                onToggled:  settings.showThumbnails = ! settings.showThumbnails
            }
        }
    }

    Maui.SectionGroup
    {
        title: i18n("Sorting")
//        description: i18n("Sorting order and behavior.")

        Maui.FlexSectionItem
        {
            label1.text: i18n("Sort by")
            label2.text: i18n("Change the sorting key.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.TextOnly

                Action
                {
                    text: i18n("Title")
                    onTriggered: settings.sortBy =  "title"
                    checked: settings.sortBy ===  "title"
                }

                Action
                {
                    text: i18n("Date")
                    onTriggered: settings.sortBy = "modified"
                    checked: settings.sortBy ===  "modified"
                }

                Action
                {
                    text: i18n("Fav")
                    onTriggered: settings.sortBy = "favorite"
                    checked: settings.sortBy ===  "favorite"
                }
            }
        }

        Maui.FlexSectionItem
        {
            label1.text: i18n("Sort Order")
            label2.text: i18n("Change the sorting order.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.IconOnly

                Action
                {
                    text: i18n("Ascending")
                    icon.name: "view-sort-ascending"
                    onTriggered: settings.sortOrder = Qt.AscendingOrder
                    checked: settings.sortOrder === Qt.AscendingOrder
                }

                Action
                {
                    text: i18n("Descending")
                    icon.name: "view-sort-descending"
                    onTriggered: settings.sortOrder = Qt.DescendingOrder
                    checked: settings.sortOrder === Qt.DescendingOrder
                }
            }
        }
    }
}
