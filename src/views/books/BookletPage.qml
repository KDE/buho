import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
id: control

signal exit()

headBar.leftContent: ToolButton
{
    icon.name: "go-previous"
    onClicked: control.exit()
}

Kirigami.OverlayDrawer
{
    edge: Qt.RightEdge
    width: Kirigami.Units.gridUnit * 16
    height: parent.height - headBar.height
    y: headBar.height
    modal: true
}

}
