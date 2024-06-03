#include <iostream>
//#include <thread>
#include <boost/asio.hpp>
#include "app/sub_program.hpp"
namespace app
{
namespace applications
{
//----------------------------------------------------------------------------//
int main_real_socket_test(::std::vector< ::std::string > arguments)
{
  ::std::string interface = "127.0.0.1";
  unsigned short port = 58432;
  if(arguments.at(0) == "--client")
  {
    // client example
    try
    {
      ::boost::asio::io_service io_service;
      ::boost::asio::ip::tcp::socket socket(io_service);
      ::boost::asio::ip::tcp::endpoint endpoint(
        ::boost::asio::ip::address::from_string(interface), port);
      socket.connect(endpoint);

      ::std::string str_to_send("This is a test string");
      size_t message_size = str_to_send.size();
      auto b1 = ::boost::asio::buffer(&message_size, sizeof(message_size));
      auto b2 = ::boost::asio::buffer(str_to_send);
      socket.send(b1);
      socket.send(b2);
    }
    catch (::std::exception& e)
    {
      ::std::cerr << "Exception: " << e.what() << "\n";
    }
  }
  else
  {
    // server example
    try
    {
      ::boost::asio::io_context io_context;
      ::boost::asio::ip::tcp::acceptor a(io_context,
        ::boost::asio::ip::tcp::endpoint(::boost::asio::ip::tcp::v4(), port));
//      ::std::thread(session, a.accept()).detach();
      ::boost::asio::ip::tcp::socket sock = a.accept();
      const int max_length = 1024;
      try
      {
        for (;;)
        {
          char data[max_length];

          ::boost::system::error_code error;
          size_t length = sock.read_some(::boost::asio::buffer(data), error);
          if (error == ::boost::asio::error::eof)
          {
            break; // Connection closed cleanly by peer.
          }
          else if (error)
          {
            throw ::boost::system::system_error(error); // Some other error.
          }

          ::std::cout.write(data, static_cast<::std::streamsize>(length));
          ::std::cout.flush();
          ::boost::asio::write(sock, ::boost::asio::buffer(data, length));
        }
      }
      catch (::std::exception& e)
      {
        ::std::cerr << "Exception in thread: " << e.what() << "\n";
      }
    }
    catch (::std::exception& e)
    {
      ::std::cerr << "Exception: " << e.what() << "\n";
    }
  }

  return EXIT_SUCCESS;
}
//----------------------------------------------------------------------------//
REGISTER_SUB_PROGRAM(real_socket_test, &main_real_socket_test, {"--server"})
} // namespace applications
} // namespace app

