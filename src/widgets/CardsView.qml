import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.0 as Maui

GridView
{
    property bool gridView : true

    property alias holder : holder
    property alias menu : cardMenu
    readonly property  int defaultSize : unit * 200
    property int itemWidth : !gridView ?  width :
                                         isMobile? (width-itemSpacing) * 0.42 : unit * 200
    property int itemHeight: unit * 120
    property int itemSpacing:  space.huge

    signal itemClicked(int index)
    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds

    cellWidth: itemWidth + itemSpacing
    cellHeight: itemHeight + itemSpacing
    clip : true

    Maui.Holder
    {
        id: holder
        visible: count < 1
        z: 999
    }


    CardMenu
    {
        id: cardMenu
    }

    model: ListModel { id: cardsModel}

    delegate: CardDelegate
    {
        id: delegate
        cardWidth: itemWidth
        cardHeight: itemHeight

        onClicked:
        {
            currentIndex = index
            itemClicked(index)
        }

        onRightClicked:
        {
            currentIndex = index
            cardMenu.popup()
        }

        onPressAndHold:
        {
            currentIndex = index
            cardMenu.popup()
        }
    }

    //    onWidthChanged: if(!isMobile && gridView) adaptGrid()

    function adaptGrid()
    {
        var amount = parseInt(width/(itemWidth + itemSpacing),10)
        var leftSpace = parseInt(width-(amount*(itemWidth + itemSpacing)), 10)
        var size = parseInt((itemWidth + itemSpacing)+(parseInt(leftSpace/amount, 10)), 10)

        size = size > itemWidth + itemSpacing ? size : itemWidth + itemSpacing

        cellWidth = size

    }

    function refresh()
    {
        model = cardsModel
    }

}
