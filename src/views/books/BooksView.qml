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
            adaptContent: false
            itemSize:  Maui.Style.iconSizes.huge + Maui.Style.space.big
            //        centerContent: true
            spacing: Maui.Style.space.huge

            cellHeight: itemSize * 1.5

            model: _booksModel

            delegate: Maui.ItemDelegate
            {
                id: _delegate

                width: cardsView.cellWidth
                height: cardsView.cellHeight

                padding: Maui.Style.space.small

                background: Item {}
                isCurrentItem: GridView.isCurrentItem

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: model.url

                Maui.GridItemTemplate
                {
                    isCurrentItem: _delegate.isCurrentItem

                    anchors.fill: parent
                    label1.text: model.title
                    iconSizeHint: parent.height * 0.6
                    imageSource:  "qrc:/booklet.svg"
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
