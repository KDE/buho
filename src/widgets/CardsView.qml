import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.2 as Kirigami
import org.kde.maui 1.0 as Maui

GridView
{
    property alias holder : holder
    property int itemWidth : Kirigami.Units.devicePixelRatio * 200
    property int itemHeight: Kirigami.Units.devicePixelRatio * 120
    property int itemSpacing: space.huge

    signal itemClicked(int index)

    cellWidth: itemWidth + itemSpacing
    cellHeight: itemHeight + itemSpacing

    Maui.Holder
    {
        id: holder
        visible: count < 1
        message: "<h3>No notes!</h3><p>You can create new notes<br>links and books</p>"
    }

    model: ListModel { }

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

    onWidthChanged: adaptGrid()

    function adaptGrid()
    {
        var amount = parseInt(width/(itemWidth + itemSpacing),10)
        var leftSpace = parseInt(width-(amount*(itemWidth + itemSpacing)), 10)
        var size = parseInt((itemWidth + itemSpacing)+(parseInt(leftSpace/amount, 10)), 10)

        size = size > itemWidth + itemSpacing ? size : itemWidth + itemSpacing

        cellWidth = size
    }
}
