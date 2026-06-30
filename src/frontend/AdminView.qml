import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20

        RowLayout {
            Image {
                source: "https://www.svgrepo.com/show/521469/settings.svg"
                sourceSize: Qt.size(36, 36)
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
            }
            Text {
                text: "Administración de Productos"
                color: "#0f172a"
                font.pixelSize: 34
                font.bold: true
            }
        }

        SolidCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 400
            
            GridLayout {
                anchors.fill: parent
                anchors.margins: 30
                columns: 2
                rowSpacing: 20
                columnSpacing: 20

                Text { text: "Nombre del Producto:"; color: "#475569"; font.pixelSize: 16; font.bold: true }
                TextField { id: tfName; Layout.fillWidth: true; placeholderText: "Ej. Teclado Mecanico" }

                Text { text: "Categoría:"; color: "#475569"; font.pixelSize: 16; font.bold: true }
                ComboBox { 
                    id: cbCategory; Layout.fillWidth: true; 
                    model: ["Electronica", "Accesorios", "Audio", "Cables", "Otros"]
                }

                Text { text: "Código de Barras:"; color: "#475569"; font.pixelSize: 16; font.bold: true }
                TextField { id: tfBarcode; Layout.fillWidth: true; placeholderText: "Ej. 7501234567890" }

                Text { text: "Precio ($):"; color: "#475569"; font.pixelSize: 16; font.bold: true }
                TextField { id: tfPrice; Layout.fillWidth: true; placeholderText: "0.00"; validator: DoubleValidator {bottom: 0} }

                Text { text: "Stock Inicial:"; color: "#475569"; font.pixelSize: 16; font.bold: true }
                TextField { id: tfStock; Layout.fillWidth: true; placeholderText: "0"; validator: IntValidator {bottom: 0} }

                Item { Layout.fillWidth: true } 
                Button {
                    text: "Guardar Producto"
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        let ok = inventorySystem.addNewProduct(tfName.text, cbCategory.currentText, tfBarcode.text, parseFloat(tfPrice.text), parseInt(tfStock.text));
                        if(ok) {
                            tfName.text = ""; tfBarcode.text = ""; tfPrice.text = ""; tfStock.text = "";
                            audioSystemRef.playSuccess();
                        }
                    }
                    background: Rectangle { color: "#0ea5e9"; radius: 8 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; padding: 10 }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
