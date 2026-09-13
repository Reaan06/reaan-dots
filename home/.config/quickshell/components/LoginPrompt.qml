import QtQuick

import "../services"

Item {
    id: root

    property string service: ""
    property string label: "Log in"

    implicitWidth: button.implicitWidth
    implicitHeight: button.implicitHeight

    PillButton {
        id: button
        text: root.label
        onClicked: AuthService.login(root.service)
    }
}
