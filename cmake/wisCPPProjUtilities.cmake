################################################################################
# wisCPPProjUtilities.cmake - part of CMake configuration of wiSCADA
#
################################################################################
# 生成 普通C++工程
#
################################################################################

#_______________________________________________________________________________
# INIT_TYPE 
#	EXE		可执行程序 
#	DLL		动态链接库
#	LIB		静态链接库
#
#
#
#
FUNCTION (WIS_INIT_COMMON_LIB INIT_TYPE)
	#包含头文件
	INCLUDE_DIRECTORIES(${PROJECT_BINARY_DIR})
	#项目名称全打写 全小写
	STRING(TOLOWER "${PROJECT_NAME}" PROJECTNAMEL)
	STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
	SOURCE_GROUP("Header Files" FILES ${HEADERS})
	SOURCE_GROUP("Source Files" FILES ${SOURCES})
	SOURCE_GROUP("Other Files" 	FILES ${OTHER_FILES})
	IF( ${INIT_TYPE} STREQUAL "EXE" OR ${INIT_TYPE} STREQUAL "CONSOLE")##可执行程序(包括GUI应用程序和控制台应用程序)
		#WIN32
		set(WINDOWS
		)
		#其中WINDOWS变量的作用是:调试版附带控制台,发布版去除控制台
		IF(NOT ${CMAKE_BUILD_TYPE} MATCHES "Debug")
		   set(WINDOWS WIN32)
		ENDIF()
		ADD_EXECUTABLE(${PROJECTNAMEL} ${WINDOWS}
			${HEADERS}
			${SOURCES}
			${OTHER_FILES}
		)
		IF(WIN32)
			##需要管理员权限,放在add_executable的后面
			#SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
			#	LINK_FLAGS	"/level='requireAdministrator' /uiAccess='false'")
				##"/MANIFESTUAC:\"level='asInvoker' uiAccess='false'\"")#"/MANIFESTUAC:\" level='requireAdministrator' uiAccess='false' "/SUBSYSTEM:WINDOWS")
		ENDIF(WIN32)
	
		IF(WIN32)
			IF(MSVC)
				IF (CMAKE_BUILD_TYPE MATCHES Debug)
					SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
						LINK_FLAGS_DEBUG "/SUBSYSTEM:CONSOLE")
					SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
						COMPILE_DEFINITIONS_DEBUG "_CONSOLE")					
				ELSE()
					IF (${INIT_TYPE} STREQUAL "CONSOLE")
						SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
							LINK_FLAGS_RELEASE "/SUBSYSTEM:CONSOLE")
						SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
							COMPILE_DEFINITIONS_RELEASE "_CONSOLE")		
						SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
							LINK_FLAGS_RELWITHDEBINFO "/SUBSYSTEM:CONSOLE")
						SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
							COMPILE_DEFINITIONS_RELWITHDEBINFO "_CONSOLE")		
					ELSE()
						SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
							LINK_FLAGS_RELEASE "/SUBSYSTEM:WINDOWS")
						SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
							LINK_FLAGS_RELWITHDEBINFO "/SUBSYSTEM:WINDOWS")
					ENDIF()					
				ENDIF()
			ENDIF(MSVC)
		ENDIF(WIN32)
	ELSEIF(${INIT_TYPE} STREQUAL "LIB")
		# Utils shared library
		ADD_LIBRARY(${PROJECTNAMEL} STATIC
			${HEADERS}
			${SOURCES}		
			${OTHER_FILES}
		)
	ELSE()
		# Utils shared library
		ADD_LIBRARY(${PROJECTNAMEL} SHARED
			${HEADERS}
			${SOURCES}		
			${OTHER_FILES}
		)
	ENDIF()
	## 当前工程依赖的lib
	SET(LINK_DEPS
		)
	FOREACH(deps ${WIS_MODULE_DEPS})
		STRING(TOUPPER "${deps}" deps)
		LIST(APPEND LINK_DEPS "${${deps}_TARGET_LINK}")
	ENDFOREACH()

	FOREACH(deps ${DEPENDENCIES})
		LIST(APPEND LINK_DEPS "${deps}")
	ENDFOREACH()

	TARGET_LINK_LIBRARIES(${PROJECTNAMEL} 
		${LINK_DEPS}
	)
	STRING(LENGTH "${WIS_MODULE_DEPS}" varlen)
	IF(NOT ${varlen} MATCHES "0")
		ADD_DEPENDENCIES(${PROJECTNAMEL}
			${WIS_MODULE_DEPS}
		)
	ENDIF()
	IF(WIN32 OR APPLE)
		IF(NOT ${INIT_TYPE} MATCHES "EXE")##非可执行程序
			SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
				DEBUG_POSTFIX ${WIS_DEBUG_POSTFIX}
			)
		ENDIF()
	ENDIF()
	## 输出目录
	SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${BIN_DIR}
		ARCHIVE_OUTPUT_DIRECTORY_DEBUG   ${LIB_DIR}
		LIBRARY_OUTPUT_DIRECTORY_DEBUG   ${BIN_DIR}
	)
	SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY_RELEASE   ${BIN_DIR}
		ARCHIVE_OUTPUT_DIRECTORY_RELEASE   ${LIB_DIR}
		LIBRARY_OUTPUT_DIRECTORY_RELEASE   ${BIN_DIR}
	)
	SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
		RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO   ${BIN_DIR}
		ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO   ${LIB_DIR}
		LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO   ${BIN_DIR}
	)
	## 设置多核编译
	SET_TARGET_PROPERTIES(${PROJECTNAMEL} 
		PROPERTIES 
		COMPILE_FLAGS "/MP" )  #Yes 多核编译
	IF(WIN32)
		SET_TARGET_PROPERTIES( ${PROJECTNAMEL} 
			PROPERTIES 
			COMPILE_FLAGS "/EHsc" ) #yes 启用C++异常
	ENDIF()
	
	# configuration summary	
	boost_report_value(LINK_DEPS)
	wis_report_directory_property(COMPILE_DEFINITIONS)
	IF(NOT ${INIT_TYPE} MATCHES "EXE")
		wis_target_output_name(${PROJECTNAMEL} ${PROJECTNAMEU}_TARGET_LINK)	
		# # Export core target name to make it visible by backends
		SET(${PROJECTNAMEU}_TARGET_LINK ${${PROJECTNAMEU}_TARGET_LINK} PARENT_SCOPE)
	ENDIF()
ENDFUNCTION()

#_______________________________________________________________________________
# 构造动态链接库
#
# HEADERS 		头文件
# SOURCES 		源文件
# OTHER_FILES	其它文件
#
# DEPENDENCIES 	依赖的第三方的lib
#
# WIS_MODULE_DEPS 依赖的本解决方案内的项目名称

MACRO(WIS_INIT_LIBRARY_MODULE )
	##构造目标项目
	WIS_INIT_LIBRARY_MODULE_PCH("" "")	
ENDMACRO(WIS_INIT_LIBRARY_MODULE )
#
# 带预编译头的动态链接库
#
MACRO(WIS_INIT_LIBRARY_MODULE_PCH
	PrecompiledHeader PrecompiledSource 
	)
	#项目名称大写
	STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
	## 动态库导出
	ADD_DEFINITIONS(-D${PROJECTNAMEU}_LIBRARY)
	##构造目标项目
	WIS_INIT_COMMON_LIB("DLL")
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_INIT_LIBRARY_MODULE_PCH )
#_______________________________________________________________________________
# 静态链接库
#
MACRO(WIS_INIT_STATIC_MODULE)
	##构造目标项目	
	WIS_INIT_STATIC_MODULE_PCH("" "")	
ENDMACRO(WIS_INIT_STATIC_MODULE)
#
# 带预编译头的静态链接库
#
MACRO(WIS_INIT_STATIC_MODULE_PCH
	PrecompiledHeader PrecompiledSource)
	#项目名称大写
	STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
	## 静态库导出
	ADD_DEFINITIONS(-D${PROJECTNAMEU}_STATIC_LIB)
	##构造目标项目
	WIS_INIT_COMMON_LIB("LIB")
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_INIT_STATIC_MODULE_PCH)
################################################################################
# 控制台应用程序
MACRO(WIS_INIT_CONSOLE_EXE_MODULE)
	##构造目标项目
	WIS_INIT_CONSOLE_EXE_MODULE_PCH("" "")	
ENDMACRO(WIS_INIT_CONSOLE_EXE_MODULE)
#_______________________________________________________________________________
# 可执行程序 带预编译头
#
#
MACRO(WIS_INIT_CONSOLE_EXE_MODULE_PCH
	PrecompiledHeader PrecompiledSource)
	##构造目标项目
	WIS_INIT_COMMON_LIB("CONSOLE")
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_INIT_CONSOLE_EXE_MODULE_PCH)

################################################################################
# GUI应用程序
#_______________________________________________________________________________
# 可执行程序
#
#
MACRO(WIS_INIT_EXE_MODULE)
	##构造目标项目
	WIS_INIT_EXE_MODULE_PCH("" "")	
ENDMACRO(WIS_INIT_EXE_MODULE)
#_______________________________________________________________________________
# 可执行程序 带预编译头
#
#
MACRO(WIS_INIT_EXE_MODULE_PCH
	PrecompiledHeader PrecompiledSource)
	##构造目标项目
	WIS_INIT_COMMON_LIB("EXE")
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_INIT_EXE_MODULE_PCH)