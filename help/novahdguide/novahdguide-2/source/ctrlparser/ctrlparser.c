/* 
 * ctrlparser version 0.1 by megacz@usa.com
*/

#define __USE_SYSBASE 1

#include <proto/dos.h>
#include <dos/rdargs.h>
#include <dos/dosextens.h>
#include <dos/dostags.h>
#include <proto/exec.h>
#include <exec/types.h>
#include <exec/memory.h>
#include <string.h>

#define SCREENPREFS_A "\x46\x4F\x52\x4D\x00\x00\x00\x36\x50\x52\x45\x46\x50\x52\x48\x44\x00\x00\x00\x06\x00\x00\x00\x00\x00\x00\x53\x43\x52\x4D\x00\x00\x00\x1C\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
#define SCREENPREFS_B "\xFF\xFF\xFF\xFF\x00\x03\x00\x01"
#define SCREENPREFS_PAL "\x02\x90\x04"
#define SCREENPREFS_NTSC "\x01\x90\x04"
#define SCREENPREFS_DBLNTSC "\x09\x90\x04"
#define STRTOK_M(__strtok_1, __strtok_2, __strtok_t, __strtok_o) \
__strtok_o=__strtok_1; \
if(__strtok_1) \
  __strtok_t=__strtok_1; \
else \
  __strtok_o=__strtok_t; \
__strtok_o+=strspn(__strtok_o,__strtok_2); \
if(*__strtok_o!='\0') \
{ \
  __strtok_t=__strtok_o; \
  __strtok_t+=strcspn(__strtok_o,__strtok_2); \
  if(*__strtok_t!='\0') \
    *__strtok_t++='\0'; \
} \
else \
  __strtok_o=(char *)0;

char equalize(char);

int main (void)
{
  struct ExecBase *SysBase = (*((struct ExecBase **) 4));
  struct DosLibrary *DOSBase;
  struct RDArgs *rdargs;
  long argv[1];
  long rc = 5;
  BPTR myfile;
  BPTR prefsfile;
  long filesize;
  char *memory;
  long counter;
  char *strtokptr_a = NULL;
  char *strtokptr_b = NULL;
  char *subargv_a;
  char *subargv_b;


  if((DOSBase=(struct DosLibrary *)OpenLibrary("dos.library", 36L)) != NULL)
  {      
    memset((char *)argv, 0, sizeof(argv));
  
    rdargs = ReadArgs("FILE/A", argv, NULL);
  
    if (rdargs)
    {
      if (argv[0])
      {
        if ((myfile = Open((char*)argv[0],MODE_OLDFILE)) != NULL)
        {
          Seek(myfile,0,OFFSET_END);

          if ((filesize = Seek(myfile,0,OFFSET_BEGINNING)) > 0);
          {
            if ((memory = AllocVec(filesize + 1, MEMF_ANY | MEMF_CLEAR)) != NULL)
            {
              rc = 0;
              Read(myfile, memory, filesize);
   
              for (counter = 0; counter < filesize; counter++)
              {

                memory[counter] = equalize(memory[counter]);

                if ((memory[counter] != 'a' && memory[counter] != 'b' && memory[counter] != 'c' &&
                     memory[counter] != 'd' && memory[counter] != 'e' && memory[counter] != 'f' &&
                     memory[counter] != 'g' && memory[counter] != 'h' && memory[counter] != 'i' &&
                     memory[counter] != 'j' && memory[counter] != 'k' && memory[counter] != 'l' &&
                     memory[counter] != 'm' && memory[counter] != 'n' && memory[counter] != 'o' &&
                     memory[counter] != 'p' && memory[counter] != 'q' && memory[counter] != 'r' &&
                     memory[counter] != 's' && memory[counter] != 't' && memory[counter] != 'u' &&
                     memory[counter] != 'v' && memory[counter] != 'w' && memory[counter] != 'x' &&
                     memory[counter] != 'y' && memory[counter] != 'z' && memory[counter] != '1' &&
                     memory[counter] != '2' && memory[counter] != '3' && memory[counter] != '4' &&
                     memory[counter] != '5' && memory[counter] != '6' && memory[counter] != '7' &&
                     memory[counter] != '8' && memory[counter] != '9' && memory[counter] != '0' &&
                     memory[counter] != '=' && memory[counter] != '(' && memory[counter] != ')' &&
                     memory[counter] != '|'))
                  memory[counter] = ' ';

              }           

              STRTOK_M(memory, " ", strtokptr_a, subargv_a);

              while (subargv_a)
              {
                if ((strstr(subargv_a, "display=")) && (!(strstr(subargv_a, "("))))
                {
                  if ((prefsfile = Open("env:sys/screenmode.prefs",MODE_NEWFILE)) != NULL)
                  {
                    STRTOK_M(subargv_a, "=", strtokptr_b, subargv_b);
                    STRTOK_M(NULL, "=", strtokptr_b, subargv_b);

                    if (subargv_b)
                    {
                      if (strcmp("pal",subargv_b) == NULL)
                      {
                        SetVar("DISPLAY", "029004", 6, GVF_LOCAL_ONLY);
                        Write(prefsfile,SCREENPREFS_A""SCREENPREFS_PAL""SCREENPREFS_B,62);
                      }
                      else if (strcmp("ntsc",subargv_b) == NULL)
                      {
                        SetVar("DISPLAY", "019004", 6, GVF_LOCAL_ONLY);
                        Write(prefsfile,SCREENPREFS_A""SCREENPREFS_NTSC""SCREENPREFS_B,62);
                      }
                      else
                      {
                        SetVar("DISPLAY", "099004", 6, GVF_LOCAL_ONLY);
                        Write(prefsfile,SCREENPREFS_A""SCREENPREFS_DBLNTSC""SCREENPREFS_B,62);
                      }
                    }
                    else
                    {
                      SetVar("DISPLAY", "019004", 6, GVF_LOCAL_ONLY);
                        Write(prefsfile,SCREENPREFS_A""SCREENPREFS_NTSC""SCREENPREFS_B,62);
                    }

                    Close(prefsfile);
                  }
                }

                if ((strstr(subargv_a, "fblit=")) && (!(strstr(subargv_a, "("))))
                {
                  STRTOK_M(subargv_a, "=", strtokptr_b, subargv_b);
                  STRTOK_M(NULL, "=", strtokptr_b, subargv_b);

                  if (subargv_b)
                  {
                    if (strcmp("0",subargv_b) == NULL)
                      SetVar("FBLIT", "0", 1, GVF_LOCAL_ONLY);
                    else
                      SetVar("FBLIT", "1", 1, GVF_LOCAL_ONLY);
                  }
                  else
                    SetVar("FBLIT", "0", 1, GVF_LOCAL_ONLY);
                }

                if ((strstr(subargv_a, "fscreen=")) && (!(strstr(subargv_a, "("))))
                {
                  STRTOK_M(subargv_a, "=", strtokptr_b, subargv_b);
                  STRTOK_M(NULL, "=", strtokptr_b, subargv_b);

                  if (subargv_b)
                  {
                    if (strcmp("0",subargv_b) == NULL)
                      SetVar("FSCREEN", "0", 1, GVF_LOCAL_ONLY);
                    else
                      SetVar("FSCREEN", "1", 1, GVF_LOCAL_ONLY);
                  }
                  else
                    SetVar("FSCREEN", "0", 1, GVF_LOCAL_ONLY);
                }

                STRTOK_M(NULL, " ", strtokptr_a, subargv_a);
              }

              FreeVec(memory);     
            }
          }

          Close(myfile);
        }
      }
  
      FreeArgs(rdargs);
    }
    else
      FPuts(Output(), " *** template: ctrlparser <CTRL.info>\n");
  
    CloseLibrary((struct Library *)DOSBase);
  }

  return rc;
}

char equalize(char chr)
{
  if ((chr >= 'A') && (chr <= 'Z'))
    return (char)(chr + 32);

  return (char)chr;
}
