################################################################################
# Config.cmake - CMake build configuration of st_asio_wrapper library
################################################################################

INCLUDE(CheckCXXSymbolExists)

if(WIN32)
  check_cxx_symbol_exists("_M_AMD64" "" WIS_TARGET_ARCH_X64)
  if(NOT RTC_ARCH_X64)
    check_cxx_symbol_exists("_M_IX86" "" WIS_TARGET_ARCH_X86)
  endif(NOT RTC_ARCH_X64)
  # add check for arm here
  # see http://msdn.microsoft.com/en-us/library/b0084kay.aspx
else(WIN32)
  check_cxx_symbol_exists("__i386__" "" WIS_TARGET_ARCH_X86)
  check_cxx_symbol_exists("__x86_64__" "" WIS_TARGET_ARCH_X64)
  check_cxx_symbol_exists("__arm__" "" WIS_TARGET_ARCH_ARM)
endif(WIN32)

#
# C++11 Option
#
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
if(COMPILER_SUPPORTS_CXX11)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
	set (WIS_CXX_C11 OFF CACHE BOOL "Build to the C++11 standard")
else()
    message(STATUS "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
	set (WIS_CXX_C11 OFF)
endif()
#
# Force compilation flags and set desired warnings level
#

if (MSVC)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
  add_definitions(-D_CRT_SECURE_NO_WARNINGS)
  add_definitions(-D_CRT_NONSTDC_NO_WARNING)
  add_definitions(-D_SCL_SECURE_NO_WARNINGS)

  if(CMAKE_CXX_FLAGS MATCHES "/W[0-4]")
    string(REGEX REPLACE "/W[0-4]" "/W4" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
  else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /W4819")
  endif()

else()

  set(WIS_GCC_CLANG_COMMON_FLAGS
	"-pedantic -Werror -Wno-error=parentheses -Wall -Wpointer-arith -Wcast-align -Wcast-qual -Wfloat-equal -Wredundant-decls -Wno-long-long")


if (WIS_CXX_C11)
	set(WIS_CXX_VERSION_FLAGS "-std=c++11")
else()
	set(WIS_CXX_VERSION_FLAGS "-std=gnu++98")
endif()

  if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)

    if(NOT CMAKE_CXX_COMPILER_VERSION LESS 4.8 AND WIS_ASAN)
      set(WIS_GCC_CLANG_COMMON_FLAGS "${WIS_GCC_CLANG_COMMON_FLAGS} -fsanitize=address")
    endif()

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WIS_GCC_CLANG_COMMON_FLAGS} ${WIS_CXX_VERSION_FLAGS} ")
    if (CMAKE_COMPILER_IS_GNUCXX)
        if (CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
        else()
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-variadic-macros")
        endif()
    endif()

  elseif("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang" OR "${CMAKE_CXX_COMPILER}" MATCHES "clang")

    if(NOT CMAKE_CXX_COMPILER_VERSION LESS 3.1 AND WIS_ASAN)
      set(WIS_GCC_CLANG_COMMON_FLAGS "${WIS_GCC_CLANG_COMMON_FLAGS} -fsanitize=address")
    endif()

    # enforce C++11 for Clang
    set(WIS_CXX_C11 ON)
    set(WIS_CXX_VERSION_FLAGS "-std=c++11")
    add_definitions(-DCATCH_CONFIG_CPP11_NO_IS_ENUM)

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${WIS_GCC_CLANG_COMMON_FLAGS} ${WIS_CXX_VERSION_FLAGS}")

  else()
	message(WARNING "Unknown toolset - using default flags to build wiSCADA library")
  endif()

endif()
IF (MSVC)
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -wd4819")	
ENDIF()

# Set WIS_HAVE_* variables for wis-config.h generator
set(WIS_HAVE_CXX_C11 ${WIS_CXX_C11} CACHE INTERNAL "Enables C++11 support")

SET(CMAKE_DEFAULT_BUILD_TYPE "Debug" CACHE STRING "Variable that stores the default CMake build type" FORCE)

IF(NOT CMAKE_BUILD_TYPE)
   SET( CMAKE_BUILD_TYPE
    ${CMAKE_DEFAULT_BUILD_TYPE} CACHE STRING
    "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel."
    FORCE)
ENDIF(NOT CMAKE_BUILD_TYPE)
IF(CMAKE_BUILD_TYPE MATCHES Debug)
	ADD_DEFINITIONS(-DCMAKE_VERBOSE_MAKEFILE=ON)
ENDIF(CMAKE_BUILD_TYPE MATCHES Debug)

# 动态链接库输出规则
if(WIN32)
	#Postfix of xxxd.x
	set(WIS_DEBUG_POSTFIX d)
else(APPLE)
	#Postfix of xxx_debug.x
	set(WIS_DEBUG_POSTFIX _debug)
 ELSE()
	#Postfix of xxx.x
	set(WIS_DEBUG_POSTFIX "")
endif()

if(DEFINED CMAKEWIS_DEBUG_POSTFIX)
	set(WIS_DEBUG_POSTFIX "${CMAKEWIS_DEBUG_POSTFIX}")
endif()

IF (CMAKE_BUILD_TYPE MATCHES Debug)
	ADD_DEFINITIONS (-DWIS_DEBUG_POSTFIX="${WIS_DEBUG_POSTFIX}")	
ENDIF (CMAKE_BUILD_TYPE MATCHES Debug)