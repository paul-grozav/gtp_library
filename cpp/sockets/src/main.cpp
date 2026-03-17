// -------------------------------------------------------------------------- //
// Author: Tancredi-Paul Grozav <paul@grozav.info>
// -------------------------------------------------------------------------- //
/*!
 * main.cpp
 *
 * Created on: Mar 12, 2013
 * Author: Tancredi-Paul Grozav (paul@grozav.info)
 */
#include "ServerSocket.hpp"

/*! Handles a client. The int returned is the exit status of the PID created for
that client. */
int clientHandler(ServerSocket::ClientSocket clientSocket)
{
  // Receiving message
  char buffer[1024];
  printf("Waiting for message from client ...");
  if (recv(clientSocket.connectionFileDescriptor, &buffer, sizeof(buffer), 0)
    == -1)
    perror("Can not read from the socket");
  printf(" Client said: \"%s\"\n", buffer);

  // Sending message
  char message[1034];
  strcpy(message, "You said: ");
  strcat(message, buffer);
  printf("char* message = \"%s\"\n", message);
  printf("Sending a message to the client ...");
  if (send(clientSocket.connectionFileDescriptor, message, strlen(message), 0)
    == -1)
    perror("Can not write the message to the socket");
  printf(" Message sent\n");

  // Closing the socket
  printf("Disconnecting the client ...");
  close(clientSocket.connectionFileDescriptor);
  printf(" Socket closed!\n");
  return 0;
}

int main(int argc, char* argv[])
{
  ServerSocket s(1234);
  printf("server: waiting for connections...\n");
  while (1)
    s.acceptClient(&clientHandler);
  return 0;
}
// -------------------------------------------------------------------------- //
