import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami
import Links 1.0

import "../../widgets"

Maui.Page
{
    id: control

    property alias cardsView : cardsView
    property alias model : linksModel
    property alias list : linksList
    property alias currentIndex : cardsView.currentIndex

    property var currentLink : ({})

    signal linkClicked(var link)

    headBar.visible: linksList.count > 0
    padding: Maui.Style.space.big

    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: linksList.count + " " + qsTr("links")
        onAccepted: linksModel.filter = text
        onCleared: linksModel.filter = ""
    }

    headBar.leftContent: ToolButton
    {
        icon.name: cardsView.gridView ? "view-list-icons" : "view-list-details"
        onClicked: cardsView.gridView = !cardsView.gridView
    }

    headBar.rightContent: [

        ToolButton
        {
            icon.name: "view-sort"
            onClicked: sortMenu.open();

            Menu
            {
                id: sortMenu

                MenuItem
                {
                    text: qsTr("Ascedent")
                    checkable: true
                    checked: linksList.order === Links.ASC
                    onTriggered: linksList.order = Links.ASC
                }

                MenuItem
                {
                    text: qsTr("Descendent")
                    checkable: true
                    checked: linksList.order === Links.DESC
                    onTriggered: linksList.order = Links.DESC
                }

                MenuSeparator{}

                MenuItem
                {
                    checkable: true
                    text: qsTr("Title")
                    onTriggered: Links.TITLE
                }              

                MenuItem
                {
                    checkable: true
                    text: qsTr("Add date")
                    onTriggered: linksList.sortBy = Links.ADD_DATE
                }

                MenuItem
                {
                    checkable: true
                    text: qsTr("Updated")
                    onTriggered: linksList.sortBy = Links.MODIFIED
                }

                MenuItem
                {
                    checkable: true
                    text: qsTr("Favorite")
                    onTriggered: linksList.sortBy = Links.FAVORITE
                }
            }
        }
    ]

    Links
    {
        id: linksList
    }

    Maui.BaseModel
    {
        id: linksModel
        list: linksList
    }

    CardsView
    {
        id: cardsView
        anchors.fill: parent
        holder.emoji: "qrc:/view-links.svg"
        holder.title : qsTr("No Links!")
        holder.body: qsTr("Click here to save a new link")
        holder.emojiSize: Maui.Style.iconSizes.huge
        itemHeight: Maui.Style.unit * 250

        model: linksModel

        delegate: LinkCardDelegate
        {
            id: delegate
            width: Math.min(cardsView.cellWidth, cardsView.itemWidth) - Kirigami.Units.largeSpacing * 2
            height: cardsView.itemHeight
            anchors.left: parent.left
            anchors.leftMargin: cardsView.width <= cardsView.itemWidth ? 0 : (index % 2 === 0 ? Math.max(0, cardsView.cellWidth - cardsView.itemWidth) :
                                                                                                cardsView.cellWidth)

            onClicked:
            {
                currentIndex = index
                currentLink = linksList.get(index)
                linkClicked(linksList.get(index))
            }

            onRightClicked:
            {
                currentIndex = index
                currentLink = linksList.get(index)
                cardsView.menu.popup()
            }

            onPressAndHold:
            {
                currentIndex = index
                currentLink = linksList.get(index)
                cardsView.menu.popup()
            }
        }

        Connections
        {
            target: cardsView.holder
            onActionTriggered: newLink()
        }

        Connections
        {
            target: cardsView.menu
            onDeleteClicked: linksList.remove(cardsView.currentIndex)
            onOpened:
            {
                cardsView.menu.isFav = currentLink.fav == 1 ? true : false
                cardsView.menu.isPin = currentLink.pin == 1 ? true : false
            }
            onColorClicked:
            {
                linksList.update(({"color": color}), cardsView.currentIndex)
            }

            onFavClicked:
            {
                linksList.update(({"fav": fav}), cardsView.currentIndex)
            }

            onPinClicked:
            {
                linksList.update(({"pin": pin}), cardsView.currentIndex)
            }

            onCopyClicked:
            {
                Maui.Handy.copyToClipboard(currentLink.title+"\n"+currentLink.link)
            }
        }
    }
}
