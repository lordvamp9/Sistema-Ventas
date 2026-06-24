import QtQuick

Item {
    id: root

    function playBeep() {
        if (typeof posController !== 'undefined') {
            posController.playBeep();
        }
    }

    function playError() {
        if (typeof posController !== 'undefined') {
            posController.playError();
        }
    }

    function playSuccess() {
        if (typeof posController !== 'undefined') {
            posController.playSuccess();
        }
    }
}
