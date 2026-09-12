// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   M A I N                                                                │
// │   sddm login screen                                                      │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick
import QtQuick.Shapes

import "components"

// No `import SDDM`: that is the Qt5 module, and under Qt6 the theme fails to
// load. `sddm`, `userModel`, `sessionModel` and `keyboard` are context
// properties.

// Same layout as the shell's lock screen, over a painting instead of the
// desktop. Account, session and power controls are the only additions.
Rectangle {
    id: root

    color: Theme.island

    // ── BACKGROUND ──────────────────────────────────────────────────────────

    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: true
        sourceSize.width: root.width
        sourceSize.height: root.height
    }

    // Radial darkening behind the text only: the painting is mid-toned and
    // busy, so neither white nor black text reads on it directly.
    Shape {
        anchors.fill: parent
        opacity: 0.92

        ShapePath {
            strokeColor: "transparent"
            fillGradient: RadialGradient {
                centerX: root.width / 2
                centerY: root.height * 0.52
                centerRadius: Math.max(root.width, root.height) * 0.42
                focalX: centerX
                focalY: centerY

                GradientStop { position: 0.0; color: "#d9000000" }
                GradientStop { position: 0.45; color: "#a6000000" }
                GradientStop { position: 0.78; color: "#40000000" }
                GradientStop { position: 1.0; color: "#00000000" }
            }

            startX: 0
            startY: 0
            PathLine { x: root.width; y: 0 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: 0 }
        }
    }

    // ── STATE ───────────────────────────────────────────────────────────────

    property bool authenticating: false
    property bool failed: false
    property string message: ""

    function attempt(password: string): void {
        if (root.authenticating)
            return
        root.authenticating = true
        root.failed = false
        root.message = ""
        sddm.login(who.userName, password, session.currentIndex)
    }

    Connections {
        target: sddm

        function onLoginSucceeded(): void {
            root.authenticating = false
            root.message = ""
        }

        // The field clears itself; clearing it here would fight its shake.
        function onLoginFailed(): void {
            root.authenticating = false
            root.failed = true
            root.message = qsTr("Wrong password")
        }

        function onInformationMessage(message: string): void {
            root.message = message
        }
    }

    // ── CLOCK AND LOGIN ─────────────────────────────────────────────────────

    property date now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    // Positions match the lock screen: clock above centre, field at a fixed
    // distance from the bottom, account just above the field. Anchored rather
    // than one Column because the gaps differ.

    Column {
        id: face

        anchors.centerIn: parent
        anchors.verticalCenterOffset: -60
        spacing: 4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(root.now, "HH:mm")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeClock
            font.weight: Font.Light
            color: Theme.text
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(root.now, "dddd d MMMM")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.text
            opacity: 0.75
        }
    }

    UserPicker {
        id: who

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: field.top
        anchors.bottomMargin: 26
        z: 2

        users: userModel
        currentIndex: userModel.lastIndex

        // Switching account discards the half-typed password.
        onChosen: {
            field.clear()
            root.failed = false
            root.message = ""
            field.claim()
        }
    }

    PasswordField {
        id: field

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 104
        z: 1

        authenticating: root.authenticating
        failed: root.failed
        message: root.message
        capsLock: keyboard.capsLock

        onSubmitted: root.attempt(password)

        // `failed` is bound from here, so the field only signals; assigning
        // it inside the field would break the binding.
        onDismissed: {
            root.failed = false
            root.message = ""
        }

        // Focused from the start: the first key press is the first character.
        Component.onCompleted: field.claim()
    }

    // ── BATTERY ─────────────────────────────────────────────────────────────
    //
    // Top right, where the lock screen shows it.

    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: parent.top
        anchors.topMargin: Theme.barTopMargin
        width: Theme.capsuleHeight
        height: Theme.capsuleHeight
        radius: Theme.radiusPill
        color: Theme.island
        visible: charge.available

        BatteryRing {
            id: charge

            anchors.centerIn: parent
            size: Theme.capsuleHeight
        }
    }

    // ── POWER AND SESSION ───────────────────────────────────────────────────
    //
    // Power bottom left, as on the lock screen; session bottom right.

    PowerRow {
        anchors.left: parent.left
        anchors.leftMargin: Theme.barTopMargin + 6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.barTopMargin + 6

        canReboot: sddm.canReboot
        canPowerOff: sddm.canPowerOff

        onRebootRequested: sddm.reboot()
        onPowerOffRequested: sddm.powerOff()
    }

    SessionPicker {
        id: session

        anchors.right: parent.right
        anchors.rightMargin: Theme.barTopMargin + 6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.barTopMargin + 6

        sessions: sessionModel
        currentIndex: sessionModel.lastIndex
    }

    // ── ESCAPE ──────────────────────────────────────────────────────────────
    //
    // Escape collapses whatever is open.

    focus: true
    Keys.onEscapePressed: {
        who.expanded = false
        session.expanded = false
    }
}
