//	Encapsulation of the external port driver

#include "AmigaOS.h"
#pragma header

#include "extdriver.hpp"
#include "lcd.h"

/*
** Imported functions from driver module
*/
//extern "C" STRPTR	lcd_alloc(struct lcdparams *);
//extern "C" void	lcd_free(void);

extern struct lcdparams lcdpar;

ExtDriverC::ExtDriverC(InfoRequesterC &info,STRPTR libname):
	LCDDriverBase(NULL),
	m_name(NULL)
{
	// If the library is specified by the user, try that one, otherwise try the default one.
	if(!libname)libname="lcddriver.library";
	if(LCDDriverBase=(struct LCDDriverBase *)OpenLibrary(libname,37L)){
		
	}
//	if(!(name=lcd_alloc(&lcdpar))){
//		info.request("Could not initialize driver");
//	}
}
ExtDriverC::~ExtDriverC(){
	if(LCDDriverBase){
//		lcd_free();
		CloseLibrary((struct Library *)LCDDriverBase);
	}
}


