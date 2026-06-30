import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root

    property string barcodeBuffer: ""
    property int selectedIndex: -1
    property var audioSystemRef: null

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
                if(root.audioSystemRef) root.audioSystemRef.playBeep();
                cartList.positionViewAtEnd();
            } else {
                if(root.audioSystemRef) root.audioSystemRef.playError();
            }
        }
        function onCheckoutCompleted() {
            if(root.audioSystemRef) root.audioSystemRef.playSuccess();
            selectedIndex = -1;
            // update dashboard stats if needed, or rely on dailyStatsChanged
        }
        function onCartChanged() {
            if(posController.cartItems.length === 0) {
                selectedIndex = -1;
            }
        }
    }

    PaymentDialog {
        id: paymentDialog
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

                // Search Bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: Theme.surface
                    border.color: Theme.border
                    border.width: 1
                    radius: 12
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        Image { source: "qrc:/vamp9/Vamp9POS/src/assets/icons/barcode.svg"; Layout.preferredWidth: 24; Layout.preferredHeight: 24 }
                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "Buscar producto por nombre o escanear..."
                            font.pixelSize: Theme.sizeMD
                            font.family: Theme.font
                            background: Item {} // remove border
                            onTextChanged: {
                                if (text.length >= 2) {
                                    searchResults.model = inventorySystem.searchByName(text)
                                    searchResultsPopup.open()
                                } else {
                                    searchResultsPopup.close()
                                }
                            }
                        }
                    }

                    Popup {
                        id: searchResultsPopup
                        y: 60
                        width: parent.width
                        height: 200
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                        background: Rectangle { color: Theme.surface; border.color: Theme.border; radius: 8 }
                        ListView {
                            id: searchResults
                            anchors.fill: parent
                            clip: true
                            delegate: ItemDelegate {
                                width: ListView.view.width
                                text: modelData.name + " - $" + modelData.price
                                font.family: Theme.font
                                font.pixelSize: Theme.sizeMD
                                onClicked: {
                                    posController.processScan(modelData.barcode)
                                    searchField.text = ""
                                    searchResultsPopup.close()
                                }
                            }
                        }
                    }
                }

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: Theme.bg
                    border.color: Theme.border
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        Text { text: "Producto"; color: Theme.textSecondary; font.pixelSize: Theme.sizeMD; font.bold: true; font.family: Theme.font; Layout.fillWidth: true }
                        Text { text: "Cant."; color: Theme.textSecondary; font.pixelSize: Theme.sizeMD; font.bold: true; font.family: Theme.font; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignHCenter }
                        Text { text: "Precio"; color: Theme.textSecondary; font.pixelSize: Theme.sizeMD; font.bold: true; font.family: Theme.font; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight }
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
                        color: root.selectedIndex === index ? "#e0f2fe" : (index % 2 === 0 ? Theme.surface : Theme.bg)
                        border.color: Theme.border
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
                                color: Theme.textPrimary
                                font.pixelSize: Theme.sizeLG
                                font.family: Theme.font
                                Layout.fillWidth: true 
                            }
                            
                            RowLayout {
                                Layout.preferredWidth: 80
                                spacing: 5
                                ActionButton {
                                    Layout.preferredWidth: 24; Layout.preferredHeight: 24; radius: 12
                                    text: "-"
                                    buttonColor: Theme.border
                                    textColor: Theme.textPrimary
                                    textSize: Theme.sizeMD
                                    onClicked: posController.decreaseQty(index)
                                }
                                Text { 
                                    text: modelData.quantity
                                    color: Theme.textPrimary
                                    font.pixelSize: Theme.sizeLG
                                    font.bold: true
                                    font.family: Theme.font
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                                ActionButton {
                                    Layout.preferredWidth: 24; Layout.preferredHeight: 24; radius: 12
                                    text: "+"
                                    buttonColor: Theme.border
                                    textColor: Theme.textPrimary
                                    textSize: Theme.sizeMD
                                    onClicked: posController.increaseQty(index)
                                }
                            }

                            Text { 
                                text: "$" + (modelData.price * modelData.quantity).toFixed(0)
                                color: Theme.textPrimary
                                font.pixelSize: Theme.sizeLG
                                font.bold: true 
                                font.family: Theme.font
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
                backgroundColor: Theme.brand
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 5
                    
                    Text { text: "TOTAL A PAGAR"; color: "#e0f2fe"; font.pixelSize: Theme.sizeLG; font.bold: true; font.family: Theme.font }
                    Text { 
                        text: "$" + posController.totalAmount.toFixed(0)
                        color: "#ffffff"
                        font.pixelSize: Theme.size4XL
                        font.bold: true 
                        font.family: Theme.font
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
                            ActionButton {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                text: modelData
                                buttonColor: Theme.bg
                                textColor: Theme.textPrimary
                                textSize: Theme.size2XL
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

                    ActionButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        text: "Efectivo"
                        buttonColor: Theme.success
                        textSize: Theme.sizeXL
                        onClicked: {
                            if (posController.totalAmount > 0) {
                                paymentDialog.paymentMethod = "Efectivo"
                                paymentDialog.open()
                            }
                        }
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        text: "Tarjeta"
                        buttonColor: Theme.brandDark
                        textSize: Theme.sizeXL
                        onClicked: {
                            if (posController.totalAmount > 0) {
                                paymentDialog.paymentMethod = "Tarjeta"
                                paymentDialog.open()
                            }
                        }
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        text: "Anular Ítem"
                        buttonColor: Theme.danger
                        textSize: Theme.sizeMD
                        onClicked: {
                            if(root.selectedIndex !== -1) {
                                posController.removeCartItem(root.selectedIndex);
                            }
                        }
                    }

                    ActionButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60
                        text: "Vaciar Caja"
                        buttonColor: Theme.warning
                        textSize: Theme.sizeMD
                        onClicked: posController.clearCart()
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }

            // Input buffer display
            SolidCard {
                Layout.fillWidth: true
                height: 50
                backgroundColor: Theme.bg
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "Input Scanner/Numpad:"; color: Theme.textSecondary; font.pixelSize: Theme.sizeSM; font.family: Theme.font }
                    Text { text: root.barcodeBuffer; color: Theme.textPrimary; font.pixelSize: Theme.sizeLG; font.bold: true; font.family: Theme.font; Layout.fillWidth: true }
                    ActionButton {
                        text: "Enter"
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 30
                        textSize: Theme.sizeSM
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
