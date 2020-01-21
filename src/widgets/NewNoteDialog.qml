import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Dialog
{
    id: control
    parent: parent

    property alias editor: _editor
    property string selectedColor
    property color fgColor: Qt.darker(selectedColor, 3)
    property bool showEditActions : false
    signal noteSaved(var note)

    Kirigami.Theme.backgroundColor: if(selectedColor)
                                        return control.selectedColor

    Kirigami.Theme.textColor: if(selectedColor)
                                  return fgColor

    heightHint: 0.95
    widthHint: 0.95
    maxWidth: 700 * Maui.Style.unit
    maxHeight: maxWidth

    page.padding: 0

    rejectText:  qsTr("Discard")
    rejectButton.visible: false
    acceptText: qsTr("Save")
    onAccepted:  packNote()
    onRejected: clear()
    footBar.leftContent: [

        ToolButton
        {
            id: favButton
            icon.name: "love"
            checkable: true
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
            document.autoReload: true
            Layout.fillHeight: true
            Layout.fillWidth: true
            Kirigami.Theme.backgroundColor: control.selectedColor
            Kirigami.Theme.textColor: Qt.darker(control.selectedColor, 2.5)
            body.placeholderText: qsTr("Title\nBody")
            footBar.visible: false
            headBar.leftContent: ToolButton
            {
                icon.name: "image"
                icon.color: control.Kirigami.Theme.textColor
            }

            headBar.rightContent: ColorsBar
            {
                onColorPicked: control.selectedColor = color
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
            list.lot: " "
//            onTagRemovedClicked: list.removeFromAbstract(index)
            Kirigami.Theme.backgroundColor: "transparent"
            Kirigami.Theme.textColor: Kirigami.Theme.textColor

        }
    }

    onOpened: editor.body.forceActiveFocus()

    function clear()
    {
        control.close()
        editor.body.clear()
        fill(({}))
    }

    function fill(note)
    {
        editor.fileUrl = note.url
        control.selectedColor =  note.color ? note.color : ""
        favButton.checked = note.favorite == 1
        tagBar.list.lot = note.url
    }

    function packNote()
    {
        const content =  editor.body.text
        if(content.length == 0)
            return;

        control.noteSaved({
                              url: editor.fileUrl,
                              content: content,
                              color: control.selectedColor ?  control.selectedColor : "",
                              tag: tagBar.list.tags.join(","),
                              favorite: favButton.checked ? 1 : 0,
                              format: ".txt" //for now only simple txt files
                          })
        control.clear()
    }
}
