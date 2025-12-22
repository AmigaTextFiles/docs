
/* *** filename.c ***********************************************************
 *
 * File IO Suite  --  File Name Construction Routines
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
 * 4 Feb 87     RJ              Real release
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 3 May 86     =RJ Mical=      Fix prop gadget for both 1.1 and 1.2
 * 1 Feb 86     =RJ Mical=      Created this file.
 *
 * *********************************************************************** */


#define FILEIO_SOURCEFILE
#include "fileio.h"
#include <libraries/dosextens.h>


#define FRIENDLY_NOT		0
#define FRIENDLY_DRAWER		1
#define FRIENDLY_OTHER		2



VOID BuildNameTable(fileio)
struct FileIOSupport *fileio;
/* This routine searches through the fileio lock for all file entries,
 * and builds a list of the names found.
 * If the user wants Workbench-style pattern matching, filenames are
 * passed through a filter before being added to the list.
 * All directory entries are added to the list.
 */
{
	struct FileInfoBlock *fileinfo;
	UBYTE *ptr;
	UBYTE workname[MAX_NAME_LENGTH + 5]; /* the extra 5 are for the ".info" */
	struct Remember **key;
	ULONG lock;
	SHORT i, flags, type;
	SHORT pick;

	fileio->NameCount = 0;
	lock = fileio->DOSLock;
	key = &fileio->NameKey;
	FreeRemember(key, TRUE);
	ClearFlag(fileio->Flags, GOOD_FILENAMES);

	if ((fileinfo = (struct FileInfoBlock *)AllocMem(
			sizeof(struct FileInfoBlock), MEMF_CLEAR)) == NULL)
		goto BUILD_EXIT;

	SetWaitPointer(OpenReqWindow);

	/* Now, first, before we might be interrupted by MessageInterrupt(),
	 * check whether or not we're looking in a drawer and, if so, add the
	 * entry that allows the user to ascend one drawer.
	 */
	if (StringLength(&OpenReqFileIO->DrawerName[0]))
		{
		MakeEntry("\253\253 PRIOR DRAWER", key, NAMED_PREVIOUS);
		/* bump the master count */
		fileio->NameCount++;
		}

	/* starting from Examine() until ExNext() is NULL */
	if (Examine(lock, fileinfo))
		while (ExNext(lock, fileinfo))
			{
			/* Default:  this entry is a normal file */
			flags = NULL;
			CopyString(&workname[0], fileinfo->fib_FileName);

#ifdef WBENCH_CODE
			/* Now, does the caller want Workbench-style pattern matching? */
			if (FlagIsSet(fileio->Flags, WBENCH_MATCH))
				{
				/* start from location 1 to avoid matching the ".info" file */
				if (ptr = FindSuffix(&workname[1], ".info")) 
					{
					*ptr = '\0';	/* strip the suffix off that baby */

					/* Get the friendliness quotient of this .info file */
					type = FriendlyInfoType(&workname[0], fileio);

					/* If just not friendly, forget about it */
					if (type == FRIENDLY_NOT) goto NEXT_LOCK;

					/* If this was a drawer, set the fileinfo as a directory */
					if (type == FRIENDLY_DRAWER)
						fileinfo->fib_DirEntryType = 1;
					}
				else goto NEXT_LOCK;
				}
#endif /* ... of WBENCH_CODE conditional */

			if (fileinfo->fib_DirEntryType >= 0)
				{
				/* This entry is a directory */
				flags = NAMED_DIRECTORY;

				/* If you change the following text, change DIR_TEXT_SIZE too */
				for (i = StringLength(&workname[0]); i >= 0; i--)
					workname[i + DIR_TEXT_SIZE] = workname[i];
				workname[0] = '\273';
				workname[1] = '\273';
				workname[2] = ' ';
				}

			pick = MakeEntry(&workname[0], key, flags);
			/* bump the master count */
			fileio->NameCount++;

			if (pick <= fileio->CurrentPick)
				fileio->CurrentPick++;

			InitOpenProp(FALSE);
			StuffSelectNames(2);

NEXT_LOCK:
			/* If there's a message pending, split with what we've got */
			if (MessageInterrupt()) goto EXAMINE_DONE;
			}

	SetFlag(fileio->Flags, GOOD_FILENAMES);


EXAMINE_DONE:

	if (OpenReqWindow) ClearPointer(OpenReqWindow);
	FreeMem(fileinfo, sizeof(struct FileInfoBlock));


BUILD_EXIT: ;
}



VOID PropInterrupt()
/* This routine is called by MessageInterrupt() if the prop gadget 
 * is played with while the file name table is being built.  
 * As long as the user is using the proportional gadget, hang around here. 
 */
{
	struct IntuiMessage *message;
	struct Gadget *gadget;
	BOOL mousemove;

	FOREVER
		{
		WaitPort(OpenReqWindow->UserPort);
		mousemove = FALSE;

		while (message = GetMsg(OpenReqWindow->UserPort))
			{
			switch (message->Class)
				{
				case GADGETUP:
					gadget = (struct Gadget *)message->IAddress;
					switch (gadget->GadgetID)
						{
						case OPENGADGET_PROPGADGET:
							ReplyMsg(message);
							HandleGadget(gadget, 0, 0, 0, 0);
							return;

						default:
							goto MESSAGE_RETURN;
						}
					break;

				case MOUSEMOVE:
					ReplyMsg(message);
					mousemove = TRUE;
					break;

				default:
					goto MESSAGE_RETURN;

				}
			}

		if (mousemove) PropMouseMoves();
		}

MESSAGE_RETURN:
	/* Pretend we didn't see this message */
	AddHead(&OpenReqWindow->UserPort->mp_MsgList, message);
}



BOOL MessageInterruptGrunt(message)
struct IntuiMessage *message;
/* Test if there's a gadget type of message at the window port, 
 * react to it if there is one, and return TRUE if the message is 
 * one that should interrupt the building of the file name list.
 */
{
	ULONG class;
	SHORT x, y;
	struct Gadget *gadget;
	LONG seconds, micros;

	class = message->Class;
	if ((class == GADGETDOWN) || (class == GADGETUP))
		{
		gadget = (struct Gadget *)message->IAddress;
		x = message->MouseX;
		y = message->MouseY;
		seconds = message->Seconds;
		micros = message->Micros;
		OpenReqSupport.SelectedGadgetID = gadget->GadgetID;

		switch (gadget->GadgetID)
			{
			case OPENGADGET_SELECTNAME:
				y = HandleSelect(y, seconds, micros);
				if ((y == -1) || (y == 1))
					{
					/* Pretend we didn't see this message */
					AddHead(&OpenReqWindow->UserPort->mp_MsgList, message);
					return(TRUE);
					}

				StuffFileName();
				StuffSelectNames(5);
				goto REPLY_AND_RETURN_FALSE;

			case OPENGADGET_UPGADGET:
			case OPENGADGET_DOWNGADGET:
				goto REPLY_AND_RETURN_FALSE;

			case OPENGADGET_PROPGADGET:
				HandleGadget(gadget, x, y, seconds, micros);
				if (class == GADGETDOWN) PropInterrupt();
				goto REPLY_AND_RETURN_FALSE;

			default:
				/* Do nothing, fall into the message's AddHead() below.
				 * This includes the gadgets OK, CANCEL, NEXTDISK, 
				 * DISKNAME, DRAWERNAME, FILENAME, and BACKDROP.
				 */
				break;
			}
		}

	/* Pretend we didn't see this message */
	AddHead(&OpenReqWindow->UserPort->mp_MsgList, message);
	return(TRUE);

REPLY_AND_RETURN_FALSE:
	ReplyMsg(message);
	return(FALSE);
}



BOOL MessageInterrupt()
/* Call MessageInterruptGrunt() with each message.
 * Return TRUE if the message is one that should interrupt the building 
 * of the file name list, else return FALSE.
 */
{
	struct IntuiMessage *message;

	while (message = GetMsg(OpenReqWindow->UserPort))
		{
		if (MessageInterruptGrunt(message))
			return(TRUE);
		}
	return(FALSE);
}



SHORT MakeEntry(name, startkey, flags)
UBYTE *name;
struct Remember **startkey;
UBYTE flags;
{
	SHORT length, pos;
	struct Remember *localkey, *nextkey, *oldkey;
	UBYTE *ptr;

	/* length equals the length of the text plus one for the 
	 * terminating NULL
	 */
	length = StringLength(name) + 1;
	localkey = NULL;
	/* Alloc one larger than length to make room for the flag byte */
	ptr = AllocRemember(&localkey, length + 1, NULL);
	if (ptr == NULL) return(32767);
	CopyString(ptr, name);
	*(ptr + length) = flags;
	nextkey = *startkey;
	pos = 0;
	oldkey = NULL;
	while (nextkey)
		{
		if (CompareUpperStrings(nextkey->Memory, name) >= 0)
			goto DONE;

		oldkey = nextkey;
		nextkey = nextkey->NextRemember;
		pos++;
		}

DONE:
	if (oldkey) oldkey->NextRemember = localkey;
	else *startkey = localkey;
	localkey->NextRemember = nextkey;
	return(pos);
}




#ifdef WBENCH_CODE

SHORT FriendlyInfoType(infoname, fileio)
UBYTE *infoname;
struct FileIOSupport *fileio;
/* This routine looks at the .info file that's named infoname and
 * tests to see if its object type and tool type match the specifications
 * in the fileio structure.  Returns TRUE if everything matches.
 * If the .info file couldn't be opened or if the requirements don't
 * match, FALSE is returned.
 */
{
	struct DiskObject *object;
	SHORT result;

	result = FRIENDLY_NOT;
	if (object = GetDiskObject(infoname)) 
		{
		if ((object->do_Type == WBDRAWER) || (object->do_Type == WBGARBAGE))
			result = FRIENDLY_DRAWER;
		else if (object->do_Type == WBDISK) 
			result = FRIENDLY_NOT;
		else
			{
			if (FlagIsSet(fileio->Flags, MATCH_OBJECTTYPE))
				if (object->do_Type != fileio->DiskObjectType) goto FRIEND_DONE;

			result = FRIENDLY_OTHER;

			if (FlagIsSet(fileio->Flags, MATCH_TOOLTYPE))
				{
				if (NOT MatchToolValue(
					   FindToolType(object->do_ToolTypes, "FILETYPE"), 
						&fileio->ToolType[0]))
					result = FRIENDLY_NOT;
				}
			}
		}

FRIEND_DONE:
	if (object) FreeDiskObject(object);
	return(result);
}

#endif /* ... of WBENCH_CODE conditional */



