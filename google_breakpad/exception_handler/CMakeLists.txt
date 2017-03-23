colormsg(_HIBLUE_ "---Start---Configuring Google Breakpad exception_handler library:")
#############################################################
project(exception_handler)
#####################################################
# Source files.
SET(SOURCES
	${GBREAKPAD_ROOT}/src/client/windows/handler/exception_handler.cc
)
#####################################################
# Header files.
SET(HEADERS
	${GBREAKPAD_ROOT}/src/client/windows/handler/exception_handler.h
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
# EXTENSIONSYSTEM dependencies
set(DEPENDENCIES
	
)
#依赖项目
SET(WIS_MODULE_DEPS
)

WIS_INIT_STATIC_MODULE()
STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
SET(${PROJECTNAMEU}_TARGET_LINK ${${PROJECTNAMEU}_TARGET_LINK} PARENT_SCOPE)
colormsg(_HIBLUE_ "---End---")
