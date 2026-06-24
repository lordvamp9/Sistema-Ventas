import QtQuick
import QtMultimedia

Item {
    id: root

    MediaPlayer {
        id: beepPlayer
        source: "https://actions.google.com/sounds/v1/alarms/beep_short.ogg"
        audioOutput: AudioOutput {}
    }

    MediaPlayer {
        id: errorPlayer
        source: "https://actions.google.com/sounds/v1/alarms/error_beep.ogg"
        audioOutput: AudioOutput {}
    }

    MediaPlayer {
        id: successPlayer
        source: "https://actions.google.com/sounds/v1/cartoon/magic_chime.ogg"
        audioOutput: AudioOutput {}
    }

    function playBeep() { beepPlayer.play() }
    function playError() { errorPlayer.play() }
    function playSuccess() { successPlayer.play() }
}
