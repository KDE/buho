/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.5
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import "private"
import org.kde.kirigami 2.2


/**
 * An item that can be used as a title for the application.
 * Scrolling the main page will make it taller or shorter (trough the point of going away)
 * It's a behavior similar to the typical mobile web browser adressbar
 * the minimum, preferred and maximum heights of the item can be controlled with
 * * minimumHeight: default is 0, i.e. hidden
 * * preferredHeight: default is Units.gridUnit * 1.6
 * * maximumHeight: default is Units.gridUnit * 3
 *
 * To achieve a titlebar that stays completely fixed just set the 3 sizes as the same
 */
AbstractApplicationHeader {
    id: header

    /**
     * headerStyle: int
     * The way the separator between pages should be drawn in the header.
     * Allowed values are:
     * * Breadcrumb: the pages are hyerarchical and the separator will look like a >
     * * TabBar: the pages are intended to behave like tabbar pages
     *    and the separator will look limke a dot.
     *
     * When the heaer is in wide screen mode, no separator will be drawn.
     */
    property int headerStyle: ApplicationHeaderStyle.Auto

    /**
     * backButtonEnabled: bool
     * if true, there will be a back button present that will make the pagerow scroll back when clicked
     */
    property bool backButtonEnabled: (!titleList.isTabBar && (!Settings.isMobile || Qt.platform.os == "ios"))

    onBackButtonEnabledChanged: {
        if (backButtonEnabled && !titleList.backButton) {
            var component = Qt.createComponent(Qt.resolvedUrl("private/BackButton.qml"));
            titleList.backButton = component.createObject(navButtons);
            component = Qt.createComponent(Qt.resolvedUrl("private/ForwardButton.qml"));
            titleList.forwardButton = component.createObject(navButtons, {"headerFlickable": titleList});
        } else if (titleList.backButton) {
            titleList.backButton.destroy();
            titleList.forwardButton.destroy();
        }
    }
    property Component pageDelegate: Component {
        Row {
            height: parent.height

            spacing: Units.smallSpacing

            x: Units.smallSpacing

            Icon {
                //in tabbar mode this is just a spacer
                visible: !titleList.wideMode && ((typeof(modelData) != "undefined" && modelData > 0) || titleList.internalHeaderStyle == ApplicationHeaderStyle.TabBar)
                anchors.verticalCenter: parent.verticalCenter
                height: Units.iconSizes.small
                width: height
                selected: header.background && header.background.color && header.background.color == Theme.highlightColor
                source: titleList.isTabBar ? "" : (LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic")
            }

            Heading {
                id: title
                width: Math.min(parent.width, Math.min(titleList.width, implicitWidth)) + Units.smallSpacing
                anchors.verticalCenter: parent.verticalCenter
                opacity: current ? 1 : 0.4
                //Scaling animate NativeRendering is too slow
                renderType: Text.QtRendering
                color: header.background && header.background.color && header.background.color == Theme.highlightColor ? Theme.highlightedTextColor : Theme.textColor
                elide: Text.ElideRight
                text: page ? page.title : ""
                font.pointSize: Math.max(1, titleList.height / (1.6 * Units.devicePixelRatio))
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                    height: Units.smallSpacing
                    color: title.color
                    opacity: 0.6
                    visible: titleList.isTabBar && current
                }
            }
        }
    }

    Rectangle {
        anchors {
            right: titleList.left
            verticalCenter: parent.verticalCenter
        }
        visible: titleList.x > 0 && !titleList.atXBeginning
        height: parent.height * 0.7
        color: Theme.highlightedTextColor
        width: Math.ceil(Units.smallSpacing / 6)
        opacity: 0.4
    }

    QQC2.StackView {
        id: stack
        anchors {
            fill: parent
            leftMargin: (titleList.scrollingLocked && titleList.wideMode) || headerStyle == ApplicationHeaderStyle.Titles && depth < 2 ? 0 : navButtons.width
        }
        initialItem: titleList

        popEnter: Transition {
            YAnimator {
                from: -height
                to: 0
                duration: Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
        popExit: Transition {
            YAnimator {
                from: 0
                to: height
                duration: Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        pushEnter: Transition {
            YAnimator {
                from: height
                to: 0
                duration: Units.longDuration
                easing.type: Easing.OutCubic 
            }
        }

        pushExit: Transition {
            YAnimator {
                from: 0
                to: -height
                duration: Units.longDuration
                easing.type: Easing.OutCubic 
            }
        }

        replaceEnter: Transition {
            YAnimator {
                from: height
                to: 0
                duration: Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        replaceExit: Transition {
            YAnimator {
                from: 0
                to: -height
                duration: Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
    }
    Repeater {
        model: __appWindow.pageStack.layers.depth -1
        delegate: Loader {
            sourceComponent: header.pageDelegate
            readonly property Page page: __appWindow.pageStack.layers.get(modelData+1)
            readonly property bool current: true;
            Component.onCompleted: stack.push(this)
            Component.onDestruction: stack.pop()
        }
    }

    RowLayout {
        id: navButtons
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
    }

    ListView {
        id: titleList
        readonly property bool wideMode: typeof __appWindow.pageStack.wideMode !== "undefined" ?  __appWindow.pageStack.wideMode : __appWindow.wideMode
        property int internalHeaderStyle: header.headerStyle == ApplicationHeaderStyle.Auto ? (titleList.wideMode ? ApplicationHeaderStyle.Titles : ApplicationHeaderStyle.Breadcrumb) : header.headerStyle
        //if scrolling the titlebar should scroll also the pages and vice versa
        property bool scrollingLocked: (header.headerStyle == ApplicationHeaderStyle.Titles || titleList.wideMode)
        //uses this to have less strings comparisons
        property bool scrollMutex
        property bool isTabBar: header.headerStyle == ApplicationHeaderStyle.TabBar

        property Item backButton
        property Item forwardButton
        clip: true

        cacheBuffer: width ? Math.max(0, width * count) : 0
        displayMarginBeginning: __appWindow.pageStack.width * count
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        model: __appWindow.pageStack.depth
        spacing: 0
        currentIndex: __appWindow.pageStack && __appWindow.pageStack.currentIndex !== undefined ? __appWindow.pageStack.currentIndex : 0

        function gotoIndex(idx) {
            //don't actually scroll in widescreen mode
            if (titleList.wideMode) {
                return;
            }
            listScrollAnim.running = false
            var pos = titleList.contentX;
            var destPos;
            titleList.positionViewAtIndex(idx, ListView.Center);
            destPos = titleList.contentX;
            listScrollAnim.from = pos;
            listScrollAnim.to = destPos;
            listScrollAnim.running = true;
        }

        NumberAnimation {
            id: listScrollAnim
            target: titleList
            property: "contentX"
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }
        Timer {
            id: contentXSyncTimer
            interval: 0
            onTriggered: {
                titleList.contentX = __appWindow.pageStack.contentItem.contentX - __appWindow.pageStack.contentItem.originX + titleList.originX;
            }
        }
        onCountChanged: contentXSyncTimer.restart();
        onCurrentIndexChanged: gotoIndex(currentIndex);
        onModelChanged: gotoIndex(currentIndex);
        onContentWidthChanged: gotoIndex(currentIndex);

        onContentXChanged: {
            if (moving && !titleList.scrollMutex && titleList.scrollingLocked && !__appWindow.pageStack.contentItem.moving) {
                titleList.scrollMutex = true;
                __appWindow.pageStack.contentItem.contentX = titleList.contentX - titleList.originX + __appWindow.pageStack.contentItem.originX;
                titleList.scrollMutex = false;
            }
        }
        onHeightChanged: {
            titleList.returnToBounds()
        }
        onMovementEnded: {
            if (titleList.scrollingLocked) {
                //this will trigger snap as well
                __appWindow.pageStack.contentItem.flick(0,0);
            }
        }
        onFlickEnded: movementEnded();

        NumberAnimation {
            id: scrollTopAnimation
            target: __appWindow.pageStack.currentItem && __appWindow.pageStack.currentItem.flickable ? __appWindow.pageStack.currentItem.flickable : null
            property: "contentY"
            to: 0
            duration: Units.longDuration
            easing.type: Easing.InOutQuad
        }

        delegate: MouseArea {
            id: delegate
            readonly property int currentIndex: index
            readonly property var currentModelData: modelData
            clip: true

            width: {
                //more columns shown?
                if (titleList.scrollingLocked && delegateLoader.page) {
                    return delegateLoader.page.width;
                } else {
                    return Math.min(titleList.width, delegateLoader.implicitWidth + Units.smallSpacing);
                }
            }
            height: titleList.height
            onClicked: {
                if (__appWindow.pageStack.currentIndex == modelData) {
                    //scroll up if current otherwise make current
                    if (!__appWindow.pageStack.currentItem.flickable) {
                        return;
                    }
                    if (__appWindow.pageStack.currentItem.flickable.contentY > -__appWindow.header.height) {
                        scrollTopAnimation.to = -__appWindow.pageStack.currentItem.flickable.topMargin;
                        scrollTopAnimation.running = true;
                    }

                } else {
                    __appWindow.pageStack.currentIndex = modelData;
                }
            }

            Loader {
                id: delegateLoader
                height: parent.height
                x: titleList.wideMode || headerStyle == ApplicationHeaderStyle.Titles ? (Math.min(delegate.width - implicitWidth, Math.max(0, titleList.contentX - delegate.x + navButtons.width + (navButtons.width > 0 ? Units.smallSpacing : 0)))) : 0
                width: parent.width - x

                Connections {
                    target: delegateLoader.page
                    Component.onDestruction: delegateLoader.sourceComponent = null
                }

                sourceComponent: header.pageDelegate

                readonly property Page page: __appWindow.pageStack.get(modelData)
                //NOTE: why not use ListViewCurrentIndex? because listview itself resets
                //currentIndex in some situations (since here we are using an int as a model,
                //even more often) so the property binding gets broken
                readonly property bool current: __appWindow.pageStack.currentIndex == index
                readonly property int index: parent.currentIndex
                readonly property var modelData: parent.currentModelData
            }
        }
        Connections {
            target: titleList.scrollingLocked ? __appWindow.pageStack.contentItem : null
            onContentXChanged: {
                if (!titleList.contentItem.moving && !titleList.scrollMutex) {
                    titleList.contentX = __appWindow.pageStack.contentItem.contentX - __appWindow.pageStack.contentItem.originX + titleList.originX;
                }
            }
        }
    }
}
