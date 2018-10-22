import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.2 as Kirigami

import BuhoModel 1.0
import Notes 1.0
import OWL 1.0 //To get the enums

import "../../widgets"

Maui.Page
{
    property var currentNote : ({})

    property alias cardsView : cardsView
    property alias model : notesModel
    property alias list : notesList
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

            Maui.Menu
            {
                id: sortMenu
                parent: parent

                Maui.MenuItem
                {
                    text: qsTr("Ascedent")
                    checkable: true
                    checked: notesList.order === Notes.ASC
                    onTriggered: notesList.order = Notes.ASC
                }

                Maui.MenuItem
                {
                    text: qsTr("Descendent")
                    checkable: true
                    checked: notesList.order === Notes.DESC
                    onTriggered: notesList.order = Notes.DESC
                }

                MenuSeparator{}

                Maui.MenuItem
                {
                    text: qsTr("Title")
                    onTriggered: notesList.sortBy = KEY.TITLE
                }

                Maui.MenuItem
                {
                    text: qsTr("Color")
                    onTriggered: notesList.sortBy = KEY.COLOR
                }

                Maui.MenuItem
                {
                    text: qsTr("Add date")
                    onTriggered: notesList.sortBy = KEY.ADD_DATE
                }

                Maui.MenuItem
                {
                    text: qsTr("Updated")
                    onTriggered: notesList.sortBy = KEY.UPDATED
                }

                Maui.MenuItem
                {
                    text: qsTr("Fav")
                    onTriggered: notesList.sortBy = KEY.FAV
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

    Notes
    {
        id: notesList
    }

    BuhoModel
    {
        id: notesModel
        list: notesList
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
                    currentNote = notesList.get(index)
                    noteClicked(currentNote)
                }

                onRightClicked:
                {
                    currentIndex = index
                    currentNote = notesList.get(index)
                    cardsView.menu.popup()
                }

                onPressAndHold:
                {
                    currentIndex = index
                    currentNote = notesList.get(index)
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
                onOpened:
                {
                    cardsView.menu.isFav = currentNote.fav == 1 ? true : false
                    cardsView.menu.isPin = currentNote.pin == 1 ? true : false
                }

                onDeleteClicked: notesList.remove(cardsView.currentIndex)
                onColorClicked:
                {
                    notesList.update(({"color": color}), cardsView.currentIndex)
                }

                onFavClicked:
                {
                    notesList.update(({"fav": fav}), cardsView.currentIndex)
                }

                onPinClicked:
                {
                    notesList.update(({"pin": pin}), cardsView.currentIndex)
                }

                onCopyClicked:
                {
                    Maui.Handy.copyToClipboard(currentNote.title+"\n"+currentNote.body)
                }
            }
        }
    }
}
