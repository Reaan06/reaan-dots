// ╭──────────────────────────────────────────────────────────────────────────╮
// │                                                                          │
// │   P A S S W O R D   F I E L D                                            │
// │   password field                                                         │
// │                                                                          │
// │   github.com/andreumassanet/impasto                                      │
// │                                                                          │
// ╰──────────────────────────────────────────────────────────────────────────╯

import QtQuick

import "."

// Same behaviour as the lock screen's field: it has keyboard focus from the
// start and stays hidden, showing a hint, until the first key. Hidden by
// opacity, because an item with `visible: false` cannot hold focus.
Item {
    id: root

    property bool authenticating: false
    property bool failed: false
    property string message: ""
    property bool capsLock: false

    signal submitted(string password)
    signal dismissed()

    function claim(): void {
        field.forceActiveFocus()
    }

    function clear(): void {
        field.clear()
    }

    readonly property bool typing: field.text !== ""
        || root.authenticating
        || root.failed

    implicitWidth: 360
    implicitHeight: 96

    // ── HINT ────────────────────────────────────────────────────────────────

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 12
        spacing: 10
        opacity: root.typing ? 0 : 1
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easing }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰌌"
            font.family: Theme.fontMono
            font.pixelSize: 17
            color: Theme.text
            opacity: 0.85
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Type your password to sign in")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.text
            opacity: 0.85
        }
    }

    // ── FIELD ───────────────────────────────────────────────────────────────

    Capsule {
        id: box

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 320
        height: 50
        radius: Theme.radiusPill
        border.color: {
            if (root.failed)
                return Theme.indicatorBad
            return field.activeFocus ? Theme.accent : Theme.islandBorder
        }

        opacity: root.typing ? 1 : 0
        // Scales in slightly as it fades in.
        scale: root.typing ? 1 : 0.94

        Behavior on opacity {
            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easing }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easing }
        }

        // Shake on a failed attempt.
        SequentialAnimation {
            id: refusal

            loops: 2
            NumberAnimation { target: box; property: "anchors.horizontalCenterOffset"
                to: -9; duration: 55; easing.type: Easing.OutCubic }
            NumberAnimation { target: box; property: "anchors.horizontalCenterOffset"
                to: 9; duration: 55; easing.type: Easing.OutCubic }
            NumberAnimation { target: box; property: "anchors.horizontalCenterOffset"
                to: 0; duration: 55; easing.type: Easing.OutCubic }
        }

        Connections {
            target: root
            function onFailedChanged(): void {
                if (root.failed)
                    refusal.restart()
            }
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 19
            anchors.verticalCenter: parent.verticalCenter
            text: "󰌾"
            font.family: Theme.fontMono
            font.pixelSize: 15
            color: root.failed ? Theme.indicatorBad : Theme.textMuted

            Behavior on color { ColorAnimation { duration: Theme.durationFast } }
        }

        TextInput {
            id: field

            anchors.left: parent.left
            anchors.leftMargin: 48
            anchors.right: parent.right
            anchors.rightMargin: 48
            anchors.verticalCenter: parent.verticalCenter

            echoMode: TextInput.Password
            passwordCharacter: "•"
            passwordMaskDelay: 0
            enabled: !root.authenticating
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.text
            selectionColor: Theme.accent
            selectedTextColor: Theme.accentText
            clip: true

            onAccepted: {
                if (field.text === "")
                    return
                root.submitted(field.text)
            }

            // Typing again clears the failure state.
            onTextChanged: {
                if (root.failed && field.text !== "")
                    root.dismissed()
            }

            // Don't leave a half-typed password on screen.
            Keys.onEscapePressed: field.clear()
        }

        RingSpinner {
            anchors.right: parent.right
            anchors.rightMargin: 17
            anchors.verticalCenter: parent.verticalCenter
            visible: root.authenticating
            running: root.authenticating
        }
    }

    // ── STATUS ──────────────────────────────────────────────────────────────
    //
    // Caps Lock takes priority over the PAM message.

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: box.bottom
        anchors.topMargin: 14
        text: root.capsLock ? qsTr("Caps Lock is on") : root.message
        visible: text !== ""
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        font.weight: Font.DemiBold
        color: root.capsLock ? Theme.indicatorWarn : Theme.indicatorBad
    }
}
