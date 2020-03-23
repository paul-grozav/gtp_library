# Includes and function definitions
# ============================================================================ #
include(ExternalProject) # Enable ExternalProject CMake module

# glue the elements of a list.
# example:
#list(APPEND my_list element1 element2 element3)
#join("${my_list}" "," my_str)
#message(STATUS "my_str=${my_str}") # prints: element1,element2,element3
function(JOIN VALUES GLUE OUTPUT)
  string(REGEX REPLACE "([^\\]|^);" "\\1${GLUE}" _TMP_STR "${VALUES}")
  string(REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}") #fixes escaping
  set(${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)
endfunction()
# ============================================================================ #
# Project definition
# ============================================================================ #
project(gtp_cpp)
cmake_minimum_required(VERSION 2.8)
set(CMAKE_VERBOSE_MAKEFILE on)

# Compiler options for GNU and MSVC
if (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
  set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -MMD -Wall -std=c++11" )
elseif (${CMAKE_CXX_COMPILER_ID} STREQUAL "MSVC")
  set( CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT" )
else (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
  message(STATUS "unknow compiler")
endif (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")


set(source_directory src)
include_directories(${source_directory})

# Mark headers to be part of the cmake project, but not adding them to:
# add_executable, because they don't need to be compiled.
file(GLOB_RECURSE header_files
  ${source_directory}/gtp/*.hpp
  ${source_directory}/gtp/*/*/*.hpp

  ${source_directory}/app/*.hpp
  ${source_directory}/app/*/*.hpp
)
add_custom_target(headers SOURCES ${header_files})

list(APPEND cpp_files_common
  ${source_directory}/gtp/debugging_utils.cpp
  ${source_directory}/gtp/db/interface/mysql_result_set.cpp
  ${source_directory}/gtp/db/interface/mysql_connection.cpp
)
list(APPEND cpp_files_unit_test
  # No mock cpp files
  ${cpp_files_common}
)
list(APPEND cpp_files_app
  ${cpp_files_common}
  ${source_directory}/gtp/db/real/mysql_driver.cpp
  ${source_directory}/gtp/db/real/mysql_result_set.cpp
  ${source_directory}/gtp/db/real/mysql_connection.cpp
)

# ============================================================================ #
# GTP Library
# ============================================================================ #
# Requires mysql.h to be in include_path
add_library(${PROJECT_NAME}
  ${cpp_files_common}
  ${cpp_files_unit_test}
  ${cpp_files_app}
)

#if (${project_dependencies_length} GREATER 0)
#  add_dependencies(${PROJECT_NAME}
#    ${project_dependencies}
#  )
#endif (${project_dependencies_length} GREATER 0)
#target_link_libraries(${PROJECT_NAME}
#  ${ep_mysql_library} # MySQL C Connector
#  ${ep_dynamic_library} # "Dynamic Library" library
#)


# ============================================================================ #
# ========================== EXTERNAL DEPENDENCIES =========================== #
# ============================================================================ #
set(dependencies_dir ${CMAKE_BINARY_DIR}/dependencies)
set(external_projects_base_dir ${dependencies_dir}/external_projects)
set_property(DIRECTORY PROPERTY EP_BASE ${external_projects_base_dir})
#include_directories(${dependencies_dir})

# ================================= MySQL ==================================== #
# If don't exist defines depend_mysql_include_path and depend_mysql_library_path
if (${WIN32})
  set(mysql_library_name "libmysql.lib")
else (${WIN32})
  set(mysql_library_name "libmysqlclient.a")
endif (${WIN32})
if ((NOT DEFINED depend_mysql_include_path) OR
  (NOT DEFINED depend_mysql_library_path))
  message(STATUS "No MySQL dependency paths were given. "
    "Will download dependency.")
  if (${WIN32})
    set( ep_mysql_url "http://dev.mysql.com/get/Downloads/Connector-C/")
    set( ep_mysql_url "${ep_mysql_url}mysql-connector-c-6.1.6-winx64.zip")
  else (${WIN32})
    set( ep_mysql_url "http://dev.mysql.com/get/Downloads/Connector-C/")
    set( ep_mysql_url "${ep_mysql_url}mysql-connector-c-6.1.6-linux-glibc2.5-")
    set( ep_mysql_url "${ep_mysql_url}x86_64.tar.gz")
  endif (${WIN32})
  ExternalProject_Add(mysql
    URL                ${ep_mysql_url}
    URL_MD5            627d71c61dfad9048360c40ec822eac1
    BINARY_DIR         ${external_projects_base_dir}/Source/mysql
    CONFIGURE_COMMAND  ""
    BUILD_COMMAND      ""
    INSTALL_COMMAND    ""
    LOG_DOWNLOAD       ON
    LOG_CONFIGURE      ON
    LOG_BUILD          ON
    LOG_INSTALL        ON
  )
  add_dependencies(${PROJECT_NAME} mysql)
  ExternalProject_Get_Property(mysql binary_dir)
  set(ep_mysql_dir ${binary_dir})
  list(APPEND depend_mysql_include_path
    ${ep_mysql_dir}/include)
  list(APPEND depend_mysql_library_path
    ${ep_mysql_dir}/lib/${mysql_library_name})
  unset(binary_dir)
  unset(ep_mysql_url)
  unset(ep_mysql_dir)
  message(STATUS "Will use MySQL paths:")
  join("${depend_mysql_include_path}" " , " depend_mysql_include_path_str)
  message(STATUS "MySQL include paths: ${depend_mysql_include_path_str}")
  join("${depend_mysql_library_path}" " , " depend_mysql_library_path_str)
  message(STATUS "MySQL library paths: ${depend_mysql_library_path_str}")
else ((NOT DEFINED depend_mysql_include_path) OR
  (NOT DEFINED depend_mysql_library_path))
  message(STATUS "MySQL dependency paths are set. Using:")
  join(${depend_mysql_include_path} " , " depend_mysql_include_path_str)
  message(STATUS "MySQL include paths: ${depend_mysql_include_path_str}")
  join(${depend_mysql_library_path} " , " depend_mysql_library_path_str)
  message(STATUS "MySQL library paths: ${depend_mysql_library_path_str}")
endif ((NOT DEFINED depend_mysql_include_path) OR
  (NOT DEFINED depend_mysql_library_path))
unset(mysql_library_name)
# =============================== END MySQL ================================== #

# =============================== GoogleTest ================================= #
# If don't exist defines depend_gtest_include_path and depend_gtest_library_path
if ((NOT DEFINED depend_gtest_include_path) OR
  (NOT DEFINED depend_gtest_library_path))
  message(STATUS "No GTest or GMock dependency paths were given. "
    "Will download dependency.")
  ExternalProject_Add(gtest
    GIT_REPOSITORY    https://github.com/google/googletest.git
    GIT_TAG           master
    SOURCE_DIR        ${dependencies_dir}/googletest-src
    BINARY_DIR        ${dependencies_dir}/googletest-build
    CMAKE_ARGS        -DCMAKE_BUILD_TYPE=Release
    INSTALL_COMMAND   "" # Do not run install command
  )
  # Get external project source and binary directories
  set( ep_gtest_source_dir ${dependencies_dir}/googletest-src )
  set( ep_gtest_binary_dir ${dependencies_dir}/googletest-build )
  if (${WIN32})
    set( ep_gtest_library_name gtest.lib )
    set( ep_gmock_library_name gmock.lib )
  else (${WIN32})
    set( ep_gtest_library_name libgtest.a )
    set( ep_gmock_library_name libgmock.a )
  endif (${WIN32})
  # Add google test to include paths
  list(APPEND depend_gtest_include_path
    ${ep_gtest_source_dir}/googletest/include
    ${ep_gtest_source_dir}/googlemock/include
  )
  list(APPEND depend_gtest_library_path
    ${ep_gtest_binary_dir}/lib/${ep_gtest_library_name}
    ${ep_gtest_binary_dir}/lib/${ep_gmock_library_name}
  )
  message(STATUS "Will use GTest & GMock paths:")
  join("${depend_gtest_include_path}" " , " depend_gtest_include_path_str)
  message(STATUS "GTest include paths: ${depend_gtest_include_path_str}")
  join("${depend_gtest_library_path}" " , " depend_gtest_library_path_str)
  message(STATUS "GTest library paths: ${depend_gtest_library_path_str}")

  unset(ep_gtest_source_dir)
  unset(ep_gtest_binary_dir)
  unset(ep_gtest_library_name)
  unset(ep_gmock_library_name)
else ((NOT DEFINED depend_gtest_include_path) OR
    (NOT DEFINED depend_gtest_library_path))
  message(STATUS "GTest & GMock dependency paths are set. Using:")
  join("${depend_gtest_include_path}" " , " depend_gtest_include_path_str)
  message(STATUS "GTest include paths: ${depend_gtest_include_path_str}")
  join("${depend_gtest_library_path}" " , " depend_gtest_library_path_str)
  message(STATUS "GTest library paths: ${depend_gtest_library_path_str}")
endif ((NOT DEFINED depend_gtest_include_path) OR
  (NOT DEFINED depend_gtest_library_path))
# ============================ END Google Test =============================== #

# ================================ PThread =================================== #
if (${WIN32})
  set( depend_pthread_library "" )
else (${WIN32})
  set( depend_pthread_library pthread )
endif (${WIN32})
# ============================== END PThread ================================= #

# ============================ Dynamic Library =============================== #
if (${WIN32})
  set( depend_dynamic_library "" )
else (${WIN32})
  set( depend_dynamic_library dl )
endif (${WIN32})
# ========================== END Dynamic Library ============================= #

# ============================================================================ #
# ============================================================================ #
# ============================================================================ #

include_directories(
  ${depend_mysql_include_path}
  ${depend_gtest_include_path}
)

# ============================================================================ #
# Unit tests executable
# ============================================================================ #
add_executable(${PROJECT_NAME}_unit_tests
#  ${cpp_files_unit_test}
  ${source_directory}/main_unit_tests.cpp
  ${source_directory}/app/tests/example.cpp
)
#add_dependencies( ${PROJECT_NAME}_unit_tests
#  gtest
#)
target_link_libraries(${PROJECT_NAME}_unit_tests
  ${PROJECT_NAME} # Project GTP library
  ${depend_gtest_library_path} # Google Testing & Mocking Framework
  ${depend_pthread_library} # PThread required for gtest
)

# ============================================================================ #
# Main executable
# ============================================================================ #
add_executable(${PROJECT_NAME}_app
  ${source_directory}/main.cpp
  ${source_directory}/app/application.cpp
  ${source_directory}/app/sub_program.cpp
  # Sub programs
  ${source_directory}/app/applications/fast_query.cpp
  ${source_directory}/app/applications/detailed_query.cpp
)
#add_dependencies(${PROJECT_NAME}_app
#  mysql
#)
target_link_libraries(${PROJECT_NAME}_app
  ${PROJECT_NAME} # Project GTP library
  ${depend_mysql_library_path} # MySQL C Connector
  ${depend_pthread_library} # PThread required for gtest
  ${depend_dynamic_library} # "Dynamic Library" library
)
# ============================================================================ #
