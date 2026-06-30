import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Popup {
    id: root
    property var themeRef: null
    property string method: "Efectivo"

    anchors.centerIn: Overlay.overlay
    width: 480
    height: method === "Efectivo" ? 440 : 320
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    onOpened: {
        cashInput.text = ""
        if (method === "Efectivo") cashInput.forceActiveFocus()
    }

    background: Rectangle {
        color: "#ffffff"
        radius: 16
        border.color: "#e2e8f0"
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 18

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: method === "Efectivo" ? "💵  Pago en Efectivo" : "💳  Pago con Tarjeta"
                font.pixelSize: 22; font.bold: true; font.family: "Inter"; color: "#0f172a"
                Layout.fillWidth: true
            }

            Rectangle {
                width: 32; height: 32; radius: 16
                color: xHover.containsMouse ? "#fee2e2" : "#f8fafc"
                Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 14; font.bold: true; color: "#dc2626" }
                MouseArea { id: xHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: "#e2e8f0" }

        // Total banner
        Rectangle {
            Layout.fillWidth: true
            height: 72
            radius: 12
            color: "#e0f2fe"
            border.color: "#38bdf8"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20

                Text { text: "Total a Pagar"; font.pixelSize: 15; font.family: "Inter"; color: "#0284c7"; Layout.fillWidth: true }
                Text {
                    text: posController ? ("$" + posController.totalAmount.toFixed(0)) : "$0"
                    font.pixelSize: 30; font.bold: true; font.family: "Inter"; color: "#0284c7"
                }
            }
        }

        // Cash payment fields
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12
            visible: method === "Efectivo"

            Text { text: "Monto entregado por el cliente:"; font.pixelSize: 14; font.family: "Inter"; color: "#475569" }

            TextField {
                id: cashInput
                Layout.fillWidth: true
                height: 52
                font.pixelSize: 22; font.bold: true; font.family: "Inter"
                color: "#0f172a"
                horizontalAlignment: TextInput.AlignRight
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegularExpressionValidator { regularExpression: /^\d*$/ }
                placeholderText: "0"
                background: Rectangle {
                    radius: 10
                    color: "#f8fafc"
                    border.color: cashInput.activeFocus ? "#0ea5e9" : "#e2e8f0"
                    border.width: cashInput.activeFocus ? 2 : 1
                }
            }

            // Change amount
            Rectangle {
                Layout.fillWidth: true
                height: 54
                radius: 10
                visible: cashInput.text.length > 0
                property double changeAmt: parseFloat(cashInput.text || "0") - (posController ? posController.totalAmount : 0)
                color: changeAmt >= 0 ? "#dcfce7" : "#fee2e2"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    Text {
                        text: parent.parent.changeAmt >= 0 ? "Vuelto:" : "Falta:"
                        font.pixelSize: 15; font.family: "Inter"
                        color: parent.parent.changeAmt >= 0 ? "#16a34a" : "#dc2626"
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "$" + Math.abs(parent.parent.changeAmt).toFixed(0)
                        font.pixelSize: 22; font.bold: true; font.family: "Inter"
                        color: parent.parent.changeAmt >= 0 ? "#16a34a" : "#dc2626"
                    }
                }
            }
        }

        // Card payment info
        Rectangle {
            Layout.fillWidth: true
            height: 80
            radius: 12
            visible: method === "Tarjeta"
            color: "#f8fafc"
            border.color: "#e2e8f0"

            Column {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "💳"; font.pixelSize: 28; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: "Pase la tarjeta por la terminal bancaria"; font.pixelSize: 14; font.family: "Inter"; color: "#475569" }
            }
        }

        Item { Layout.fillHeight: true }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 10
                color: cancelHover.containsMouse ? "#e2e8f0" : "#f8fafc"
                border.color: "#e2e8f0"
                Text { anchors.centerIn: parent; text: "Cancelar"; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#475569" }
                MouseArea { id: cancelHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 48
                radius: 10
                property bool canPay: {
                    if (method === "Tarjeta") return true
                    if (cashInput.text.length === 0) return false
                    return parseFloat(cashInput.text) >= (posController ? posController.totalAmount : 0)
                }
                color: canPay ? (confirmHover.containsMouse ? "#15803d" : "#16a34a") : "#94a3b8"
                Behavior on color { ColorAnimation { duration: 80 } }

                Text { anchors.centerIn: parent; text: "✓  Confirmar Pago"; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                MouseArea {
                    id: confirmHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.canPay ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (parent.canPay) {
                            posController.checkout(method)
                            root.close()
                        }
                    }
                }
            }
        }
    }
}
