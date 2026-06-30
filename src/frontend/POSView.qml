import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import "components"

Item {
    id: root
    property var themeRef: null
    property var audioRef: null

    // ── Scanner state ─────────────────────────────────────────
    property string barcodeBuffer: ""
    property int    selectedRow:   -1

    // USB Barcode Scanner: keyboard input ends with Enter/Return
    Keys.onPressed: function(event) {
        if (!root.visible) return
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (barcodeBuffer.length > 0) {
                posController.processScan(barcodeBuffer)
                barcodeBuffer = ""
            }
            event.accepted = true
        } else if (event.text.length > 0) {
            barcodeBuffer += event.text
            event.accepted = true
        }
    }
    focus: true
    onVisibleChanged: { if (visible) forceActiveFocus() }

    // ── C++ backend signals ───────────────────────────────────
    Connections {
        target: posController
        function onScanResult(success) {
            if (success) {
                if (root.audioRef) root.audioRef.playBeep()
                cartList.positionViewAtEnd()
            } else {
                if (root.audioRef) root.audioRef.playError()
            }
        }
        function onCheckoutCompleted() {
            if (root.audioRef) root.audioRef.playSuccess()
            root.selectedRow = -1
        }
        function onCartChanged() {
            if (posController.cartItems.length === 0) root.selectedRow = -1
        }
    }

    PaymentDialog {
        id: paymentDialog
        themeRef: root.themeRef
    }

    // ── Layout ────────────────────────────────────────────────
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // ════════════════════════════════════════════════════
        // LEFT: Cart / Ticket
        // ════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: "#ffffff"
            border.color: "#e2e8f0"
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Search bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 52
                    color: "#f8fafc"
                    border.color: "#e2e8f0"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Text { text: "🔍"; font.pixelSize: 16 }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            placeholderText: "Buscar producto por nombre o escanear código de barras..."
                            font.pixelSize: 14
                            font.family: "Inter"
                            color: "#0f172a"
                            background: Rectangle { color: "transparent" }
                            onTextChanged: {
                                if (text.length >= 2) {
                                    searchResultsModel.clear()
                                    var results = inventorySystem.searchByName(text)
                                    for (var i = 0; i < results.length; i++) {
                                        searchResultsModel.append(results[i])
                                    }
                                    searchPopup.open()
                                } else {
                                    searchPopup.close()
                                }
                            }
                        }
                    }

                    // Search dropdown popup
                    Popup {
                        id: searchPopup
                        y: parent.height
                        x: 0
                        width: parent.width
                        height: Math.min(searchResultsModel.count * 44 + 8, 220)
                        padding: 4
                        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
                        background: Rectangle { color: "#ffffff"; border.color: "#e2e8f0"; radius: 8 }

                        ListModel { id: searchResultsModel }

                        ListView {
                            anchors.fill: parent
                            model: searchResultsModel
                            clip: true
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 44
                                color: siHover.containsMouse ? "#e0f2fe" : "transparent"
                                radius: 6
                                Behavior on color { ColorAnimation { duration: 80 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    Text { text: model.name;  font.pixelSize: 14; font.family: "Inter"; color: "#0f172a"; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: "$" + model.price; font.pixelSize: 13; font.bold: true; font.family: "Inter"; color: "#0ea5e9" }
                                }

                                MouseArea {
                                    id: siHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        posController.processScan(model.barcode)
                                        searchField.text = ""
                                        searchPopup.close()
                                    }
                                }
                            }
                        }
                    }
                }

                // Column headers
                Rectangle {
                    Layout.fillWidth: true
                    height: 38
                    color: "#f8fafc"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 0
                        Text { text: "Producto";  font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.fillWidth: true }
                        Text { text: "Cant.";     font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 90;  horizontalAlignment: Text.AlignHCenter }
                        Text { text: "Subtotal";  font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#e2e8f0" }

                // Cart items list
                ListView {
                    id: cartList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: posController ? posController.cartItems : []
                    spacing: 0

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 56
                        color: root.selectedRow === index ? "#e0f2fe" : (index % 2 === 0 ? "#ffffff" : "#f8fafc")
                        Behavior on color { ColorAnimation { duration: 80 } }

                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#e2e8f0" }

                        // Selected indicator
                        Rectangle {
                            visible: root.selectedRow === index
                            width: 3; height: parent.height
                            color: "#0ea5e9"
                            anchors.left: parent.left
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 14
                            spacing: 0

                            Text {
                                text: modelData.name
                                font.pixelSize: 14; font.family: "Inter"; color: "#0f172a"
                                Layout.fillWidth: true; elide: Text.ElideRight
                            }

                            // Qty controls
                            RowLayout {
                                Layout.preferredWidth: 90
                                spacing: 6
                                Layout.alignment: Qt.AlignHCenter

                                Rectangle {
                                    width: 26; height: 26; radius: 6
                                    color: minusHover.containsMouse ? "#e2e8f0" : "#f8fafc"
                                    border.color: "#e2e8f0"
                                    Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 16; font.bold: true; color: "#475569" }
                                    MouseArea { id: minusHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: posController.decreaseQty(index) }
                                }

                                Text {
                                    text: modelData.quantity
                                    font.pixelSize: 15; font.bold: true; font.family: "Inter"; color: "#0f172a"
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.preferredWidth: 24
                                }

                                Rectangle {
                                    width: 26; height: 26; radius: 6
                                    color: plusHover.containsMouse ? "#e0f2fe" : "#f8fafc"
                                    border.color: "#0ea5e9"
                                    Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 16; font.bold: true; color: "#0ea5e9" }
                                    MouseArea { id: plusHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: posController.increaseQty(index) }
                                }
                            }

                            Text {
                                text: "$" + (modelData.price * modelData.quantity).toFixed(0)
                                font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#0f172a"
                                Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight
                            }
                        }

                        MouseArea { anchors.fill: parent; onClicked: root.selectedRow = index }
                    }

                    // Empty cart state
                    Column {
                        anchors.centerIn: parent
                        visible: cartList.count === 0
                        spacing: 8

                        Text { text: "🛒"; font.pixelSize: 40; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Carrito vacío"; font.pixelSize: 16; font.family: "Inter"; color: "#94a3b8"; anchors.horizontalCenter: parent.horizontalCenter }
                        Text { text: "Escanea o busca un producto"; font.pixelSize: 13; font.family: "Inter"; color: "#94a3b8"; anchors.horizontalCenter: parent.horizontalCenter }
                    }
                }

                // Footer bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    color: "#f8fafc"
                    border.color: "#e2e8f0"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14

                        Text {
                            text: "⌨  Escáner USB listo" + (root.barcodeBuffer.length > 0 ? "  ·  Buffer: " + root.barcodeBuffer : "")
                            font.pixelSize: 12; font.family: "Inter"; color: "#94a3b8"
                            Layout.fillWidth: true
                        }
                        Text {
                            text: cartList.count + " línea(s)"
                            font.pixelSize: 12; font.family: "Inter"; color: "#475569"
                        }
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════
        // RIGHT: Total + Numpad + Actions
        // ════════════════════════════════════════════════════
        ColumnLayout {
            Layout.fillHeight: true
            width: 320
            spacing: 12

            // Total display
            Rectangle {
                Layout.fillWidth: true
                height: 110
                radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#0369a1" }
                    GradientStop { position: 1.0; color: "#0ea5e9" }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 4
                    Text { text: "TOTAL A PAGAR"; font.pixelSize: 11; font.family: "Inter"; color: "#7dd3fc"; letterSpacing: 2 }
                    Text {
                        text: posController ? ("$" + posController.totalAmount.toLocaleString(Qt.locale("es-CL"), "f", 0)) : "$0"
                        font.pixelSize: 36; font.bold: true; font.family: "Inter"; color: "#ffffff"
                        Layout.alignment: Qt.AlignRight
                        elide: Text.ElideRight; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight
                    }
                }
            }

            // Numpad
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#ffffff"
                border.color: "#e2e8f0"
                border.width: 1

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    columns: 3
                    rowSpacing: 8
                    columnSpacing: 8

                    Repeater {
                        model: ["7","8","9","4","5","6","1","2","3","0","00","⌫"]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: numKeyArea.pressed ? "#e0f2fe" : (numKeyArea.containsMouse ? "#f8fafc" : "#ffffff")
                            border.color: "#e2e8f0"
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 60 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 22; font.bold: true; font.family: "Inter"; color: "#0f172a"
                            }

                            MouseArea {
                                id: numKeyArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData === "⌫") {
                                        if (root.barcodeBuffer.length > 0)
                                            root.barcodeBuffer = root.barcodeBuffer.slice(0, -1)
                                    } else {
                                        root.barcodeBuffer += modelData
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Enter/scan button
            Rectangle {
                Layout.fillWidth: true
                height: 44
                radius: 10
                color: enterArea.pressed ? "#0284c7" : (enterArea.containsMouse ? "#0ea5e9" : "#38bdf8")
                Behavior on color { ColorAnimation { duration: 80 } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    Text { text: "⏎"; font.pixelSize: 16; color: "#fff" }
                    Text { text: "Procesar Código"; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#fff" }
                }

                MouseArea {
                    id: enterArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.barcodeBuffer.length > 0) {
                            posController.processScan(root.barcodeBuffer)
                            root.barcodeBuffer = ""
                        }
                    }
                }
            }

            // Payment buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ActionButton {
                    text: "💵  Efectivo"
                    btnColor: "#16a34a"
                    textSize: 15
                    Layout.fillWidth: true
                    height: 56
                    btnRadius: 10
                    onClicked: {
                        if (posController && posController.totalAmount > 0) {
                            paymentDialog.method = "Efectivo"
                            paymentDialog.open()
                        }
                    }
                }

                ActionButton {
                    text: "💳  Tarjeta"
                    btnColor: "#0284c7"
                    textSize: 15
                    Layout.fillWidth: true
                    height: 56
                    btnRadius: 10
                    onClicked: {
                        if (posController && posController.totalAmount > 0) {
                            paymentDialog.method = "Tarjeta"
                            paymentDialog.open()
                        }
                    }
                }
            }

            // Utility buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ActionButton {
                    text: "Anular ítem"
                    btnColor: "#dc2626"
                    textSize: 13
                    Layout.fillWidth: true
                    height: 40
                    btnRadius: 8
                    enabled: root.selectedRow >= 0
                    onClicked: {
                        posController.removeCartItem(root.selectedRow)
                        root.selectedRow = -1
                    }
                }

                ActionButton {
                    text: "Vaciar caja"
                    btnColor: "#d97706"
                    textSize: 13
                    Layout.fillWidth: true
                    height: 40
                    btnRadius: 8
                    onClicked: posController.clearCart()
                }
            }
        }
    }
}
