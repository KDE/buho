cmake_minimum_required(VERSION 3.0)
set(BUHO_VERSION 1.1.1)
project(buho VERSION ${BUHO_VERSION})

find_package(ECM 1.7.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" ${ECM_MODULE_PATH})

find_package(Qt5 REQUIRED NO_MODULE COMPONENTS Qml Quick Sql Svg QuickControls2 WebView)
find_package(KF5 REQUIRED COMPONENTS Config KIO Notifications I18n Attica SyntaxHighlighting)
find_package(MauiKit REQUIRED)

include(KDEInstallDirs)
include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDECMakeSettings)
include(ECMInstallIcons)
include(ECMSetupVersion)
include(ECMAddAppIcon)
include(FeatureSummary)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#add_definitions( -Wall -O2 -fexceptions -std=c99)

ecm_setup_version(${BUHO_VERSION}
    VARIABLE_PREFIX BUHO
    VERSION_HEADER "${CMAKE_CURRENT_BINARY_DIR}/buho_version.h"
    )

if (ANDROID)
    find_package(Qt5 REQUIRED COMPONENTS AndroidExtras)
endif()

add_subdirectory(src)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
