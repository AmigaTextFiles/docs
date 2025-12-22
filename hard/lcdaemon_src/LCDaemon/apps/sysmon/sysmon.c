#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <signal.h>
#include <proto/intuition.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/utility.h>
#include <clib/locale_protos.h>
#include <pragmas/locale_pragmas.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <intuition/intuition.h>
#include <libraries/locale.h>
#include <utility/date.h>
#include "lcd.h"
#include "SysMon_locale.h"
#include "SysMon_version.h"

#define BUFSIZE 200		/*	>= max characters*max lines	*/
#define UPDATEDELAY	250
#define QUITAFTER	1000

int __oslibversion=37L;
static char *tag=VERSTAG " © 1995 VOMIT, inc.";
struct MsgPort *replyport=NULL;
struct lcdmessage msg;
BOOL msgsent=FALSE;
struct lcdparams lcdpar;
struct Library *LocaleBase=NULL;
struct Locale *locale;

UBYTE *months[]={"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
UBYTE *days[]={"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
UBYTE *template="UPDATEDELAY=UD/K/N,QUITAFTER=Q/K/N\n";
#define NUMBEROFPARAMS 2
struct parameters {
	ULONG updatedelay;	/*	jiffys	*/
	ULONG quitafter;	/*	seconds	*/
} params;
LONG p[]={
	UPDATEDELAY,QUITAFTER
};

int SafePutToPort(struct lcdmessage *message,STRPTR portname){
	struct MsgPort *port;
	Forbid();
	port=FindPort(portname);
	if(port) PutMsg(port,(struct Message *)message);
	Permit();
	return(port?TRUE:FALSE);
}
long sendtolcd_sync(long code,APTR data,long time){
	msg.lcd_Code=code;
	msg.lcd_Data=data;
	msg.lcd_Ticks=time;
	if(SafePutToPort(&msg,lcdportname)){
		WaitPort(replyport);
		GetMsg(replyport);
		return(msg.lcd_Error);
	}
	return(-1);
}
long sendtolcd_async(long code,APTR data,long time){
	msg.lcd_Code=code;
	msg.lcd_Data=data;
	msg.lcd_Ticks=time;
	if(!msgsent&&SafePutToPort(&msg,lcdportname)){
		msgsent=TRUE;
		return(0);
	}
	return(-1);
}
long waitlcd_async(void){
	if(msgsent){
		WaitPort(replyport);
		GetMsg(replyport);
		msgsent=FALSE;
		return(msg.lcd_Error);
	}
	return(-1);
}

void fail(APTR cause){
	struct EasyStruct ez={
		sizeof(struct EasyStruct),
		0,
		NULL,NULL,NULL};

	if(cause){
		ez.es_Title=GetSysMonString(msgErrorTitle);
		ez.es_TextFormat=GetSysMonString(msgErrorFormat);
		ez.es_GadgetFormat=GetSysMonString(msgErrorGadgets);
		EasyRequest(NULL,&ez,NULL,GetSysMonString(cause));
	}
	if(msgsent) waitlcd_async();
	CloseSysMonCatalog();
	if(LocaleBase&&locale)CloseLocale(locale);
	if(LocaleBase)CloseLibrary(LocaleBase);
	if(replyport) DeleteMsgPort(replyport);
	exit(cause?5:0);
}

void setup(void){
	LocaleBase=OpenLibrary("locale.library",37L);
	if(LocaleBase)locale=OpenLocale(NULL); else locale=NULL;
	if(!(replyport=CreateMsgPort())) fail(GetSysMonString(msgNoMemory));
	msg.lcd_Message.mn_Node.ln_Type=NT_MESSAGE;
	msg.lcd_Message.mn_Length=sizeof(struct lcdmessage);
	msg.lcd_Message.mn_ReplyPort=replyport;
	msg.lcd_Priority=LCDPRI_MEMDISPLAY;
}

void dolcd(char *buffer){
	struct ClockData dingdong;
	register int i,j;
	static char buffer2[100];
	enum {TCHIP=0,TFAST,TDATE,TTIME,MAX_FIELD};
	int tchip,tfast,pad[MAX_FIELD-1];
	static char temp[MAX_FIELD][40];
	int templen[MAX_FIELD];
	LONG tik,tak;

#define PAD(x)	for(j=pad[x];j;j--)strcat(buffer," ");

	CurrentTime(&tik,&tak);
	Amiga2Date(tik,&dingdong);

	sprintf(temp[TCHIP],"C:%dK",tchip=AvailMem(MEMF_CHIP)>>10);
	sprintf(temp[TFAST],"F:%dK",tchip=AvailMem(MEMF_FAST)>>10);
	sprintf(temp[TDATE],"%s %d %s",
						locale?
							GetLocaleStr(locale,ABDAY_1+dingdong.wday):
							days[dingdong.wday],
						dingdong.mday,
						locale?
							GetLocaleStr(locale,(ABMON_1-1)+dingdong.month):
							months[dingdong.month-1]);
	sprintf(temp[TTIME],"%02d:%02d",
						dingdong.hour,
						dingdong.min);

	for(i=0;i<MAX_FIELD;i++)templen[i]=strlen(temp[i]);

	if(lcdpar.height==1){
		pad[0]=pad[1]=pad[2]=(lcdpar.width-(templen[TCHIP]+templen[TFAST]+templen[TDATE]+templen[TTIME]))/3;
		if(pad[0]>0){
			pad[1]+=(lcdpar.width-(templen[TCHIP]+templen[TFAST]+templen[TDATE]+templen[TTIME]+3*pad[0]));
			strcpy(buffer,temp[TCHIP]);
			for(i=1;i<MAX_FIELD;i++){
				PAD(i-1);
				strcat(buffer,temp[i]);
			}
		}else{
			sprintf(buffer,"%s %s",temp[TCHIP],temp[TFAST]);
		}
	}else{
		pad[0]=lcdpar.width-(templen[TCHIP]+templen[TFAST]);
		pad[1]=lcdpar.width-(templen[TDATE]+templen[TTIME]);
		strcpy(buffer,temp[TCHIP]);
		PAD(0);
		strcat(buffer,temp[TFAST]);
		strcat(buffer," ");
		strcat(buffer,temp[TDATE]);
		PAD(1);
		strcat(buffer,temp[TTIME]);
	}
}

void handleargs(void){
	struct RDArgs *cmdline;
	LONG p[NUMBEROFPARAMS]={0,0};

	if(cmdline=ReadArgs(template,p,NULL)){
		if(!p[0] || *(LONG *)p[0]<=0 || *(LONG *)p[0]>50*600){
			params.updatedelay=UPDATEDELAY;
		} else params.updatedelay=*(LONG *)p[0];
		if(!p[1] || *(LONG *)p[1]<=1){
			params.quitafter=QUITAFTER;
		} else params.quitafter=*(LONG *)p[1];
	} else {
		fail(msgArguments);
	}
}

int main(int argc,char **argv){

	char buffer[BUFSIZE]="Belgium, man!";
	long quitcounter;
	long oldpri;
	long err;
	signal(SIGINT,SIG_IGN);

	OpenSysMonCatalog(NULL,NULL);

	handleargs();
	setup();

	if(sendtolcd_sync(LCDMSG_ASKPARAMS,&lcdpar,0)) fail(msgLCDUnavailable);

	quitcounter=params.quitafter;

	oldpri=SetTaskPri(FindTask(0),-1);

	while(quitcounter&&!(SetSignal(0,0)&SIGBREAKF_CTRL_C)){
		Delay(params.updatedelay);
		dolcd(buffer);
		/*	wait for reply from previous send..._async	*/
		switch(err=waitlcd_async()){
			case LCDERR_NOMEM:		/*	AAARGHH! QUICK! QUIT!!!!		*/
				quitcounter=0;
				break;
			case LCDERR_UNKNOWN:	/*	Should never appear				*/
			case LCDERR_YOURFAULT:	/*	Huh? Wrong configuration?		*/
			case -1:				/*	Port disappeared				*/
				quitcounter=quitcounter>1?1:0;	/*	Error twice = quit	*/
				break;

			case LCDERR_TOOBUSY:	/*	LCD allocated or other problem	*/
				quitcounter--;		/*	Unload if this takes too long	*/
				break;

			case LCDERR_NONE:
				quitcounter=params.quitafter;
				break;
			default:
				break;
		}
		if(quitcounter) sendtolcd_async(LCDMSG_QUEUE,buffer,params.updatedelay+10);
	}
	SetTaskPri(FindTask(0),oldpri);

	fail(NULL);
}
