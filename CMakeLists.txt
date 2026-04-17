cmake_minimum_required(VERSION 3.16)

project(KrosLauncher VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Qt motorunun C++ ve QML'i birbirine bağlaması için gerekenler
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Gerekli paketleri bul
find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick QuickControls2)

# 1. İkon dosyasını tanımla (Dosyanın klasörde 'icon.ico' adıyla durduğundan emin ol reis)
set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/icon.ico")

# 2. Çalıştırılabilir dosyayı TEK SEFERDE oluştur (İkinci bir qt_add_executable yazma sakın)
qt_add_executable(appKrosLauncher
    main.cpp
    ${app_icon_resource_windows}
)

# 3. QML modülünü bağla
qt_add_qml_module(appKrosLauncher
    URI KrosLauncher
    VERSION 1.0
    QML_FILES Main.qml
    RESOURCES icon.ico
    RESOURCES .gitignore  # İşte bu satır pencere ikonunu aktif eder reis!
)

# 4. Kütüphane bağlantılarını yap
target_link_libraries(appKrosLauncher
    PRIVATE Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2
)

# 5. Windows pencere ayarı (Konsol penceresini gizler)
set_target_properties(appKrosLauncher PROPERTIES
    WIN32_EXECUTABLE TRUE
)