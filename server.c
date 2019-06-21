#include <stdio.h> //perror, stderr, printf, fprintf, exit
#include <stdlib.h> // exit
#include <unistd.h> // fork, close
#include <string.h> // memset
#include <netdb.h> // AI_PASSIVE, getaddrinfo, gai_strerror
#include <arpa/inet.h> // inet_ntop
#include <sys/wait.h> // waitpid

/*
Compile and run using:
  gcc server.c -o server.exe && strace -T -tt -s 1024 -f ./server.exe 2>&1 | less -NS
*/


struct ClientSocket {
    //! Connector's address information
    struct sockaddr_storage clientAddr;
    //! Client socket file descriptor
    int connectionFileDescriptor;
};

typedef int (*PointerToClientHandlerFunction)(ClientSocket);

char* portToCharArray(int port)
{
    int base = 10;
    static char buf[32] =
    { 0 };
    int i = 30;
    for (; port && i; --i, port /= base)
        buf[i] = "0123456789abcdef"[port % base];
    return &buf[i + 1];
}

void ServerSocketSignalChildHandler(int s)
{
    while (waitpid(-1, NULL, WNOHANG) > 0)
        ;
}

void server(int port, int *socket_file_descriptor)
{
    //Creating and filling the hints structure, used to create the servinfo structure
    struct addrinfo hints; // filled out with relevant information
    memset(&hints, 0, sizeof hints); // make sure the struct is empty
    hints.ai_family = AF_UNSPEC; // don't care IPv4 or IPv6
    hints.ai_socktype = SOCK_STREAM; // TCP stream sockets
    hints.ai_flags = AI_PASSIVE; // use my IP

    // make servinfo point to a linked list of 1 or more struct addrinfos
    struct addrinfo *servinfo; // will point to the results (holds the interfaces)
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
        if ((*socket_file_descriptor = socket(p->ai_family, p->ai_socktype,
            p->ai_protocol)) == -1)
        {
            perror("server: Can not call socket() on that interface");
            continue;
        }

        int yes = 1;
        if (setsockopt(*socket_file_descriptor, SOL_SOCKET, SO_REUSEADDR, &yes,
            sizeof(int)) == -1)
        {
            perror("Can not call setsockopt() on that interface");
            exit(1);
        }

        if (bind(*socket_file_descriptor, p->ai_addr, p->ai_addrlen) == -1)
        {
            close (*socket_file_descriptor);
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

    if (listen(*socket_file_descriptor, backLog) == -1)
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

void acceptClient(int *socket_file_descriptor,
    PointerToClientHandlerFunction clientHandlerFunction)
{
    struct ClientSocket clientSocket;
    char s[INET6_ADDRSTRLEN];
    socklen_t sin_size = sizeof clientSocket.clientAddr;
    clientSocket.connectionFileDescriptor = accept(*socket_file_descriptor,
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

/*! Handles a client. The int returned is the exit status of the PID created for that client. */
int clientHandler(struct ClientSocket clientSocket)
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
    // Run program
    printf("Forking\n"); fflush(stdout);
    pid_t pid = fork();
    printf("Got pid %d .\n", pid); fflush(stdout);
    if(pid == 0){
      // this is the child fork
      printf("I AM CHILD.\n"); fflush(stdout);
      char *args[] = {"/bin/bash", "/home/pgrozav/data/tmp/lg/srv_client/my_program.sh", NULL};
      execvp("/bin/bash", args);
      return 0;
    }else{
      printf("I AM PARENT.\n"); fflush(stdout);
      // this is parent
      if (pid < 0){
        printf("Failed to create child process.\n"); fflush(stdout);
        exit(1);
      }
      // if here, child was started
      sleep(1);// second, allow the child to run for 1s
      // then check it's status, and if running, kill it.
      int should_run = 1;
      while(should_run){
        printf("parent_check_child.\n"); fflush(stdout);
        int child_status = 0;
        pid_t w = waitpid(pid, &child_status, WNOHANG);
        if( w == -1 ){
          printf("Failed to check for child process.\n"); fflush(stdout);
          exit(1);
        }else if( w == 0 ){
          printf("Child process is still running.\n"); fflush(stdout);
          should_run = 0;
          int kill_result = kill(pid, SIGKILL); // Kill child
          if(kill_result == 0)
          {
            printf("Signal sent.\n"); fflush(stdout);
          }else{
            printf("Error while sending signal.\n"); fflush(stdout);
          }
        }else{
          printf("Unknown error while checking for child process.\n"); fflush(stdout);
          exit(2);
        }
      }
    }











    return 0;
    int socket_file_descriptor = 0;
    server(1234, &socket_file_descriptor);
    printf("server: waiting for connections...\n");
    while (1)
        acceptClient(socket_file_descriptor, &clientHandler);
    return 0;
}