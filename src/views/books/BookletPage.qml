import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import "../../widgets"

StackView
{
    id: control

    property var currentBooklet : null
    signal exit()

    onCurrentBookletChanged:
    {
        control.push(_editorView)
        control.currentItem.document.load(currentBooklet.url)
    }

    initialItem:  Maui.Page
    {
        margins: Maui.Style.space.big
        headBar.visible: true
        headBar.farLeftContent: ToolButton
        {
            icon.name: "go-previous"
            onClicked: control.exit()
        }

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: qsTr("Filter ") + _booksList.booklet.count + " " + qsTr("booklets in ") + currentBook.title
            onAccepted: _bookletModel.filter = text
            onCleared: _bookletModel.filter = ""
        }

        Maui.FloatingButton
        {
            z: parent.z + 1
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: height
            height: Maui.Style.toolBarHeight

            icon.name: "list-add"
            icon.color: Kirigami.Theme.highlightedTextColor
            onClicked:  _newChapter.open()
        }

        Maui.Holder
        {
            anchors.margins: Maui.Style.space.huge
            visible: _booksList.booklet.count === 0
            emoji: "qrc:/document-edit.svg"
            emojiSize: Maui.Style.iconSizes.huge
            isMask: false
            title : qsTr("This book is empty!")
            body: qsTr("Start by creating a new chapter for your book")
        }

        Maui.ListBrowser
        {
            id: _listView
            visible: _booksList.booklet.count >0
            anchors.fill: parent
            orientation: ListView.Horizontal
            model:  Maui.BaseModel
            {
                id: _bookletModel
                list: _booksList.booklet
                sortOrder: Qt.DescendingOrder
                sort: "modified"
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive
            }

            spacing: Maui.Style.space.medium
            delegate: CardDelegate
            {
                width: Math.min(_listView.width * 0.7, 400)
                noteColor: Qt.lighter(Kirigami.Theme.backgroundColor)
                height: _listView.height

                onClicked:
                {
                    _listView.currentIndex = index
                    currentBooklet = _bookletModel.get(index)
                }
            }
        }
    }

    Component
    {
        id: _editorView

        Maui.Editor
        {
            id: editor
            enabled: !_holder.visible
            footBar.visible: false
            document.autoReload: true
            body.font: root.font

            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }

            headBar.rightContent: [

                ToolButton
                {
                    enabled: editor.document.modified
                    icon.name: "document-save"
                    text: qsTr("Save")
                    onClicked:
                    {
                        currentBooklet.content = editor.text
                        _booksList.booklet.update(currentBooklet, _listView.currentIndex)
                    }
                },

                ToolButton
                {
                    icon.name: "edit-delete"
                    icon.color: Kirigami.Theme.negativeTextColor
                    onClicked:
                    {
                        _booksList.booklet.remove(_listView.currentIndex)
                    }
                }
            ]

            Maui.Holder
            {
                id: _holder
                visible: _listView.count === 0
                emoji: "qrc:/document-edit.svg"
                emojiSize: Maui.Style.iconSizes.huge
                isMask: false
                title : qsTr("Nothing to edit!")
                body: qsTr("Select a chapter or create a new one")
            }
        }
    }

    Maui.Dialog
    {
        id: _newChapter

        title: qsTr("New Chapter")
        message: qsTr("Create a new chapter for your current book. Give it a title")
        entryField: true
        page.margins: Maui.Style.space.big
        onAccepted:
        {
            _booksList.booklet.insert({content: textEntry.text})
            _newChapter.close()
            _listView.currentIndex = _listView.count-1
            control.currentBooklet = _bookletModel.get(_listView.currentIndex)
        }
    }
}

