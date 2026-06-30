import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs
import "components"

Item {
    id: root

    ScrollView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 30

            Text {
                text: "Configuración"
                font.pixelSize: Theme.size3XL
                font.bold: true
                font.family: Theme.font
                color: Theme.textPrimary
            }

            // General Settings
            SolidCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                backgroundColor: Theme.surface
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: "General"
                        font.pixelSize: Theme.sizeXL
                        font.bold: true
                        font.family: Theme.font
                        color: Theme.brand
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Nombre del Local:"; font.pixelSize: Theme.sizeMD; font.family: Theme.font; Layout.preferredWidth: 200 }
                        TextField { 
                            id: storeNameField
                            text: settingsManager.storeName 
                            Layout.fillWidth: true
                            font.family: Theme.font
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Nombre del Cajero:"; font.pixelSize: Theme.sizeMD; font.family: Theme.font; Layout.preferredWidth: 200 }
                        TextField { 
                            id: cashierNameField
                            text: settingsManager.cashierName 
                            Layout.fillWidth: true
                            font.family: Theme.font
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Días Umbral Stock Crítico:"; font.pixelSize: Theme.sizeMD; font.family: Theme.font; Layout.preferredWidth: 200 }
                        SpinBox {
                            id: stockDaysField
                            value: settingsManager.criticalStockDays
                            from: 1; to: 30
                            font.family: Theme.font
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }

            // Actions Settings
            SolidCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 250
                backgroundColor: Theme.surface
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15

                    Text {
                        text: "Base de Datos y Respaldo"
                        font.pixelSize: Theme.sizeXL
                        font.bold: true
                        font.family: Theme.font
                        color: Theme.brand
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        ActionButton {
                            text: "Importar Catálogo (CSV)"
                            buttonColor: Theme.brandDark
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            onClicked: importDialog.open()
                        }
                        
                        ActionButton {
                            text: "Exportar Inventario (CSV)"
                            buttonColor: Theme.brandDark
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            onClicked: exportInvDialog.open()
                        }

                        ActionButton {
                            text: "Exportar Ventas (CSV)"
                            buttonColor: Theme.success
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            onClicked: exportSalesDialog.open()
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }

            // Save Button
            ActionButton {
                text: "Guardar Configuración"
                buttonColor: Theme.success
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                textSize: Theme.sizeLG
                onClicked: {
                    settingsManager.storeName = storeNameField.text
                    settingsManager.cashierName = cashierNameField.text
                    settingsManager.criticalStockDays = stockDaysField.value
                    settingsManager.saveSettings()
                }
            }
        }
    }

    FileDialog {
        id: importDialog
        title: "Seleccionar archivo CSV para importar"
        nameFilters: ["Archivos CSV (*.csv)"]
        onAccepted: {
            if(inventorySystem.importFromCSV(selectedFile)) {
                console.log("Imported")
            }
        }
    }

    FileDialog {
        id: exportInvDialog
        title: "Guardar Inventario CSV"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Archivos CSV (*.csv)"]
        onAccepted: {
            inventorySystem.exportInventoryCSV(selectedFile)
        }
    }

    FileDialog {
        id: exportSalesDialog
        title: "Guardar Historial Ventas CSV"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Archivos CSV (*.csv)"]
        onAccepted: {
            inventorySystem.exportSalesCSV(selectedFile)
        }
    }
}
