// AudioSystem.qml — Bridge to C++ audio backend
import QtQuick 2.15

Item {
    id: root

    function playBeep() {
        posController.playBeep()
    }

    function playError() {
        posController.playError()
    }

    function playSuccess() {
        posController.playSuccess()
    }
}
