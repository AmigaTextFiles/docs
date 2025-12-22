
/* *** color.c *************************************************************
 *
 * ColorWindow Routine  --  Color Window Routines
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


#include "color.h"



extern struct Gadget ColorTemplateGadgets[COLOR_GADGETS_COUNT];
extern struct Image ColorPropsImages[3];
extern struct PropInfo ColorPropsInfos[3];
extern struct Image ColorRGBImage;
extern struct Image ColorHSLImage;
extern struct Image SuperColorImages[32];
extern USHORT RGBData[];
extern USHORT HSLData[];

UBYTE *AllocRemember();
struct IntuiMessage *GetMsg();
struct Window *OpenWindow();



/* ColorMode definitions */
#define COPYCOLOR	1
#define RANGE_FIRST  2
#define RANGE_SECOND 3

/* These are the dimensions of the color hit box */
#define COLOR_COLOR_ROWS	(4 * 10)
#define COLOR_COLOR_COLS	(8 * 15)
#define COLOR_COLOR_RIGHT   (COLOR_BOX_LEFT + COLOR_COLOR_COLS - 1)
#define COLOR_COLOR_BOTTOM  (COLOR_COLOR_TOP + COLOR_COLOR_ROWS - 1)

VOID ResetColorProps();


struct NewWindow ColorNewWindow =
	{
	/*		SHORT LeftEdge, TopEdge;		/* screen dimensions of window */
	/*		SHORT Width, Height;				/* screen dimensions of window */
	20, 12,
	COLORWINDOW_WIDTH, COLORWINDOW_HEIGHT,

	/*		UBYTE DetailPen, BlockPen;		/* for bar/border/gadget rendering */
	-1, -1,

	/*		ULONG IDCMPFlags;				/* User-selected IDCMP flags */
	GADGETDOWN | GADGETUP | MOUSEBUTTONS  
			| MENUPICK | MOUSEMOVE | ACTIVEWINDOW | INACTIVEWINDOW,

	/*		ULONG Flags;						/* see Window struct for defines */
	WINDOWDRAG | SMART_REFRESH | NOCAREREFRESH | ACTIVATE,

	/*		struct Gadget *FirstGadget;*/
	&ColorTemplateGadgets[COLOR_GADGETS_COUNT - 1],

	/*		struct Image *CheckMark;*/
	NULL,

	/*		UBYTE *Title;						  /* the title text for this window */
	(UBYTE *)"Change Colors",
	
	/*		struct Screen *Screen;*/
	NULL,
	
	/*		struct BitMap *BitMap;*/
	NULL,

	/*		SHORT MinWidth, MinHeight;		 /* minimums */
	0, 0,
	/*		SHORT MaxWidth, MaxHeight;		 /* maximums */
	0, 0,

	/*		USHORT Type;*/
	CUSTOMSCREEN,
};

USHORT ColorMode;
USHORT RangeFirst;
struct Window *ColorWindow = NULL;
struct RastPort *ColorRPort;
struct ViewPort *ColorVPort;
SHORT RowCount, RowHeight, ColumnCount, ColumnWidth;
USHORT SavePalette[32];




/* ======================================================================= */
/* === These Routines Open, Render, and Close the Color Window =========== */
/* ======================================================================= */

VOID InitColorSizes(depth)
SHORT depth;
/* This routine adjusts the row and column variables based on the number
 * of colors supported by the ColorWindow's screen.
 */
{
	RowCount = 1 << (depth >> 1);
	RowHeight = COLOR_COLOR_ROWS / RowCount;

	ColumnCount = 1 << ((depth + 1) >> 1);
	ColumnWidth = COLOR_COLOR_COLS / ColumnCount;
}



VOID DrawBox(rp, left, top, right, bottom)
struct RastPort *rp;
SHORT left, top, right, bottom;
/* A quick utility routine */
{
	SHORT savepen;

	savepen = ColorRPort->FgPen;

	SetAPen(rp, 1);
	SetDrMd(rp, JAM2);

	Move(rp, left, top);
	Draw(rp, left, bottom);
	Draw(rp, right, bottom);
	Draw(rp, right, top);
	Draw(rp, left, top);

	SetAPen(ColorRPort, savepen);
}


	 
VOID ColorRectFill(pen)
SHORT pen;
/* This routine sets the pen in the RastPort as the current pen selected
 * by the user, and then fills the color box with that pen color.
 */
{
	SetAPen(ColorRPort, pen);
	SetDrMd(ColorRPort, JAM1);
	RectFill(ColorRPort, COLOR_BOX_LEFT, COLOR_BOX_TOP, 
		COLOR_BOX_RIGHT, COLOR_BOX_BOTTOM);
}



VOID DrawColorWindow()
/* This routine fills in all the graphic details of the ColorWindow */
{
	SHORT col, row, colstart, colend, rowstart;
	SHORT savepen;

	savepen = ColorRPort->FgPen;

	InitColorSizes(ColorRPort->BitMap->Depth);

	ColorRectFill(ColorRPort->FgPen);
/*???	DrawBox(ColorRPort, 1, 1, COLORWINDOW_WIDTH - 2, COLORWINDOW_HEIGHT - 2);*/
	DrawBox(ColorRPort, COLOR_BOX_LEFT - 2, COLOR_BOX_TOP - 2, 
			COLOR_BOX_RIGHT + 2, COLOR_BOX_BOTTOM + 2);
	DrawBox(ColorRPort, COLOR_BOX_LEFT - 2, COLOR_COLOR_TOP - 2, 
			COLOR_BOX_LEFT + (8 * 15) + 1, COLOR_COLOR_TOP + (4 * 10) + 1);

	colstart = COLOR_BOX_LEFT;
	colend = colstart + ColumnWidth - 1;
	for (col = 0; col < ColumnCount; col++)
		{
		rowstart = COLOR_COLOR_TOP;
		for (row = 0; row < RowCount; row++)
			{
			SetAPen(ColorRPort, (row * ColumnCount) + col);
			RectFill(ColorRPort, colstart, rowstart, colend, 
					rowstart + RowHeight - 1);
			rowstart += RowHeight;
			}
		colstart += ColumnWidth;
		colend += ColumnWidth;
		}

	SetAPen(ColorRPort, savepen);
}



										
struct Window *OpenColorWindow(screen, firstpen)
struct Screen *screen;
SHORT firstpen;
{
	SHORT i;

	if (ColorNewWindow.Screen = screen) ColorNewWindow.Type = CUSTOMSCREEN;
	else ColorNewWindow.Type = WBENCHSCREEN;

	if ((ColorWindow = OpenWindow(&ColorNewWindow)) == 0) return(NULL);

	ColorVPort = &ColorWindow->WScreen->ViewPort;
	ColorRPort = ColorWindow->RPort;

	for (i = 0; i < 32; i++)
		SavePalette[i] = GetRGB4(ColorVPort->ColorMap, i);

	SetAPen(ColorRPort, firstpen);
	ResetColorProps();
	DrawColorWindow();

	ColorMode = NULL;

	return(ColorWindow);
}




VOID CloseColorWindow(accept)
BOOL accept;
{
	if (ColorWindow == NULL) return;

	if (NOT accept) LoadRGB4(ColorVPort, &SavePalette[0], 32);

	CloseWindow(ColorWindow);
	ColorWindow = NULL;
}




/* ======================================================================= */
/* === These Routines Manage the User Interaction ======================== */
/* ======================================================================= */

BOOL ColorGadgetGotten(gadget)
struct Gadget *gadget;
/* This routine manages the user's gadget selection.  If one of the 
 * end gadgets, such as OK or CANCEL, was selected then this routine
 * returns FALSE, else it returns TRUE.
 */
{
	switch (gadget->GadgetID)
		{
		case COLOR_OK:
			CloseColorWindow(TRUE);
			return(FALSE);
			break;
		case COLOR_CANCEL:
			CloseColorWindow(FALSE);
			return(FALSE);
			break;
		case COLOR_COPY:
			ColorMode = COPYCOLOR;
			break;
		case COLOR_RANGE:
			ColorMode = RANGE_FIRST;
			break;
		case COLOR_HSL_RGB:
			ResetColorProps();
			break;
		}
	return(TRUE);
}



VOID ColorRange(first, last)
SHORT first, last;
/* Create the color range from first to last */
{
	SHORT i;
	SHORT whole, redfraction, greenfraction, bluefraction, divisor;
	USHORT rgb;
	SHORT firstred, firstgreen, firstblue;
	SHORT lastred, lastgreen, lastblue;
	SHORT workred, workgreen, workblue;

	/* If the pen numbers are out of order, swap */
	if (first > last)
		{
		i = first;
		first = last;
		last = i;
		}

	/* I need to see a spread of at least two, where there's at least one
	 * spot between the endpoints, else there's no work to do so I
	 * might as well just return now.
	 */
	if (first >= last - 1) return;

	rgb = GetRGB4(ColorVPort->ColorMap, first);
	firstred = (rgb >> 8) & 0xF;
	firstgreen = (rgb >> 4) & 0xF;
	firstblue = (rgb >> 0) & 0xF;

	rgb = GetRGB4(ColorVPort->ColorMap, last);
	lastred = (rgb >> 8) & 0xF;
	lastgreen = (rgb >> 4) & 0xF;
	lastblue = (rgb >> 0) & 0xF;


	divisor = last - first;

	/* Do all math as fixed-point fractions where the low 8 bits are 
	 * the fraction.  This greatly lessens the effect of rounding errors.
	 */
	whole = (lastred - firstred) << 8;
	redfraction = whole / divisor;

	whole = (lastgreen - firstgreen) << 8;
	greenfraction = whole / divisor;

	whole = (lastblue - firstblue) << 8;
	bluefraction = whole / divisor;

	for (i = first + 1; i < last; i++)
		{
		lastred = ((redfraction * (i - first)) + 0x0080) >> 8;
		workred = firstred + lastred;
		lastgreen = ((greenfraction * (i - first)) + 0x0080) >> 8;
		workgreen = firstgreen + lastgreen;
		lastblue = ((bluefraction * (i - first)) + 0x0080) >> 8;
		workblue = firstblue + lastblue;
		SetRGB4(ColorVPort, i, workred, workgreen, workblue);
		}
}




VOID ColorWindowHit(x, y)
SHORT x, y;
/* The color boxes at the bottom-right of the ColorWindow are not gadgets.
 * Instead, it's just graphics and this routine is used to detect whether
 * the user has selected one of the color boxes.
 */
{
	USHORT rgb, pen;

	/* Have we got a color specifier? */
	if ( (x >= COLOR_BOX_LEFT) && (x <= COLOR_COLOR_RIGHT)
			&& (y >= COLOR_COLOR_TOP) && (y <= COLOR_COLOR_BOTTOM) )
		{
		/* Yes, it's one of the color boxes.  Set this pen number */
		x = x - COLOR_BOX_LEFT;
		x = x / ColumnWidth;
		y = y - COLOR_COLOR_TOP;
		y = y / RowHeight;
		pen = (y * ColumnCount) + x;

		/* first, were we in COPY COLOR mode? */
		if (ColorMode == COPYCOLOR)
			{
			/* ok, copy old color here first! */
			rgb = GetRGB4(ColorVPort->ColorMap, ColorRPort->FgPen);
			SetRGB4(ColorVPort, pen, rgb >> 8, rgb >> 4, rgb);
			ColorMode = NULL;
			}
		else if (ColorMode == RANGE_FIRST)
			{
			ColorMode = RANGE_SECOND;
			RangeFirst = pen;
			}
		else if (ColorMode == RANGE_SECOND)
			{
			ColorMode = NULL;
			ColorRange(RangeFirst, pen);
			}
		ColorRectFill(pen);

		ResetColorProps();
		}
}



VOID SetPropValueGrunt(value, y)
SHORT value, y;
{
	UBYTE text[16];

	if (value >= 0) sprintf(&text[0], "%ld ", value);
	else
		{
		text[0] = ' ';
		text[1] = ' ';
		}

	Move(ColorRPort, COLOR_VALUE_X, y);
	Text(ColorRPort, &text[0], 2);
}



VOID SetPropValues(red, green, blue)
SHORT red, green, blue;
/* Sets the text to the right of the prop gadgets */
{
	SHORT savepen;

	savepen = ColorRPort->FgPen;

	SetAPen(ColorRPort, 1);
	SetDrMd(ColorRPort, JAM2);

	SetPropValueGrunt(red, COLOR_VALUE_REDY);
	SetPropValueGrunt(green, COLOR_VALUE_GREENY);
	SetPropValueGrunt(blue, COLOR_VALUE_BLUEY);

	SetAPen(ColorRPort, savepen);
}



VOID ModifyRGBColors()
{
	USHORT newred, newgreen, newblue;

	newred = ColorPropsInfos[0].HorizPot >> 12;
	newgreen = ColorPropsInfos[1].HorizPot >> 12;
	newblue = ColorPropsInfos[2].HorizPot >> 12;

	SetRGB4(ColorVPort, ColorRPort->FgPen, newred, newgreen, newblue);
	SetPropValues(newred, newgreen, newblue);
}




VOID ModifyHSLColors()
{
	USHORT rgb;

	rgb = (USHORT)HSLToRGB(
			ColorPropsInfos[0].HorizPot,
			ColorPropsInfos[1].HorizPot,
			ColorPropsInfos[2].HorizPot);

	SetRGB4(ColorVPort, ColorRPort->FgPen, rgb >> 8, rgb >> 4, rgb);
	SetPropValues(-1, -1, -1);
}




VOID ModifyColors()
/* This routine reacts to the user playing with one of the prop gadgets */
{
	if (ColorTemplateGadgets[COLOR_HSL_RGB].Flags & SELECTED)
		ModifyHSLColors();
	else
		ModifyRGBColors();
}



VOID SetRGBProps(rgb)
USHORT rgb;
{
	USHORT red, green, blue;

	red = (rgb >> 8) & 0xF;
	green = (rgb >> 4) & 0xF;
	blue = (rgb >> 0) & 0xF;

	ColorPropsInfos[0].HorizPot
			= (red << 12) | (red << 8) | (red << 4) | red;
	ColorPropsInfos[1].HorizPot
			= (green << 12) | (green << 8) | (green << 4) | green;
	ColorPropsInfos[2].HorizPot
			= (blue << 12) | (blue << 8) | (blue << 4) | blue;

	SetPropValues(red, green, blue);
}



VOID SetHSLProps(rgb)
USHORT rgb;
{
	RGBToHSL(rgb,
			&ColorPropsInfos[0].HorizPot,
			&ColorPropsInfos[1].HorizPot,
			&ColorPropsInfos[2].HorizPot);

	SetPropValues(-1, -1, -1);
}



VOID ResetColorProps()
/* This routine resets the proportional gadgets according to the current
 * pen number and the interaction technique
 */
{
	SHORT bluepos;
	USHORT rgb;

	rgb = GetRGB4(ColorVPort->ColorMap, ColorRPort->FgPen);

	bluepos = RemoveGList(ColorWindow, &ColorTemplateGadgets[COLOR_BLUE], 3);

	if (ColorTemplateGadgets[COLOR_HSL_RGB].Flags & SELECTED)
		SetHSLProps(rgb);
	else SetRGBProps(rgb);

	AddGList(ColorWindow, &ColorTemplateGadgets[COLOR_BLUE], bluepos, 3, 0);
	RefreshGList(&ColorTemplateGadgets[COLOR_BLUE], ColorWindow, NULL, 3);
}





/* ======================================================================= */
/* === And finally, the Main Entry Point ================================= */
/* ======================================================================= */


/* *** DoColorWindow() ******************************************************
 * 
 * NAME
 *     DoColorWindow  --  Allows the user to change a screen's colors
 * 
 * 
 * SYNOPSIS
 *     BOOL DoColorWindow(Screen, Left, Top, FirstPen, UseRGB);
 * 
 * 
 * FUNCTION
 *     This routine creates a window, called the ColorWindow, which has 
 *     gadgets that allow the user to change the colors of any screen.  
 *     After opening the ColorWindow, this routine interacts with the 
 *     user until the user is satisfied with the current colors, at which 
 *     time the window is closed and control is returned to you.  
 * 
 *     The ColorWindow will open in the specified Screen.  The Screen 
 *     argument can be equal to NULL; if it is, the ColorWindow will be 
 *     opened in the Workbench screen.  The ColorWindow automatically 
 *     adapts itself to any screen.  
 * 
 *     With the Top and Left arguments you specify the position of the 
 *     ColorWindow's top-left corner.  Note that no position-error 
 *     checking is done, so you must take care to not place the window 
 *     outside of the bounds of your screen.  Currently, the Left argument 
 *     can range from 0 to 88 on low-resolution screens, and 0 to 408 
 *     on high-resolution screens.  The Top argument can range from 
 *     0 to 109 on a 200-line screen, and 0 to 309 on an interlaced screen.  
 *     These figures don't include overscan, which most programmers 
 *     don't use.  The width and height of the ColorWindow are defined 
 *     by the constants COLORWINDOW_WIDTH and COLORWINDOW_HEIGHT in the 
 *     color.h file.  
 * 
 *     The FirstPen argument is used to initialize the color that's 
 *     displayed when the ColorWindow is first created.  
 * 
 *     The ColorWindow is capable of allowing the user to modify the 
 *     colors using either an RGB or an HSL technique.  The RGB technique 
 *     involves three proportional gadgets, one for each of Red, Green 
 *     and Blue.  By adjusting one of these gadgets, the user adjusts 
 *     the amount of the associated color component in the final color.  
 *     Some people feel that this is the most intuitive way to change 
 *     colors on the Amiga, as this is how colors are represented 
 *     internally by the Amiga.  The other technique, HSL, allows the 
 *     user to adjust the Hue, Saturation and Luminance of the final color.  
 *     Some people feel that *this* is the most intuitive way for users 
 *     to change color, because it's based on color theory and because 
 *     these are the types of controls that people used on their 
 *     color televisions in the old days.  
 * 
 *     You decide which mode is first used when the ColorWindow is created 
 *     by setting the UseRGB argument to TRUE or FALSE.  If TRUE, 
 *     the RGB technique will be used.  If FALSE, HSL is used.  
 * 
 *     But regardless of which technique you specify, the user can switch 
 *     to using the other technique by clicking on the RGB / HSL characters 
 *     that appear to the left of the proportional gadgets.  
 * 
 *     On return from this function, this routine returns TRUE if all 
 *     went well.  If anything went wrong (usually out of memory) and 
 *     the ColorWindow was never created, this routine returns FALSE.  
 * 
 *     NOTE:  This routine is not re-entrant.  What this means 
 *     is that if you have created a program that has more than one task,
 *     this routine cannot be called by more than one task at a time.
 *     This was done for the sake of memory efficiency.
 *     This restriction is not a problem for the grand majority of programs.
 *     But if you have some application that would require calling this 
 *     routine asynchronously from multiple tasks, you'll have to 
 *     implement some quick semaphore arrangement to avoid collisions.
 *     No big deal, actually.  See Exec semaphores for everything you need.
 * 
 * 
 * INPUTS
 *     Screen = address of the screen in which the ColorWindow will open.
 *         Can be NULL; if so, the ColorWindow will open in the Workbench
 *     Left = position of the left edge when the ColorWindow opens
 *     Top = position of the top edge when the ColorWindow opens
 *     FirstPen = pen number of the color displayed when the ColorWindow
 *         first opens
 *     UseRGB = TRUE if you want the RGB technique displayed first, 
 *         FALSE if you want the HSL technqiue.  See the discussion above
 * 
 * 
 * RESULT
 *     Returns TRUE if all went well.  If the window couldn't be opened for
 *     any reason, returns FALSE.
 * 
 * 
 */
BOOL DoColorWindow(screen, left, top, firstpen, usergb)
struct Screen *screen;
SHORT left, top, firstpen;
BOOL usergb;
{
	struct IntuiMessage *message;
	ULONG class;
	struct Gadget *gadget;
	BOOL mousemoved;
	SHORT x, y, code, i;
	struct Remember *key;
	UWORD *ptr;
	BOOL retvalue;

	key = NULL;
	retvalue = FALSE;

	if (ColorWindow) goto DONE;

	ColorNewWindow.LeftEdge = left;
	ColorNewWindow.TopEdge = top;

	if (usergb)
		ColorTemplateGadgets[COLOR_HSL_RGB].Flags &= ~SELECTED;
	else
		ColorTemplateGadgets[COLOR_HSL_RGB].Flags |= SELECTED;

	if ((ptr = (UWORD *)AllocRemember(&key, RGBHSL_SIZE * 2, MEMF_CHIP))
			== NULL)
		goto DONE;
	ColorRGBImage.ImageData = ptr;
	for (i = 0; i < RGBHSL_SIZE; i++)
		*ptr++ = RGBData[i];
	if ((ptr = (UWORD *)AllocRemember(&key, RGBHSL_SIZE * 2, MEMF_CHIP))
			== NULL)
		goto DONE;
	ColorHSLImage.ImageData = ptr;
	for (i = 0; i < RGBHSL_SIZE; i++)
		*ptr++ = HSLData[i];

	if (NOT OpenColorWindow(screen, firstpen & 0x3F)) goto DONE;

	retvalue = TRUE;

	FOREVER
		{
		Wait(1 << ColorWindow->UserPort->mp_SigBit);

		mousemoved = FALSE;
		while (message = GetMsg(ColorWindow->UserPort))
			{
			class = message->Class;
			code = message->Code;
			gadget = (struct Gadget *)(message->IAddress);
			x = message->MouseX;
			y = message->MouseY;
			ReplyMsg(message);

			switch (class)
				{
				case GADGETDOWN:
				case GADGETUP:
					if (ColorGadgetGotten(gadget) == FALSE)
						goto DONE;
					break;
				case MOUSEMOVE:
					mousemoved = TRUE;
					break;
				case MOUSEBUTTONS:
					if (code == SELECTDOWN) ColorWindowHit(x, y);
					break;
				}
			}
		if (mousemoved) ModifyColors();
		}

DONE:
	FreeRemember(&key, TRUE);
	return(retvalue);
}


