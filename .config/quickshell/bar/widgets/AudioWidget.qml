import QtQuick
import "../../theme"

Pill {
    id: root
    pillColor: PanelColors.audio
    property string screenName: ""

    label: (AudioState.muted || AudioState.volume === 0) ? "󰝟" : "󰕾 " + AudioState.volume + "%"

    mouseArea.onClicked: {
        if (AudioState.popupVisible && SessionState.activePopupScreen === root.screenName) {
            AudioState.hide()
        } else {
            SessionState.activePopupScreen = root.screenName
            AudioState.show()
        }
    }
    mouseArea.onWheel: (wheel) => {
        var newVol = wheel.angleDelta.y > 0
            ? Math.min(100, AudioState.volume + 5)
            : Math.max(0, AudioState.volume - 5)
        AudioState.setVolume(newVol)
    }
}
