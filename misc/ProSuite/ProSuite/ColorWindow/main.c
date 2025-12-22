
/* *** main.c ***************************************************************
 *
 * ColorWindow Routine  --  Main (Demonstration)
 *     from Book 1 of the Amiga Programmers' Suite by RJ Mical
 *
 * Copyright (C) 1986, 1987, Robert J. Mical
 * All Rights Reserved.
 *
 * Created for Amiga developers.
 * Any or all of this code can be used in any program as long as this
 * entire copyright notice is retained, ok?  Thanks.
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
 * 3 Jan 87     RJ >:-{)*       Clean-up for release      
 * 27 Feb 86    =RJ Mical=      Modified these routines for Zaphod
 * January 86   =RJ=            Modified the originals for Mandelbrot
 * Late 85      =RJ=            Created the color window for Graphicraft
 *
 * *********************************************************************** */



#include "color.h"

UBYTE *OpenLibrary();


struct GfxBase *GfxBase;
struct IntuitionBase *IntuitionBase;


VOID main()
{
	IntuitionBase = (struct IntuitionBase *)
			OpenLibrary("intuition.library", 0);
	GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0);

	if (IntuitionBase && GfxBase)
		DoColorWindow(NULL, 20, 20, 1, TRUE);

	if (IntuitionBase) CloseLibrary(IntuitionBase);
	if (GfxBase) CloseLibrary(GfxBase);
}

