import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
Popup
{
    parent: ApplicationWindow.overlay
    height: parent.height * (isMobile ?  0.8 : 0.7)
    width: parent.width * (isMobile ?  0.9 : 0.7)

    x: (parent.width / 2) - (width / 2)
    y: (parent.height /2 ) - (height / 2)

    ColumnLayout
    {
        anchors.fill: parent

        TextField
        {
            id: title
            Layout.fillWidth: true
            height: 24
            placeholderText: qsTr("Title")
        }

        TextArea
        {
            id: body
            height: 200
            Layout.fillHeight: true
            Layout.fillWidth: true
            placeholderText: qsTr("Body")
        }

        Row
        {
            Layout.fillWidth: true
            spacing: space.medium
            Button
            {
                id: save
                text: qsTr("Save")
                onClicked: owl.insertNote(title.text, body.text)
            }

            Button
            {
                id: discard
                text: qsTr("Discard")
                onClicked:
                {
                    clearNote()
                    close()
                }
            }
        }
    }
     onOpened: clearNote()


     function clearNote()
     {
         title.clear()
         body.clear()
     }
}
