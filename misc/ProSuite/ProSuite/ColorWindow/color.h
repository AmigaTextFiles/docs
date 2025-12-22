
/* *** color.h **************************************************************
 *
 * ColorWindow Routine  --  Include File
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
 * 20 Oct 87    - RJ            Make the window draggable
 * 3 Jan 87     RJ >:-{)*       Clean-up for release      
 * 27 Feb 86    =RJ Mical=      Modified these routines for Zaphod
 * January 86   =RJ=            Modified the originals for Mandelbrot
 * Late 85      =RJ=            Created the color window for Graphicraft
 *
 * *********************************************************************** */



#include <prosuite/prosuite.h>



/* === The definitions for ColorWindow =================================*/
#define COLOR_LEFT		0
#define COLOR_TOP		9

#define COLOR_KNOB_BODY 	0x1000

/* Extra width to make room for numeric readout */
#define NEW_EXTRALEFT		24

#define COLORWINDOW_WIDTH	(208 + NEW_EXTRALEFT + COLOR_LEFT)
#define COLORWINDOW_HEIGHT	(91 + COLOR_TOP)

#define CHARACTER_WIDTH 	8
#define CHARACTER_HEIGHT	8

#define COLOR_BOX_LEFT		(COLOR_LEFT + 7)
#define COLOR_BOX_TOP		(COLOR_TOP + 6)
#define COLOR_BOX_RIGHT 	(COLOR_BOX_LEFT + 15)
#define COLOR_BOX_BOTTOM	(COLOR_BOX_TOP + 29)
#define COLOR_COLOR_TOP 	(COLOR_TOP + 45)
#define COLOR_PROP_LEFT 	(COLOR_LEFT + 41)
#define COLOR_PROP_TOP		(COLOR_TOP + 4)
#define COLOR_PROP_WIDTH	165
#define COLOR_PROP_HEIGHT	10
#define COLOR_CLUSTER_LEFT	(COLOR_LEFT + 144)
#define COLOR_CLUSTER_TOP	(COLOR_TOP + 41)
#define COLOR_CLUSTER_WIDTH	(CHARACTER_WIDTH * 6 + 10 + NEW_EXTRALEFT)
#define COLOR_CLUSTER_HEIGHT	9
#define COLOR_HSL_TOP		COLOR_PROP_TOP
#define COLOR_HSL_LEFT		(COLOR_PROP_LEFT - 14)

#define COLOR_VALUE_X		(COLOR_PROP_LEFT + COLOR_PROP_WIDTH + 4)
#define COLOR_VALUE_REDY	(COLOR_PROP_TOP + 1 + 6)
#define COLOR_VALUE_GREENY	(COLOR_VALUE_REDY + COLOR_PROP_HEIGHT + 1)
#define COLOR_VALUE_BLUEY	(COLOR_VALUE_GREENY + COLOR_PROP_HEIGHT + 1)

/* GREEN and RED are out of order to facilitate the color cycle window sharing
 * these gadgets with the color palette window (color cycle uses the gadgets
 * only down to the COLOR_GREEN gadget)
 * (And that's why, in case you have always been wondering.  Now the
 * next mystery is:  why didn't I explain this before?)
 */
#define COLOR_COPY		0
#define COLOR_RANGE		1
#define COLOR_OK		2
#define COLOR_CANCEL		3
#define COLOR_GREEN		4
#define COLOR_RED		5
#define COLOR_BLUE		6
#define COLOR_HSL_RGB		7
#define COLOR_GADGETS_COUNT	8

#define RGBHSL_SIZE	29		/* Number of words per image */


