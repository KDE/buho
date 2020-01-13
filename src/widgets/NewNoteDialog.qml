import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Dialog
{
    id: control
    parent: parent

    property string selectedColor : Kirigami.Theme.backgroundColor
    property string fgColor: Qt.darker(selectedColor, 3)
    property bool showEditActions : false
    signal noteSaved(var note)

    Kirigami.Theme.backgroundColor: selectedColor
    Kirigami.Theme.textColor: fgColor

    heightHint: 0.95
    widthHint: 0.95
    maxWidth: 700 * Maui.Style.unit
    maxHeight: maxWidth

    page.padding: 0

    rejectText:  qsTr("Discard")
    rejectButton.visible: false
    acceptText: qsTr("Save")
    onAccepted:
    {
        if(editor.body.text.length > 0)
            packNote()
        clear()
    }

    onRejected: clear()

    headBar.middleContent:  TextField
    {
        id: title
        Layout.fillWidth: true
        Layout.margins: Maui.Style.space.medium
        placeholderText: qsTr("Title")
        font.weight: Font.Bold
        font.bold: true
        font.pointSize: Maui.Style.fontSizes.large

        background: Rectangle
        {
            color: "transparent"
        }
    }

    footBar.leftContent: [
        ToolButton
        {
            id: pinButton
            icon.name: "pin"
            checkable: true
            icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            //                onClicked: checked = !checked
        },

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
            id: editor
            Layout.fillHeight: true
            Layout.fillWidth: true
            Kirigami.Theme.backgroundColor: control.selectedColor
            Kirigami.Theme.textColor: Qt.darker(control.selectedColor, 2.5)

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
            onTagsEdited: list.append(tags)
            list.strict: true
            list.urls: [""]
//            onTagRemovedClicked: list.removeFromAbstract(index)
            Kirigami.Theme.backgroundColor: "transparent"
            Kirigami.Theme.textColor: Kirigami.Theme.textColor

        }
    }

    onOpened: editor.body.forceActiveFocus()

    function clear()
    {
        title.clear()
        editor.body.clear()
        close()
    }

    function fill(note)
    {
        title.text = note.title
        editor.body.text = note.content
        control.selectedColor =  note.color ? note.color : Kirigami.Theme.backgroundColor
        pinButton.checked = note.pin == 1
        favButton.checked = note.favorite == 1
        tagBar.list.urls = [note.url]
        open()
    }

    function packNote()
    {
        console.log("TAGS", tagBar.list.tags)
        control.noteSaved({
                      id: notesView.currentNote.id,
                      title: title.text.trim(),
                      content: editor.body.text,
                      color: selectedColor,
                      tag: tagBar.list.tags.join(","),
                      pin: pinButton.checked ? 1 : 0,
                      favorite: favButton.checked ? 1 : 0,
                      modified: new Date()
                  })
    }
}
