import QtQuick 2.9
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui

GridView
{
    id: control
    property bool gridView : true

    property alias holder : holder
    property alias menu : cardMenu
    readonly property  int defaultSize : Maui.Style.unit * 200
    property int itemWidth : !gridView ?  width :
                                        (Kirigami.Settings.isMobile ? width * 0.5 : Maui.Style.unit * 400)
    property int itemHeight: Maui.Style.unit * 180
    property int itemSpacing:  Maui.Style.space.huge

    signal itemClicked(int index)
    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds

    cellWidth: width > itemWidth ? width/2 : width
    cellHeight: itemHeight + itemSpacing
    topMargin: Kirigami.Units.largeSpacing * 2
    clip : true

    Maui.Holder
    {
        id: holder
        isMask: true
        visible: count < 1
        z: 999
    }

    CardMenu
    {
        id: cardMenu
    }

    ScrollBar.vertical: ScrollBar{ id:scrollBar; visible: !isMobile}
}
