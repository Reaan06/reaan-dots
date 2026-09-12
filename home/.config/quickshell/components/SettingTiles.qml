// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S E T T I N G   T I L E S                                              │
// │   settings choice as preview tiles                                       │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"

// A setting whose options are shapes: a row of `PreviewTile`s sharing the
// card width evenly.
Rectangle {
    id: root

    property string label: ""

    // Current value.
    property string reading: ""

    // Same meaning as in `SettingRow`.
    property bool locked: false
    property string reason: ""

    default property alias tiles: flow.data

    Layout.fillWidth: true
    implicitHeight: body.implicitHeight + 28
    radius: Theme.radiusMedium
    color: Theme.islandSurface
    border.color: Theme.islandBorder
    border.width: 1
    opacity: root.locked ? 0.55 : 1

    Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

    ColumnLayout {
        id: body

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: root.label
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                color: Theme.text
            }


            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: root.locked ? root.reason !== "" : root.reading !== ""
            spacing: 5

            Text {
                visible: root.locked
                text: "󰌾"
                font.family: Theme.fontMono
                font.pixelSize: 9
                color: Theme.textMuted
            }

            Text {
                Layout.fillWidth: true
                text: root.locked ? root.reason : root.reading
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLabel
                color: Theme.textMuted
            }
        }

        RowLayout {
            id: flow

            Layout.fillWidth: true
            Layout.topMargin: 10
            spacing: 10
            enabled: !root.locked
        }
    }
}
