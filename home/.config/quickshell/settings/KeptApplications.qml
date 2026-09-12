// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   K E P T   A P P L I C A T I O N S                                      │
// │   pinned applications list · shared by dock and launcher                 │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts
import Quickshell

import "../theme"
import "../services"
import "../components"

// The kept (pinned) applications and a picker to add one. Stored as the
// dock's pinned list, but the launcher also ranks them first, so the rows stay
// editable while the dock is off.
ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 10

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 52
        visible: DockService.pinnedCount === 0
        radius: Theme.radiusMedium
        color: Theme.islandSurface
        border.color: Theme.islandBorder
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: Tr.t("Nothing kept yet.")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textMuted
        }
    }

    Repeater {
        model: DockService.pinned

        Rectangle {
            id: kept

            required property string modelData
            required property int index

            readonly property var entry: DockService.entryOf(kept.modelData)
            readonly property string picture: kept.entry && kept.entry.icon
                ? Quickshell.iconPath(kept.entry.icon, true) : ""

            Layout.fillWidth: true
            implicitHeight: 52
            radius: Theme.radiusMedium
            color: Theme.islandSurface
            border.color: Theme.islandBorder
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: 12

                Text {
                    Layout.preferredWidth: 18
                    text: `${kept.index + 1}`
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeLabel
                    color: Theme.textMuted
                }

                Image {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    source: kept.picture
                    sourceSize: Qt.size(48, 48)
                    fillMode: Image.PreserveAspectFit
                    visible: kept.picture !== "" && status === Image.Ready
                }

                Text {
                    visible: kept.picture === ""
                    text: "󰀻"
                    font.family: Theme.fontMono
                    font.pixelSize: 18
                    color: Theme.textMuted
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: kept.entry ? kept.entry.name
                            : kept.modelData.replace(/\.desktop$/, "")
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    // An uninstalled entry keeps its place and says so.
                    Text {
                        Layout.fillWidth: true
                        text: kept.entry ? kept.modelData
                            : Tr.t("This application is no longer installed")
                        elide: Text.ElideRight
                        font.family: kept.entry ? Theme.fontMono : Theme.fontFamily
                        font.pixelSize: Theme.fontSizeLabel
                        color: kept.entry ? Theme.textMuted : Theme.yellow
                    }
                }

                IconButton {
                    Layout.alignment: Qt.AlignVCenter
                    icon: "󰅖"
                    iconSize: 12
                    onClicked: DockService.unpin(kept.modelData)
                }
            }
        }
    }

    // ── ADD ─────────────────────────────────────────────────────────────────
    //
    // Every application the launcher indexes, minus those already kept.
    Rectangle {
        id: picker

        Layout.fillWidth: true
        implicitHeight: 260
        radius: Theme.radiusMedium
        color: Theme.islandSurface
        border.color: Theme.islandBorder
        border.width: 1
        clip: true

        readonly property string term: search.text.trim().toLowerCase()

        readonly property var offered: {
            const list = []
            for (const app of LauncherService.applications) {
                if (DockService.isPinned(app.id))
                    continue
                if (picker.term !== "" && !app.name.toLowerCase().includes(picker.term)
                        && !app.keywords.includes(picker.term))
                    continue
                list.push(app)
            }
            return list
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                text: Tr.t("Add an application")
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                color: Theme.text
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                radius: Theme.radiusSmall
                color: Theme.island
                border.color: search.activeFocus ? Theme.accent : Theme.islandBorder
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 9
                    anchors.rightMargin: 9
                    spacing: 8

                    Text {
                        text: "󰍉"
                        font.family: Theme.fontMono
                        font.pixelSize: 12
                        color: Theme.textMuted
                    }

                    TextInput {
                        id: search

                        Layout.fillWidth: true
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.text
                        selectByMouse: true
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.accentText
                        clip: true

                        Keys.onEscapePressed: event => {
                            if (search.text === "") {
                                event.accepted = false
                                return
                            }
                            search.text = ""
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: search.text === ""
                            text: Tr.t("Search applications")
                            font: search.font
                            color: Theme.textMuted
                        }
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: picker.offered
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: option

                    required property var modelData

                    readonly property string picture: option.modelData.icon
                        ? Quickshell.iconPath(option.modelData.icon, true) : ""

                    width: ListView.view.width
                    height: 34
                    radius: Theme.radiusSmall
                    color: optionMouse.containsMouse ? Theme.islandBorder : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.durationFast } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 10
                        spacing: 10

                        Image {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            source: option.picture
                            sourceSize: Qt.size(40, 40)
                            fillMode: Image.PreserveAspectFit
                            visible: option.picture !== "" && status === Image.Ready
                        }

                        Text {
                            visible: option.picture === ""
                            Layout.preferredWidth: 20
                            horizontalAlignment: Text.AlignHCenter
                            text: "󰀻"
                            font.family: Theme.fontMono
                            font.pixelSize: 14
                            color: Theme.textMuted
                        }

                        Text {
                            Layout.fillWidth: true
                            text: option.modelData.name
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.text
                        }

                        Text {
                            visible: optionMouse.containsMouse
                            text: "󰐕"
                            font.family: Theme.fontMono
                            font.pixelSize: 12
                            color: Theme.accent
                        }
                    }

                    MouseArea {
                        id: optionMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: DockService.pin(option.modelData.id)
                    }
                }
            }
        }
    }
}
