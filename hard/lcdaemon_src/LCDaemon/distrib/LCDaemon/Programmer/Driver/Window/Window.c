/*
**	Amiga window driver library for LCDaemon V2.2+
*/

#include </Amiga.h>
#pragma header

#include "//lcd.h"	//	for struct lcdparams *

#include "RegisterA4.h"
#include <resources/misc.h>	/*	Parallel port		*/
#include <libraries/expansion.h>
#include <graphics/gfxbase.h>
#include "mfc3bits.h"		/*	Multifacecard 3	*/
#include "pitbits.h"		/*	Multifacecard 2	*/
#include "libraries/LCDDriverBase.h"
#include "libraries/LCDDriverMethod.h"
#include "hardware/cia.h"
#include "cgram.h"
#include <string.h>

extern struct CIA ciaa,ciab;
struct IntuitionBase	*IntuitionBase	=	NULL;
struct GfxBase *GfxBase	=	NULL;

#include "library_version.h"

char versiontag[]	=	"\0" VERSTAG;
char Copyright[]		=	"© 1997-98 Hendrik De Vloed, VOMIT, inc.";

#define THIRTYTWOBIT(x) ((ULONG)(((ULONG)0xffffff)*((ULONG)(x))))
#define RGB(a,b,c) THIRTYTWOBIT(a),THIRTYTWOBIT(b),THIRTYTWOBIT(c)

#define	CHARACTERS	40			/* current maximum	*/
#define	LINES		10
#define BLOCKWIDTH 2
#define BLOCKHEIGHT 2

#define	ALLOCATED_ACTIVEPEN	1
#define	ALLOCATED_PIXELPEN	2
#define	ALLOCATED_INACTIVEPEN	4

struct PrivateData {
	struct Library *IntuitionBase;
	struct Library *GfxBase;
	struct Window *m_Window;
	struct lcdparams	*m_lcdpar;
	STRPTR	m_startup;
	struct timerequest	*m_timereq;
	ULONG m_allocated;
	LONG m_activelcdpen,m_inactivelcdpen,m_pixelpen;
	LONG m_shift,m_cursorx,m_cursory,m_oldcursorx,m_oldcursory;
	BOOL m_displayon,m_cursorvisible,m_cursorblink,m_cursormove,m_displayshift,m_displaylines;
	UWORD m_cgramaddr;
	UBYTE m_buffer[LINES][CHARACTERS];
};

STRPTR AllocLCD(
	register __a0 struct lcdparams *lcdpar_a0,
	register __a1 STRPTR startup_a1,
	register __a2 struct timerequest *timereq_a2,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct lcdparams *lcdpar=lcdpar_a0;
	STRPTR startup=startup_a1;
	struct timerequest *timereq=timereq_a2;
	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;
	struct PrivateData *pPrivate;

	STRPTR wintitle;
	LONG bestpen;
	struct ColorMap *cmap;

	StoreA4();
	GetBaseReg();
	InitModules();

	if((lcdpar->width>=CHARACTERS) || (lcdpar->height>=LINES))return NULL;

	//	Allocate a private handle
	if(pPrivate=(struct PrivateData *)AllocVec(sizeof(struct PrivateData),MEMF_CLEAR|MEMF_PUBLIC)){
		pPrivate->m_startup=startup;
		pPrivate->m_timereq=timereq;
		pPrivate->m_lcdpar=lcdpar;

		if(IntuitionBase=(struct IntuitionBase *)(pPrivate->IntuitionBase=OpenLibrary("intuition.library",37L))){
			if(GfxBase=(struct GfxBase *)(pPrivate->GfxBase=OpenLibrary("graphics.library",37L))){
				wintitle="LCDaemon @ 1997-98 VOMIT, inc.";
				if(startup && strlen(startup))wintitle=startup;
				if(pPrivate->m_Window=OpenWindowTags(NULL,
					WA_Activate,FALSE,
					WA_DepthGadget,TRUE,
					WA_Title,wintitle,
					WA_DragBar,TRUE,
					WA_GimmeZeroZero,TRUE,
					WA_CloseGadget,TRUE,
					WA_IDCMP,IDCMP_CLOSEWINDOW,
					WA_InnerWidth,(lcdpar->width*6+1)*BLOCKWIDTH,
					WA_InnerHeight,(lcdpar->height*8+1)*BLOCKHEIGHT,
					TAG_END)
				){
					if(GfxBase->LibNode.lib_Version>=39L){
						cmap=pPrivate->m_Window->WScreen->ViewPort.ColorMap;
						if((bestpen=ObtainBestPen(cmap,RGB(0,49,17),OBP_Precision,PRECISION_EXACT,TAG_END))>=0){
							pPrivate->m_pixelpen=bestpen;
							pPrivate->m_allocated|=ALLOCATED_PIXELPEN;
						}
						if((bestpen=ObtainBestPen(cmap,RGB(0,204,0),OBP_Precision,PRECISION_EXACT,TAG_END))>=0){
							pPrivate->m_activelcdpen=bestpen;
							pPrivate->m_allocated|=ALLOCATED_ACTIVEPEN;
						}
						if((bestpen=ObtainBestPen(cmap,RGB(0,49,17),OBP_Precision,PRECISION_EXACT,TAG_END))>=0){
							pPrivate->m_inactivelcdpen=bestpen;
							pPrivate->m_allocated|=ALLOCATED_INACTIVEPEN;
						}
					}else{
						pPrivate->m_pixelpen=0;
						pPrivate->m_activelcdpen=1;
						pPrivate->m_inactivelcdpen=0;
					}
					goto success;
				}
				CloseLibrary(pPrivate->GfxBase);
			}
			CloseLibrary(pPrivate->IntuitionBase);
		}
		FreeVec(pPrivate);
	}
	pPrivate=NULL;
success:
	RestoreA4();
	return((APTR)pPrivate);
}

VOID FreeLCD(
	register __a0 APTR hndl_a0,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;

	struct ColorMap *cmap;

	StoreA4();
	GetBaseReg();

	if(hndl_a0){
		if(Private.m_Window)cmap=Private.m_Window->WScreen->ViewPort.ColorMap;
		if(Private.m_allocated&ALLOCATED_PIXELPEN)ReleasePen(cmap,Private.m_pixelpen);
		if(Private.m_allocated&ALLOCATED_ACTIVEPEN)ReleasePen(cmap,Private.m_activelcdpen);
		if(Private.m_allocated&ALLOCATED_INACTIVEPEN)ReleasePen(cmap,Private.m_inactivelcdpen);
		if(Private.m_Window)CloseWindow(Private.m_Window);
		if(Private.GfxBase)CloseLibrary(Private.GfxBase);
		if(Private.IntuitionBase)CloseLibrary(Private.IntuitionBase);
		FreeVec(&Private)
	}
	CleanupModules();
	RestoreA4();
}

ULONG LCDPreMessage(
	register __a0 APTR hndl_a0,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
/*	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;*/
	return 0;
}

ULONG LCDPostMessage(
	register __a0 APTR hndl_a0,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
/*	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;*/
	return 0;
}

ULONG LCDDelayFor(
	register __a0 APTR hndl_a0,
	register __d0 ULONG micros,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
/*	No delays are necessary in the Amiga window version

	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;

	StoreA4();
	GetBaseReg();

	Private.m_timereq->tr_node.io_Command=TR_ADDREQUEST;
	Private.m_timereq->tr_time.tv_micro=micros%1000000;
	Private.m_timereq->tr_time.tv_secs=micros/1000000;
	DoIO((struct IORequest *)Private.m_timereq);

	RestoreA4();
*/
	return 0;
}

STRPTR LCDDriverName(
	register __a0 APTR hndl_a0,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;

	return "Amiga window";
}

void lcd_docurs(
	register __a0	struct PrivateData *pPrivate
){
	int xpos,ypos;
	xpos=(6*(pPrivate->m_oldcursorx+pPrivate->m_shift)+1)*BLOCKWIDTH;
	ypos=(8*(pPrivate->m_oldcursory+1))*BLOCKHEIGHT;
	if((pPrivate->m_oldcursorx!=pPrivate->m_cursorx)||(pPrivate->m_oldcursory!=pPrivate->m_cursory)){
		SetAPen(pPrivate->m_Window->RPort,pPrivate->m_displayon?pPrivate->m_activelcdpen:pPrivate->m_inactivelcdpen);
		RectFill(pPrivate->m_Window->RPort,xpos,ypos,xpos+5*BLOCKWIDTH-1,ypos+BLOCKHEIGHT-1);
		xpos=(6*(pPrivate->m_cursorx+pPrivate->m_shift)+1)*BLOCKWIDTH;
		ypos=(8*(pPrivate->m_cursory+1))*BLOCKHEIGHT;
		if(pPrivate->m_displayon){
			SetAPen(pPrivate->m_Window->RPort,pPrivate->m_pixelpen);
			RectFill(pPrivate->m_Window->RPort,xpos,ypos,xpos+5*BLOCKWIDTH-1,ypos+BLOCKHEIGHT-1);
		}
		pPrivate->m_oldcursorx=pPrivate->m_cursorx;
		pPrivate->m_oldcursory=pPrivate->m_cursory;
	}
}

void lcd_parsechar(
	register __a0	struct PrivateData *pPrivate,
	register __d0 UBYTE code,
	register __d1 int x,
	register __d2 int y
){
	int i,j;
	UBYTE c;
	int xpos,ypos;
	UBYTE *data;
	if(!pPrivate->m_displayon) return;
	data=&(CGRAM[code*7]);
	c=*data++;
	xpos=(6*(x+pPrivate->m_shift)+1)*BLOCKWIDTH;
	ypos=(8*y+1)*BLOCKHEIGHT;
	SetAPen(pPrivate->m_Window->RPort,pPrivate->m_displayon?pPrivate->m_activelcdpen:pPrivate->m_inactivelcdpen);
	RectFill(pPrivate->m_Window->RPort,xpos,ypos,xpos+6*BLOCKWIDTH-1,ypos+8*BLOCKHEIGHT-1);
	SetAPen(pPrivate->m_Window->RPort,pPrivate->m_pixelpen);
	ypos=BLOCKHEIGHT*(8*y+1);
	for(i=0;i<7;i++,ypos+=BLOCKHEIGHT){
		xpos=BLOCKWIDTH*(6*x+1);
		for(j=0;j<5;j++,xpos+=BLOCKWIDTH){
			if(c&0x10){
				RectFill(pPrivate->m_Window->RPort,xpos,ypos,xpos+BLOCKWIDTH-1,ypos+BLOCKHEIGHT-1);
			}
			c<<=1;
		}
		c=*data++;
	}
}

ULONG LCDPutChar(
	register __a0 APTR hndl_a0,
	register __d0 UBYTE code_d0,
	register __d1 BOOL data_d1,
	register __d2 ULONG micros_d2,
	register __d3 ULONG ctrlmask_d3,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	UBYTE code=code_d0;
	BOOL data=data_d1;
	ULONG micros=micros_d2;
	ULONG ctrlmask=ctrlmask_d3;
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;

	struct IntuiMessage *msg;
	UWORD i,j;

	StoreA4();
	GetBaseReg();

	if(&Private && Private.m_Window->UserPort){
		while(msg=(struct IntuiMessage *)GetMsg(Private.m_Window->UserPort)){
			if(msg->Class==IDCMP_CLOSEWINDOW){
				SetSignal(SIGBREAKF_CTRL_C,SIGBREAKF_CTRL_C);
			}
			ReplyMsg((struct Message *)msg);
		}
	}
	if(data){
		if(Private.m_cgramaddr==(UWORD)~0){
			Move(Private.m_Window->RPort,Private.m_cursorx*8,10+Private.m_cursory*10);
			Private.m_buffer[Private.m_cursory][Private.m_cursorx]=code;
			lcd_parsechar(&Private,code,Private.m_cursorx,Private.m_cursory);
			Private.m_cursorx++;
			if(Private.m_cursorx>=Private.m_lcdpar->virtualwidth){
				Private.m_cursorx=0;
				Private.m_cursory++;
				if(Private.m_cursory>=Private.m_lcdpar->height) Private.m_cursory--;
			}
		}else{
			if(Private.m_cgramaddr<(8*8)&&(Private.m_cgramaddr%8)!=7){
				CGRAM[(Private.m_cgramaddr%8)+((Private.m_cgramaddr/8)*7)]=code;
			}
			for(i=0;i<Private.m_lcdpar->width;i++){
				for(j=0;j<Private.m_lcdpar->height;j++){
					if(Private.m_buffer[j][i]==(Private.m_cgramaddr/8)){
						lcd_parsechar(&Private,Private.m_buffer[j][i],i,j);
					}
				}
			}
			Private.m_cgramaddr++;
		}
	} else {
		if(code&0x80){
			Private.m_cursorx=(code&0x7f)%0x40;
			Private.m_cursory=(code&0x7f)/0x40;
			if(!(ctrlmask&1))Private.m_cursory+=2;
			Private.m_cgramaddr=(UWORD)~0;
		} else if(code&0x40){
			Private.m_cgramaddr=(code&0x3f);
		} else if(code&0x20){
			
		} else if(code&0x10){
			
		} else if(code&0x08){
			if(!Private.m_displayon&&(code&0x04)) SetRast(Private.m_Window->RPort,Private.m_activelcdpen);
			Private.m_displayon=code&0x04;
			if(!Private.m_displayon) SetRast(Private.m_Window->RPort,Private.m_inactivelcdpen);
			Private.m_cursorvisible=code&0x02;
			Private.m_cursorblink=code&0x01;
		} else if(code&0x04){
			Private.m_cursormove=code&0x02;
			Private.m_displayshift=code&0x01;
		} else if(code&0x02){
			Private.m_shift=Private.m_cursorx=0;
			Private.m_cursory=ctrlmask&1?0:2;
		} else if(code==0x01){
			Private.m_cgramaddr=(UWORD)~0;
			for(Private.m_cursory=ctrlmask&1?0:2;Private.m_cursory<Private.m_lcdpar->height;Private.m_cursory++){
				for(Private.m_cursorx=0;Private.m_cursorx<Private.m_lcdpar->virtualwidth;Private.m_cursorx++){
					Private.m_buffer[Private.m_cursory][Private.m_cursorx]=0x10;
				}
			}
			if(Private.m_displayon){
				SetRast(Private.m_Window->RPort,Private.m_displayon?Private.m_activelcdpen:Private.m_inactivelcdpen);
			}
			Private.m_cursorx=Private.m_shift=0;
			Private.m_cursory=ctrlmask&1?0:2
		}
	}
	if(Private.m_displayon)lcd_docurs(&Private);
/*	lcd_delayfor(micros);*/		/*	Wait while LCD processes...		*/

	RestoreA4();

	return 0;	/*	Retval unused for now	*/
}

VOID LCDVisual(
	register __a0 APTR hndl_a0,
	register __d0 ULONG backlight_d0,
	register __d1 ULONG contrast_d1,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
}

ULONG LCDMethod(
	register __a0 APTR hndl_a0,
	register __d0 ULONG method_d0,
	register __a1 APTR param_a1,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	APTR	hndl=hndl_a0;
	ULONG	method=method_d0;
	APTR	param=param_a1;

	switch(method){
	case	LCDOM_LIBVERSION:
		*(ULONG *)param=22L;	/*	This is the LCDaemon compliance level, not the (dollar)VER value	*/
		return	LCDOMERR_OK;
		break;
	case	LCDOM_GETUSERPORT:
		(*(struct MsgPort **)param)=Private.m_Window->UserPort;
		return	LCDOMERR_OK;
		break;
	case	LCDOM_USERMESSAGE:
		switch(((struct IntuiMessage *)param)->Class){
		case	IDCMP_CLOSEWINDOW:
			return LCDOMERR_QUIT;
			break;
		default:
			return	LCDOMERR_OK;
		}
		break;
	default:
		return	LCDOMERR_UNKNOWN;
	}

}

