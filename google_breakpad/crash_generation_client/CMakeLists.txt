colormsg(_HIBLUE_ "---Start---Configuring Google Breakpad crash_generation_client library:")
#############################################################
project(crash_generation_client)
#####################################################
# Source files.
SET(SOURCES
	${GBREAKPAD_ROOT}/src/client/windows/crash_generation/crash_generation_client.cc
)
#####################################################
# Header files.
SET(HEADERS
	${GBREAKPAD_ROOT}/src/client/windows/crash_generation/crash_generation_client.h
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
