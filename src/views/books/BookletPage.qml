import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.0 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.texteditor 1.0 as TE

import "../../widgets"

StackView
{
    id: control
    clip: true

    property var currentBooklet : null
    signal exit()

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
            placeholderText: i18n("Filter ") + _booksList.booklet.count + " " + i18n("booklets in ") + currentBook.title
            onAccepted: _bookletModel.filter = text
            onCleared: _bookletModel.filter = ""
        }

       headBar.rightContent: ToolButton
       {
            icon.name: "list-add"
            onClicked:  _newChapter.open()
        }

        Maui.Holder
        {
            anchors.margins: Maui.Style.space.huge
            visible: _booksList.booklet.count === 0
            emoji: "qrc:/document-edit.svg"
            emojiSize: Maui.Style.iconSizes.huge
            isMask: false
            title : i18n("This book is empty!")
            body: i18n("Start by creating a new chapter for your book")
        }

        ColumnLayout
        {
            anchors.fill: parent
            visible: _booksList.booklet.count >0
            spacing: 0

            Maui.ListItemTemplate
            {
                Layout.fillWidth: true
                Layout.margins: Maui.Style.space.small
                implicitHeight: Maui.Style.rowHeight * 2
                label1.font.pointSize: Maui.Style.fontSizes.large
                label1.font.weight: Font.Bold
                label1.font.bold: true

                label1.text: currentBook.title
                label2.text: i18n("Notes in this book: ") + currentBook.count
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
                    isCurrentItem: ListView.isCurrentItem

                    onClicked:
                    {
                        _listView.currentIndex = index

                        if(Maui.Handy.singleClick)
                        {
                             control.currentBooklet = _bookletModel.get(index)
                             control.push(_editorView)
                        }
                    }

                    onDoubleClicked:
                    {
                        _listView.currentIndex = index

                        if(!Maui.Handy.singleClick)
                        {
                            control.currentBooklet = _bookletModel.get(index)
                            control.push(_editorView)
                        }
                    }
                }
            }
        }
     }

    Component
    {
        id: _editorView

        TE.TextEditor
        {
            id: editor
            enabled: !_holder.visible
            footBar.visible: false
            document.autoReload: settings.autoReload
            document.autoSave: settings.autoSave
            document.fileUrl: currentBooklet.url
            body.font: settings.font
            showLineNumbers: settings.lineNumbers

            function saveFile(path)
            {
                if (path && FB.FM.fileExists(path))
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
                    text: i18n("Save")
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
                title : i18n("Nothing to edit!")
                body: i18n("Select a chapter or create a new one")
            }
        }
    }

    Maui.Dialog
    {
        id: _newChapter

        title: i18n("New Chapter")
        message: i18n("Create a new chapter for your current book. Give it a title")
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

