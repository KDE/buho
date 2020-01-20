import QtQuick 2.10
import org.kde.mauikit 1.0 as Maui
import QtGraphicalEffects 1.0

ListView
{
    id: control
    clip: true

    property int itemWidth: Maui.Style.unit * 300
    property int itemHeight: Maui.Style.unit * 200
    signal itemClicked(int index)

    boundsBehavior: !isMobile? Flickable.StopAtBounds : Flickable.DragAndOvershootBounds
    orientation: ListView.Horizontal
    spacing: 0   

    model: notesView.model
    delegate: Item
    {
        width: model.pin == 1 ? itemWidth : 0
        height:  model.pin == 1 ? itemHeight : 0
        visible: model.pin == 1

        CardDelegate
        {
            id: cardDelegate
            anchors.fill: parent
            anchors.margins: Maui.Style.space.medium
            anchors.centerIn: parent

            onClicked:
            {
                currentIndex = index
                itemClicked(index)
            }
        }

        DropShadow
        {
            anchors.fill: cardDelegate
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 17
            color: "#80000000"
            source: cardDelegate
        }
    }
}
