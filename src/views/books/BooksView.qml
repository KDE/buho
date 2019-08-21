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
    }

    Maui.Page
    {
        id: _booksPage
        padding: showDetails ? 0 : space.big

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

        headBar.rightContent: [
            ToolButton
            {
                icon.name: "view-sort"
            }
        ]


        Maui.GridView
        {
            id: cardsView
            anchors.fill: parent
            adaptContent: !showDetails
            itemSize: showDetails ? iconSizes.big : iconSizes.huge
            //        centerContent: true
            spacing: space.huge

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
                        radius: radiusV
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
                        margins: space.small
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
                        _stackView.push(_bookletComponent)
                    }
                }
            }

        }

    }


}
