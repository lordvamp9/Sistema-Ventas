import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import "components"

Item {
    id: root
    property var themeRef: null

    ListModel { id: productModel }

    function loadProducts(filter) {
        productModel.clear()
        var list = inventorySystem.searchByName(filter || "")
        for (var i = 0; i < list.length; i++) productModel.append(list[i])
    }

    Component.onCompleted: loadProducts("")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ── Header ────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Inventario"
                font.pixelSize: 30; font.bold: true; font.family: "Inter"; color: "#0f172a"
                Layout.fillWidth: true
            }

            Rectangle {
                width: 170; height: 40; radius: 10
                color: addBtnHover.containsMouse ? "#0284c7" : "#0ea5e9"
                Behavior on color { ColorAnimation { duration: 80 } }

                Text { anchors.centerIn: parent; text: "+ Nuevo Producto"; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                MouseArea { id: addBtnHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: newProductDrawer.open() }
            }
        }

        // ── Search toolbar ────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            height: 48
            radius: 10
            color: "#ffffff"
            border.color: "#e2e8f0"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 10

                Text { text: "🔍"; font.pixelSize: 15 }
                TextField {
                    id: searchBox
                    Layout.fillWidth: true
                    placeholderText: "Buscar producto..."
                    font.pixelSize: 14; font.family: "Inter"
                    background: Rectangle { color: "transparent" }
                    onTextChanged: loadProducts(text)
                }
            }
        }

        // ── Products table ────────────────────────────────────
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

                // Table header row
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#f8fafc"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 0
                        Text { text: "#";         font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 40 }
                        Text { text: "Nombre";    font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.fillWidth: true }
                        Text { text: "Categoría"; font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 130 }
                        Text { text: "Código";    font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 120 }
                        Text { text: "Precio";    font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 90;  horizontalAlignment: Text.AlignRight }
                        Text { text: "Stock";     font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 60;  horizontalAlignment: Text.AlignRight }
                        Text { text: "Acciones";  font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignHCenter }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#e2e8f0" }

                ListView {
                    id: productList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: productModel
                    spacing: 0

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 50
                        color: index % 2 === 0 ? "#ffffff" : "#f8fafc"
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#e2e8f0" }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 0

                            Text { text: model.id;       font.pixelSize: 13; font.family: "Inter"; color: "#94a3b8"; Layout.preferredWidth: 40 }
                            Text { text: model.name;     font.pixelSize: 14; font.family: "Inter"; color: "#0f172a"; Layout.fillWidth: true; elide: Text.ElideRight }
                            Text { text: model.category || "—"; font.pixelSize: 13; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 130; elide: Text.ElideRight }
                            Text { text: model.barcode;  font.pixelSize: 13; font.family: "Inter"; color: "#94a3b8"; Layout.preferredWidth: 120; elide: Text.ElideRight }
                            Text { text: "$" + model.price; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#0f172a"; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                            Text { text: ""; font.pixelSize: 13; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight }

                            RowLayout {
                                Layout.preferredWidth: 100
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6

                                Rectangle {
                                    width: 72; height: 30; radius: 6
                                    color: repHover.containsMouse ? "#15803d" : "#16a34a"
                                    Behavior on color { ColorAnimation { duration: 80 } }
                                    Text { anchors.centerIn: parent; text: "Reponer"; font.pixelSize: 12; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                                    MouseArea {
                                        id: repHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            restockPopup.targetId   = model.id
                                            restockPopup.targetName = model.name
                                            restockPopup.open()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: productList.count === 0
                        text: "No hay productos"
                        font.pixelSize: 15; font.family: "Inter"; color: "#94a3b8"
                    }
                }
            }
        }
    }

    // ── New Product Drawer ────────────────────────────────────
    Drawer {
        id: newProductDrawer
        width: 380
        height: root.height
        edge: Qt.RightEdge
        background: Rectangle { color: "#ffffff"; border.color: "#e2e8f0" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            Text { text: "Nuevo Producto"; font.pixelSize: 22; font.bold: true; font.family: "Inter"; color: "#0f172a" }
            Rectangle { Layout.fillWidth: true; height: 1; color: "#e2e8f0" }

            TextField { id: fName;     Layout.fillWidth: true; height: 44; placeholderText: "Nombre *";           font.pixelSize: 14; font.family: "Inter"; background: Rectangle { radius: 8; color: "#f8fafc"; border.color: "#e2e8f0" } }
            TextField { id: fCategory; Layout.fillWidth: true; height: 44; placeholderText: "Categoría";          font.pixelSize: 14; font.family: "Inter"; background: Rectangle { radius: 8; color: "#f8fafc"; border.color: "#e2e8f0" } }
            TextField { id: fBarcode;  Layout.fillWidth: true; height: 44; placeholderText: "Código de Barras *"; font.pixelSize: 14; font.family: "Inter"; background: Rectangle { radius: 8; color: "#f8fafc"; border.color: "#e2e8f0" } }
            TextField {
                id: fPrice
                Layout.fillWidth: true; height: 44
                placeholderText: "Precio ($) *"
                font.pixelSize: 14; font.family: "Inter"
                inputMethodHints: Qt.ImhDigitsOnly
                background: Rectangle { radius: 8; color: "#f8fafc"; border.color: "#e2e8f0" }
            }
            TextField {
                id: fStock
                Layout.fillWidth: true; height: 44
                placeholderText: "Stock inicial"
                font.pixelSize: 14; font.family: "Inter"
                inputMethodHints: Qt.ImhDigitsOnly
                background: Rectangle { radius: 8; color: "#f8fafc"; border.color: "#e2e8f0" }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 10
                    color: cancelDrwHover.containsMouse ? "#e2e8f0" : "#f8fafc"
                    border.color: "#e2e8f0"
                    Text { anchors.centerIn: parent; text: "Cancelar"; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#475569" }
                    MouseArea { id: cancelDrwHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: newProductDrawer.close() }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 44; radius: 10
                    color: saveDrwHover.containsMouse ? "#0284c7" : "#0ea5e9"
                    Behavior on color { ColorAnimation { duration: 80 } }
                    Text { anchors.centerIn: parent; text: "Guardar"; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                    MouseArea {
                        id: saveDrwHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (fName.text.length > 0 && fBarcode.text.length > 0) {
                                inventorySystem.addNewProduct(
                                    fName.text, fCategory.text, fBarcode.text,
                                    parseFloat(fPrice.text || "0"),
                                    parseInt(fStock.text || "0")
                                )
                                fName.text = ""; fCategory.text = ""; fBarcode.text = ""; fPrice.text = ""; fStock.text = ""
                                loadProducts(searchBox.text)
                                newProductDrawer.close()
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Restock Popup ─────────────────────────────────────────
    Popup {
        id: restockPopup
        property int    targetId:   -1
        property string targetName: ""

        anchors.centerIn: Overlay.overlay
        width: 320; height: 230
        modal: true; focus: true
        background: Rectangle { color: "#ffffff"; radius: 14; border.color: "#e2e8f0" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            Text { text: "Reponer Stock"; font.pixelSize: 20; font.bold: true; font.family: "Inter"; color: "#0f172a" }
            Text { text: restockPopup.targetName; font.pixelSize: 13; font.family: "Inter"; color: "#475569"; elide: Text.ElideRight; Layout.fillWidth: true }

            TextField {
                id: restockQtyField
                Layout.fillWidth: true; height: 48
                placeholderText: "Cantidad a agregar"
                font.pixelSize: 18; font.family: "Inter"
                horizontalAlignment: TextInput.AlignRight
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegularExpressionValidator { regularExpression: /^\d+$/ }
                background: Rectangle { radius: 8; color: "#f8fafc"; border.color: "#e2e8f0" }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true; height: 42; radius: 8
                    color: cancelRsHover.containsMouse ? "#e2e8f0" : "#f8fafc"
                    border.color: "#e2e8f0"
                    Text { anchors.centerIn: parent; text: "Cancelar"; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#475569" }
                    MouseArea { id: cancelRsHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: restockPopup.close() }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 42; radius: 8
                    color: confirmRsHover.containsMouse ? "#15803d" : "#16a34a"
                    Behavior on color { ColorAnimation { duration: 80 } }
                    Text { anchors.centerIn: parent; text: "Confirmar"; font.pixelSize: 14; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                    MouseArea {
                        id: confirmRsHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (restockQtyField.text.length > 0) {
                                inventorySystem.restockProduct(restockPopup.targetId, parseInt(restockQtyField.text))
                                restockQtyField.text = ""
                                restockPopup.close()
                                loadProducts(searchBox.text)
                            }
                        }
                    }
                }
            }
        }
    }

    FileDialog {
        id: importDialog
        title: "Importar Catálogo CSV"
        nameFilters: ["CSV (*.csv)"]
        onAccepted: inventorySystem.importFromCSV(selectedFile)
    }
}
