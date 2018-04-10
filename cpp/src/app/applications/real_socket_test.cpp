#include <iostream>
#include <boost/asio.hpp>
#include "app/sub_program.hpp"
namespace app::applications
{
int main_real_socket_test(int argc, char* argv[])
{
  try
  {
    if (argc != 3)
    {
      ::std::cerr << "Usage: asioclient <ip> <port>\n";
      return 1;
    }
    int port = atoi(argv[2]);

    boost::asio::io_service io_service;
    boost::asio::ip::tcp::socket socket(io_service);
    boost::asio::ip::tcp::endpoint endpoint(
        boost::asio::ip::address::from_string(argv[1]), port);
    socket.connect(endpoint);

    ::std::string str_to_send("This is a test string");
    unsigned int message_size = str_to_send.size();
    auto b1 = ::boost::asio::buffer (&message_size,sizeof(message_size));
    auto b2 = ::boost::asio::buffer (str_to_send);
    socket.send(b1);
    socket.send(b2);
  }
  catch (::std::exception& e)
  {
    std::cerr << "Exception: " << e.what() << "\n";
  }

  return EXIT_SUCCESS;
}
REGISTER_SUB_PROGRAM(real_socket_test, &main_real_socket_test)
} // namespace app::applications