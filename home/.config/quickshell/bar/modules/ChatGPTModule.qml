import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../services"
import "../../components"

// ChatGPT / Codex usage · current session and week
// When authenticated, shows token consumption from the local
// Codex state database. When not, shows a login prompt.
Item {
    id: root

    property bool compact: false

    implicitWidth: holder.implicitWidth
    implicitHeight: holder.implicitHeight

    Component.onCompleted: CodexService.subscribe()
    Component.onDestruction: CodexService.release()

    Loader {
        id: holder
        anchors.fill: parent
        sourceComponent: root.compact ? chip : detail
    }

    // Ring face with usage gauge.
    Component {
        id: chip

        Item {
            RingIndicator {
                id: mark

                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.capsuleHeight
                height: Theme.capsuleHeight
                thickness: 2.5
                progress: CodexService.available ? CodexService.gauge : 0
                trackColor: Theme.indicatorDim
                fillColor: CodexService.available ? Theme.indicator : Theme.indicatorDim

                Behavior on fillColor { ColorAnimation { duration: Theme.durationMedium } }

                CodexMark {
                    anchors.centerIn: parent
                    width: Math.round(Theme.capsuleHeight * 0.53)
                    height: Math.round(Theme.capsuleHeight * 0.53)
                    color: Theme.indicator
                }
            }
        }
    }

    Component {
        id: detail

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 13

                RingIndicator {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    thickness: 3
                    progress: CodexService.available ? CodexService.gauge : 0
                    trackColor: Theme.indicatorDim
                    fillColor: CodexService.available ? Theme.indicator : Theme.indicatorDim

                    Behavior on fillColor { ColorAnimation { duration: Theme.durationMedium } }

                    CodexMark {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        color: Theme.indicator
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: "ChatGPT"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeMedium
                        font.weight: Font.DemiBold
                        color: Theme.text
                    }

                    Text {
                        Layout.fillWidth: true
                        text: AuthService.chatgptAuthenticated
                            ? (CodexService.available
                                ? `Session ${CodexService.resetsIn}`
                                : "Codex account authenticated")
                            : "Codex account not authenticated"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textMuted
                    }
                }
            }

            // Authenticated: show usage breakdown
            Repeater {
                model: AuthService.chatgptAuthenticated && CodexService.available ? [
                    {
                        label: "SESSION",
                        tokens: CodexService.blockTokens,
                        count: CodexService.blockMessages
                    },
                    {
                        label: "WEEK",
                        tokens: CodexService.weekTokens,
                        count: CodexService.weekMessages
                    }
                ] : []

                ColumnLayout {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: 5

                    Figure {
                        Layout.fillWidth: true
                        label: column.modelData.label
                        value: `${CodexService.compact(column.modelData.tokens)} tokens`
                        note: CodexService.messages(column.modelData.count)
                    }
                }
            }

            // Not authenticated: show login prompt
            LoginPrompt {
                visible: !AuthService.chatgptAuthenticated
                service: "chatgpt"
                label: "Log in to ChatGPT"
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
