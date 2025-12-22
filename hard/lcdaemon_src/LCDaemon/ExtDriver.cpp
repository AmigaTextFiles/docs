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

//	Encapsulation of the external port driver

#include "AmigaOS.h"
#pragma header

#include "extdriver.hpp"
#include "libraries/LCDDriverBase.h"
#include "libraries/LCDDriverMethod.h"
#include "clib/LCDDriver_protos.h"
#include "pragma/LCDDriver_lib.h"
#include "Classes/Exec/Ports.h"
#include "lcd.h"

/*
** Imported functions from driver module
*/
extern "C" STRPTR	lcd_alloc(struct lcdparams *);
extern "C" void	lcd_free(void);
extern STRPTR startup;
extern struct timerequest *timereq;

struct LCDDriverBase *LCDDriverBase;

extern struct lcdparams lcdpar;

ExtDriverC::ExtDriverC(InfoRequesterC &info,STRPTR libname){
	STRPTR	initerror="Could not initialize driver";
	name=NULL;hndl=NULL;userport=NULL;
	LCDDriverBase=(struct LCDDriverBase *)NULL;
	if(!libname)libname="lcdguppy.library";
	if(LCDDriverBase=(struct LCDDriverBase *)OpenLibrary(libname,37L)){
		hndl=AllocLCD(&lcdpar,startup,timereq);
		if(hndl){
			name=LCDDriverName(hndl);
			if(name){
				ULONG version=22L;
				ULONG versionerr=LCDMethod(hndl,LCDOM_LIBVERSION,&version);
				if((versionerr==LCDOMERR_OK) && (version<22)){
					initerror="Driver library version is obsolete";
					name=NULL;
				}else{
					struct MsgPort *msgport;
					if(LCDOMERR_OK==LCDMethod(hndl,LCDOM_GETUSERPORT,&msgport)){
						try{
							if(msgport){
								userport=new ExtSignalC(msgport);
							}
						}catch(...){}
					}
				}
			}
		}
	}
	if(!name){
		info.request(initerror);
	}
}
ExtDriverC::~ExtDriverC(){
	if(userport)delete userport;
	if(LCDDriverBase){
		if(hndl)FreeLCD(hndl);
		CloseLibrary((struct Library *)LCDDriverBase);
	}
}

void	ExtDriverC::lcd_pre_message(void){
	LCDPreMessage(hndl);
}
void	ExtDriverC::lcd_post_message(void){
	LCDPostMessage(hndl);
}
void ExtDriverC::lcd_putchar(UBYTE code,BOOL data,ULONG micros,ULONG ctrlmask){
	LCDPutChar(hndl,code,data,micros,ctrlmask);
}
void ExtDriverC::lcd_delayfor(ULONG micros){
	LCDDelayFor(hndl,micros);
}
void ExtDriverC::lcd_visual(ULONG backlight,ULONG contrast){
	LCDVisual(hndl,backlight,contrast);
}
ULONG ExtDriverC::lcd_usermessage(MessageC &msg){
	return LCDMethod(hndl,LCDOM_USERMESSAGE,&msg);
}


STRPTR ExtDriverC::name;
APTR ExtDriverC::hndl;
ExtSignalC *ExtDriverC::userport;
