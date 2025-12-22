
/* *** main.c ***************************************************************
 *
 * XText  --  Example Program
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


#include "xtext.h"

extern struct Window *OpenWindow();
extern struct XTextSupport *MakeXTextSupport();
extern UBYTE *MakeXTextFont();



/* Define XTEXTING if you want to see XText(), comment it out if you want 
 * to see normal Amiga Text() processing.
 */
#define XTEXTING

/* If you have asked to see XText() (by defined XTEXTING above), then 
 * define SHOW_SLIM_XTEXTING to see the slower, slimmer version of XText().  
 * Comment out this definition if you want to see the faster, fatter XText().
 */
/* #define SHOW_SLIM_XTEXTING */

/* If you have asked to see XText() (by defined XTEXTING above), then 
 * define TOPAZ11_XTEXTING to see the Topaz-11 disk-based font used.  
 * Comment out this definition if you want to see normal Topaz-8 XText.
 */
/* #define TOPAZ11_XTEXTING */




struct NewWindow NewXTextWindow =
	{
	0, 0,				/* LeftEdge, TopEdge */
	640, 200, 				/* Width, Height */
	-1, -1,				/* Detail/BlockPens */
	CLOSEWINDOW,		/* IDCMP Flags */
	WINDOWDEPTH | WINDOWCLOSE | SMART_REFRESH | ACTIVATE | BORDERLESS
			| NOCAREREFRESH,
							/* Window Specification Flags */
	NULL,					/* FirstGadget */
	NULL,					/* Checkmark */
	(UBYTE *)"XText Window",  /* WindowTitle */
	NULL,					/* Screen */
	NULL,					/* SuperBitMap */
	96, 30,				/* MinWidth, MinHeight */
	640, 200,			/* MaxWidth, MaxHeight */
	WBENCHSCREEN,
	};


UBYTE buffer[23][80];


struct TextAttr DiskFont =
    {
    (UBYTE *)"topaz.font",
    11,
    FS_NORMAL,		/* equal 0 */
    FPB_DISKFONT,
    };


VOID myAddFont();
VOID infoLine();
VOID advancePens();



VOID main()
{
	struct Window *window;
	struct XTextSupport *xtext;
	SHORT line, nextchar, i, i2, lineindex;
	LONG count;
	struct TextAttr *testfont;

	IntuitionBase = (struct IntuitionBase *)
			OpenLibrary("intuition.library", 0);
	GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0);
	if ((IntuitionBase == NULL) || (GfxBase == NULL)) goto DONE;

	if ((window = OpenWindow(&NewXTextWindow)) == NULL) goto DONE;

	SetAPen(window->RPort, 1);
	RectFill(window->RPort, 28, 0, 586, 9);
	SetWindowTitles(window,
			"                      XText Demonstration Window", -1);
	Move(window->RPort, 216, 32);
	Text(window->RPort, "Please wait a moment ...", 24);


#ifdef TOPAZ11_XTEXTING
	testfont = &DiskFont;
#else
	testfont = NULL;
#endif


#ifdef SHOW_SLIM_XTEXTING
	xtext = MakeXTextSupport(window->RPort, testfont, 80, SLIM_XTEXT);
#else
	xtext = MakeXTextSupport(window->RPort, testfont, 80, NULL);
#endif
	if (xtext == NULL) goto DONE;


#ifdef XTEXTING	/* Do you want to see an example of XText() ? */
	myAddFont(xtext, FSF_BOLD, BOLD_FONT, testfont);
	myAddFont(xtext, FSF_UNDERLINED, ULINE_FONT, testfont);
	myAddFont(xtext, FSF_UNDERLINED | FSF_BOLD, ULINE_BOLD_FONT, testfont);
	myAddFont(xtext, FSF_ITALIC, ITALIC_FONT, testfont);
	myAddFont(xtext, FSF_ITALIC | FSF_BOLD, ITALIC_BOLD_FONT, testfont);
	myAddFont(xtext, FSF_ITALIC | FSF_UNDERLINED, 
			ITALIC_ULINE_FONT, testfont);
	myAddFont(xtext, FSF_ITALIC | FSF_UNDERLINED | FSF_BOLD, 
			ITALIC_ULINE_BOLD_FONT, testfont);
#endif

	nextchar = 32;
	for (i = 0; i < 23; i++)
		for (i2 = 0; i2 < 80; i2++)
			{
			buffer[i][i2] = nextchar++;
			if (nextchar >= 256) nextchar = 0;
			}

	line = 12;
	lineindex = 0;
	count = 0;

	while (NOT GetMsg(window->UserPort))
		{
#ifdef XTEXTING
		if (lineindex == 2) infoLine(xtext, line);
		else XText(xtext, &buffer[lineindex][0], 80, 0, line);
#else
		Move(window->RPort, 0, line);
		Text(window->RPort, &buffer[lineindex][0], 80);
#endif

		line += xtext->CharHeight;
		lineindex++;

		if (line > 192)
			{
			count++;
			sprintf(&buffer[3][33], "-  %ld  -", count);
			line = 12;
			lineindex = 0;

			xtext->FontSelect++;
			if (xtext->FontSelect >= 8)
				{
				xtext->FontSelect = 0;
				advancePens(xtext);
				}
#ifndef XTEXTING
			SetAPen(window->RPort, xtext->FrontPen);
			SetBPen(window->RPort, xtext->BackPen);
			SetSoftStyle(window->RPort, xtext->FontSelect, -1);
#endif
			}
		}



DONE:

	if (xtext) UnmakeXTextSupport(xtext);
	if (window) CloseWindow(window);
	if (IntuitionBase) CloseLibrary(IntuitionBase);
	if (GfxBase) CloseLibrary(GfxBase);
}



VOID myAddFont(xtext, style, index, font)
struct XTextSupport *xtext;
SHORT style, index;
struct TextAttr *font;
{
	if (font == NULL) font = &SafeFont;
	font->ta_Style = style;

	/* I could check if the next routine returned NULL, but since it
	 * doesn't hurt anything if it fails, I just won't bother.  It's ok.
	 */
	MakeXTextFont(font, xtext, index);
}



VOID infoLine(xtext, line)
struct XTextSupport *xtext;
SHORT line;
{
	SHORT selectsave, pen;

	selectsave = xtext->FontSelect;

	pen = xtext->FrontPen;
	xtext->FrontPen = xtext->BackPen;
	xtext->BackPen = pen;

	xtext->FontSelect = NORMAL_FONT;
	XText(xtext, 
		"- Every time the color changes the text has been entirely redrawn ", 
		66, 0, line);
	xtext->FontSelect = BOLD_FONT;
	XText(xtext, "eight times! -", -1, 66 * 8, line);

	pen = xtext->FrontPen;
	xtext->FrontPen = xtext->BackPen;
	xtext->BackPen = pen;
	xtext->FontSelect = selectsave;
}



VOID advancePens(xtext)
struct XTextSupport *xtext;
{
	SHORT frontpen, backpen;

	frontpen = xtext->FrontPen;
	backpen = xtext->BackPen;

	backpen++;
	if (backpen == frontpen) backpen++;
	if (backpen > 3)
		{
		backpen = 0;
		frontpen++;
		if (frontpen > 3)
			{
			frontpen = 0;
			backpen = 1;
			}
		}
	xtext->FrontPen = frontpen;
	xtext->BackPen = backpen;
}


