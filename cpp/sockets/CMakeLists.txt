# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
cmake_minimum_required(VERSION 3.30)
project(my_app)
set(CMAKE_VERBOSE_MAKEFILE true)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# include_directories(inc)

# Compile executable
add_executable(main
  src/main.cpp
  src/ServerSocket.cpp
)
# ============================================================================ #
