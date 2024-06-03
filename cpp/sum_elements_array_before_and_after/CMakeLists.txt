# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
cmake_minimum_required(VERSION 2.8)
project(bit_processor C)
set(CMAKE_VERBOSE_MAKEFILE true)

# Compile executable
include_directories(inc)
add_executable(main
  src/main.c
  src/find_index.c
)

option(build_unit_tests "Build unit tests binary" OFF)
if(build_unit_tests)
  add_executable(unit_tests
    src/unit_tests.c
    src/find_index.c
  )
endif(build_unit_tests)

