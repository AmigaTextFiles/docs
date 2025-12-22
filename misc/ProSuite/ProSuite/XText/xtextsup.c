
/* *** xtextsup.c ***********************************************************
 *
 * XText  --  Support Procedures
 *    from Book 1 of the Amiga Programmers' Suite by RJ Mical
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


VOID UnmakeXTextSupport();


struct TextAttr DefaultXTextFont =
		{
		(UBYTE *)"topaz.font",
		TOPAZ_EIGHTY,
		0,
		FS_NORMAL
		};


UBYTE *AllocXTextPlane(xtext)
struct XTextSupport *xtext;
/* This routine allocates an XText text plane, with one byte for each
 * line of each character in the widest allowable line.
 */
{
	return (AllocRemember(&xtext->XTextKey, 
			xtext->MaxTextWidth * xtext->CharHeight,
			MEMF_CLEAR | MEMF_CHIP));
}



VOID AttachRemember(tokey, fromkey)
struct Remember **tokey, **fromkey;
/* Attach the contents of a Remember key to the allocations of another
 * Remember key.
 */
{
	struct Remember *workkey;

	if ((workkey = *tokey) == NULL) *tokey = *fromkey;
	else
		{
		while (workkey->NextRemember) workkey = workkey->NextRemember;
		workkey->NextRemember = *fromkey;
		}
	*fromkey = NULL;
}



VOID MakeXTextFontData(font, style, bufptr, xtext)
struct TextFont *font;
USHORT style;
UBYTE *bufptr;
struct XTextSupport *xtext;
/* This awful little routine fills the buffer with the XText-style
 * font imagery.  The font is set to reflect the desired style, if any,
 * and then one character at a time is drawn (using Text()) into
 * a temporary rastport and then copies the character imagery into
 * the XText buffer.
 */
{
	SHORT i, i2;
	UBYTE text;
	SHORT baseline, height, xoffset, bytewidth;
	SHORT extracolumn, movecolumn;
	LONG enable;
	UBYTE *ptr;
	struct RastPort *rport;
	struct BitMap *bmap;
	struct TmpRas *tmpras;
	struct Remember *localKey;

	localKey = NULL;
	rport = (struct RastPort *)AllocRemember(&localKey,
			sizeof(struct RastPort), NULL);
	bmap = (struct BitMap *)AllocRemember(&localKey,
			sizeof(struct BitMap), NULL);
	tmpras = (struct TmpRas *)AllocRemember(&localKey,
			sizeof(struct TmpRas), NULL);
	if ((rport == NULL) || (bmap == NULL) || (tmpras == NULL))
		goto DONE;

	bytewidth = xtext->MaxTextWidth;
	height = xtext->CharHeight;

	InitBitMap(bmap, 1, bytewidth * XTEXT_CHARWIDTH, height);
	bmap->Planes[0] = xtext->NormalTextPlane;
	InitRastPort(rport);
	rport->BitMap = bmap;
	rport->TmpRas = InitTmpRas(tmpras, xtext->InverseTextPlane,
			bytewidth * height);

	SetAPen(rport, 1);
	SetBPen(rport, 0);
	SetDrMd(rport, JAM2);

	SetFont(rport, font);
	enable = AskSoftStyle(rport);
	SetSoftStyle(rport, style, enable);

	baseline = rport->TxBaseline;

	/* Now, italics are a real pain in the ascii.
	 * An 8-bit-wide font is normally wider than 8 bits when rendered 
	 * in italics, so some of the character data must be lost.  
	 * You can set the xoffset variable to some alternate value 
	 * if you want an alternate slice of the font data.
	 * 
	 * Furthermore, I just spent several hours discovering that 
	 * the Text() routine creates the italics by shifting the lines above
	 * the baseline to the right *and* by shifting the lines below the
	 * baseline to the left.  So what, you ask?  Well, if a character 
	 * is printed starting at column 0, in a RastPort 
	 * unprotected by a Layer, then those left-shifted bits 
	 * tickle the nose of the guru, doncha know.  Achoo!  Blink blink blink.
	 */

	xoffset = 0;
	/* See the comment above regarding xoffset */
	if (style & FSF_ITALIC) xoffset = ITALIC_LEFT_EDGE;

	/* Text is drawn at least at column 8, and perhaps even further 
	 * to the right if the left-shift of italics makes it necessary.
	 */
	extracolumn = ((height - baseline) - 1) >> 3;
	movecolumn = (8 + (extracolumn << 3)) - xoffset;

	for (i = 0; i < 256; i++)
		{
		text = i;

		/* Finally, move the pens to our spot and draw the next character */
		Move(rport, movecolumn, baseline);
		Text(rport, &text, 1);

		/* Now copy that character in XText font format into the buffer. */
		ptr = bmap->Planes[0] + 1 + extracolumn;
		for (i2 = 0; i2 < height; i2++)
			{
			*bufptr++ = *ptr;
			if (FlagIsClear(xtext->Flags, SLIM_XTEXT)) *bufptr++ = 0;
			ptr += bytewidth;		/* Skip to the next row */
			}
		}

DONE:
	FreeRemember(&localKey, TRUE);
}



/* *** MakeXTextFont() ******************************************************
 * 
 * NAME
 *    MakeXTextFont  --  Make font imagery for the XText routines
 * 
 * 
 * SYNOPSIS
 *    UBYTE *MakeXTextFont(TextAttr, XTextSupport, Index);
 * 
 * 
 * FUNCTION
 *    This routine creates font imagery in the format that the XText()
 *    routine uses.  It allocates the font data buffer and then constructs
 *    the XText font imagery in this buffer using the imagery of the
 *    font specified by the TextAttr argument.
 *    
 *    This routine is normally called by MakeXTextSupport().  You do not
 *    need to use this routine unless you want to create fonts that
 *    have special styles such as bold, underline, and italics.
 *    
 *    If all is successful, this routine writes the address of the font 
 *    data buffer in the XTextSupport's FontData array at the Index position,
 *    and returns the address of the new font data buffer.  
 *    If anything goes wrong, the FontData array is unchanged and this 
 *    routine returns NULL.
 *    
 *    You can specify font styles in your TextAttr structure.
 *    If the TextAttr argument is equal to NULL, the system's 80-column 
 *    "topaz.font" will be used instead.
 *    
 *    You must have called MakeXTextSupport() before calling this routine,
 *    as this routine requires an initialized XTextSupport structure.
 *    All memory allocations are attached to the XTextSupport structure's
 *    Remember key.
 *    
 *    
 * INPUTS
 *    TextAttr = a pointer to a TextAttr structure specifying the font
 *       to be used for this XText font imagery.  If the TextAttr
 *       argument is equal to NULL, the system's 80-column "topaz.font"
 *       will be used.
 *    
 *    XTextSupport = a pointer to an initialized XTextSupport structure,
 *       which structure is created by a call to MakeXTextSupport().
 *    
 *    Index = index into the XTextSupport's FontData array for this font
 *    
 *    
 * RESULT
 *    Returns a pointer to the memory block that contains the font imagery.
 *    If anything goes wrong (usually out of memory), returns NULL.
 *    
 *    
 * EXAMPLE
 *      struct XTextSupport *xtext;
 *      struct TextAttr localTextAttr = { ... };
 *      xtext = MakeXTextSupport();
 *    [Make a BOLD font for XText() calls]
 *      localTextAttr.ta_Style = FSF_BOLD;
 *      MakeXTextFont(&localTextAttr, xtext, BOLD_FONT);
 *    [Write some BOLD characters]
 *      xtext->FontSelect = BOLD_FONT;
 *      XText(...);
 *
 * BUGS
 *    Well, if there is a bug it's a highly technical one that most
 *    of you can ignore.  I'm not sure that it's entirely 100% for sure 
 *    safe to work with DiskfontBase the way I have below and still expect
 *    this program to be re-entrant.  It should be OK up to and including 
 *    the 1.2 release of the system, but in the future this could cause
 *    some very mysterioso bug.
 *    
 *    
 * SEE ALSO
 *    MakeXTextSupport(), XText(), UnmakeXTextSupport()
 */
UBYTE *MakeXTextFont(textattr, xtext, index)
struct TextAttr *textattr;
struct XTextSupport *xtext;
SHORT index;
/* === Get our special expanded-data font === */
{
	struct TextFont *localfont;
	BOOL openedlib, success;
	UBYTE *data;
	struct Remember *localkey;
	SHORT size;

	openedlib = success = FALSE;
	localkey = NULL;
	localfont = NULL;

	/* If the user has specified no font, use 80-column "topaz.font" */
	if (textattr == NULL) textattr = &DefaultXTextFont;

	/* Allocate a special-character buffer where there are 256 characters
	 * and each character is CharHeight tall.  If not SLIM_XTEXT, make the 
	 * text two bytes wide for each character.
	 */
	size = 256 * xtext->CharHeight;
	if (FlagIsClear(xtext->Flags, SLIM_XTEXT)) size *= 2;
	if ((data = AllocRemember(&localkey, size, MEMF_CHIP)) == NULL)
		goto DONE;

	/* Attempt to open the specified font */
	if ((localfont = OpenFont(textattr)) == NULL)
		{
		if ((DiskfontBase = (struct DiskfontBase *)
				OpenLibrary("diskfont.library", 0)) == NULL)
			goto DONE;
		openedlib = TRUE;

		if ((localfont = OpenDiskFont(textattr)) == NULL) goto DONE;
		}

	/* localfont is opened.  Transform the data into XText format */
	MakeXTextFontData(localfont, textattr->ta_Style, data, xtext);

	CloseFont(localfont);

	success = TRUE;

DONE:
	if (openedlib) CloseLibrary(DiskfontBase);
	if (success)
		{
		AttachRemember(&xtext->XTextKey, &localkey);
		xtext->FontData[index] = data;
		}
	else 
		{
		FreeRemember(&localkey, TRUE);
		data = NULL;
		}

	return(data);
}



/* *** MakeXTextSupport() ***************************************************
 * 
 * NAME
 *    MakeXTextSupport  --  Allocate and initialize XText Support data
 * 
 * 
 * SYNOPSIS
 *    struct XTextSupport *MakeXTextSupport(RastPort, TextAttr, 
 *          MaxTextWidth, InitialFlags);
 * 
 * 
 * FUNCTION
 *    This routine allocates an XTextSupport structure and initializes
 *    the structure for use by the XText routines.
 * 
 *    The font specified by the TextAttr argument is opened.  If the
 *    TextAttr arg is equal to NULL, the system font "topaz.font" is
 *    opened instead.  If you are specifying a TextAttr, the font you
 *    specify must have a character cel that is 8-bits wide.
 * 
 *    Image data from this font is then used to create the special
 *    font data used by the XText routines.  The address of this data
 *    is put in the FontData variable of the XTextSupport structure,
 *    as well as in all of the elements in the SpecialFontData array.
 * 
 *    The MaxTextWidth argument describes the maximum number of 
 *    characters that you will ever print at one time with the 
 *    XText() routine.  Typically this number will be 80 or 40, 
 *    depending on whether your display is high-res or low-res.  
 *    This number should be an even number; if the number you 
 *    supply is odd, the actual number used will be your number 
 *    rounded up to the next even number.
 * 
 *    The InitialFlags argument is used to preset your XTextSupport's
 *    Flags variable before anything is done with the structure.  
 *    See the file xtext.h for the definitions of the XTextSupport 
 *    structure's Flags.
 * 
 *    An InitialFlag of note is the SLIM_XTEXT flag, which you can 
 *    set to define that you want the slim (and slow) XText technique 
 *    to be used when the XText font data is created and when 
 *    XText is rendered to the display.  The advantage of SLIM_XTEXT 
 *    is that the technique requires half as much memory as the 
 *    fast fat technique.  The disadvantage is that it runs about 
 *    20% more slowly than fast fat XText.  
 * 
 *    After you have called MakeXTextSupport(), you can use
 *    the Remember key in the XTextSupport structure -- named
 *    XTextKey -- for further memory allocations.  All memory
 *    allocations made using XTextKey are freed when 
 *    UnmakeXTextSupport() is called.
 * 
 * 
 * INPUTS
 *    RastPort = a pointer to the RastPort that will be the destination
 *       for text created by the XText routines.  Typically, this
 *       will be the RastPort of an Intuition window or screen
 *       that you've opened.  For an example, see EXAMPLE below.
 * 
 *    TextAttr = a pointer to a TextAttr structure specifying the font
 *       to be used for this XText font imagery.  If the TextAttr
 *       argument is equal to NULL, the system's 80-column "topaz.font"
 *       will be used.
 * 
 *    MaxTextWidth = Maximum number of characters per line.  This should 
 *       be an even number, and if odd will be rounded up to the 
 *       next even number.
 * 
 *    InitialFlags = Flags that will be preset in your XTextSupport's
 *       Flags variable before anything is done with the structure.  
 *       See the file xtext.h for the definitions of the XTextSupport 
 *       structure's Flags.
 * 
 * 
 * RESULT
 *    Returns the address of the XTextSupport structure, or NULL
 *    if there were any problems (usually out of memory).
 * 
 * 
 * EXAMPLE
 *    window = OpenWindow( ... );
 *    xtext = MakeXTextSupport(window->RPort, &DiskFontTextAttr, 80, NULL);
 *    - or, as another example, open a 320 screen and ... -
 *    screen = OpenScreen( ... );
 *    xtext = MakeXTextSupport(&screen->RastPort, NULL, 40, SLIM_XTEXT);
 * 
 * 
 * SEE ALSO
 *    MakeXTextFont(), XText(), UnmakeXTextSupport()
 */
struct XTextSupport *MakeXTextSupport(rport, textattr, maxwidth, flags)
struct RastPort *rport;
struct TextAttr *textattr;
SHORT maxwidth;
SHORT flags;
{
	struct XTextSupport *xtext;
	SHORT i;

	maxwidth = (maxwidth + 1) & -2;

	if ((xtext = (struct XTextSupport *)AllocMem(sizeof(struct XTextSupport),
			MEMF_CLEAR)) == NULL)
		return (NULL);

	xtext->FrontPen = 1;
	xtext->DrawMode = JAM2;
	xtext->MaxTextWidth = maxwidth;
	xtext->Flags = flags;

	/* If the user has specified no font, use 80-column "topaz.font" */
	if (textattr == NULL) textattr = &DefaultXTextFont;

	xtext->CharHeight = textattr->ta_YSize;

	xtext->NormalTextPlane = AllocXTextPlane(xtext);
	xtext->InverseTextPlane = AllocXTextPlane(xtext);
	xtext->AllClearPlane = AllocXTextPlane(xtext);
	xtext->AllSetPlane = AllocXTextPlane(xtext);

	if ((xtext->NormalTextPlane == NULL)
			|| (xtext->InverseTextPlane == NULL)
			|| (xtext->AllClearPlane == NULL)
			|| (xtext->AllSetPlane == NULL))
		{
		UnmakeXTextSupport(xtext);
		return (NULL);
		}

	for (i = 0; i < (xtext->CharHeight * maxwidth); i++)
		xtext->AllSetPlane[i] = -1;

	xtext->OutputRPort = rport;

	InitBitMap(&xtext->TextBitMap, rport->BitMap->Depth, 
			maxwidth * XTEXT_CHARWIDTH, xtext->CharHeight);

	if (MakeXTextFont(textattr, xtext, NORMAL_FONT) == NULL)
		{
		UnmakeXTextSupport(xtext);
		return (NULL);
		}

	for (i = 1; i < 8; i++)
		xtext->FontData[i] = xtext->FontData[0];

	return(xtext);
}



/* *** UnmakeXTextSupport() *************************************************
 * 
 * NAME
 *    UnmakeXTextSupport  --  Free the XTextSupport structure and buffers
 * 
 * 
 * SYNOPSIS
 *    UnmakeXTextSupport(XTextSupport)
 * 
 * 
 * FUNCTION
 *    Frees the XTextSupport structure and buffers.
 *
 *
 * INPUTS
 *    XTextSupport = pointer to an XTextSupport structure (typically
 *               created by a call to MakeXTextSupport() )
 *
 *
 * RESULT
 *    None
 *
 *
 * SEE ALSO
 *    MakeXTextSupport()
 */
VOID UnmakeXTextSupport(xtext)
struct XTextSupport *xtext;
{
	if (xtext)
		{
		FreeRemember(&xtext->XTextKey, TRUE);
		FreeMem(xtext, sizeof(struct XTextSupport));
		}
}


