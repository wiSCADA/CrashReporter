# Qt5
FIND_PACKAGE(Qt5Core)
FIND_PACKAGE(Qt5Concurrent )
FIND_PACKAGE(Qt5LinguistTools)

#翻译工具
SET(LUPDATE 		${_qt5_linguisttools_install_prefix}/bin/lupdate)
SET(LUPDATE_OPTIONS -locations relative -no-ui-lines -no-sort )
SET(LRELEASE 		${_qt5_linguisttools_install_prefix}/bin/lrelease)
SET(LCONVERT 		${_qt5_linguisttools_install_prefix}/bin/lconvert)
SET(XMLPATTERNS 	${_qt5XmlPatterns_install_prefix}/bin/xmlpatterns)
SET(RCC 			${_qt5_linguisttools_install_prefix}/bin/rcc)

ADD_DEFINITIONS(-DQT_NO_CAST_TO_ASCII)
ADD_DEFINITIONS("-DQT_DISABLE_DEPRECATED_BEFORE=0x040900")
IF(MSVC)
	ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS)
ENDIF()
IF(NOT APPLE)
	ADD_DEFINITIONS(-DQT_USE_FAST_OPERATOR_PLUS -DQT_USE_FAST_CONCATENATION)
ENDIF()
## 多核编译
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP") 

  
### Using Qt 5 with CMake older than 2.8.9########################
# Add compiler flags for building executables (-fPIE)
###set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${Qt5Widgets_EXECUTABLE_COMPILE_FLAGS}")


FUNCTION(WIS_QT_INIT_COMMON_LIB 
	INIT_TYPE 
	HAS_QM)
	IF(EXISTS _UNICODE)	
		## Qt工程采用Unicode
		ADD_DEFINITIONS(-D_UNICODE -DUNICODE)
	ENDIF()
	#包含头文件
	INCLUDE_DIRECTORIES(${PROJECT_BINARY_DIR})
	#项目名称全打写 全小写
	STRING(TOLOWER "${PROJECT_NAME}" PROJECTNAMEL)
	STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
	##--------------------------------------------------------------------------
	## 链接的Qt库
	SET(QT_LINK_DEPS
	)
	FOREACH(deps ${QT_MODULES})
		IF(NOT Qt5${deps}_FOUND)
			FIND_PACKAGE(Qt5${deps})
		ENDIF()
		LIST(APPEND QT_LINK_DEPS "Qt5::${deps}")
	ENDFOREACH()
	## 判断Qt::Core是否存在	
	LIST(LENGTH QT_LINK_DEPS qt_link_deps_len)
	IF(${qt_link_deps_len} STREQUAL "0")
		LIST(APPEND QT_LINK_DEPS "Qt5::Core")
	ELSE()
		LIST(FIND QT_LINK_DEPS "Qt5::Core" QtModuleIndex)
		IF(${QtModuleIndex} STREQUAL "-1")
			LIST(INSERT QT_LINK_DEPS 0 "Qt5::Core")
		ENDIF()
	ENDIF()
	
	## 判断Qt::Concurrent是否存在	
	LIST(FIND QT_LINK_DEPS "Qt5::Concurrent" QtModuleIndex)
	IF(${QtModuleIndex} STREQUAL "-1")
		LIST(LENGTH QT_LINK_DEPS qt_link_deps_len)
		IF(${qt_link_deps_len} STREQUAL "1")
			LIST(APPEND QT_LINK_DEPS "Qt5::Concurrent")
		ELSE()
			LIST(INSERT QT_LINK_DEPS 1 "Qt5::Concurrent")
		ENDIF()
	ENDIF()
	
	# Header files needs to be processed by Qt's pre-processor to generate Moc files.	
	QT5_WRAP_CPP(MOC_HDS 	${HEADERS} )	
	# UI files need to be processed by Qt wrapper to generate UI headers.	
	QT5_WRAP_UI(UI_HDS 		${FORMS})		
	# RC files need to be processed by Qt wrapper to generate RC headers.	
	QT5_ADD_RESOURCES(RCC_HDS ${RESOURCES} )
	LIST(APPEND OTHER_FILES ${RESOURCES} )
	
	## 如果有需要翻译文件
	IF(HAS_QM)
	
	ENDIF()
	# Group all ui files in the same virtual directory.
	SOURCE_GROUP("Form Files" 				FILES 	${FORMS} )
	# Group generated files in the same isolated virtual directory.
	SOURCE_GROUP("Generated Files\\qrc" 	FILES 	${RCC_HDS})
	#SOURCE_GROUP("Generated Files\\ui" 		FILES 	${UI_HDS})
	#SOURCE_GROUP("Generated Files\\moc" 	FILES 	${MOC_HDS})
	# Group all Other files in the same virtual directory.
	SOURCE_GROUP("Other Files" 				FILES 	${OTHER_FILES})
	##--------------------------------------------------------------------------
	IF(${INIT_TYPE} STREQUAL "EXE" OR ${INIT_TYPE} STREQUAL "CONSOLE" ) ##生成可执行程序
		#WIN32
		set(WINDOWS
		)
		#其中WINDOWS变量的作用是:调试版附带控制台,发布版去除控制台
		IF(NOT ${CMAKE_BUILD_TYPE} MATCHES "Debug")
			   set(WINDOWS WIN32)
		ENDIF()
		# Qt4::WinMain
		SET(QT_USE_QTMAIN TRUE)#qtmain
		# 生成目标程序
		ADD_EXECUTABLE(${PROJECTNAMEL} ${WINDOWS}
			${HEADERS}
			${SOURCES}
			${FORMS}
			${RESOURCES}
			${OTHER_FILES}	
			#${MOC_HDS}
			#${UI_HDS}
			${RCC_HDS}
		)
		IF(WIN32)
			TARGET_LINK_LIBRARIES(${PROJECTNAMEL}
				${QT_QTMAIN_LIBRARY})
			##需要管理员权限,放在add_executable的后面
			SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
				LINK_FLAGS	"/level='requireAdministrator' /uiAccess='false'")
				##"/MANIFESTUAC:\"level='asInvoker' uiAccess='false'\"")#"/MANIFESTUAC:\" level='requireAdministrator' uiAccess='false' "/SUBSYSTEM:WINDOWS")
			
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
							LINK_FLAGS_RELWITHDEBINFO "/SUBSYSTEM:WINDOWS")					
						SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES 
							LINK_FLAGS_RELEASE "/SUBSYSTEM:WINDOWS")
					ENDIF()
				ENDIF()
			ENDIF(MSVC)
		ENDIF(WIN32)
	ELSEIF(${INIT_TYPE} STREQUAL "LIB")## 生成静态链接库
		ADD_LIBRARY(${PROJECTNAMEL} STATIC
			${HEADERS}
			${SOURCES}
			${FORMS}
			${RESOURCES}
			${OTHER_FILES}	
			#${MOC_HDS}
			#${UI_HDS}
			${RCC_HDS}
		)
	ELSE()## 生成动态链接库
		ADD_LIBRARY(${PROJECTNAMEL} SHARED
			${HEADERS}
			${SOURCES}
			${FORMS}
			${RESOURCES}
			${OTHER_FILES}	
			#${MOC_HDS}
			#${UI_HDS}
			${RCC_HDS}
		)
	ENDIF()
	##--------------------------------------------------------------------------
	## 当前工程依赖的本工程的项目lib
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
	##--------------------------------------------------------------------------
	## 链接的Qt库
	FOREACH(deps ${QT_LINK_DEPS})
		TARGET_LINK_LIBRARIES(${PROJECTNAMEL} 
		${deps})
	ENDFOREACH()
	
	##--------------------------------------------------------------------------
	## 设置生成的文件名后缀和生成文件的目标路径
	IF(WIN32 OR APPLE)
		IF(NOT ${INIT_TYPE} MATCHES "EXE")##非可执行程序
			SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
				DEBUG_POSTFIX ${WIS_DEBUG_POSTFIX}
			)
		ENDIF()
	ENDIF()
	IF( ${INIT_TYPE} STREQUAL "PLUGIN")##插件
		SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
			RUNTIME_OUTPUT_DIRECTORY_DEBUG   ${PLUGINDIR}
			ARCHIVE_OUTPUT_DIRECTORY_DEBUG   ${LIB_DIR}
			LIBRARY_OUTPUT_DIRECTORY_DEBUG   ${PLUGINDIR}
		)
		SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
			RUNTIME_OUTPUT_DIRECTORY_RELEASE   ${PLUGINDIR}
			ARCHIVE_OUTPUT_DIRECTORY_RELEASE   ${LIB_DIR}
			LIBRARY_OUTPUT_DIRECTORY_RELEASE   ${PLUGINDIR}
		)
		SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
			RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO   ${PLUGINDIR}
			ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO   ${LIB_DIR}
			LIBRARY_OUTPUT_DIRECTORY_RELWITHDEBINFO   ${PLUGINDIR}
		)
	ELSE()##其它
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
	ENDIF()
	##--------------------------------------------------------------------------
	IF(WIN32)
		IF(MSVC)
			SET_TARGET_PROPERTIES(${PROJECTNAMEL} PROPERTIES
				VS_KEYWORD Qt4VSv1.0 #可以用来改变visual studio的关键字，例如如果该选项被设置为Qt4VSv1.0的话，QT集成将会运行得更好。
				VS_GLOBAL_KEYWORD Qt4VSv1.0
			)
		ENDIF(MSVC)
		SET_TARGET_PROPERTIES(${PROJECTNAMEL}
			PROPERTIES
			OUTPUT_NAME 		"${PROJECTNAMEL}"
			#VERSION	 			${${PROJECTNAMEU}_VERSION}
			CLEAN_DIRECT_OUTPUT 1)		
	ELSE()
		SET_TARGET_PROPERTIES(${PROJECTNAMEL}
			PROPERTIES
			#VERSION 			${${PROJECTNAMEU}_VERSION}
			#SOVERSION			${${PROJECTNAMEU}_SOVERSION}
			CLEAN_DIRECT_OUTPUT 1)
	ENDIF()
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
##初始化预编译头
FUNCTION (WIS_INIT_PCH
	PrecompiledHeader PrecompiledSource)
	## 预编译头判断
	IF(NOT ${PrecompiledHeader} STREQUAL "" AND NOT ${PrecompiledSource} STREQUAL "")
	message("-------------------------${PrecompiledHeader}----${PrecompiledSource}")
		## 预编译头
		# 头文件的文件名可以任意，并且gcc下面其实并不需要stdafx.cpp，但是考虑到对Visual Studio的兼容性，
		# 这里仍然需要一个cpp文件
		ADD_PRECOMPILED_HEADER(${PROJECT_NAME} ${PrecompiledHeader} ${PrecompiledSource})
		## 处理要使用预编译头的源文件
		SET(USE_PRECOMPILED_SRC 
		)
		FOREACH(source ${SOURCES})
			IF(NOT (source MATCHES ".*${PrecompiledSource}*")) 
				LIST(APPEND USE_PRECOMPILED_SRC ${source})
			 ENDIF()
		ENDFOREACH()
		# 然后简单的一个调用就搞定了
		USE_PRECOMPILED_HEADER(USE_PRECOMPILED_SRC)
	ENDIF()
ENDFUNCTION()
#_______________________________________________________________________________
# 构造动态链接库
#
# HEADERS 		头文件
# SOURCES 		源文件
# FORMS 		窗体文件
# RESOURCES		资源文件
# OTHER_FILES	其它文件
#
# DEPENDENCIES 	依赖的第三方的lib
#
# WIS_MODULE_DEPS 依赖的本解决方案内的项目名称

MACRO(WIS_QT_INIT_LIBRARY_MODULE 
	HAS_QM)
	##构造目标项目
	WIS_QT_INIT_LIBRARY_MODULE_PCH(${HAS_QM} "" "")	
ENDMACRO(WIS_QT_INIT_LIBRARY_MODULE )
#
# 带预编译头的动态链接库
#
MACRO(WIS_QT_INIT_LIBRARY_MODULE_PCH 
	HAS_QM
	PrecompiledHeader PrecompiledSource 
	)
	#项目名称大写
	STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
	## 动态库导出
	ADD_DEFINITIONS(-D${PROJECTNAMEU}_LIBRARY)
	##构造目标项目
	WIS_QT_INIT_COMMON_LIB("DLL" ${HAS_QM})
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_QT_INIT_LIBRARY_MODULE_PCH )
#_______________________________________________________________________________
# 静态链接库
#
MACRO(WIS_QT_INIT_STATIC_MODULE 
	HAS_QM)
	##构造目标项目	
	WIS_QT_INIT_STATIC_MODULE_PCH(${HAS_QM} "" "")	
ENDMACRO(WIS_QT_INIT_STATIC_MODULE)
#
# 带预编译头的静态链接库
#
MACRO(WIS_QT_INIT_STATIC_MODULE_PCH
	HAS_QM
	PrecompiledHeader PrecompiledSource)
	#项目名称大写
	STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
	## 静态库导出
	ADD_DEFINITIONS(-D${PROJECTNAMEU}_STATIC_LIB)
	##构造目标项目
	WIS_QT_INIT_COMMON_LIB("LIB" ${HAS_QM})
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_QT_INIT_STATIC_MODULE_PCH)
#_______________________________________________________________________________
# 插件
#
#
MACRO(WIS_QT_INIT_PLUGIN_MODULE 
	HAS_QM)
	##构造目标项目
	WIS_QT_INIT_PLUGIN_MODULE_PCH(${HAS_QM} "" "")	
ENDMACRO(WIS_QT_INIT_PLUGIN_MODULE )
#
# 插件带预编译头
#
MACRO(WIS_QT_INIT_PLUGIN_MODULE_PCH
	HAS_QM
	PrecompiledHeader PrecompiledSource)
	#项目名称大写
	STRING(TOUPPER "${PROJECT_NAME}" PROJECTNAMEU)
	## 动态库导出
	ADD_DEFINITIONS(-D${PROJECTNAMEU}_LIBRARY)
	## 插件特殊标记
	ADD_DEFINITIONS(-DQT_PLUGIN -DQT_DLL)
	##构造目标项目
	WIS_QT_INIT_COMMON_LIB("PLUGIN" ${HAS_QM})
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_QT_INIT_PLUGIN_MODULE_PCH )
###############################################################################
# 控制台应用程序
#
MACRO(WIS_QT_INIT_CONSOLE_EXE_MODULE 
	HAS_QM)
	##构造目标项目
	WIS_QT_INIT_CONSOLE_EXE_MODULE_PCH(${HAS_QM} "" "")	
ENDMACRO(WIS_QT_INIT_CONSOLE_EXE_MODULE)
#_______________________________________________________________________________
# 依赖于Qt的控制台应用程序 带预编译头
#
#
MACRO(WIS_QT_INIT_CONSOLE_EXE_MODULE_PCH
	HAS_QM
	PrecompiledHeader PrecompiledSource)
	##构造目标项目
	WIS_QT_INIT_COMMON_LIB("CONSOLE" ${HAS_QM})
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_QT_INIT_CONSOLE_EXE_MODULE_PCH)
#_______________________________________________________________________________
# 依赖于Qt的可执行程序
#
#
MACRO(WIS_QT_INIT_EXE_MODULE 
	HAS_QM)
	##构造目标项目
	WIS_QT_INIT_EXE_MODULE_PCH(${HAS_QM} "" "")	
ENDMACRO(WIS_QT_INIT_EXE_MODULE)
#_______________________________________________________________________________
# 依赖于Qt的可执行程序 带预编译头
#
#
MACRO(WIS_QT_INIT_EXE_MODULE_PCH
	HAS_QM
	PrecompiledHeader PrecompiledSource)
	##构造目标项目
	WIS_QT_INIT_COMMON_LIB("EXE" ${HAS_QM})
	## 预编译头设置
	WIS_INIT_PCH("${PrecompiledHeader}" "${PrecompiledSource}")
ENDMACRO(WIS_QT_INIT_EXE_MODULE_PCH)
