/*

						LCDaemon	©1995-97 VOMIT,inc.
						Email: hendrik.devloed@barco.com

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

/*	History can be found in "History.h", but is not included for speed reasons
#include "History.h"
*/

/*
	LCDaemon is intended to compile with Maxon C++ PRO, which includes the EasyObjects classes.
	The class libraries do not mention the copying policy, but as they are part of the
	extra features of the PRO version versus the LITE version, I presume they cannot be
	distributed. If you want to compile this source without EasyObject sources, contact me
	in order to learn the class API's so you can write compatible replacements.
*/

#include "AmigaOS.h"
#pragma header
#include <Classes/Workbench/Workbench.h>

#undef LCD_NO_PORTNAMES	//	Force the static data in lcd.h to be linked in, but only here.
#include "lcd.h"
#define LCD_NO_PORTNAMES

#include "lcd_version.h"
#include <clib/rexxsyslib_protos.h>
#include <clib/locale_protos.h>
#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <iostream.h>

#define LCDNAME (&(verstag[7]))

#define MIN(x,y)	((x)<(y)?(x):(y))
#define MAXPORTNUMBER 9				//	Maximum suffix for public port
#define MAXREXXPARAMS 16				//	Maximum number of AREXX parameters
#define MAXREXXFUNCTIONS	4			//	Maximum number of AREXX callback functions
#define UNIVERSALBUFFERSIZE	256	//	A do-it-all buffer allocated statically

//	Debugging macros

#define nDEBUG
#ifdef DEBUG
	#define D(x) x
	#define BUG(x) PutStr(x "\n");
	#define SAFETY 400
#else
	#define D(x)
	#define SAFETY 4					/*	safety factor for time delays	*/
#endif

//	Exceptions thrown

//class SevereX {};

//	C++ support classes

#include "hd44780.hpp"
#include "ExtDriver.hpp"
#include "ControllerPool.hpp"
#include "EnvVar.hpp"
#include "ToolTypeMatch.hpp"
#include "MemMap.hpp"
#include "OutputStream.hpp"

/********************************************************************************************/

//	Global variables

static LONG newpri;
static UBYTE running,cursorstate,descenders,dots,quiet;
static ULONG contrast=~0,backlight=~0;
static UBYTE universalbuffer[UNIVERSALBUFFERSIZE];
static UBYTE *verstag=VERSTAG;
static UBYTE *okay="OK";
static struct WBStartup *StartupMessage=NULL;

//	Auto-open of additional libraries
LibraryBaseErrC RexxSysBase("rexxsyslib.library",36L);	//	for REXX port
//LibraryBaseErrC LocaleBase("locale.library",38L);			//	for IsSpace in REXX
LibraryBaseErrC ExpansionBase("expansion.library",37L);	//	for card autodetection
LibraryBaseErrC UtilityBase("utility.library",37L);		//	for Strnicmp()
LibraryBaseErrC WorkbenchBase("workbench.library",37L);		//	for startup messages and 
struct Library *TimerBase=NULL;

//	Exported to driver module
STRPTR startup;
struct lcdparams lcdpar={16,40,2,5};
struct timerequest *timereq;

//	Imported from port driver

//extern "C" void	lcd_pre_message(void);
//extern "C" void	lcd_post_message(void);

//	A group of HD44780 controllers
ControllerPool ctrlpool;


//	Time request containing all display info

#define	TRC_FREE_IF_EXPIRED	1L
#define	TRC_CANT_TOUCH_THIS	2L
#define	TRC_CAME_FROM_REXX	4L
#define	TRC_INVALID_CUSTOMCHARS	1L
#define	TRC_INVALID_DISPLAYDATA	2L
#define	TRC_INVALID_OPTICAL		4L

class TimerHandler : public IORequestC {
public:
	TimerHandler(InfoRequesterC &info,ULONG unit=0);
	~TimerHandler();
protected:
	virtual BOOL handleMsg(MessageC &);
private:
};
extern TimerHandler alarm;

class TimeRequestC : public ENodeC {
public:
	TimeRequestC(ULONG flags=0L);
	BOOL ConvertText(STRPTR text);
	void Expires(ULONG ticks);
	void Priority(BYTE pri);
	void Enqueue(void);
	void Expire(BOOL Free=TRUE);
	ULONG Update(ULONG ticks);
	ULONG IsREXX(void){return flags&TRC_CAME_FROM_REXX;}
	void AddTimerHandler(int &hndl);
	BOOL CanTouchThis(void){return !(flags&TRC_CANT_TOUCH_THIS);};
	static void InitConversionTable(void);
	static void Reschedule(void);
	static ULONG Allocated(void){return instances;}
	operator struct lcdscreen *() {return &scrn;};
	~TimeRequestC();
	static EListC queue;
	static MemoryMapC *memmap;
private:
	static TimeRequestC *active;
	static UBYTE asc2lcd[256];
	struct lcdscreen scrn;
	struct timeval endtime;
	static ULONG instances;
	ULONG	flags;
	ULONG	invalidated;
	ULONG	backlight;
	ULONG	contrast;
	UBYTE *scrbuf;
	UBYTE *charbuf;
	UBYTE customcharnum,customcharheight;
};
TimeRequestC::TimeRequestC(ULONG flags) : ENodeC() {
	UWORD memsiz=lcdpar.virtualwidth*lcdpar.height;
	scrbuf=(UBYTE *)AllocVec(memsiz,MEMF_ANY);
	scrn.screenbuffer=(UBYTE *)AllocVec(memsiz,MEMF_PUBLIC);
	charbuf=(UBYTE *)AllocVec(64,MEMF_ANY|MEMF_CLEAR);
	if(!scrbuf||!charbuf||!scrn.screenbuffer)throw MemoryX();
	memset(scrn.screenbuffer,' ',memsiz);
	memset(scrbuf,' ',memsiz);
	scrn.version=LCDSCREEN_MINVERSION;
	scrn.bufferwidth=lcdpar.virtualwidth;
	scrn.bufferheight=lcdpar.height;
	scrn.myprivate=(APTR)this;
	scrn.ud_flags=0;
	scrn.customcharheight=8;
	scrn.customcharnum=8;
	scrn.customchardefs=NULL;
	scrn.contrast=scrn.backlight=~0;
	this->flags=flags;
	this->contrast=contrast;this->backlight=backlight;
	invalidated=0;
	instances++;
}
TimeRequestC::~TimeRequestC(){
	instances--;
	if(isInList())remove();
	if(scrn.screenbuffer)FreeVec(scrn.screenbuffer);
	if(scrbuf)FreeVec(scrbuf);
	if(charbuf)FreeVec(charbuf);
}
BOOL TimeRequestC::ConvertText(STRPTR text){
	UWORD x,charsinword;	//	x=current X position on this line
	STRPTR from,to,wordstart,maxbuf;
	STRPTR dest;
	UBYTE chr;
	from=text;
	dest=to=scrbuf;
	wordstart=text;
	x=charsinword=0;
	maxbuf=&scrbuf[scrn.bufferheight*scrn.bufferwidth];
	do{
		chr=*from;
		if((to+charsinword)>=(maxbuf-1))chr=0;
		if(to>=maxbuf)break;
		switch(chr){
			case ' ':
			case 0x00:
				if(charsinword){
					if(x+charsinword<=lcdpar.width){
						//	Word fits on line: just add it.
						CopyMem(wordstart,to,charsinword);

						charsinword++;
						wordstart+=charsinword;
						x+=charsinword;
						to+=charsinword;
						charsinword=0;
					}else{
						if(charsinword>lcdpar.width){
							// Can't possibly fit this on any line. Just cut off as much as we can fit on this line
							// and then re-process until it does fit
							UWORD fittingpart=lcdpar.width-x;
							CopyMem(wordstart,to,fittingpart);
							wordstart+=fittingpart;
							charsinword-=fittingpart;
						}else{
							// First add blanks to newline, after which the word can be copied.
							memset(to,' ',scrn.bufferwidth-x-1);
						}
						to+=scrn.bufferwidth-x;
						x=0;
						from--; //do this loop again for the remaining word so we correct for the from++ later on
						chr=0xff;	//	Make sure we get another pass even if this is the end of the string
					}
				}else{
					//	Another space comes in... Just copy
					wordstart++;
					x++;to++;
					if(x>=lcdpar.width){
						to+=lcdpar.virtualwidth-x;
						x=0;
					}
				}
				break;
			default:
				charsinword++;	//	Process characters until we encounter the next space or arrive at the end
		}
		from++;
	}while(chr);/* &&(to+charsinword)<maxbuf);*/

	return TRUE;
}
void TimeRequestC::InitConversionTable(void){
	register UBYTE i=0;
	do{
		asc2lcd[i]=i;
	} while(++i);

	if(descenders){
		asc2lcd['p']=0xF0;
		asc2lcd['q']=0xF1;
	}
	asc2lcd[165]=asc2lcd['[']+1;
	asc2lcd[187]=asc2lcd['}']+1;
	asc2lcd[171]=asc2lcd[187]+1;
	asc2lcd[183]=165;
	asc2lcd[197]=asc2lcd[228]=0xE1;
	asc2lcd[223]=0xE2;
	asc2lcd[181]=0xE4;
	asc2lcd[185]=0xE9;
	asc2lcd[131]=0xEA;
	asc2lcd[215]=0xEB;
	asc2lcd[162]=0xEC;
	asc2lcd[209]=asc2lcd[241]=0xEE;
	asc2lcd[214]=asc2lcd[246]=0xEF;
	asc2lcd[222]=asc2lcd[254]=0xF2;
	asc2lcd[167]=0xF3;
	asc2lcd[220]=asc2lcd[252]=0xF5;
	asc2lcd[182]=0xF7;
	asc2lcd[247]=0xFD;
	asc2lcd[173]=0xFF;
	/*asc2lcd['']=asc2lcd['']+1;*/
}
void TimeRequestC::Expires(ULONG ticks){
	struct timeval thistime;
	if(ticks!=~0){
		GetSysTime(&endtime);
		thistime.tv_secs=ticks/50;
		thistime.tv_micro=(ticks%50)*20000;
		AddTime(&endtime,&thistime);
	}else{
		endtime.tv_secs=~0;
		endtime.tv_micro=~0;
	}
}
void TimeRequestC::Enqueue(void){
	if(isInList())remove();
	queue.enqueue((ENodeC &)*this);
}
ULONG TimeRequestC::Update(ULONG ticks){
	BOOL rethink=FALSE;
	struct lcdscreen *sc=&(this->scrn);
	D(BUG("Update"));
	if(scrn.ud_flags&LCDUPD_DISPLAY){
		CopyMem(scrn.screenbuffer,scrbuf,scrn.bufferwidth*scrn.bufferheight);
		rethink=TRUE;
	}
	if(scrn.ud_flags&LCDUPD_CUSTOMCHARNUM){
		if(scrn.customchardefs){
			if((customcharnum*customcharheight)!=(scrn.customcharnum*scrn.customcharheight)){
				UBYTE *newbuf;
				if(newbuf=(UBYTE *)AllocVec(scrn.customcharnum*scrn.customcharheight,MEMF_PUBLIC)){
					if(charbuf)FreeVec(charbuf);
					charbuf=newbuf;
					customcharnum=scrn.customcharnum;
					customcharheight=scrn.customcharheight;
					if((NodeC *)this==queue.first()){
						invalidated|=TRC_INVALID_CUSTOMCHARS;
					}
				}else{
					D(BUG("Update:nomem"));
					return LCDERR_NOMEM;
				}
			}
		}
	}
	if(scrn.ud_flags&LCDUPD_CUSTOMCHARDEFS){
		if(charbuf&&(customcharnum*customcharheight)){
			CopyMem(scrn.customchardefs,charbuf,scrn.customcharheight*scrn.customcharnum);
			if((NodeC *)this==queue.first()){
				invalidated|=TRC_INVALID_CUSTOMCHARS;
			}
		}
	}
	if(scrn.ud_flags&LCDUPD_DISPLAY){
		CopyMem(scrn.screenbuffer,scrbuf,scrn.bufferwidth*scrn.bufferheight);
		if(((NodeC *)this)==queue.first()){
			invalidated|=TRC_INVALID_DISPLAYDATA;
		}
	}
	if(scrn.ud_flags&LCDUPD_OPTICAL){
		if(scrn.version>=22){
			invalidated|=TRC_INVALID_OPTICAL;
			contrast=scrn.contrast;
			backlight=scrn.backlight
		}
	}
	Expires(ticks);
	if(!isInList()){
		D(BUG("Re-Enqueueing lcdscreen"));
		Enqueue();
	}
	D(BUG("End Update"));
	return LCDERR_NONE;
}
void TimeRequestC::Priority(BYTE pri){
	if(isInList()){
		if(this->pri()!=pri){
			remove();
			setPri(pri);
			queue.enqueue(*this);
		}
	}else{
		setPri(pri);
	}
}
void TimeRequestC::Reschedule(void){
	TimeRequestC *head,*next;
	struct timeval now;
	D(BUG("Reschedule"));
	GetSysTime(&now);
	//	Filter out all expired requests and free them if necessary
	for(next=(TimeRequestC *)(queue.first());head=next;){
		D(BUG("Checking timerequest for expiration"));
		next=(TimeRequestC *)(head->next());
		if(CmpTime(&head->endtime,&now)>0){
			head->remove();
			if(head==active)active=NULL;
			if(head->flags & TRC_FREE_IF_EXPIRED){
				D(BUG("Deleting timerequest"));
				delete head;
			}
		}
	}
	//	Update visible request if necessary
	head=(TimeRequestC *)(queue.first());
	int pre_called=0;
	if(head){
		if((active!=head) || (head->invalidated & TRC_INVALID_CUSTOMCHARS)){
			ExtDriverC::lcd_pre_message();pre_called=1;
			D(BUG("Checking timerequest for customchars"));
			//	Update of custom characters
//	For the moment, no controller specific characters are necessary so we send the data at once to all controllers.
//	instead of looping through all controllers.
//  See also class HD44780::lcd_WriteData for this fix.
//			for(register UWORD i=0;i<ctrlpool.numControllers();i++){
//				UWORD ctrllr=i/2;
				const UWORD ctrllr=0;
				ctrlpool.Controller(ctrllr).lcd_CGRAMAddress(0);
				for(register UWORD j=0;j<head->customcharnum*head->customcharheight;j++){
				ctrlpool.Controller(ctrllr).lcd_WriteData(head->charbuf[j]);
				}
//			}
			head->invalidated&=~TRC_INVALID_CUSTOMCHARS;
		}
		if((active!=head) || (head->invalidated&TRC_INVALID_DISPLAYDATA)){
			if(!pre_called){
				ExtDriverC::lcd_pre_message();pre_called=1;
			}
			D(BUG("Checking timerequest for displaydata"));
			//	Update the data to reflect this timerequest.
			//	Reset all controllers to home position, without clearing to avoid flicker
			for(int ctrllr=0;ctrllr<ctrlpool.numControllers();ctrllr++){
				ctrlpool.Controller(ctrllr).lcd_DDRAMAddress(0);	//	faster than HOME
			}
			//	Now walk through the request and update its contents
			ctrllr=0;
			int ctrly,x,y;
			ctrlpool.Controller(ctrllr).lcd_DDRAMAddress(0);
			for(y=0,ctrly=0;y<head->scrn.bufferheight;y++,ctrly++){
				UBYTE *chr = &(head->scrbuf[(head->scrn.bufferwidth)*y]);
				for(x=0;x<lcdpar.width;x++){
					int skip;
					ctrlpool.Controller(ctrllr).lcd_WriteData(asc2lcd[*chr++]);
					if(memmap->eoc(x,ctrly)){
						++ctrllr;ctrly=0;
						if(ctrllr>=ctrlpool.numControllers())goto l_UpdateComplete;

						ctrlpool.Controller(ctrllr).lcd_DDRAMAddress(0);
					}else if((skip=memmap->skip(x,ctrly))!=MemoryMapC::e_DontSkip){
						ctrlpool.Controller(ctrllr).lcd_DDRAMAddress(skip);
					}
				}
			}
			l_UpdateComplete:
			head->invalidated&=~TRC_INVALID_DISPLAYDATA;
		}
		if((active!=head) || (head->invalidated & TRC_INVALID_OPTICAL)){
			if(!pre_called){
				ExtDriverC::lcd_pre_message();pre_called=1;
			}
			ExtDriverC::lcd_visual(head->backlight,head->contrast);
		}
	}else{
		D(BUG("No scheduled request..clearing LCD"));
		ExtDriverC::lcd_pre_message();pre_called=1;
		for(register UWORD i=0;i<ctrlpool.numControllers();i++){
			ctrlpool.Controller(i).lcd_Clear();
		}
	}

	if(pre_called)ExtDriverC::lcd_post_message();

	if(head&&(active!=head)){
		D(BUG("Rescheduling alarm"));
		if(alarm.isSend()){
			D(BUG("Removing old alarm"));
			alarm.abortIO();
			alarm.waitIO();
		}
		struct timerequest *req=(struct timerequest *)alarm.request();
		req->tr_time.tv_secs=head->endtime.tv_secs;
		req->tr_time.tv_micro=head->endtime.tv_micro;
		alarm.sendIO(TR_ADDREQUEST);
	}
	active=head;
	D(BUG("End Reschedule"));
}
void TimeRequestC::Expire(BOOL Free){
	endtime.tv_secs=0;
	endtime.tv_micro=0;
	flags|=(Free?TRC_FREE_IF_EXPIRED:0L)|TRC_CANT_TOUCH_THIS;
}
EListC TimeRequestC::queue;
UBYTE TimeRequestC::asc2lcd[256];
ULONG TimeRequestC::instances=0;
TimeRequestC *TimeRequestC::active=NULL;
MemoryMapC *TimeRequestC::memmap;


//	Timer device interface

TimerHandler::TimerHandler(InfoRequesterC &info,ULONG unit):IORequestC(sizeof(struct timerequest)){
	if(open("timer.device",unit,0)){
		info.request("Can't allocate timer.device");
		throw MemoryX();
	}
	TimerBase=(struct Library *)(request()->io_Device);
}
TimerHandler::~TimerHandler(){
//	close();
}
BOOL TimerHandler::handleMsg(MessageC &msg){
	D(BUG("Handle timer message..."));
	waitIO();
	D(BUG("Rescheduling from timer handler"));
	TimeRequestC::Reschedule();
	D(BUG("End of timer handling"));
	return (!running && !TimeRequestC::Allocated());
}

InfoRequesterC info(NULL,LCDNAME,okay);
TimerHandler alarm(info,UNIT_WAITUNTIL);
TimerHandler pause(info,UNIT_MICROHZ);



//	AREXX handler functions

typedef void (rxfunction)(struct RexxMsg *, STRPTR);
struct RDArgs *rxf_makeargs(STRPTR templ,APTR param,STRPTR text){
	struct RDArgs *arg;
	STRPTR tmptext;
	ULONG textlen;
	if(text){
		textlen=strlen(text);
		if(tmptext=(STRPTR)AllocVec(textlen+2,MEMF_ANY)){
			if(arg=(struct RDArgs *)AllocDosObjectTags(DOS_RDARGS,TAG_END)){
				//sprintf(tmptext,"%s\n",text);
				CopyMem(text,tmptext,textlen);
				tmptext[textlen]='\n';
				tmptext[++textlen]=0;
				arg->RDA_Source.CS_Buffer=tmptext;
				arg->RDA_Source.CS_Length=textlen;
				arg->RDA_Source.CS_CurChr=0;
				arg->RDA_Buffer=universalbuffer;
				arg->RDA_BufSiz=UNIVERSALBUFFERSIZE;
				arg->RDA_ExtHelp=NULL;
				arg->RDA_Flags=RDAF_NOPROMPT;
				if(ReadArgs(templ,(LONG *)param,arg)){
					FreeVec(tmptext);
					return(arg);
				}
				FreeDosObject(DOS_RDARGS,arg);
			}
			FreeVec(tmptext);
		}
	}
	return(FALSE);
}
void rxf_lcdmessage(struct RexxMsg *rxmsg, STRPTR text){	STRPTR tmplate="TIME/K/N,PRI/K/N,TEXT/F\n";
	APTR rexxparams[MAXREXXPARAMS];
	struct RDArgs *arg;
	ULONG deftime=200;
	LONG defpri=LCDPRI_APPLICATION-10;
	rexxparams[0]=&deftime;
	rexxparams[1]=&defpri;
	rexxparams[2]=NULL;
	if(arg=rxf_makeargs(tmplate,rexxparams,text)){
		try{
			TimeRequestC *tr = new TimeRequestC(TRC_FREE_IF_EXPIRED|TRC_CAME_FROM_REXX);
			if(tr->ConvertText((STRPTR)rexxparams[2])){
				tr->Priority((BYTE)((*(LONG *)rexxparams[1])&0xff));
				tr->Expires(*(ULONG *)rexxparams[0]);
				tr->Enqueue();
			}else{
				delete tr;
			}
		}catch(...){
		}
		FreeArgs(arg);
		FreeDosObject(DOS_RDARGS,arg);
	} else {
		rxmsg->rm_Result1=ERR10_018;
	}
}
void rxf_getchars(struct RexxMsg *rxmsg,STRPTR text){
	UBYTE	result[5];
	rxmsg->rm_Result1=0;
	sprintf(result,"%1.4d",lcdpar.width);
	if(!(rxmsg->rm_Result2=(LONG)CreateArgstring(result,strlen(result)))){
		rxmsg->rm_Result2=NULL;
	}
}
void rxf_getlines(struct RexxMsg *rxmsg,STRPTR text){
	UBYTE	result[5];
	rxmsg->rm_Result1=0;
	sprintf(result,"%1.4d",lcdpar.height);
	if(!(rxmsg->rm_Result2=(LONG)CreateArgstring(result,strlen(result)))){
		rxmsg->rm_Result2=NULL;
	}
}
void rxf_norexxmsgs(struct RexxMsg *rxmsg,STRPTR text){
	TimeRequestC *head,*next;
	D(BUG("Killing REXX related messages..."));
	for(next=(TimeRequestC *)(TimeRequestC::queue.first());head=next;){
		D(BUG("Checking timerequest for rexxness"));
		next=(TimeRequestC *)(head->next());
		if(head->IsREXX()){
			head->Expire();
		}
	}
	D(BUG("REXX murder completed..."));
}


//	AREXX port handling


class REXXPortC : public PortC {
public:
	REXXPortC(STRPTR name);
	inline void RegisterREXXFunction(STRPTR n,rxfunction *f);
	struct rexxfunction *MatchREXXFunction(STRPTR name);
	~REXXPortC();
protected:
	virtual BOOL handleMsg(MessageC &msg);
private:
	struct rexxfunction {
		STRPTR  name;
		rxfunction *function;
	} rexxfunctions[MAXREXXFUNCTIONS];
	ULONG numrexxfunctions;
	struct RDArgs *makeargs(STRPTR templ,APTR param,STRPTR text);
};
REXXPortC::REXXPortC(STRPTR name) : PortC(name,0) {
	numrexxfunctions=0;
	RegisterREXXFunction("LCDMESSAGE",rxf_lcdmessage);
	RegisterREXXFunction("GETCHARACTERS",rxf_getchars);
	RegisterREXXFunction("GETLINES",rxf_getlines);
	RegisterREXXFunction("CLEARREXXMESSAGES",rxf_norexxmsgs);
}
REXXPortC::~REXXPortC(){
}
void REXXPortC::RegisterREXXFunction(STRPTR n,rxfunction *f){
	rexxfunctions[numrexxfunctions].name=n;
	rexxfunctions[numrexxfunctions].function=f;
	numrexxfunctions++;
}
rexxfunction *REXXPortC::MatchREXXFunction(STRPTR name){
	STRPTR endword=name;
	rexxfunction *fun=NULL;
	if(name){
		while(*endword){
			if(*endword==' '){
				break;
			}
			endword++;
		}
		for(register UWORD i=0;i<numrexxfunctions;i++){
			if(!Strnicmp(name,rexxfunctions[i].name,endword-name)){
				fun=&rexxfunctions[i];
				break;
			}
		}
	}
	return fun;
}
BOOL REXXPortC::handleMsg(MessageC &msg){
	STRPTR string;
	struct RexxMsg &rxmsg=(struct RexxMsg &)msg;
	if(!msg.isReplied()){
		rxmsg.rm_Result1=rxmsg.rm_Result2=0;
		if(running){
			if(IsRexxMsg(&rxmsg)){
				string=(STRPTR)rxmsg.rm_Args[0];
				while(*string && isspace(*string))string++;	//	Skip leading spaces
				rexxfunction *rxf=MatchREXXFunction(string);
				if(rxf){
					(*rxf->function)(&rxmsg,string+strlen(rxf->name));
				}else{
					rxmsg.rm_Result1=ERR10_015;	//	function not found
				}
			}
		} else {
			rxmsg.rm_Result1=LCDRXE_IMGONE;
		}
		msg.reply();
	}
	TimeRequestC::Reschedule();
	return FALSE;
}


//	Public rendezvous message port handler

class PublicPortC : public PortC {
public:
	PublicPortC(STRPTR name);
	~PublicPortC();
protected:
	virtual BOOL handleMsg(MessageC &msg);
private:
	UWORD handlesopen,allocated;
};
PublicPortC::PublicPortC(STRPTR name) : PortC(name,0) {
	handlesopen=0;
	allocated=0;
}
PublicPortC::~PublicPortC(){
}
BOOL PublicPortC::handleMsg(MessageC &msg){
	D(BUG("Message received"))
	if(!msg.isReplied()){
		D(BUG("Processing message"))
		struct lcdmessage &lcdmsg=(struct lcdmessage &)msg;
		lcdmsg.lcd_Error=LCDERR_TOOBUSY;
		switch(lcdmsg.lcd_Code){
			case LCDMSG_ASKPARAMS:	//	Fill out the supplied parameter field and return it
				D(BUG("ASKPARMS message"))
				lcdmsg.lcd_Error=LCDERR_YOURFAULT;
				if(lcdmsg.lcd_Data){
					((struct lcdparams *)lcdmsg.lcd_Data)->width=lcdpar.width;
					((struct lcdparams *)lcdmsg.lcd_Data)->virtualwidth=lcdpar.virtualwidth;
					((struct lcdparams *)lcdmsg.lcd_Data)->height=lcdpar.height;
					((struct lcdparams *)lcdmsg.lcd_Data)->maxqueuetime=lcdpar.maxqueuetime;
					lcdmsg.lcd_Error=LCDERR_NONE;
				}
				break;

			case LCDMSG_NONE:	//	Futile

				D(BUG("NULL message"))
				lcdmsg.lcd_Error=LCDERR_NONE;
				break;

			case LCDMSG_QUEUE:	//	Queue a supplied text string
				{
					D(BUG("QUEUE message"))
					lcdmsg.lcd_Error=LCDERR_NOMEM;
					TimeRequestC *tr;
					try{
						tr = new TimeRequestC(TRC_FREE_IF_EXPIRED);
						lcdmsg.lcd_Error=LCDERR_YOURFAULT;
						if(tr->ConvertText((STRPTR)lcdmsg.lcd_Data)){
							tr->Expires(lcdmsg.lcd_Ticks);
							tr->Priority(lcdmsg.lcd_Priority);
							tr->Enqueue();
							lcdmsg.lcd_Error=LCDERR_NONE;
						}else{
							delete tr;
						}
					}catch(...){}
				}
				break;

			case LCDMSG_ALLOCATEHANDLE:
				D(BUG("ALLOCATEHANDLE message"))
				lcdmsg.lcd_Error=LCDERR_TOOBUSY;
				if(running&&!allocated){
					lcdmsg.lcd_Error=LCDERR_NOMEM;
					try{
						TimeRequestC *newtr=new TimeRequestC;
						lcdmsg.lcd_Error=LCDERR_NONE;
						lcdmsg.lcd_Data=(APTR)(struct lcdscreen *)(*newtr);
						newtr->Expires(lcdmsg.lcd_Ticks);
						newtr->Priority(lcdmsg.lcd_Priority);
						newtr->Enqueue();
						handlesopen++;
					}catch(...){
					}
				}
				break;

			case LCDMSG_FREEHANDLE:
				{
					D(BUG("FREEHANDLE message"))
					lcdmsg.lcd_Error=LCDERR_NONE;
					//	TODO: Remove TimeRequestC by invalidating expiration time and setting free_if_expired flag
					TimeRequestC *tr=(TimeRequestC *)(((struct lcdscreen *)lcdmsg.lcd_Data)->myprivate);
//					if(tr->CanTouchThis()){
						tr->Enqueue();	//	We need to enqueue this to make sure it will be deleted in the rescheduler.
						tr->Expire();
						handlesopen--;
//					}
				}
				break;

			case LCDMSG_UPDATEHANDLE:
				{
					D(BUG("UPDATEHANDLE message"))
					lcdmsg.lcd_Error=LCDERR_TOOBUSY;
					if(running){
						TimeRequestC *tr=(TimeRequestC *)(((struct lcdscreen *)lcdmsg.lcd_Data)->myprivate);
//						lcd_updatescreen((struct lcdscreen *)lcdmsg->lcd_Data,lcdmsg);
						if(tr->CanTouchThis()){
							tr->Priority(lcdmsg.lcd_Priority);
							lcdmsg.lcd_Error=tr->Update(lcdmsg.lcd_Ticks);
						}
					}
				}
				break;
			default:
				D(BUG("Unknown message"))
				lcdmsg.lcd_Error=LCDERR_UNKNOWN;

		}
		D(BUG("Replying..."))
		msg.reply();
		D(BUG("Rescheduling..."))
		TimeRequestC::Reschedule();
	}
	D(BUG("Message processing completed."))
	return ((!TimeRequestC::Allocated()) && (!running));
}


//	CtrlCDispatcher

class CtrlCDispatcher : public CtrlCHandlerC{
		virtual BOOL pressed(void);
};
BOOL CtrlCDispatcher::pressed(void){
	//	Block all new requests coming in and update requests from existing clients
	running=FALSE;

	ULONG length=TimeRequestC::queue.length();
	for(ULONG i=0;i<length;i++){
		struct TimeRequestC *request=(struct TimeRequestC *)TimeRequestC::queue.find(i);
		if(request){
			//	Mark all pending requests as obsolete but don't try to free them
			//	since this is the client's job.
			request->Expire(FALSE);	//	Don't free ourselves, let the client do this.
		}
	}

	TimeRequestC::Reschedule();	//	Now try to clean up everything we can

	ULONG allocated;
	if(allocated=TimeRequestC::Allocated()){
		info.request(
			"Can't quit yet: %ld client handle%s still allocated.\n"
			"However,new requests will be denied and LCDaemon\n"
			"will quit once all clients have unregistered.",
		allocated,allocated>1?"s are":" is");
		return FALSE;
	}else{
		return TimeRequestC::queue.isEmpty();
	}
}

//	Control-F (forced quit) dispatcher

class CtrlFDispatcher : public CtrlFHandlerC{
		virtual BOOL pressed(void);
};
BOOL CtrlFDispatcher::pressed(void){
	ThreeButtonRequesterC sure(NULL,LCDNAME,"Forced quit","Quit","Cancel");
	switch(sure.request(
		"A forced quit of LCDaemon can result in memory loss\n"
		"and/or system instability. Are you sure you want to\n"
		"quit forcibly?"
	)){
		case 1:
			return TRUE;
		case 2:
			SetSignal(SIGBREAKF_CTRL_C,SIGBREAKF_CTRL_C);
		default:
	}
	return FALSE;
}

//	Light-weight AmigaOS cout equivalent
OutputStream output;

//	Main loop

ULONG main(void){
	STRPTR	driverlib;
	ULONG memmaptype;
	if(!LibraryBaseC::areAllOpen()) return(20L);

	//	Declare main signal dispatcher
	SignalsC mainsigs;
	//	Handle break signal
	CtrlCDispatcher ctrlc;
	CtrlFDispatcher ctrlf;

	//	Make the struct timerequest publicly available to the port driver.
	timereq=(struct timerequest *)pause.request();

	try{
		enum ParmEnum {
			PARM_WIDTH,PARM_VIRTUALWIDTH,PARM_LINESPERCONTROLLER,PARM_HEIGHT,PARM_TASKPRI,
			PARM_STARTUP,PARM_CURSOR,
			PARM_DESCENDERS,PARM_TENDOTS,PARM_QUIET,
			PARM_DRIVERLIB,PARM_CONTRAST,PARM_BACKLIGHT,
			PARM_MEMMAP
		};
		STRPTR ParmName[]={
			"LCDaemon/WIDTH",
			"LCDaemon/VIRTUAL",
			"LCDaemon/LINESPERCONTROLLER",
			"LCDaemon/HEIGHT",
			"LCDaemon/TASKPRI",
			"LCDaemon/STARTUP",
			"LCDaemon/CURSOR",
			"LCDaemon/DESCENDERS",
			"LCDaemon/TENDOTS",
			"LCDaemon/QUIET",
			"LCDaemon/DRIVERLIB",
			"LCDaemon/CONTRAST",
			"LCDaemon/BACKLIGHT",
			"LCDaemon/MEMMAP"
		};

		//	Read environment variables
		EnvVarC env;
		lcdpar.width=env.getNumber(ParmName[PARM_WIDTH],20);
		lcdpar.virtualwidth=env.getNumber(ParmName[PARM_VIRTUALWIDTH],0x40);
		ControllerPool::m_LinesPerController=env.getNumber(ParmName[PARM_LINESPERCONTROLLER],2);
		lcdpar.height=env.getNumber(ParmName[PARM_HEIGHT],2);
		newpri=env.getNumber(ParmName[PARM_TASKPRI],0);
		startup=env.getStr(ParmName[PARM_STARTUP],NULL);
		cursorstate=env.getSwitch(ParmName[PARM_CURSOR]);
		descenders=env.getSwitch(ParmName[PARM_DESCENDERS]);
		dots=(env.getSwitch(ParmName[PARM_TENDOTS])?LCDC_TENDOTS:LCDC_SEVENDOTS);
		quiet=env.getSwitch(ParmName[PARM_QUIET]);
		driverlib=env.getStr(ParmName[PARM_DRIVERLIB],NULL);
		contrast=env.getNumber(ParmName[PARM_CONTRAST],contrast);
		backlight=env.getNumber(ParmName[PARM_BACKLIGHT],backlight);
		memmaptype=env.getNumber(ParmName[PARM_MEMMAP],0);

		//	Override them with icon values, if any

		ToolTypeMatchC toolt(StartupMessage);

		const int prefixoffset=9;	//	Reuse the same string table by skipping the "LCDaemon/" prefix

		lcdpar.width=toolt.getNumber(ParmName[PARM_WIDTH]+prefixoffset,lcdpar.width);
		lcdpar.virtualwidth=toolt.getNumber(ParmName[PARM_VIRTUALWIDTH]+prefixoffset,lcdpar.virtualwidth);
		ControllerPool::m_LinesPerController=toolt.getNumber(ParmName[PARM_LINESPERCONTROLLER]+prefixoffset,ControllerPool::m_LinesPerController);
		lcdpar.height=toolt.getNumber(ParmName[PARM_HEIGHT]+prefixoffset,lcdpar.height);
		newpri=toolt.getNumber(ParmName[PARM_TASKPRI]+prefixoffset,newpri);
		startup=toolt.getStr(ParmName[PARM_STARTUP]+prefixoffset,startup);
		cursorstate=toolt.getSwitch(ParmName[PARM_CURSOR]+prefixoffset)?TRUE:cursorstate;
		descenders=toolt.getSwitch(ParmName[PARM_DESCENDERS]+prefixoffset)?TRUE:descenders;
		dots=toolt.getSwitch(ParmName[PARM_TENDOTS]+prefixoffset)?LCDC_TENDOTS:dots;
		quiet=toolt.getSwitch(ParmName[PARM_QUIET]+prefixoffset)?TRUE:quiet;
		driverlib=toolt.getStr(ParmName[PARM_DRIVERLIB]+prefixoffset,driverlib);
		contrast=toolt.getNumber(ParmName[PARM_CONTRAST]+prefixoffset,contrast);
		backlight=toolt.getNumber(ParmName[PARM_BACKLIGHT]+prefixoffset,backlight);
		memmaptype=toolt.getNumber(ParmName[PARM_MEMMAP]+prefixoffset,memmaptype);

		//	Override them with command line args
		ArgsC	cmdargs(
				"WIDTH=CHARACTERS/K/N,"
				"VIRTUAL=VIRTUALWIDTH/K/N,"
				"LINESPERCONTROLLER=LPC/K/N,"
				"HEIGHT=LINES/K/N,"
				"TASKPRI=TP/K/N,"
				"STARTUP=ST/K,"
				"CURSOR=C/S,"
				"DESCENDERS=D/S,"
				"TENDOTS/S,"
				"QUIET=Q/S,"
				"DRIVERLIB/K,"
				"CONTRAST/K/N,"
				"BACKLIGHT/K/N,"
				"MEMMAP/K/N"
				"\n");
		if(!StartupMessage){
			lcdpar.width=cmdargs.getNumber(PARM_WIDTH,lcdpar.width);
			lcdpar.virtualwidth=cmdargs.getNumber(PARM_VIRTUALWIDTH,lcdpar.virtualwidth);
			ControllerPool::m_LinesPerController=cmdargs.getNumber(PARM_LINESPERCONTROLLER,ControllerPool::m_LinesPerController);
			lcdpar.height=cmdargs.getNumber(PARM_HEIGHT,lcdpar.height);
			newpri=cmdargs.getNumber(PARM_TASKPRI,newpri);
			startup=cmdargs.getStr(PARM_STARTUP,startup);
			cursorstate=cmdargs.getSwitch(PARM_CURSOR)?TRUE:cursorstate;
			descenders=cmdargs.getSwitch(PARM_DESCENDERS)?TRUE:descenders;
			dots=cmdargs.getSwitch(PARM_TENDOTS)?LCDC_TENDOTS:dots;
			quiet=cmdargs.getSwitch(PARM_QUIET)?TRUE:quiet;
			driverlib=cmdargs.getStr(PARM_DRIVERLIB,driverlib);
			contrast=cmdargs.getNumber(PARM_CONTRAST,contrast);
			backlight=cmdargs.getNumber(PARM_BACKLIGHT,backlight);
			memmaptype=cmdargs.getNumber(PARM_MEMMAP,memmaptype);
		}

		//	ISO Latin to HD44780 ascii conversion table
		TimeRequestC::InitConversionTable();
	
		//	Initialize port driver
		ExtDriverC driver(info,driverlib);
		if(!driver.DriverName())return 5L;
		driver.lcd_visual(backlight,contrast);
		if(ExtDriverC::userport){
			mainsigs.add(*ExtDriverC::userport);
		}


		//	Initialize the memory map
		MemoryMapC memmap(lcdpar.width,ControllerPool::m_LinesPerController,lcdpar.virtualwidth,MemoryMapC::MemoryOrganization(memmaptype));
		TimeRequestC::memmap=&memmap;
	
		//	Keep on trying to inialize ports until we find a non-public one.
		int portid;
		try{
			for(portid=0;portid>=0 && portid<=MAXPORTNUMBER;portid++){
				UBYTE lcdportnameid[32],lcdrexxnameid[16];
				strcpy(lcdportnameid,lcdportname);
				strcpy(lcdrexxnameid,lcdrexxname);
				if(portid){	//	Concatenate the id number to the port name
					sprintf(&lcdportnameid[strlen(lcdportnameid)],".%d",portid);
					sprintf(&lcdrexxnameid[strlen(lcdrexxnameid)],".%d",portid);
				}
	
				try{
					//	Allocate the ports
					PublicPortC rendezvous(lcdportnameid);
					REXXPortC rexx(lcdrexxnameid);
					portid=-1;	//	Indicate port allocation went OK.
	
					if(!quiet){
						output<<(STRPTR)LCDNAME<<newline
							<<"© 1995-1998 Hendrik De Vloed"<<newline
							<<"Configuration statistics:"<<newline
							<<"Hitachi HD44780 controller"<<newline
							<<"connected to "<<driver.DriverName()<<newline
							<<lcdpar.width<<" characters"<<newline
							<<((lcdpar.height>1)?2:1)<<" line(s)/controller"<<newline
							<<"("<<(lcdpar.height+1)/2<<" controller(s))"<<newline;
					}
					//	Now allocate virtual controllers to cache HD44780 I/O
					ExtDriverC::lcd_pre_message();
					try{
						for(UBYTE i=0;i<(lcdpar.height+1)/2;i++){
							D(BUG("Allocating controller"));
							HD44780 *newctrl=new HD44780(i,
								((dots==LCDC_TENDOTS)	?	HD44780_INIT_TALLCHARS	:	0)||
								((i==(lcdpar.height-1))	?	0							:	HD44780_INIT_TWOLINES)
							);
							//	The controller pool will take care of deallocation
							D(BUG("Adding controller to pool"));
							ctrlpool.AddController(*newctrl);
						}
					}catch(...){
						info.request("Controller initialization failed");
						return(5L);
					}
					ExtDriverC::lcd_post_message();
					//	Set up all necessary message dispatchers
					mainsigs.add(ctrlc);
					mainsigs.add(ctrlf);
					mainsigs.add(rendezvous);
					mainsigs.add(rexx);
					mainsigs.add(alarm);
	
					if(!quiet){output<<"Started"<<newline;}
	
					running=TRUE;
					if(newpri)newpri=SetTaskPri(FindTask(NULL),newpri);
					mainsigs.loop();
					SetTaskPri(FindTask(NULL),newpri);
					return 0;
				}catch(PortX){
					//	If a port already is public, trap the error and try another port name
				}
			}
		}catch(...){
			if(portid>=0){
				info.request("Unable to initialize port");
			}else{
				info.request("Abnormal termination");
			}
		}
	}catch(RDArgsX){
		PrintFault(IoErr(),LCDNAME);
		return(5L);
	}
}

//	Workbench startup

extern "C" void wbparse(struct WBStartup *);

extern "C" void wbmain(struct WBStartup *wb){
	StartupMessage=wb;
	wbparse(wb);
}

