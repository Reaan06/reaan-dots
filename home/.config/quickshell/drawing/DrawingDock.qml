import QtQuick
import "../../theme"

Rectangle {
    id: root

    property color panelBg: Qt.rgba(0.08, 0.08, 0.10, 0.88)
    property color panelBorder: Qt.rgba(0.8, 0.8, 0.85, 0.14)
    property color accentColor: Theme.accent || "#0a84ff"
    property color textColor: Theme.text || "#ffffff"
    property color textMuted: Theme.textMuted || "#8e8e93"
    property string iconFamily: "Font Awesome 7 Free, Font Awesome 6 Free, Iosevka Nerd Font"

    property string currentTool: "pen"
    property color primaryColor: "#f4f1ed"
    property color secondaryColor: "#e68b83"
    property int activeColorSlot: 0
    property int strokesCount: 0
    property int redoCount: 0

    signal undoClicked()
    signal redoClicked()
    signal clearClicked()
    signal toolSelected(string toolId)
    signal colorSlotClicked(int slot)
    signal swapColorsClicked()

    height: 46
    width: toolRow.width + 24
    radius: 13
    color: root.panelBg
    border.color: root.panelBorder
    border.width: 1

    Row {
        id: toolRow
        anchors.centerIn: parent
        spacing: 8

        Rectangle {
            width: 32; height: 32; radius: 8
            color: undoHover.containsMouse && root.strokesCount ? "#2f2d3a" : "transparent"
            opacity: root.strokesCount ? 1.0 : 0.35
            Text {
                anchors.centerIn: parent
                text: "\uF0E2"
                color: root.textColor
                font.family: root.iconFamily
                font.pixelSize: 13
            }
            MouseArea {
                id: undoHover; anchors.fill: parent; hoverEnabled: true
                cursorShape: root.strokesCount ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.undoClicked()
            }
        }

        Rectangle {
            width: 32; height: 32; radius: 8
            color: redoHover.containsMouse && root.redoCount ? "#2f2d3a" : "transparent"
            opacity: root.redoCount ? 1.0 : 0.35
            Text {
                anchors.centerIn: parent
                text: "\uF01E"
                color: root.textColor
                font.family: root.iconFamily
                font.pixelSize: 13
            }
            MouseArea {
                id: redoHover; anchors.fill: parent; hoverEnabled: true
                cursorShape: root.redoCount ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: root.redoClicked()
            }
        }

        Rectangle {
            width: 1; height: 20; color: root.panelBorder
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            spacing: 4
            Repeater {
                model: [
                    { id: "pen", icon: "\uF040" },
                    { id: "brush", icon: "\uF1FC" },
                    { id: "marker", icon: "\uF576" },
                    { id: "eraser", icon: "\uF12D" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool active: root.currentTool === modelData.id
                    width: 34; height: 32; radius: 8
                    color: active ? Qt.rgba(0.25, 0.25, 0.35, 0.7) : (toolMouse.containsMouse ? "#262430" : "transparent")
                    border.width: active ? 1 : 0
                    border.color: root.accentColor
                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        color: active ? root.accentColor : root.textColor
                        font.family: root.iconFamily
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: toolMouse; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toolSelected(modelData.id)
                    }
                }
            }
        }

        Rectangle {
            width: 1; height: 20; color: root.panelBorder
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 24; height: 24; radius: 12
                color: root.primaryColor
                border.width: root.activeColorSlot === 0 ? 2 : 1
                border.color: root.activeColorSlot === 0 ? "#ffffff" : "#555260"
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.colorSlotClicked(0)
                }
            }

            Rectangle {
                width: 20; height: 20; radius: 5
                color: swapHover.containsMouse ? "#2f2d3a" : "transparent"
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    anchors.centerIn: parent
                    text: "\uF0EC"
                    color: root.textMuted
                    font.family: root.iconFamily
                    font.pixelSize: 10
                }
                MouseArea {
                    id: swapHover; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.swapColorsClicked()
                }
            }

            Rectangle {
                width: 24; height: 24; radius: 12
                color: root.secondaryColor
                border.width: root.activeColorSlot === 1 ? 2 : 1
                border.color: root.activeColorSlot === 1 ? "#ffffff" : "#555260"
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.colorSlotClicked(1)
                }
            }
        }

        Rectangle {
            width: 1; height: 20; color: root.panelBorder
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 32; height: 32; radius: 8
            color: clearHover.containsMouse ? "#3d2226" : "transparent"
            Text {
                anchors.centerIn: parent
                text: "\uF1F8"
                color: clearHover.containsMouse ? "#ff6b6b" : "#e06c75"
                font.family: root.iconFamily
                font.pixelSize: 13
            }
            MouseArea {
                id: clearHover; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clearClicked()
            }
        }
    }
}
