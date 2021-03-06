import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.3 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control
    property alias editor: _editor
    property string backgroundColor: note.color ? note.color : "transparent"
    property bool showEditActions : false
    property var note : ({})

    signal noteSaved(var note)

    headBar.visible: false

    Maui.Editor
    {
        id: _editor
        anchors.fill: parent

        fileUrl: control.note.url
        showLineNumbers: false
        document.autoReload: settings.autoReload
        document.autoSave: settings.autoSave

        body.font: settings.font

        footBar.visible: false

//        autoHideHeader: true
//        autoHideHeaderMargins: control.height * 0.3

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
                if(Maui.FM.fileExists(_editor.document.fileUrl))
                {
                    _editor.document.saveAs(_editor.document.fileUrl)
                }

                control.noteSaved(packNote())

                control.clear()
                control.parent.pop(StackView.Immediate)
            }
        }

        headBar.rightContent: ColorsBar
        {
            onColorPicked: control.backgroundColor = color
            currentColor: control.backgroundColor
        }

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

    footBar.leftContent: [

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
                                                shareDialog.show(editor.body.text)
        }

    ]

    footBar.rightContent: [
//            ToolButton
//            {
//                text: i18n("Export")
//                icon.name: "document-export"
//            },

        ToolButton
        {
            text: i18n("Delete")
            icon.name: "entry-delete"
            Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        }
    ]

    footerColumn: Maui.TagsBar
    {
        id: tagBar
        position: ToolBar.Footer
        width: parent.width
        allowEditMode: true
        onTagsEdited:
        {
            if(editor.fileUrl)
                tagBar.list.updateToUrls(tags)
        }

        list.strict: true
        list.urls: editor.fileUrl ? [editor.fileUrl] : []
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
