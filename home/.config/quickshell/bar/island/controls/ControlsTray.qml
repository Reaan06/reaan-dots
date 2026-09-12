// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   C O N T R O L S   T R A Y                                              │
// │   block tray · shown while arranging the control centre                  │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "../../../theme"
import "../../../services"
import "../../../components"

// The tray of blocks, hung under the island on the bar's surface while the
// grid is being arranged. It lives on the bar's surface so a tile can be
// dragged from here onto the grid within one window.
//
// Each tile is a live miniature of the block at its squarest size, scaled to
// fit. Tiles are sorted by shape, squares first, and bottom-aligned so a row
// of different shapes sits on one line. Each plate fits its tile.
EditTray {
    id: root

    // Parent for the drag ghost (the bar's overlay), so it can cross the
    // island.
    required property Item host

    // The block being dragged out of the tray, or empty.
    property string pulling: ""

    model: ControlsService.trayOrder
    roomAcross: root.host.width - 2 * Theme.desktopGutter
    receiving: ControlsService.dragging !== "" && ControlsService.landing === null
    onDone: ControlsService.edit(false)

    // Published as an item rather than a rectangle so the service maps points
    // into it on demand; the tray is created while the island may still be
    // animating, and a rectangle measured then would stay wrong.
    Binding {
        target: ControlsService
        property: "tray"
        value: root
    }

    Component.onDestruction: {
        ControlsService.tray = null
        ControlsService.landing = null
    }

    // ── TILE ────────────────────────────────────────────────────────────────

    delegate: Item {
        id: tile

        required property var modelData

        readonly property string blockId: tile.modelData.id
        // Shown at its squarest; added at its smallest.
        readonly property string size: ControlsService.squarest(tile.blockId)
        readonly property var box: ControlsService.pixels(tile.size)
        readonly property real factor:
            Math.min(root.tile / tile.box.width, root.tile / tile.box.height)
        readonly property bool pulled: root.pulling === tile.blockId

        width: root.tile
        height: root.tile + 18

        Item {
            width: root.tile
            height: root.tile

            // Scaled about the bottom edge so every miniature sits on the same
            // line.
            Item {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: tile.box.width
                height: tile.box.height
                scale: tile.factor
                transformOrigin: Item.Bottom

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -6
                    radius: Theme.radiusLarge
                    color: Theme.island
                    border.color: tile.pulled ? Theme.accent : Theme.islandBorder
                    border.width: tile.pulled ? 6 : 3
                }

                BlockFace {
                    anchors.fill: parent
                    blockId: tile.blockId
                    size: tile.size
                    enabled: false
                }
            }
        }

        Text {
            anchors.bottom: parent.bottom
            width: parent.width
            text: Tr.t(tile.modelData.name)
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLabel
            color: Theme.textMuted
        }

        HoverHandler {
            cursorShape: tile.pulled ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        }

        TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: ControlsService.add(tile.blockId)
        }

        DragHandler {
            id: pull

            target: null

            onActiveChanged: {
                if (pull.active) {
                    root.pulling = tile.blockId
                    root.aim(pull.centroid.scenePosition)
                    return
                }
                const spot = ControlsService.landing
                root.pulling = ""
                ControlsService.landing = null
                if (spot)
                    ControlsService.add(tile.blockId, spot.col, spot.row)
            }

            onCentroidChanged: {
                if (pull.active)
                    root.aim(pull.centroid.scenePosition)
            }
        }
    }

    // ── GHOST ───────────────────────────────────────────────────────────────
    //
    // The dragged block at its landing size, over the island, with the landing
    // cell highlighted on the grid. Hidden while the pointer is over the tray.
    function aim(scene: point): void {
        const board = ControlsService.board
        const at = root.host.mapFromItem(null, scene.x, scene.y)
        ghost.x = at.x - ghost.width / 2
        ghost.y = at.y - ghost.height / 2
        if (!board)
            return
        const pointer = board.mapFromItem(null, scene.x, scene.y)
        if (ControlsService.overTray(pointer.x, pointer.y)) {
            ControlsService.landing = null
            return
        }
        const corner = board.mapFromItem(root.host, ghost.x, ghost.y)
        const size = ControlsService.sizesFor(root.pulling)[0] ?? "2x2"
        const spot = ControlsService.nearestFree(
            ControlsService.cellX(corner.x), ControlsService.cellY(corner.y), size, "")
        ControlsService.landing = spot
            ? { col: spot.col, row: spot.row, size: size } : null
    }

    Rectangle {
        id: ghost

        readonly property var entry: ControlsService.entry(root.pulling)
        readonly property var size: ControlsService.pixels(
            ControlsService.sizesFor(root.pulling)[0] ?? "2x2")

        parent: root.host
        z: 100
        visible: root.pulling !== ""
        width: ghost.size.width
        height: ghost.size.height
        radius: Theme.radiusMedium
        color: Theme.islandSurface
        border.color: Theme.accent
        border.width: 2
        opacity: 0.9

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ghost.entry ? ghost.entry.icon : ""
                font.family: Theme.fontMono
                font.pixelSize: 16
                color: Theme.accent
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: ghost.entry ? Tr.t(ghost.entry.name) : ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
                color: Theme.text
            }
        }
    }
}
