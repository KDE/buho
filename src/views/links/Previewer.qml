import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.maui 1.0 as Maui


Popup
{
    parent: ApplicationWindow.overlay
    height: parent.height *  0.9
    width: parent.width * (isMobile ?  0.9 : 0.7)
    x: (parent.width / 2) - (width / 2)
    y: (parent.height /2 ) - (height / 2)
    modal: true
    clip: true
    padding: isAndroid ? 2 : "undefined"
    property alias webView: webViewer.item

    Maui.Page
    {
        anchors.fill: parent
        margins: 0
        padding: 0

        onExit: close()

        headBar.rightContent: [
            Maui.ToolButton
            {
                iconName: "entry-delete"
            },

            Maui.ToolButton
            {
                iconName: "document-save"
            },

            Maui.ToolButton
            {
                iconName: "view-fullscreen"
                onClicked: owl.openLink(webView.url)
            }
        ]
        headBar.middleContent: Label
        {
            clip: true
            text: webView.title
            width: headBar.width * 0.5
            horizontalAlignment: Qt.AlignHCenter
            font.bold: true
            font.pointSize: fontSizes.big
            font.weight: Font.Bold
            elide: Label.ElideRight
        }

        ColumnLayout
        {
            anchors.fill: parent


            Loader
            {
                id: webViewer
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: isAndroid ? "qrc:/src/views/links/WebViewAndroid.qml" :
                                    "qrc:/src/views/links/WebViewLinux.qml"

                onVisibleChanged:
                {
                    if(!visible) webView.url = "about:blank"
                }
            }

            Maui.TagsBar
            {
                id: tagBar
                Layout.fillWidth: true
                allowEditMode: true

                onTagsEdited:
                {
                    for(var i in tags)
                        append({tag : tags[i]})
                }
            }
        }
    }

    function show(link)
    {
        webView.url = link.link
        tagBar.populate(link.tags)
        open()
    }
}
