colormsg(_HIBLUE_ "---Start---Configuring sample_1 App")
#############################################################
project(sample_1)
# Include path
INCLUDE_DIRECTORIES(
	${PROJECT_SOURCE_DIR}/../..
	${GBREAKPAD_ROOT}/src
)

#####################################################
# Source files.
SET(SOURCES 
	main.cpp
	breakpadtest.cpp
	../../crashhandler/crashhandler.cpp
)
#####################################################
# Header files.
SET(HEADERS	
	breakpadtest.h
	../../crashhandler/crashhandler.h
	
)
SET(FORMS
	breakpadtest.ui
)
#####################################################
# Resource files.
SET (RESOURCES
	breakpadtest.qrc
)
########################################################
# Other files
SET(OTHER_FILES
	CMakeLists.txt
)


########################################################
set(DEPENDENCIES
	Wininet.lib
)

#Qt模块
SET(QT_MODULES	
	Gui
	Widgets
	Network
	)
IF(Qt4_FOUND)
	
ELSE()

ENDIF()
#依赖项目
SET(WIS_MODULE_DEPS	 
	common
	exception_handler
	crash_generation_client
	crash_generation_server
	)
###
WIS_QT_INIT_EXE_MODULE(TRUE)