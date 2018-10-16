import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import org.buho.editor 1.0

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

    headBar.leftContent: [

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
            iconName: "edit-undo"
            enabled: body.canUndo
            onClicked: body.undo()
            opacity: enabled ? 1 : 0.5

        },

        Maui.ToolButton
        {
            iconName: "edit-redo"
            enabled: body.canRedo
            onClicked: body.redo()
            opacity: enabled ? 1 : 0.5
        },

        Maui.ToolButton
        {
            iconName: "format-text-bold"
            focusPolicy: Qt.TabFocus
            iconColor: checked ? highlightColor : textColor
            checkable: true
            checked: document.bold
            onClicked: document.bold = !document.bold
        },

        Maui.ToolButton
        {
            iconName: "format-text-italic"
            iconColor: checked ? highlightColor : textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: document.italic
            onClicked: document.italic = !document.italic
        },

        Maui.ToolButton
        {
            iconName: "format-text-underline"
            iconColor: checked ? highlightColor : textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: document.underline
            onClicked: document.underline = !document.underline
        },

        Maui.ToolButton
        {
            iconName: "format-text-uppercase"
            iconColor: checked ? highlightColor : textColor
            focusPolicy: Qt.TabFocus
            checkable: true
            checked: document.uppercase
            onClicked: document.uppercase = !document.uppercase
        },

        Maui.ToolButton
        {
            iconName: "image"
        }
    ]

    colorScheme.backgroundColor: selectedColor

    headBar.rightContent: ColorsBar
    {
        onColorPicked: selectedColor = color
    }

    footBar.leftContent: [

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
            onClicked: isAndroid ? Maui.Android.shareText(body.text) :
                                   shareDialog.show(body.text)
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
        if(body.text.length > 0)
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

        DocumentHandler
        {
            id: document
            document: body.textDocument
            cursorPosition: body.cursorPosition
            selectionStart: body.selectionStart
            selectionEnd: body.selectionEnd
            // textColor: TODO
            //            onLoaded: {
            //                body.text = text
            //            }
            onError:
            {
                body.text = message
                body.visible = true
            }


        }

        ScrollView
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: space.medium

            TextArea
            {
                id: body
                width: parent.width
                height: parent.height
                placeholderText: qsTr("Body")
                selectByKeyboard :!isMobile
                selectByMouse : !isMobile
                textFormat : TextEdit.AutoText
                color: fgColor
                font.pointSize: fontSizes.large
                wrapMode: TextEdit.WrapAnywhere
                activeFocusOnPress: true
                activeFocusOnTab: true
                persistentSelection: true
                background: Rectangle
                {
                    color: "transparent"
                }

                onPressAndHold: documentMenu.popup()
                onPressed:
                {
                    if(!isMobile && event.button === Qt.RightButton)
                        documentMenu.popup()
                }

                Row
                {
                    anchors
                    {
                        right: parent.right
                        bottom: parent.bottom
                    }

                    width: implicitWidth
                    height: implicitHeight

                    Label
                    {
                        text: body.length + " / " + body.lineCount
                        color: Qt.darker(selectedColor,1.5)
                        opacity: 0.5
                        font.pointSize: fontSizes.medium
                    }

                }

                Maui.Menu
                {
                    id: documentMenu
                    z: 999

                    Maui.MenuItem
                    {
                        text: qsTr("Copy")
                        onTriggered: Maui.Handy.copyToClipboard(body.selectedText)
                    }

                    Maui.MenuItem
                    {
                        text: qsTr("Cut")
                    }

                    Maui.MenuItem
                    {
                        text: qsTr("Paste")
                        onTriggered:
                        {
                            var text = Maui.Handy.getClipboard()
                            body.insert(body.cursorPosition,text)
                        }
                    }

                    Maui.MenuItem
                    {
                        text: qsTr("Select all")
                        onTriggered: body.selectAll()
                    }

                    Maui.MenuItem
                    {
                        text: qsTr("Web search")
                        onTriggered: Maui.FM.openUrl("https://www.google.com/search?q="+body.selectedText)
                    }
                }
            }
        }

        Maui.TagsBar
        {
            id: tagBar
            Layout.fillWidth: true
            allowEditMode: true

            onTagsEdited:
            {
                for(var i in tags)
                    append({tag : tags[i]})
            }
        }
    }

    onOpened: if(isMobile) body.forceActiveFocus()


    function clear()
    {
        title.clear()
        body.clear()
        close()
    }

    function fill(note)
    {
        title.text = note.title
        body.text = note.body
        selectedColor =  note.color
        pinButton.checked = note.pin == 1
        favButton.checked = note.fav == 1
        tagBar.populate(note.tags)

        open()
    }

    function packNote()
    {
        noteSaved({
                      id: notesView.currentNote.id,
                      title: title.text.trim(),
                      body: body.text,
                      color: selectedColor,
                      tag: tagBar.getTags(),
                      pin: pinButton.checked,
                      fav: favButton.checked,
                      updated: new Date()
                  })
    }
}
