import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import "../../widgets"

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

    signal linkSaved(var link)

    Maui.Page
    {
        anchors.fill: parent
        margins: 0
        padding: 0

        headBarExit: false
        headBar.leftContent: [
            Maui.ToolButton
            {
                id: pinButton
                iconName: "edit-pin"
                checkable: true
                iconColor: checked ? highlightColor : textColor
                //                onClicked: checked = !checked
            },

            Maui.ToolButton
            {
                iconName: "document-save"
            },

            Maui.ToolButton
            {
                iconName: "document-launch"
                onClicked: owl.openLink(webView.url)
            }
        ]

        headBar.rightContent: ColorsBar
        {
            id: colorBar
        }

        footBar.leftContent: [

            Maui.ToolButton
            {
                id: favButton
                iconName: "love"
                checkable: true
                iconColor: checked ? "#ff007f" : textColor
            },

            Maui.ToolButton
            {
                iconName: "document-share"
                onClicked: isAndroid ? Maui.Android.shareLink(webView.url) :
                                       shareDialog.show(webView.url)
            },

            Maui.ToolButton
            {
                iconName: "document-export"
            },

            Maui.ToolButton
            {
                iconName: "entry-delete"
            }
        ]


        footBar.rightContent: Row
        {
            spacing: space.medium

            Button
            {
                id: discard
                text: qsTr("Discard")
                onClicked: close()

            }

            Button
            {
                id: save
                text: qsTr("Save")
                onClicked:
                {
                    packLink()
                    close()
                }
            }

        }

        ColumnLayout
        {
            anchors.fill: parent

            //            Item
            //            {
            //                Layout.fillWidth: true
            //                height: rowHeightAlt

            //                Label
            //                {
            //                    clip: true
            //                    text: webView.title
            //                    width: parent.width
            //                    height: parent.height
            //                    horizontalAlignment: Qt.AlignHCenter
            //                    verticalAlignment: Qt.AlignVCenter
            //                    font.bold: true
            //                    font.pointSize: fontSizes.big
            //                    font.weight: Font.Bold
            //                    elide: Label.ElideRight
            //                }
            //            }

            Loader
            {
                id: webViewer
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 0
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
        pinButton.checked = link.pin == 1
        favButton.checked = link.fav == 1
        open()
    }

    function packLink()
    {
        linkSaved({
                      link: webView.url,
                      color: colorBar.currentColor,
                      tag: tagBar.getTags(),
                      pin: pinButton.checked,
                      fav: favButton.checked
                  })
    }
}
