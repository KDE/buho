import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.accounts 1.0 as MA

import org.maui.buho 1.0

import "../../widgets"

StackView
{
    id: control
    property var currentNote : ({})

    property alias cardsView : cardsView

    property alias list : notesList
    property alias model : notesModel

    property alias currentIndex : cardsView.currentIndex

    readonly property Flickable flickable : currentItem.flickable

    readonly property bool editing : control.depth > 1

    function setNote(note)
    {
        control.push(_editNoteComponent)
        control.currentItem.editor.body.forceActiveFocus()
        control.currentItem.noteIndex = control.currentIndex
    }

    function newNote(contents)
    {
        control.push(_newNoteComponent, {'text': contents})
        control.currentItem.editor.body.forceActiveFocus()
    }

    Action
    {
        id: _pasteAction
        text: i18n("Paste")
        icon.name: "edit-paste"
        shortcut: "Ctrl+V"
        onTriggered:
        {
            console.log("PASTE NOTE FROM CLIPBOARD")
            newNote(Maui.Handy.getClipboardText())
        }
    }

    Component
    {
        id: _editNoteComponent

        NewNoteDialog
        {
            note: control.currentNote
            onNoteSaved:
            {
                console.log("updating note <<" , note , control.currentIndex , noteIndex, notesModel.mappedToSource(noteIndex))
                control.list.update(note, notesModel.mappedToSource(noteIndex))
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

    Maui.InfoDialog
    {
        id: _removeNotesDialog

        property var notes

        title: i18n("Remove notes")
        message: i18n("Are you sure you want to delete the selected notes?")

        template.iconSource: "view-notes"

        onAccepted:
        {
            console.log (notes)
        }

        onRejected: close()
    }

    initialItem: Maui.AltBrowser
    {
        id: cardsView
        gridView.itemSize: Math.min(300, control.width* 0.4)
        gridView.cellHeight: 180

        enableLassoSelection: true

        viewType: control.width > Maui.Style.units.gridUnit * 30 ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

        floatingFooter: true
        altHeader: Maui.Handy.isMobile

        holder.visible: notesList.count === 0 || cardsView.count === 0
        holder.emoji: "qrc:/view-notes.svg"
        holder.title :i18n("No notes!")
        holder.body: i18n("You can quickly create a new note")

        holder.actions:[ Action
            {
                text: i18n("New note")
                icon.name: "list-add"
                onTriggered: control.newNote()
            }]

        headBar.rightContent: ToolButton
        {
            icon.name: "list-add"
            onClicked: control.newNote()
        }
        headBar.forceCenterMiddleContent: root.isWide
        headBar.middleContent: Loader
        {
            Layout.fillWidth: true
            Layout.maximumWidth: 500
            Layout.alignment: Qt.AlignCenter
            //            active: notesList.count > 0
            //            visible: active
            asynchronous: true

            sourceComponent: Maui.SearchField
            {
                placeholderText: i18n("Search ") + control.list.count + " " + i18n("notes")
                onAccepted: control.model.filter = text
                onCleared: control.model.filter = ""
            }
        }

        headBar.leftContent: Maui.ToolButtonMenu
        {
            icon.name: "application-menu"

            MA.AccountsMenuItem{}

            MenuItem
            {
                text: i18n("Settings")
                icon.name: "settings-configure"
                onTriggered: _settingsDialog.open()
            }

            MenuItem
            {
                text: i18n("About")
                icon.name: "documentinfo"
                onTriggered: root.about()
            }
        }

        property string typingQuery

        Maui.Chip
        {
            z: cardsView.z + 99999
            Maui.Theme.colorSet:Maui.Theme.Complementary
            visible: _typingTimer.running
            label.text: cardsView.typingQuery
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            showCloseButton: false
            anchors.margins: Maui.Style.space.medium
        }

        Timer
        {
            id: _typingTimer
            interval: 250
            onTriggered:
            {
                const index = notesList.indexOfName(cardsView.typingQuery)
                if(index > -1)
                {
                    control.currentIndex = notesModel.mappedFromSource(index)
                }

                cardsView.typingQuery = ""
            }
        }

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
                const item = notesModel.get(index)

                var pat = /^([a-zA-Z0-9 _-]+)$/
                if(event.count === 1 && pat.test(event.text))
                {
                    cardsView.typingQuery += event.text
                    _typingTimer.restart()
                }

                if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
                {
                    cardsView.currentView.itemsSelected([index])
                }

                if(event.key === Qt.Key_Return)
                {
                    currentNote = item
                    setNote()
                }
            }
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

        footer: Maui.SelectionBar
        {
            id: _selectionbar
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)

            maxListHeight: control.height - Maui.Style.space.medium
            display: ToolButton.IconOnly

            onVisibleChanged:
            {
                if(!visible)
                {
                    cardsView.selectionMode = false
                }
            }

            onExitClicked:
            {
                clear()
            }

            listDelegate: Maui.ListBrowserDelegate
            {
                height: Maui.Style.rowHeight
                width: ListView.view.width

                background: Rectangle
                {
                    color: model.color ? model.color : "transparent"
                    radius:Maui.Style.radiusV
                }

                label1.text: model.title
                template.iconVisible: false
                iconSource: "view-pim-notes"
                checkable: true
                checked: true
                onToggled: _selectionbar.removeAtIndex(index)
            }

            Action
            {
                text: i18n("Favorite")
                icon.name: "love"
                onTriggered:
                {
                    for(var item of _selectionbar.items)
                        notesList.update(({"favorite": _notesMenu.isFav ? 0 : 1}), notesModel.mappedToSource(notesList.indexOfNote(item.path)))

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
                Maui.Theme.textColor: Maui.Theme.negativeTextColor
                icon.name: "edit-delete"

                onTriggered:
                {
                    _removeNotesDialog.notes = _selectionbar.uris
                    _removeNotesDialog.open()
                }
            }
        }

        listDelegate: CardDelegate
        {
            id: _listDelegate
            width: ListView.view.width
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
                _notesMenu.show()
            }

            onPressAndHold:
            {
                currentIndex = index
                currentNote = notesModel.get(index)
                _notesMenu.show()
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
                    console.log(index, notesModel.mappedToSource(index), notesList.indexOfNote(model.url))

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
                    _notesMenu.show()
                }

                onPressAndHold:
                {
                    currentIndex = index
                    currentNote = notesModel.get(index)
                    _notesMenu.show()
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

        Maui.ContextualMenu
        {
            id: _notesMenu

            property bool isFav: currentNote.favorite == 1

            Maui.MenuItemActionRow
            {
                Action
                {
                    icon.name: "love"
                    text: _notesMenu.isFav? i18n("UnFav") : i18n("Fav")
                    onTriggered:
                    {
                        notesList.update(({"favorite": _notesMenu.isFav ? 0 : 1}), notesModel.mappedToSource(cardsView.currentIndex))
                        _notesMenu.close()
                    }
                }

                Action
                {
                    icon.name: "document-export"
                    text: i18n("Export")
                    onTriggered:
                    {
                        _notesMenu.close()
                    }
                }

                Action
                {
                    icon.name : "edit-copy"
                    text: i18n("Copy")
                    onTriggered:
                    {
                        Maui.Handy.copyToClipboard({'text': currentNote.content})
                        _notesMenu.close()
                    }
                }

                Action
                {
                    text: i18n("Share")
                    icon.name: "document-share"
                    //                    onTriggered: shareClicked()
                }
            }

            MenuSeparator {}

            MenuItem
            {
                text: i18n("Select")
                icon.name: "item-select"
                onTriggered:
                {
                    if(Maui.Handy.isTouch)
                    {
                        cardsView.selectionMode = true
                    }

                    cardsView.currentView.itemsSelected([cardsView.currentIndex])
                }
            }


            MenuSeparator { }

            MenuItem
            {
                icon.name: "edit-delete"
                text: i18n("Remove")
                Maui.Theme.textColor: Maui.Theme.negativeTextColor
                onTriggered:
                {
                    notesList.remove(notesModel.mappedToSource(cardsView.currentIndex))
                    _notesMenu.close()
                }
            }

            MenuSeparator { }


            ColorsBar
            {
                id: colorBar
                padding: control.padding
                width: parent.width
                currentColor: currentNote.color
                onColorPicked:
                {
                    notesList.update(({"color": color}), notesModel.mappedToSource(cardsView.currentIndex))
                    _notesMenu.close()
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

