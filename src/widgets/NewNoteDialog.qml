import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.mauikit.texteditor as TE

Maui.Page
{
    id: control

    property alias editor: _editor
    property alias document: _editor.document

    property string tagColor: note.color ? note.color : "transparent"
    property bool showEditActions : false
    property var note : ({})
    property int noteIndex : -1
    title : text.split("\n")[0]

    property alias text: _editor.text

    signal noteSaved(var note, int noteIndex)

    headBar.visible: !editor.body.readOnly
    headBar.leftContent: [

        Maui.ToolActions
        {
            expanded: true
            autoExclusive: false
            checkable: false

            Action
            {
                icon.name: "edit-undo"
                enabled: editor.body.canUndo
                onTriggered: editor.body.undo()
            }

            Action
            {
                icon.name: "edit-redo"
                enabled: editor.body.canRedo
                onTriggered: editor.body.redo()
            }
        },

        Maui.ToolActions
        {
            visible: (document.isRich || editor.body.textFormat === Text.RichText) && !editor.body.readOnly
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
            checked: note.favorite == 1
            icon.color: checked ? "#ff007f" : Maui.Theme.textColor

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
                Maui.Theme.textColor: Maui.Theme.negativeTextColor
                onTriggered: {}
            }

            MenuSeparator {}

            Item
            {
                height: Maui.Style.rowHeight
                width: parent.width

                ColorsBar
                {
                    anchors.centerIn: parent
                    onColorPicked:
                    {
                        control.tagColor = color
                    }

                    currentColor: control.tagColor
                }
            }
        }
    ]

    TE.TextEditor
    {
        id: _editor
        anchors.fill: parent

        fileUrl: control.note.url
        showLineNumbers: false
        document.autoReload: settings.autoReload
        document.autoSave: settings.autoSave
        spellcheckEnabled: settings.spellcheckEnabled

        body.font: settings.font

        document.enableSyntaxHighlighting: false
        body.placeholderText: i18n("Title\nBody")

        Rectangle
        {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            color: control.tagColor
            height : 12
        }

        Timer
        {
            id: _notifyTimer
            running: false
            interval: 2500
        }

        Maui.Chip
        {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: Maui.Style.space.big
            visible: _notifyTimer.running
            label.text: i18n("Note saved")
            iconSource: "document-save"
            Maui.Theme.backgroundColor: "yellow"
        }

        Connections
        {
            target: control.document
            function onFileSaved()
            {
                console.log("NOTE SAVED")
                _notifyTimer.start()
            }
        }
    }

    function update()
    {
        _editor.fileUrl =  Qt.binding(()=> {return control.note.url})
    }

    function clear()
    {
        editor.body.clear()
        control.note = ({})
    }

    function packNote()
    {
        var note = ({})
        const content = editor.body.text
        if(content.length > 0)
        {
            note  = {
                url: editor.fileUrl,
                content: content,
                favorite: favButton.checked ? 1 : 0,
                format: ".txt" //for now only simple txt files
            }

            if(control.tagColor  !== "transparent")
            {
                note["color"] = control.tagColor
            }
        }

        return note
    }

    function saveNote()
    {
        if(FB.FM.fileExists(document.fileUrl))
        {
            if(document.modified)
            {
                console.log("Saving a new note but existing file", document.fileUrl)
                document.saveAs(document.fileUrl)
            }

            console.log("trying to update note in the main model", noteIndex,notesModel.mappedToSource(noteIndex) )
            list.update(packNote(), notesModel.mappedToSource(noteIndex))
            return packNote()
        }else
        {
            return list.insert(packNote())
        }
    }
}
