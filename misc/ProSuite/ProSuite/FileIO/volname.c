
/* *** volname.c ************************************************************
 *
 * File IO Suite  --  Volume Name Construction Routines
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
 * 27 Sep 87    RJ              Leave VolumeIndex alone as much as possible.
 *                              Also, after building a new volume table, try 
 *                              to look up the old volume name among the 
 *                              new volume entries and set VolumeIndex 
 *                              if possible.
 * 4 Feb 87     RJ              Real release
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 3 May 86     =RJ Mical=      Fix prop gadget for both 1.1 and 1.2
 * 1 Feb 86     =RJ Mical=      Created this file.
 *
 * *********************************************************************** */


#define FILEIO_SOURCEFILE
#include "fileio.h"
#include <libraries/dosextens.h>


/* Lattice doesn't accept the ID_DOS_DISK which looks like this:
 * #define ID_DOS_DISK ('DOS\0')
 * so I make up my own.
 */
#define X_ID_DOS_DISK (((LONG)'D'<<24)|((LONG)'O'<<16)|('S'<<8)|('\0'))


BOOL DOSDisk(device)
struct DeviceList *device;
/* This little routine dips its gnarled toes directly into the 
 * scary murky depths of AmigaDOS interior.
 * If it survives, it returns TRUE or FALSE depending on whether or
 * the specified device is a DOS disk.
 * Jeez, Look at the structure names in this routine!  Whew!  You almost
 * gotta be a computer scientist to understand this stuff.
 */
{
	struct MsgPort *port;
	BOOL result;
	struct InfoData *info;
	struct StandardPacket *packet;


	result = FALSE;

	/* Allocate the data structures required to communicate with AmigaDOS */
	info = (struct InfoData *)AllocMem(sizeof(struct InfoData), MEMF_CLEAR);
	packet = (struct StandardPacket *)AllocMem(sizeof(struct StandardPacket),
			MEMF_CLEAR);

	/* Grab us a message port for the reply from DOS */
	port = CreatePort(NULL, 0);

	if (port && info && packet)
		{
		/* OK, everything is set so here we go! */

		/* Set up the StandardPacket's Exec message */
		packet->sp_Msg.mn_Node.ln_Type = NT_MESSAGE;
		packet->sp_Msg.mn_Node.ln_Name = (char *)&packet->sp_Pkt;
		packet->sp_Msg.mn_ReplyPort = port;

		/* Set up the StandardPacket's DOS data */
		packet->sp_Pkt.dp_Link = &packet->sp_Msg;
		packet->sp_Pkt.dp_Type = ACTION_DISK_INFO;
		packet->sp_Pkt.dp_Arg1 = ((LONG)info >> 2);
		packet->sp_Pkt.dp_Port = port;

		/* Now, ask the device whether or not it's a DOS disk */
		PutMsg(device->dl_Task, &packet->sp_Msg);
		/* zzz */
		WaitPort(port);

		/* Well? */
		if (info->id_DiskType == X_ID_DOS_DISK) result = TRUE;
		}

	if (port) DeletePort(port);
	if (info) FreeMem(info, sizeof(struct InfoData));
	if (packet) FreeMem(packet, sizeof(struct StandardPacket));

	return(result);
}



VOID BuildVolumeTable(fileio)
struct FileIOSupport *fileio;
/* This routine builds an alphabetically-sorted list of all active volumes.
 * The names can be either the device names or the volume names, depending
 * on whether you set USE_VOLUME_NAMES.
 */
{
	struct DosInfo *dosinfo;
	struct DeviceList *masterlist, *devlist, *worklist;
	struct MsgPort *handler;
	LONG yuck;
	UBYTE *nameptr, *textptr;
	UBYTE len;
	SHORT i;
	struct Remember **key, *localkey, *keyptr;

	if (DosBase == NULL) return;

	key = &fileio->VolumeKey;
	FreeRemember(key, TRUE);
	localkey = NULL;

/* FORMERLY:  fileio->VolumeCount = fileio->VolumeIndex = 0;
 * Instead, try leaving index where it was, clipping as needed at the end
 */
	fileio->VolumeCount = 0;

	/* First, feel through from DosBase down to the device list, dancing
	 * all the while with the bcpl pointers.
	 */
	yuck = (LONG)((struct RootNode *)DosBase->dl_Root)->rn_Info;
	dosinfo = (struct DosInfo *)(yuck << 2);	/* reality pointer */
	yuck = (LONG)dosinfo->di_DevInfo;
	masterlist = (struct DeviceList *)(yuck << 2);	/* reality pointer */

	devlist = masterlist;


	while (devlist)
		{
		/* First, find each device that's active (dl_Task is not NULL) */
		if ((devlist->dl_Type == DLT_DEVICE) && (devlist->dl_Task))
			{
			/* OK, got a device.  Now ask it if it's a DOS disk. */
			if (NOT DOSDisk(devlist)) goto NEXT_DEVICE;

			/* OK, got a device that's a DOS disk.  Now find the name.
			 * If USE_VOLUME_NAMES is clear, use the device name,
			 * else look up the volume name.
			 */
			nameptr = (UBYTE *)devlist->dl_Name;
			if (FlagIsSet(fileio->Flags, USE_VOLUME_NAMES))
				{
				/* Use the handler for this volume to find the matching device */
				handler = (struct MsgPort *)devlist->dl_Task;

				worklist = masterlist;
				while (worklist)
					{
					if ((worklist->dl_Type == DLT_VOLUME)
							&& (worklist->dl_Task == handler))
						{
						nameptr = (UBYTE *)worklist->dl_Name;
						goto GOT_NAME;
						}

					yuck = worklist->dl_Next;
					worklist = (struct DeviceList *)(yuck << 2);
					}
				/* If we get to the end of this loop and fall out, then what?  
				 * Got an active device but no matching volume?  OK.
				 */
				}

GOT_NAME:
			yuck = (LONG)nameptr;
			nameptr = (UBYTE *)(yuck << 2);
			len = *nameptr++;

			if ((textptr = AllocRemember(&localkey, len + 2, NULL)) == NULL)
				{
				Alert(ALERT_OUTOFMEM, NULL);
				goto DEVICES_DONE;
				}

			fileio->VolumeCount++;
			for (i = 0; i < len; i++) *textptr++ = *nameptr++;
			*textptr++ = ':';
			*textptr = '\0';
			MakeEntry(localkey->Memory, key, NULL);
			}

NEXT_DEVICE:
		yuck = devlist->dl_Next;
		devlist = (struct DeviceList *)(yuck << 2);
		}


DEVICES_DONE:

	FreeRemember(&localkey, TRUE);

	/* Safety measure */
	if (fileio->VolumeIndex >= fileio->VolumeCount)
		fileio->VolumeIndex = fileio->VolumeCount - 1;

	keyptr = fileio->VolumeKey;
	nameptr = &fileio->DiskName[0];
	i = 0;
	while (keyptr)
		{
		if (StringsEqual(keyptr->Memory, nameptr))
			{
			fileio->VolumeIndex = i;
			goto DONE;
			}
		keyptr = keyptr->NextRemember;
		i++;
		}

	fileio->VolumeIndex = 0;

DONE:	;
}


UBYTE *CurrentVolumeName()
/* This routine returns a pointer the name of the current volume */
{
	SHORT i;
	struct Remember *remember;

	/* If there's no active volumes then return the "safe" volume name */
	if (OpenReqFileIO->VolumeCount < 1)
		return(&CurrentDiskString[0]);

	/* Safety measure */
	if (OpenReqFileIO->VolumeIndex >= OpenReqFileIO->VolumeCount)
		OpenReqFileIO->VolumeIndex = 0;

	/* Finally, look up the name */
	remember = OpenReqFileIO->VolumeKey;
	for (i = 0; i < OpenReqFileIO->VolumeIndex; i++)
		remember = remember->NextRemember;
	return(remember->Memory);
}

