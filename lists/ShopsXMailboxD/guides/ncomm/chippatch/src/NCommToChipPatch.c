/* NCommToChipPatch.c

	Auto: SC LINK NOSTKCHK NOSTARTUP <path>NCommToChipPatch.c OBJ <path>sprintf.o
*/

#include <exec/types.h>
#include <libraries/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <string.h>

#define BUFFERSIZE 400*1024

extern APTR SPrintf(STRPTR dest, STRPTR fmtstr, ...);

UBYTE *template = "NCOMMEXECUTABLE,USAGE/S";
enum {
   TEM_NCOMMEXECUTABLE,
   TEM_USAGE,
   TEM_NUMBEROF
};

UBYTE __far buffer[BUFFERSIZE];
UBYTE toname[250];

STRPTR fmtstr =
"NCommToChipPatch V1.1  Usage: NCommToChipPatch [ncommexecutable]\n"
"Copyright © 1996 Ultima Thule Software. Author: Eivind Nordseth.\n"
"This program will create a patched NComm which makes all hunks\n"
"to end up in chip memory when loaded. This will slow NComm down,\n"
"and make it usable on Faaaaaaaaaaaaaaaaaast Amigas. No more hickups.\n"
"The patched file will be saved as ChipNComm in the same directory as\n"
"the ncomm executable. 3.02k, 3.05 and 3.06 versions can be patched.\n%s";

LONG __saveds NoName(void)
{
   struct DosLibrary *DOSBase;
   struct RDArgs *rdargs = NULL, *args = NULL;
   LONG array[TEM_NUMBEROF], retval = RETURN_ERROR, read;
   STRPTR ptr;
   BPTR fh = NULL;

   if(!(DOSBase = (struct DosLibrary *) OpenLibrary(DOSNAME, 37L))) 
      return(10000L);

   if(!(args = AllocDosObject(DOS_RDARGS, NULL))) goto quit;
   setmem(array, TEM_NUMBEROF * sizeof(LONG), 0);

   SPrintf(args->RDA_ExtHelp = buffer, fmtstr, template);
      
   if(!(rdargs = ReadArgs(template, array, args)))
   {
      Printf("Error in arguments.");
      goto quit;
   }

   if(array[TEM_USAGE] || !array[TEM_NCOMMEXECUTABLE])
   {
      Printf(fmtstr, "");
      retval = RETURN_OK;
      goto quit;
   }

	if(!(fh = Open((STRPTR) array[TEM_NCOMMEXECUTABLE], MODE_OLDFILE))) 
	{
		Printf("Could not open %s\n", array[TEM_NCOMMEXECUTABLE]);
		goto quit;
	}
	
	read = Read(fh, buffer, BUFFERSIZE);
	
	if(read == 216292) Printf("NComm 3.02k version found.\n");
	else if(read == 218244) Printf("NComm 3.05 version found.\n");
	else if(read == 222928) Printf("NComm 3.06 version found.\n");
	else
	{
		Printf("%s is no known NComm version\n", array[TEM_NCOMMEXECUTABLE]);
		goto quit;
	}

	buffer[0x14] = 0x40;
	buffer[0x1C] = 0x40;

	buffer[0x20] = 0x40;
	buffer[0x24] = 0x40;
	buffer[0x28] = 0x40;
	
	
	strcpy(toname, (STRPTR) array[TEM_NCOMMEXECUTABLE]);
	ptr = PathPart(toname);
	if(*ptr == '/') *ptr++;
	strcpy(ptr, "ChipNComm");
	
	Close(fh);
	if(!(fh = Open(toname, MODE_NEWFILE)))
	{
		Printf("Could not create ChipNComm\n");
		goto quit;
	}

	if(Write(fh, buffer, read) != read)
	{
		Printf("Failed to write output file\n");
		goto quit;
	}

	Printf("A patched version of NComm is now saved as %s.\n", toname);

   retval = RETURN_OK;

quit:
	if(fh) Close(fh);
   if(rdargs) FreeArgs(rdargs);
   if(args) FreeDosObject(DOS_RDARGS, args);

   CloseLibrary((struct Library *) DOSBase);
   return(retval);
}
