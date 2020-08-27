import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab

import org.kde.kirigami 2.7 as Kirigami
import Notes 1.0
import Qt.labs.platform 1.0 as Labs

import "../../widgets"

StackView
{
    id: control
    property var currentNote : ({})

    property alias cardsView : cardsView
    property alias list : notesList
    property alias currentIndex : cardsView.currentIndex

    function setNote(note)
    {
        control.push(_editNoteComponent, {}, StackView.Immediate)
        currentNote = note
        control.currentItem.editor.body.forceActiveFocus()
    }

    function newNote()
    {
        control.push(_newNoteComponent, {}, StackView.Immediate)
        control.currentItem.editor.body.forceActiveFocus()
    }

    Component
    {
        id: _editNoteComponent
        NewNoteDialog
        {
            note: control.currentNote
            onNoteSaved: control.list.update(note, control.currentIndex)
        }
    }

    Component
    {
        id: _newNoteComponent
        NewNoteDialog
        {
            onNoteSaved: control.list.insert(note)
        }
    }

    initialItem: CardsView
    {
        id: cardsView

        holder.visible: notesList.count < 1
        holder.emoji: "qrc:/view-notes.svg"
        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.title :qsTr("No notes!")
        holder.body: qsTr("Click here to create a new note")

        model: Maui.BaseModel
        {
            id: notesModel
            list: Notes
            {
                id: notesList
            }
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        headBar.visible: !holder.visible
        headBar.leftContent: Maui.ToolActions
        {
            autoExclusive: true
            expanded: isWide
            currentIndex : cardsView.viewType === MauiLab.AltBrowser.ViewType.List ? 0 : 1
            display: ToolButton.TextBesideIcon

            Action
            {
                text: qsTr("List")
                icon.name: "view-list-details"
                onTriggered: cardsView.viewType = MauiLab.AltBrowser.ViewType.List
            }

            Action
            {
                text: qsTr("Cards")
                icon.name: "view-list-icons"
                onTriggered: cardsView.viewType= MauiLab.AltBrowser.ViewType.Grid
            }
        }

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: qsTr("Search ") + notesList.count + " " + qsTr("notes")
            onAccepted: notesModel.filter = text
            onCleared: notesModel.filter = ""
        }

        headBar.rightContent: [
            ToolButton
            {
                icon.name: "view-sort"
                onClicked: sortMenu.open();

                Menu
                {
                    id: sortMenu

                    Labs.MenuItemGroup
                    {
                        id: orderGroup
                    }

                    Labs.MenuItemGroup
                    {
                        id: sortGroup
                    }

                    MenuItem
                    {
                        text: qsTr("Ascedent")
                        checkable: true
                        checked: notesList.order === Notes.ASC
                        onTriggered: notesList.order = Notes.ASC
                    }

                    MenuItem
                    {
                        text: qsTr("Descendent")
                        checkable: true
                        checked: notesList.order === Notes.DESC
                        onTriggered: notesList.order = Notes.DESC
                    }

                    MenuSeparator{}

                    Labs.MenuItem
                    {
                        text: qsTr("Title")
                        checkable: true
                        checked: notesList.sortBy === Notes.TITLE
                        onTriggered: notesList.sortBy = Notes.TITLE
                        group: orderGroup
                    }

                    Labs.MenuItem
                    {
                        text: qsTr("Color")
                        checkable: true
                        checked: notesList.sortBy === Notes.COLOR
                        onTriggered: notesList.sortBy = Notes.COLOR
                        group: orderGroup
                    }

                    Labs.MenuItem
                    {
                        text: qsTr("Add date")
                        checkable: true
                        checked: notesList.sortBy === Notes.ADDDATE
                        onTriggered: notesList.sortBy = Notes.ADDDATE
                        group: orderGroup
                    }

                    Labs.MenuItem
                    {
                        text: qsTr("Updated")
                        checkable: true
                        checked: notesList.sortBy === Notes.Modified
                        onTriggered: notesList.sortBy = Notes.Modified
                        group: orderGroup
                    }

                    Labs.MenuItem
                    {
                        text: qsTr("Favorite")
                        checkable: true
                        checked: notesList.sortBy === Notes.FAVORITE
                        onTriggered: notesList.sortBy = Notes.FAVORITE
                        group: orderGroup
                    }
                }
            },
            ToolButton
            {
                id: favButton
                icon.name: "love"
                checkable: true
                icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            }
        ]

        listDelegate: CardDelegate
        {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Maui.Style.space.big
            height: 150

            onClicked:
            {
                currentIndex = index
                setNote(notesList.get(index))
            }

            onRightClicked:
            {
                currentIndex = index
                currentNote = notesList.get(index)
                _notesMenu.popup()
            }

            onPressAndHold:
            {
                currentIndex = index
                currentNote = notesList.get(index)
                _notesMenu.popup()
            }
        }

        gridDelegate: Item
        {
            id: delegate
            width: cardsView.gridView.cellWidth
            height: cardsView.gridView.cellHeight

            CardDelegate
            {
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium

                onClicked:
                {
                    currentIndex = index
                    setNote(notesList.get(index))
                }

                onRightClicked:
                {
                    currentIndex = index
                    currentNote = notesList.get(index)
                    _notesMenu.popup()
                }

                onPressAndHold:
                {
                    currentIndex = index
                    currentNote = notesList.get(index)
                    _notesMenu.popup()
                }
            }
        }

        Connections
        {
            target: cardsView.holder
            function onActionTriggered()
            {
                newNote()
            }
        }

        Menu
        {
            id: _notesMenu
            width: colorBar.implicitWidth + Maui.Style.space.medium

            property bool isFav: currentNote.favorite == 1

            MenuItem
            {
                icon.name: "love"
                text: qsTr(_notesMenu.isFav? "UnFav" : "Fav")
                onTriggered:
                {
                    notesList.update(({"favorite": _notesMenu.isFav ? 0 : 1}), cardsView.currentIndex)
                    _notesMenu.close()
                }
            }

            MenuItem
            {
                icon.name: "document-export"
                text: qsTr("Export")
                onTriggered:
                {
                    _notesMenu.close()
                }
            }

            MenuItem
            {
                icon.name : "edit-copy"
                text: qsTr("Copy")
                onTriggered:
                {
                    Maui.Handy.copyToClipboard({'text': currentNote.content})
                    _notesMenu.close()
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
                    notesList.remove(cardsView.currentIndex)
                    _notesMenu.close()
                }
            }

            MenuSeparator { }

            MenuItem
            {
                width: parent.width
                height: Maui.Style.rowHeight

                ColorsBar
                {
                    id: colorBar
                    anchors.centerIn: parent
                    onColorPicked:
                    {
                        notesList.update(({"color": color}), cardsView.currentIndex)
                        _notesMenu.close()
                    }
                }
            }
        }
    }

}

