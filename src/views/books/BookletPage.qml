import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import "../../widgets"

StackView
{
    id: control
    clip: true

    property var currentBooklet : null
    signal exit()

    onCurrentBookletChanged:
    {
        control.push(_editorView)
        control.currentItem.document.load(currentBooklet.url)
    }

    initialItem: Maui.Page
    {
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

        ColumnLayout
        {
            anchors.fill: parent
            anchors.margins: Maui.Style.space.big
            visible: _booksList.booklet.count >0

            Maui.ListItemTemplate
            {
                Layout.fillWidth: true
                implicitHeight: Maui.Style.rowHeight * 2
                label1.font.pointSize: Maui.Style.fontSizes.large
                label1.font.weight: Font.Bold
                label1.font.bold: true

                label1.text: currentBook.title
                label2.text: qsTr("Notes in this book: ") + currentBook.count
                label3.text: Qt.formatDateTime(new Date(currentBook.modified), "d MMM yyyy")
            }

            Maui.ListBrowser
            {
                id: _listView
                Layout.fillHeight: true
                Layout.fillWidth: true

                margins: Maui.Style.space.big
                spacing: margins
                orientation: ListView.Horizontal

                verticalScrollBarPolicy: ScrollBar.AlwaysOff

                model: Maui.BaseModel
                {
                    id: _bookletModel
                    list: _booksList.booklet
                    sortOrder: Qt.DescendingOrder
                    sort: "modified"
                    recursiveFilteringEnabled: true
                    sortCaseSensitivity: Qt.CaseInsensitive
                    filterCaseSensitivity: Qt.CaseInsensitive
                }

                delegate: CardDelegate
                {
                    width: Math.min(Math.max(200, ListView.view.width * 0.7), 400)
                    noteColor: Qt.lighter(Kirigami.Theme.backgroundColor)
                    height: ListView.view.height

                    onClicked:
                    {
                        _listView.currentIndex = index
                        control.currentBooklet = _bookletModel.get(index)
                    }
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
            document.autoReload: settings.autoReload
            document.autoSave: settings.autoSave
            body.font: settings.font
            showLineNumbers: settings.lineNumbers

            function saveFile(path)
            {
                if (path && Maui.FM.fileExists(path))
                {
                    editor.document.saveAs(path)
                }
        //        else
//                {
        //            _dialogLoader.sourceComponent = _fileDialogComponent
        //            dialog.mode = dialog.modes.SAVE;
        //            //            fileDialog.settings.singleSelection = true
        //            dialog.show(function (paths)
        //            {
        //                item.document.saveAs(paths[0])
        //                _historyList.append(paths[0])
        //            });
//                }
            }

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
                        saveFile(editor.fileUrl)
                        control.currentBooklet.content = editor.text
                        _booksList.booklet.update(control.currentBooklet, _listView.currentIndex)
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
        textEntry.text:  Qt.formatDateTime(new Date(), "d-MMM-yyyy")
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

