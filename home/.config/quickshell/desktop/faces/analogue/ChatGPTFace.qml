import QtQuick

import "../../../services"
import "../../../components"

// ChatGPT / Codex instrument · shows usage and login state
Instrument {
    id: face

    property bool authenticated: AuthService.chatgptAuthenticated
    property bool available: CodexService.available

    line: authenticated
        ? (available
            ? `Session ${CodexService.primaryResetNote || "reset unavailable"} · ${Math.round(CodexService.primaryUsedPercent)}% used`
            : "Codex account authenticated")
        : "Codex account not authenticated"
    reading: authenticated
        ? (available ? `${Math.round(CodexService.primaryUsedPercent)}% used` : "Ready")
        : "Login"
    note: authenticated
        ? (available
            ? (CodexService.secondaryAvailable
                ? `Week: ${Math.round(CodexService.secondaryUsedPercent)}% used · ${CodexService.secondaryResetNote || "reset unavailable"}`
                : "Week quota unavailable")
            : "Codex authenticated")
        : "ChatGPT login required"
    filled: authenticated

    CodexMark {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.34
        height: width
        color: face.ink.text
    }

    extra: [
        MouseArea {
            parent: face
            visible: !AuthService.chatgptAuthenticated
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: AuthService.login("chatgpt")
        }
    ]
}
