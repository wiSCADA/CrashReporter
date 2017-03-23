OPTION(USE_QT4 "Use Qt 4.x.x lib " OFF)
OPTION(USE_QT5 "Use Qt 5.x.x lib " ON)
IF(USE_QT4 AND USE_QT5)
  MESSAGE(FATAL_ERROR "Only choose one Qt Version")
ENDIF()
IF(NOT USE_QT4 AND NOT USE_QT5)
	MESSAGE(FATAL_ERROR "Must choose Qt Version")
ENDIF()


SET(QT_DIR	## Qt安装路径的环境变量
	$ENV{QT_DIR}
)
STRING(LENGTH "${QT_DIR}" QT_DIR_LENGTH)
IF(${QT_DIR_LENGTH} MATCHES "0")
	SET(QT_DIR ${QT_DIR} CACHE PATH  "Qt install path")
	MESSAGE(FATAL_ERROR "Please set the Qt install path first. -DQT_DIR=XXXX ")
ENDIF()

MESSAGE(STATUS "QT_DIR=${QT_DIR}")
IF(USE_QT5)
	##	Set Qt 5 Install path 
	SET(CMAKE_PREFIX_PATH
		${CMAKE_PREFIX_PATH}
		${QT_DIR}
	)
	## 
	FIND_PACKAGE(Qt5Core)
	## 
	IF(Qt5Core_FOUND)
		MESSAGE(STATUS "Qt Version=${Qt5Core_VERSION_STRING}")
		SET(CMAKE_MODULE_PATH ${QT_DIR}/lib/cmake/Qt5Core ${CMAKE_MODULE_PATH})
		##MESSAGE(STATUS "${CMAKE_MODULE_PATH}")
		#INCLUDE(Qt5CTestMacros)
		##
		INCLUDE(wisQt5Config)
	ELSE()
		MESSAGE(FATAL_ERROR "Qt 5 install path invalid!")
	ENDIF()
ENDIF()
IF(USER_QT4)
	##
	SET(QT_QMAKE_EXECUTABLE ${QT_DIR}/bin/qmake)
	##
	FIND_PACKAGE(Qt4)
	##
	IF(Qt4_FOUND)
		MESSAGE("Qt Version=${QTVERSION}")		
		##
		INCLUDE(wisQt4Config)
	ELSE()
		MESSAGE(FATAL_ERROR "Qt 5 install path invalid!")
	ENDIF()
ENDIF()

# Find includes in corresponding build directories
set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Instruct CMake to run moc automatically when needed.
set(CMAKE_AUTOMOC ON)


