import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QtQml.Models 2.1

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

import "../../widgets"
import "../../utils/owl.js" as O

import Notes 1.0
import Owl 1.0

Maui.Page
{
    property var currentNote : ({})

    property alias cardsView : cardsView
    property alias model : notesModel
    property alias currentIndex : cardsView.currentIndex

    signal noteClicked(var note)

    margins: space.big

    headBarExit : false
    headBarVisible: !cardsView.holder.visible
    headBarTitle : cardsView.count + " notes"

    headBar.leftContent: [
        Maui.ToolButton
        {
            iconName:  cardsView.gridView ? "view-list-icons" : "view-list-details"
            onClicked:
            {
                cardsView.gridView = !cardsView.gridView
            }
        },
        Maui.ToolButton
        {
            iconName: "view-sort"
            onClicked: sortMenu.open();

            Menu
            {
                id: sortMenu
                MenuItem
                {
                    text: qsTr("Title")
                    onTriggered: notesModel.sortBy(KEY.TITLE, "ASC")
                }

                MenuItem
                {
                    text: qsTr("Color")
                    onTriggered: notesModel.sortBy(KEY.COLOR, "ASC")
                }

                MenuItem
                {
                    text: qsTr("Add date")
                    onTriggered: notesModel.sortBy(KEY.ADD_DATE, "DESC")
                }

                MenuItem
                {
                    text: qsTr("Updated")
                    onTriggered: notesModel.sortBy(KEY.UPDATED, "DESC")
                }
                MenuItem
                {
                    text: qsTr("Fav")
                    onTriggered: notesModel.sortBy(KEY.FAV, "DESC")
                }
            }
        }
    ]

    headBar.rightContent: [
        Maui.ToolButton
        {
            iconName: "tag-recents"

        },
        Maui.ToolButton
        {
            id: pinButton
            iconName: "edit-pin"
            checkable: true
            iconColor: checked ? highlightColor : textColor

        },

        Maui.ToolButton
        {
            iconName: "view-calendar"

        }
    ]

    NotesModel
    {
        id: notesModel
    }




    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0

        Rectangle
        {
            visible: pinButton.checked
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            height: cardsView.itemHeight

            CardsList
            {
                id: pinnedList

                height: parent.height *0.9
                width: parent.width * 0.9
                anchors.centerIn: parent
                itemHeight: cardsView.itemHeight * 0.9
                itemWidth: itemHeight * 1.5
                onItemClicked: noteClicked(cardsView.model.get(index))
            }

            color: altColor
            radius: radiusV

            border.color: Qt.darker(altColor, 1.4)
        }


        CardsView
        {
            id: cardsView
            Layout.fillHeight: true
            Layout.fillWidth: true
            width: parent.width
            holder.emoji: "qrc:/Type.png"
            holder.emojiSize: iconSizes.huge
            holder.isMask: false
            holder.title : "No notes!"
            holder.body: "Click here to create a new note"

            model: notesModel
            delegate: CardDelegate
            {
                id: delegate
                cardWidth: Math.min(cardsView.cellWidth, cardsView.itemWidth) - Kirigami.Units.largeSpacing * 2
                cardHeight: cardsView.itemHeight
                anchors.left: parent.left
                anchors.leftMargin: cardsView.width <= cardsView.itemWidth ? 0 : (index % 2 === 0 ? Math.max(0, cardsView.cellWidth - cardsView.itemWidth) :
                                                                                             cardsView.cellWidth)

                onClicked:
                {
                    currentIndex = index
                    noteClicked(notesModel.get(index))
                }

                onRightClicked:
                {
                    currentIndex = index
                    cardsView.menu.popup()
                }

                onPressAndHold:
                {
                    currentIndex = index
                    cardsView.menu.popup()
                }
            }

            Connections
            {
                target: cardsView.holder
                onActionTriggered: newNote()
            }

            Connections
            {
                target: cardsView.menu
                onDeleteClicked: if(O.removeNote(cardsView.model.get(cardsView.currentIndex)))
                                     cardsView.model.remove(cardsView.currentIndex)
            }
        }
    }
}
