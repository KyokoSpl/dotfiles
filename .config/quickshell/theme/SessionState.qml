pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property bool visible: false
    property bool powerPopupVisible: false
    property bool bluetoothPopupVisible: false
    property bool networkPopupVisible: false
    property bool systemPopupVisible: false
    property bool layoutPopupVisible: false
    property string activePopupScreen: ""
    function show() { visible = true }
    function hide() { visible = false }

    function closeAllPopups() {
        powerPopupVisible = false
        bluetoothPopupVisible = false
        networkPopupVisible = false
        systemPopupVisible = false
        layoutPopupVisible = false
        visible = false
        AudioState.hide()
    }
}
