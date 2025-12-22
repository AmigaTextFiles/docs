/*	LCD-handler	*/

#include "lcdh_version.h"

#define __USE_SYSBASE

#include "includes.h"

#include "lcd.h"

/*
**	Definitions & structs
*/

#define BCPL_MAX_LEN 256
#define noDEBUG

void kprintf(UBYTE *fmt, ...);
#ifdef DEBUG
#define bug kprintf
#define D(x) (x)
#else
#define D(x)
#endif

struct lcdhfileinfo {
	ULONG time;
	LONG pri;
};
struct privatehandle {
	struct lcdscreen *scr;
	ULONG time;
};


/*
**	Only 1 prototype
*/
void mainroutine(void);

/*
**	jump to main routine, so it doesn't have to be in front of all other routines,
**	which avoids a lot of prototypes
*/
LONG __saveds entrypoint(void){
						
	mainroutine();
	return(0L);
}

/*
**	Global data
*/
struct ExecBase *SysBase;
struct DosLibrary *DOSBase=NULL;
char VersionString[] = VERSTAG;
struct lcdmessage *msg=NULL;
struct lcdparams lcdpar;
struct MsgPort *PacketPort=NULL;
struct MsgPort *replyport=NULL;

/*
**	For LCdaemon communication
*/
int SafePutToPort(struct lcdmessage *message,STRPTR portname){
	struct MsgPort *port;
	Forbid();
	port=FindPort(portname);
	if(port) PutMsg(port,(struct Message *)message);
	Permit();
	return(port?TRUE:FALSE);
}


/*
**	Extract "LCD:time/pri" to a lcdhfileinfo structure
*/
void fillfileinfo(UBYTE *s,struct lcdhfileinfo *fi){
	UBYTE Name[BCPL_MAX_LEN],*c;
	/*	Convert BSTR to C-string	*/
	CopyMem(&s[1],Name,s[0]);
	Name[s[0]]=(UBYTE)0;
	s=Name;

	/*	Initialize lcdhfileinfo with defaults	*/
	fi->time=~(ULONG)0;
	fi->pri=LCDPRI_APPLICATION;

	/*	Skip upto ':'	*/
	if(c=strchr(s,':'))s=c+1;

	if(strlen(s)){
		if(c=strchr(s,'/')){
			*c=0;
		}
		StrToLong(s,&(fi->time));
		if(!fi->time)fi->time=~(ULONG)0;
		if(c)s=c+1;
		if(strlen(s)){
			StrToLong(s,&(fi->pri));
		}
	}
}

void lcd_newhandle(struct DosPacket *Pkt,ULONG *opencnt){
	struct FileHandle *fh;
	struct lcdhfileinfo finfo;
	struct privatehandle *ph;

	Pkt->dp_Res1=DOSFALSE;
	fh=(struct FileHandle *)BADDR(Pkt->dp_Arg1);
	fh->fh_Port=(struct MsgPort *)FALSE;
	fh->fh_Arg1=0L;
	Pkt->dp_Res1=DOSFALSE;
	Pkt->dp_Res2=0;

	fillfileinfo((UBYTE *)BADDR(Pkt->dp_Arg3),&finfo);

	if(ph=AllocMem(sizeof(struct privatehandle),MEMF_PUBLIC|MEMF_CLEAR)){
		msg->lcd_Message.mn_ReplyPort=replyport;
		msg->lcd_Priority=finfo.pri;
		msg->lcd_Code=LCDMSG_ASKPARAMS;
		msg->lcd_Data=&lcdpar;

		if(SafePutToPort(msg,lcdportname)&&(WaitPort(replyport),GetMsg(replyport),msg->lcd_Error==LCDERR_NONE)){
			msg->lcd_Code=LCDMSG_ALLOCATEHANDLE;
			msg->lcd_Data=NULL;
			msg->lcd_Ticks=finfo.time;
			if(SafePutToPort(msg,lcdportname)&&(WaitPort(replyport),GetMsg(replyport),msg->lcd_Error==LCDERR_NONE)){
				ph->scr=(struct lcdscreen *)(msg->lcd_Data);
				ph->time=finfo.time;
				fh->fh_Arg1=(LONG)ph;
				ReplyPkt(Pkt,DOSTRUE,0);
				(*opencnt)++;
				return;
			}else{
				ReplyPkt(Pkt,DOSFALSE,ERROR_OBJECT_NOT_FOUND);
			}
		}else{
			ReplyPkt(Pkt,DOSFALSE,ERROR_NO_DISK);
		}
		DeleteMsgPort(replyport);
		FreeMem(ph,sizeof(struct privatehandle));
	}else{
		ReplyPkt(Pkt,DOSFALSE,ERROR_NO_FREE_STORE);
	}
}

void lcd_write(struct DosPacket *Pkt){
	struct lcdscreen *scr;
	struct privatehandle *ph;
	UBYTE *screenbuf;
	UBYTE *buf;
	LONG bytes2write,byteswritten,max,in;

	ph=(struct privatehandle *)Pkt->dp_Arg1;
	scr=ph->scr;

	if(scr->version>=LCDSCREEN_MINVERSION){
		screenbuf=scr->screenbuffer;
		buf=(UBYTE *)Pkt->dp_Arg2;
		bytes2write=Pkt->dp_Arg3;
		max=scr->bufferwidth*scr->bufferheight;
		in=0;
		while(bytes2write){
			for(byteswritten=0;bytes2write&&byteswritten<max;bytes2write--,byteswritten++,in++){
				screenbuf[byteswritten]=buf[in];
			}
			while(byteswritten<max)screenbuf[byteswritten++]=' ';
			msg->lcd_Code=LCDMSG_UPDATEHANDLE;
			msg->lcd_Data=scr;
			scr->ud_flags=LCDUPD_DISPLAY;
			SafePutToPort(msg,lcdportname);
			WaitPort(replyport);
			GetMsg(replyport);
			D(bug("delay\n"));
			Delay(50);
		}
		ReplyPkt(Pkt,byteswritten,0);
	}else{
		ReplyPkt(Pkt,DOSFALSE,ERROR_INVALID_RESIDENT_LIBRARY);
	}
}

void lcd_closehandle(struct DosPacket *Pkt,ULONG *opencnt){
	struct privatehandle *ph;
	ph=(struct privatehandle *)Pkt->dp_Arg1;
	msg->lcd_Data=ph->scr;
	msg->lcd_Code=LCDMSG_FREEHANDLE;
	if(SafePutToPort(msg,lcdportname)){
		WaitPort(replyport);
		GetMsg(replyport);
	}
	FreeMem(ph,sizeof(struct privatehandle));
	(*opencnt)--;
	ReplyPkt(Pkt,DOSTRUE,0);
}


struct DosPacket *WaitDosPacket(struct MsgPort *PacketPort){
	WaitPort(PacketPort);
	return (struct DosPacket *)GetMsg(PacketPort)->mn_Node.ln_Name;
}

void __regargs ReplyDosPacket(struct DosPacket *Packet,
                              struct MsgPort *PacketPort,
                              LONG Res1,LONG Res2){
	struct MsgPort *ReplyPort;

	ReplyPort=Packet->dp_Port;
	Packet->dp_Port=PacketPort;
	Packet->dp_Link->mn_Node.ln_Name=(char *)Packet;
	Packet->dp_Res1=Res1;
	Packet->dp_Res2=Res2;

	PutMsg (ReplyPort,Packet->dp_Link);
}

void __regargs ReturnDosPacket(	struct DosPacket *Packet,
								struct MsgPort *PacketPort){
	struct MsgPort *ReplyPort;

	ReplyPort=Packet->dp_Port;
	Packet->dp_Port=PacketPort;
	Packet->dp_Link->mn_Node.ln_Name=(char *)Packet;

	PutMsg (ReplyPort,Packet->dp_Link);
}

/*
**	Error cleanup
*/

void fail(ULONG err){
	struct Message *mess;
	if(msg)FreeMem(msg,sizeof(struct lcdmessage));
	if(replyport){
		Forbid();
		while(mess=GetMsg(replyport))ReplyMsg(mess);
		DeleteMsgPort(replyport);
		Permit();
	}
	D(bug("Bye!\n"));
	if(err)Exit(RETURN_FAIL);	/*	I need dos.library for Exit() ... How the @#$ do I CloseLibrary() it???	*/
	if(DOSBase)CloseLibrary((struct Library *)DOSBase);
	return;
}

/*
**	Main dispatcher
*/
void mainroutine(void){
	struct Process *MyProc;
	struct DosPacket *Pkt;
	struct DeviceNode *DeviceNode;
	BOOL Done;
	ULONG OpenCnt;

	D(bug("Init..."));
	SysBase=*(struct ExecBase **)4L;
	if(!(DOSBase=(struct DosLibrary *)OpenLibrary("dos.library",37L)))fail(20L);

	/*	Fail if started from command line	*/
	if ((MyProc=(struct Process *)FindTask(NULL))->pr_CLI)fail(20L);
	D(bug("I'm process %lx\n",MyProc));
	Pkt=WaitDosPacket(&MyProc->pr_MsgPort);
	D(bug("Startup packet received.\n"));
	DeviceNode=(struct DeviceNode *)BADDR(Pkt->dp_Arg3);

	if (SysBase->LibNode.lib_Version<37)
	{
		D(bug("Wrong Kickstart\n"));
		ReplyPkt(Pkt,DOSFALSE,ERROR_INVALID_RESIDENT_LIBRARY);
		fail(1);
	}

	if(!(msg=AllocMem(sizeof(struct lcdmessage),MEMF_PUBLIC|MEMF_CLEAR))){
		D(bug("Can't allocate msg\n"));
		fail(1);
	}

	if(replyport=CreateMsgPort()){
			msg->lcd_Message.mn_Node.ln_Type=NT_MESSAGE;
			msg->lcd_Message.mn_Length=sizeof(struct lcdmessage);
			msg->lcd_Message.mn_ReplyPort=replyport;
	}else{
		D(bug("Can't create msgport\n"));
		fail(1);
	}
	PacketPort=&MyProc->pr_MsgPort;
	Pkt->dp_Arg4=(LONG)PacketPort;
	ReplyPkt(Pkt,DOSTRUE,Pkt->dp_Res2);

	Done=FALSE;
	OpenCnt=0L;
	D(bug("Entering main loop...\n"));
	while (!Done){
		Pkt=WaitDosPacket(PacketPort);
		switch (Pkt->dp_Type){
			case ACTION_FINDOUTPUT:
				D(bug("Findoutput\n"));
				lcd_newhandle(Pkt,&OpenCnt);
				break;
			case ACTION_FINDINPUT:
			case ACTION_FINDUPDATE:
				D(bug("Unsupported\n"));
				ReplyPkt(Pkt,DOSFALSE,ERROR_OBJECT_WRONG_TYPE);
				break;
			case ACTION_WRITE:
				D(bug("Write\n"));
				lcd_write(Pkt);
				break;
			case ACTION_END:
				D(bug("End\n"));
				lcd_closehandle(Pkt,&OpenCnt);
				break;
			default:
				D(bug("Unknown\n",NULL));
				ReplyPkt(Pkt,DOSFALSE,ERROR_ACTION_NOT_KNOWN);
		}
		if (OpenCnt==0L){
			Forbid();
			if (PacketPort->mp_MsgList.lh_Head->ln_Succ==NULL){
				DeviceNode->dn_Task=NULL;
				Done=TRUE;
			}
			Permit();
			D(bug("Zero opencount\n"));
		}
	}
	D(bug("Completed\n"));

	fail(0L);
}
