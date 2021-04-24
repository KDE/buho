import QtQuick 2.14
import "../../widgets"
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.4
import org.mauikit.controls 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

import org.maui.buho 1.0

StackView
{
    id: control

    property alias list : _booksList
    property alias cardsView : cardsView
    property var currentBook : ({})

    readonly property bool editing : depth > 1

    Component
    {
        id: _bookletComponent

        BookletPage
        {
            onExit: control.pop()
        }
    }

    initialItem: Maui.Page
    {
        id: _booksPage

        headBar.middleContent: Maui.TextField
        {
            enabled: !_holder.visible
            Layout.fillWidth: true
            placeholderText: i18n("Search ") + _booksList.count + " " + i18n("books")
            onAccepted: _booksModel.filter = text
            onCleared: _booksModel.filter = ""
        }

        headBar.rightContent: ToolButton
        {
            icon.name: "list-add"
            onClicked: newBook()
        }

        Maui.Holder
        {
            id: _holder
            visible: _booksList.count === 0
            emoji: "qrc:/view-books.svg"
            emojiSize: Maui.Style.iconSizes.huge
            title : i18n("There are no Books!")
            body: i18n("You can create new books and organize your notes")
        }

        Maui.AltBrowser
        {
            id: cardsView

            headBar.visible: false
            visible: !_holder.visible
            viewType: root.isWide ? Maui.AltBrowser.ViewType.Grid : Maui.AltBrowser.ViewType.List

            anchors.fill: parent
            gridView.itemSize: 140
            gridView.itemHeight: gridView.itemSize * 1.2
            listView.snapMode: ListView.SnapOneItem

            model: Maui.BaseModel
            {
                id: _booksModel
                sortOrder: settings.sortOrder
                sort: settings.sortBy
                recursiveFilteringEnabled: true
                sortCaseSensitivity: Qt.CaseInsensitive
                filterCaseSensitivity: Qt.CaseInsensitive

                list: Books
                {
                    id: _booksList
                    currentBook: _booksList.mappedIndex(cardsView.currentIndex)
                }
            }

            listDelegate: Maui.ItemDelegate
            {
                id: _listDelegate
                width: ListView.view.width
                height: Maui.Style.rowHeight * 2
                isCurrentItem: ListView.isCurrentItem

                Kirigami.Theme.backgroundColor: Qt.lighter(control.Kirigami.Theme.backgroundColor, 2)

                RowLayout
                {
                    anchors.fill: parent

                    Rectangle
                    {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height
                        Layout.margins: Maui.Style.space.small
                        color: model.color
                        radius: Maui.Style.radiusV

                       Label
                       {
                           text: model.title[0].toUpperCase()
                           font.pointSize: Maui.Style.iconSizes.big
                           color: Qt.lighter(parent.color)
                           anchors.centerIn: parent
                       }
                    }

                    Maui.ListItemTemplate
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        rightMargin: Maui.Style.space.small
                        isCurrentItem: _listDelegate.isCurrentItem
                        hovered: _listDelegate.hovered
                        label1.text: model.title
                        //                        labe1.font.bold: true
                        label1.font.weight: Font.Bold
                        label2.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")

                        Maui.Badge
                        {
                            radius: 4
                            text: model.count
                        }
                    }
                }

                onClicked:
                {
                    cardsView.currentIndex = index
                    control.currentBook = model
                    control.push(_bookletComponent)
                }

            }

            gridDelegate: Maui.ItemDelegate
            {
                id: _delegate

                width: cardsView.gridView.cellWidth
                height: cardsView.gridView.cellHeight
                isCurrentItem: GridView.isCurrentItem

                background: Item {}

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: model.url

                ColumnLayout
                {
                    height: cardsView.gridView.itemHeight - 10
                    width: cardsView.gridView.itemSize - 20
                    anchors.centerIn: parent
                    spacing: Maui.Style.space.medium
                    Rectangle
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: model.color
                        radius: Maui.Style.radiusV

                        Label
                        {
                            text: model.title[0].toUpperCase()
                            font.pointSize: Maui.Style.iconSizes.huge
                            color: Qt.lighter(parent.color)
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            anchors.fill: parent
                        }
                    }

                    Maui.ListItemTemplate
                    {
                        isCurrentItem: _delegate.isCurrentItem
                        hovered: _delegate.hovered
                        Layout.fillWidth: true
                        label1.text: model.title
                        //                        labe1.font.bold: true
                        label1.font.weight: Font.Bold
                        label2.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")

                        Maui.Badge
                        {
                            radius: 4
                            text: model.count
                        }
                    }
                }

                onClicked:
                {
                    cardsView.currentIndex = index
                    control.currentBook = model
                    console.log("CurrentBOok ", control.currentBook.title)
                    control.push(_bookletComponent)
                }
            }
        }
    }
}







