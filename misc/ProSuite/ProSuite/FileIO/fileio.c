
/* *** fileio.c *************************************************************
 *
 * File IO Suite  --  Primary FileIO Requester Routines
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
 * 26 Aug 87    RJ              Added test for 0 GadgetID at end of 
 *                              GetFileIOName()
 * 4 Feb 87     RJ              Real release
 * 12 Aug 86    RJ >:-{)*       Prepare (clean house) for release
 * 3 May 86     =RJ Mical=      Fix prop gadget for both 1.1 and 1.2
 * 1 Feb 86     =RJ Mical=      Created this file.
 *
 * *********************************************************************** */


#define FILEIO_SOURCEFILE
#include "fileio.h"


/* These routines can be found in filesupp.c */
extern HandleGadget();
extern StartOpenRequester();
extern DiskInserted();
extern PropMouseMoves();



/* *** GetFileIOSupport() ***************************************************
 * 
 * NAME
 *     GetFileIOSupport  --  Allocate and initialize a FileIOSupport structure
 * 
 * 
 * SYNOPSIS
 *     struct FileIOSupport *GetFileIOSupport();
 * 
 * 
 * FUNCTION
 *     Allocates and initializes a FileIOSupport structure for use with
 *     calls to GetFileIOName().
 * 
 *     You may want to further initialize the structure before calling
 *     GetFileIOName().  Refer to the FileIO documentation for more
 *     information.
 * 
 *     When you're done with the structure, call ReleaseFileIO().
 * 
 * 
 * INPUTS
 *     None
 * 
 * 
 * RESULT
 *     If all goes well, returns the address of a FileIOSupport structure.
 *     If anything goes wrong (usually out of memory), returns NULL.
 * 
 * 
 * EXAMPLE
 *     struct FileIOSupport *fileio;
 *     fileio = GetFileIOSupport();
 *     GetFileIOName(fileio, window);
 *     ReleaseFileIO(fileio);
 * 
 * 
 * BUGS
 *     None known
 * 
 * 
 * SEE ALSO
 *     GetFileIOName(), ReleaseFileIO()
 */
struct FileIOSupport *GetFileIOSupport()
{
	struct FileIOSupport *fileio;

	if (fileio = (struct FileIOSupport *)AllocMem(
			sizeof(struct FileIOSupport), MEMF_CLEAR))
		{
		/* Anything special to initialize? */
		SetFlag(fileio->Flags, USE_VOLUME_NAMES | RENAME_RAMDISK);
		}
	return(fileio);
}



/* *** GetFileIOName() ******************************************************
 * 
 * NAME
 *     GetFileIOName  --  Gets a file name for input/output from the user
 * 
 * 
 * SYNOPSIS
 *     BOOL GetFileIOName(FileIO, Window);
 * 
 * 
 * FUNCTION
 *     This routine creates a filename requester which allows the user
 *     to browse through the AmigaDOS filesystem and select one of
 *     the filenames found there.
 * 
 *     The FileIO argument is a pointer to a FileIOSupport structure,
 *     which is allocated and initialized for you via a call to 
 *     GetFileIOSupport().
 *     You may preset the FileIO parameters before calling this routine, 
 *     or you may leave them set at their default values.  See the FileIO
 *     documentation for complete details.
 * 
 *     The Window argument is the pointer to the window structure returned
 *     by a call to Intuition's OpenWindow() function.  As this routine
 *     opens a requester and requesters open in windows, you must have
 *     already opened a window before calling this routine, even if it's
 *     a window opened for no other purpose than to call this routine.
 * 
 *     This routine returns a BOOL value of TRUE or FALSE, depending on
 *     whether the user chose to accept or cancel the filename selection 
 *     operation.  If TRUE, the filename selected by the user can be
 *     found in the FileIO structure FileName[] field.  This filename
 *     will have all leading and trailing blanks removed (in case the
 *     user typed in a filename with extraneous spaces).  Likewise,
 *     the pathname to the disk and drawer can be found in the text
 *     fields DiskName[] and DrawerName[].  You can construct 
 *     the pathname using these text strings.  Also, you can call 
 *     BuildFileIOPathname() to build the pathname automatically.
 * 
 *     There's a *lot* more to be said about this function.  Please 
 *     read the documentation.
 * 
 *     NOTE:  This routine is not re-entrant.  What this means 
 *     is that if you have created a program that has more than one task,
 *     this routine cannot be called by more than one task at a time.
 *     This is not a problem for the grand majority of programs.
 *     But if you have some application that would require calling this 
 *     routine asynchronously from multiple tasks, you'll have to 
 *     implement some quick semaphore arrangement to avoid collisions.
 *     No big deal, actually.  See Exec semaphores for everything you need.
 * 
 * 
 * INPUTS
 *     FileIO = pointer to a FileIOSupport structure, as allocated
 *         via a call to GetFileIOSupport()
 *     Window = pointer to a Window structure, as created via a call
 *         to Intuition's OpenWindow()
 * 
 * 
 * RESULT
 *     TRUE if the user decided that the filename selection was successful,
 *     FALSE if the user chose to cancel the operation
 * 
 * 
 * EXAMPLE
 *     if (GetFileIOName(fileio, window))
 *         ProcessFileName(&fileio->FileName[0]);
 * 
 * 
 * BUGS
 *     None known, though there could be some, and the disk selection
 *     subsystem logic is not perfectly polished (though it's believed 
 *     to be bug-free).
 * 
 * 
 * SEE ALSO
 *     BuildFileIOPathname(), GetFileIOSupport(), ReleaseFileIO()
 */
BOOL GetFileIOName(fileio, window)
struct FileIOSupport *fileio;
struct Window *window;
{
	UBYTE *newtext;

	if ((fileio == NULL) || (window == NULL)) return(FALSE);

	OpenSaveLock = CurrentDir(NULL);
	CurrentDir(OpenSaveLock);
	fileio->DOSLock = OpenSaveLock;

	/* Get easily-accessible copies of the values that are referenced 
	 * most often
	 */
	OpenReq = &OpenReqSupport.Requester;
	OpenReqWindow = OpenReqSupport.Window = window;
	OpenReqFileIO = fileio;

	/* Set up the DoRequest() handlers */
	OpenReqSupport.GadgetHandler = HandleGadget;
	OpenReqSupport.StartRequest = StartOpenRequester;
	OpenReqSupport.NewDiskHandler = DiskInserted;
	OpenReqSupport.MouseMoveHandler = PropMouseMoves;

	/* Init the string gadget buffers */
	OpenNameTextInfo.Buffer = &fileio->FileName[0];
	OpenDrawerTextInfo.Buffer = &fileio->DrawerName[0];
	OpenDiskTextInfo.Buffer = &fileio->DiskName[0];

	/* Initialize the requester title */
	if ((ReqTitleText.IText = fileio->ReqTitle) == NULL)
		ReqTitleText.IText = DefaultReqTitle;
	ReqTitleText.LeftEdge
		= (OPEN_WIDTH - IntuiTextLength(&ReqTitleText)) >> 1;

	/* If this fileio doesn't have valid filenames,
	 * then refresh the whole thing
	 */
	if (FlagIsClear(fileio->Flags, GOOD_FILENAMES))
		{
		ResetNameText(TRUE);
		ResetDrawerText(TRUE);
		BuildVolumeTable(fileio);
		CopyString(&OpenReqFileIO->DiskName[0], CurrentVolumeName());
		}

	ResetNameText(FALSE);
	ResetDrawerText(FALSE);
	ResetDiskText(FALSE);

	StuffSelectNames(0);
	InitOpenProp(TRUE);

	/* Reset the double-click time variables */
	OpenClickSeconds = OpenClickMicros = 0;


	/* And now, do that requester. */
	DoRequest(&OpenReqSupport);
	/* Back, eh?  Wasn't that easy? */


	if (FlagIsSet(fileio->Flags, LOCK_GOTTEN))
		{
		UnLock(fileio->DOSLock);
		ClearFlag(fileio->Flags, LOCK_GOTTEN);
		}

	CurrentDir(OpenSaveLock);
	OpenReqFileIO = NULL;

	/* Strip any excess leading and trailing blanks off the final name */
	newtext = StripOuterSpace(&fileio->FileName[0], " ");
	CopyString(&fileio->FileName[0], newtext);

	if ((OpenReqSupport.SelectedGadgetID)
			&& (OpenReqSupport.SelectedGadgetID != OPENGADGET_CANCEL))
		return(TRUE);
	return(FALSE);
}



/* *** BuildFileIOPathname() ************************************************
 * 
 * NAME
 *     BuildFileIOPathname  --  Build a file pathname using a FileIO struct
 * 
 * 
 * SYNOPSIS
 *     BuildFileIOPathname(FileIOSupport, Buffer);
 * 
 * 
 * FUNCTION
 *     Builds the text for a pathname using the FileName[], DrawerName[] and
 *     DiskName[] fields of the specified FileIOSupport structure
 *     after the support structure has been used in a successful call
 *     to GetFileIOName().  Writes the text into the Buffer.
 * 
 * 
 * INPUTS
 *     FileIOSupport = the address of a FileIOSupport structure
 *     Buffer = address of the buffer to receive the file pathname
 * 
 * 
 * RESULT
 *     None
 * 
 * 
 * SEE ALSO
 *     GetFileIOName()
 */
VOID BuildFileIOPathname(fileio, buffer)
struct FileIOSupport *fileio;
UBYTE *buffer;
{
	StripOuterSpace(&fileio->DiskName[0], " ");
	StripOuterSpace(&fileio->DrawerName[0], " ");
	StripOuterSpace(&fileio->FileName[0], " ");

	CopyString(buffer, &fileio->DiskName[0]);
	if (StringLength(&fileio->DrawerName[0]))
		{
		ConcatString(buffer, &fileio->DrawerName[0]);
		ConcatString(buffer, "/");
		}
	ConcatString(buffer, &fileio->FileName[0]);
}



/* *** AddFileIOName() ******************************************************
 * 
 * NAME
 *     AddFileIOName  --  Add a file name to the names in a FileIOSupport
 * 
 * 
 * SYNOPSIS
 *     AddFileIOName(FileIOSupport, FileName);
 * 
 * 
 * FUNCTION
 *     This routine adds a file name to the list of file names currently 
 *     in the specified FileIOSupport structure.  The next time the 
 *     FileIOSupport structure is used for a call to GetFileIOName(), the 
 *     new file name will apppear alphabetized in with the other file names.  
 *     
 *     This routine will most often be used after a call to GetFileIOName() 
 *     or some other routine where the user is allowed to specify the name 
 *     of a file to be opened for output.  If the file is opened 
 *     successfully, this routine will make sure that the name of the file 
 *     is in the FileIOSupport structure.  This is important if the output 
 *     file has been newly created; otherwise, without calling this 
 *     routine, the next time the FileIOSupport structure is used the new 
 *     file name would not appear even though the file exists.  If the name 
 *     is already in the list when you call AddFileIOName() then nothing 
 *     happens.  This allows you to call AddFileIOName() without worrying 
 *     about duplicate name redundancy.
 *     
 *     Here's a typical sequence of events leading up to a call to 
 *     AddFileIOName():
 *     
 *         First, get a FileIOSupport structure:
 *             fileio = GetFileIOSupport(...);
 *     
 *         When the user wants to write data, use GetFileIOName()
 *         to provide a convenient and consistent interface to
 *         the filesystem:
 *             goodfile = GetFileIOName(...);
 *     
 *         If the user has selected a name for output (in this example,
 *         goodfile will equal TRUE if the user selected a name), then
 *         open the file (possibly creating it) and then call 
 *         AddFileIOName() to make sure the name is in the FileIOSupport
 *         structure's list:
 *             if (goodfile)
 *                 {
 *                 UBYTE filename[80];
 *                 
 *                 BuildFileIOPathname(fileio, &filename[0]);
 *                 ... open filename, write it, close it ...
 *                 if (filename opened successfully)
 *                     AddFileIOName(fileio, &filename[0]);
 *                 }
 * 
 * 
 * INPUTS
 *     FileIOSupport = the address of a FileIOSupport structure
 *     FileName = the address of null-terminated text that is
 *         either a simple file name or a valid AmigaDOS pathname.
 * 
 * 
 * RESULT
 *     None
 * 
 * 
 * SEE ALSO
 *     GetFileIOName()
 *     GetFileIOSupport()
 */
VOID AddFileIOName(fileio, filename)
struct FileIOSupport *fileio;
UBYTE *filename;
{
	SHORT index, i, length;
	struct Remember *remember, *oldremember;
	UBYTE *nextentry;
	struct Remember *namekey;

	/* Does the filename start with a volume name?  If so, skip over it */
	index = IndexString(filename, ":");
	if (index >= 0) filename += index + 1;

	/* Does the filename start with a directory name?  If so, skip over it */
	do 
		{
		index = IndexString(filename, "/");
		if (index >= 0) filename += index + 1;
		}
	while (index >= 0);

	if (*filename == 0) return;

	/* Here, filename points to what is presumed to be a valid file name.
	 * If it's found among the FileIOSupport's names, exit.
	 * If it's not found in the list, add it.
	 *
	 * The current file names are stored in the fileio's Remember list.
	 */
	remember = fileio->NameKey;
	oldremember = NULL;
	while (remember)
		{
		i = CompareUpperStrings(filename, remember->Memory);
		if (i < 0) goto ADD_FILENAME;
		if (i == 0) return;
		oldremember = remember;
		remember = remember->NextRemember;
		}

ADD_FILENAME:
	/* Name not on list, so add it now */
	length = StringLength(filename);

	namekey = NULL;
	if (nextentry = AllocRemember(&namekey, length + 1 + 1, NULL))
		{
		CopyString(nextentry, filename);
		*(nextentry + length + 1) = 0;
		if (oldremember) oldremember->NextRemember = namekey;
		else fileio->NameKey = namekey;
		/* This assignment is valid whether or not remember is NULL */
		namekey->NextRemember = remember;
		fileio->NameCount++;
		}
}



/* *** ReleaseFileIO() ******************************************************
 * 
 * NAME
 *     ReleaseFileIO  --  Release the FileIO structure and all local memory
 * 
 * 
 * SYNOPSIS
 *     ReleaseFileIO(FileIO);
 * 
 * 
 * FUNCTION
 *     Releases the FileIO structure by freeing all local memory attached
 *     to the structure and then freeing the structure itself.
 * 
 * 
 * INPUTS
 *     FileIO = the address of a FileIO structure
 * 
 * 
 * RESULT
 *     None
 * 
 * 
 * SEE ALSO
 *     GetFileIOSupport()
 */
VOID ReleaseFileIO(fileio)
struct FileIOSupport *fileio;
{
	if (fileio)
		{
		FreeRemember(&fileio->VolumeKey, TRUE);
		FreeRemember(&fileio->NameKey, TRUE);
		FreeMem(fileio, sizeof(struct FileIOSupport));
		}
}


