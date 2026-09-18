/*
 * Copyright 2026 Carl Schwan <carl@carlschwan.eu>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts

/*!
    \qmltype FormDelegateLayout
    \internal Layout shared by form delegates with leading and trailing items.
*/
RowLayout {
    id: root

    property Item leading: null
    property Item trailing: null
    property real leadingPadding: 0
    property real trailingPadding: 0

    // LayoutItemProxy controls its target's visibility. Keep a stable visual
    // parent so hiding content can collapse its slot without a visibility loop.
    component SideItem: Item {
        id: container

        property Item contentItem: null
        readonly property bool contentVisible: contentItem !== null && contentItem.visible

        visible: contentItem !== null
        implicitWidth: contentVisible ? contentItem.implicitWidth : 0
        implicitHeight: contentVisible ? contentItem.implicitHeight : 0

        Layout.minimumWidth: contentVisible ? contentItem.Layout.minimumWidth : 0
        Layout.minimumHeight: contentVisible ? contentItem.Layout.minimumHeight : 0
        Layout.preferredWidth: contentVisible ? contentItem.Layout.preferredWidth : 0
        Layout.preferredHeight: contentVisible ? contentItem.Layout.preferredHeight : 0
        Layout.maximumWidth: contentVisible ? contentItem.Layout.maximumWidth : 0
        Layout.maximumHeight: contentVisible ? contentItem.Layout.maximumHeight : 0
        Layout.fillWidth: contentVisible && contentItem.Layout.fillWidth
        Layout.fillHeight: contentVisible && contentItem.Layout.fillHeight
        Layout.alignment: contentVisible ? contentItem.Layout.alignment : 0
        Layout.horizontalStretchFactor: contentVisible ? contentItem.Layout.horizontalStretchFactor : -1
        Layout.verticalStretchFactor: contentVisible ? contentItem.Layout.verticalStretchFactor : -1
        Layout.leftMargin: contentVisible ? contentItem.Layout.leftMargin : 0
        Layout.rightMargin: contentVisible ? contentItem.Layout.rightMargin : 0
        Layout.topMargin: contentVisible ? contentItem.Layout.topMargin : 0
        Layout.bottomMargin: contentVisible ? contentItem.Layout.bottomMargin : 0

        onContentItemChanged: {
            for (const child of container.children) {
                if (child !== contentItem) {
                    child.anchors.fill = null;
                    child.parent = null;
                }
            }
            if (contentItem) {
                contentItem.parent = container;
                contentItem.anchors.fill = container;
            }
        }
    }

    default property alias content: contentLayout.data

    spacing: 0

    Layout.fillWidth: true

    SideItem {
        contentItem: root.leading
        Layout.rightMargin: contentVisible ? root.leadingPadding : 0
    }

    RowLayout {
        id: contentLayout

        Layout.fillWidth: true
        spacing: 0
    }

    SideItem {
        contentItem: root.trailing
        Layout.leftMargin: contentVisible ? root.trailingPadding : 0
    }
}
