// Theme.qml — Design token object, instantiate once in main.qml as "Theme { id: T }"
// Usage: T.brand, T.fontMD, etc.
import QtQuick 2.15

QtObject {
    // Brand Colors - vamp9 sky-blue palette
    readonly property color brand:       "#0ea5e9"
    readonly property color brandDark:   "#0284c7"
    readonly property color brandLight:  "#e0f2fe"
    readonly property color brandAccent: "#38bdf8"

    // Backgrounds
    readonly property color bg:         "#f0f4f8"
    readonly property color surface:    "#ffffff"
    readonly property color surfaceAlt: "#f8fafc"
    readonly property color border:     "#e2e8f0"

    // Text
    readonly property color textPrimary:   "#0f172a"
    readonly property color textSecondary: "#475569"
    readonly property color textMuted:     "#94a3b8"

    // Semantic
    readonly property color success:      "#16a34a"
    readonly property color successLight: "#dcfce7"
    readonly property color danger:       "#dc2626"
    readonly property color dangerLight:  "#fee2e2"
    readonly property color warning:      "#d97706"
    readonly property color warningLight: "#fef3c7"

    // Sidebar
    readonly property color sidebarBg:     "#075985"
    readonly property color sidebarActive: "#0369a1"

    // Typography
    readonly property string font: "Inter"
    readonly property int fontXS:  11
    readonly property int fontSM:  13
    readonly property int fontMD:  15
    readonly property int fontLG:  17
    readonly property int fontXL:  20
    readonly property int font2XL: 24
    readonly property int font3XL: 30
    readonly property int font4XL: 40
}
