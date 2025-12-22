/*

    Small program to set the default out port for the Triple Play or Quadra
    Play midi-interfaces. Made by Kjetil S. Matheussen.

    This program and its sourcecode is released into the Public Domain, and
    may be freely distributed in its original form.

    It is supplied ``as is'', and comes with no warranty. This program code
    was  released  because it might be useful as a starting point for other
    programmers. However, if any damage arises from its use,  the  original
    author and I will not be held liable. Use it at your own risk.

    You are free to use and modify  this  code  to  your  heart's  content,
    provided you acknowledge me as the original author in any code that you
    might distribute which is based largely on this code.

*/

#include <stdio.h>
#include <stdlib.h>
#include <exec/types.h>

extern void __asm set_dtr_rts(
    register __d0 LONG dtr,
    register __d1 LONG rts
);

int main(int argc,char **argv){
    if(argc!=2){
        printf("Settppoutport. Made by Kjetil S. Matheussen.\nUsage: settppoutport <port>\nPort can be 1,2,3 or 4.\n",argv[1]);
        return 1;
    }
    switch(atoi(argv[1])){
        case 1:
            set_dtr_rts(1,1);
            break;
        case 2:
            set_dtr_rts(1,0);
            break;
        case 3:
            set_dtr_rts(0,1);
            break;
        case 4:
            set_dtr_rts(0,0);
            break;
        default:
            printf("Port can only be 1,2,3 or 4.\n",argv[1]);
            return 2;
    }
    return 0;
}
