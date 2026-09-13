import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../services"
import "../../components"

// ChatGPT / Codex account quota · current session and week
// When authenticated, shows account rate limits from Codex app-server.
Item {
    id: root

    property bool compact: false

    function resetText(timestamp: real, windowAvailable: bool): string {
        const seconds = Number(timestamp)
        if (!CodexService.available || !windowAvailable
                || !Number.isFinite(seconds) || seconds <= 0)
            return "Reset unavailable"

        const date = new Date(seconds * 1000)
        return Number.isNaN(date.getTime())
            ? "Reset unavailable"
            : `Resets ${date.toLocaleString()}`
    }

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

                ChatGPTMark {
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

                    ChatGPTMark {
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
                                ? (CodexService.plan
                                    ? `Codex ${CodexService.plan}`
                                    : "Codex account quota")
                                : "Codex account authenticated")
                            : "Codex account not authenticated"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.textMuted
                    }
                }
            }

             // Keep both windows visible; an omitted secondary window is not 0%.
             RowLayout {
                 Layout.alignment: Qt.AlignHCenter
                 spacing: 12

                  ColumnLayout {
                      Layout.preferredWidth: 82
                      spacing: 4

                      QuotaRing {
                          Layout.alignment: Qt.AlignHCenter
                          Layout.preferredWidth: 58
                          Layout.preferredHeight: 58
                          usedPercent: CodexService.primaryUsedPercent
                          available: AuthService.chatgptAuthenticated && CodexService.available
                          label: CodexService.primaryWindowLabel || "5h"
                          trackColor: Theme.indicatorDim
                          fillColor: Theme.indicator
                      }

                      Text {
                          Layout.fillWidth: true
                          text: root.resetText(CodexService.primaryResetAt, true)
                          horizontalAlignment: Text.AlignHCenter
                          wrapMode: Text.Wrap
                          font.family: Theme.fontFamily
                          font.pixelSize: Theme.fontSizeLabel
                          color: Theme.textMuted
                      }
                  }

                  ColumnLayout {
                      Layout.preferredWidth: 82
                      spacing: 4

                      QuotaRing {
                          Layout.alignment: Qt.AlignHCenter
                          Layout.preferredWidth: 58
                          Layout.preferredHeight: 58
                          usedPercent: CodexService.secondaryUsedPercent
                          available: AuthService.chatgptAuthenticated && CodexService.available
                              && CodexService.secondaryAvailable
                          label: CodexService.secondaryWindowLabel || "week"
                          trackColor: Theme.indicatorDim
                          fillColor: Theme.indicator
                      }

                      Text {
                          Layout.fillWidth: true
                          text: root.resetText(CodexService.secondaryResetAt,
                                               CodexService.secondaryAvailable)
                          horizontalAlignment: Text.AlignHCenter
                          wrapMode: Text.Wrap
                          font.family: Theme.fontFamily
                          font.pixelSize: Theme.fontSizeLabel
                          color: Theme.textMuted
                      }
                  }
               }

              PillButton {
                 visible: AuthService.chatgptAuthenticated
                 enabled: !AuthService.loggingOut
                 text: "Log out of Codex"
                 Layout.alignment: Qt.AlignRight
                  onClicked: AuthService.logout("chatgpt")
              }

              Text {
                  visible: AuthService.logoutError !== ""
                  text: AuthService.logoutError
                  color: Theme.indicatorBad
                  font.family: Theme.fontFamily
                  font.pixelSize: Theme.fontSizeSmall
                  Layout.fillWidth: true
                  horizontalAlignment: Text.AlignRight
                  wrapMode: Text.Wrap
              }

             // Only show the login prompt while the Codex account is unauthenticated.
            LoginPrompt {
                visible: !AuthService.chatgptAuthenticated
                service: "chatgpt"
                label: "Log in to ChatGPT"
                Layout.alignment: Qt.AlignRight
            }
        }
    }
}
