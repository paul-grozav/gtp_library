// -------------------------------------------------------------------------- //
// Author: Tancredi-Paul Grozav <paul@grozav.info>
// -------------------------------------------------------------------------- //
#include <iostream>
#include <memory>
#include <string>

#include <grpcpp/grpcpp.h>

#include "rpc.grpc.pb.h"

using namespace ::std;
using ::grpc::Channel;
using ::grpc::ClientContext;
using ::grpc::Status;
using ::info::grozav::paul::hello_request;
using ::info::grozav::paul::hello_reply;
using ::info::grozav::paul::greeter;
// -------------------------------------------------------------------------- //
class greeter_client
{
 public:
  greeter_client(std::shared_ptr<Channel> channel)
      : stub_(greeter::NewStub(channel)) {}

  // Assembles the client's payload, sends it and presents the response back
  // from the server.
  string say_hello(const string& user)
  {
    // Data we are sending to the server.
    hello_request request;
    request.set_name(user);

    // Container for the data we expect from the server.
    hello_reply reply;

    // Context for the client. It could be used to convey extra information to
    // the server and/or tweak certain RPC behaviors.
    ClientContext context;

    // The actual RPC.
    Status status = stub_->say_hello(&context, request, &reply);

    // Act upon its status.
    if (status.ok())
    {
      return reply.message();
    }
    else
    {
      cout << status.error_code() << ": " << status.error_message() << endl;
      return "RPC failed";
    }
  }

 private:
  unique_ptr<greeter::Stub> stub_;
};
// -------------------------------------------------------------------------- //
int main(int argc, char** argv)
{
  cout << "I am client" << endl;
  // Instantiate the client. It requires a channel, out of which the actual RPCs
  // are created. This channel models a connection to an endpoint specified by
  // the argument "--target=" which is the only expected argument.
  // We indicate that the channel isn't authenticated (use of
  // InsecureChannelCredentials()).
  string target_str;
  string arg_str("--target");
  if (argc > 1)
  {
    string arg_val = argv[1];
    size_t start_pos = arg_val.find(arg_str);
    if (start_pos != string::npos)
    {
      start_pos += arg_str.size();
      if (arg_val[start_pos] == '=')
      {
        target_str = arg_val.substr(start_pos + 1);
      }
      else
      {
        cout << "The only correct argument syntax is --target=" << endl;
        return 0;
      }
    }
    else
    {
      cout << "The only acceptable argument is --target=" << endl;
      return 0;
    }
  }
  else
  {
    target_str = "localhost:50051";
  }
  greeter_client greeter(grpc::CreateChannel(
    target_str, grpc::InsecureChannelCredentials()));
  string user("client");
  string reply = greeter.say_hello(user);
  cout << "Greeter received: " << reply << endl;
  return 0;
}
// -------------------------------------------------------------------------- //

