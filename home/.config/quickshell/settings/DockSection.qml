// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   D O C K   S E C T I O N                                                │
// │   dock · position, pinned apps and behaviour                             │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Layouts

import "../theme"
import "../services"
import "../components"

// Edge, size, behaviour and kept applications. Icon order is changed by
// dragging on the dock itself.
SettingsSection {
    id: root

    // Unused: this page has no parts, but `SettingsPanel` sets it on all pages.
    property string tab: ""

    // Used for both the controls and their readings.
    readonly property var edges: [
        { id: "bottom", label: Tr.t("Bottom") },
        { id: "left", label: Tr.t("Left") },
        { id: "right", label: Tr.t("Right") }
    ]

    readonly property var alignments: [
        { id: "start", label: Tr.t("Start") },
        { id: "center", label: Tr.t("Middle") },
        { id: "end", label: Tr.t("End") }
    ]

    function labelOf(list: var, id: string): string {
        const found = list.find(entry => entry.id === id)
        return found ? found.label : ""
    }

    // Everything but the main switch is locked while the dock is off.
    readonly property bool off: !SettingsService.dockEnabled
    readonly property string offReason: Tr.t("The dock is off")

    GroupHeading {
        leading: true
        title: Tr.t("The dock")
        note: Tr.t("Your kept and open applications, on one edge of the screen.")
        hint: Tr.t("An empty dock is not drawn. Icons are reordered by dragging them on the dock itself, and the top edge is left to the bar.")
    }

    SettingRow {
        label: Tr.t("Show the dock")
        reading: SettingsService.dockEnabled ? Tr.t("Shown") : Tr.t("Hidden")

        ToggleSwitch {
            checked: SettingsService.dockEnabled
            onToggled: checked => SettingsService.set("dockEnabled", checked)
        }
    }

    // ── POSITION ────────────────────────────────────────────────────────────
    //
    // Each tile also draws the current alignment.
    SettingTiles {
        label: Tr.t("Edge")
        reading: root.labelOf(root.edges, SettingsService.dockEdge)
        locked: root.off
        reason: root.offReason

        Repeater {
            model: root.edges

            PreviewTile {
                id: tile

                required property var modelData

                caption: tile.modelData.label
                selected: SettingsService.dockEdge === tile.modelData.id
                onPicked: SettingsService.set("dockEdge", tile.modelData.id)

                // Schematic screen: the bar along the top, the dock on the
                // offered edge. Not to scale.
                Rectangle {
                    anchors.centerIn: parent
                    width: 96
                    height: 54
                    radius: Theme.radiusSmall
                    color: Theme.island
                    border.color: Theme.islandBorder
                    border.width: 1

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 4
                        width: 26
                        height: 4
                        radius: Theme.radiusPill
                        color: Theme.islandSurfaceHover
                    }

                    Rectangle {
                        readonly property bool upright: tile.modelData.id !== "bottom"
                        readonly property string alignment: SettingsService.dockAlignment

                        width: upright ? 6 : 40
                        height: upright ? 32 : 6
                        radius: Theme.radiusPill
                        color: Theme.accent

                        x: tile.modelData.id === "left" ? 4
                            : (tile.modelData.id === "right" ? parent.width - width - 4
                                : (alignment === "start" ? 4
                                    : (alignment === "end" ? parent.width - width - 4
                                        : (parent.width - width) / 2)))

                        y: !upright ? parent.height - height - 4
                            : (alignment === "start" ? 8
                                : (alignment === "end" ? parent.height - height - 4
                                    : (parent.height - height) / 2))
                    }
                }
            }
        }
    }

    SettingRow {
        label: Tr.t("Alignment")
        reading: root.labelOf(root.alignments, SettingsService.dockAlignment)
        locked: root.off
        reason: root.offReason

        SegmentedControl {
            options: root.alignments
            current: SettingsService.dockAlignment
            onSelected: id => SettingsService.set("dockAlignment", id)
        }
    }

    // ── SIZE ────────────────────────────────────────────────────────────────

    GroupHeading {
        title: Tr.t("Size")
        note: Tr.t("Everything on the dock scales with the icon size.")
        hint: Tr.t("Background sets how opaque the capsule behind the icons is; lower it to let the blurred wallpaper through.")
    }

    SettingSlider {
        Layout.fillWidth: true
        label: Tr.t("Icon size")
        value: SettingsService.dockIconSize
        from: 28
        to: 72
        stepSize: 2
        unit: " px"
        locked: root.off
        reason: root.offReason
        onMoved: value => SettingsService.set("dockIconSize", Math.round(value))
    }

    SettingSlider {
        Layout.fillWidth: true
        label: Tr.t("Background")
        value: SettingsService.dockOpacity
        from: 20
        to: 100
        stepSize: 5
        unit: "%"
        locked: root.off
        reason: root.offReason
        onMoved: value => SettingsService.set("dockOpacity", Math.round(value))
    }

    // ── BEHAVIOUR ───────────────────────────────────────────────────────────

    GroupHeading {
        title: Tr.t("How it behaves")
        note: Tr.t("What else the dock shows, and how windows treat it.")
        hint: Tr.t("The launcher button opens the island's launcher, and open applications appear after a divider while they run. Reserving keeps windows from tiling under the dock, and has no effect while it hides.")
    }

    SettingRow {
        label: Tr.t("Launcher button")
        reading: SettingsService.dockLauncher ? Tr.t("Shown") : Tr.t("Hidden")
        locked: root.off
        reason: root.offReason

        ToggleSwitch {
            checked: SettingsService.dockLauncher
            onToggled: checked => SettingsService.set("dockLauncher", checked)
        }
    }

    SettingRow {
        label: Tr.t("Open applications")
        reading: SettingsService.dockRunning ? Tr.t("Shown") : Tr.t("Hidden")
        locked: root.off
        reason: root.offReason

        ToggleSwitch {
            checked: SettingsService.dockRunning
            onToggled: checked => SettingsService.set("dockRunning", checked)
        }
    }

    // A hidden dock reserves nothing, so this is locked while autohide is on.
    SettingRow {
        label: Tr.t("Reserve its space")
        reading: SettingsService.dockReserve
            ? Tr.t("Windows tile around it")
            : Tr.t("Windows pass under it")
        locked: root.off || SettingsService.dockAutohide
        reason: root.off ? root.offReason
            : Tr.t("Nothing is reserved while it hides")

        ToggleSwitch {
            checked: SettingsService.dockReserve
            onToggled: checked => SettingsService.set("dockReserve", checked)
        }
    }

    SettingRow {
        label: Tr.t("Hide until pointed at")
        reading: SettingsService.dockAutohide
            ? Tr.t("Hidden until pointed at")
            : Tr.t("Always on screen")
        locked: root.off
        reason: root.offReason

        ToggleSwitch {
            checked: SettingsService.dockAutohide
            onToggled: checked => SettingsService.set("dockAutohide", checked)
        }
    }

    // ── KEPT APPLICATIONS ───────────────────────────────────────────────────
    //
    // Not locked while the dock is off: the launcher uses this list too.

    GroupHeading {
        title: Tr.t("What is kept on it")
        note: Tr.t("These stay whether they are running or not, and they lead the launcher's list too.")
        hint: Tr.t("Their order is set by dragging them on the dock, and right-clicking a dock icon also keeps or removes it. The launcher uses this list too, so it stays editable with the dock off.")
    }

    KeptApplications {
        Layout.fillWidth: true
    }
}
