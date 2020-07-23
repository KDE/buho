import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control
    property alias editor: _editor
    property string backgroundColor: note.color ? note.color : Kirigami.Theme.backgroundColor
    property bool showEditActions : false
    signal noteSaved(var note)

    property var note : ({})

    footBar.rightContent: Button
    {
        text: qsTr("Save")
        onClicked: packNote()
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
            onClicked: isAndroid ? Maui.Android.shareText(editor.body.text) :
                                   shareDialog.show(editor.body.text)
            icon.color: Kirigami.Theme.textColor
        },

        ToolButton
        {
            icon.name: "document-export"
            icon.color: Kirigami.Theme.textColor
        },

        ToolButton
        {
            icon.name: "entry-delete"
            icon.color: Kirigami.Theme.textColor
        }
    ]

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        Maui.Editor
        {
            id: _editor
            fileUrl: control.note.url ? control.note.url : ""
            showLineNumbers: false
            document.autoReload: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            body.font.pointSize: Maui.Style.fontSizes.huge

            Kirigami.Theme.backgroundColor: control.backgroundColor
            Kirigami.Theme.textColor: control.backgroundColor.length ? Qt.darker(control.backgroundColor, 2) : control.Kirigami.Theme.textColor

            document.enableSyntaxHighlighting: false
            body.placeholderText: qsTr("Title\nBody")
            footBar.visible: false
            headBar.leftContent: ToolButton
            {
                icon.name: "image"
                icon.color: control.Kirigami.Theme.textColor
            }

            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.parent.pop(StackView.Immediate)
            }

            headBar.rightContent: ColorsBar
            {
                onColorPicked: control.backgroundColor = color
            }
        }

        Maui.TagsBar
        {
            id: tagBar
            position: ToolBar.Footer
            Layout.fillWidth: true
            allowEditMode: true
            onTagsEdited:
            {
                if((editor.fileUrl).toString().length > 0)
                    tagBar.list.updateToAbstract(tags)
                else
                    tagBar.list.append(tags)
            }

            list.strict: true
            list.abstract: true
            list.key: "notes"
            list.lot: control.note.url ? control.note.url : " "
//            onTagRemovedClicked: list.removeFromAbstract(index)
            Kirigami.Theme.backgroundColor: "transparent"
            Kirigami.Theme.textColor: Kirigami.Theme.textColor

        }
    }


    function clear()
    {
        editor.body.clear()
        control.note = ({})
    }

    function fill(note)
    {
    }

    function packNote()
    {
        const content =  editor.body.text
        if(content.length == 0)
            return;

        control.noteSaved({
                              url: editor.fileUrl,
                              content: content,
                              color: control.backgroundColor ?  control.backgroundColor : "",
                              tag: tagBar.list.tags.join(","),
                              favorite: favButton.checked ? 1 : 0,
                              format: ".txt" //for now only simple txt files
                          })
        control.clear()
        control.parent.pop(StackView.Immediate)

    }
}
