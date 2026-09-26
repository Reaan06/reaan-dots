import QtQuick
import QtCore
import Quickshell
import Quickshell.Wayland

// Strokes are normalized to the drawing surface, so resizing the card does
// not discard them. The dotted backdrop is separate from the exported Canvas.
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

    readonly property int cardWidth: Math.min(460, Math.max(1, screen.width - 24))
    readonly property int cardHeight: Math.min(480, Math.max(1, screen.height - 24))
    readonly property int cardY: Math.round((height - cardHeight) / 2)
    // Leave the drawing surface and a scrollable row of tools on short screens.
    readonly property bool compactHeight: cardHeight < 230
    readonly property color coral: "#e68b83"
    readonly property color muted: "#b6aebc"

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
        // Save only the Canvas texture, never the dotted backdrop.
        const name = "drawing-" + Qt.formatDateTime(new Date(), "yyyyMMdd-hhmmss-zzz") + ".png"
        const destination = local.replace(/\/$/, "") + "/" + name
        const ok = canvas.save(destination)
        status = ok ? "Saved to Pictures: " + name : "Could not save PNG to Pictures"
        saving = false
    }

    anchors { left: true; top: true; bottom: true }
    implicitWidth: open ? cardWidth + 16 : 30
    implicitHeight: screen.height
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    WlrLayershell.namespace: "impasto-drawing"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {
        x: 0
        y: root.open ? root.cardY : Math.round(root.height / 2 - 44)
        width: root.open ? root.width : (root.hovered ? 28 : 5)
        height: root.open ? root.cardHeight : 88
    }

    Rectangle {
        id: card
        visible: root.open
        x: 14
        y: root.cardY
        width: root.cardWidth
        height: root.cardHeight
        radius: 18
        color: "#242329"
        border.color: "#504650"
        border.width: 1
        clip: true

        Column {
            id: layout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Item {
                visible: !root.compactHeight
                width: parent.width
                height: 32
                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "DRAWING PAD"
                    color: root.muted
                    font.pixelSize: 11
                    font.bold: true
                    font.letterSpacing: 2
                }
                Rectangle {
                    anchors.right: parent.right
                    width: 32
                    height: 32
                    radius: 10
                    color: "#39363e"
                    Text {
                        anchors.centerIn: parent
                        text: "×"
                        color: "#f2d0ca"
                        font.pixelSize: 20
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.open = false
                    }
                }
            }

            Item {
                id: drawingArea
                width: parent.width
                height: Math.max(1, layout.height - tools.height - (footer.visible ? footer.height : 0)
                                 - (root.compactHeight ? (footer.visible ? 2 : 1) : 3) * layout.spacing
                                 - (root.compactHeight ? 0 : 32))
                clip: true

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: "#1d1d23"
                    border.color: "#48414a"
                    border.width: 1
                }
                Canvas {
                    id: dots
                    anchors.fill: parent
                    renderTarget: Canvas.Image
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.fillStyle = "#48434e"
                        for (let x = 12; x < width; x += 18)
                            for (let y = 12; y < height; y += 18) {
                                ctx.beginPath()
                                ctx.arc(x, y, 0.9, 0, 2 * Math.PI)
                                ctx.fill()
                            }
                    }
                }
                Canvas {
                    id: canvas
                    anchors.fill: parent
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

            Rectangle {
                id: tools
                width: parent.width
                height: root.compactHeight
                    ? Math.min(46, Math.max(1, layout.height - (footer.visible ? footer.height : 0)
                        - (footer.visible ? 2 : 1) * layout.spacing - 24))
                    : Math.min(toolContents.height + 16,
                        Math.max(40, layout.height - 32 - footer.height
                            - 3 * layout.spacing - 80))
                radius: 12
                color: "#302c34"
                border.color: "#504650"
                clip: true

                Flickable {
                    anchors.fill: parent
                    anchors.margins: 8
                    contentHeight: toolContents.height
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    Column {
                        id: toolContents
                        width: parent.width
                        spacing: 7

                    Flow {
                        width: parent.width
                        spacing: 5
                        Repeater {
                            model: ["Pen", "Eraser", "Undo", "Clear", "Save PNG"]
                            delegate: Rectangle {
                                required property string modelData
                                readonly property bool selected: (modelData === "Pen" && !root.erasing)
                                    || (modelData === "Eraser" && root.erasing)
                                width: label.implicitWidth + 18
                                height: 30
                                radius: 8
                                color: selected ? "#704b52" : "#403b45"
                                border.color: selected ? root.coral : "#5b535f"
                                Text {
                                    id: label
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: selected ? "#ffe7e0" : "#e9dfe9"
                                    font.pixelSize: 12
                                    font.bold: selected
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

                    Flow {
                        width: parent.width
                        spacing: 6
                        Repeater {
                            model: ["#f4f1ed", "#e68b83", "#d1afe2", "#ffc45c", "#81d4a0", "#79b9ff"]
                            delegate: Rectangle {
                                required property string modelData
                                width: 26
                                height: 26
                                radius: 13
                                color: modelData
                                border.width: Qt.colorEqual(root.ink, modelData) ? 3 : 1
                                border.color: Qt.colorEqual(root.ink, modelData) ? "white" : "#716b75"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { root.ink = modelData; root.erasing = false }
                                }
                            }
                        }
                        Text {
                            text: "Size " + root.brushSize
                            color: "#e9dfe9"
                            font.pixelSize: 12
                            height: 26
                            verticalAlignment: Text.AlignVCenter
                        }
                        Repeater {
                            model: ["−", "+"]
                            delegate: Rectangle {
                                required property string modelData
                                width: 28
                                height: 26
                                radius: 7
                                color: "#403b45"
                                border.color: "#5b535f"
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: "#f2d0ca"
                                    font.pixelSize: 16
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.brushSize = modelData === "−"
                                        ? Math.max(1, root.brushSize - 2) : Math.min(48, root.brushSize + 2)
                                }
                            }
                        }
                    }
                    }
                }
            }

            Text {
                id: footer
                visible: !root.compactHeight || root.status !== ""
                width: parent.width
                height: 16
                color: root.muted
                elide: Text.ElideRight
                text: root.status || "Draw on the canvas · Super+D to hide"
                font.pixelSize: 11
            }
        }
    }

    // The closed window has no painted pixels. Only five edge pixels capture
    // hover; expanding the mask with the handle lets the pointer click it.
    Rectangle {
        x: 0
        y: root.height / 2 - 44
        width: root.open || root.hovered ? 28 : 5
        height: 88
        radius: 8
        visible: root.open || root.hovered
        color: "#383139"
        border.color: root.coral
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: root.open ? "‹" : "›"
            color: "#f2b1a9"
            font.pixelSize: 20
        }
    }
    MouseArea {
        x: 0
        y: root.height / 2 - 44
        width: root.open || root.hovered ? 28 : 5
        height: 88
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.toggle()
    }
}
