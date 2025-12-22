
#ifndef EGLOBAL_FILEIO_C
#define EGLOBAL_FILEIO_C


/* *** eglobfio.c ***********************************************************
 *
 * File IO Suite  --  External Global Variable Definitions
 *     from Book 1 of the Amiga Programmers' Suite by RJ Mical
 *         (available soon if not already)
 *
 * Copyright (C) 1986, 1987, Robert J. Mical
 * All Rights Reserved.
 *
 * Created for Amiga developers.
 * Any or all of this code can be used in any program as long as this
 * entire copyright notice is retained, ok?
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
 * 27 Sep 87    RJ              Changed name of this file from eglobal.c
 * 4 Feb 87     RJ              Real release
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 3 May 86     RJ              Fix prop gadget for both 1.1 and 1.2
 * 1 Feb 86     =RJ Mical=      Created this file.
 *
 * *********************************************************************** */



/* === System Global Variables ========================================== */
extern struct IntuitionBase *IntuitionBase;
extern struct GfxBase *GfxBase;
extern struct DosLibrary *DosBase;
extern struct IconBase *IconBase;

extern struct TextAttr SafeFont;
extern struct Gadget OKGadget, CancelGadget;



/* === Open Requester Declarations ======================================= */
/* The global declaration of these can be found in opendata.c */
extern struct Requester *OpenReq;
extern struct ReqSupport OpenReqSupport;
extern struct Window *OpenReqWindow;
extern struct FileIOSupport *OpenReqFileIO;

extern struct StringInfo OpenNameTextInfo;
extern struct StringInfo OpenDrawerTextInfo;
extern struct StringInfo OpenDiskTextInfo;
extern struct Gadget OpenNameTextGadget;
extern struct Gadget OpenDiskTextGadget;
extern struct Gadget OpenDrawerTextGadget;
extern struct PropInfo OpenPropInfo;
extern struct Image OpenPropImage;
extern struct Gadget OpenSelectNameGadget;

extern UBYTE OpenUndoBuffer[];
extern UBYTE OpenSelectBuffers[NAME_ENTRY_COUNT][VISIBLE_SELECT_LENGTH];
extern struct IntuiText OpenSelectText[NAME_ENTRY_COUNT];
extern UBYTE OpenLockName[];

extern struct IntuiText ReqTitleText;
extern UBYTE *DefaultReqTitle;

extern ULONG OpenSaveLock;

extern UBYTE CurrentDiskString[];

extern LONG OpenClickSeconds;
extern LONG OpenClickMicros;

/* The global declaration of these can be found in chipdata.c */
extern USHORT OpenUpData[];
extern USHORT OpenDownData[];
extern USHORT OpenPropData[];
extern USHORT OpenPropTop[];
extern USHORT OpenPropBottom[];



#endif /* of EGLOBAL_FILEIO_C */

