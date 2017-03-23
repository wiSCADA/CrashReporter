colormsg(_HIBLUE_ "---Start---Configuring qt-solutions qtservice library:")
#############################################################
project(QtService)
IF(NOT EXISTS QTSERVICE_SRC)
	### qtservice 源码目录
	SET(QTSERVICE_SRC
		${QT_SOLUTIONS_ROOT}/qtservice/src
	)
ENDIF()

INCLUDE_DIRECTORIES(
	${QTSERVICE_SRC}
)

#####################################################
# Source files.
SET(SOURCES	
	${QTSERVICE_SRC}/qtservice.cpp
)
IF(WIN32)
	SET(SOURCES
		${SOURCES}
		${QTSERVICE_SRC}/qtservice_win.cpp
	)
ELSE()
	SET(SOURCES
		${SOURCES}
		${QTSERVICE_SRC}/qtunixsocket.cpp
		${QTSERVICE_SRC}/qtunixserversocket.cpp		
		${QTSERVICE_SRC}/qtservice_unix.cpp
	)
ENDIF()
#####################################################
# Header files.
SET(HEADERS	
	${QTSERVICE_SRC}/qtservice_p.h
	${QTSERVICE_SRC}/qtservice.h
)
IF(WIN32)
	SET(HEADERS
		${HEADERS}		
	)
ELSE()
	SET(HEADERS
		${HEADERS}
		${QTSERVICE_SRC}/qtunixsocket.h
		${QTSERVICE_SRC}/qtunixserversocket.h
	)
ENDIF()
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
)

WIS_QT_INIT_STATIC_MODULE(FALSE)
STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
SET(${PROJECTNAMEU}_TARGET_LINK ${${PROJECTNAMEU}_TARGET_LINK} PARENT_SCOPE)
colormsg(_HIBLUE_ "---End---")
