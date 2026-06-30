import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root

    property string barcodeBuffer: ""
    property int selectedIndex: -1

    // Global Key handler for laser scanner
    // Laser scanners act as keyboards sending keys fast, ending with Return.
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
                // Auto scroll to bottom
                cartList.positionViewAtEnd();
            } else {
                audioSystemRef.playError();
            }
        }
        function onCheckoutCompleted() {
            audioSystemRef.playSuccess();
            selectedIndex = -1;
        }
        function onCartChanged() {
            if(posController.cartItems.length === 0) {
                selectedIndex = -1;
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Left Panel: Ticket / Cart
        SolidCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 60
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 0
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    color: "#f8fafc"
                    border.color: "#e2e8f0"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        Text { text: "Producto"; color: "#475569"; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true }
                        Text { text: "Precio"; color: "#475569"; font.pixelSize: 18; font.bold: true; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight }
                    }
                }

                ListView {
                    id: cartList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: posController.cartItems
                    clip: true
                    
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 60
                        color: root.selectedIndex === index ? "#e0f2fe" : (index % 2 === 0 ? "#ffffff" : "#f8fafc")
                        border.color: "#e2e8f0"
                        border.width: root.selectedIndex === index ? 2 : 1
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.selectedIndex = index
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            Text { 
                                text: modelData.name
                                color: "#0f172a"
                                font.pixelSize: 20
                                Layout.fillWidth: true 
                            }
                            Text { 
                                text: "$" + modelData.price.toFixed(0)
                                color: "#0f172a"
                                font.pixelSize: 20
                                font.bold: true 
                                Layout.preferredWidth: 100
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }
        }

        // Right Panel: Controls
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 40
            spacing: 20

            // Total Display
            SolidCard {
                Layout.fillWidth: true
                height: 120
                backgroundColor: "#0ea5e9"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 5
                    
                    Text { text: "TOTAL A PAGAR"; color: "#e0f2fe"; font.pixelSize: 18; font.bold: true }
                    Text { 
                        text: "$" + posController.totalAmount.toFixed(0)
                        color: "#ffffff"
                        font.pixelSize: 48
                        font.bold: true 
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }

            // Numpad and Actions
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20

                // Numpad
                SolidCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 60
                    
                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        columns: 3
                        rowSpacing: 10
                        columnSpacing: 10

                        Repeater {
                            model: ["7", "8", "9", "4", "5", "6", "1", "2", "3", "0", "00", "C"]
                            Button {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: modelData
                                font.pixelSize: 28
                                font.bold: true
                                background: Rectangle {
                                    color: pressed ? "#e2e8f0" : "#f8fafc"
                                    border.color: "#cbd5e1"
                                    radius: 8
                                }
                                onClicked: {
                                    if (modelData === "C") {
                                        root.barcodeBuffer = "";
                                    } else {
                                        root.barcodeBuffer += modelData;
                                    }
                                }
                            }
                        }
                    }
                }

                // Actions
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 40
                    spacing: 10

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        text: "Efectivo"
                        font.pixelSize: 20
                        font.bold: true
                        onClicked: posController.checkout()
                        background: Rectangle { color: "#10b981"; radius: 8 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 20 }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        text: "Tarjeta"
                        font.pixelSize: 20
                        font.bold: true
                        onClicked: posController.checkout()
                        background: Rectangle { color: "#3b82f6"; radius: 8 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 20 }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        text: "Anular Ítem"
                        font.pixelSize: 16
                        font.bold: true
                        onClicked: {
                            if(root.selectedIndex !== -1) {
                                posController.removeCartItem(root.selectedIndex);
                            }
                        }
                        background: Rectangle { color: "#ef4444"; radius: 8 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 16 }
                    }

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        text: "Vaciar Caja"
                        font.pixelSize: 16
                        font.bold: true
                        onClicked: posController.clearCart()
                        background: Rectangle { color: "#f59e0b"; radius: 8 }
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter; font.pixelSize: 16 }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }

            // Input buffer display
            SolidCard {
                Layout.fillWidth: true
                height: 50
                backgroundColor: "#f1f5f9"
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Input Scanner/Numpad:"; color: "#64748b"; font.pixelSize: 14 }
                    Text { text: root.barcodeBuffer; color: "#0f172a"; font.pixelSize: 18; font.bold: true; Layout.fillWidth: true }
                    Button {
                        text: "Enter"
                        onClicked: {
                            if (root.barcodeBuffer.length > 0) {
                                posController.processScan(root.barcodeBuffer);
                                root.barcodeBuffer = "";
                            }
                        }
                    }
                }
            }

        }
    }
}
