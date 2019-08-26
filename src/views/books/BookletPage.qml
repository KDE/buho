import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Item
{
    id: control

    signal exit()


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
//                onClicked: control.exit()
            },

            TextField
            {
                id: title
                Layout.fillWidth: true
                Layout.margins: space.medium
                placeholderText: qsTr("New chapter...")
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
        ]


        Maui.Holder
        {
            id: _holder
            visible: !_listView.count
            emoji: "qrc:/Type.png"
            emojiSize: iconSizes.huge
            isMask: false
            title : "Nothing to edit!"
            body: "Select a chapter or create a new one"
        }

        Maui.Editor
        {
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
                anchors.fill: parent

                title: "argh"

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
                    anchors.margins: space.huge
                    visible: !_listView.count
                    emoji: "qrc:/E-reading.png"
                    emojiSize: iconSizes.huge
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
                    delegate: Maui.LabelDelegate
                    {
                        id: _delegate
                        label: index  + " - " + model.title

                        Connections
                        {
                            target:_delegate

                            onClicked:
                            {
                                _listView.currentIndex = index
                                console.log("Booklet cliked:",  _booksList.booklet.get(index).url, _booksList.booklet.get(index).content )
                            }
                        }
                    }


                }

                Rectangle
                {
                    z: 999
                    anchors.bottom: parent.bottom
                    anchors.margins: space.huge
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: toolBarHeight
                    width: height

                    color: Kirigami.Theme.positiveTextColor
                    radius: radiusV

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
