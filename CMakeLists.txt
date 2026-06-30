cmake_minimum_required(VERSION 3.16)
project(Vamp9POS VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 COMPONENTS Core Gui Qml Quick Sql QuickDialogs2 REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/src)

set(SOURCES
    src/main.cpp
    src/backend/DatabaseManager.cpp
    src/backend/InventorySystem.cpp
    src/backend/SettingsManager.cpp
    src/backend/POSController.cpp
)

if(WIN32)
    qt_add_executable(Vamp9POS WIN32 ${SOURCES})
else()
    qt_add_executable(Vamp9POS ${SOURCES})
endif()

qt_add_qml_module(Vamp9POS
    URI vamp9.Vamp9POS
    VERSION 1.0
    QML_FILES
        src/frontend/main.qml
        src/frontend/NavigationSidebar.qml
        src/frontend/Dashboard.qml
        src/frontend/POSView.qml
        src/frontend/AdminView.qml
        src/frontend/components/SolidCard.qml
        src/frontend/components/AlertCard.qml
        src/frontend/components/AudioSystem.qml
        src/frontend/components/ActionButton.qml
        src/frontend/components/Theme.qml
        src/frontend/PaymentDialog.qml
        src/frontend/SettingsView.qml
    RESOURCES
        src/assets/icons/home.svg
        src/assets/icons/barcode.svg
        src/assets/icons/settings.svg
        src/assets/icons/alert-circle.svg
        src/assets/icons/package.svg
        src/assets/icons/dollar-sign.svg
        src/assets/icons/upload.svg
        src/assets/icons/download.svg
        src/assets/icons/trash-2.svg
        src/assets/icons/edit.svg
        src/assets/icons/shopping-cart.svg
        src/assets/fonts/Inter-Regular.ttf
        src/assets/fonts/Inter-Bold.ttf
        src/assets/fonts/Inter-SemiBold.ttf
        src/assets/cash.wav
)

target_link_libraries(Vamp9POS PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::Sql
    Qt6::QuickDialogs2
    winmm
)
