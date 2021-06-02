import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.4

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

import org.maui.buho 1.0

import "../../widgets"

StackView
{
    id: control

    property alias list : _tagsList
    property alias cardsView : cardsView
    property var currentBook : ({})

    readonly property bool editing : depth > 1

//    Component
//    {
//        id: _bookletComponent

//        BookletPage
//        {
//            onExit: control.pop()
//        }
//    }


        FB.NewTagDialog
        {
            id: _newTagDialog
        }

    initialItem: Maui.Page
    {
        id: _booksPage

        headBar.middleContent: Maui.TextField
        {
            enabled: !_holder.visible
            Layout.fillWidth: true
            Layout.maximumWidth: 500

            placeholderText: i18n("Filter ") + _tagsList.count + " " + i18n("tags")
            onAccepted: _booksModel.filter = text
            onCleared: _booksModel.filter = ""
        }

        headBar.rightContent: ToolButton
        {
            icon.name: "list-add"
            onClicked: _newTagDialog.open()
        }

        Maui.Holder
        {
            id: _holder
            visible: _tagsList.count === 0
            emoji: "qrc:/view-books.svg"
            emojiSize: Maui.Style.iconSizes.huge
            title : i18n("There are no Tags!")
            body: i18n("You can create new tags to organize your notes")
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

                list: TagsModel
                {
                    id: _tagsList
                }
            }

            listDelegate: Maui.ListBrowserDelegate
            {
                id: _listDelegate
                width: ListView.view.width
                height: Maui.Style.rowHeight * 2

                label1.text: model.tag
                label1.font.weight: Font.Bold
                label2.text: Qt.formatDateTime(new Date(model.adddate), "d MMM yyyy")
iconVisible: true
                    template.iconComponent: Rectangle
                    {                       
                        color: model.color && model.color.length ? model.color : randomHexColor()
                        radius: Maui.Style.radiusV

                       Label
                       {
                           text: model.tag[0].toUpperCase()
                           font.pointSize: Maui.Style.iconSizes.big
                           color: Qt.lighter(parent.color)
                           anchors.centerIn: parent
                       }
                    }


                onClicked:
                {
                    cardsView.currentIndex = index
//                    control.currentBook = model
//                    control.push(_bookletComponent)
                }

            }

            gridDelegate: Item
            {
                id: _delegate

                width: cardsView.gridView.cellWidth
                height: cardsView.gridView.cellHeight
                readonly property bool isCurrentItem: GridView.isCurrentItem

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: model.tag

                Maui.GridBrowserDelegate
                {
                    isCurrentItem: parent.isCurrentItem
                    height: cardsView.gridView.itemHeight - 10
                    width: cardsView.gridView.itemSize - 20
                    anchors.centerIn: parent
//                    spacing: Maui.Style.space.medium
                    label1.text: model.tag

                    template.iconComponent: Rectangle
                    {

                        color: model.color && model.color.length ? model.color : randomHexColor()
                        radius: Maui.Style.radiusV

                        Label
                        {
                            text: model.tag[0].toUpperCase()
                            font.pointSize: Maui.Style.iconSizes.huge
                            color: Qt.lighter(parent.color)
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            anchors.fill: parent
                        }
                    }
                    onClicked:
                    {
                        cardsView.currentIndex = index
    //                    control.currentBook = model
    //                    console.log("CurrentBOok ", control.currentBook.title)
    //                    control.push(_bookletComponent)
                    }

                }


            }
        }
    }

    function randomHexColor()
      {
          var color = '#', i = 5;
          do{ color += "0123456789abcdef".substr(Math.random() * 16,1); }while(i--);
          return color;
      }
}







