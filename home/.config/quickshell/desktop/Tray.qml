// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   T   R   A   Y                                                          │
// │   widget tray · drag modules onto the grid                               │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "../theme"
import "../services"
import "../components"

// The tray shown while arranging: one tile per catalogue module, each a live
// miniature of its 2×2 face. Drag a tile onto the grid, or click it to place it
// on the first free cell; drop a widget here to remove it. Every module is
// offered regardless of its current state.
//
// The ghost (the tile at full size while dragged) lives on the board rather
// than here, so it can leave the tray.
EditTray {
    id: root

    required property Item board

    // Size of the 2×2 face the tile is scaled down from.
    readonly property int faceSize: DesktopService.sizeFor("2x2").width

    // The module being dragged out of the tray, or empty.
    property string pulling: ""

    model: DesktopService.offerable
    roomAcross: root.board.width - 2 * Theme.desktopGutter
    receiving: DesktopService.dragging !== "" && DesktopService.landing === null
    onDone: DesktopService.edit(false)

    // The tray's rect in board coordinates, so a drop can tell whether it
    // landed here. The Loader is a child of the board, so its position is the
    // tray's.
    Binding {
        target: DesktopService
        property: "trayBox"
        value: ({
            x: root.parent.x, y: root.parent.y,
            width: root.width, height: root.height
        })
    }

    Component.onDestruction: {
        DesktopService.trayBox = null
        DesktopService.landing = null
    }

    // ── TILE ────────────────────────────────────────────────────────────────

    delegate: Item {
        id: tile

        required property var modelData

        readonly property string moduleId: tile.modelData.id
        readonly property bool pulled: root.pulling === tile.moduleId

        width: root.tile
        height: root.tile + 18

        Item {
            width: root.tile
            height: root.tile

            // The real 2×2 face at a third of its size, on the island's black.
            Item {
                width: root.faceSize
                height: root.faceSize
                scale: root.tile / root.faceSize
                transformOrigin: Item.TopLeft

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.desktopRadius
                    color: Theme.island
                    border.color: tile.pulled ? Theme.accent : Theme.islandBorder
                    border.width: tile.pulled ? 4 : 2
                }

                Face {
                    anchors.fill: parent
                    moduleId: tile.moduleId
                    family: "2x2"
                    ink: DesktopService.inkFor(null)
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

        // Exclusive from the press, so the background's tap handler does not
        // also fire.
        TapHandler {
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: DesktopService.add(tile.moduleId)
        }

        DragHandler {
            id: pull

            target: null

            onActiveChanged: {
                if (pull.active) {
                    root.pulling = tile.moduleId
                    DesktopService.selected = ""
                    root.aim(pull.centroid.scenePosition)
                    return
                }
                const spot = DesktopService.landing
                const edge = DeckService.receiving
                root.pulling = ""
                DesktopService.landing = null
                DeckService.receiving = ""
                if (edge !== "" && tile.moduleId === "notes")
                    DesktopService.addDeck(edge)
                else if (spot)
                    DesktopService.add(tile.moduleId, spot.col, spot.row)
            }

            onCentroidChanged: {
                if (pull.active)
                    root.aim(pull.centroid.scenePosition)
            }
        }
    }

    // ── GHOST ───────────────────────────────────────────────────────────────
    //
    // The dragged tile at its final size, following the pointer; the surface
    // draws the target cell under it. Parented to the board so it can leave the
    // tray.
    function aim(scene: point): void {
        const pointer = root.board.mapFromItem(null, scene.x, scene.y)
        ghost.x = pointer.x - ghost.width / 2
        ghost.y = pointer.y - ghost.height / 2
        if (DesktopService.overTray(pointer.x, pointer.y)) {
            DesktopService.landing = null
            DeckService.receiving = ""
            return
        }
        // A notes tile against an edge is a deck there, not a square.
        const edge = root.pulling === "notes"
            ? DeckService.edgeAt(pointer.x, pointer.y, root.board.width, root.board.height) : ""
        DeckService.receiving = edge
        if (edge !== "") {
            DesktopService.landing = null
            return
        }
        const familyId = DesktopService.familiesFor(root.pulling)[0] ?? "4x2"
        const spot = DesktopService.nearestFree(
            DesktopService.cellOf(ghost.x), DesktopService.cellOf(ghost.y), familyId, "")
        DesktopService.landing = spot
            ? { col: spot.col, row: spot.row, family: familyId } : null
    }

    Item {
        id: ghost

        parent: root.board
        z: 10
        visible: root.pulling !== ""
        width: root.faceSize
        height: root.faceSize
        opacity: 0.9

        Rectangle {
            anchors.fill: parent
            radius: Theme.desktopRadius
            color: Theme.island
            border.color: Theme.accent
            border.width: 2
        }

        Face {
            anchors.fill: parent
            moduleId: root.pulling
            family: "2x2"
            ink: DesktopService.inkFor(null)
            enabled: false
        }
    }
}
