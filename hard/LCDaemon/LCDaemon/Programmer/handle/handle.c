#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <signal.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <exec/ports.h>
#include <dos/dos.h>
#include "lcd.h"

#define C(a,b,c,d,e) (((a)<<4)|((b)<<3)|((c)<<2)|((d)<<1)|(e))
UBYTE customchar[]={
	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,1,1,1,0),
	C(0,1,0,1,0),
	C(0,1,0,1,0),
	C(0,1,0,1,0),
	C(0,1,1,1,0),
	C(0,0,0,0,0),

	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,0,1,0,0),
	C(0,0,1,0,0),
	C(0,0,1,0,0),
	C(0,0,1,0,0),
	C(0,0,1,0,0),
	C(0,0,0,0,0),

	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,1,1,0,0),
	C(0,0,0,1,0),
	C(0,0,1,0,0),
	C(0,1,0,0,0),
	C(0,1,1,1,0),
	C(0,0,0,0,0),

	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,1,1,0,0),
	C(0,0,0,1,0),
	C(0,0,1,0,0),
	C(0,0,0,1,0),
	C(0,1,1,0,0),
	C(0,0,0,0,0),

	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,1,0,1,0),
	C(0,1,0,1,0),
	C(0,0,1,1,0),
	C(0,0,0,1,0),
	C(0,0,0,1,0),
	C(0,0,0,0,0),

	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,1,1,1,0),
	C(0,1,0,0,0),
	C(0,0,1,0,0),
	C(0,0,0,1,0),
	C(0,1,1,0,0),
	C(0,0,0,0,0),

	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,0,1,1,0),
	C(0,1,0,0,0),
	C(0,1,1,1,0),
	C(0,1,0,1,0),
	C(0,1,1,1,0),
	C(0,0,0,0,0),

	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,1,1,1,0),
	C(0,0,0,1,0),
	C(0,0,0,1,0),
	C(0,0,0,1,0),
	C(0,0,0,1,0),
	C(0,0,0,0,0)
};

UBYTE bargraph[]={
	C(1,1,1,1,1),
	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(0,0,0,0,0),
	C(1,1,1,1,1),
	C(0,0,0,0,0),

	C(1,1,1,1,1),
	C(1,0,0,0,0),
	C(1,0,0,0,0),
	C(1,0,0,0,0),
	C(1,0,0,0,0),
	C(1,0,0,0,0),
	C(1,1,1,1,1),
	C(0,0,0,0,0),

	C(1,1,1,1,1),
	C(1,1,0,0,0),
	C(1,1,0,0,0),
	C(1,1,0,0,0),
	C(1,1,0,0,0),
	C(1,1,0,0,0),
	C(1,1,1,1,1),
	C(0,0,0,0,0),

	C(1,1,1,1,1),
	C(1,1,1,0,0),
	C(1,1,1,0,0),
	C(1,1,1,0,0),
	C(1,1,1,0,0),
	C(1,1,1,0,0),
	C(1,1,1,1,1),
	C(0,0,0,0,0),

	C(1,1,1,1,1),
	C(1,1,1,1,0),
	C(1,1,1,1,0),
	C(1,1,1,1,0),
	C(1,1,1,1,0),
	C(1,1,1,1,0),
	C(1,1,1,1,1),
	C(0,0,0,0,0),

	C(1,1,1,1,1),
	C(1,1,1,1,1),
	C(1,1,1,1,1),
	C(1,1,1,1,1),
	C(1,1,1,1,1),
	C(1,1,1,1,1),
	C(1,1,1,1,1),
	C(0,0,0,0,0),

};

struct MsgPort *replyport;
struct lcdmessage msg;
struct lcdparams lcdpar;
struct lcdscreen *scr;

int SafePutToPort(struct lcdmessage *message,STRPTR portname){
	struct MsgPort *port;
	Forbid();
	port=FindPort(portname);
	if(port) PutMsg(port,(struct Message *)message);
	Permit();
	return(port?TRUE:FALSE);
}

int main(int argc, char **argv){

	register int i,j;

		if(replyport=CreateMsgPort()){
			msg.lcd_Message.mn_Node.ln_Type=NT_MESSAGE;
			msg.lcd_Message.mn_Length=sizeof(struct lcdmessage);
			msg.lcd_Message.mn_ReplyPort=replyport;
			msg.lcd_Priority=LCDPRI_APPLICATION;

			msg.lcd_Code=LCDMSG_ASKPARAMS;
			msg.lcd_Data=&lcdpar;
			if(SafePutToPort(&msg,lcdportname)){
				printf("Ask OK\n");
				WaitPort(replyport);
				GetMsg(replyport);
				msg.lcd_Code=LCDMSG_ALLOCATEHANDLE;
				msg.lcd_Data=NULL;
				msg.lcd_Priority=LCDPRI_APPLICATION-10;	/*	lower than lcdecho to show off priority :-) */
				msg.lcd_Ticks=~0;	/*	use ~0 as special case: "forever" (until deallocation)	*/
				if(SafePutToPort(&msg,lcdportname)){
					WaitPort(replyport);
					GetMsg(replyport);
				}
				if(!msg.lcd_Error){
					printf("Handle OK\n");
					scr=(struct lcdscreen *)msg.lcd_Data;

					msg.lcd_Code=LCDMSG_UPDATEHANDLE;
					msg.lcd_Data=(APTR)scr;
					strcpy(scr->screenbuffer,"Vomit \001\002\003\004\005\006\007");
					scr->ud_flags=LCDUPD_DISPLAY|LCDUPD_CUSTOMCHARNUM|LCDUPD_CUSTOMCHARDEFS;
					scr->customchardefs=customchar;
					scr->customcharnum=8;
					scr->customcharheight=8;
					SafePutToPort(&msg,lcdportname);
					WaitPort(replyport);
					GetMsg(replyport);

					for(i=0;i<8;i++){
						msg.lcd_Code=LCDMSG_UPDATEHANDLE;
						scr->ud_flags=LCDUPD_CUSTOMCHARDEFS;
						customchar[i*8+7]=0xff;
						Delay(20);
						SafePutToPort(&msg,lcdportname);
						WaitPort(replyport);
						GetMsg(replyport);
					}
					Delay(20);

					msg.lcd_Code=LCDMSG_UPDATEHANDLE;
					scr->ud_flags=LCDUPD_CUSTOMCHARDEFS|LCDUPD_CUSTOMCHARNUM|LCDUPD_DISPLAY;
					scr->customchardefs=bargraph;
					scr->customcharnum=6;
					scr->customcharheight=8;
					strcpy(scr->screenbuffer,"Speed:");
					for(i=6;i<scr->bufferwidth;i++){
						scr->screenbuffer[i]=' ';
					}
					for(i=0;i<lcdpar.width;i++){
						for(j=0;j<6;j++){

							scr->screenbuffer[scr->bufferwidth+i]=j;

							SafePutToPort(&msg,lcdportname);
							WaitPort(replyport);
							GetMsg(replyport);
							scr->ud_flags=LCDUPD_DISPLAY;
							Delay(1);
						}
					}

					msg.lcd_Code=LCDMSG_FREEHANDLE;
					msg.lcd_Data=(APTR)scr;
					SafePutToPort(&msg,lcdportname);
					WaitPort(replyport);
					GetMsg(replyport);
				}
			}
			DeleteMsgPort(replyport);
		}

	
}
