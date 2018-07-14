import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui

GridView
{
    property bool gridView : true

    property alias holder : holder
    readonly property  int defaultSize : Kirigami.Units.devicePixelRatio * 200
    property int itemWidth : !gridView ?  parent.width :
                                         isMobile? (width-itemSpacing) * 0.42 : Kirigami.Units.devicePixelRatio * 200
    property int itemHeight: Kirigami.Units.devicePixelRatio * 120
    property int itemSpacing:  space.huge

    signal itemClicked(int index)

    cellWidth: itemWidth + itemSpacing
    cellHeight: itemHeight + itemSpacing

    Maui.Holder
    {
        id: holder
        visible: count < 1
        message: "<h3>No notes!</h3><p>You can create new notes<br>links and books</p>"
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
