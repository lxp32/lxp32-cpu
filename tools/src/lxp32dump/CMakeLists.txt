cmake_minimum_required(VERSION 3.3.0)

add_executable(lxp32dump disassembler.cpp main.cpp)

# Install

install(TARGETS lxp32dump DESTINATION .)
