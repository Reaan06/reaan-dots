import QtQuick
import QtCore
import Quickshell
import Quickshell.Wayland

import "../theme"

// The surface occupies only the left edge; its input region is the handle at
// rest and the actual drawing card when open. Strokes belong to this instance,
// not to the Canvas texture (which is discarded when the surface is resized).
PanelWindow {
    id: root

    property bool open: false
    property bool hovered: false
    property bool erasing: false
    property color ink: "#f4f1ed"
    property int brushSize: 5
    property var strokes: []
    property var pending: null
    property string status: ""
    property bool saving: false

    readonly property int cardWidth: Math.min(760, Math.max(260, screen.width - 56))
    readonly property int cardHeight: Math.min(680, Math.max(260, screen.height - 110))
    readonly property int cardY: Math.round((height - cardHeight) / 2)

    function toggle(): void { open = !open }

    function point(x, y): var {
        return { x: x / canvas.width, y: y / canvas.height }
    }

    function paintStroke(ctx, stroke): void {
        const points = stroke.points
        if (!points.length)
            return
        ctx.save()
        ctx.globalCompositeOperation = stroke.erase ? "destination-out" : "source-over"
        ctx.strokeStyle = stroke.color
        ctx.fillStyle = stroke.color
        ctx.lineWidth = stroke.size
        ctx.lineCap = "round"
        ctx.lineJoin = "round"
        ctx.beginPath()
        ctx.moveTo(points[0].x * canvas.width, points[0].y * canvas.height)
        for (let i = 1; i < points.length; ++i)
            ctx.lineTo(points[i].x * canvas.width, points[i].y * canvas.height)
        if (points.length === 1) {
            ctx.arc(points[0].x * canvas.width, points[0].y * canvas.height,
                    stroke.size / 2, 0, 2 * Math.PI)
            ctx.fill()
        } else {
            ctx.stroke()
        }
        ctx.restore()
    }

    function undo(): void {
        if (strokes.length === 0)
            return
        strokes = strokes.slice(0, -1)
        canvas.requestPaint()
    }

    function clear(): void {
        strokes = []
        canvas.requestPaint()
    }

    function exportPng(): void {
        if (saving)
            return
        const pictures = StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        const folder = pictures ? pictures.toString() : ""
        // StandardPaths yields a local file URL in QML. Canvas.save takes
        // a filesystem path, not a URL; decode only a local file URL.
        const local = folder.startsWith("file://")
            ? decodeURIComponent(folder.slice(7)) : (folder.includes("://") ? "" : folder)
        if (!local.startsWith("/") || canvas.width < 1 || canvas.height < 1) {
            status = "Pictures folder or drawing surface unavailable"
            return
        }
        saving = true
        status = "Saving…"
        // Save only the Canvas texture, not its dark background child.
        // Canvas.save forces any pending painting before writing the PNG.
        const name = "drawing-" + Qt.formatDateTime(new Date(), "yyyyMMdd-hhmmss-zzz") + ".png"
        const destination = local.replace(/\/$/, "") + "/" + name
        const ok = canvas.save(destination)
        status = ok ? "Saved to Pictures: " + name : "Could not save PNG to Pictures"
        saving = false
    }

    anchors { left: true; top: true; bottom: true }
    implicitWidth: open ? cardWidth + 38 : 38
    implicitHeight: screen.height
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.namespace: "impasto-drawing"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {
        x: 0
        y: root.open ? root.cardY : Math.round(root.height / 2 - 40)
        width: root.open ? root.width : (root.hovered ? 38 : 18)
        height: root.open ? root.cardHeight : 80
    }

    Rectangle {
        id: card
        visible: root.open
        x: 32
        y: root.cardY
        width: root.cardWidth
        height: root.cardHeight
        radius: 18
        color: Theme.island
        border.color: Theme.islandBorder
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            Row {
                height: 32
                spacing: 8

                Repeater {
                    model: ["Pen", "Eraser", "Undo", "Clear", "Save PNG"]
                    delegate: Rectangle {
                        required property string modelData
                        width: label.implicitWidth + 18
                        height: 32
                        radius: 9
                        color: (modelData === "Pen" && !root.erasing)
                            || (modelData === "Eraser" && root.erasing)
                            ? Theme.accent : "#42434b"

                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: modelData
                            color: "white"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData === "Pen") root.erasing = false
                                else if (modelData === "Eraser") root.erasing = true
                                else if (modelData === "Undo") root.undo()
                                else if (modelData === "Clear") root.clear()
                                else root.exportPng()
                            }
                        }
                    }
                }
            }

            Row {
                height: 30
                spacing: 10
                Text {
                    text: "Ink"
                    color: Theme.text
                    anchors.verticalCenter: parent.verticalCenter
                }
                Repeater {
                    model: ["#f4f1ed", "#ff7777", "#ffc45c", "#81d4a0", "#79b9ff", "#be95ed"]
                    delegate: Rectangle {
                        required property string modelData
                        width: 24
                        height: 24
                        radius: 12
                        anchors.verticalCenter: parent.verticalCenter
                        color: modelData
                        border.width: Qt.colorEqual(root.ink, modelData) ? 3 : 1
                        border.color: Qt.colorEqual(root.ink, modelData) ? "white" : "#777777"
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { root.ink = modelData; root.erasing = false }
                        }
                    }
                }
                Text {
                    text: "Size " + root.brushSize
                    color: Theme.text
                    anchors.verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: 32
                    height: 28
                    radius: 8
                    color: "#42434b"
                    Text {
                        anchors.centerIn: parent
                        text: "−"
                        color: "white"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.brushSize = Math.max(1, root.brushSize - 2)
                    }
                }
                Rectangle {
                    width: 32
                    height: 28
                    radius: 8
                    color: "#42434b"
                    Text { anchors.centerIn: parent; text: "+"; color: "white" }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.brushSize = Math.min(48, root.brushSize + 2)
                    }
                }
            }

            Canvas {
                id: canvas
                width: parent.width
                height: Math.max(1, parent.height - 32 - 30 - 42)
                renderTarget: Canvas.Image
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    for (const stroke of root.strokes)
                        root.paintStroke(ctx, stroke)
                    if (root.pending)
                        root.paintStroke(ctx, root.pending)
                }

                // The exported canvas is transparent: erasing removes ink, not
                // a painted approximation of the background.
                Rectangle {
                    anchors.fill: parent
                    color: "#23252b"
                    z: -1
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.CrossCursor
                    onPressed: mouse => {
                        root.pending = { erase: root.erasing, color: root.ink.toString(),
                                         size: root.brushSize, points: [root.point(mouse.x, mouse.y)] }
                        canvas.requestPaint()
                    }
                    onPositionChanged: mouse => {
                        if (!pressed || !root.pending)
                            return
                        root.pending.points.push(root.point(mouse.x, mouse.y))
                        canvas.requestPaint()
                    }
                    onReleased: {
                        if (!root.pending)
                            return
                        root.strokes = root.strokes.concat([root.pending])
                        root.pending = null
                        canvas.requestPaint()
                    }
                    onCanceled: { root.pending = null; canvas.requestPaint() }
                }
            }
            Text {
                width: parent.width
                height: 22
                color: Theme.text
                elide: Text.ElideRight
                text: root.status || "Draw on the canvas · Super+D to hide"
                font.pixelSize: 12
            }
        }
    }

    Rectangle {
        x: 0
        y: root.height / 2 - 40
        width: root.hovered || root.open ? 32 : 14
        height: 80
        radius: 7
        color: Theme.accent
        Text {
            anchors.centerIn: parent
            text: root.open ? "‹" : "›"
            color: "white"
            font.pixelSize: 22
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: root.hovered = true
            onExited: root.hovered = false
            onClicked: root.toggle()
        }
    }
}
