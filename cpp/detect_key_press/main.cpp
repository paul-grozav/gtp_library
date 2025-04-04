#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/time.h>

void changemode(int dir)
{
  static struct termios oldt, newt;
  if ( dir == 1 )
  {
    tcgetattr( STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~( ICANON | ECHO );
    tcsetattr( STDIN_FILENO, TCSANOW, &newt);
  }else
    tcsetattr( STDIN_FILENO, TCSANOW, &oldt);
}

int kbhit(void)
{
  struct timeval tv;
  fd_set rdfs;
  tv.tv_sec = 0;
  tv.tv_usec = 0;
  FD_ZERO(&rdfs);
  FD_SET (STDIN_FILENO, &rdfs);
  select(STDIN_FILENO+1, &rdfs, NULL, NULL, &tv);
  return FD_ISSET(STDIN_FILENO, &rdfs);
}

int main(void)
{
  changemode(1);
  while(true)
  {
    while( !kbhit() ){} // While no key is pressed, do nothing
    char ch = getchar(); // When a key was pressed, we get the character
    printf("Got %i=%c\n", ch, ch); // Print the info about the key that was pressed
    if(ch==113) break; // We might need a break condition
  }

  changemode(0);
  return 0;
}
