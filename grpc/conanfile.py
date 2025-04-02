import os
from conans import ConanFile, CMake
# ============================================================================ #
class conan_test_recipe(ConanFile):
  name = "test"
  version = "0.1"
  settings = "os", "compiler", "build_type", "arch"

  description = "gRPC implementation."
  url = "https://paul.grozav.info"
  license = "Proprietary software"
  requires = (
    ("grpc/1.25.0@inexorgame/stable")
  )
  generators = "cmake"
# ============================================================================ #
  def build(self):
    # Get paths to protoc and grpc protoc plugin
    # They are passesd to CMake to build the files.
    protoc_bin = os.path.join(self.deps_cpp_info["protoc_installer"]\
      .bin_paths[0], "protoc")
    self.output.info("protoc = " + protoc_bin)

    grpc_plugin_bin = os.path.join(self.deps_cpp_info["grpc"]\
      .bin_paths[0], "grpc_cpp_plugin")
    self.output.info("grpc_plugin_bin_path = " + grpc_plugin_bin)

    cmake = CMake(self)
    cmake.definitions["protoc_bin_path"] = protoc_bin
    cmake.definitions["grpc_plugin_bin_path"] = grpc_plugin_bin
    cmake.configure()
    cmake.build()
# ============================================================================ #
  def package(self):
    self.copy("build/bin/conan_test", dst="bin", keep_path=False)
# ============================================================================ #

