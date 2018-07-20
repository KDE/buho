import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.maui 1.0 as Maui
import org.buho.editor 1.0

Popup
{
    parent: ApplicationWindow.overlay
    height: parent.height * (isMobile ?  0.8 : 0.7)
    width: parent.width * (isMobile ?  0.9 : 0.7)

    property string selectedColor : "#ffffe6"
    property string fgColor: Qt.darker(selectedColor, 2.5)
    property bool showEditActions : false

    signal noteSaved(var note)
    x: (parent.width / 2) - (width / 2)
    y: (parent.height /2 ) - (height / 2)

    modal: true

    padding: isAndroid ? 1 : "undefined"

    Maui.Page
    {
        id: content
        anchors.fill: parent
        margins: 0
        onExit: clear()
        headBarExit: false

        Rectangle
        {
            id: bg
            color: selectedColor
            z: -1
            anchors.fill: parent
        }

        headBar.leftContent: [

            Maui.ToolButton
            {
                id: pinButton
                iconName: "window-pin"
                checkable: true
                iconColor: checked ? highlightColor : textColor
                //                onClicked: checked = !checked
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
                iconName: "format-text-italic-symbolic"
                iconColor: checked ? highlightColor : textColor
                focusPolicy: Qt.TabFocus
                checkable: true
                checked: document.italic
                onClicked: document.italic = !document.italic
            },

            Maui.ToolButton
            {
                iconName: "format-text-underline-symbolic"
            },

            Maui.ToolButton
            {
                iconName: "format-text-uppercase"
            },

            Maui.ToolButton
            {
                iconName: "image"
            }
        ]

        headBar.rightContent:
            ColorsBar
        {
            onColorPicked: selectedColor = color
        }


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

                    background: Rectangle
                    {
                        color: "transparent"
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


        footBar.rightContent: Row
        {
            spacing: space.medium

            Button
            {
                id: discard
                text: qsTr("Discard")
                onClicked: clear()

            }

            Button
            {
                id: save
                text: qsTr("Save")
                onClicked:
                {
                    if(body.text.length > 0)
                        packNote()
                    clear()
                }
            }
        }
    }

    onOpened: body.forceActiveFocus()


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
                      fav: favButton.checked
                  })
    }
}
