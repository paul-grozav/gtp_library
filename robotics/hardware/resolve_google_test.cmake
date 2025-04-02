# Author : Tancredi-Paul Grozav <paul@grozav.info>
# ============================================================================ #
#
# Resolve: Google Testing and Mocking Framework(library)
#
# Input variables:
# - depend_gtest_include_path - optional - Path to directory containing gtest
#   header files
# - depend_gtest_library_path - optional - Path to compiled gtest library file
# - depend_gmock_include_path - optional - Path to directory containing gmock
#   header files
# - depend_gmock_library_path - optional - Path to compiled gmock library file
# - external_projects_base_dir - required - working directory for external
#   projects
# - git_base - required - git base url for downloading dependency
#
# This method downloads gtest project and compiles both the testing and mocking
# libraries.
#
# ============================================================================ #
if ((NOT DEFINED depend_gtest_include_path) OR
  (NOT DEFINED depend_gtest_library_path) OR
  (NOT DEFINED depend_gmock_include_path) OR
  (NOT DEFINED depend_gmock_library_path))

  message(STATUS "No GTest or GMock dependency paths were given. "
    "Will download dependency.")

  # Set library names on different OSes
  if (${WIN32})
    set( ep_gtest_library_name gtest_main.lib )
    set( ep_gmock_library_name gmock_main.lib )

    # on windows, let msbuild to select build type
    set(EXTERNAL_PROJ_CMAKE_ARGS "")
  else (${WIN32})
    set( ep_gtest_library_name libgtest_main.a )
    set( ep_gmock_library_name libgmock_main.a )
    set(EXTERNAL_PROJ_CMAKE_ARGS "-DCMAKE_BUILD_TYPE=Release")
  endif (${WIN32})

  # Download and build
  include(ExternalProject) # Enable ExternalProject CMake module
  ExternalProject_Add(gtest
    GIT_REPOSITORY    https://github.com/google/googletest.git
    GIT_TAG           5e7fd50e17b6edf1cadff973d0ec68966cf3265e
    SOURCE_DIR        ${external_projects_base_dir}/Source/googletest
    BINARY_DIR        ${external_projects_base_dir}/Install/googletest
    CMAKE_ARGS        ${EXTERNAL_PROJ_CMAKE_ARGS}
    INSTALL_COMMAND   "" # Do not run install command
    UPDATE_COMMAND    "" # Do not run update command
  )
  # Get external project source and binary directories
  ExternalProject_Get_Property(gtest source_dir binary_dir)

  # Add google test to include paths
  set(depend_gtest_include_path
    ${source_dir}/googletest/include)

  if(${WIN32})
    set(depend_gtest_library_path
      ${binary_dir}/googlemock/gtest/Release/${ep_gtest_library_name})
  else(${WIN32})
    set(depend_gtest_library_path
      ${binary_dir}/googlemock/gtest/${ep_gtest_library_name})
  endif(${WIN32})

  # Add google mock to include paths
  set(depend_gmock_include_path
    ${source_dir}/googlemock/include)

  if(${WIN32})
    set(depend_gmock_library_path
      ${binary_dir}/googlemock/Release/${ep_gmock_library_name})
  else(${WIN32})
    set(depend_gmock_library_path
      ${binary_dir}/googlemock/${ep_gmock_library_name})
  endif(${WIN32})

  # Unset used variables
  unset(source_dir)
  unset(binary_dir)
  unset(ep_gtest_library_name)
  unset(ep_gmock_library_name)
  unset(EXTERNAL_PROJ_CMAKE_ARGS)
else ((NOT DEFINED depend_gtest_include_path) OR
  (NOT DEFINED depend_gtest_library_path) OR
  (NOT DEFINED depend_gmock_include_path) OR
  (NOT DEFINED depend_gmock_library_path))

  message(STATUS "GTest & GMock dependency paths are set. Will not resolve "
    "dependency")

endif ((NOT DEFINED depend_gtest_include_path) OR
  (NOT DEFINED depend_gtest_library_path) OR
  (NOT DEFINED depend_gmock_include_path) OR
  (NOT DEFINED depend_gmock_library_path))

# Print values that will be used
message("depend_gtest_include_path: ${depend_gtest_include_path}")
message("depend_gtest_library_path: ${depend_gtest_library_path}")
message("depend_gmock_include_path: ${depend_gmock_include_path}")
message("depend_gmock_library_path: ${depend_gmock_library_path}")

