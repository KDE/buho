import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import org.kde.kirigami 2.0 as Kirigami
import org.kde.maui 1.0 as Maui

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    header: Maui.ToolBar
    {

    }

}
