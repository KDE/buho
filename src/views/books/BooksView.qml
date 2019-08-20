import QtQuick 2.9
import "../../widgets"
import QtQuick.Controls 2.3

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

StackView
{
    id: control

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
            spacing: space.big

            cellWidth: showDetails ?  parent.width : itemSize * 1.5
            cellHeight: itemSize * 1.5

            model: ListModel
            {
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 0}
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 3}
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 10}
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 2}
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 9}
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 2}
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 3}
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 1}
                ListElement {label: "test"; thumbnail:"qrc:/booklet.svg"; mime: "image"; count: 0}


            }

            delegate: Maui.IconDelegate
            {
                id: _delegate

                isDetails: control.showDetails
                folderSize: cardsView.itemSize
                showThumbnails: true
                showEmblem: false
                width: cardsView.cellWidth
                height: cardsView.cellHeight * 0.9

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
