import QtQuick 2.14
import QtQml 2.14

import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui

Maui.SettingsDialog
{
    Maui.SettingsSection
    {
        title: i18n("Editor")
        description: i18n("Configure the editor behaviour.")

        Maui.SettingTemplate
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

        Maui.SettingTemplate
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

        Maui.SettingTemplate
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

        Maui.SettingTemplate
        {
            label1.text: i18n("Dark Mode")
            label2.text: i18n("Switch between light and dark colorscheme")

            Switch
            {
                Layout.fillHeight: true
                checked: settings.darkMode
                onToggled:
                {
                     settings.darkMode = !settings.darkMode
                    setAndroidStatusBarColor()
                }
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Fonts")
        description: i18n("Configure the global editor font family and size")

        Maui.SettingTemplate
        {
            label1.text:  i18n("Family")

            Maui.FontsComboBox
            {
                id: _fontsCombobox
                Layout.fillWidth: true
                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                onActivated: settings.font.family = currentText
            }
        }

        Maui.SettingTemplate
        {
            label1.text:  i18n("Size")

            SpinBox
            {
                from: 0; to : 500
                value: settings.font.pointSize
                onValueChanged: settings.font.pointSize = value
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Syncing")
        description: i18n("Configure the syncing of notes and books.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Auto sync")
            label2.text: i18n("Sync notes and books on start up")

            Switch
            {
                checkable: true
                checked:  settings.showThumbnails
                onToggled:  settings.showThumbnails = ! settings.showThumbnails
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Sorting")
        description: i18n("Sorting order and behavior.")

        Maui.SettingTemplate
        {
            label1.text: i18n("Sorting by")
            label2.text: i18n("Change the sorting key.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.TextOnly

                Binding on currentIndex
                {
                    value:  switch(settings.sortBy)
                            {
                            case  "title": return 0;
                            case  "modified": return 1;
                            case  "favorite": return 2;
                            default: return -1;
                            }
                    restoreMode: Binding.RestoreValue
                }

                Action
                {
                    text: i18n("Title")
                    onTriggered: settings.sortBy =  "title"
                }

                Action
                {
                    text: i18n("Date")
                    onTriggered: settings.sortBy = "modified"
                }

                Action
                {
                    text: i18n("Fav")
                    onTriggered: settings.sortBy = "favorite"
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Sort order")
            label2.text: i18n("Change the sorting order.")

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: true
                display: ToolButton.IconOnly

                Binding on currentIndex
                {
                    value:  switch(settings.sortOrder)
                            {
                            case Qt.AscendingOrder: return 0;
                            case Qt.DescendingOrder: return 1;
                            default: return -1;
                            }
                    restoreMode: Binding.RestoreValue
                }

                Action
                {
                    text: i18n("Ascending")
                    icon.name: "view-sort-ascending"
                    onTriggered: settings.sortOrder = Qt.AscendingOrder
                }

                Action
                {
                    text: i18n("Descending")
                    icon.name: "view-sort-descending"
                    onTriggered: settings.sortOrder = Qt.DescendingOrder
                }
            }
        }
    }
}
