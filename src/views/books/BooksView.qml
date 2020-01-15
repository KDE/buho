import QtQuick 2.9
import "../../widgets"
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

import Books 1.0

StackView
{
    id: control

    property alias list : _booksList
    property alias cardsView : cardsView
    property bool showDetails: false
    property var currentBook : ({})

    StackView
    {
        id: _stackView
        anchors.fill: parent
        initialItem: _booksPage
    }

    Component
    {
        id: _bookletComponent

        BookletPage
        {
            onExit: _stackView.pop()
        }
    }


    Maui.BaseModel
    {
        id: _booksModel
        list: _booksList
    }

    Books
    {
        id: _booksList
        currentBook: cardsView.currentIndex
    }

    Maui.Page
    {
        id: _booksPage
        padding: showDetails ? 0 : Maui.Style.space.big

        title : cardsView.count + " books"
        //    headBar.leftContent: [
        //        ToolButton
        //        {
        //            icon.name:  showDetails ? "view-list-icons" : "view-list-details"
        //            onClicked:
        //            {
        //                showDetails = !showDetails
        //            }
        //        }
        //    ]

        headBar.visible: !_holder.visible
        headBar.rightContent: [
            ToolButton
            {
                icon.name: "view-sort"
            }
        ]

        Maui.Holder
        {
            id: _holder
            visible: !cardsView.count
            emoji: "qrc:/view-books.svg"
            emojiSize: Maui.Style.iconSizes.huge
            title : qsTr("There are not Books!")
            body: qsTr("You can create new books and organize your notes")
        }



        Maui.GridView
        {
            id: cardsView
            visible: !_holder.visible
            anchors.fill: parent
            adaptContent: !showDetails
            itemSize: showDetails ? Maui.Style.iconSizes.big : Maui.Style.iconSizes.huge
            //        centerContent: true
            spacing: Maui.Style.space.huge

            cellWidth: showDetails ?  parent.width : itemSize * 1.5
            cellHeight: itemSize * 1.5

            model: _booksModel


            delegate: ItemDelegate
            {
                id: _delegate

                width: cardsView.cellWidth * 0.9
                height: cardsView.cellHeight

                hoverEnabled: !isMobile
                background: Rectangle
                {
                    color: "transparent"
                }

                ColumnLayout
                {
                    anchors.fill : parent

                    Item
                    {
                        Layout.fillWidth: true
                        Layout.preferredHeight: cardsView.itemSize

                        Image
                        {
                            id: _img
                            anchors.centerIn: parent
                            source: "qrc:/booklet.svg"
                            sourceSize.width: cardsView.itemSize
                            sourceSize.height: cardsView.itemSize
                        }
                    }

                    Rectangle
                    {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        color: hovered ? Kirigami.Theme.highlightColor : "transparent"
                        radius: Maui.Style.radiusV
                        Label
                        {
                            width: parent.width
                            height: parent.height
                            color: hovered ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            text: model.title
                            horizontalAlignment: Qt.AlignHCenter

                        }
                    }

                }

                Maui.Badge
                {
                    anchors
                    {
                        left: parent.left
                        top: parent.top
                        margins: Maui.Style.space.small
                    }

                    Kirigami.Theme.backgroundColor: Kirigami.Theme.neutralTextColor
                    Kirigami.Theme.textColor: Qt.darker(Kirigami.Theme.neutralTextColor, 2.4)

                    text: model.count
                }

                Connections
                {
                    target:_delegate

                    onClicked:
                    {
                        console.log("BOOKLET CLICKED", index)
                        cardsView.currentIndex = index
                        control.currentBook = _booksList.get(index)
                        _stackView.push(_bookletComponent)
                    }
                }
            }
        }
    }
}
