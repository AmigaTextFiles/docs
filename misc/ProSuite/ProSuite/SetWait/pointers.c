
/* *** pointers.c ***********************************************************
 *
 * Intuition Wait Pointers Routines
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
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 3 May 86     =RJ Mical=      Fix prop gadget for both 1.1 and 1.2
 * 1 Feb 86     =RJ Mical=      Created this file.
 *
 * *********************************************************************** */


#include <prosuite/prosuite.h>
#include <prosuite/pointers.h>



VOID SetWaitPointer(pointnumber, window)
SHORT pointnumber;
struct Window *window;
{
	switch (pointnumber)
		{
		case GCRAFT_POINTER:
			SetPointer(window, &GCraftWaitPointer[0], GCRAFTPOINT_HEIGHT,
					16, GCRAFTPOINT_XOFF, GCRAFTPOINT_YOFF);
			break;
		case WBENCH_POINTER:
			SetPointer(window, &WBenchWaitPointer[0], WBENCHPOINT_HEIGHT,
					16, WBENCHPOINT_XOFF, WBENCHPOINT_YOFF);
			break;
		case ELECARTS_POINTER:
		default:	/* This one is the default because it's my favorite */
				SetPointer(window, &ElecArtsWaitPointer[0], ELECARTSPOINT_HEIGHT,
					16, ELECARTSPOINT_XOFF, ELECARTSPOINT_YOFF);
			break;
		}
}

