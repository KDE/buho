import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Item
{
    id: control

    property var currentBooklet : null
    signal exit()

    onCurrentBookletChanged:
    {
        editor.document.load(currentBooklet.url)
        _sidebar.title = currentBook.title
    }

    Maui.BaseModel
    {
        id: _bookletModel
        list: _booksList.booklet
    }

    Maui.Page
    {
        id: _page
        anchors.fill: parent
        title: currentBooklet.title

        headBar.leftContent: [
            ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.exit()
            },

            Kirigami.Separator
            {
               Layout.fillHeight: true

            },

            ToolButton
            {
              icon.name: "view-calendar-list"
              text: qsTr("Chapters")
              onClicked: checked ? _layout.currentIndex = 0 : _layout.currentIndex = 1
              checked: _layout.firstVisibleItem === _sidebar

            }
        ]

        Maui.Holder
        {
            id: _holder
            visible: !_listView.count || !currentBooklet
            emoji: "qrc:/document-edit.svg"
            emojiSize: Maui.Style.iconSizes.huge
            isMask: false
            title : qsTr("Nothing to edit!")
            body: qsTr("Select a chapter or create a new one")
        }


        Kirigami.PageRow
        {
            id: _layout
            anchors.fill: parent
            initialPage: [_sidebar, editor]
            interactive: true
defaultColumnWidth: Kirigami.Units.gridUnit * 11
            Maui.Editor
            {
                id: editor
                visible: !_holder.visible
                footBar.visible: false
                document.autoReload: true

                headBar.rightContent: [

                    ToolButton
                    {
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
            }

            Maui.Page
            {

                id: _sidebar
                headBar.visible: true
                headBar.rightContent: ToolButton
                {
                    icon.name: "view-sort"
                }

                background: Rectangle
                {
                    color: "transparent"
                }

                Maui.Holder
                {
                    anchors.margins: Maui.Style.space.huge
                    visible: !_listView.count
                    emoji: "qrc:/document-edit.svg"
                    emojiSize: Maui.Style.iconSizes.huge
                    isMask: false
                    title : qsTr("This book is empty!")
                    body: qsTr("Start by creating a new chapter for your book by clicking the + icon")
                }

                ListView
                {
                    id: _listView
                    anchors.fill: parent
                    model: _bookletModel
                    clip: true

                    onCountChanged:
                    {
                        _listView.currentIndex = count-1
                        control.currentBooklet = _booksList.booklet.get(_listView.currentIndex)
                    }

                    footerPositioning: ListView.OverlayFooter
                    footer: Button
                    {
                        text: qsTr("New chapter")
                        onClicked: _newChapter.open()

                        height: Maui.Style.rowHeight
                        width: parent.width
                        Kirigami.Theme.backgroundColor: Kirigami.Theme.positiveTextColor
                        Kirigami.Theme.textColor: "white"
                    }

                    delegate: Maui.LabelDelegate
                    {
                        id: _delegate
                        width: parent.width
                        label: index+1  + " - " + model.title

                        Connections
                        {
                            target:_delegate

                            onClicked:
                            {
                                _listView.currentIndex = index
                                currentBooklet =  _booksList.booklet.get(index)
                            }
                        }
                    }
                }
            }
        }

        Maui.Dialog
        {
            id: _newChapter

            title: qsTr("New Chapter")
            message: qsTr("Create a new chapter for your current book. Give it a title")
            entryField: true
            page.padding: Maui.Style.space.huge
            onAccepted:
            {
                _booksList.booklet.insert({content: textEntry.text})
            }
        }

    }
}
