import QtQuick
import Quickshell
import Quickshell.Io
import "../theme"

PopupWindow {
    id: root
    visible: animState !== "closed"
    implicitWidth: 200
    implicitHeight: 600
    color: "transparent"

    property string animState: "closed"
    property string currentLayout: "T"
    property string screenName: ""
    property var layouts: []
    property bool widgetOpen: false

    onWidgetOpenChanged: {
        if (widgetOpen) {
            layoutListProc.running = true
            getLayoutProc.running = true
            animState = "open"
        } else if (animState === "open") {
            animState = "closing"
        }
    }

    function layoutName(code) {
        if (code === "T")  return "Tile"
        if (code === "S")  return "Stack"
        if (code === "G")  return "Grid"
        if (code === "M")  return "Monocle"
        if (code === "K")  return "Keyed"
        if (code === "CT") return "Center Tile"
        if (code === "RT") return "Right Tile"
        if (code === "VS") return "V-Stack"
        if (code === "VT") return "V-Tile"
        if (code === "VG") return "V-Grid"
        if (code === "VK") return "V-Keyed"
        if (code === "TG") return "Tag Grid"
        return code
    }

    function layoutIcon(code) {
        if (code === "T")  return "󰙀"
        if (code === "S")  return "󱒎"
        if (code === "G")  return "󰕰"
        if (code === "M")  return "󰍉"
        if (code === "K")  return "󰌨"
        if (code === "CT") return "󰕴"
        if (code === "RT") return "󰁁"
        if (code === "VS") return "󱒏"
        if (code === "VT") return "󰯍"
        if (code === "VG") return "󰕳"
        if (code === "VK") return "󰌩"
        if (code === "TG") return "󱇙"
        return "󰙀"
    }

    // ── Get available layouts ──
    Process {
        id: layoutListProc
        command: ["mmsg", "-L"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                var result = []
                for (var i = 0; i < lines.length; i++) {
                    var code = lines[i].trim()
                    if (code !== "") result.push(code)
                }
                root.layouts = result
            }
        }
    }

    // ── Get current layout ──
    Process {
        id: getLayoutProc
        command: root.screenName !== "" ? ["mmsg", "-o", root.screenName, "-g", "-l"] : ["mmsg", "-g", "-l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var match = lines[i].match(/(\S+)\s+layout\s+(\S+)/)
                    if (match) {
                        if (root.screenName !== "" && match[1] !== root.screenName) continue
                        root.currentLayout = match[2]
                        return
                    }
                }
            }
        }
    }

    // ── Set layout ──
    Process {
        id: setLayoutProc
        property string layoutCode: ""
        command: root.screenName !== "" ? ["mmsg", "-o", root.screenName, "-s", "-l", layoutCode] : ["mmsg", "-s", "-l", layoutCode]
        running: false
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
        border.color: Colors.blueGrey500
        border.width: 2
        clip: true

        Column {
            id: column
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 10 }
            spacing: 4

            // ── Header ──
            Row {
                height: 24; leftPadding: 4; spacing: 6
                Text { text: "󰙀"; font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"; color: Colors.blueGrey300; anchors.verticalCenter: parent.verticalCenter }
                Text { text: "Layout"; font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"; color: Colors.grey200; anchors.verticalCenter: parent.verticalCenter }
            }

            // ── Layout list ──
            Repeater {
                model: root.layouts
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool isActive: modelData === root.currentLayout
                    width: column.width; height: 34; radius: 6
                    color: isActive ? Colors.blueGrey500 : (layoutMouse.containsMouse ? Colors.grey700 : Colors.grey800)

                    Rectangle {
                        visible: !isActive
                        width: 3; height: parent.height - 10; radius: 2
                        anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                        color: Colors.blueGrey500
                    }
                    Row {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                        spacing: 8
                        Text {
                            text: root.layoutIcon(modelData)
                            font.pixelSize: 15; font.family: "JetBrainsMono Nerd Font"
                            color: isActive ? Colors.grey900 : Colors.grey200
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: root.layoutName(modelData)
                            font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font"
                            color: isActive ? Colors.grey900 : Colors.grey200
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "(" + modelData + ")"
                            font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                            color: isActive ? Colors.grey800 : Colors.grey500
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        id: layoutMouse
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            setLayoutProc.layoutCode = modelData
                            setLayoutProc.running = true
                            root.currentLayout = modelData
                            SessionState.layoutPopupVisible = false
                        }
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }
    }
}
