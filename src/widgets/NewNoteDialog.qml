import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.texteditor 1.0 as TE

Maui.Page
{
    id: control

    property alias editor: _editor
    property alias body : _editor.body
    property alias document : _editor.document

    property string backgroundColor: note.color ? note.color : "transparent"
    property bool showEditActions : false
    property var note : ({})
    property int noteIndex : -1

    signal noteSaved(var note, int noteIndex)

    headBar.visible: false

    TE.TextEditor
    {
        id: _editor
        anchors.fill: parent

        fileUrl: control.note.url
        showLineNumbers: false
        document.autoReload: settings.autoReload
        document.autoSave: settings.autoSave

        body.font: settings.font

        Kirigami.Theme.backgroundColor: control.backgroundColor !== "transparent" ? control.backgroundColor : Kirigami.Theme.backgroundColor
        Kirigami.Theme.textColor: control.backgroundColor  !== "transparent" ? Qt.darker(control.backgroundColor, 2) : control.Kirigami.Theme.textColor

        document.enableSyntaxHighlighting: false
        body.placeholderText: i18n("Title\nBody")

        headBar.farLeftContent: ToolButton
        {
            icon.name: "go-previous"
            onClicked:
            {
                console.log(_editor.document.fileUrl, "File Url")
                if(FB.FM.fileExists(_editor.document.fileUrl))
                {
                    _editor.document.saveAs(_editor.document.fileUrl)
                }

                control.noteSaved(packNote(), control.noteIndex)

                control.clear()
                control.parent.pop(StackView.Immediate)
            }
        }

        headBar.visible: !body.readOnly
        headBar.leftContent: [

            Maui.ToolActions
            {
                expanded: true
                autoExclusive: false
                checkable: false

                Action
                {
                    icon.name: "edit-undo"
                    enabled: body.canUndo
                    onTriggered: body.undo()
                }

                Action
                {
                    icon.name: "edit-redo"
                    enabled: body.canRedo
                    onTriggered: body.redo()
                }
            },

            Maui.ToolActions
            {
                visible: (document.isRich || body.textFormat === Text.RichText) && !body.readOnly
                expanded: true
                autoExclusive: false
                checkable: false

                Action
                {
                    icon.name: "format-text-bold"
                    checked: document.bold
                    onTriggered: document.bold = !document.bold
                }

                Action
                {
                    icon.name: "format-text-italic"
                    checked: document.italic
                    onTriggered: document.italic = !document.italic
                }

                Action
                {
                    icon.name: "format-text-underline"
                    checked: document.underline
                    onTriggered: document.underline = !document.underline
                }

                Action
                {
                    icon.name: "format-text-uppercase"
                    checked: document.uppercase
                    onTriggered: document.uppercase = !document.uppercase
                }
            }
        ]

        headBar.rightContent: [

            ToolButton
            {
                id: favButton
                icon.name: "love"
                checkable: true
                checked:  note.favorite == 1
                icon.color: checked ? "#ff007f" : Kirigami.Theme.textColor

            },

            ToolButton
            {
                icon.name: "document-share"

                onClicked: Maui.Handy.isAndroid ? Maui.Android.shareText(editor.body.text) :
                                                  Maui.Platform.shareFiles(editor.fileUrl)
            },


            Maui.ToolButtonMenu
            {
                icon.name: "overflow-menu"

                MenuItem
                {
                    ColorsBar
                    {
                        anchors.centerIn: parent
                        onColorPicked:
                        {
                            control.backgroundColor = color
                        }

                        currentColor: control.backgroundColor
                    }
                }

                MenuItem
                {
                    icon.name: "edit-find"
                    text: i18n("Find and Replace")
                    checked: editor.showFindBar
                    checkable: true
                    onTriggered: editor.showFindBar = !editor.showFindBar
                }

                MenuSeparator {}

                MenuItem
                {
                    text: i18n("Delete")
                    icon.name: "entry-delete"
                    Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
                    onTriggered: {}
                }


            }
        ]

        Connections
        {
            target: _editor.document
            function onFileSaved()
            {
                console.log("NOTE SAVED")
                //                control.noteSaved(packNote())
            }
        }
    }



    function clear()
    {
        editor.body.clear()
        control.note = ({})
    }

    function packNote()
    {
        var note = ({})
        const content =  editor.body.text
        if(content.length > 0)
        {
            note  = {
                url: editor.fileUrl,
                content: content,
                favorite: favButton.checked ? 1 : 0,
                format: ".txt" //for now only simple txt files
            }

            if(control.backgroundColor  !== "transparent")
            {
                note["color"] = control.backgroundColor
            }
        }

        return note
    }
}
