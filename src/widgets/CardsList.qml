import QtQuick 2.0
import org.kde.mauikit 1.0 as Maui

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

//    Maui.Holder
//    {
//        id: holder
//        visible: control.count > 0
//        emoji: "qrc:/Type.png"
//        emojiSize: Maui.Style.iconSizes.big
//        isMask: false
//        title : "No pinned notes!"
//        body: "You can pin your notes to see them here"
//        z: 999
//         colorScheme.textColor: altColorText
//   }

    model: notesView.model
    delegate: Item
    {
        width: model.pin == 1 ? itemWidth : 0
        height:  model.pin == 1 ? itemHeight : 0
        visible: model.pin == 1

        CardDelegate
        {
            width: parent.width * 0.8
            height:  parent.height

            anchors.centerIn: parent

            onClicked:
            {
                currentIndex = index
                itemClicked(index)
            }
        }
    }

}
