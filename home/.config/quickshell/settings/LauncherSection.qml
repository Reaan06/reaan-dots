// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   L A U N C H E R   S E C T I O N                                        │
// │   launcher · results, prefixes and clipboard                             │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"
import "../services"
import "../components"

// Launcher modes are chosen by the first character typed; the sigils are
// listed and changed here.
SettingsSection {
    id: root

    // The visible part; set by `SettingsPanel`.
    property string tab: ""

    // Asks `SettingsPanel` to open another section.
    signal navigate(string section, string tab)

    // ── RESULTS ─────────────────────────────────────────────────────────────

    ColumnLayout {
        Layout.fillWidth: true
        spacing: root.spacing
        visible: root.tab === "results"

        GroupHeading {
            leading: true
            title: Tr.t("The list")
            note: Tr.t("What the launcher lists with nothing typed, and how tall it gets.")
            hint: Tr.t("By use ranks applications by launches, with older launches counting for less; those kept on the dock come first until something else is used more. As tall as the answer sizes the island to the results, up to the limit above; off, the box is fixed and the list scrolls.")
        }

        SettingRow {
            label: Tr.t("Order")

            SegmentedControl {
                options: [
                    { id: "recent", label: Tr.t("By use") },
                    { id: "alphabetical", label: Tr.t("Alphabetical") }
                ]
                current: SettingsService.launcherOrder
                onSelected: id => SettingsService.set("launcherOrder", id)
            }
        }

        SettingSlider {
            label: Tr.t("Results shown")
            value: SettingsService.launcherResults
            from: 4
            to: 14
            reading: `${SettingsService.launcherResults} ${Tr.t("rows")}`
            onMoved: value => SettingsService.set("launcherResults", Math.round(value))
        }

        SettingRow {
            label: Tr.t("As tall as the answer")
            reading: SettingsService.launcherFits
                ? Tr.t("Only as tall as it needs") : Tr.t("A fixed box")

            ToggleSwitch {
                checked: SettingsService.launcherFits
                onToggled: checked => SettingsService.set("launcherFits", checked)
            }
        }

        // Skeleton preview of the list at the chosen length.
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: mini.implicitHeight + 28
            radius: Theme.radiusMedium
            color: Theme.islandSurface
            border.color: Theme.islandBorder
            border.width: 1

            Behavior on implicitHeight {
                NumberAnimation { duration: Theme.durationFast; easing.type: Theme.easing }
            }

            Rectangle {
                id: mini

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 14
                width: 250
                implicitHeight: rows.implicitHeight + 20
                height: implicitHeight
                radius: Theme.radiusMedium
                color: Theme.island
                border.color: Theme.islandBorder
                border.width: 1

                ColumnLayout {
                    id: rows

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 10
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.bottomMargin: 3
                        spacing: 8

                        Text {
                            text: "󰍉"
                            font.family: Theme.fontMono
                            font.pixelSize: 10
                            color: Theme.textMuted
                        }

                        Rectangle {
                            width: 52
                            height: 4
                            radius: 2
                            color: Theme.textMuted
                            opacity: 0.5
                        }

                        Item { Layout.fillWidth: true }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Theme.hairline
                    }

                    Repeater {
                        model: SettingsService.launcherResults

                        Rectangle {
                            required property int index

                            Layout.fillWidth: true
                            implicitHeight: 18
                            radius: Theme.radiusSmall - 2
                            color: index === 0 ? Theme.islandSurfaceHover : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                spacing: 8

                                Rectangle {
                                    Layout.preferredWidth: 9
                                    Layout.preferredHeight: 9
                                    radius: 3
                                    color: Theme.islandSurfaceHover
                                    border.color: Theme.islandBorder
                                    border.width: 1
                                }

                                // Varied widths, so the skeleton reads as
                                // names rather than stripes.
                                Rectangle {
                                    Layout.preferredWidth: 48 + (index * 37) % 76
                                    Layout.preferredHeight: 4
                                    radius: 2
                                    color: Theme.textMuted
                                    opacity: index === 0 ? 0.8 : 0.4
                                }

                                Item { Layout.fillWidth: true }
                            }
                        }
                    }
                }
            }
        }

        // Kept applications are edited on the dock page.
        LinkRow {
            label: Tr.t("Applications you keep")
            reading: Tr.t("Kept on the dock, and they lead this list")
            onFollowed: root.navigate("dock", "")
        }
    }

    // ── SIGILS ──────────────────────────────────────────────────────────────

    ColumnLayout {
        Layout.fillWidth: true
        spacing: root.spacing
        visible: root.tab === "sigils"

        // Each sigil is edited in place. Letters, digits and spaces are
        // rejected (they start an application search), as is a sigil another
        // mode already uses.
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: modes.implicitHeight + 28
            radius: Theme.radiusMedium
            color: Theme.islandSurface
            border.color: Theme.islandBorder
            border.width: 1

            ColumnLayout {
                id: modes

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 2

                Text {
                    text: Tr.t("What the first character does")
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    color: Theme.text
                }

                Text {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8
                    text: Tr.t("Plain text searches applications, and a sigil in front switches mode. Click one to change it.")
                    wrapMode: Text.WordWrap
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeLabel
                    color: Theme.textMuted
                }

                Repeater {
                    model: LauncherService.modes

                    RowLayout {
                        id: mode

                        required property var modelData
                        readonly property bool fixed: mode.modelData.id === "apps"

                        function accept(sigil: string): bool {
                            if (sigil.length !== 1 || /[A-Za-z0-9 ]/.test(sigil))
                                return false
                            const clash = LauncherService.modes.some(other =>
                                other.id !== mode.modelData.id && other.prefix === sigil)
                            return !clash
                        }

                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 22
                            radius: Theme.radiusSmall - 2
                            color: Theme.island
                            border.color: sigil.activeFocus ? Theme.accent : Theme.islandBorder
                            border.width: 1

                            Behavior on border.color { ColorAnimation { duration: Theme.durationFast } }

                            Text {
                                anchors.centerIn: parent
                                visible: mode.fixed
                                text: "abc"
                                font.family: Theme.fontMono
                                font.pixelSize: 8
                                font.weight: Font.DemiBold
                                color: Theme.accent
                            }

                            TextInput {
                                id: sigil

                                anchors.fill: parent
                                visible: !mode.fixed
                                horizontalAlignment: TextInput.AlignHCenter
                                verticalAlignment: TextInput.AlignVCenter
                                maximumLength: 1
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.DemiBold
                                color: Theme.accent
                                selectByMouse: true

                                text: mode.modelData.prefix
                                onTextEdited: {
                                    if (mode.accept(sigil.text))
                                        SettingsService.setLauncherPrefix(
                                            mode.modelData.id, sigil.text)
                                }
                                // Revert to the stored value, so a rejected
                                // character does not look accepted.
                                onEditingFinished:
                                    sigil.text = Qt.binding(() => mode.modelData.prefix)
                            }
                        }

                        Text {
                            Layout.preferredWidth: 78
                            text: Tr.t(mode.modelData.label)
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.DemiBold
                            color: Theme.text
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Tr.t(mode.modelData.hint)
                            elide: Text.ElideRight
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeLabel
                            color: Theme.textMuted
                        }
                    }
                }
            }
        }
    }

    // ── CLIPBOARD ───────────────────────────────────────────────────────────
    //
    // The clipboard history is a launcher mode, so its settings live here.

    ColumnLayout {
        Layout.fillWidth: true
        spacing: root.spacing
        visible: root.tab === "clipboard"

        GroupHeading {
            leading: true
            title: Tr.t("Clipboard history")
            note: Tr.t("Everything copied, searchable from the launcher.")
            hint: Tr.t("Copies from password managers are never stored, and turning the history off stops the watcher entirely. Emptying on lock is off by default, since the lock already protects the session.")
        }

        SettingRow {
            label: Tr.t("Keep a history")
            reading: SettingsService.clipboardHistory
                ? Tr.t("Watching") : Tr.t("Nothing kept")

            ToggleSwitch {
                checked: SettingsService.clipboardHistory
                onToggled: checked => SettingsService.set("clipboardHistory", checked)
            }
        }

        // Locked rather than hidden while the history is off.
        SettingSlider {
            label: Tr.t("Entries kept")
            value: SettingsService.clipboardKeep
            from: 20
            to: 500
            locked: !SettingsService.clipboardHistory
            reason: Tr.t("No history is being kept")
            onMoved: value => SettingsService.set("clipboardKeep", Math.round(value))
        }

        SettingRow {
            label: Tr.t("Keep images")
            reading: SettingsService.clipboardImages
                ? Tr.t("Pictures as well as text") : Tr.t("Text only")
            locked: !SettingsService.clipboardHistory
            reason: Tr.t("No history is being kept")

            ToggleSwitch {
                checked: SettingsService.clipboardImages
                onToggled: checked => SettingsService.set("clipboardImages", checked)
            }
        }

        SettingRow {
            label: Tr.t("Empty it on lock")
            reading: SettingsService.clipboardWipeOnLock
                ? Tr.t("Thrown away on lock") : Tr.t("Kept across a lock")
            locked: !SettingsService.clipboardHistory
            reason: Tr.t("No history is being kept")

            ToggleSwitch {
                checked: SettingsService.clipboardWipeOnLock
                onToggled: checked => SettingsService.set("clipboardWipeOnLock", checked)
            }
        }
    }
}
