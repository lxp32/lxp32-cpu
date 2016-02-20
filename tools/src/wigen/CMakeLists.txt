cmake_minimum_required(VERSION 3.3.0)

add_executable(wigen generator.cpp main.cpp range.cpp)

# Install

install(TARGETS wigen DESTINATION .)
