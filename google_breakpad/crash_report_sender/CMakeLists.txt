colormsg(_HIBLUE_ "---Start---Configuring Google Breakpad crash_report_sender library:")
#############################################################
project(crash_report_sender)
#####################################################
# Source files.
SET(SOURCES
	${GBREAKPAD_ROOT}/src/client/windows/sender/crash_report_sender.cc
)
#####################################################
# Header files.
SET(HEADERS
	${GBREAKPAD_ROOT}/src/client/windows/sender/crash_report_sender.h
)

#####################################################
# Resource files.
SET (RESOURCES
)
########################################################
# Other files
SET(OTHER_FILES
	CMakeLists.txt	
)
#  dependencies
set(DEPENDENCIES
	Wininet.lib
)
#依赖项目
SET(WIS_MODULE_DEPS
	common
)

WIS_INIT_STATIC_MODULE()
STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
SET(${PROJECTNAMEU}_TARGET_LINK ${${PROJECTNAMEU}_TARGET_LINK} PARENT_SCOPE)
colormsg(_HIBLUE_ "---End---")

