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

    readonly property string backgroundColor: note.color
    property bool showEditActions : false
    property var note : ({})
    property int noteIndex : -1

    signal noteSaved(var note, int noteIndex)

    TE.TextEditor
    {
        id: _editor
        anchors.fill: parent

        fileUrl: control.note.url
        showLineNumbers: false
        document.autoReload: settings.autoReload
        document.autoSave: settings.autoSave

        body.font: settings.font

        document.enableSyntaxHighlighting: false
        body.placeholderText: i18n("Title\nBody")

        //        headBar.farLeftContent: ToolButton
        //        {
        //            icon.name: "go-previous"
        //            onClicked:
        //            {
        //                console.log(_editor.document.fileUrl, "File Url")
        //                if(FB.FM.fileExists(_editor.document.fileUrl))
        //                {
        //                    _editor.document.saveAs(_editor.document.fileUrl)
        //                }

        //                control.noteSaved(packNote(), control.noteIndex)

        //                control.clear()
        //                control.parent.pop(StackView.Immediate)
        //            }
        //        }

        Label
        {
            padding: 0
            anchors.margins: Maui.Style.space.big
            anchors.top: parent.top
            anchors.right: parent.right
            horizontalAlignment: Qt.AlignRight
            text: Qt.formatDateTime(new Date(control.note.modified), "h:mm d MMM yyyy")
            color: Kirigami.Theme.textColor
            elide: Qt.ElideRight
            wrapMode: TextEdit.NoWrap
            font.family: settings.font.family
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.small
        }

        headBar.visible: !body.readOnly
        altHeader: true

        headBar.rightContent: [

            ToolButton
            {
                id: favButton
                icon.name: "love"
                checkable: true
                checked:  note.favorite == 1
                icon.color: checked ? "#ff007f" : Kirigami.Theme.textColor

            },

            Maui.ToolButtonMenu
            {
                icon.name: "overflow-menu"


                MenuItem
                {
                    icon.name: "document-share"
                    text: i18n("Share")
                    onTriggered: Maui.Handy.isAndroid ? Maui.Android.shareText(editor.body.text) :
                                                        Maui.Platform.shareFiles(editor.fileUrl)
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

                MenuSeparator {}

                Item
                {
                    width: parent.width
                    height: Maui.Style.rowHeight
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
            }
        ]

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
                //                visible: (document.isRich || body.textFormat === Text.RichText) && !body.readOnly
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

        Connections
        {
            target: _editor.document
            function onFileSaved()
            {
                console.log("NOTE SAVED")
                control.noteSaved(packNote(), control.noteIndex)
            }

            function onModifiedChanged()
            {
                if(!FB.FM.fileExists(control.document.fileUrl))
                {
                    notesView.saveNote(packNote())
                }
            }
        }
    }

    function clear()
    {
        editor.body.clear()
        //        control.note.clear()
        control.note = ({})
        control.noteChanged()
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
