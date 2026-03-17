/*
 * ServerSocket.cpp
 *
 * Created on: Mar 12, 2013
 * Author: Tancredi-Paul Grozav <paul@grozav.info>
 */

#include "ServerSocket.hpp"

void ServerSocketSignalChildHandler(int s)
{
  while (waitpid(-1, NULL, WNOHANG) > 0)
    ;
}

ServerSocket::ServerSocket(int port)
{
  // Creating and filling the hints structure, used to create the servinfo
  // structure
  struct addrinfo hints; // filled out with relevant information
  memset(&hints, 0, sizeof hints); // make sure the struct is empty
  hints.ai_family = AF_UNSPEC; // don't care IPv4 or IPv6
  hints.ai_socktype = SOCK_STREAM; // TCP stream sockets
  hints.ai_flags = AI_PASSIVE; // use my IP

  // make servinfo point to a linked list of 1 or more struct addrinfos
  // will point to the results (holds the interfaces)
  struct addrinfo *servinfo;
  int rv;
  if ((rv = getaddrinfo(NULL, portToCharArray(port), &hints, &servinfo)) != 0)
  {
    fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
    exit(1);
  }

  // loop through all the results and bind to the first we can
  struct addrinfo *p;
  for (p = servinfo; p != NULL; p = p->ai_next)
  {
    if ((socketFileDescriptor = socket(p->ai_family, p->ai_socktype,
      p->ai_protocol)) == -1)
    {
      perror("server: Can not call socket() on that interface");
      continue;
    }

    int yes = 1;
    if (setsockopt(socketFileDescriptor, SOL_SOCKET, SO_REUSEADDR, &yes,
      sizeof(int)) == -1)
    {
      perror("Can not call setsockopt() on that interface");
      exit(1);
    }

    if (bind(socketFileDescriptor, p->ai_addr, p->ai_addrlen) == -1)
    {
      close (socketFileDescriptor);
      perror("server: Can not call bind() on that interface");
      continue;
    }

    break;
  }

  // If we reached the end of the list
  if (p == NULL)
  {
    fprintf(stderr, "server: failed to bind\n");
    exit(2);
  }
  // free the servinfo variable
  freeaddrinfo(servinfo); // all done with this structure
  // we now have the sockfd structure

  int backLog = 10; // how many pending connections queue will hold

  if (listen(socketFileDescriptor, backLog) == -1)
  {
    perror("Can not listen() on that socket");
    exit(1);
  }

  // reap all dead processes
  // This code is responsible for reaping zombie processes
  // that appear as the fork()ed child processes exit.
  // If you make lots of zombies and don't reap them,
  // your system administrator will become agitated.
  struct sigaction sa;
  sa.sa_handler = &ServerSocketSignalChildHandler;
  sigemptyset(&sa.sa_mask);
  sa.sa_flags = SA_RESTART;
  if (sigaction(SIGCHLD, &sa, NULL) == -1)
  {
    perror("sigaction");
    exit(1);
  }
}

ServerSocket::~ServerSocket()
{
}

void ServerSocket::acceptClient(
  PointerToClientHandlerFunction clientHandlerFunction)
{
  ServerSocket::ClientSocket clientSocket;
  char s[INET6_ADDRSTRLEN];
  socklen_t sin_size = sizeof clientSocket.clientAddr;
  clientSocket.connectionFileDescriptor = accept(socketFileDescriptor,
    (struct sockaddr *) &clientSocket.clientAddr, &sin_size);
  if (clientSocket.connectionFileDescriptor == -1)
  {
    perror("Can not accept() the connection");
    // continue;
  }
  printf("Connection accepted\n");

  if (((struct sockaddr *) &clientSocket.clientAddr)->sa_family == AF_INET)
  { //IPv4 address
    inet_ntop(clientSocket.clientAddr.ss_family,
      &(((struct sockaddr_in*) ((struct sockaddr *) &clientSocket
        .clientAddr))->sin_addr), s, sizeof s);
  }
  else
  { //IPv6 address
    inet_ntop(clientSocket.clientAddr.ss_family,
      &(((struct sockaddr_in6*) ((struct sockaddr *) &clientSocket
        .clientAddr))->sin6_addr), s, sizeof s);
  }
  printf("Got connection from %s\n", s);

  pid_t pid = fork();
  if (pid == -1)
  {
    perror("Can not fork()");
  }
  else if (pid == 0)
  { // this is the child process
    exit(clientHandlerFunction(clientSocket));
  }
  else
  {
    printf("pid = %d > 0", pid);
  }
  close(clientSocket.connectionFileDescriptor); // parent doesn't need this
}

char* ServerSocket::portToCharArray(int port)
{
  int base = 10;
  static char buf[32] = { 0 };
  int i = 30;
  for (; port && i; --i, port /= base)
    buf[i] = "0123456789abcdef"[port % base];
  return &buf[i + 1];
}