import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Dialog
{
    id: control
    parent: parent
    heightHint: 0.95
    widthHint: 0.95
    maxWidth: 700*unit
    maxHeight: maxWidth

    property string selectedColor : "#ffffe6"
    property string fgColor: Qt.darker(selectedColor, 3)
    property bool showEditActions : false

    rejectButton.visible: false
    signal noteSaved(var note)
    page.padding: 0
    Kirigami.Theme.backgroundColor: selectedColor
     Kirigami.Theme.textColor: fgColor
    headBar.leftContent: [

        ToolButton
        {
            icon.name: "edit-undo"
            enabled: editor.body.canUndo
            onClicked: editor.body.undo()
            opacity: enabled ? 1 : 0.5
            icon.color: Kirigami.Theme.textColor
        },

        ToolButton
        {
            icon.name: "edit-redo"
            enabled: editor.body.canRedo
            onClicked: editor.body.redo()
            opacity: enabled ? 1 : 0.5
            icon.color: Kirigami.Theme.textColor
        },

        ToolButton
        {
            icon.name: "format-text-bold"
            focusPolicy: Qt.TabFocus
            icon.color: checked ? Kirigami.Theme.highlightColor :  Kirigami.Theme.textColor
            checkable: true
            checked: editor.document.bold
            onClicked: editor.document.bold = !editor.document.bold
        },

        ToolButton
        {
            icon.name: "format-text-italic"
            icon.color: checked ? Kirigami.Theme.highlightColor :  Kirigami.Theme.textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: editor.document.italic
            onClicked: editor.document.italic = !editor.document.italic
        },

        ToolButton
        {
            icon.name: "format-text-underline"
            icon.color: checked ? Kirigami.Theme.highlightColor :  Kirigami.Theme.textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: editor.document.underline
            onClicked: editor.document.underline = !editor.document.underline
        },

        ToolButton
        {
            icon.name: "format-text-uppercase"
            icon.color: checked ? Kirigami.Theme.highlightColor :  Kirigami.Theme.textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: editor.document.uppercase
            onClicked: editor.document.uppercase = !editor.document.uppercase
        },
        ToolButton
        {
            icon.name: "image"
            icon.color: control.Kirigami.Theme.textColor
        }
    ]

    headBar.rightContent: ColorsBar
    {
        onColorPicked: selectedColor = color
    }

    footBar.leftContent: [
        ToolButton
        {
            id: pinButton
            icon.name: "edit-pin"
            checkable: true
            icon.color: checked ? highlightColor : Kirigami.Theme.textColor
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

    acceptText: qsTr("Save")
    rejectText:  qsTr("Discard")
    onAccepted:
    {
        if(editor.body.text.length > 0)
            packNote()
        clear()
    }

    onRejected: clear()

    ColumnLayout
    {
        anchors.fill: parent

        TextField
        {
            id: title
            Layout.fillWidth: true
            Layout.margins: space.medium
            height: 24
            placeholderText: qsTr("Title")
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: fontSizes.large
//            Kirigami.Theme.backgroundColor: selectedColor
//            Kirigami.Theme.textColor: Qt.darker(selectedColor, 2.5)
//            color: fgColor
            background: Rectangle
            {
                color: "transparent"
            }
        }

        Maui.Editor
        {
            id: editor
            Layout.fillHeight: true
            Layout.fillWidth: true
            Kirigami.Theme.backgroundColor: selectedColor
            Kirigami.Theme.textColor: Qt.darker(selectedColor, 2.5)
            headBar.visible: false

        }

        Maui.TagsBar
        {
            id: tagBar
            Layout.fillWidth: true
            allowEditMode: true
            list.abstract: true
            list.key: "notes"
            onTagsEdited: list.updateToAbstract(tags)
            onTagRemovedClicked: list.removeFromAbstract(index)
             Kirigami.Theme.backgroundColor: "transparent"
             Kirigami.Theme.textColor: Kirigami.Theme.textColor

        }
    }

    onOpened: if(isMobile) editor.body.forceActiveFocus()


    function clear()
    {
        title.clear()
        editor.body.clear()
        close()
    }

    function fill(note)
    {
        title.text = note.title
        editor.body.text = note.body
        selectedColor =  note.color
        pinButton.checked = note.pin == 1
        favButton.checked = note.fav == 1

        tagBar.list.lot= note.id

        open()
    }

    function packNote()
    {
        noteSaved({
                      id: notesView.currentNote.id,
                      title: title.text.trim(),
                      body: editor.body.text,
                      color: selectedColor,
                      tag: tagBar.getTags(),
                      pin: pinButton.checked ? 1 : 0,
                      fav: favButton.checked ? 1 : 0,
                      updated: new Date()
                  })
    }
}
