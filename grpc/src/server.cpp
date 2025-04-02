// -------------------------------------------------------------------------- //
// Author: Tancredi-Paul Grozav <paul@grozav.info>
// -------------------------------------------------------------------------- //
#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>
#include <grpcpp/health_check_service_interface.h>
#include <grpcpp/ext/proto_server_reflection_plugin.h>

#include "rpc.grpc.pb.h"

using namespace ::std;
using ::grpc::Server;
using ::grpc::ServerBuilder;
using ::grpc::ServerContext;
using ::grpc::Status;
using ::info::grozav::paul::hello_request;
using ::info::grozav::paul::hello_reply;
using ::info::grozav::paul::greeter;

// -------------------------------------------------------------------------- //
// Logic and data behind the server's behavior.
class greeter_service_impl final : public greeter::Service
{
  Status say_hello(ServerContext* context, const hello_request* request,
    hello_reply* reply) override
  {
    std::string prefix("Hello ");
    reply->set_message(prefix + request->name());
    return Status::OK;
  }
};

void run_server()
{
  string server_address("0.0.0.0:50051");
  greeter_service_impl service;

  grpc::EnableDefaultHealthCheckService(true);
  grpc::reflection::InitProtoReflectionServerBuilderPlugin();
  ServerBuilder builder;
  // Listen on the given address without any authentication mechanism.
  builder.AddListeningPort(server_address, grpc::InsecureServerCredentials());
  // Register "service" as the instance through which we'll communicate with
  // clients. In this case it corresponds to an *synchronous* service.
  builder.RegisterService(&service);
  // Finally assemble the server.
  unique_ptr<Server> server(builder.BuildAndStart());
  cout << "Server listening on " << server_address << endl;

  // Wait for the server to shutdown. Note that some other thread must be
  // responsible for shutting down the server for this call to ever return.
  server->Wait();
}

int main(int argc, char** argv)
{
  cout << "I am server" << endl;
  run_server();
  return 0;
}
// -------------------------------------------------------------------------- //
