// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   E D I T   T R A Y                                                      │
// │   edit tray · tiles and a done button                                    │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "../theme"

// The floating edit capsule shared by the desktop and the control centre: a
// strip of tiles, a hairline, and Done.
//
// Tiles come from the caller as a delegate given `modelData`, `tile` wide
// and `tile + 18` tall (name under the picture). The strip scrolls by wheel
// rather than being a Flickable, which would steal the sideways drag that
// pulls a tile out.
Item {
    id: root

    property var model: []
    property Component delegate: null

    readonly property int tile: 76
    readonly property int gap: 8
    readonly property int pad: 12

    // Maximum width.
    property real roomAcross: 0

    // Highlighted while a dragged item is over it: dropping removes it.
    property bool receiving: false

    signal done()

    implicitWidth: Math.min(
        root.roomAcross > 0 ? root.roomAcross : 100000,
        tiles.width + doneBox.width + 3 * root.pad + 1)
    implicitHeight: 2 * root.pad + root.tile + 18

    // Swallow presses on the capsule, so a click between tiles does not reach
    // the dismissing surface below.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.desktopRadius
        color: Theme.island
        border.color: root.receiving ? Theme.accent : Theme.islandBorder
        border.width: root.receiving ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }
    }

    // ── STRIP ───────────────────────────────────────────────────────────────

    Item {
        id: strip

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.pad
        anchors.topMargin: root.pad
        anchors.bottomMargin: root.pad
        width: root.width - doneBox.width - 3 * root.pad - 1
        clip: true

        readonly property real overflow: Math.max(0, tiles.width - strip.width)

        Row {
            id: tiles

            x: 0
            spacing: root.gap

            Behavior on x {
                NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easing }
            }

            Repeater {
                model: root.model
                delegate: root.delegate
            }
        }

        WheelHandler {
            enabled: strip.overflow > 0
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const delta = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
                tiles.x = Math.max(-strip.overflow, Math.min(0, tiles.x + delta))
            }
        }
    }

    Rectangle {
        anchors.left: strip.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: root.pad
        anchors.topMargin: root.pad
        anchors.bottomMargin: root.pad
        width: 1
        color: Theme.hairline
    }

    Item {
        id: doneBox

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.rightMargin: root.pad
        width: doneButton.implicitWidth

        PillButton {
            id: doneButton

            anchors.centerIn: parent
            text: Tr.t("Done")
            implicitHeight: 28
            onClicked: root.done()
        }
    }
}
