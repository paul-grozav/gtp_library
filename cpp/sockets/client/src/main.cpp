// -------------------------------------------------------------------------- //
// Author: Tancredi-Paul Grozav <paul@grozav.info>
// -------------------------------------------------------------------------- //
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

void die(const char *msg)
{
  // Print the message to standart error output stream
  perror(msg);
  // Exit the program with the errorCode 1
  exit(1);
}

typedef void (*PointerToHandlerFunction)(int socketFileDescriptor);

void clientSocket_connect(const char* hostAddress, int port,
  PointerToHandlerFunction handler)
{
  // Creating the socketFileDescriptor
  int socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0);
  // Die if the socketFileDescriptor could not be created
  if (socketFileDescriptor < 0)
    die("ERROR opening socket");

  // Get the server host
  struct hostent* server = gethostbyname(hostAddress);
  // Die if the server info could not be loaded
  if (server == NULL)
    die("ERROR, no such host\n");

  // Create the serverAddress structure
  // Define the serverAddress structure
  struct sockaddr_in serverAddress;
  // Zero-fill the structure
  bzero((char*) &serverAddress, sizeof(serverAddress));
  // Set the sin_family member
  serverAddress.sin_family = AF_INET;
  // Set the HOST ADDRESS
  bcopy((char*) server->h_addr, (char*)&serverAddress.sin_addr.s_addr,
    server->h_length);
  // Set the PORT NUMBER
  serverAddress.sin_port = htons(port);

  // Connect to the server using the serverAddress structure or die
  if (connect(socketFileDescriptor, (struct sockaddr*) &serverAddress,
    sizeof(serverAddress)) < 0)
    die("ERROR connecting");

  // Call the handler function
  handler(socketFileDescriptor);

  // Close the socket
  close(socketFileDescriptor);
}

void connectionHandler(int socketFileDescriptor)
{
  // Send data
  // Define the buffer
  char buffer[256];
  // Set the message in that buffer (bytes to be sent)
  strcpy(buffer,
    "GET /maya/ HTTP/1.1nhost: debian.server.paul.grozav.infon\n");
  // Write the bytes to the socket
  int n = write(socketFileDescriptor, buffer, strlen(buffer));
  // Die if you couldn't write those bytes
  if (n < 0)
    die("ERROR writing to socket");

  // Clear the buffer - we'll read data to the same buffer
  bzero(buffer, 256);

  // Read data to buffer
  // Read from socket and store to buffer
  n = read(socketFileDescriptor, buffer, 255);
  // Die if you couldn't read
  if (n < 0)
    die("ERROR reading from socket");

  // Print the received bytes
  printf("%s\n", buffer);
}

int main(int argc, char* argv[])
{
  clientSocket_connect("debian.server.paul.grozav.info", 80,
    &connectionHandler);
  return 0;
}
