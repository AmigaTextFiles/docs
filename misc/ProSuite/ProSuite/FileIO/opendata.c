
/* *** opendata.c ***********************************************************
 *
 * File IO Suite  --  Open Requester Data
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
 * 18 Aug 87    RJ              Removed SELECTED from most string gadgets
 * 18 Aug 87    RJ              Added KeyHandler field to ReqSupport
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 3 May 86     =RJ Mical=      Fix prop gadget for both 1.1 and 1.2
 * 1 Feb 86     =RJ Mical=      Created this file.
 *
 * *********************************************************************** */


#define FILEIO_SOURCEFILE
#include "fileio.h"




struct TextAttr SafeFont =
	{
	(UBYTE *)"topaz.font",
	TOPAZ_EIGHTY,
	0,
	0,
	};



/* This is where the Select text is kept!  This array of text will be
 * redrawn every time we want Intuition to redraw the lowly SelectGadget.
 * The strings themselves are kept in OpenSelectBuffers where 
 * the open routines make sure that the buffers are padded with
 * blanks and are always null-terminated.  Ha ha!  Like madmen
 * dancing, like crazy monkeys.
 */
UBYTE OpenSelectBuffers[NAME_ENTRY_COUNT][VISIBLE_SELECT_LENGTH];
struct IntuiText OpenSelectText[NAME_ENTRY_COUNT] =
	{
		{
		1, 0, 
		JAM2,
		1, 1 + (OPEN_LINEHEIGHT * 0),
		&SafeFont,
		&OpenSelectBuffers[0][0],
		NULL,
		},

		{
		1, 0, 
		JAM2,
		1, 1 + (OPEN_LINEHEIGHT * 1),
		&SafeFont,
		&OpenSelectBuffers[1][0],
		&OpenSelectText[0],
		},

		{
		1, 0, 
		JAM2,
		1, 1 + (OPEN_LINEHEIGHT * 2),
		&SafeFont,
		&OpenSelectBuffers[2][0],
		&OpenSelectText[1],
		},

		{
		1, 0, 
		JAM2,
		1, 1 + (OPEN_LINEHEIGHT * 3),
		&SafeFont,
		&OpenSelectBuffers[3][0],
		&OpenSelectText[2],
		},

		{
		1, 0, 
		JAM2,
		1, 1 + (OPEN_LINEHEIGHT * 4),
		&SafeFont,
		&OpenSelectBuffers[4][0],
		&OpenSelectText[3],
		},

		{
		1, 0, 
		JAM2,
		1, 1 + (OPEN_LINEHEIGHT * 5),
		&SafeFont,
		&OpenSelectBuffers[5][0],
		&OpenSelectText[4],
		},

	};




/* === Backdrop Gadget =================================================== */
/* We shouldn't need this gadget.  It's sole purpose is to allow the user 
 * to cancel the filename building operation by clicking outside any of 
 * the regular requester gadgets.  Why, we may ask, don't we just make 
 * the requester a NOISYREQ and detect SELECTDOWN.  Well, we tried that, 
 * and either there's something wrong with our brains or 1.2 Intuition has 
 * a bug that doesn't broadcast SELECTDOWN to requester listeners.  
 * It broadcasts SELECTUP, MENUDOWN and MENUUP jes' fine, but no DOWN.  
 * Bummer.  So anyway, now we got an imageless, highlightless gadget that 
 * fills up the entire requester but, being at the back of the list, won't 
 * be hit unless all other gadgets are missed.  
 * Having a wonderful time, wish you were here.
 */
struct Gadget BackdropGadget =
	{
	NULL,
	0, 0, 
	OPEN_WIDTH, OPEN_HEIGHT, 
	GADGHNONE,				/* Flags */
	GADGIMMEDIATE,			/* Activation */
	REQGADGET | BOOLGADGET,	/* Type */
	NULL, 					/* GadgetRender */
	NULL,					/* SelectRender */
	NULL,
	NULL, NULL, 
	OPENGADGET_BACKDROP, 
	NULL,
	};



/* === OK, Cancel, and NextDisk Gadgets ================================== */
SHORT BoolCluster3Pairs[] =
	{
	0, -3, 
	55, -3,
	57, -1,
	57, 19,
	55, 21,
	-1, 21,
	-3, 19,
	-3, -1,
	-1, -3,
	};

SHORT BoolCluster2Pairs[] =
	{
	-2, -1,
	56, -1,
	56, 19,
	-2, 19,
	-2, -1,
	};

SHORT BoolClusterPairs[] =
	{
	-1, -2,
	55, -2,
	55, 20,
	-1, 20,
	-1, -2,
	};

struct Border BoolCluster3Border =
	{
	1, 1,
	2, 0,
	JAM1,
	9,
	&BoolCluster3Pairs[0],
	NULL,
	};

struct Border BoolCluster2Border =
	{
	1, 1,
	1, 0,
	JAM1,
	5,
	&BoolCluster2Pairs[0],
	&BoolCluster3Border,
	};

struct Border BoolClusterBorder =
	{
	1, 1,
	1, 0,
	JAM1,
	5,
	&BoolClusterPairs[0],
	&BoolCluster2Border,
	};

struct IntuiText NextDisk2Text =
	{
	1, 0, 
	JAM2,
	13, 11,
	&SafeFont,
	(UBYTE *)"DISK",
	NULL,
	};

struct IntuiText NextDiskText =
	{
	1, 0, 
	JAM2,
	13, 3,
	&SafeFont,
	(UBYTE *)"NEXT",
	&NextDisk2Text,
	};

struct IntuiText CancelText =
	{
	1, 0, 
	JAM2,
	5, 7,
	&SafeFont,
	(UBYTE *)"CANCEL",
	NULL,
	};

struct IntuiText OK2Text =
	{
	1, 0, 
	JAM2,
	17, 7,
	&SafeFont,
	(UBYTE *)"OK!",
	NULL,
	};


struct Gadget NextDiskGadget =
	{
	&BackdropGadget,
	197, 82 + REQTITLE_HEIGHT,
	57, 21,
	GADGHCOMP,	/* Flags */
	RELVERIFY,		/* Activation */
	REQGADGET | BOOLGADGET,		/* Type */
	(APTR)&BoolClusterBorder, 			/* GadgetRender */
	NULL,				/* SelectRender */
	&NextDiskText,
	NULL, NULL, 
	OPENGADGET_NEXTDISK, 
	NULL,
	};

struct Gadget CancelGadget =
	{
	&NextDiskGadget,
	114, 82 + REQTITLE_HEIGHT,
	57, 21,
	GADGHCOMP,	/* Flags */
	RELVERIFY | ENDGADGET,		/* Activation */
	REQGADGET | BOOLGADGET,		/* Type */
	(APTR)&BoolClusterBorder, 			/* GadgetRender */
	NULL,				/* SelectRender */
	&CancelText,
	NULL, NULL, 
	OPENGADGET_CANCEL,
	NULL,
	};

struct Gadget OKGadget =
	{
	&CancelGadget,
	32, 82 + REQTITLE_HEIGHT,
	57, 21,
	GADGHCOMP,		/* Flags */
	RELVERIFY | ENDGADGET,		/* Activation */
	REQGADGET | BOOLGADGET,		/* Type */
	(APTR)&BoolClusterBorder, 
	NULL,				/* Renders */
	&OK2Text,
	NULL, NULL, 
	OPENGADGET_OK, 
	NULL,
	};



/* === OpenUp ============================================================= */

struct Image OpenUpImage =
	{
	1, -1,
	15, 14,
	2,
	&OpenUpData[0],
	0x03, 0x00,
	NULL,
	};

struct Gadget OpenUpGadget =
	{
	&OKGadget,
	134, 14 + REQTITLE_HEIGHT,
	15, 12,
	GADGIMAGE | GADGHNONE,			  /* Flags */
	GADGIMMEDIATE,					  /* Activation */
	REQGADGET | BOOLGADGET,			 /* Type */
	(APTR)&OpenUpImage, 
	NULL,							   /* Renders */
	NULL,
	NULL, NULL, 
	OPENGADGET_UPGADGET, 
	NULL,
	};



/* === OpenDown =========================================================== */

struct Image OpenDownImage =
	{
	1, -1,
	15, 14,
	2,
	&OpenDownData[0],
	0x03, 0x00,
	NULL,
	};

struct Gadget OpenDownGadget =
	{
	&OpenUpGadget,
	134, 64 + REQTITLE_HEIGHT,
	15, 12,
	GADGIMAGE | GADGHNONE,			  /* Flags */
	GADGIMMEDIATE,						  /* Activation */
	REQGADGET | BOOLGADGET,			 /* Type */
	(APTR)&OpenDownImage, 
	NULL,							   /* Renders */
	NULL,
	NULL, NULL, 
	OPENGADGET_DOWNGADGET, 
	NULL,
	};


/* === OpenDrawerText ==================================================== */

struct StringInfo OpenDrawerTextInfo =
	{
	NULL, /* Must be supplied from the appropriate FileIOSupport structure */
	&OpenUndoBuffer[0],
	0,
	MAX_NAME_LENGTH,
	0,
	0,0,0,0,0,0,0,0,
	};

struct Gadget OpenDrawerTextGadget =
	{
	&OpenDownGadget,
	157, 41 + REQTITLE_HEIGHT,
	122, 10,
	GADGHCOMP,			   /* Flags */
	RELVERIFY | STRINGCENTER,			   /* Activation */
	REQGADGET | STRGADGET,			  /* Type */
	NULL, NULL,						 /* Renders */
	NULL,
	NULL,
	(APTR)&OpenDrawerTextInfo,
	OPENGADGET_DRAWERTEXT,
	NULL,
	};


/* === OpenDiskText ====================================================== */

struct StringInfo OpenDiskTextInfo =
	{
	NULL, /* Must be supplied from the appropriate FileIOSupport structure */
	&OpenUndoBuffer[0],
	0,
	MAX_NAME_LENGTH,
	0,
	0,0,0,0,0,0,0,0,
	};

struct Gadget OpenDiskTextGadget =
	{
	&OpenDrawerTextGadget,
	157, 65 + REQTITLE_HEIGHT,
	122, 10,
	GADGHCOMP,			   /* Flags */
	RELVERIFY | STRINGCENTER,			   /* Activation */
	REQGADGET | STRGADGET,			  /* Type */
	NULL, NULL,						 /* Renders */
	NULL,
	NULL,
	(APTR)&OpenDiskTextInfo,
	OPENGADGET_DISKTEXT,
	NULL,
	};



/* === OpenNameText ====================================================== */

struct StringInfo OpenNameTextInfo =
	{
	NULL, /* Must be supplied from the appropriate FileIOSupport structure */
	&OpenUndoBuffer[0],
	0,
	MAX_NAME_LENGTH,
	0,
	0,0,0,0,0,0,0,0,
	};

struct Gadget OpenNameTextGadget =
	{
	&OpenDiskTextGadget,
	157, 16 + REQTITLE_HEIGHT,
	122, 10,
	GADGHCOMP | SELECTED,			   /* Flags */
	RELVERIFY | ENDGADGET | STRINGCENTER,			   /* Activation */
	REQGADGET | STRGADGET,			  /* Type */
	NULL, NULL,						 /* Renders */
	NULL,
	NULL,
	(APTR)&OpenNameTextInfo,
	OPENGADGET_NAMETEXT,
	NULL,
	};


/* === OpenProp =========================================================== */
/* OpenPropData[] is in chipdata.c */

struct Image OpenPropImage =
	{
	1, 0,
	11, 8,
	2,
	&OpenPropData[0],
	0x03, 0x00,
	NULL,
	};

struct PropInfo OpenPropInfo =
	{
	FREEVERT | PROPBORDERLESS,
	0, 0,  /* Pots should be reinitialized on the fly */
	0, 0,  /* Bodies should be reinitialized on the fly */
	0, 0, 0, 0, 0, 0,
	};

struct Gadget OpenPropGadget =
	{
	&OpenNameTextGadget,
	136, 30 + REQTITLE_HEIGHT,	/* Left, Top */
	13, 30,		/* Width, Height */
	GADGIMAGE | GADGHNONE,		 /* Flags */
	GADGIMMEDIATE | RELVERIFY | FOLLOWMOUSE,  /* Activation */
	REQGADGET | PROPGADGET,				/* Type */
	(APTR)&OpenPropImage, 
	NULL,						  /* Renders */
	NULL,
	NULL, 
	(APTR)&OpenPropInfo, 
	OPENGADGET_PROPGADGET, 
	NULL,
	};





/* === OpenSelectName ==================================================== */

struct Gadget OpenSelectNameGadget =
	{
	&OpenPropGadget,
	OPENSELECT_LEFT, OPENSELECT_TOP,		/* Left, Top */
	OPENSELECT_WIDTH, OPENSELECT_HEIGHT,	/* Width, Height */
	GADGHNONE,								/* Flags */
	GADGIMMEDIATE,							/* Activation */
	REQGADGET | BOOLGADGET,					/* Type */
	NULL, NULL,								/* Renders */
	NULL,									/* Text */
	NULL, NULL, 
	OPENGADGET_SELECTNAME,
	NULL,
	};



/* === Requester Details ================================================= */
/* This data is used to render the requester more prettily. */

/* === Line Pairs === */
SHORT Req3BorderData[] =
	{
	  1, 0,
	OPEN_WIDTH - 2, 0,
	OPEN_WIDTH - 2, 1,
	OPEN_WIDTH - 1, 1,
	OPEN_WIDTH - 1, 108 + REQTITLE_HEIGHT,
	OPEN_WIDTH - 2, 108 + REQTITLE_HEIGHT,
	OPEN_WIDTH - 2, 109 + REQTITLE_HEIGHT,
	  1, 109 + REQTITLE_HEIGHT,
	  1, 108 + REQTITLE_HEIGHT,
	  0, 108 + REQTITLE_HEIGHT,
	  0, 1,
	  1, 1,
	  1, 0,
	};

SHORT Req2BorderData[] =
	{
	  1 + 1, 0 + 1,
	OPEN_WIDTH - 2 - 1, 0 + 1,
	OPEN_WIDTH - 2 - 1, 1 + 1,
	OPEN_WIDTH - 1 - 1, 1 + 1,
	OPEN_WIDTH - 1 - 1, 108 - 1 + REQTITLE_HEIGHT,
	OPEN_WIDTH - 2 - 1, 108 - 1 + REQTITLE_HEIGHT,
	OPEN_WIDTH - 2 - 1, 109 - 1 + REQTITLE_HEIGHT,
	  1 + 1, 109 - 1 + REQTITLE_HEIGHT,
	  1 + 1, 108 - 1 + REQTITLE_HEIGHT,
	  0 + 1, 108 - 1 + REQTITLE_HEIGHT,
	  0 + 1, 1 + 1,
	  1 + 1, 1 + 1,
	  1 + 1, 0 + 1,
	};

SHORT ReqBorderData[] =
	{
	  1 + 2, 0 + 2,
	OPEN_WIDTH - 2 - 2, 0 + 2,
	OPEN_WIDTH - 2 - 2, 1 + 2,
	OPEN_WIDTH - 1 - 2, 1 + 2,
	OPEN_WIDTH - 1 - 2, 108 - 2 + REQTITLE_HEIGHT,
	OPEN_WIDTH - 2 - 2, 108 - 2 + REQTITLE_HEIGHT,
	OPEN_WIDTH - 2 - 2, 109 - 2 + REQTITLE_HEIGHT,
	  1 + 2, 109 - 2 + REQTITLE_HEIGHT,
	  1 + 2, 108 - 2 + REQTITLE_HEIGHT,
	  0 + 2, 108 - 2 + REQTITLE_HEIGHT,
	  0 + 2, 1 + 2,
	  1 + 2, 1 + 2,
	  1 + 2, 0 + 2,
	};

SHORT SelectBorderData[] =
	{
	8,   14 + REQTITLE_HEIGHT,
	129, 14 + REQTITLE_HEIGHT,
	130, 15 + REQTITLE_HEIGHT,
	130, 74 + REQTITLE_HEIGHT,
	129, 75 + REQTITLE_HEIGHT,
	8,   75 + REQTITLE_HEIGHT,
	7,   74 + REQTITLE_HEIGHT,
	7,   15 + REQTITLE_HEIGHT,
	8,   14 + REQTITLE_HEIGHT,
	};

SHORT TextBorderData[] =
	{
	-1,  -2,
	120, -2,
	121, -1,
	121, 8,
	120, 9,
	-1,  9,
	-2,  8,
	-2,  -1,
	-1,  -2,
	};

SHORT PropBorderData[] =
	{
	0,  -3,
	16, -3,
	16, 32,
	0,  32,
	0,  -2,
	15, -2,
	15, -1,
	17, -1,
	17, 30,
	15, 30,
	15, 31,
	1,  31,
	1,  30,
	-1, 30,
	-1, -1,
	-1, 1,
	};


/* === Borders === */
struct Border Req3Border =
	{
	0, 0,
	1, 0,
	JAM1,
	13,
	&Req3BorderData[0],
	NULL,
	};

struct Border Req2Border =
	{
	0, 0,
	2, 0,
	JAM1,
	13,
	&Req2BorderData[0],
	&Req3Border,
	};

struct Border ReqBorder =
	{
	0, 0,
	1, 0,
	JAM1,
	13,
	&ReqBorderData[0],
	&Req2Border,
	};

struct Border SelectBorder =
	{
	0, 0,
	1, 0,
	JAM1,
	9,
	&SelectBorderData[0],
	&ReqBorder,
	};

struct Border Text3Border =
	{
	157, 65 + REQTITLE_HEIGHT,
	1, 0,
	JAM1,
	9,
	&TextBorderData[0],
	&SelectBorder,
	};

struct Border Text2Border =
	{
	157, 41 + REQTITLE_HEIGHT,
	1, 0,
	JAM1,
	9,
	&TextBorderData[0],
	&Text3Border,
	};

struct Border TextBorder =
	{
	157, 16 + REQTITLE_HEIGHT,
	1, 0,
	JAM1,
	9,
	&TextBorderData[0],
	&Text2Border,
	};

struct Border PropBorder =
	{
	134, 30 + REQTITLE_HEIGHT,
	1, 0,
	JAM1,
	16,
	&PropBorderData[0],
	&TextBorder,
	};

/* === RJ wants to know:  Some Requester Text For You? === */
UBYTE *DefaultReqTitle = (UBYTE *)"File IO Requester";
struct IntuiText ReqTitleText =
	{
	1, 0, 
	JAM2,
	0, 5,		/* The x-coordinate is initialized to center the title */
	&SafeFont,
	NULL,		/* Points to the title supplied in the FileIOSupport */
	NULL,
	};

struct IntuiText SelectText =
	{
	1, 0, 
	JAM2,
	18, 6 + REQTITLE_HEIGHT,
	&SafeFont,
	(UBYTE *)"Select a Name",
	&ReqTitleText,
	};

struct IntuiText Type3Text =
	{
	1, 0, 
	JAM2,
	201, 55 + REQTITLE_HEIGHT,
	&SafeFont,
	(UBYTE *)"Disk",
	&SelectText,
	};

struct IntuiText Type2Text =
	{
	1, 0, 
	JAM2,
	193, 31 + REQTITLE_HEIGHT,
	&SafeFont,
	(UBYTE *)"Drawer",
	&Type3Text,
	};

struct IntuiText TypeText =
	{
	1, 0, 
	JAM2,
	161, 6 + REQTITLE_HEIGHT,
	&SafeFont,
	(UBYTE *)"Or Type a Name",
	&Type2Text,
	};



/* === Main Data ======================================================== */
struct ReqSupport OpenReqSupport = 
	{

	/* struct Requester Requester; */
		{
		/*	struct Requester *OlderRequest;*/
		NULL,

		/*	SHORT LeftEdge, TopEdge;*/
		OPEN_LEFT, OPEN_TOP,

		/*	SHORT Width, Height;*/
		OPEN_WIDTH, OPEN_HEIGHT, 

		/*	SHORT RelLeft, RelTop;*/
		0, 0,

		/*	struct Gadget *ReqGadget;*/
		&OpenSelectNameGadget,
	
		/*	struct Border *ReqBorder;*/
		&PropBorder,
	
		/*	struct IntuiText *ReqText;*/
		&TypeText,
	
		/*	USHORT Flags;*/
		NOISYREQ,

		/*	UBYTE BackFill;*/
		0,

		/*	struct ClipRect ReqCRect;*/
		{ NULL },

		/*	struct BitMap *ImageBMap;*/
		NULL,

		/*	struct BitMap ReqBMap;*/
		{ NULL },

		},	/* end of Requester structure */

	/* struct Window *Window; */
	NULL,

	/* LONG (*StartRequest)(); */
	NULL,

	/* LONG (*ReqHandler)(); */
	NULL,

	/* LONG (*NewDiskHandler)(); */
	NULL,

	/* LONG (*KeyHandler)(); */
	NULL,

	/* LONG (*MouseMoveHandler)(); */
	NULL,

	/* SHORT SelectedGadgetID; */
	0,
};

struct Requester *OpenReq = NULL;
struct Window *OpenReqWindow = NULL;
struct FileIOSupport *OpenReqFileIO = NULL;
UBYTE OpenUndoBuffer[MAX_NAME_LENGTH];
UBYTE OpenLockName[128] = {0};

ULONG OpenSaveLock = NULL;

UBYTE CurrentDiskString[] = ":";

LONG OpenClickSeconds;
LONG OpenClickMicros;

