// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S E G M E N T E D   C O N T R O L                                      │
// │   pick one of a few, with all of them visible                            │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"

// For two or three options, all visible at once.
Rectangle {
    id: root

    // Entries of { id, label }.
    property var options: []
    property string current: ""

    signal selected(string id)

    implicitWidth: layout.implicitWidth + 6
    implicitHeight: 28
    radius: Theme.radiusSmall
    opacity: root.enabled ? 1 : 0.45

    Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
    color: Theme.islandSurfaceHover
    border.color: Theme.islandBorder
    border.width: 1

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            model: root.options

            Rectangle {
                id: segment

                required property var modelData
                readonly property bool active: segment.modelData.id === root.current

                Layout.preferredWidth: Math.max(64, label.implicitWidth + 20)
                Layout.preferredHeight: 22
                radius: Theme.radiusSmall - 2
                color: segment.active ? Theme.accent
                    : (segmentMouse.containsMouse ? Theme.islandBorder : "transparent")

                Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: segment.modelData.label
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: segment.active ? Font.DemiBold : Font.Normal
                    color: segment.active ? Theme.accentText : Theme.textMuted
                }

                MouseArea {
                    id: segmentMouse
                    anchors.fill: parent
                    enabled: root.enabled
                    hoverEnabled: true
                    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: root.selected(segment.modelData.id)
                }
            }
        }
    }
}
