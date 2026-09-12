// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   P O W E R   R O W                                                      │
// │   reboot and shut down buttons                                           │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "."

// Restart and shut down; no suspend, since there is no session yet.
//
// The first click arms a button and the second confirms, as in the shell;
// it disarms after 3 s. Buttons logind does not allow are hidden, so under
// --test-mode, where both report false, the row is empty.
Row {
    id: root

    property bool canReboot: false
    property bool canPowerOff: false

    property string armed: ""

    signal rebootRequested()
    signal powerOffRequested()

    spacing: 8

    readonly property Timer disarm: Timer {
        interval: 3000
        onTriggered: root.armed = ""
    }

    component Chip: Capsule {
        id: chip

        property string action: ""
        property string glyph: ""
        property string caption: ""

        readonly property bool isArmed: root.armed === chip.action

        signal confirmed()

        width: chip.isArmed ? name.implicitWidth + Theme.capsuleHeight + 16
                            : Theme.capsuleHeight
        height: Theme.capsuleHeight
        radius: Theme.radiusPill
        hovered: area.containsMouse

        color: {
            if (chip.isArmed)
                return Theme.indicatorBad
            return area.containsMouse ? Theme.islandSurfaceHover : Theme.island
        }
        border.color: chip.isArmed ? Theme.indicatorBad : Theme.islandBorder

        Behavior on width {
            NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easing }
        }
        Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

        Row {
            anchors.centerIn: parent
            spacing: 7

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: chip.glyph
                font.family: Theme.fontMono
                font.pixelSize: 15
                color: Theme.text
                opacity: chip.isArmed || area.containsMouse ? 1 : 0.75

                Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }
            }

            Text {
                id: name

                anchors.verticalCenter: parent.verticalCenter
                visible: chip.isArmed
                text: chip.caption
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                color: Theme.text
            }
        }

        MouseArea {
            id: area

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (chip.isArmed) {
                    root.armed = ""
                    root.disarm.stop()
                    chip.confirmed()
                    return
                }
                root.armed = chip.action
                root.disarm.restart()
            }
        }
    }

    Chip {
        action: "reboot"
        glyph: "󰜉"
        caption: qsTr("Restart")
        visible: root.canReboot
        onConfirmed: root.rebootRequested()
    }

    Chip {
        action: "shutdown"
        glyph: "󰐥"
        caption: qsTr("Shut down")
        visible: root.canPowerOff
        onConfirmed: root.powerOffRequested()
    }
}
