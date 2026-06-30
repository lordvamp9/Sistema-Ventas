import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs

Item {
    id: root
    property var themeRef: null

    ScrollView {
        anchors.fill: parent
        anchors.margins: 24
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AsNeeded
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: parent.width
            spacing: 20

            Text {
                text: "Configuración"
                font.pixelSize: 30; font.bold: true; font.family: "Inter"; color: "#0f172a"
            }

            // ── General ───────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: genLayout.implicitHeight + 40
                radius: 12; color: "#ffffff"; border.color: "#e2e8f0"; border.width: 1

                ColumnLayout {
                    id: genLayout
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    Text { text: "General"; font.pixelSize: 17; font.bold: true; font.family: "Inter"; color: "#0ea5e9" }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#e2e8f0" }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Nombre del Local"; font.pixelSize: 14; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 220 }
                        TextField {
                            id: storeNameInput
                            text: settingsManager ? settingsManager.storeName : ""
                            font.pixelSize: 14; font.family: "Inter"
                            height: 40; Layout.fillWidth: true
                            background: Rectangle { radius: 8; color: "#f8fafc"; border.color: "#e2e8f0" }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Nombre del Cajero"; font.pixelSize: 14; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 220 }
                        TextField {
                            id: cashierInput
                            text: settingsManager ? settingsManager.cashierName : ""
                            font.pixelSize: 14; font.family: "Inter"
                            height: 40; Layout.fillWidth: true
                            background: Rectangle { radius: 8; color: "#f8fafc"; border.color: "#e2e8f0" }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Días umbral stock crítico"; font.pixelSize: 14; font.family: "Inter"; color: "#475569"; Layout.preferredWidth: 220 }
                        SpinBox {
                            id: criticalDaysInput
                            from: 1; to: 30
                            value: settingsManager ? settingsManager.criticalStockDays : 3
                            font.pixelSize: 14; font.family: "Inter"
                        }
                    }
                }
            }

            // ── Data management ───────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: dataLayout.implicitHeight + 40
                radius: 12; color: "#ffffff"; border.color: "#e2e8f0"; border.width: 1

                ColumnLayout {
                    id: dataLayout
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 14

                    Text { text: "Datos e Inventario"; font.pixelSize: 17; font.bold: true; font.family: "Inter"; color: "#0ea5e9" }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#e2e8f0" }

                    Text {
                        text: "Importa catálogo desde CSV (columnas: nombre, categoría, barcode, precio, stock) o exporta el inventario actual y el historial de ventas."
                        font.pixelSize: 13; font.family: "Inter"; color: "#475569"
                        wrapMode: Text.WordWrap; Layout.fillWidth: true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            height: 42; Layout.preferredWidth: 190; radius: 10
                            color: impHover.containsMouse ? "#0284c7" : "#0369a1"
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Text { anchors.centerIn: parent; text: "⬆  Importar CSV"; font.pixelSize: 13; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                            MouseArea { id: impHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: importDialog.open() }
                        }

                        Rectangle {
                            height: 42; Layout.preferredWidth: 200; radius: 10
                            color: expInvHover.containsMouse ? "#0284c7" : "#0ea5e9"
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Text { anchors.centerIn: parent; text: "⬇  Exportar Inventario"; font.pixelSize: 13; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                            MouseArea { id: expInvHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: exportInvDialog.open() }
                        }

                        Rectangle {
                            height: 42; Layout.preferredWidth: 180; radius: 10
                            color: expSalHover.containsMouse ? "#15803d" : "#16a34a"
                            Behavior on color { ColorAnimation { duration: 80 } }
                            Text { anchors.centerIn: parent; text: "📊  Exportar Ventas"; font.pixelSize: 13; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                            MouseArea { id: expSalHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: exportSalesDialog.open() }
                        }
                    }
                }
            }

            // ── Save button ───────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 10
                color: saveHover.containsMouse ? "#15803d" : "#16a34a"
                Behavior on color { ColorAnimation { duration: 80 } }

                Text { anchors.centerIn: parent; text: "✓  Guardar Configuración"; font.pixelSize: 15; font.bold: true; font.family: "Inter"; color: "#ffffff" }
                MouseArea {
                    id: saveHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (settingsManager) {
                            settingsManager.storeName       = storeNameInput.text
                            settingsManager.cashierName     = cashierInput.text
                            settingsManager.criticalStockDays = criticalDaysInput.value
                            settingsManager.saveSettings()
                        }
                    }
                }
            }
        }
    }

    // ── File Dialogs ──────────────────────────────────────────
    FileDialog {
        id: importDialog
        title: "Importar Catálogo CSV"
        nameFilters: ["Archivos CSV (*.csv)"]
        onAccepted: inventorySystem.importFromCSV(selectedFile)
    }

    FileDialog {
        id: exportInvDialog
        title: "Exportar Inventario"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Archivos CSV (*.csv)"]
        defaultSuffix: "csv"
        onAccepted: inventorySystem.exportInventoryCSV(selectedFile)
    }

    FileDialog {
        id: exportSalesDialog
        title: "Exportar Historial de Ventas"
        fileMode: FileDialog.SaveFile
        nameFilters: ["Archivos CSV (*.csv)"]
        defaultSuffix: "csv"
        onAccepted: inventorySystem.exportSalesCSV(selectedFile)
    }
}
