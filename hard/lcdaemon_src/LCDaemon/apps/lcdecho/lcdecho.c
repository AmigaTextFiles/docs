#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <signal.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <exec/ports.h>
#include <dos/dos.h>
#include "lcd.h"

struct MsgPort *replyport;
struct lcdmessage msg;
struct lcdparams lcdpar;
LONG time=100;
char text[1000];
char message[1000];
STRPTR argstring="TIME/K/N,TEXT/A";

int SafePutToPort(struct lcdmessage *message,STRPTR portname){
	struct MsgPort *port;
	Forbid();
	port=FindPort(portname);
	if(port) PutMsg(port,(struct Message *)message);
	Permit();
	return(port?TRUE:FALSE);
}

int main(int argc,char **argv){
	register int i;
	char *to;
	LONG argarray[]={(LONG)&time,(LONG)""};
	struct RDArgs *args=NULL;

	signal(SIGINT,SIG_IGN);
	if(args=ReadArgs(argstring,argarray,NULL)){

		if(replyport=CreateMsgPort()){
			msg.lcd_Message.mn_Node.ln_Type=NT_MESSAGE;
			msg.lcd_Message.mn_Length=sizeof(struct lcdmessage);
			msg.lcd_Message.mn_ReplyPort=replyport;
			msg.lcd_Priority=LCDPRI_APPLICATION;

			msg.lcd_Code=LCDMSG_ASKPARAMS;
			msg.lcd_Data=&lcdpar;
			if(SafePutToPort(&msg,lcdportname)){
				WaitPort(replyport);
				GetMsg(replyport);
				for(i=0,to=message;((STRPTR)(argarray[1]))[i];i++){
					switch(((STRPTR)(argarray[1]))[i]){
/*					case 163:
						while(to<&message[lcdpar.virtualwidth]) *to++=' ';
						break;*/
					default:
						*to++=((STRPTR)(argarray[1]))[i];
					}
				}
				*to=0;
				msg.lcd_Code=LCDMSG_QUEUE;
				msg.lcd_Data=message;
				msg.lcd_Ticks=*((LONG *)argarray[0]);
				msg.lcd_Priority=LCDPRI_APPLICATION;
				if(SafePutToPort(&msg,lcdportname)){
					WaitPort(replyport);
					GetMsg(replyport);
				}
			}
			DeleteMsgPort(replyport);
		}
		FreeArgs(args);
	} else {
		printf("Usage: %s %s\n",argv[0],argstring);
	}
	return(0);
}
