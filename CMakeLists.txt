project(buho)
cmake_minimum_required(VERSION 3.0)

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 Widgets)
find_package(KF5 REQUIRED COMPONENTS Config KIO Notifications I18n Attica SyntaxHighlighting)
find_package(MauiKit REQUIRED)

include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(FeatureSummary)
include(ECMAddAppIcon)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#add_definitions( -Wall -O2 -fexceptions -std=c99)

if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)
else()
    find_package(Qt5 REQUIRED COMPONENTS WebView)
endif()

add_subdirectory(src)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
