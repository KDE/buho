import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui

Maui.Dialog
{
    parent: parent
    heightHint: 0.95
    widthHint: 0.95
    maxWidth: 700*unit
    maxHeight: maxWidth

    property string selectedColor : "#ffffe6"
    property string fgColor: Qt.darker(selectedColor, 2.5)
    property bool showEditActions : false

    rejectButton.visible: false
    signal noteSaved(var note)
    page.margins: 0
    colorScheme.backgroundColor: selectedColor
    headBar.leftContent: [

        Maui.ToolButton
        {
            iconName: "edit-undo"
            enabled: editor.body.canUndo
            onClicked: editor.body.undo()
            opacity: enabled ? 1 : 0.5

        },

        Maui.ToolButton
        {
            iconName: "edit-redo"
            enabled: editor.body.canRedo
            onClicked: editor.body.redo()
            opacity: enabled ? 1 : 0.5
        },

        Maui.ToolButton
        {
            iconName: "format-text-bold"
            focusPolicy: Qt.TabFocus
            iconColor: checked ? highlightColor : textColor
            checkable: true
            checked: editor.document.bold
            onClicked: editor.document.bold = !editor.document.bold
        },

        Maui.ToolButton
        {
            iconName: "format-text-italic"
            iconColor: checked ? highlightColor : textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: editor.document.italic
            onClicked: editor.document.italic = !editor.document.italic
        },

        Maui.ToolButton
        {
            iconName: "format-text-underline"
            iconColor: checked ? highlightColor : textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: editor.document.underline
            onClicked: editor.document.underline = !editor.document.underline
        },

        Maui.ToolButton
        {
            iconName: "format-text-uppercase"
            iconColor: checked ? highlightColor : textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: editor.document.uppercase
            onClicked: editor.document.uppercase = !editor.document.uppercase
        },
        Maui.ToolButton
        {
            iconName: "image"
        }
    ]

    headBar.rightContent: ColorsBar
    {
        onColorPicked: selectedColor = color
    }

    footBar.leftContent: [
        Maui.ToolButton
        {
            id: pinButton
            iconName: "edit-pin"
            checkable: true
            iconColor: checked ? highlightColor : textColor
            //                onClicked: checked = !checked
        },

        Maui.ToolButton
        {
            id: favButton
            iconName: "love"
            checkable: true
            iconColor: checked ? "#ff007f" : textColor
        },

        Maui.ToolButton
        {
            iconName: "document-share"
            onClicked: isAndroid ? Maui.Android.shareText(editor.body.text) :
                                   shareDialog.show(editor.body.text)
        },

        Maui.ToolButton
        {
            iconName: "document-export"
        },

        Maui.ToolButton
        {
            iconName: "entry-delete"
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

            color: fgColor
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
            colorScheme.backgroundColor: selectedColor
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
