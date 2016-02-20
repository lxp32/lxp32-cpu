cmake_minimum_required(VERSION 3.3.0)

add_executable(lxp32asm assembler.cpp linkableobject.cpp linker.cpp main.cpp outputwriter.cpp utils.cpp)

if(MSVC)
# Make the program expand wildcard command-line arguments
	set_target_properties(lxp32asm PROPERTIES LINK_FLAGS "setargv.obj")
endif()

# Install

install(TARGETS lxp32asm DESTINATION .)
