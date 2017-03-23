colormsg(_HIBLUE_ "---Start---Configuring Google Breakpad common library:")
#############################################################
project(common)
#####################################################
# Source files.
SET(SOURCES
	${GBREAKPAD_ROOT}/src/common/windows/guid_string.cc
	${GBREAKPAD_ROOT}/src/common/windows/string_utils.cc
	${GBREAKPAD_ROOT}/src/common/windows/http_upload.cc
)
#####################################################
# Header files.
SET(HEADERS
	${GBREAKPAD_ROOT}/src/common/windows/guid_string.h
	${GBREAKPAD_ROOT}/src/common/windows/http_upload.h
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
# dependencies
set(DEPENDENCIES
	Wininet.lib
)
#依赖项目
SET(WIS_MODULE_DEPS
)

WIS_INIT_STATIC_MODULE()
STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
SET(${PROJECTNAMEU}_TARGET_LINK ${${PROJECTNAMEU}_TARGET_LINK} PARENT_SCOPE)
colormsg(_HIBLUE_ "---End---")
