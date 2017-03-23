colormsg(_HIBLUE_ "---Start---Configuring Google Breakpad crash_generation_app library:")
#############################################################
project(crash_generation_app)
#####################################################
# Source files.
SET(SOURCES
	${GBREAKPAD_ROOT}/src/client/windows/tests/crash_generation_app/abstract_class.cc
	${GBREAKPAD_ROOT}/src/client/windows/tests/crash_generation_app/crash_generation_app.cc
)
#####################################################
# Header files.
SET(HEADERS
	${GBREAKPAD_ROOT}/src/client/windows/tests/crash_generation_app/crash_generation_app.h
)

#####################################################
# Resource files.
SET (RESOURCES
)
########################################################
# Other files
SET(OTHER_FILES
	CMakeLists.txt		
	${GBREAKPAD_ROOT}/src/client/windows/tests/crash_generation_app/small.ico
	${GBREAKPAD_ROOT}/src/client/windows/tests/crash_generation_app/crash_generation_app.ico
)
IF(WIN32)
	LIST(APPEND OTHER_FILES 
		${GBREAKPAD_ROOT}/src/client/windows/tests/crash_generation_app/crash_generation_app.rc
	)
	SET(HEADERS
		${HEADERS}		
		${GBREAKPAD_ROOT}/src/client/windows/tests/crash_generation_app/resource.h
	)
ENDIF(WIN32)

#  dependencies
set(DEPENDENCIES
	Wininet.lib
)
#依赖项目
SET(WIS_MODULE_DEPS
	common
	exception_handler
	crash_generation_client
	crash_generation_server
)

WIS_INIT_EXE_MODULE()
STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
SET(${PROJECTNAMEU}_TARGET_LINK ${${PROJECTNAMEU}_TARGET_LINK} PARENT_SCOPE)
colormsg(_HIBLUE_ "---End---")

