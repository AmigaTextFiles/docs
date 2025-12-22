/* 
 * cdalldevs version 0.1 by megacz@usa.com
 * - this is mostly ripped from 'Scout'.
*/

#define __USE_SYSBASE 1

#include <proto/dos.h>
#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <dos/filehandler.h>
#include <proto/exec.h>
#include <exec/types.h>

#define DOLLEN 256

int main (void)
{
  struct ExecBase *SysBase = (*((struct ExecBase **) 4));
  struct DosLibrary *DOSBase;
  struct DosList *dol;
  char *dolstrptr;
  char *dolnameptr;
  char dolbuffer[DOLLEN+2];
  long dollen = DOLLEN;
  long dolcnt;
  BPTR cd;


  if((DOSBase=(struct DosLibrary *)OpenLibrary("dos.library", 36L)) != NULL)
  {      
    dol = LockDosList(LDF_READ | LDF_DEVICES);

    while ((dol = NextDosEntry(dol, LDF_DEVICES)) != NULL)
    {
      struct FileSysStartupMsg *fssm;


      fssm = (struct FileSysStartupMsg *)BADDR(dol->dol_misc.dol_handler.dol_Startup);

      if ((ULONG)fssm > 0x400 && (BOOL)((TypeOfMem(fssm)) ? TRUE : FALSE) &&
           fssm->fssm_Unit <= 0x00ffffff)
      {
        UBYTE *p = BADDR(fssm->fssm_Device);


        if (p != NULL && (BOOL)((TypeOfMem(p)) ? TRUE : FALSE) &&
            p[0] != 0x00 && p[1] != 0x00)
        {
          struct DosEnvec *de = (struct DosEnvec *)BADDR(fssm->fssm_Environ);


          if (de != NULL && (BOOL)((TypeOfMem(de)) ? TRUE : FALSE))
          {
            dolstrptr = BADDR(dol->dol_Name);
            dolnameptr = dolbuffer;

            if ((long)*dolstrptr < dollen)
              dollen = (long)*dolstrptr;
   
            *dolstrptr++;         
   
            for(dolcnt = 0; dolcnt < dollen; dolcnt++)
              *dolnameptr++ = (char)*dolstrptr++;

            *dolnameptr++ = ':';   
            *dolnameptr = '\0';

            if((cd = Open(dolbuffer,MODE_OLDFILE)) != NULL)
              Close(cd);   

            FPrintf(Output(),"%s\n", dolbuffer);
          }
        }
      }
    }

    UnLockDosList(LDF_READ | LDF_DEVICES);

    CloseLibrary((struct Library *)DOSBase);
  }

  return 0;
}
