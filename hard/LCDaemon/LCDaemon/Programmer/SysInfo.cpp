#include <pragma/exec_lib.h>
#include <pragma/dos_lib.h>
#include <pragma/SysInfo_lib.h>
#pragma header
#include <iostream.h>
#include <Classes/Exec/Libraries.h>
#include <Classes/Dos/Arguments.h>
#include <lcd.h>
#include <string.h>
#include <stdio.h>

LibraryBaseErrC SysInfoBase(SYSINFONAME,SYSINFOVERSION);

struct SysInfo *sysinfo;

class VomitX{};

class CustomCharDefs
{
	public:
		CustomCharDefs();
		operator char *();
	private:
		UBYTE chars[48];
//	char * operator();
};

CustomCharDefs::CustomCharDefs()
{
	for(register int i=0;i<6;i++){
		for(register int j=0;j<8;j++){
			if(j%2 && j<7){
				chars[i*8+j]=0xff;
				for(register int k=0;k<5-i;k++){
					chars[i*8+j]<<=1;
				}
			}else{
				chars[i*8+j]=0x00;
			}
		}
	}
}

CustomCharDefs::operator char*()
{
	return chars;
}

class LCD
{
	public:
		LCD() throw(VomitX);
		void SetLCDMsg(LONG code,APTR data,LONG ticks,BYTE pri);
		void SetLCDMsg(APTR data);
		int SendLCDMsg();
		int width(){return lcdpar.width;};
		int height(){return lcdpar.height;};
		int WaitLCDMsg(void);
		APTR LCDData();
		~LCD();
	private:
	struct MsgPort *replyport;
	struct lcdmessage msg;
	struct lcdparams lcdpar;
	BOOL messagepending;
};

LCD::LCD()
{
	messagepending=FALSE;
	if(replyport=CreateMsgPort()){
		msg.lcd_Message.mn_Node.ln_Type=NT_MESSAGE;
		msg.lcd_Message.mn_Length=sizeof(struct lcdmessage);
		msg.lcd_Message.mn_ReplyPort=replyport;
	}else{
		throw VomitX();
	}
	msg.lcd_Priority=LCDPRI_APPLICATION;
	msg.lcd_Code=LCDMSG_ASKPARAMS;
	msg.lcd_Data=&lcdpar;
	if(SendLCDMsg()){
		WaitLCDMsg();
	}else{
		throw VomitX();
	}

}

LCD::~LCD()
{
	if(messagepending)WaitLCDMsg();
	if(replyport){
		while(GetMsg(replyport));
		DeleteMsgPort(replyport);
	}
}

void LCD::SetLCDMsg(LONG code,APTR data,LONG ticks,BYTE pri)
{
	msg.lcd_Code=code;
	msg.lcd_Data=data;
	msg.lcd_Priority=pri;
	msg.lcd_Ticks=ticks;
}

void LCD::SetLCDMsg(APTR data)
{
		msg.lcd_Data=data;
}

int LCD::SendLCDMsg()
{
	struct MsgPort *port;
	if(messagepending)return(FALSE);
	Forbid();
	port=FindPort(lcdportname);
	if(port) {
		PutMsg(port,(struct Message *)&msg);
		messagepending=TRUE;
	}
	Permit();
	return(port?TRUE:FALSE);
}

int LCD::WaitLCDMsg(void)
{
	if(!messagepending)return(LCDERR_YOURFAULT);
	WaitPort(replyport);
	GetMsg(replyport);
	messagepending=FALSE;
	return(msg.lcd_Error);
}

APTR LCD::LCDData(){
	return(msg.lcd_Data);
}

class LCDscreen : public LCD{
	public:
		LCDscreen();
		void print(char *text);
		void update();
		UBYTE *character(int x,int y);
		~LCDscreen();
	private:
		struct lcdscreen *scr;
		CustomCharDefs chars;
};

UBYTE *LCDscreen::character(int x,int y)
{
	if(x>=width())x=width()-1;
	if(y>=height())y=height()-1;
	return &(scr->screenbuffer[y*scr->bufferwidth+x]);
}

void LCDscreen::update()
{
	SetLCDMsg(LCDMSG_UPDATEHANDLE,scr,55,LCDPRI_MEMDISPLAY);
	scr->ud_flags=LCDUPD_DISPLAY;
	if(SendLCDMsg())WaitLCDMsg();
}

void LCDscreen::print(char *text)
{
	strcpy(scr->screenbuffer,text);
	SetLCDMsg(LCDMSG_UPDATEHANDLE,scr,100,LCDPRI_APPLICATION);
	scr->ud_flags=LCDUPD_DISPLAY;
	if(SendLCDMsg())WaitLCDMsg();
}

LCDscreen::LCDscreen()
{
	scr=NULL;
	SetLCDMsg(LCDMSG_ALLOCATEHANDLE,NULL,0,LCDPRI_MEMDISPLAY);
	if(SendLCDMsg()){
		if(!WaitLCDMsg()){
			scr=(struct lcdscreen *)LCDData();
			scr->customchardefs=chars;
			scr->ud_flags=LCDUPD_CUSTOMCHARNUM|LCDUPD_CUSTOMCHARDEFS;
			scr->customcharnum=6;
			scr->customcharheight=8;
			SetLCDMsg(LCDMSG_UPDATEHANDLE,scr,55,LCDPRI_MEMDISPLAY);
			if(SendLCDMsg()){
				if(!WaitLCDMsg()){
					return;
				}
			}
		}
	}
	throw VomitX();
}

LCDscreen::~LCDscreen()
{
	if(scr){
		SetLCDMsg(LCDMSG_FREEHANDLE,scr,0,LCDPRI_MEMDISPLAY);
		if(SendLCDMsg()){
			WaitLCDMsg();
		}
	}
}

class SysMon
{
	public:
		SysMon(ArgsC &args) throw(VomitX);
		~SysMon();
		int run(void) throw(VomitX);
	private:
		LCDscreen lcd;
		struct SI_Notify *notify;
		struct SI_CpuUsage use;
};

SysMon::SysMon(ArgsC &args)
{
	if(!(notify=AddNotify(sysinfo,AN_USE_MESSAGES,10)))throw VomitX();
}

int SysMon::run(void)
{
	ULONG ichipavail,ifastavail;
	ULONG sigs=0,waitsig=SIGBREAKF_CTRL_C|(1L<<notify->notify_port->mp_SigBit);
	struct Message *msg;
	int chipwidth,fastwidth;
	UBYTE theday[LEN_DATSTRING],thedate[LEN_DATSTRING],thetime[LEN_DATSTRING];
	UBYTE schipavail[16],sfastavail[16];
	char *c;
	int daylen,datelen,timelen;
	struct DateTime dt={{0,0,0},FORMAT_DOS,0,theday,thedate,thetime};
	while(!(sigs&SIGBREAKF_CTRL_C)){
		sigs=Wait(waitsig);
		while(msg=GetMsg(notify->notify_port))ReplyMsg(msg);
		GetCpuUsage(sysinfo,&use);
		if(use.used_cputime_lastsec_hz){
			int usage=5*lcd.width()*use.used_cputime_lastsec/use.used_cputime_lastsec_hz;
			//lcd.print("Hello!");

			// Put chip & fast mem stats on line 0
			ichipavail=AvailMem(MEMF_CHIP);
			ifastavail=AvailMem(MEMF_FAST);
			sprintf(schipavail,"C:%dK",ichipavail/1024);
			sprintf(sfastavail,"F:%dK",ifastavail/1024);
			memset(lcd.character(0,0),0,lcd.width()*lcd.height());
			chipwidth=strlen(schipavail);
			fastwidth=strlen(sfastavail);
			c=lcd.character(lcd.width()-fastwidth,0);
			strncpy(c,sfastavail,fastwidth);
			c-=1+chipwidth;
			strncpy(c,schipavail,chipwidth);
			// Put date and time on line 1
			if(lcd.height()>1){
				c=lcd.character(0,1);
				DateStamp(&dt.dat_Stamp);
				DateToStr(&dt);
				daylen=strlen(theday);datelen=strlen(thedate);timelen=strlen(thetime);
				if(daylen+datelen+timelen+2<=lcd.width()){
					sprintf(c,"%s %s %s",theday,thedate,thetime);
				}else if(datelen+timelen+1<=lcd.width()){
					sprintf(c,"%s %s",thedate,thetime);
				}else if(timelen<=lcd.width()){
					sprintf(c,"%s",thetime);
				}
			}
			// Overwrite with CPU load bar
			c=lcd.character(0,0);
			for(int i=usage/5;i;i--){
				*c++=5;
			}
			if(usage%5)*c++=usage%5;
			lcd.update();
		}
	}
	return(0L);
}

SysMon::~SysMon()
{
	if(notify)RemoveNotify(sysinfo,notify);
}

int main(void)
{
	int retval=5;
	if(LibraryBaseC::areAllOpen()){
		if(sysinfo=InitSysInfo()){
			if(sysinfo->notify_msg_implemented && (sysinfo->cpu_usage_implemented&CPU_USAGEF_LASTSEC_IMPLEMENTED)){
				try{
					//ArgsC cmdline(NULL);
					SysMon theMon(NULL);
					retval=theMon.run();
				}catch(RdArgsX){
					cout<<"Invalid arguments"<<endl;
				}catch(...){
					cout<<"General failure. (C)rash,(F)ail: F"<<endl;
				}
			}else{
				cout<<"No signal notification implemented"<<endl;
			}
			FreeSysInfo(sysinfo);
		}
	}
	return(retval);
}

