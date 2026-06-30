import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root

    property var audioSystemRef: null
    
    // Simple mock model for demonstration, in a real app this would come from a QAbstractTableModel in C++
    ListModel {
        id: productModel
    }

    function loadProducts() {
        productModel.clear();
        var prods = inventorySystem.searchByName("");
        for(var i=0; i<prods.length; ++i) {
            productModel.append(prods[i]);
        }
    }

    Component.onCompleted: loadProducts()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 25
        spacing: 20

        Text {
            text: "Administración de Inventario"
            font.pixelSize: Theme.size3XL
            font.bold: true
            font.family: Theme.font
            color: Theme.textPrimary
        }

        SolidCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            backgroundColor: Theme.surface

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    TextField {
                        id: searchField
                        placeholderText: "Buscar producto..."
                        font.pixelSize: Theme.sizeMD
                        font.family: Theme.font
                        Layout.preferredWidth: 300
                        background: Rectangle { color: Theme.bg; border.color: Theme.border; radius: 8 }
                        onTextChanged: {
                            productModel.clear()
                            var prods = inventorySystem.searchByName(text)
                            for(var i=0; i<prods.length; ++i) {
                                productModel.append(prods[i])
                            }
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    ActionButton {
                        text: "Nuevo Producto"
                        buttonColor: Theme.brand
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 45
                        onClicked: newProductDrawer.open()
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                // Headers
                RowLayout {
                    Layout.fillWidth: true
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    Text { text: "ID"; font.bold:true; font.family: Theme.font; Layout.preferredWidth: 40 }
                    Text { text: "Nombre"; font.bold:true; font.family: Theme.font; Layout.fillWidth: true }
                    Text { text: "Código"; font.bold:true; font.family: Theme.font; Layout.preferredWidth: 150 }
                    Text { text: "Precio"; font.bold:true; font.family: Theme.font; Layout.preferredWidth: 100 }
                    Text { text: "Acciones"; font.bold:true; font.family: Theme.font; Layout.preferredWidth: 150 }
                }

                ListView {
                    id: productList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: productModel
                    spacing: 5
                    
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 50
                        color: index % 2 === 0 ? Theme.surface : Theme.bg
                        border.color: Theme.border
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            
                            Text { text: model.id; font.family: Theme.font; Layout.preferredWidth: 40 }
                            Text { text: model.name; font.family: Theme.font; Layout.fillWidth: true }
                            Text { text: model.barcode; font.family: Theme.font; Layout.preferredWidth: 150 }
                            Text { text: "$" + model.price; font.family: Theme.font; Layout.preferredWidth: 100 }
                            
                            RowLayout {
                                Layout.preferredWidth: 150
                                spacing: 10
                                
                                ActionButton {
                                    text: "Reponer"
                                    buttonColor: Theme.success
                                    textSize: Theme.sizeSM
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 30
                                    onClicked: {
                                        restockPopup.productId = model.id
                                        restockPopup.productName = model.name
                                        restockPopup.open()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // New Product Drawer
    Drawer {
        id: newProductDrawer
        width: 400
        height: parent.height
        edge: Qt.RightEdge
        
        background: Rectangle {
            color: Theme.surface
            border.color: Theme.border
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            Text { text: "Nuevo Producto"; font.pixelSize: Theme.size2XL; font.bold: true; font.family: Theme.font }
            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

            TextField { id: pName; placeholderText: "Nombre"; Layout.fillWidth: true }
            TextField { id: pCat; placeholderText: "Categoría"; Layout.fillWidth: true }
            TextField { id: pBar; placeholderText: "Código de Barras"; Layout.fillWidth: true }
            TextField { id: pPrice; placeholderText: "Precio ($)"; Layout.fillWidth: true; validator: RegularExpressionValidator { regularExpression: /^[0-9]+$/ } }
            TextField { id: pStock; placeholderText: "Stock Inicial"; Layout.fillWidth: true; validator: RegularExpressionValidator { regularExpression: /^[0-9]+$/ } }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                ActionButton {
                    text: "Cancelar"
                    buttonColor: Theme.border
                    textColor: Theme.textPrimary
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    onClicked: newProductDrawer.close()
                }
                ActionButton {
                    text: "Guardar"
                    buttonColor: Theme.brand
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    onClicked: {
                        if (pName.text !== "" && pBar.text !== "") {
                            inventorySystem.addNewProduct(pName.text, pCat.text, pBar.text, parseFloat(pPrice.text || "0"), parseInt(pStock.text || "0"))
                            root.loadProducts()
                            pName.text = ""; pCat.text = ""; pBar.text = ""; pPrice.text = ""; pStock.text = "";
                            newProductDrawer.close()
                        }
                    }
                }
            }
        }
    }

    // Restock Popup
    Popup {
        id: restockPopup
        width: 300
        height: 250
        anchors.centerIn: parent
        modal: true
        focus: true
        
        property int productId: -1
        property string productName: ""

        background: Rectangle { color: Theme.surface; radius: 12; border.color: Theme.border }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text { text: "Reponer Stock"; font.pixelSize: Theme.sizeXL; font.bold: true; font.family: Theme.font }
            Text { text: restockPopup.productName; font.pixelSize: Theme.sizeMD; font.family: Theme.font; color: Theme.textSecondary }
            
            TextField {
                id: restockQty
                placeholderText: "Cantidad a agregar"
                validator: RegularExpressionValidator { regularExpression: /^[0-9]+$/ }
                Layout.fillWidth: true
                font.pixelSize: Theme.sizeLG
                font.family: Theme.font
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                ActionButton {
                    text: "Cancelar"
                    buttonColor: Theme.border
                    textColor: Theme.textPrimary
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    onClicked: restockPopup.close()
                }
                ActionButton {
                    text: "Confirmar"
                    buttonColor: Theme.success
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    onClicked: {
                        if(restockQty.text !== "") {
                            inventorySystem.restockProduct(restockPopup.productId, parseInt(restockQty.text))
                            restockQty.text = ""
                            restockPopup.close()
                            root.loadProducts()
                        }
                    }
                }
            }
        }
    }
}
