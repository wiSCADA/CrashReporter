colormsg(_HIBLUE_ "---Start---Configuring wiSCADA CrashReporter App")
#############################################################
project(CrashReporter)
#版本
wis_version(MAJOR 1 MINOR 0 PATCH 0)
# Include path
INCLUDE_DIRECTORIES(
	${PROJECT_SOURCE_DIR}/src
	${PROJECT_BINARY_DIR} ###version.h	
)
#############################################################
# create version.h
CONFIGURE_FILE (
  "${PROJECT_SOURCE_DIR}/version.h.in"
  "${PROJECT_BINARY_DIR}/version.h"
  )    
# Source files.
FILE(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
#####################################################
# Header files.
FILE(GLOB_RECURSE HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/src/*.h")
SET(HEADERS 
	${HEADERS}
	${PROJECT_BINARY_DIR}/version.h
)

#####################################################
# UI files
FILE(GLOB_RECURSE FORMS "${CMAKE_CURRENT_SOURCE_DIR}/*.ui")
#####################################################
# Resource files.
SET (RESOURCES
)
########################################################
# Other files
SET(OTHER_FILES
	CMakeLists.txt
)
IF(WIN32)
	LIST(APPEND OTHER_FILES ${PROJECT_SOURCE_DIR}/crashreporter.rc)
	LIST(APPEND HEADERS resource.h)
ENDIF(WIN32)


########################################################
set(DEPENDENCIES
)

#Qt模块
SET(QT_MODULES	
	Gui
	Widgets
	Network
	Test
	)
IF(Qt4_FOUND)
	
ELSE()

ENDIF()
#依赖项目
SET(WIS_MODULE_DEPS	 
	)

### 生成exe项目
WIS_QT_INIT_EXE_MODULE(TRUE)