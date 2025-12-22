
/* *** alerts.c *************************************************************
 *
 * Alert and Abort AutoRequest Routines
 *     from Book 1 of the Amiga Programmers' Suite by RJ Mical
 *
 * Copyright (C) 1986, 1987, Robert J. Mical
 * All Rights Reserved.
 *
 * Created for Amiga developers.
 * Any or all of this code can be used in any program as long as this
 * entire copyright notice is retained, ok?
 *
 * The Amiga Programmer's Suite Book 1 is copyrighted but freely distributable.
 * All copyright notices and all file headers must be retained intact.
 * The Amiga Programmer's Suite Book 1 may be compiled and assembled, and the 
 * resultant object code may be included in any software product.  However, no 
 * portion of the source listings or documentation of the Amiga Programmer's 
 * Suite Book 1 may be distributed or sold for profit or in a for-profit 
 * product without the written authorization of the author, RJ Mical.
 * 
 * HISTORY      NAME            DESCRIPTION
 * -----------  --------------  --------------------------------------------
 * 27 Sep 87    RJ              Removed reference to alerts.h, brought 
 *                              declarations into this file
 * 4 Feb 87     RJ              Real release
 * 11 Jul 86    RJ >:-{)*       Prepare (clean house) for release
 * 1 Feb 86     =RJ Mical=      Created this file with fond memories
 *
 * *********************************************************************** */


#include <prosuite/prosuite.h>


#define ALERT_TEXT_TOP   6
#define ALERT_TEXT_LEFT  6


extern struct TextAttr SafeFont;


UBYTE *AlertStrings[] =
	{
	/*       "Longest allowed string -----------|" */
	(UBYTE *)"Really broken.  Stop all and reboot",
	(UBYTE *)"Out of memory!  Sheesh.",
	(UBYTE *)"Invalid Disk or Drawer Selection",
	};


struct IntuiText AlertText =
	{
	AUTOFRONTPEN, AUTOBACKPEN, AUTODRAWMODE,
	AUTOLEFTEDGE + ALERT_TEXT_LEFT, AUTOTOPEDGE + ALERT_TEXT_TOP,
	&SafeFont,
	NULL, NULL,
	};


struct IntuiText AlertOKText =
	{
	AUTOFRONTPEN, AUTOBACKPEN, AUTODRAWMODE,
	AUTOLEFTEDGE, AUTOTOPEDGE,
	&SafeFont,
	(UBYTE *)"OK", 
	NULL,
	};



VOID AlertGrunt(text, window)
UBYTE *text;
struct Window *window;
{
	AlertText.IText = text;
	AutoRequest(window, &AlertText, NULL, 
			&AlertOKText, 0, 0, 320, 48 + ALERT_TEXT_TOP);
}
 


VOID Alert(abortNumber, window)
USHORT abortNumber;
struct Window *window;
{
	AlertGrunt(AlertStrings[abortNumber], window);
}
 


VOID Abort(abortNumber, window)
USHORT abortNumber;
struct Window *window;
{
	Alert(abortNumber, window);
/*???	FOREVER Alert(ALERT_ABORT, window);*/
	FOREVER Alert(0, window);
}
 
