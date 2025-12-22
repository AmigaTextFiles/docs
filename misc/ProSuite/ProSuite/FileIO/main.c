
/* *** main.c ***************************************************************
 *
 * File IO Suite  --  Example Main 
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
#include "fileio.h"


BOOL TestFileIO();


struct NewScreen NewFileIOScreen =
	{
	0, 0,	/* LeftEdge, TopEdge */
	320, 200, /* Width, Height */
	2, /* Depth */
	0, 1,	/* Detail/BlockPens */
	NULL,	/* ViewPort Modes (must set/clear HIRES as needed) */
	CUSTOMSCREEN,
	&SafeFont,	/* Font */
	(UBYTE *)"Example FileIO Program's Screen",
	NULL,	/* Gadgets */
	NULL,	/* CustomBitMap */
	};

struct NewWindow NewFileIOWindow =
	{
	0, 12,					/* LeftEdge, TopEdge */
	320, 150, 			/* Width, Height */
	-1, -1,				/* Detail/BlockPens */
	NEWSIZE | MOUSEBUTTONS | VANILLAKEY | MENUPICK | CLOSEWINDOW
			| DISKINSERTED,
							/* IDCMP Flags */
	WINDOWSIZING | WINDOWDRAG | WINDOWDEPTH | WINDOWCLOSE
			| SIZEBRIGHT | SMART_REFRESH | RMBTRAP | ACTIVATE | NOCAREREFRESH,
							/* Window Specification Flags */
	NULL,					/* FirstGadget */
	NULL,					/* Checkmark */
	(UBYTE *)"FileIO Requester Window",  /* WindowTitle */
	NULL,					/* Screen */
	NULL,					/* SuperBitMap */
	96, 30,				/* MinWidth, MinHeight */
	640, 200,			/* MaxWidth, MaxHeight */
	WBENCHSCREEN,
	};



VOID main(argc, argv)
LONG argc;
char **argv;
{
	struct Screen *screen;
	struct Window *window;
	struct FileIOSupport *fileio1, *fileio2;
	BOOL mainswitch, ioswitch, mainsuccess;
	LONG class;
	struct IntuiMessage *message;
	SHORT pick;

	mainsuccess = FALSE;

	screen = NULL;
	window = NULL;
	fileio1 = fileio2 = NULL;

	IntuitionBase = (struct IntuitionBase *)
			OpenLibrary("intuition.library", 0);
	GfxBase = (struct GfxBase *)OpenLibrary("graphics.library", 0);
	DosBase = (struct DosLibrary *)OpenLibrary("dos.library", 0);
	IconBase = (struct IconBase *)OpenLibrary("icon.library", 0);

	if ( (IntuitionBase == NULL)
			|| (GfxBase == NULL)
			|| (DosBase == NULL)
			|| (IconBase == NULL) )
		goto MAIN_DONE;

	if (argv)
		{
		/* OK, we started from CLI */
		if (argc > 1)
			{
			if (screen = OpenScreen(&NewFileIOScreen))
				{
				NewFileIOWindow.Screen = screen;
				NewFileIOWindow.Type = CUSTOMSCREEN;
				}
			}
		}

	window = OpenWindow(&NewFileIOWindow);

	fileio1 = GetFileIOSupport();
	fileio2 = GetFileIOSupport();

	if ((window == NULL) || (fileio1 == NULL) || (fileio2 == NULL))
		goto MAIN_DONE;

	SetFlag(fileio2->Flags, WBENCH_MATCH | MATCH_OBJECTTYPE);
	fileio2->DiskObjectType = WBTOOL;
	fileio2->ReqTitle = (UBYTE *)"- Workbench Tools and Drawers -";

	SetAPen(window->RPort, 1);
	Move(window->RPort, 25, 40);
	Text(window->RPort, "= Click for FileIO Requester =", 30);

	mainswitch = TRUE;
	pick = 0;

	while (mainswitch)
		{
		WaitPort(window->UserPort);

		ioswitch = FALSE;
		while (message = GetMsg(window->UserPort))
			{
			class = message->Class;
			ReplyMsg(message);

			switch (class)
				{
				case CLOSEWINDOW:
					mainswitch = FALSE;
					break;
				case DISKINSERTED:
					/* You should clear the GOOD_FILENAMES flag whenever you
					 * detect that a new disk was inserted.
					 */
					ClearFlag(fileio1->Flags, GOOD_FILENAMES);
					ClearFlag(fileio2->Flags, GOOD_FILENAMES);

					/* While I'm here, I'll demo another feature for you. */
					ToggleFlag(fileio1->Flags, USE_VOLUME_NAMES);
					ToggleFlag(fileio2->Flags, USE_VOLUME_NAMES);

					break;
				default:
					/* If any other event occurs, bring up that old requester! */
					ioswitch = TRUE;
					break;
				}
			}

		if (ioswitch)
			{
			if (pick == 0)
				{
				if (TestFileIO(fileio1, window))
					/* Oops, disk swapped, so restart the other */
					ClearFlag(fileio2->Flags, GOOD_FILENAMES);
				}
			else
				{
				if (TestFileIO(fileio2, window))
					/* Oops, disk swapped, so restart the other */
					ClearFlag(fileio1->Flags, GOOD_FILENAMES);
				}
			pick = 1 - pick;
			}
		}

	mainsuccess = TRUE;

MAIN_DONE:
	if (NOT mainsuccess) Alert(ALERT_NO_MEMORY, NULL);

	if (fileio1) ReleaseFileIO(fileio1);
	if (fileio2) ReleaseFileIO(fileio2);

	if (window) CloseWindow(window);
	if (screen) CloseScreen(screen);

	if (IntuitionBase) CloseLibrary(IntuitionBase);
	if (GfxBase) CloseLibrary(GfxBase);
	if (DosBase) CloseLibrary(DosBase);
	if (IconBase) CloseLibrary(IconBase);
}



BOOL TestFileIO(fileio, window)
struct FileIOSupport *fileio;
struct Window *window;
/* This guy calls GetFileIOName(), displays the file name selected by the
 * user, and returns TRUE if the user swapped disks during GetFileIOName()
 * (else returns FALSE)
 */
{
	UBYTE name[80];

	if (GetFileIOName(fileio, window))
		{
		/* If user was positive, display the name */
		CopyString(&name[0], "[");
		BuildFileIOPathname(fileio, &name[1]);
		ConcatString(&name[0], "]");
		AlertGrunt(&name[0], window);
		}

	if (FlagIsSet(fileio->Flags, DISK_HAS_CHANGED))
		{
		ClearFlag(fileio->Flags, DISK_HAS_CHANGED);
		return(TRUE);
		}
	else return(FALSE);
}

