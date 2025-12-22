
/* *** filesupp.c ***********************************************************
 *
 * File IO Suite  --  Open Requester Routines
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
 * 20 Oct 87    - RJ            Added RENAME_RAMDISK to fix what seems to 
 *                              be a bug in either AmigaDOS or Workbench.
 * 27 Sep 87    RJ              In order to show the correct DiskName during
 *                              WarmStartFileIO(), that routine now 
 *                              refreshes the gadgets both before and after 
 *                              the BuildNameTable() process.
 * 4 Feb 87     RJ              Real release
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 3 May 86     =RJ Mical=      Fix prop gadget for both 1.1 and 1.2
 * 1 Feb 86     =RJ Mical=      Created this file.
 *
 * *********************************************************************** */


#define FILEIO_SOURCEFILE
#include "fileio.h"


/* I think these are silly, but I put them here anyway to avoid compiler
 * warnings.
 */
VOID InitOpenProp();
VOID StuffSelectNames();



/* ======================================================================= */
/* === ResetText Routines ================================================ */
/* ======================================================================= */

VOID ResetTextGrunt(info, resetbuffer)
struct StringInfo *info;
BOOL resetbuffer;
/* Reset the string position variables, and reset the buffer itself if
 * resetbuffer is TRUE.
 */
{
	info->BufferPos = info->DispPos = 0;
	if (resetbuffer) info->Buffer[0] = '\0';
}

VOID ResetNameText(resetbuffer)
BOOL resetbuffer;
{
	ResetTextGrunt(&OpenNameTextInfo, resetbuffer);
}

VOID ResetDrawerText(resetbuffer)
BOOL resetbuffer;
{
	ResetTextGrunt(&OpenDrawerTextInfo, resetbuffer);
}

VOID ResetDiskText(resetbuffer)
BOOL resetbuffer;
{
	ResetTextGrunt(&OpenDiskTextInfo, resetbuffer);
}



/* ======================================================================= */
/* === WarmStart Initializer ============================================= */
/* ======================================================================= */

VOID WarmStartFileIO(fileio)
struct FileIOSupport *fileio;
/* This routine establishes a lock on the current disk and drawer,
 * resets all of the subsystem control variables,
 * gets the file names for the current disk and drawer,
 * initializes the proportional gadget,
 * and then refreshes the requester.
 */
{
	ULONG lock;

	/* If the fileio already had a lock, release it before proceeding */
	if (FlagIsSet(fileio->Flags, LOCK_GOTTEN))
		{
		UnLock(fileio->DOSLock);
		ClearFlag(fileio->Flags, LOCK_GOTTEN);
		fileio->DOSLock = OpenSaveLock;
		CurrentDir(OpenSaveLock);
		}

	/* Build the lock name using the current disk and drawer names */
	if (StringLength(&fileio->DiskName[0]))
		CopyString(&OpenLockName[0], &fileio->DiskName[0]);
	else
		CopyString(&OpenLockName[0], CurrentVolumeName());

	/* If the programmer wants us to sidestep the "RAM DISK:" bug, 
	 * then by all means oblige her or him.
	 */
	if (FlagIsSet(fileio->Flags, RENAME_RAMDISK) 
			&& CompareUpperStrings(&OpenLockName[0], 
			"RAM DISK:") == 0)
		{
		/* Everyone seems suspicious of "RAM Disk:" */
		OpenLockName[3] = ':';
		OpenLockName[4] = '\0';
		}

	ConcatString(&OpenLockName[0], &fileio->DrawerName[0]);

	/* Can we get a lock on this name? */
	if (lock = Lock(&OpenLockName[0], ACCESS_READ))
		{
		/* Got it! */
		SetFlag(fileio->Flags, LOCK_GOTTEN);
		fileio->DOSLock = lock;
		CurrentDir(lock);
		}
	else
		{
		/* Hey, bad break, this name just won't do.  But the rest of these
		 * routines need a valid directory, so go back home.
		 */
		Alert(ALERT_BAD_DIRECTORY, OpenReqWindow);
		CopyString(&fileio->DiskName[0], &CurrentDiskString[0]);
		ResetDiskText(FALSE);
		ResetDrawerText(TRUE);
		}

	/* Reset the fileio name selection variables */
	fileio->CurrentPick = -1;
	fileio->NameStart = 0;
	fileio->NameCount = 0;

	/* Reset the text and gadgets */
	InitOpenProp(TRUE);				/* Initialize the prop gadget */
	StuffSelectNames(-1);			/* Display all of the names */
	BuildNameTable(OpenReqFileIO);	/* Get the file names */
	StuffSelectNames(1);			/* Display the file names */
}



/* ======================================================================= */
/* === Select Name Routines ============================================== */
/* ======================================================================= */

VOID BlankSelectText(index)
SHORT index;
/* This routine truns the SelectText at index into blanks */
{
	UBYTE *ptr;
	SHORT blanklength;

	ptr = &OpenSelectBuffers[index][0];
	for (blanklength = VISIBLE_SELECT_LENGTH - 1; blanklength; blanklength--)
		*ptr++ = ' ';
	*ptr = '\0';

	OpenSelectText[index].FrontPen = 1;
	OpenSelectText[index].BackPen = 0;
}



VOID DrawSelectNames()
{
	struct Layer *layer;

	Forbid();
	if (layer = OpenReq->ReqLayer)
		if (layer->rp)
			PrintIText(layer->rp,
					&OpenSelectText[NAME_ENTRY_COUNT - 1], 
					OPENSELECT_LEFT, OPENSELECT_TOP);
	Permit();
}



VOID StuffSelectNames(refreshcount)
SHORT refreshcount;
/* This routine stuffs the Open Requester's filename gadgets with
 * names from the fileio structure, starting from the 
 * fileio->NameStart name.  If the refreshcount is nonzero, the gadgets
 * will be refreshed too.
 */
{
	SHORT i, end, bufferpos;
	SHORT length, blanklength;
	UBYTE *ptr, *ptr2;
	struct Remember *remember;
	struct Layer *layer;

	if (OpenReqFileIO->NameCount 
			> OpenReqFileIO->NameStart + NAME_ENTRY_COUNT) 
		end = OpenReqFileIO->NameStart + NAME_ENTRY_COUNT;
	else end = OpenReqFileIO->NameCount;

	bufferpos = 0;

	/* The current file names are stored in the fileio's Remember list */
	remember = OpenReqFileIO->NameKey;
	for (i = 0; i < OpenReqFileIO->NameStart; i++) 
		remember = remember->NextRemember;

	for (i = OpenReqFileIO->NameStart; i < end; i++) 
		{
		ptr = &OpenSelectBuffers[bufferpos][0];
		ptr2 = remember->Memory;

		length = StringLength(ptr2);
		if (length >= VISIBLE_SELECT_LENGTH)
			length = VISIBLE_SELECT_LENGTH - 1;
		blanklength = (VISIBLE_SELECT_LENGTH - 1) - length;

		/* By filling up the IntuiText with blanks after the characters,
		 * the text, when printed, will overstrike any characters that were 
		 * there before.
		 */
		for ( ; length; length--) *ptr++ = *ptr2++;
		for ( ; blanklength; blanklength--) *ptr++ = ' ';
		*ptr = '\0';

		/* If this is the selected text, then use "highlight" pens */
		if (i == OpenReqFileIO->CurrentPick)
			{
			OpenSelectText[bufferpos].FrontPen = -2;
			OpenSelectText[bufferpos].BackPen = -1;
			}
		else
			{
			OpenSelectText[bufferpos].FrontPen = 1;
			OpenSelectText[bufferpos].BackPen = 0;
			}

		bufferpos++;
		remember = remember->NextRemember;
		}

	/* Now, for all lines that have no entries, fill with blanks */
	for ( ; bufferpos < NAME_ENTRY_COUNT; bufferpos++)
		BlankSelectText(bufferpos);

	/* Finally, redraw the lot */
	if (refreshcount)
		{
		Forbid();
		if (layer = OpenReq->ReqLayer)
			if (layer->rp)
				RefreshGList(&OpenSelectNameGadget, OpenReqWindow, OpenReq,
						refreshcount);
		DrawSelectNames();
		Permit();
		}
}



VOID SetNameStart()
/* This little guy sets the NameStart based on the current
 * prop gadget setting.
 */
{
	if (OpenReqFileIO->NameCount <= NAME_ENTRY_COUNT)
		OpenReqFileIO->NameStart = 0;
	else
		OpenReqFileIO->NameStart = (OpenPropInfo.VertPot 
				* (OpenReqFileIO->NameCount - NAME_ENTRY_COUNT + 1)) >> 16;
}



VOID StripLastDrawer()
/* This guy strips the end drawer reference off of the drawer string,
 * which includes nulling out the string if there's only one to strip.
 */
{
	UBYTE *ptr;
	SHORT index;

	ptr = OpenDrawerTextInfo.Buffer;
	index = IndexString(ptr, "/");
	if (index != -1)
		{
		/* OK, there's more than one drawer reference, so get the ptr + index
		 * to the last one.
		 */
		do 
			ptr += (index + 1);
		while ((index = IndexString(ptr, "/")) != -1);
		}
	else index = 0;
	/* Zammo! */
	*(ptr + index) = '\0';
}



BOOL DirectoryName()
/* Returns TRUE if the selected name was a directory-type reference
 * (up or down), else returns FALSE for a normal filename.
 */
{
	struct Remember *nextentry;
	SHORT i;
	UBYTE entryflags;

	if (OpenReqFileIO->NameCount)
		{
		/* Find the selected entry in the key list */
		nextentry = OpenReqFileIO->NameKey;
		for (i = OpenReqFileIO->CurrentPick; i > 0; i--)
			nextentry = nextentry->NextRemember;
		i = StringLength(nextentry->Memory) + 1;
		entryflags = *(nextentry->Memory + i);

		if (FlagIsSet(entryflags, NAMED_DIRECTORY | NAMED_PREVIOUS))
			return(TRUE);

		/* else just a normal file name was selected, so fall out to ... */
		}
	return(FALSE);
}



VOID StuffFileName()
/* If the selected name is a normal filename, stuffs the filename into the
 * Name gadget.  If the selected name is a directory reference,
 * adjusts the drawer gadget accordingly.
 * Returns TRUE if the selected name was a directory-type reference
 * (up or down), else returns FALSE for a normal filename.
 */
{
	struct Remember *nextentry;
	SHORT i;
	UBYTE entryflags;

	if (OpenReqFileIO->NameCount)
		{
		/* Find the selected entry in the key list */
		nextentry = OpenReqFileIO->NameKey;
		for (i = OpenReqFileIO->CurrentPick; i; i--)
			nextentry = nextentry->NextRemember;
		i = StringLength(nextentry->Memory) + 1;
		entryflags = *(nextentry->Memory + i);

		if (FlagIsSet(entryflags, NAMED_DIRECTORY))
			{
			/* If there's already a drawer reference, build a proper
			 * extension before adding the new to the end.
			 */
			if (StringLength(OpenDrawerTextInfo.Buffer))
				ConcatString(OpenDrawerTextInfo.Buffer, "/");

	 		ConcatString(OpenDrawerTextInfo.Buffer,
					nextentry->Memory + DIR_TEXT_SIZE);

			ResetDrawerText(FALSE);
			ResetNameText(TRUE);
			}
		else if (FlagIsSet(entryflags, NAMED_PREVIOUS))
			{
			/* Remove the last drawer reference */
			StripLastDrawer();
			ResetDrawerText(FALSE);
			ResetNameText(TRUE);
			}
		else
			{
			/* Just a normal old file name was selected */
	 		CopyString(OpenNameTextInfo.Buffer, nextentry->Memory);
			ResetNameText(FALSE);
			}
		}
}



/* ======================================================================= */
/* === Proportional Gadget Routines ====================================== */
/* ======================================================================= */

VOID SetOpenPropPot(resetpos)
BOOL resetpos;
/* This routine resets the vertical pot of the proportional gadget
 * with respect to the current number of displayable file names.
 */
{
	LONG slack, result;

	slack = OpenReqFileIO->NameCount - NAME_ENTRY_COUNT;

	if (slack > 0)
		{
		result = ((LONG)OpenReqFileIO->NameStart << 16) / slack;
		if (result > 0xFFFF) result = 0xFFFF;
		OpenPropInfo.VertPot = result;
		}
	else
		OpenPropInfo.VertPot = 0;

	if (resetpos) OpenPropImage.TopEdge = 0;
}



VOID InitOpenProp(resetpos)
BOOL resetpos;
/* This routine initializes the variable imagery of the proportional
 * gadget and then initializes the gadget's vertical pot.
 * The BOOL arg resetpos describes whether you want the call to 
 * SetOpenPropPot() to reset the prop's knob position.
 */
{
	LONG namecount, height;
	SHORT i, i2;

	namecount = OpenReqFileIO->NameCount;

	if (namecount <= NAME_ENTRY_COUNT)
		{
		OpenPropInfo.VertBody = 0xFFFF;
		ClearFlag(OpenPropInfo.Flags, FREEVERT);
		height = OPENPROP_MAXHEIGHT;
		}
	else
		{
		OpenPropInfo.VertBody = ((LONG)NAME_ENTRY_COUNT << 16) / namecount;
		SetFlag(OpenPropInfo.Flags, FREEVERT);
		height = (OPENPROP_MAXHEIGHT * NAME_ENTRY_COUNT)  / namecount;
		if (height < OPENPROP_MINHEIGHT) height = OPENPROP_MINHEIGHT;
		}

	OpenPropImage.Height = height;
	for (i = 0; i < OPENPROP_TOPHEIGHT; i++)
		{
		OpenPropData[i] = OpenPropTop[i];
		OpenPropData[i + height] = OpenPropTop[i + OPENPROP_TOPHEIGHT];
		}

	for (i = OPENPROP_TOPHEIGHT; i < height - OPENPROP_BOTTOMHEIGHT; i++)
		{
		OpenPropData[i] = OpenPropBottom[0];
		OpenPropData[i + height] = OpenPropBottom[OPENPROP_BOTTOMHEIGHT];
		}

	i2 = 0;
	for (i = height - OPENPROP_BOTTOMHEIGHT; i < height; i++)
		{
		OpenPropData[i] = OpenPropBottom[i2];
		OpenPropData[i + height] = OpenPropBottom[i2 + OPENPROP_BOTTOMHEIGHT];
		i2++;
		}

	SetOpenPropPot(resetpos);
}




/* ======================================================================= */
/* === Requester Handler Routines ======================================== */
/* ======================================================================= */

VOID StartOpenRequester()
/* Called after the requester has been opened. */
{
	ActivateGadget(&OpenNameTextGadget, OpenReqWindow, OpenReq);

	if (FlagIsClear(OpenReqFileIO->Flags, GOOD_FILENAMES))
		WarmStartFileIO(OpenReqFileIO);
	else DrawSelectNames();
}



SHORT HandleSelect(y, seconds, micros)
SHORT y;
LONG seconds, micros;
/* This routine accepts that a GADGETDOWN occured at the given 
 * pointer y offset.  This is translated into the ordinal number of the 
 * filename selected by the user, and this is assigned to the 
 * CurrentPick variable of the OpenReqFileIO structure.
 * Returns:
 *     1 = DirectoryName() returned TRUE (selection was directory name)
 *     0 = new name selected, DirectoryName() returned FALSE (normal name)
 *    -1 = same name selected, double-clicked
 *    -2 = same name selected, not double-clicked
 */
{
	SHORT returnvalue, oldy;
	LONG oldseconds, oldmicros;

	y -= (OpenReq->TopEdge + OPENSELECT_TOP);
	y = y / OPEN_LINEHEIGHT;
	y += OpenReqFileIO->NameStart;
	if (y >= OpenReqFileIO->NameCount)
		y = OpenReqFileIO->NameCount - 1;

	oldseconds = OpenClickSeconds;
	oldmicros = OpenClickMicros;
	OpenClickSeconds = seconds;
	OpenClickMicros = micros;

	oldy = OpenReqFileIO->CurrentPick;
	OpenReqFileIO->CurrentPick = y;

	if (DirectoryName())
		{
		returnvalue = 1;
		}
	else
		{
		if (y == oldy)
			{
			/* User has selected the same name again.
			 * Was it done quickly enough to count as a
			 * double-click selection?
			 */
			if (FlagIsClear(OpenReqFileIO->Flags, DOUBLECLICK_OFF)
					&& DoubleClick(oldseconds, oldmicros,
							OpenClickSeconds, OpenClickMicros))
				returnvalue = -1;
			else returnvalue = -2;
			}
		else
			{
			/* Do this work, what there is of it, only if the user 
			 * hasn't reselected an already-selected name.
			 */
			returnvalue = 0;
			}
		}

	return(returnvalue);
}



LONG HandleGadget(gadget, x, y, seconds, micros)
struct Gadget *gadget;
SHORT x, y;
LONG seconds, micros;
/* This routine handles one gadget selection */
{
	BOOL softbuild, hardbuild;
	SHORT count;
	LONG returnvalue;

	/* softbuild causes the file names to be refreshed.
	 * hardbuild causes the entire requester to be reestablished.
	 * either or both can be set.
	 */
	softbuild = hardbuild = FALSE;

	/* count refers to the count that will be sent to StuffSelectNames().
	 * The default is 2, as you can see.
	 */
   count = 2;

	/* If the selection of any gadget causes us to want the requester to
	 * go away, set the returnvalue non-zero.
	 */
	returnvalue = 0;

	switch (gadget->GadgetID)
		{
		case OPENGADGET_SELECTNAME:
			if (OpenReqFileIO->NameCount)
				{
				/* So our big name gadget was selected, eh?  Well, which one 
				 * was the user really pointing at?
				 */
				y = HandleSelect(y, seconds, micros);
				if (y < 0)
					{
					/* The user has reselected the old name */
					if (y == -1) returnvalue = -1;
					}
				else
					{
					/* The user has selected a new name */
					StuffFileName();
					softbuild = TRUE;
					if (y == 1) hardbuild = TRUE;
					count = 5;
					}
				}
			break;
		case OPENGADGET_UPGADGET:
			if (OpenReqFileIO->NameStart)
				{
				OpenReqFileIO->NameStart--;
				softbuild = TRUE;
				}
			break;
		case OPENGADGET_DOWNGADGET:
			if (OpenReqFileIO->NameStart + NAME_ENTRY_COUNT
					< OpenReqFileIO->NameCount)
				{
				OpenReqFileIO->NameStart++;
				softbuild = TRUE;
				}
			break;
		case OPENGADGET_PROPGADGET:
			if (OpenReqFileIO->NameCount > NAME_ENTRY_COUNT)
				{
				SetNameStart();
				softbuild = TRUE;
				}
			break;
		case OPENGADGET_NEXTDISK:
			/* Next disk!  Wholly mackerel!  First, if no "next" then split */
			if (OpenReqFileIO->VolumeCount <= 1) break;

			OpenReqFileIO->VolumeIndex++;
			if (OpenReqFileIO->VolumeIndex >= OpenReqFileIO->VolumeCount)
				OpenReqFileIO->VolumeIndex = 0;
			CopyString(&OpenReqFileIO->DiskName[0], CurrentVolumeName());
			ResetDiskText(FALSE);
			ResetDrawerText(TRUE);

			/* Refresh the display so the user can see what's been done, as
			 * well as having the display refreshed all over again (hardbuild)
			 * below after the new filenames are retrieved.
			 */
			softbuild = TRUE;
			count = 5;

			/* Intentionally fall into DRAWER/DISKTEXT */

		case OPENGADGET_DRAWERTEXT:
		case OPENGADGET_DISKTEXT:
			ResetNameText(TRUE);
			hardbuild = TRUE;
			break;
		default:
			break;
		}

	/* These are split intentionally, because setters of hardbuild might
	 * want a softbuild done first, to show why a hardbuild is being done!
	 */
	if (hardbuild) SetWaitPointer(OpenReqWindow);
	if (softbuild)
		{
		SetOpenPropPot();
		StuffSelectNames(count);
		}
	if (hardbuild)
		WarmStartFileIO(OpenReqFileIO);	/* Restart the lock etc. */

	return(returnvalue);
}



VOID DiskInserted()
/* This routine is called by the RequesterSupport code whenever a new disk
 * has been inserted.  This allows the user to swap disks while the
 * requester is displayed.  Unfortunately, I have no way of knowing which
 * disk swapped, so I have to restart the requester more or less.
 * Not too bad, but a little unpleasant.
 */
{
	SetWaitPointer(OpenReqWindow);
	SetFlag(OpenReqFileIO->Flags, DISK_HAS_CHANGED);
	BuildVolumeTable(OpenReqFileIO);
	CopyString(&OpenReqFileIO->DiskName[0], CurrentVolumeName());
	WarmStartFileIO(OpenReqFileIO);
}



VOID PropMouseMoves()
/* This routine is called by RequesterSupport whenever the mouse moves
 * while a FOLLOWMOUSE gadget is set.  The only FOLLOWMOUSE gadget is
 * the prop gadget, so...
 */
{
	/* ... if there's more names than the number of visible names,
	 * then reset the name start and redisplay the names.
	 */
	if (OpenReqFileIO->NameCount > NAME_ENTRY_COUNT)
		{
		SetNameStart();
		StuffSelectNames(2);
		}
}

