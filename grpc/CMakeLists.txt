# ============================================================================ #
project(test)
cmake_minimum_required(VERSION 2.8)
set(CMAKE_VERBOSE_MAKEFILE on)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()
# ============================================================================ #
message("protoc_bin_path=${protoc_bin_path}")
message("grpc_plugin_bin_path=${grpc_plugin_bin_path}")
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/src/proto)

set(protoc_cpp_out ${CMAKE_BINARY_DIR}/src/proto)
macro(compile_proto_file file)
  get_filename_component(file_dirname ${file} PATH)
  get_filename_component(file_basename ${file} NAME_WE)
  add_custom_command(
    OUTPUT
      ${protoc_cpp_out}/${file_basename}.pb.h
      ${protoc_cpp_out}/${file_basename}.pb.cc
    DEPENDS ${protoc_bin_path} ${file}
    COMMENT "Compiling protobuf file: ${file}"
    COMMAND ${protoc_bin_path} ${file}
      --proto_path=${file_dirname}
      --cpp_out=${protoc_cpp_out}
  )
endmacro(compile_proto_file)
macro(compile_grpc_file file)
  get_filename_component(file_dirname ${file} PATH)
  get_filename_component(file_basename ${file} NAME_WE)
  add_custom_command(
    OUTPUT
      ${protoc_cpp_out}/${file_basename}.grpc.pb.h
      ${protoc_cpp_out}/${file_basename}.grpc.pb.cc
    DEPENDS ${protoc_bin_path} ${grpc_plugin_bin_path} ${file}
    COMMENT "Compiling protobuf file: ${file}"
    COMMAND ${protoc_bin_path} ${file}
      --proto_path=${file_dirname}
      --grpc_out=${protoc_cpp_out}
      --plugin=protoc-gen-grpc=${grpc_plugin_bin_path}
  )
endmacro(compile_grpc_file)
# ============================================================================ #
compile_grpc_file(${CMAKE_SOURCE_DIR}/src/proto/rpc.proto)
compile_proto_file(${CMAKE_SOURCE_DIR}/src/proto/rpc.proto)

include_directories(${protoc_cpp_out})
set(proto_project_files
  # Proto generated files
  ${CMAKE_BINARY_DIR}/src/proto/rpc.pb.h
  ${CMAKE_BINARY_DIR}/src/proto/rpc.pb.cc
  ${CMAKE_BINARY_DIR}/src/proto/rpc.grpc.pb.h
  ${CMAKE_BINARY_DIR}/src/proto/rpc.grpc.pb.cc
)

add_executable(server
  ${CMAKE_SOURCE_DIR}/src/server.cpp
  ${proto_project_files}
)
# Reflection for:
# https://grpc.github.io/grpc/cpp/md_doc_server_reflection_tutorial.html
target_link_libraries(server ${CONAN_LIBS} grpc++_reflection)


add_executable(client
  ${CMAKE_SOURCE_DIR}/src/client.cpp
  ${proto_project_files}
)
target_link_libraries(client ${CONAN_LIBS})
# ============================================================================ #
