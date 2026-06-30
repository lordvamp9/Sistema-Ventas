import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Popup {
    id: root
    width: 500
    height: 400
    modal: true
    focus: true
    anchors.centerIn: parent
    closePolicy: Popup.NoAutoClose

    property string paymentMethod: "Efectivo" // "Efectivo" or "Tarjeta"
    
    // Reset inputs when opened
    onOpened: {
        deliveredInput.text = ""
        deliveredInput.forceActiveFocus()
    }

    background: Rectangle {
        color: Theme.surface
        radius: 12
        border.color: Theme.border
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Text {
            text: "Confirmar Pago - " + root.paymentMethod
            font.pixelSize: Theme.sizeXL
            font.bold: true
            font.family: Theme.font
            color: Theme.textPrimary
            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        // Total
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Total a Pagar:"
                font.pixelSize: Theme.sizeLG
                font.family: Theme.font
                color: Theme.textSecondary
                Layout.fillWidth: true
            }
            Text {
                text: "$" + posController.totalAmount.toFixed(0)
                font.pixelSize: Theme.size3XL
                font.bold: true
                font.family: Theme.font
                color: Theme.brand
            }
        }

        // Efectivo Specific
        ColumnLayout {
            Layout.fillWidth: true
            visible: root.paymentMethod === "Efectivo"
            spacing: 15

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Monto Entregado:"
                    font.pixelSize: Theme.sizeLG
                    font.family: Theme.font
                    color: Theme.textSecondary
                    Layout.fillWidth: true
                }
                TextField {
                    id: deliveredInput
                    font.pixelSize: Theme.size2XL
                    font.bold: true
                    font.family: Theme.font
                    color: Theme.textPrimary
                    horizontalAlignment: TextInput.AlignRight
                    Layout.preferredWidth: 200
                    validator: RegularExpressionValidator { regularExpression: /^[0-9]+$/ }
                    background: Rectangle {
                        color: Theme.bg
                        border.color: Theme.border
                        radius: 8
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Vuelto:"
                    font.pixelSize: Theme.sizeLG
                    font.family: Theme.font
                    color: Theme.textSecondary
                    Layout.fillWidth: true
                }
                Text {
                    property double delivered: deliveredInput.text === "" ? 0 : parseFloat(deliveredInput.text)
                    property double vuelto: delivered - posController.totalAmount
                    text: vuelto >= 0 ? "$" + vuelto.toFixed(0) : "Falta dinero"
                    font.pixelSize: Theme.size2XL
                    font.bold: true
                    font.family: Theme.font
                    color: vuelto >= 0 ? Theme.success : Theme.danger
                }
            }
        }

        // Tarjeta Specific
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.paymentMethod === "Tarjeta"
            
            Text {
                text: "Por favor, pase la tarjeta por la terminal bancaria."
                font.pixelSize: Theme.sizeLG
                font.family: Theme.font
                color: Theme.textSecondary
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                wrapMode: Text.WordWrap
            }
        }

        Item { Layout.fillHeight: true }

        // Actions
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            ActionButton {
                text: "Cancelar"
                buttonColor: Theme.danger
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                onClicked: root.close()
            }

            ActionButton {
                text: "Confirmar Pago"
                buttonColor: Theme.success
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                // For efectivo, only enable if sufficient funds
                property bool canConfirm: root.paymentMethod === "Tarjeta" || 
                    (deliveredInput.text !== "" && parseFloat(deliveredInput.text) >= posController.totalAmount)
                
                opacity: canConfirm ? 1.0 : 0.5
                enabled: canConfirm

                onClicked: {
                    posController.checkout(root.paymentMethod)
                    root.close()
                }
            }
        }
    }
}
