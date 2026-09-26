import QtQuick
import QtCore
import Quickshell
import Quickshell.Wayland
import "../theme"

// Independent floating drawing canvas inspired by Serpantinum's DrawAction.
// Modularized into DrawingTopBar, DrawingDock, and DrawingPopups.
PanelWindow {
    id: root

    property bool open: false
    property bool hovered: false
    property string currentTool: "pen" // "pen", "brush", "marker", "eraser"

    property color primaryColor: "#f4f1ed"
    property color secondaryColor: "#e68b83"
    property int activeColorSlot: 0
    readonly property color currentColor: activeColorSlot === 0 ? primaryColor : secondaryColor

    property int penSize: 4
    property int brushSize: 12
    property int markerSize: 22
    property int eraserSize: 20

    readonly property int currentToolSize: {
        if (currentTool === "eraser") return eraserSize
        if (currentTool === "marker") return markerSize
        if (currentTool === "brush") return brushSize
        return penSize
    }

    function setToolSize(size): void {
        const val = Math.max(1, Math.min(64, Math.round(size)))
        if (currentTool === "eraser") eraserSize = val
        else if (currentTool === "marker") markerSize = val
        else if (currentTool === "brush") brushSize = val
        else penSize = val
    }

    property bool showSizePopup: false
    property bool showColorPopup: false

    property var strokes: []
    property var redoStack: []
    property var pending: null
    property string status: ""
    property bool saving: false

    readonly property int cardWidth: Math.min(680, Math.max(340, screen.width - 32))
    readonly property int cardHeight: Math.min(540, Math.max(240, screen.height - 36))
    readonly property int cardY: Math.round((height - cardHeight) / 2)

    readonly property color accentColor: Theme.accent || "#0a84ff"
    readonly property color textColor: Theme.text || "#ffffff"
    readonly property color textMuted: Theme.textMuted || "#8e8e93"

    function toggle(): void {
        open = !open
        if (!open) {
            showSizePopup = false
            showColorPopup = false
        }
    }

    function point(localX, localY): var {
        return {
            x: Math.max(0, Math.min(1, localX / canvas.width)),
            y: Math.max(0, Math.min(1, localY / canvas.height))
        }
    }

    function paintStroke(ctx, stroke): void {
        const points = stroke.points
        if (!points || !points.length)
            return
        ctx.save()
        if (stroke.tool === "eraser") {
            ctx.globalCompositeOperation = "destination-out"
            ctx.strokeStyle = "rgba(0,0,0,1)"
            ctx.fillStyle = "rgba(0,0,0,1)"
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
        } else if (stroke.tool === "marker") {
            ctx.globalCompositeOperation = "source-over"
            ctx.globalAlpha = 0.4
            ctx.strokeStyle = stroke.color
            ctx.fillStyle = stroke.color
            ctx.lineWidth = stroke.size
            ctx.lineCap = "square"
            ctx.lineJoin = "bevel"
            ctx.beginPath()
            ctx.moveTo(points[0].x * canvas.width, points[0].y * canvas.height)
            for (let i = 1; i < points.length; ++i)
                ctx.lineTo(points[i].x * canvas.width, points[i].y * canvas.height)
            ctx.stroke()
        } else if (stroke.tool === "brush") {
            ctx.globalCompositeOperation = "source-over"
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            const bSize = stroke.size
            const bristles = Math.max(4, Math.floor(bSize * 0.45))
            for (let b = 0; b < bristles; ++b) {
                const angle = (b / bristles) * Math.PI * 2
                const radius = (0.2 + ((b % 5) / 5) * 0.8) * (bSize * 0.4)
                const ox = Math.cos(angle) * radius
                const oy = Math.sin(angle) * radius
                ctx.globalAlpha = 0.22 + ((b % 3) / 3) * 0.35
                ctx.lineWidth = Math.max(1, bSize * 0.25)
                ctx.strokeStyle = stroke.color
                ctx.beginPath()
                ctx.moveTo(points[0].x * canvas.width + ox, points[0].y * canvas.height + oy)
                for (let i = 1; i < points.length; ++i)
                    ctx.lineTo(points[i].x * canvas.width + ox, points[i].y * canvas.height + oy)
                ctx.stroke()
            }
        } else {
            // standard pen
            ctx.globalCompositeOperation = "source-over"
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
        }
        ctx.restore()
    }

    function undo(): void {
        if (!strokes.length)
            return
        const last = strokes[strokes.length - 1]
        redoStack = redoStack.concat([last])
        strokes = strokes.slice(0, -1)
        canvas.requestPaint()
    }

    function redo(): void {
        if (!redoStack.length)
            return
        const next = redoStack[redoStack.length - 1]
        redoStack = redoStack.slice(0, -1)
        strokes = strokes.concat([next])
        canvas.requestPaint()
    }

    function clear(): void {
        if (!strokes.length)
            return
        redoStack = redoStack.concat([{ type: "snapshot", prev: strokes }])
        strokes = []
        canvas.requestPaint()
    }

    function exportPng(): void {
        if (saving)
            return
        const pictures = StandardPaths.writableLocation(StandardPaths.PicturesLocation)
        const folder = pictures ? pictures.toString() : ""
        const local = folder.startsWith("file://")
            ? decodeURIComponent(folder.slice(7)) : (folder.includes("://") ? "" : folder)
        if (!local.startsWith("/") || canvas.width < 1 || canvas.height < 1) {
            status = "Pictures folder unavailable"
            return
        }
        saving = true
        status = "Saving…"
        const name = "drawing-" + Qt.formatDateTime(new Date(), "yyyyMMdd-hhmmss") + ".png"
        const destination = local.replace(/\/$/, "") + "/" + name
        const ok = canvas.save(destination)
        if (ok) {
            status = "Saved: " + name
            Quickshell.execDetached(["notify-send", "-a", "Quickshell", "Drawing saved", destination])
        } else {
            status = "Could not save PNG"
        }
        saving = false
    }

    function copyClipboard(): void {
        if (saving || canvas.width < 1 || canvas.height < 1)
            return
        saving = true
        status = "Copying…"
        const tempPath = "/tmp/quickshell_drawing_" + Date.now() + ".png"
        const ok = canvas.save(tempPath)
        if (ok) {
            Quickshell.execDetached(["sh", "-c", "wl-copy -t image/png < " + tempPath + " && rm -f " + tempPath])
            status = "Copied to clipboard"
            Quickshell.execDetached(["notify-send", "-a", "Quickshell", "Drawing", "Copied to clipboard"])
        } else {
            status = "Clipboard copy failed"
        }
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

    Shortcut { sequence: "Ctrl+Z"; enabled: root.open; onActivated: root.undo() }
    Shortcut { sequence: "Ctrl+Shift+Z"; enabled: root.open; onActivated: root.redo() }
    Shortcut { sequence: "Escape"; enabled: root.open; onActivated: root.open = false }

    Rectangle {
        id: card
        visible: root.open
        x: 14
        y: root.cardY
        width: root.cardWidth
        height: root.cardHeight
        radius: 18
        color: "#181822"
        border.color: "#383642"
        border.width: 1
        clip: true

        Item {
            id: drawingArea
            anchors.fill: parent
            clip: true

            Item {
                id: cameraRig
                anchors.fill: parent

                property real zoom: 1.0
                property real panX: 0
                property real panY: 0

                function zoomBy(factor): void {
                    const next = Math.max(0.4, Math.min(3.0, zoom * factor))
                    zoom = Math.round(next * 100) / 100
                }

                function resetZoom(): void {
                    zoom = 1.0
                    panX = 0
                    panY = 0
                }

                Item {
                    id: canvasContainer
                    width: drawingArea.width
                    height: drawingArea.height
                    x: cameraRig.panX
                    y: cameraRig.panY
                    scale: cameraRig.zoom
                    transformOrigin: Item.Center

                    Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }

                    Canvas {
                        id: dots
                        anchors.fill: parent
                        renderTarget: Canvas.Image
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            ctx.fillStyle = "#3e3b4a"
                            const spacing = 18
                            for (let x = spacing / 2; x < width; x += spacing) {
                                for (let y = spacing / 2; y < height; y += spacing) {
                                    ctx.beginPath()
                                    ctx.arc(x, y, 1.1, 0, 2 * Math.PI)
                                    ctx.fill()
                                }
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
                            for (const stroke of root.strokes) {
                                if (stroke.type === "snapshot") continue
                                root.paintStroke(ctx, stroke)
                            }
                            if (root.pending)
                                root.paintStroke(ctx, root.pending)
                        }
                    }
                }

                MouseArea {
                    id: drawAreaMouse
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    cursorShape: pressed && (mouseButton === Qt.MiddleButton)
                        ? Qt.ClosedHandCursor : Qt.CrossCursor

                    property int mouseButton: Qt.NoButton
                    property real dragStartX: 0
                    property real dragStartY: 0
                    property real initPanX: 0
                    property real initPanY: 0

                    onPressed: mouse => {
                        root.showSizePopup = false
                        root.showColorPopup = false
                        mouseButton = mouse.button
                        if (mouse.button === Qt.MiddleButton) {
                            dragStartX = mouse.x
                            dragStartY = mouse.y
                            initPanX = cameraRig.panX
                            initPanY = cameraRig.panY
                            return
                        }
                        const p = mapToItem(canvas, mouse.x, mouse.y)
                        root.pending = {
                            tool: root.currentTool,
                            color: root.currentColor.toString(),
                            size: root.currentToolSize,
                            points: [root.point(p.x, p.y)]
                        }
                        canvas.requestPaint()
                    }

                    onPositionChanged: mouse => {
                        if (!pressed) return
                        if (mouseButton === Qt.MiddleButton) {
                            cameraRig.panX = initPanX + (mouse.x - dragStartX)
                            cameraRig.panY = initPanY + (mouse.y - dragStartY)
                            return
                        }
                        if (!root.pending) return
                        const p = mapToItem(canvas, mouse.x, mouse.y)
                        root.pending.points.push(root.point(p.x, p.y))
                        canvas.requestPaint()
                    }

                    onReleased: {
                        if (root.pending) {
                            root.strokes = root.strokes.concat([root.pending])
                            root.redoStack = []
                            root.pending = null
                            canvas.requestPaint()
                        }
                        mouseButton = Qt.NoButton
                    }

                    onCanceled: {
                        root.pending = null
                        mouseButton = Qt.NoButton
                        canvas.requestPaint()
                    }
                }
            }

            // Top Floating Bar (Zoom, Save, Clipboard, Close)
            DrawingTopBar {
                id: topActions
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 14
                z: 10
                zoom: cameraRig.zoom
                onZoomIn: cameraRig.zoomBy(1.25)
                onZoomOut: cameraRig.zoomBy(1.0 / 1.25)
                onZoomReset: cameraRig.resetZoom()
                onSaveClicked: root.exportPng()
                onCopyClicked: root.copyClipboard()
                onCloseClicked: root.open = false
            }

            // Status message badge
            Rectangle {
                visible: root.status !== ""
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 14
                height: 28
                width: statusText.implicitWidth + 20
                radius: 8
                color: Qt.rgba(0.08, 0.08, 0.10, 0.88)
                border.color: Qt.rgba(0.8, 0.8, 0.85, 0.14)
                border.width: 1
                z: 10
                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: root.status
                    color: root.textMuted
                    font.pixelSize: 11
                }
            }

            // Size Slider & Color Palette Popups
            DrawingPopups {
                id: popups
                anchors.bottom: bottomToolbar.top
                anchors.bottomMargin: 10
                anchors.horizontalCenter: bottomToolbar.horizontalCenter
                z: 20
                showSizePopup: root.showSizePopup
                showColorPopup: root.showColorPopup
                currentTool: root.currentTool
                currentToolSize: root.currentToolSize
                currentColor: root.currentColor
                onSizeChanged: s => root.setToolSize(s)
                onColorSelected: c => {
                    if (root.activeColorSlot === 0) root.primaryColor = c
                    else root.secondaryColor = c
                    if (root.currentTool === "eraser") root.currentTool = "pen"
                    root.showColorPopup = false
                }
            }

            // Bottom Floating Bar (Dock Toolbar)
            DrawingDock {
                id: bottomToolbar
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottomMargin: 14
                z: 10
                currentTool: root.currentTool
                primaryColor: root.primaryColor
                secondaryColor: root.secondaryColor
                activeColorSlot: root.activeColorSlot
                strokesCount: root.strokes.length
                redoCount: root.redoStack.length
                onUndoClicked: root.undo()
                onRedoClicked: root.redo()
                onClearClicked: {
                    root.clear()
                    root.showSizePopup = false
                    root.showColorPopup = false
                }
                onToolSelected: toolId => {
                    if (root.currentTool === toolId) {
                        root.showSizePopup = !root.showSizePopup
                    } else {
                        root.currentTool = toolId
                        root.showSizePopup = true
                    }
                    root.showColorPopup = false
                }
                onColorSlotClicked: slot => {
                    root.activeColorSlot = slot
                    root.showColorPopup = !root.showColorPopup
                    root.showSizePopup = false
                    if (root.currentTool === "eraser") root.currentTool = "pen"
                }
                onSwapColorsClicked: {
                    const tmp = root.primaryColor
                    root.primaryColor = root.secondaryColor
                    root.secondaryColor = tmp
                }
            }
        }
    }

    // Left-edge sensor & handle:
    // Invisible 5px sensor captures hover; expands to 28px on hover showing the chevron handle.
    Rectangle {
        x: 0
        y: root.height / 2 - 44
        width: root.open || root.hovered ? 28 : 5
        height: 88
        radius: 8
        visible: root.open || root.hovered
        color: "#282630"
        border.color: root.accentColor
        border.width: 1
        Text {
            anchors.centerIn: parent
            text: root.open ? "‹" : "›"
            color: root.accentColor
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
