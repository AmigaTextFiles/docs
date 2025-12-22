#ifndef XTEXT_H
#define XTEXT_H


/* *** xtext.h **************************************************************
 *
 * XText Routines
 *	 from Book 1 of the Amiga Programmers' Suite by RJ Mical
 *
 * Copyright (C) 1986, 1987, Robert J. Mical
 * All Rights Reserved.
 *
 * Created for Amiga developers.
 * Any or all of this code can be used in any program as long as this
 * entire notice is retained, ok?  Thanks.
 *
 * HISTORY       NAME            DESCRIPTION
 * -----------   --------------  --------------------------------------------
 * 27 Oct 86     RJ              Add XText buffer stuff, prepare for release
 * March 86      RJ              Incorporated this code in Sidecar
 * 26 Jan 86     RJ Mical        Created this file (on my birthday!)
 *
 * *********************************************************************** */


#include <exec/types.h>
#include <exec/memory.h>

#include <intuition/intuition.h>




/* === System Macros ==================================================== */
#define SetFlag(v,f)		((v)|=(f))
#define ClearFlag(v,f)		((v)&=~(f))
#define ToggleFlag(v,f) 	((v)^=(f))
#define FlagIsSet(v,f)		((BOOL)(((v)&(f))!=0))
#define FlagIsClear(v,f)	((BOOL)(((v)&(f))==0))



/* === XText Support Structure =========================================== */
struct XTextSupport
	{
	BYTE FrontPen, BackPen;
	BYTE DrawMode;

	BYTE MaxTextWidth;

	SHORT CharHeight;
	SHORT Flags;

	UBYTE *NormalTextPlane;
	UBYTE *InverseTextPlane;
	UBYTE *AllClearPlane;
	UBYTE *AllSetPlane;

	struct Remember *XTextKey;

	struct RastPort *OutputRPort;

	SHORT FontSelect;		/* Definitions for FontSelect are below */
	UBYTE *FontData[8];

	struct BitMap TextBitMap;
	};


/* === FontSelect Definitions === */
/* Though these are given names, these are basically just indices into the
 * FontData array.
 */
#define NORMAL_FONT					0		/* The default, don'cha know */
#define BOLD_FONT					1
#define ULINE_FONT					2
#define ULINE_BOLD_FONT				3
#define ITALIC_FONT					4
#define ITALIC_BOLD_FONT			5
#define ITALIC_ULINE_FONT			6
#define ITALIC_ULINE_BOLD_FONT		7

/* === XTextSupport Flags Definitions === */
#define SLIM_XTEXT	0x0001



/* === XText Miscellaneous Definitions =================================== */
#define XTEXT_CHARWIDTH				8		/* This is sacrosanct */

/* The ITALIC_LEFT_EDGE is used to determine which slice of the italic
 * imagery is used for the font imagery.
 * The value of this constant is used as the starting left column of
 * font imagery after italics have been applied to the font.
 * If you haven't the foggiest notion what this means, leave this
 * constant alone and you'll be OK.
 */
#define ITALIC_LEFT_EDGE			1



/* === Function Definitions ============================================== */
UBYTE *AllocMem();
UBYTE *AllocRemember();

struct XTextSupport *MakeXTextSupport();

struct TextFont *OpenDiskFont();
struct TextFont *OpenFont();
UBYTE *OpenLibrary();
struct Screen *OpenScreen();
struct TmpRas *InitTmpRas();
struct Window *OpenWindow();



/* === And finally, eglobal inclusion ==================================== */
#ifndef EGLOBAL_CANCEL
#include "eglobal.c"
#endif


#endif /* of XTEXT_H */


