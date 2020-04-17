import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

import org.kde.kirigami 2.2 as Kirigami
import Links 1.0

import "../../widgets"

CardsView
{
    id: control

    property alias list : linksList
    property alias currentIndex : control.currentIndex

    property var currentLink : ({})

    signal linkClicked(var link)

    headBar.visible: linksList.count > 0
    headBar.middleContent: Maui.TextField
    {
        Layout.fillWidth: true
        placeholderText: qsTr("Search ") +linksList.count + " " + qsTr("links")
        onAccepted: linksModel.filter = text
        onCleared: linksModel.filter = ""
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

    holder.emoji: "qrc:/view-links.svg"
    holder.title : qsTr("No Links!")
    holder.body: qsTr("Click here to save a new link")
    holder.emojiSize: Maui.Style.iconSizes.huge
    holder.visible: linksList.count <= 0
    gridView.itemSize: Math.min(defaultSize, control.width)
    gridView.cellHeight: defaultSize + Maui.Style.space.big

    viewType: MauiLab.AltBrowser.ViewType.Grid
    model:  Maui.BaseModel
    {
        id: linksModel
        list: linksList
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
    }

    gridDelegate: Item
    {
        id: delegate
        width: control.gridView.cellWidth
        height: control.gridView.cellHeight

        LinkCardDelegate
        {
            anchors.fill: parent
            anchors.margins: Maui.Style.space.medium

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
                _linksMenu.popup()
            }

            onPressAndHold:
            {
                currentIndex = index
                currentLink = linksList.get(index)
                _linksMenu.popup()
            }
        }
    }

    Connections
    {
        target: control.holder
        onActionTriggered: newLink()
    }

    Menu
    {
        id: _linksMenu
        property bool isFav : currentLink.favorite == 1 ? true : false

        MenuItem
        {
            icon.name: "love"
            text: qsTr(_linksMenu.isFav? "UnFav" : "Fav")
            onTriggered:
            {
                linksList.update(({"favorite": _linksMenu.isFav ? 0 : 1}), control.currentIndex)
                _linksMenu.close()
            }
        }

        MenuItem
        {
            icon.name: "document-export"
            text: qsTr("Export")
            onTriggered:
            {
                _linksMenu.close()
            }
        }

        MenuItem
        {
            icon.name : "edit-copy"
            text: qsTr("Copy")
            onTriggered:
            {
                Maui.Handy.copyToClipboard({'urls': [currentLink.url]})
                _linksMenu.close()
            }
        }

        MenuSeparator { }

        MenuItem
        {
            icon.name: "edit-delete"
            text: qsTr("Remove")
            Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
            onTriggered:
            {
                linksList.remove(control.currentIndex)
                _linksMenu.close()
            }
        }
    }
}

