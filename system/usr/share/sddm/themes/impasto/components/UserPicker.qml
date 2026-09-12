// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   U S E R   P I C K E R                                                  │
// │   user picker · the avatar switches user                                 │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "."

// The avatar and name are the control: with more than one account, clicking
// them opens the list, which overlays the field rather than pushing it down.
// With a single account nothing is clickable.
Item {
    id: root

    property var users: null
    property int currentIndex: 0
    property bool expanded: false

    // userModel is a C++ model with no get() (bindings silently evaluate to
    // undefined). An Instantiator exposes one object per row, and objectAt()
    // keeps the bindings below in sync with the selection.
    Instantiator {
        id: rows

        model: root.users

        delegate: QtObject {
            required property string name
            required property string realName
            required property url icon
        }
    }

    readonly property bool many: rows.count > 1

    readonly property var current: rows.count > 0
        ? rows.objectAt(Math.max(0, Math.min(root.currentIndex, rows.count - 1)))
        : null

    readonly property string userName: root.current !== null ? root.current.name : ""
    readonly property string displayName: {
        if (root.current === null)
            return ""
        const real = root.current.realName
        return real !== undefined && real !== "" ? real : root.current.name
    }

    // First and last initials, as in the shell's AccountService.
    function initialsOf(label: string): string {
        const words = String(label).trim().split(/\s+/).filter(w => w.length > 0)
        if (words.length === 0)
            return "?"
        if (words.length === 1)
            return words[0].charAt(0).toUpperCase()
        return (words[0].charAt(0) + words[words.length - 1].charAt(0)).toUpperCase()
    }

    signal chosen()

    implicitWidth: 320
    implicitHeight: head.height

    Column {
        id: head

        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12

        Avatar {
            id: face

            anchors.horizontalCenter: parent.horizontalCenter
            width: 88
            height: 88
            source: root.current !== null ? String(root.current.icon) : ""
            initials: root.initialsOf(root.displayName)
            ring: mouse.containsMouse && root.many ? Theme.accent : Theme.islandBorder
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.displayName
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge
                font.weight: Font.DemiBold
                color: Theme.text
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.many
                text: "󰅀"
                font.family: Theme.fontMono
                font.pixelSize: 14
                color: Theme.text
                opacity: 0.7
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easing }
                }
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: head
        hoverEnabled: true
        enabled: root.many
        cursorShape: root.many ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.expanded = !root.expanded
    }

    // ── ACCOUNT LIST ────────────────────────────────────────────────────────

    Capsule {
        id: sheet

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: head.bottom
        anchors.topMargin: 18
        width: 320
        height: list.height + 16
        radius: Theme.radiusLarge
        visible: opacity > 0
        opacity: root.expanded ? 1 : 0
        scale: root.expanded ? 1 : 0.96

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
                model: root.users

                Rectangle {
                    required property int index
                    required property string name
                    required property string realName
                    required property url icon

                    width: list.width
                    height: 52
                    radius: Theme.radiusMedium
                    color: row.containsMouse ? Theme.islandSurface : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    Avatar {
                        id: mark

                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 32
                        height: 32
                        source: String(icon)
                        initials: root.initialsOf(realName !== "" ? realName : name)
                    }

                    // Anchored so the tick's column is always reserved.
                    Text {
                        anchors.left: mark.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.rightMargin: 38
                        anchors.verticalCenter: parent.verticalCenter
                        text: realName !== "" ? realName : name
                        elide: Text.ElideRight
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: index === root.currentIndex ? Font.DemiBold : Font.Normal
                        color: Theme.text
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        visible: index === root.currentIndex
                        text: "󰄬"
                        font.family: Theme.fontMono
                        font.pixelSize: 14
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
                            root.chosen()
                        }
                    }
                }
            }
        }
    }
}
