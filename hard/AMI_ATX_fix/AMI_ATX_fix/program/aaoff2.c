
/* MASTER - AMI ATX OFF, update by orange */
static const char __version[] = "$VER: AMI ATX OFF V1.3 (28.04.2014) MASTEr and orange";
#include <stdio.h>
#include <time.h>
void delay(int milliseconds);
int main ()
{


  char *p = 0xbfd100;
  //(*0xbfd100) = 4;

  *p = 4;
  delay(170);  // 170 millisecond delay

  *p = -1;
  delay(170); 

  *p = 4;
 
 return (0);
}




void delay(int milliseconds)
{
    long pause;
    clock_t now,then;

    pause = milliseconds*(CLOCKS_PER_SEC/1000);
    now = then = clock();
    while( (now-then) < pause )
        now = clock();
}


