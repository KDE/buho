import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.0
import org.kde.mauikit 1.0 as Maui
import org.kde.kirigami 2.7 as Kirigami
import QtWebView 1.1

Maui.Dialog
{
    id: control
    parent: parent
    heightHint: 0.95
    widthHint: 0.95
    maxHeight: previewReady ? Maui.Style.unit * 800 : contentLayout.implicitHeight
    maxWidth: Maui.Style.unit *700

    signal linkSaved(var link)
    property string selectedColor : "#ffffe6"
    property string fgColor: Qt.darker(selectedColor, 2.5)

    property bool previewReady : false
    x: (parent.width / 2) - (width / 2)
    y: (parent.height /2 ) - (height / 2)
    modal: true
    padding: isAndroid ? 1 : undefined
    page.padding: 0

    Connections
    {
        target: linker
        onPreviewReady:
        {
            previewReady = true
            fill(link)
        }
    }
    headBar.visible: previewReady
    footBar.visible: previewReady

    headBar.leftContent: [
        ToolButton
        {
            id: pinButton
            icon.name: "window-pin"
            checkable: true
            icon.color: checked ? Kirigami.Theme.highlightColor : Kirigami.Theme.textColor
            //                onClicked: checked = !checked
        },

        TextField
        {
            id: title
            visible: previewReady
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.medium
            height: 24
            placeholderText: qsTr("Title")
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.large
            color: fgColor
            text: _webView.title

            background: Rectangle
            {
                color: "transparent"
            }
        }
    ]

    headBar.rightContent: ColorsBar
    {
        onColorPicked: selectedColor = color
    }

    footBar.leftContent: [

        ToolButton
        {
            id: favButton
            icon.name: "love"
            checkable: true
            icon.color: checked ? "#ff007f" : Kirigami.Theme.textColor
        },

        ToolButton
        {
            icon.name: "document-share"
            onClicked: isAndroid ? Maui.Android.shareText(link.text) :
                                   shareDialog.show(link.text)
        },

        ToolButton
        {
            icon.name: "document-export"
        }
    ]

    acceptText: qsTr("Save")
    rejectText:  qsTr("Discard")

    onAccepted: packLink()

    onRejected:  clear()

    ColumnLayout
    {
        id: contentLayout
        anchors.fill: parent

        TextField
        {
            id: link
            Layout.fillWidth: true
            Layout.margins: Maui.Style.space.medium
            height: Maui.Style.rowHeight
            verticalAlignment: Qt.AlignVCenter
            placeholderText: qsTr("URL")
            font.weight: Font.Bold
            font.bold: true
            font.pointSize: Maui.Style.fontSizes.large
            color: fgColor
            Layout.alignment: Qt.AlignCenter

            background: Rectangle
            {
                color: "transparent"
            }

            onAccepted:
            {
                _webView.url = link.text
                control.previewReady = true
            }
        }

        Item
        {
            id: _webViewItem
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: control.previewReady

            WebView
            {
                id: _webView
                anchors.fill: parent
            }
        }



        Maui.TagsBar
        {
            id: tagBar
            visible: control.previewReady
            Layout.fillWidth: visible
            allowEditMode: true
            list.abstract: true
            list.key: "links"
            onTagsEdited: list.updateToAbstract(tags)
            onTagRemovedClicked: list.removeFromAbstract(index)
        }
    }

    function clear()
    {
        title.clear()
        link.clear()
        tagBar.clear()
        _webView.stop()
        previewReady = false
        close()
    }

    function fill(link)
    {
        title.text = link.title
        populatePreviews(link.img)
        tagBar.list.lot= link.url

        open()
    }

    function populatePreviews(imgs)
    {
        for(var i in imgs)
        {
            console.log("PREVIEW:", imgs[i])
            previewList.model.append({url : imgs[i]})
        }
    }

    function packLink()
    {
        const imgUrl = "/home/camilo/.local/share/buho/links/" +Math.floor(Math.random() * 100) + ".jpeg";
        _webView.grabToImage(function (result)
        {
            console.log("save to", imgUrl)
            result.saveToFile(imgUrl)
            clear()
        }, Qt.size(_webView.width -48, _webView.height - 48));

        var data = ({
                        url : _webView.url,
                        title: title.text,
                        preview: imgUrl,
                        color: control.selectedColor ?  control.selectedColor : "",
                        tag: tagBar.list.tags.join(","),
                        pin: pinButton.checked ? 1 : 0,
                        favorite: favButton.checked ? 1 : 0
                    })
        linkSaved(data)
    }
}
