// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   S E S S I O N   P I C K E R                                            │
// │   session picker · unfolds upward                                        │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "."

// Session chooser in the bottom-right corner; the list unfolds upward.
Item {
    id: root

    property var sessions: null
    property int currentIndex: 0
    property bool expanded: false

    // Read through delegates by role name: SDDM's models have no get(), and
    // numeric role 260 means different things in its user and session models.
    Instantiator {
        id: rows

        model: root.sessions

        delegate: QtObject {
            required property string name
        }
    }

    readonly property int count: rows.count

    readonly property var current: rows.count > 0
        ? rows.objectAt(Math.max(0, Math.min(root.currentIndex, rows.count - 1)))
        : null

    readonly property string sessionName: root.current !== null ? root.current.name : ""

    implicitWidth: chip.width
    implicitHeight: Theme.capsuleHeight

    Capsule {
        id: chip

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: label.width + 42
        height: Theme.capsuleHeight
        hovered: mouse.containsMouse

        Row {
            id: label

            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰧨"
                font.family: Theme.fontMono
                font.pixelSize: 13
                color: Theme.text
                opacity: 0.75
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.sessionName
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                color: Theme.text
            }
        }

        MouseArea {
            id: mouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    Capsule {
        id: sheet

        anchors.bottom: chip.top
        anchors.bottomMargin: 10
        anchors.right: chip.right
        // Wide enough for names like "Hyprland (uwsm-managed)".
        width: Math.max(236, chip.width + 44)
        height: list.height + 16
        radius: Theme.radiusLarge
        visible: opacity > 0
        opacity: root.expanded ? 1 : 0
        scale: root.expanded ? 1 : 0.96
        transformOrigin: Item.Bottom

        Behavior on opacity {
            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easing }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easing }
        }

        Column {
            id: list

            anchors.centerIn: parent
            width: parent.width - 16

            Repeater {
                model: root.sessions

                Rectangle {
                    required property int index
                    required property string name

                    width: list.width
                    height: 38
                    radius: Theme.radiusSmall
                    color: row.containsMouse ? Theme.islandSurface : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        // Always reserve the tick's column.
                        anchors.right: parent.right
                        anchors.rightMargin: 34
                        anchors.verticalCenter: parent.verticalCenter
                        text: name
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeRegular
                        font.weight: index === root.currentIndex ? Font.DemiBold : Font.Normal
                        color: Theme.text
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        visible: index === root.currentIndex
                        text: "󰄬"
                        font.family: Theme.fontMono
                        font.pixelSize: 13
                        color: Theme.accent
                    }

                    MouseArea {
                        id: row

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.currentIndex = index
                            root.expanded = false
                        }
                    }
                }
            }
        }
    }
}
