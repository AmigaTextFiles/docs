
/* *** global.c *************************************************************
 *
 * XText  --  Global Variable Declarations
 *	 from Book 1 of the Amiga Programmers' Suite by RJ Mical
 *
 * Copyright (C) 1986, 1987, Robert J. Mical
 * All Rights Reserved.
 *
 * Created for Amiga developers.
 * Any or all of this code can be used in any program as long as this
 * entire notice is retained, ok?  Thanks.
 *
 * The Amiga Programmer's Suite Book 1 is copyrighted but freely distributable.
 * All copyright notices and all file headers must be retained intact.
 * The Amiga Programmer's Suite Book 1 may be compiled and assembled, and the 
 * resultant object code may be included in any software product.  However, no 
 * portion of the source listings or documentation of the Amiga Programmer's 
 * Suite Book 1 may be distributed or sold for profit or in a for-profit 
 * product without the written authorization of the author, RJ Mical.
 * 
 * HISTORY       NAME            DESCRIPTION
 * -----------   --------------  --------------------------------------------
 * 27 Oct 86     RJ              Add XText buffer stuff, prepare for release
 * March 86      RJ              Incorporated this code in Sidecar
 * 26 Jan 86     RJ Mical        Created this file (on my birthday!)
 *
 * *********************************************************************** */


#define EGLOBAL_CANCEL		/* This prevents eglobal.c from being included */
#include "xtext.h"



/* === System Global Variables ========================================== */
struct IntuitionBase *IntuitionBase = NULL;
struct GfxBase *GfxBase = NULL;
struct DiskfontBase *DiskfontBase = NULL;

struct TextAttr SafeFont =
		{
		(UBYTE *)"topaz.font",
		TOPAZ_EIGHTY,
		0,
		FS_NORMAL
		};




