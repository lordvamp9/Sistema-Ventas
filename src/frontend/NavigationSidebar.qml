import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "components"

Rectangle {
    id: root
    color: Theme.brand // vamp9 light blue brand color
    
    signal currentViewChanged(var viewIndex)
    property int activeIndex: 0

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        Text {
            text: "vamp9 POS"
            color: "#ffffff"
            font.pixelSize: 28
            font.bold: true
            font.family: Theme.font
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 30
        }

        SidebarButton {
            text: "Dashboard"
            iconSource: "qrc:/vamp9/Vamp9POS/src/assets/icons/home.svg" 
            isActive: root.activeIndex === 0
            onClicked: { root.activeIndex = 0; root.currentViewChanged(0) }
        }

        SidebarButton {
            text: "Caja (POS)"
            iconSource: "qrc:/vamp9/Vamp9POS/src/assets/icons/barcode.svg"
            isActive: root.activeIndex === 1
            onClicked: { root.activeIndex = 1; root.currentViewChanged(1) }
        }

        SidebarButton {
            text: "Administración"
            iconSource: "qrc:/vamp9/Vamp9POS/src/assets/icons/package.svg"
            isActive: root.activeIndex === 2
            onClicked: { root.activeIndex = 2; root.currentViewChanged(2) }
        }

        SidebarButton {
            text: "Configuración"
            iconSource: "qrc:/vamp9/Vamp9POS/src/assets/icons/settings.svg"
            isActive: root.activeIndex === 3
            onClicked: { root.activeIndex = 3; root.currentViewChanged(3) }
        }

        Item { Layout.fillHeight: true } 
    }

    component SidebarButton: Rectangle {
        id: btn
        property string text: ""
        property string iconSource: ""
        property bool isActive: false
        signal clicked()

        Layout.fillWidth: true
        height: 50
        radius: 8
        color: isActive ? Qt.rgba(255, 255, 255, 0.25) : (mouseArea.containsMouse ? Qt.rgba(255, 255, 255, 0.15) : "transparent")
        
        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            visible: btn.isActive
            width: 4; height: parent.height * 0.6
            radius: 2
            color: "#ffffff"
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 15
            spacing: 15

            Image {
                source: btn.iconSource
                sourceSize: Qt.size(24, 24)
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
            }

            Text {
                text: btn.text
                color: "#ffffff"
                font.pixelSize: Theme.sizeLG
                font.bold: true
                font.family: Theme.font
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }
}
