
	IFND	XTEXT_I
XTEXT_I	EQU	1

* **************************************************************************
*
* XText Routines
*     from Book 1 of the Amiga Programmers' Suite by RJ Mical
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
* HISTORY      NAME            DESCRIPTION
* -----------  --------------  --------------------------------------------
* 26 Jan 86    RJ Mical        Created this file (on my birthday!)
* March 86     RJ              Incorporated this code in Sidecar
* 27 Oct 86    RJ              Add XText buffer stuff, prepare for release
*
* *********************************************************************** *


* AZTEC	EQU	1



	INCLUDE	"exec/types.i"
	INCLUDE "graphics/gfx.i"
	INCLUDE "intuition/intuition.i"
	INCLUDE "hardware/custom.i"

	IFND	AZTEC ; If AZTEC not defined, do it the standard way
	INCLUDE "asmsupp.i"
	ENDC
	IFD	AZTEC ; If AZTEC defined, do it the non-standard way (sigh)
	INCLUDE "assmsupp.i"
	ENDC



* === System Macros ===================================================== */
			   
INFOLEVEL	EQU	100

LINKGFX MACRO	
	LINKSYS \1,_GfxBase    
	ENDM

LINKINT MACRO
	LINKSYS \1,_IntuitionBase
	ENDM


* === System Definitions ================================================= */

	XLIB	BltBitMapRastPort
	XLIB	BltMaskBitMapRastPort
	XLIB	Debug
	XLIB	DisownBlitter
	XLIB	Move
	XLIB	OwnBlitter
	XLIB	RectFill
	XLIB	SetAPen
	XLIB	SetBPen
	XLIB	SetDrMd
	XLIB	Text
	XLIB	WaitBlit


* === XText Support Structure ===========================================
 STRUCTURE XTextSupport,0
	BYTE	xt_FrontPen
	BYTE	xt_BackPen
	BYTE	xt_DrawMode

	BYTE	xt_MaxTextWidth

	SHORT	xt_CharHeight
	SHORT	xt_Flags

	APTR	xt_NormalTextPlane
	APTR	xt_InverseTextPlane
	APTR	xt_AllClearPlane
	APTR	xt_AllSetPlane

	APTR	xt_XTextKey

	APTR	xt_OutputRPort

	SHORT   xt_FontSelect
	STRUCT	xt_FontData,(8*4)

	STRUCT	xt_TextBitMap,bm_SIZEOF

	LABEL	xt_SIZEOF


* === XTextSupport Flags Definitions ===
SLIM_XTEXT	EQU	$0001




* === ===================================================================
XTEXT_CHARWIDTH		EQU	8


	ENDC		; of XTEXT_I


