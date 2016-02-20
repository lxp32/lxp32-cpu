cmake_minimum_required(VERSION 3.3.0)
project(lxp32tools)

# Examine environment

if(CMAKE_C_COMPILER_ID STREQUAL GNU OR CMAKE_C_COMPILER_ID STREQUAL Clang)
	set(GNU_SYNTAX TRUE)
endif()

# Set default install prefix if not manually set by the user

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	set(CMAKE_INSTALL_PREFIX "${PROJECT_SOURCE_DIR}/../bin" CACHE PATH "Install prefix" FORCE)
endif()

message("Install prefix: ${CMAKE_INSTALL_PREFIX}")

# Enable C++11

set(CMAKE_CXX_STANDARD 11)

# Set up warning level for GCC/Clang

if(GNU_SYNTAX)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pedantic -Wall -Wextra")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic -Wall -Wextra")
endif()

# On Windows, link runtime statically

if(WIN32)
	if(GNU_SYNTAX)
		set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static")
	elseif(MSVC)
		foreach(flag_var
			CMAKE_C_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_C_FLAGS_RELEASE
			CMAKE_C_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
			CMAKE_CXX_FLAGS CMAKE_CXX_FLAGS_DEBUG CMAKE_CXX_FLAGS_RELEASE
			CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_CXX_FLAGS_RELWITHDEBINFO
		)
			string(REGEX REPLACE "/MD" "/MT" ${flag_var} "${${flag_var}}")
		endforeach(flag_var)
	endif()
endif()

# Build targets

add_subdirectory(lxp32asm)
add_subdirectory(lxp32dump)
add_subdirectory(wigen)
