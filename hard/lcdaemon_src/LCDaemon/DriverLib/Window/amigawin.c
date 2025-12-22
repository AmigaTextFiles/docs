/****************************************************************************\
**																			**
\****************************************************************************/
#include <clib/all_protos.h>
#include <devices/timer.h>
#include <graphics/gfxbase.h>
#include <graphics/view.h>
#include <intuition/intuition.h>
#pragma header
#include <string.h>
#include "lcd.h"
#define CHARACTERS	40			/* current maximum	*/
#define LINES		10

#define BLOCKWIDTH 2
#define BLOCKHEIGHT 2

/*
** Exported functions to LCDaemon
*/
STRPTR	lcd_alloc(struct lcdparams *);
void	lcd_free(void);
void	lcd_delayfor(ULONG);
void	lcd_putchar(UBYTE,BOOL,ULONG,ULONG);

/*
** Imported from LCDaemon
*/
extern STRPTR startup;
extern struct timerequest *timereq;

extern struct GfxBase *GfxBase;
int shift,cursorx,cursory,oldcursorx,oldcursory;
struct Window *outwin;
char buffer[LINES][CHARACTERS];
void dumpbuffer(void);
BOOL displayon,cursorvisible,cursorblink,cursormove,displayshift,displaylines;
int pixelpen=1,activelcdpen=0,inactivelcdpen=3;
BOOL pixpen=FALSE,alcdpen=FALSE,ialcdpen=FALSE;
struct lcdparams *params;
UWORD cgramaddr=0;
#include "cgram.h"				/*	character generator RAM from LCD module	*/

/****************************************************************************\
**	Allocate everything needed for port access								**
**																			**
**	Return 0 for success.													**
\****************************************************************************/
STRPTR lcd_alloc(struct lcdparams *param){
	STRPTR success="Amiga Window";
	STRPTR wintitle;
	LONG bestpen;
	struct ColorMap *cmap;
	struct EasyStruct es={sizeof(struct EasyStruct),0,"AmigaWin driver failure:",
		"Need Kickstart 3.0 for\npen allocation features.","Sorry"
	};
	params=param;
	wintitle=startup;
	if(!(wintitle&&(strlen(wintitle)>1)))wintitle="LCDaemon AmiWindow © 1997 VOMIT,inc.";
	if(!(outwin=OpenWindowTags(	NULL,WA_Activate,FALSE,WA_DepthGadget,FALSE,
								WA_Title,wintitle,
								WA_DragBar,TRUE,
								WA_GimmeZeroZero,TRUE,
								WA_CloseGadget,TRUE,
								WA_IDCMP,IDCMP_CLOSEWINDOW,
								WA_InnerWidth,(params->width*6+1)*BLOCKWIDTH,
								WA_InnerHeight,(params->height*8+1)*BLOCKHEIGHT,
								TAG_END))) success=FALSE;
	cursorvisible=cursorblink=displayshift=displayon=FALSE;
	displaylines=cursormove=TRUE;
	shift=oldcursorx=oldcursory=cursorx=cursory=0;
/*	if(GfxBase->LibNode.lib_Version<39L){
		EasyRequest(outwin,&es,0,TAG_DONE);
		return(FALSE);
	}
*/
#define THIRTYTWOBIT(x) ((ULONG)(((ULONG)0xffffff)*((ULONG)(x))))
#define RGB(a,b,c) THIRTYTWOBIT(a),THIRTYTWOBIT(b),THIRTYTWOBIT(c)
	if(outwin&&(GfxBase->LibNode.lib_Version>=39L)){
		cmap=outwin->WScreen->ViewPort.ColorMap;
		if((bestpen=ObtainBestPen(cmap,RGB(0,49,17),OBP_Precision,PRECISION_EXACT,TAG_END))>=0){
			pixelpen=bestpen;
			pixpen=TRUE;
		}
		if((bestpen=ObtainBestPen(cmap,RGB(0,204,0),OBP_Precision,PRECISION_EXACT,TAG_END))>=0){
			activelcdpen=bestpen;
			alcdpen=TRUE;
		}
		if((bestpen=ObtainBestPen(cmap,RGB(0,49,17),OBP_Precision,PRECISION_EXACT,TAG_END))>=0){
			inactivelcdpen=bestpen;
			ialcdpen=TRUE;
		}
	}else{
		pixpen=0;
		alcdpen=1;
		ialcdpen=0;
	}
	return(success);
}

/****************************************************************************\
**	Free everything allocated.												**
**																			**
**	lcd_free() is called even when lcd_alloc() failed, to allow for			**
**	freeing the successful allocations in lcd_alloc()						**
\****************************************************************************/
void lcd_free(void){
	struct ColorMap *cmap;
	if(outwin)cmap=outwin->WScreen->ViewPort.ColorMap;
	if(outwin&&(GfxBase->LibNode.lib_Version>=39L)){
		if(pixpen)ReleasePen(cmap,pixelpen);
		if(alcdpen)ReleasePen(cmap,activelcdpen);
		if(ialcdpen)ReleasePen(cmap,inactivelcdpen);
	}
	if(outwin)CloseWindow(outwin);
}

/****************************************************************************\
**	AmigaDOS Delay(), but using microseconds								**
\****************************************************************************/
void lcd_delayfor(ULONG micros){
	timereq->tr_node.io_Command=TR_ADDREQUEST;
	timereq->tr_time.tv_micro=micros%1000000;
	timereq->tr_time.tv_secs=micros/1000000;
	DoIO((struct IORequest *)timereq);	
}

void lcd_docurs(void){
	int xpos,ypos;
	xpos=(6*(oldcursorx+shift)+1)*BLOCKWIDTH;
	ypos=(8*(oldcursory+1))*BLOCKHEIGHT;
	if((oldcursorx!=cursorx)||(oldcursory!=cursory)){
		SetAPen(outwin->RPort,displayon?activelcdpen:inactivelcdpen);
		RectFill(outwin->RPort,xpos,ypos,xpos+5*BLOCKWIDTH-1,ypos+BLOCKHEIGHT-1);
		xpos=(6*(cursorx+shift)+1)*BLOCKWIDTH;
		ypos=(8*(cursory+1))*BLOCKHEIGHT;
		if(displayon){
			SetAPen(outwin->RPort,pixelpen);
			RectFill(outwin->RPort,xpos,ypos,xpos+5*BLOCKWIDTH-1,ypos+BLOCKHEIGHT-1);
		}
		oldcursorx=cursorx;
		oldcursory=cursory;
	}
}

void lcd_parsechar(UBYTE code,int x,int y){
	register int i,j;
	register UBYTE c;
	int xpos,ypos;
	UBYTE *data;
	if(!displayon) return;
	data=&(CGRAM[code*7]);
	c=*data++;
	xpos=(6*(x+shift)+1)*BLOCKWIDTH;
	ypos=(8*y+1)*BLOCKHEIGHT;
	SetAPen(outwin->RPort,displayon?activelcdpen:inactivelcdpen);
	RectFill(outwin->RPort,xpos,ypos,xpos+6*BLOCKWIDTH-1,ypos+8*BLOCKHEIGHT-1);
	SetAPen(outwin->RPort,pixelpen);
	ypos=BLOCKHEIGHT*(8*y+1);
	for(i=0;i<7;i++,ypos+=BLOCKHEIGHT){
		xpos=BLOCKWIDTH*(6*x+1);
		for(j=0;j<5;j++,xpos+=BLOCKWIDTH){
			if(c&0x10){
				RectFill(outwin->RPort,xpos,ypos,xpos+BLOCKWIDTH-1,ypos+BLOCKHEIGHT-1);
			}
			c<<=1;
		}
		c=*data++;
	}
}

/****************************************************************************\
**	Send code to LCD, with pause for LCD to comply							**
**																			**
**	Hardware:																**
**																			**
**	Centronics			LCD													**
**	D0...D7		->		d0...d7												**
**	BUSY		->		Enable												**
**	POUT		->		Register Select										**
**																			**
\****************************************************************************/
void lcd_putchar(UBYTE code,BOOL data,ULONG micros,ULONG ctrlmask){
	if(outwin && outwin->UserPort){
		struct IntuiMessage *msg;
		while(msg=(struct IntuiMessage *)GetMsg(outwin->UserPort)){
			if(msg->Class==IDCMP_CLOSEWINDOW){
				SetSignal(SIGBREAKF_CTRL_C,SIGBREAKF_CTRL_C);
			}
			ReplyMsg((struct Message *)msg);
		}
	}
	if(data){
		if(cgramaddr==(UWORD)~0){
			Move(outwin->RPort,cursorx*8,10+cursory*10);
			buffer[cursory][cursorx]=code;
			lcd_parsechar(code,cursorx,cursory);
			cursorx++;
			if(cursorx>=params->virtualwidth){
				cursorx=0;
				cursory++;
				if(cursory>=params->height) cursory--;
			}
		}else{
			register int i,j;
			if(cgramaddr<(8*8)&&(cgramaddr%8)!=7){
				CGRAM[(cgramaddr%8)+((cgramaddr/8)*7)]=code;
			}
			for(i=0;i<params->width;i++){
				for(j=0;j<params->height;j++){
					if(buffer[j][i]==(cgramaddr/8)){
						lcd_parsechar(buffer[j][i],i,j);
					}
				}
			}
			cgramaddr++;
		}
	} else {
		if(code&0x80){
			cursorx=(code&0x7f)%0x40;
			cursory=(code&0x7f)/0x40;
			if(!(ctrlmask&1))cursory+=2;
			cgramaddr=(UWORD)~0;
		} else if(code&0x40){
			cgramaddr=(code&0x3f);
		} else if(code&0x20){
			
		} else if(code&0x10){
			
		} else if(code&0x08){
			if(!displayon&&(code&0x04)) SetRast(outwin->RPort,activelcdpen);
			displayon=code&0x04;
			if(!displayon) SetRast(outwin->RPort,inactivelcdpen);
			cursorvisible=code&0x02;
			cursorblink=code&0x01;
		} else if(code&0x04){
			cursormove=code&0x02;
			displayshift=code&0x01;
		} else if(code&0x02){
			shift=cursorx=0;
			cursory=ctrlmask&1?0:2;
		} else if(code==0x01){
			cgramaddr=(UWORD)~0;
			for(cursory=ctrlmask&1?0:2;cursory<params->height;cursory++){
				for(cursorx=0;cursorx<params->virtualwidth;cursorx++){
					buffer[cursory][cursorx]=0x10;
				}
			}
			if(displayon){
				SetRast(outwin->RPort,displayon?activelcdpen:inactivelcdpen);
			}
			cursorx=shift=0;
			cursory=ctrlmask&1?0:2
		}
	}
	if(displayon)lcd_docurs();
	lcd_delayfor(micros);		/*	Wait while LCD processes...		*/
}
