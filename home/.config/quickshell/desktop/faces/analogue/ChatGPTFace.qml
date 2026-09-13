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
            ? `Session ${CodexService.resetsIn} · ${CodexService.compact(CodexService.blockTokens)} tokens`
            : "Codex account authenticated")
        : "Codex account not authenticated"
    reading: authenticated
        ? (available ? CodexService.compact(CodexService.blockTokens) + " tokens" : "Ready")
        : "Login"
    note: authenticated
        ? (available ? `Week: ${CodexService.compact(CodexService.weekTokens)} tokens` : "Codex authenticated")
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
