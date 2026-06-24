import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root

    property string barcodeBuffer: ""

    // Global Key handler for laser scanner. Scanners act as keyboards ending with Enter/Return.
    Item {
        anchors.fill: parent
        focus: true 
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                if (barcodeBuffer.length > 0) {
                    posController.processScan(barcodeBuffer);
                    barcodeBuffer = "";
                }
                event.accepted = true;
            } else if (event.text !== "") {
                barcodeBuffer += event.text;
                event.accepted = true;
            }
        }
    }

    Connections {
        target: posController
        function onScanResult(success) {
            if (success) {
                audioSystemRef.playBeep();
            } else {
                audioSystemRef.playError();
            }
        }
        function onCheckoutCompleted() {
            audioSystemRef.playSuccess();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20

        RowLayout {
            Image {
                source: "https://www.svgrepo.com/show/521509/barcode.svg"
                sourceSize: Qt.size(36, 36)
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
            }
            Text {
                text: "Caja (Punto de Venta)"
                color: "#ffffff"
                font.pixelSize: 34
                font.bold: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 25

            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 70
                
                ListView {
                    anchors.fill: parent
                    anchors.margins: 20
                    model: posController.cartItems
                    spacing: 10
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 50
                        color: Qt.rgba(255, 255, 255, 0.05)
                        radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            Text { text: modelData.name; color: "#fff"; font.pixelSize: 18; Layout.fillWidth: true }
                            Text { text: "$" + modelData.price.toFixed(2); color: "#4ade80"; font.pixelSize: 18; font.bold: true }
                        }
                    }
                }
            }

            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 30
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text { text: "Total"; color: "#94a3b8"; font.pixelSize: 20 }
                    Text { 
                        text: "$" + posController.totalAmount.toFixed(2)
                        color: "#4ade80"; font.pixelSize: 48; font.bold: true 
                    }

                    Item { Layout.fillHeight: true }

                    Text {
                        text: "(Escanea un producto con la pistola laser para agregarlo)"
                        color: "#64748b"
                        font.pixelSize: 14
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        text: "Simular Pago"
                        Layout.fillWidth: true
                        height: 60
                        font.pixelSize: 20
                        font.bold: true
                        onClicked: posController.checkout()
                        background: Rectangle {
                            color: "#3b82f6"
                            radius: 12
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "#ffffff"
                            font.pixelSize: 20
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
