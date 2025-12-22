
#ifndef FILEIO_H
#define FILEIO_H


/* *** fileio.h *************************************************************
 *
 * Amiga Programmers' Suite  --  File IO Include File
 *     from Book 1 of the Amiga Programmers' Suite by RJ Mical
 *
 * Copyright (C) 1986, =Robert J. Mical=
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
 * 20 Oct 87    - RJ            Added RENAME_RAMDISK to fix what seems to 
 *                              be a bug in AmigaDOS.
 * 27 Sep 87    RJ              Removed reference to alerts.h, brought 
 *                              declarations into this file
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 14 Feb 86    =RJ Mical=      Created this file.
 *
 * *********************************************************************** */


#include <prosuite/prosuite.h>
#include <prosuite/pointers.h>
#include <prosuite/reqsupp.h>



/* === General FileIO Declarations ======================================= */
#define MAX_NAME_LENGTH 		64		/* Includes terminating NULL */
#define MAX_TOOLTYPE_LENGTH	80		/* Includes terminating NULL */
#define VISIBLE_SELECT_LENGTH	16		/* Buffer for visible chars + '\0' */

/* The WBENCH_CODE definition is used to define whether to include 
 * or not include the Workbench-style .info file pattern matching code.
 * If you intend on using Workbench pattern matching, or if you are 
 * going to give the user the option, define this constant.
 * This makes sure that the Workbench-style code is in included in the 
 * FileIO files when they are compiled.
 * To attempt to match Workbench patterns at run time, you must set 
 * the WBENCH_MATCH flag in your FileIOSupport structure.
 * 
 * If you aren't interested in Workbench-style pattern matching 
 * and are interested in saving about 500 bytes of code size, 
 * comment out the WBENCH_CODE definition.
 */
#define WBENCH_CODE



/* === FileIO Support Structure ========================================== */
struct FileIOSupport
	{
	SHORT Flags;

	UBYTE *ReqTitle;	/* The text that will be the requester's title */

	/* After a successful call to GetFileIOName(), these fields will have
	 * the names selected by the user.  You should never have to initialize
	 * these fields, only read from them, though initializing them won't hurt.
	 */
	UBYTE FileName[MAX_NAME_LENGTH];
	UBYTE DrawerName[MAX_NAME_LENGTH];
	UBYTE DiskName[MAX_NAME_LENGTH];

	/* If the LOCK_GOTTEN flag is set, the lock can be found here. */
	ULONG DOSLock;

	SHORT NameCount;
	SHORT NameStart;
	SHORT CurrentPick;
	struct Remember *NameKey;

	SHORT VolumeIndex;
	SHORT VolumeCount;
	struct Remember *VolumeKey;

	SHORT DiskObjectType;
	UBYTE ToolType[MAX_TOOLTYPE_LENGTH];

	LONG UserData;		/* Use this for anything you want */
	};


/* === User FileIO Flag Definitions === */
#define GOOD_FILENAMES		0x0001  /* Clear this if disk has changed */
#define USE_VOLUME_NAMES	0x0002  /* Use volume rather than device names */
#define DISK_HAS_CHANGED	0x0004  /* Disk changed during GetFileIOName() */
#define DOUBLECLICK_OFF		0x0008  /* Inhibit double-clicking */
#define WBENCH_MATCH		0x0010  /* If set check .info files only */
#define MATCH_OBJECTTYPE	0x0020  /* If set with .info check ObjectType */
#define MATCH_TOOLTYPE		0x0040  /* If set with .info check ToolType */
#define RENAME_RAMDISK		0x0080  /* If set, "RAM DISK:" becomes "RAM:" */

/* === System FileIO Flag Definitions === */
#define LOCK_GOTTEN			0x1000	/* Got lock, need to unlock */



/* === Name Table Entry Flags =========================================== */
/* The Name Table Entry consists of the text, null-terminated, followed by 
 * a byte of flag definitions.
 */
/* === Flags Definitions === */
#define NAMED_DIRECTORY	0x01
#define NAMED_PREVIOUS	0x02

#define DIR_TEXT_SIZE	3	/* Number of characters for "directory" mark */



/* === OpenRequester ===================================================== */
#define OPENGADGET_CANCEL		0x7FA0
#define OPENGADGET_OK			0x7FA1
#define OPENGADGET_NAMETEXT		0x7FA2
#define OPENGADGET_DRAWERTEXT	0x7FA3
#define OPENGADGET_DISKTEXT		0x7FA4
#define OPENGADGET_SELECTNAME	0x7FA5
#define OPENGADGET_UPGADGET		0x7FA6
#define OPENGADGET_DOWNGADGET	0x7FA7
#define OPENGADGET_PROPGADGET	0x7FA8
#define OPENGADGET_NEXTDISK		0x7FA9
#define OPENGADGET_BACKDROP		0x7FAA

#define NAME_ENTRY_COUNT	6	/* These many names in the SelectName box */

#define OPEN_NEXTDISK_COUNT	2

#define REQTITLE_HEIGHT			8

#define OPEN_LEFT				8
#define OPEN_TOP				15
#define OPEN_WIDTH				286
#define OPEN_HEIGHT				(110 + REQTITLE_HEIGHT)
#define OPEN_LINEHEIGHT			10

#define OPENSELECT_LEFT			8
#define OPENSELECT_TOP			(15 + REQTITLE_HEIGHT)
#define OPENSELECT_WIDTH		122
#define OPENSELECT_HEIGHT		60

#define OPENPROP_MAXHEIGHT		30
#define OPENPROP_TOPHEIGHT		2
#define OPENPROP_BOTTOMHEIGHT	6
#define OPENPROP_MINHEIGHT		8



/* === ALERT Definitions ================================================ */
#define ALERT_ABORT					0 /* Always zero! */
#define ALERT_NO_MEMORY				1 /* This and next are duplicates ... */
#define ALERT_OUTOFMEM				1 /* ... intentionally because I forget */
#define ALERT_BAD_DIRECTORY			2



/* === Function Declarations (in alphabetical order) ===================== */
UBYTE *AllocMem();
UBYTE *AllocRemember();

struct MsgPort *CreatePort();
UBYTE *CurrentVolumeName();

BOOL DirectoryName();
BOOL DoubleClick();

UBYTE *FindSuffix();
SHORT FriendlyInfoType();

struct DiskObject *GetDiskObject();
struct FileIOSupport *GetFileIOSupport();
BOOL GetFileIOName();
struct IntuiMessage *GetMsg();

SHORT HandleSelect();

SHORT MakeEntry();
BOOL MatchToolValue();
BOOL MessageInterrupt();

UBYTE *OpenLibrary();
struct Screen *OpenScreen();
struct Window *OpenWindow();

SHORT RemoveGadget();
BOOL Request();


/* === String Functions === */
SHORT CompareUpperStrings();
VOID ConcatString();
VOID CopyString();

UBYTE *FindSuffix();

SHORT IndexString();

SHORT StringLength();
BOOL StringsEqual();
UBYTE *StripLeadingSpace();
UBYTE *StripOuterSpace();



/* === And Finally, eglobfio inclusion ==================================== */
/* If this is a FileIO source file (as compared with a normal source 
 * from your own program), consider including eglobfio.c.
 */
#ifdef FILEIO_SOURCEFILE
#ifndef EGLOBAL_FILEIO_CANCEL
#include "eglobfio.c"
#endif /* ... end of EGLOBAL_FILEIO_CANCEL conditional */
#endif /* ... end of FILEIO_SOURCEFILE conditional */



#endif /* of FILEIO_H */

