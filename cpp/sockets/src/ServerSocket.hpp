/*!
* ServerSocket.h
*
* Created on: Mar 12, 2013
* Author: Tancredi-Paul Grozav <paul@grozav.info>
*/

#ifndef SERVERSOCKET_HPP_
#define SERVERSOCKET_HPP_

#include <stdio.h> //perror, stderr, printf, fprintf
#include <cstdlib> // exit
#include <unistd.h> // fork, close
#include <string.h> // memset
#include <netdb.h> // AI_PASSIVE, getaddrinfo, gai_strerror
#include <arpa/inet.h> // inet_ntop
#include <sys/wait.h> // waitpid

/*! This class simplifies the usage of sockets */
class ServerSocket {
public:
  struct ClientSocket {
    //! Connector's address information
    struct sockaddr_storage clientAddr;
    //! Client socket file descriptor
    int connectionFileDescriptor;
  };

  typedef int (*PointerToClientHandlerFunction)(ClientSocket);

  ServerSocket(int port);
  virtual ~ServerSocket();
  /*! This method must take as an argument, the pointer to a function that
  takes as a parameter a ServerSocket::ClientSocket and returns an int. The
  int is the PID exit status */
  void acceptClient(PointerToClientHandlerFunction clientHandlerFunction);

private:
  char* portToCharArray(int port);

  // listen on socketFileDescriptor
  int socketFileDescriptor;
};

#endif /* SERVERSOCKET_HPP_ */