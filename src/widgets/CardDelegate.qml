import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.2 as Kirigami

ItemDelegate
{
    id: control
    property int cardWidth: Kirigami.Units.devicePixelRatio*200
    property int cardHeight: Kirigami.Units.devicePixelRatio*120

    width: cardWidth
    height: cardHeight

    background: Rectangle
    {
        color: "transparent"

    }

    DropShadow
    {
        anchors.fill: card
        visible: card.visible
        horizontalOffset: 0
        verticalOffset: 3
        radius: 8.0
        samples: 17
        color: "#80000000"
        source: card
    }

    Rectangle
    {
        id: card
        z: -999
        anchors.centerIn: control
        anchors.fill: control

        color: model.color || viewBackgroundColor
        radius: Kirigami.Units.devicePixelRatio*3
    }

    ColumnLayout
    {
        anchors.fill: parent
        spacing: 0
        Label
        {
            Layout.margins: space.medium
            Layout.fillWidth: true
            text: title
            font.weight: Font.Bold
            font.bold: true
        }

        TextArea
        {
            Layout.margins: space.medium
            Layout.fillHeight: true
            Layout.fillWidth: true
            enabled: false
            text: body

            background: Rectangle
            {
                color: "transparent"
            }
        }
    }


}
