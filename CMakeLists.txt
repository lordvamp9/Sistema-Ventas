cmake_minimum_required(VERSION 3.16)
project(Vamp9POS VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 COMPONENTS Core Gui Qml Quick REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/src)

set(SOURCES
    src/main.cpp
    src/backend/DatabaseManager.cpp
    src/backend/InventorySystem.cpp
    src/backend/POSController.cpp
)

qt_add_executable(Vamp9POS ${SOURCES})

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
)

target_link_libraries(Vamp9POS PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    winmm
)
