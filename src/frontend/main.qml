import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "components"

Window {
    id: mainWindow
    width: 1366
    height: 768
    minimumWidth: 1100
    minimumHeight: 650
    visible: true
    title: "vamp9 POS"
    color: "#f0f4f8"

    // Global design tokens — accessible anywhere via "theme"
    Theme { id: theme }

    // Audio engine
    AudioSystem { id: audioSystem }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ── Sidebar ──────────────────────────────────────────
        NavigationSidebar {
            id: sidebar
            Layout.fillHeight: true
            Layout.preferredWidth: 230
            themeRef: theme
            onNavSelected: function(idx) {
                stackLayout.currentIndex = idx
            }
        }

        // ── Main content area ────────────────────────────────
        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0

            Dashboard    { id: dashboardView;  themeRef: theme }
            POSView      { id: posView;         themeRef: theme; audioRef: audioSystem }
            AdminView    { id: adminView;       themeRef: theme }
            SettingsView { id: settingsView;    themeRef: theme }
        }
    }
}
