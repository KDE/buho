import QtQuick 2.10
import QtQuick.Controls 2.10
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.ItemDelegate
{
    id: control
    Kirigami.Theme.inherit: false
    property bool condition : true
    isCurrentItem: GridView.isCurrentItem

    visible: condition
    padding: Maui.Style.space.medium

    Item
    {
        anchors.fill: parent
        anchors.margins: Maui.Style.space.tiny
        anchors.centerIn: parent

        Image
        {
            id: _image

            anchors.fill: parent
            anchors.margins: 1
            sourceSize.height: height
            sourceSize.width: width
            source: model.preview
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true

            onStatusChanged:
            {
                if (status == Image.Error)
                    source = "qrc:/link-default.png";
            }

            layer.enabled: true
            layer.effect: OpacityMask
            {
                maskSource: Item
                {
                    width: _image.width
                    height: _image.height

                    Rectangle
                    {
                        anchors.centerIn: parent
                        width:_image.width
                        height: _image.height
                        radius: Maui.Style.radiusV
                    }
                }
            }
        }

        Item
        {
            id: _labelBg
            height: parent.height * 0.3 + Maui.Style.space.big
            width: parent.width -1
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            Kirigami.Theme.inherit: false
            Kirigami.Theme.backgroundColor: "#333";
            Kirigami.Theme.textColor: "#fafafa"

            FastBlur
            {
                id: blur
                anchors.fill: parent
                source: ShaderEffectSource
                {
                    sourceItem: _image
                    sourceRect:Qt.rect(0,
                                       _image.height - _labelBg.height,
                                       _labelBg.width,
                                       _labelBg.height)
                }
                radius: 50

                Rectangle
                {
                    anchors.fill: parent
                    color: _labelBg.Kirigami.Theme.backgroundColor
                    opacity: 0.2
                }

                layer.enabled: true
                layer.effect: OpacityMask
                {
                    maskSource: Item
                    {
                        width: blur.width
                        height: blur.height

                        Rectangle
                        {
                            anchors.centerIn: parent
                            width: parent.width
                            height: parent.height
                            radius: Maui.Style.radiusV

                            Rectangle
                            {
                                anchors.top: parent.top
                                width: parent.width
                                height: parent.radius
                            }
                        }
                    }
                }
            }

            Label
            {
                id: _label1
                width: parent.width *0.9
                height: Math.min(parent.height * 0.9, implicitHeight)
                anchors.centerIn: parent
                horizontalAlignment: Qt.AlignLeft
                elide: Text.ElideRight
                font.pointSize: Maui.Style.fontSizes.big
                font.bold: true
                font.weight: Font.Bold
                color: Kirigami.Theme.textColor
                wrapMode: Text.WrapAnywhere
                text: model.title
            }
        }

        Rectangle
        {
            anchors.fill: parent
            color: "transparent"
            border.color: Kirigami.Theme.textColor
            opacity: 0.3
            radius: Maui.Style.radiusV
        }
    }


}
