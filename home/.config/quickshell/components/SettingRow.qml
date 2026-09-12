// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S E T T I N G   R O W                                                  │
// │   one preference · its name, what it says now, and its control           │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"

// One setting: its name, its current value underneath, and a control.
// Descriptions live on the group heading, not on each row.
//
// A `locked` row is dimmed and its control disabled, but it stays in place
// (and searchable); `reason` replaces the value line to say why.
Rectangle {
    id: root

    property string label: ""

    // Current value. One clause, no full stop.
    property string reading: ""

    property bool locked: false

    // Why it is locked. One clause, usually "Set by …".
    property string reason: ""

    default property alias control: holder.data

    Layout.fillWidth: true
    implicitHeight: Math.max(42, body.implicitHeight + 16)
    radius: Theme.radiusMedium
    color: Theme.islandSurface
    border.color: Theme.islandBorder
    border.width: 1
    opacity: root.locked ? 0.55 : 1

    Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

    RowLayout {
        id: body

        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 14

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.label
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                color: Theme.text
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
        }

        Item {
            id: holder

            Layout.alignment: Qt.AlignVCenter
            enabled: !root.locked
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }
    }
}
