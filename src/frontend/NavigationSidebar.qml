import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Rectangle {
    id: root
    color: "#0ea5e9" // vamp9 light blue brand color
    
    signal currentViewChanged(int viewIndex)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "vamp9 POS"
            color: "#ffffff"
            font.pixelSize: 28
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 30
        }

        SidebarButton {
            text: "Dashboard"
            iconSource: "https://www.svgrepo.com/show/522137/home.svg" 
            onClicked: root.currentViewChanged(0)
        }

        SidebarButton {
            text: "Caja (POS)"
            iconSource: "https://www.svgrepo.com/show/521509/barcode.svg"
            onClicked: root.currentViewChanged(1)
        }

        SidebarButton {
            text: "Administración"
            iconSource: "https://www.svgrepo.com/show/521469/settings.svg"
            onClicked: root.currentViewChanged(2)
        }

        Item { Layout.fillHeight: true } 
    }

    component SidebarButton: Rectangle {
        id: btn
        property string text: ""
        property string iconSource: ""
        signal clicked()

        Layout.fillWidth: true
        height: 50
        radius: 8
        color: mouseArea.containsMouse ? Qt.rgba(255, 255, 255, 0.2) : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            spacing: 15

            Image {
                source: btn.iconSource
                sourceSize: Qt.size(24, 24)
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                // A bit hacky way to colorize SVG if needed, but white icons work well
            }

            Text {
                text: btn.text
                color: "#ffffff"
                font.pixelSize: 18
                font.bold: true
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btn.clicked()
        }
    }
}
