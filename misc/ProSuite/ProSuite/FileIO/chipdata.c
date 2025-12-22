
/* *** chipdata.c ***********************************************************
 *
 * File IO Suite  --  Chip Memory Data Declarations
 *     from Book 1 of the Amiga Programmers' Suite by RJ Mical
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
 * 4 Feb 87     RJ              Real release
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 3 May 86     =RJ Mical=      Fix prop gadget for both 1.1 and 1.2
 * 1 Feb 86     =RJ Mical=      Created this file.
 *
 * *********************************************************************** */


#define FILEIO_SOURCEFILE
/* This prevents eglobfio.c from being included */
#define EGLOBAL_FILEIO_CANCEL
#include "fileio.h"



/* === WaitPointer Imagery =============================================== */
USHORT ElecArtsWaitPointer[(ELECARTSPOINT_HEIGHT * 2) + 4] =
	{
	0x0000, 0x0000,

	0x6700, 0xC000,
	0xCFA0, 0xC700,
	0xBFF0, 0x0FA0,
	0x70F8, 0x3FF0,
	0x7DFC, 0x3FF8,
	0xFBFC, 0x7FF8,
	0x70FC, 0x3FF8,
	0x7FFE, 0x3FFC,
	0x7F0E, 0x3FFC,
	0x3FDF, 0x1FFE,
	0x7FBE, 0x3FFC,
	0x3F0E, 0x1FFC,
	0x1FFC, 0x07F8,
	0x07F8, 0x01E0,
	0x01E0, 0x0080,
	0x07C0, 0x0340,
	0x0FE0, 0x07C0,
	0x0740, 0x0200,
	0x0000, 0x0000,
	0x0070, 0x0020,
	0x0078, 0x0038,
	0x0038, 0x0010,

	0x0000, 0x0000,
	};



/* === Open Requester Imagery ============================================ */
USHORT OpenPropData[OPENPROP_MAXHEIGHT * 2];

USHORT OpenPropTop[OPENPROP_TOPHEIGHT * 2] =
	{
	/* plane 0 */
	0x7FC0,
	0xE0E0,

	/* plane 1 */
	0x0000,
	0x1F00,
	};


USHORT OpenPropBottom[OPENPROP_BOTTOMHEIGHT * 2] =
	{
	/* plane 0 */
	0xC060,
	0xC060,
	0xC060,
	0xC060,
	0xE0E0,
	0x7FC0,

	/* plane 1 */
	0x3F80,
	0x3F80,
	0x3F80,
	0x3F80,
	0x1F00,
	0x0000,
	};


USHORT OpenUpData[] =
	{
	/* plane 0 */
	0x0100,
	0x739C,
	0x87C2,
	0x8FE2,
	0x9FF2,
	0xBFFA,
	0x8382,
	0x8382,
	0x8382,
	0x8382,
	0x8382,
	0x7BBC,
	0x0380,
	0x0380,

	/* plane 1 */
	0x0000,
	0x0000,
	0x600C,
	0x4004,
	0x0000,
	0x0000,
	0x0000,
	0x783C,
	0x783C,
	0x783C,
	0x783C,
	0x0000,
	0x0000,
	0x0000,
	};

USHORT OpenDownData[] =
	{
	/* plane 0 */
	0x0380,
	0x0380,
	0x7BBC,
	0x8382,
	0x8382,
	0x8382,
	0x8382,
	0x8382,
	0xBFFA,
	0x9FF2,
	0x8FE2,
	0x87C2,
	0x739C,
	0x0100,

	/* plane 1 */
	0x0000,
	0x0000,
	0x0000,
	0x783C,
	0x783C,
	0x783C,
	0x783C,
	0x0000,
	0x0000,
	0x0000,
	0x4004,
	0x600C,
	0x0000,
	0x0000,
	};

