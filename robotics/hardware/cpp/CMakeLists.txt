# ============================================================================ #
# Author: Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
project(hardware)
cmake_minimum_required(VERSION 2.8)
set(CMAKE_CXX_STANDARD 11) # Activate C++ 11
set(CMAKE_DEBUG_POSTFIX _dbg)
option(build_demo "Should I build the demo application?" OFF)
option(build_unit_tests "Should I build the unit_tests application?" OFF)
# ============================================================================ #
# Library
include_directories(src)

add_library(hardware
  src/hardware/electric_value.hpp
  src/hardware/pin.hpp
  src/hardware/pin.cpp
)
# ============================================================================ #
# Demo executable
if(build_demo)
  add_executable(demo
    src/hardware_demo/main.cpp
  )
  target_link_libraries(demo
    hardware
  )
endif(build_demo)
# ============================================================================ #
# Unit tests executable
if(build_unit_tests)
  set(dependencies_dir ${CMAKE_BINARY_DIR}/dependencies)
  set(external_projects_base_dir ${dependencies_dir}/external_projects)
  set_property(DIRECTORY PROPERTY "EP_BASE" ${external_projects_base_dir})
  include(${CMAKE_CURRENT_SOURCE_DIR}/resolve_google_test.cmake)

  include_directories(
    ${depend_gtest_include_path}
    ${depend_gmock_include_path}
  )
  add_executable(unit_tests
    src/hardware_tests/pin.cpp
  )
  set(pthread_lib pthread)
  if(WIN32)
    set(pthread_lib "")
  endif(WIN32)
  target_link_libraries(unit_tests
    hardware
    ${depend_gtest_library_path}
    ${depend_gmock_library_path}
    ${pthread_lib}
  )
  add_dependencies(unit_tests gtest)
endif(build_unit_tests)
# ============================================================================ #
