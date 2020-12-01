import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui

import org.kde.kirigami 2.7 as Kirigami
import org.maui.buho 1.0

import "../../widgets"

StackView
{
    id: control
    property var currentNote : ({})

    property alias cardsView : cardsView
    property alias list : notesList
    property alias currentIndex : cardsView.currentIndex

    readonly property Flickable flickable : currentItem.flickable

    readonly property bool editing : control.depth > 1

    function setNote(note)
    {
        control.push(_editNoteComponent, {}, StackView.Immediate)
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
            onNoteSaved:
            {
                console.log("updating note <<" , note)
                control.list.update(note, control.currentIndex)
            }
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

        floatingFooter: true

        holder.visible: notesList.count < 1
        holder.emoji: "qrc:/view-notes.svg"
        holder.emojiSize: Maui.Style.iconSizes.huge
        holder.title :i18n("No notes!")
        holder.body: i18n("Click here to create a new note")
        enableLassoSelection: true

        viewType: control.width > Kirigami.Units.gridUnit * 25 ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

        Connections
        {
            target: cardsView.currentView
            ignoreUnknownSignals: true

            function onItemsSelected(indexes)
            {
                console.log(indexes)
                for(var index of indexes)
                    select(notesModel.get(index))
            }

            function onKeyPress(event)
            {
                const index = cardsView.currentIndex
                const item = cardsView.model.get(index)

                if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
                {
                    cardsView.currentView.itemsSelected([index])
                }
            }
        }

        headBar.rightContent: ToolButton
        {
            id: _selectButton
            visible: Maui.Handy.isTouch
            icon.name: "item-select"
            checkable: true
            checked: cardsView.selectionMode
            onClicked: cardsView.selectionMode = !cardsView.selectionMode
        }

        model: Maui.BaseModel
        {
            id: notesModel
            list: Notes
            {
                id: notesList
            }
            sortOrder: settings.sortOrder
            sort: settings.sortBy
            recursiveFilteringEnabled: true
            sortCaseSensitivity: Qt.CaseInsensitive
            filterCaseSensitivity: Qt.CaseInsensitive
        }

        Maui.FloatingButton
        {
            z: parent.z + 1
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Maui.Style.space.huge
            anchors.bottomMargin: Maui.Style.space.huge + flickable.bottomMargin
            height: Maui.Style.toolBarHeight

            icon.name: "list-add"
            icon.color: Kirigami.Theme.highlightedTextColor
            onClicked: newNote()
        }

        headBar.visible: !holder.visible
        //        headBar.leftContent: Maui.ToolActions
        //        {
        //            autoExclusive: true
        //            expanded: isWide
        //            currentIndex : cardsView.viewType === MauiLab.AltBrowser.ViewType.List ? 0 : 1
        //            display: ToolButton.TextBesideIcon

        //            Action
        //            {
        //                text: i18n("List")
        //                icon.name: "view-list-details"
        //                onTriggered: cardsView.viewType = MauiLab.AltBrowser.ViewType.List
        //            }

        //            Action
        //            {
        //                text: i18n("Cards")
        //                icon.name: "view-list-icons"
        //                onTriggered: cardsView.viewType= MauiLab.AltBrowser.ViewType.Grid
        //            }
        //        }

        headBar.middleContent: Maui.TextField
        {
            Layout.fillWidth: true
            placeholderText: i18n("Search ") + notesList.count + " " + i18n("notes")
            onAccepted: notesModel.filter = text
            onCleared: notesModel.filter = ""
        }

        footer: Maui.SelectionBar
        {
            id: _selectionbar
            visible: count > 0 && !swipeView.currentItem.editing
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
            padding: Maui.Style.space.big
            maxListHeight: swipeView.height - Maui.Style.space.medium

            onExitClicked: clear()

            Action
            {
                text: i18n("Favorite")
                icon.name: "love"
                onTriggered:
                {
                    for(var item of _selectionbar.items)
                        notesList.update(({"favorite": _notesMenu.isFav ? 0 : 1}), notesList.indexOfNote(item.path))

                    _selectionbar.clear()
                }
            }

            Action
            {
                text: i18n("Share")
                icon.name: "document-share"
            }

            Action
            {
                text: i18n("Export")
                icon.name: "document-export"
            }

            Action
            {
                text: i18n("Delete")
                Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
                icon.name: "edit-delete"
            }
        }

        listDelegate: CardDelegate
        {
            id: _listDelegate
            width: ListView.view.width
            height: 150
            checkable: cardsView.selectionMode
            checked: _selectionbar.contains(model.path)
            isCurrentItem: ListView.isCurrentItem

            onClicked:
            {
                currentIndex = index                

                if(cardsView.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
                {
                    cardsView.currentView.itemsSelected([index])
                }else if(Maui.Handy.singleClick)
                {
                    currentNote = notesModel.get(index)
                    setNote()
                }
            }

            onDoubleClicked:
            {
                control.currentIndex = index
                if(!Maui.Handy.singleClick && !cardsView.selectionMode)
                {
                    currentNote = notesModel.get(index)
                    setNote()
                }
            }

            onRightClicked:
            {
                currentIndex = index
                currentNote = notesModel.get(index)
                _notesMenu.popup()
            }

            onPressAndHold:
            {
                currentIndex = index
                currentNote = notesModel.get(index)
                _notesMenu.popup()
            }

            onToggled:
            {
                currentIndex = index
                select(notesModel.get(index))
            }

            Connections
            {
                target: _selectionbar
                ignoreUnknownSignals: true

                function onUriRemoved(uri)
                {
                    if(uri === model.url)
                    {
                        _listDelegate.checked = false
                    }
                }

                function onUriAdded(uri)
                {
                    if(uri === model.url)
                    {
                        _listDelegate.checked = true
                    }
                }

                function onCleared()
                {
                    _listDelegate.checked = false
                }
            }
        }

        gridDelegate: Item
        {
            id: delegate
            width: cardsView.gridView.cellWidth
            height: cardsView.gridView.cellHeight

            property bool isCurrentItem: GridView.isCurrentItem

            CardDelegate
            {
                id: _gridDelegate
                anchors.fill: parent
                anchors.margins: Maui.Style.space.medium
                checkable: cardsView.selectionMode
                checked: _selectionbar.contains(model.path)
                isCurrentItem: parent.isCurrentItem

                onClicked:
                {
                    currentIndex = index

                    if(cardsView.selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
                    {
                        cardsView.currentView.itemsSelected([index])
                    }else if(Maui.Handy.singleClick)
                    {
                        currentNote = notesModel.get(index)
                        setNote()
                    }
                }

                onDoubleClicked:
                {
                    control.currentIndex = index
                    if(!Maui.Handy.singleClick && !cardsView.selectionMode)
                    {
                        currentNote = notesModel.get(index)
                        setNote()
                    }
                }

                onRightClicked:
                {
                    currentIndex = index
                    currentNote = notesModel.get(index)
                    _notesMenu.popup()
                }

                onPressAndHold:
                {
                    currentIndex = index
                    currentNote = notesModel.get(index)
                    _notesMenu.popup()
                }

                onToggled:
                {
                    currentIndex = index
                    select(notesModel.get(index))
                }
            }

            Connections
            {
                target: _selectionbar
                ignoreUnknownSignals: true

                function onUriRemoved(uri)
                {
                    if(uri === model.url)
                    {
                        _gridDelegate.checked = false
                    }
                }

                function onUriAdded(uri)
                {
                    if(uri === model.url)
                    {
                        _gridDelegate.checked = true
                    }
                }

                function onCleared()
                {
                    _gridDelegate.checked = false
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
                text: _notesMenu.isFav? i18n("UnFav") : i18n("Fav")
                onTriggered:
                {
                    notesList.update(({"favorite": _notesMenu.isFav ? 0 : 1}), cardsView.currentIndex)
                    _notesMenu.close()
                }
            }

            MenuItem
            {
                icon.name: "document-export"
                text: i18n("Export")
                onTriggered:
                {
                    _notesMenu.close()
                }
            }

            MenuItem
            {
                icon.name : "edit-copy"
                text: i18n("Copy")
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
                text: i18n("Remove")
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


    function select(item)
    {
        if(_selectionbar.contains(item.path))
        {
            _selectionbar.removeAtUri(item.path)
        }else
        {
            _selectionbar.append(item.path, item)

        }
    }
}

