###############################################################################
#
# This file is part of CMake configuration for wiSCADA
#
# Copyright (C) 2014-2016 wiSCADA  wiscada@qq.com
#
###############################################################################
# General settings
###############################################################################
# CMake的最低版本
CMAKE_MINIMUM_REQUIRED(VERSION 3.7.0 FATAL_ERROR)

#项目名称
PROJECT(wiCrashReporter)

###############################################################################
# wiSCADA CMake modules
###############################################################################
# Path to additional CMake modules
SET(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
##
INCLUDE(wisConfig)
# 工具
INCLUDE(wisUtilities)
# 版本
INCLUDE(wisVersion)
#版本
wis_version(MAJOR 1 MINOR 0 PATCH 0)
## 工程采用Unicode
ADD_DEFINITIONS(-D_UNICODE -DUNICODE)

# 预编译头文件处理
INCLUDE(wisPrecompiled)
# C++工程工具
INCLUDE(wisCPPProjUtilities)
# Qt配置
INCLUDE(wisFindQt)
##################################################################################
### qt-solutions 的根目录
SET(QT_SOLUTIONS_ROOT $ENV{QT_SOLUTIONS_ROOT} CACHE PATH  "qt-solutions root path ")
IF (NOT (EXISTS "${QT_SOLUTIONS_ROOT}"))	
	MESSAGE(FATAL_ERROR "qt-solutions root path not found in ${QT_SOLUTIONS_ROOT}")
ENDIF()
### qtservice 源码目录
SET(QTSERVICE_SRC
	${QT_SOLUTIONS_ROOT}/qtservice/src
)
##################################################################################
### google breakpad 的根目录
SET(GBREAKPAD_ROOT $ENV{GBREAKPAD_ROOT} CACHE PATH  "google breakpad root path ")
IF (NOT (EXISTS "${GBREAKPAD_ROOT}"))	
	MESSAGE(FATAL_ERROR "google breakpad root path not found in ${GBREAKPAD_ROOT}")
ENDIF()

# 生成文件的路径
SET(BIN_DIR ${CMAKE_BINARY_DIR}/../bin)
SET(LIB_DIR ${CMAKE_BINARY_DIR}/../lib)
set(PLUGINDIR "${BIN_DIR}/plugins")

SET(LIBRARY_OUTPUT_PATH ${LIB_DIR})
SET(EXECUTABLE_OUTPUT_PATH ${BIN_DIR})

boost_report_value(EXECUTABLE_OUTPUT_PATH)
boost_report_value(LIBRARY_OUTPUT_PATH)

SET(LANGUAGES CACHE STRING  "Need to be translated in the target language" "zh_CN")
## 全局Include路径
INCLUDE_DIRECTORIES(
	${PROJECT_SOURCE_DIR}
	${PROJECT_BINARY_DIR}
	${GBREAKPAD_ROOT}/src		
)
##lib搜索路径
LINK_DIRECTORIES(
	${LIB_DIR}
)
### 设置crashreporter应用程序名称
SET(CRASHREPORTER_PROJ_NAME BugReporter)
#############################################################
#加载子项目目录
ADD_SUBDIRECTORY(google_breakpad)
ADD_SUBDIRECTORY(qtservice)
ADD_SUBDIRECTORY(crashreporter)
ADD_SUBDIRECTORY(crashservice)
ADD_SUBDIRECTORY(sample)
