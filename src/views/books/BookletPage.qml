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
        _drawerPage.title = currentBook.title
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
        anchors.rightMargin: _drawer.modal === false ? _drawer.contentItem.width * _drawer.position : 0

        headBar.leftContent: [
            ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.exit()
            },

            ToolButton
            {
                icon.name: "document-save"
                onClicked:
                {
                    currentBooklet.content = editor.text
                    currentBooklet.title = title.text
                    _booksList.booklet.update(currentBooklet, _listView.currentIndex)
                }
            },

            TextField
            {
                id: title
                Layout.fillWidth: true
                Layout.fillHeight: true
//                Layout.margins: Maui.Style.space.medium
                placeholderText: qsTr("New chapter...")
                font.weight: Font.Bold
                font.bold: true
                font.pointSize: Maui.Style.fontSizes.large
                text: currentBooklet.title
                //            Kirigami.Theme.backgroundColor: selectedColor
                //            Kirigami.Theme.textColor: Qt.darker(selectedColor, 2.5)
                //            color: fgColor
                background: Rectangle
                {
                    color: "transparent"
                }
            }
        ]


        Maui.Holder
        {
            id: _holder
            visible: !_listView.count || !currentBooklet
            emoji: "qrc:/Type.png"
            emojiSize: Maui.Style.iconSizes.huge
            isMask: false
            title : "Nothing to edit!"
            body: "Select a chapter or create a new one"
        }

        Maui.Editor
        {
            id: editor
            anchors.fill: parent
            visible: !_holder.visible
        }

        Maui.Dialog
        {
            id: _newChapter

            title: qsTr("New Chapter")
            message: qsTr("Create a new chapter for your current book. Give it a title")
            entryField: true

            onAccepted:
            {
                _booksList.booklet.insert({title: textEntry.text})
            }
        }

        Connections
        {
            target: root
            onCurrentViewChanged: _drawer.close()
        }

        Kirigami.OverlayDrawer
        {
            id: _drawer
            edge: Qt.RightEdge
            width: Kirigami.Units.gridUnit * 16
            height: parent.height - _page.headBar.height
            y: _page.headBar.height
            modal: !isWide
            visible: _holder.visible

            contentItem: Maui.Page
            {
                id: _drawerPage
                anchors.fill: parent
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
                    emoji: "qrc:/E-reading.png"
                    emojiSize: Maui.Style.iconSizes.huge
                    isMask: false
                    title : "This book is empty!"
                    body: "Start by creating a new chapter for your book by clicking the + icon"
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

                    delegate: Maui.LabelDelegate
                    {
                        id: _delegate
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

                Rectangle
                {
                    z: 999
                    anchors.bottom: parent.bottom
                    anchors.margins: Maui.Style.space.huge
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: Maui.Style.toolBarHeight
                    width: height

                    color: Kirigami.Theme.positiveTextColor
                    radius: Maui.Style.radiusV

                    ToolButton
                    {
                        anchors.centerIn: parent
                        icon.name: "list-add"
                        icon.color: "white"
                        onClicked: _newChapter.open()
                    }
                }
            }
        }
    }
}
