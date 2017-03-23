colormsg(_HIBLUE_ "---Start---Configuring wiSCADA CrashService App")
#############################################################
project(CrashService)
#版本
wis_version(MAJOR 1 MINOR 0 PATCH 0)
# Include path
INCLUDE_DIRECTORIES(
	${PROJECT_SOURCE_DIR}/src
	${PROJECT_BINARY_DIR} ###version.h	
	${QTSERVICE_SRC}
)
#############################################################
# create version.h
CONFIGURE_FILE (
  "${PROJECT_SOURCE_DIR}/version.h.in"
  "${PROJECT_BINARY_DIR}/version.h"
  )    
# Source files.
FILE(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
#####################################################
# Header files.
FILE(GLOB_RECURSE HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
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
########################################################
set(DEPENDENCIES
)

#Qt模块
SET(QT_MODULES	
	Network
	)
IF(Qt4_FOUND)
	
ELSE()

ENDIF()
#依赖项目
SET(WIS_MODULE_DEPS	 
	qtservice
	common
	exception_handler
	crash_generation_client
	crash_generation_server
)
### 生成exe项目
WIS_QT_INIT_CONSOLE_EXE_MODULE(FALSE)