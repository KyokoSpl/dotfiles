import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

PopupWindow {
    id: root
    visible: animState !== "closed"
    implicitWidth: 280
    implicitHeight: 600
    color: "transparent"

    property string animState: "closed"
    property string screenName: ""
    property bool wifiEnabled: false
    property bool scanning: false
    property string activeConnection: ""
    property var networks: []

    Connections {
        target: SessionState
        function onNetworkPopupVisibleChanged() {
            if (SessionState.networkPopupVisible && SessionState.activePopupScreen === root.screenName) {
                refresh()
                animState = "open"
            } else if (animState === "open") {
                animState = "closing"
            }
        }
    }

    function refresh() {
        wifiStateProc.running = true
        activeProc.running = true
        listProc.running = true
    }

    readonly property int maxListHeight: 6 * 34 + 5 * 4

    // ── WiFi enabled check ──
    Process {
        id: wifiStateProc
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled"
            }
        }
    }

    // ── Active connection ──
    Process {
        id: activeProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi", "list", "--rescan", "no"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                for (const line of lines) {
                    const parts = line.split(":")
                    if (parts[0] === "yes") {
                        root.activeConnection = parts[1] || ""
                        return
                    }
                }
                root.activeConnection = ""
            }
        }
    }

    // ── Network list ──
    Process {
        id: listProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "dev", "wifi", "list", "--rescan", "auto"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.scanning = false
                const lines = text.trim().split("\n")
                var result = []
                var seen = {}
                for (var i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":")
                    if (parts.length < 3) continue
                    const ssid = parts[0].trim()
                    if (!ssid || seen[ssid]) continue
                    seen[ssid] = true
                    result.push({
                        ssid: ssid,
                        signal: parseInt(parts[1]) || 0,
                        security: parts[2] || "",
                        active: parts[3] === "*"
                    })
                }
                result.sort(function(a, b) {
                    if (a.active && !b.active) return -1
                    if (!a.active && b.active) return 1
                    return b.signal - a.signal
                })
                root.networks = result
            }
        }
    }

    // ── Scan ──
    Process {
        id: scanProc
        command: ["nmcli", "dev", "wifi", "rescan"]
        running: false
        onRunningChanged: {
            if (!running) {
                scanDelayTimer.start()
            }
        }
    }

    Timer {
        id: scanDelayTimer
        interval: 2000
        repeat: false
        onTriggered: listProc.running = true
    }

    // ── Connect/Disconnect ──
    Process {
        id: connectProc
        property string ssid: ""
        command: ["nmcli", "dev", "wifi", "connect", ssid]
        running: false
        onRunningChanged: if (!running) refresh()
    }

    Process {
        id: disconnectProc
        command: ["nmcli", "dev", "disconnect", "wlan0"]
        running: false
        onRunningChanged: if (!running) refresh()
    }

    // ── Toggle WiFi ──
    Process {
        id: wifiToggleProc
        property string state: "on"
        command: ["nmcli", "radio", "wifi", state]
        running: false
        onRunningChanged: if (!running) { wifiStateProc.running = true; listProc.running = true; activeProc.running = true }
    }

    // ── Auto refresh ──
    Timer {
        interval: 15000
        running: root.animState === "open"
        repeat: true
        onTriggered: refresh()
    }

    function signalIcon(sig) {
        if (sig >= 80) return "󰤨"
        if (sig >= 60) return "󰤥"
        if (sig >= 40) return "󰤢"
        if (sig >= 20) return "󰤟"
        return "󰤯"
    }

    Rectangle {
        id: innerRect
        width: parent.width
        height: column.implicitHeight + 20
        Behavior on height {
            SmoothedAnimation { velocity: 800; easing.type: Easing.OutExpo }
        }

        y: 0
        opacity: 1.0

        states: [
            State {
                name: "open"
                when: root.animState === "open"
                PropertyChanges { target: innerRect; y: 0; opacity: 1.0 }
            },
            State {
                name: "closing"
                when: root.animState === "closing"
                PropertyChanges { target: innerRect; y: -20; opacity: 0.0 }
            }
        ]

        transitions: [
            Transition {
                from: "*"; to: "open"
                SequentialAnimation {
                    PropertyAction { target: innerRect; property: "y"; value: -20 }
                    PropertyAction { target: innerRect; property: "opacity"; value: 0.0 }
                    ParallelAnimation {
                        NumberAnimation { target: innerRect; property: "y"; to: 0; duration: 250; easing.type: Easing.OutExpo }
                        NumberAnimation { target: innerRect; property: "opacity"; to: 1.0; duration: 180; easing.type: Easing.OutCubic }
                    }
                }
            },
            Transition {
                from: "*"; to: "closing"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation { target: innerRect; property: "y"; to: -20; duration: 180; easing.type: Easing.InCubic }
                        NumberAnimation { target: innerRect; property: "opacity"; to: 0.0; duration: 150; easing.type: Easing.InCubic }
                    }
                    ScriptAction { script: root.animState = "closed" }
                }
            }
        ]

        radius: 10
        color: Colors.grey900
        border.color: root.wifiEnabled ? Colors.purple200 : Colors.grey700
        border.width: 2
        clip: true

        Column {
            id: column
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 10 }
            spacing: 4

            // ── WiFi toggle ──
            Rectangle {
                width: parent.width; height: 34; radius: 6
                color: root.wifiEnabled ? Colors.purple200 : Colors.grey800

                Rectangle {
                    visible: !root.wifiEnabled
                    width: 3; height: parent.height - 10; radius: 2
                    anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                    color: Colors.purple200
                }
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    spacing: 8
                    Text {
                        text: root.wifiEnabled ? "󰤨" : "󰤭"
                        font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"
                        color: root.wifiEnabled ? Colors.grey900 : Colors.grey200
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.wifiEnabled ? "WiFi On" : "WiFi Off"
                        font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        color: root.wifiEnabled ? Colors.grey900 : Colors.grey200
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                    onClicked: {
                        wifiToggleProc.state = root.wifiEnabled ? "off" : "on"
                        wifiToggleProc.running = true
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // ── Active connection ──
            Rectangle {
                visible: root.wifiEnabled && root.activeConnection !== ""
                width: parent.width; height: visible ? 34 : 0; radius: 6
                color: Colors.purple200

                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14; right: parent.right; rightMargin: 10 }
                    spacing: 8
                    Text {
                        text: "󰈀"
                        font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"
                        color: Colors.grey900
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.activeConnection
                        font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        color: Colors.grey900
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        width: parent.width - 23 - 8
                    }
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                    onClicked: {
                        disconnectProc.running = true
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // ── Divider ──
            Rectangle {
                visible: root.wifiEnabled
                width: parent.width; height: visible ? 1 : 0
                color: Colors.grey800
            }

            // ── Scan button ──
            Rectangle {
                visible: root.wifiEnabled
                width: parent.width; height: visible ? 34 : 0; radius: 6
                color: root.scanning ? Colors.teal400 : Colors.grey800

                Rectangle {
                    visible: !root.scanning
                    width: 3; height: parent.height - 10; radius: 2
                    anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                    color: Colors.teal400
                }
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    spacing: 8
                    Text {
                        text: root.scanning ? "" : "󰑐"
                        font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"
                        color: root.scanning ? Colors.grey900 : Colors.grey200
                        anchors.verticalCenter: parent.verticalCenter
                        SequentialAnimation on opacity {
                            running: root.scanning
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.4; duration: 600; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                        }
                    }
                    Text {
                        text: root.scanning ? "Scanning..." : "Scan"
                        font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        color: root.scanning ? Colors.grey900 : Colors.grey200
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                    onClicked: {
                        if (!root.scanning) {
                            root.scanning = true
                            scanProc.running = true
                        }
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // ── Network list ──
            Item {
                visible: root.wifiEnabled && root.networks.length > 0
                width: parent.width
                height: visible ? Math.min(root.maxListHeight, networkColumn.implicitHeight) : 0

                Flickable {
                    id: networkFlickable
                    anchors.fill: parent
                    contentHeight: networkColumn.implicitHeight
                    clip: true
                    interactive: contentHeight > height

                    Column {
                        id: networkColumn
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: root.networks
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                readonly property bool isActive: modelData.ssid === root.activeConnection
                                visible: !isActive
                                width: networkColumn.width
                                height: visible ? 34 : 0
                                radius: 6
                                color: netMouse.containsMouse ? Colors.grey700 : Colors.grey800

                                Rectangle {
                                    width: 3; height: parent.height - 10; radius: 2
                                    anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                                    color: Colors.purple200
                                }
                                Row {
                                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14; right: parent.right; rightMargin: 10 }
                                    spacing: 8
                                    Text {
                                        text: root.signalIcon(modelData.signal)
                                        font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"
                                        color: Colors.grey200
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text {
                                        text: modelData.ssid
                                        font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                                        color: Colors.grey200
                                        anchors.verticalCenter: parent.verticalCenter
                                        elide: Text.ElideRight
                                        width: parent.width - 23 - 8 - (lockIcon.visible ? 20 : 0)
                                    }
                                    Text {
                                        id: lockIcon
                                        visible: modelData.security !== "" && modelData.security !== "--"
                                        text: "󰌾"
                                        font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
                                        color: Colors.grey500
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                                MouseArea {
                                    id: netMouse
                                    anchors.fill: parent; hoverEnabled: true
                                    onClicked: {
                                        connectProc.ssid = modelData.ssid
                                        connectProc.running = true
                                    }
                                }
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }
                        }
                    }
                }

                // Scroll up hint
                Rectangle {
                    visible: !networkFlickable.atYBeginning
                    anchors { top: parent.top; left: parent.left; right: parent.right }
                    height: 22; radius: 6
                    color: Colors.grey800
                    Row {
                        anchors.centerIn: parent; spacing: 6
                        Text { text: "󰁄"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey500; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "scroll up"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey500; anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                // Scroll down hint
                Rectangle {
                    visible: !networkFlickable.atYEnd
                    anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                    height: 22; radius: 6
                    color: Colors.grey800
                    Row {
                        anchors.centerIn: parent; spacing: 6
                        Text { text: "󰁆"; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey500; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "scroll for more"; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey500; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }

            // ── Settings shortcut ──
            Rectangle {
                visible: root.wifiEnabled
                width: parent.width; height: visible ? 34 : 0; radius: 6
                color: Colors.grey800

                Rectangle {
                    width: 3; height: parent.height - 10; radius: 2
                    anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                    color: Colors.grey500
                }
                Row {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    spacing: 8
                    Text {
                        text: "󰒓"
                        font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"
                        color: Colors.grey400
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Network Settings..."
                        font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                        color: Colors.grey400
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    anchors.fill: parent; hoverEnabled: true
                    onEntered: parent.opacity = 0.8
                    onExited: parent.opacity = 1.0
                    onClicked: {
                        Quickshell.execDetached(["nm-connection-editor"])
                        SessionState.networkPopupVisible = false
                    }
                }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }
}
