/*
 *  yKick.c
 *
 *  (c)Copyright 1992,93 by Tobias Ferber,  All Rights Reserved.
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <fcntl.h>
#include <stdio.h>

/* default values */
#define KICKORG  0x200000
#define KICKWOM  0xF80000 /* 0xFC0000 */
#define KICKSIZE (512*1024)

extern void reset(long,long);
extern void patch(long,long,long,long,long);

static char rcs_id[]= "$VER: $Id: ykick.c,v 1.1 93/02/25 01:15:08 tf Exp $";
#define BANNER &rcs_id[6]

/*
 *   kickload -- load a ZKick file to a fix address
 *   result is 0 in case of an error, != 0 otherwise
 */

int kickload(char *fname, long fmem)  /* 0= error */
{
  int ok= 0,
      fh= open(fname,O_RDONLY);

  if(fh >= 0)
  { long fsize;
    fsize= lseek(fh,0,SEEK_END);
    if(fsize==KICKSIZE+8)
    { printf("Loading \"%s\" (%ld-8 bytes) to $%06lx, ",fname,fsize,fmem);
      fflush(stdout);
      lseek(fh,8,SEEK_SET); /* skip 0x00000000, 0x00080000 header */
      ok= read(fh,(void *)fmem,fsize-8);
      if(ok==fsize-8) puts("ok.");
      else
      { puts("error.");
        ok=0;
      }
    }
    else puts("Failure -- File is not A2000/500 Kickstart V37.175");
    close(fh);
  }
  else printf("Can't open %s\n",fname);

  return(ok);
}

/*
 *   kicksave -- save a A1000 kickstart file
 *   result is 0 in case of an error, != 0 otherwise
 */

int kicksave(char *fname, long fmem)
{
  int ok= 1,
      fh= open(fname,O_RDONLY);
   
  if(fh >= 0)
  { char c;
    close(fh);
    printf("\"%s\" already exists, overwrite? (Y/n): ",fname);
    fflush(stdout);
    c= getchar();
    if(c=='n' && c=='N')
      ok=0;
  }

  if(ok)
  { fh= open(fname,O_WRONLY|O_CREAT);
    if(fh >= 0)
    { printf("Writing \"%s\" (%ld bytes) ",fname,KICKSIZE);
      fflush(stdout);
      ok= write(fh,(void *)fmem,KICKSIZE);
      if(ok==KICKSIZE) puts("ok.");
      else
      { puts("error.");
        ok=0;
      }
      close(fh);
    }
    else
    { printf("Can't open %s\n",fname);
      ok=0;
    }
  }
  return(ok);
}

/*
 *   reloc -- relocate a ZKick file for A1000 usage
 *
 *   The Kickfile loaded to 'loadmem' will be relocated using
 *   Daniel Zenchelsky's kickfile reloc table.  The lower 256k
 *   will be relocated to 'kickmem' -- the upper 256k to $fc0000
 */

void reloc(char *mem,  /* current location of the kickfile */
           long kick)  /* absolute memory origin 1st part */
{
  extern long rtable[]; /* ZKick relocation table */

  long r;  /* index for rtable[] */
  long *v;

  for(r=0; rtable[r]!=0; r++)
  { v= (long *)&mem[rtable[r]];
    *v-= KICKORG;
    if(*v<0x40000) *v+=kick;
    else *v+=KICKWOM;
  }
}

/*
 *   checksum -- compute the kickstart checksum
 */

long checksum(long *mem,      /* beg. of memory block */
              long numbytes)  /* must be a multiple of 4 */
{
  unsigned long s,t;

  for(s=0;numbytes>0;numbytes-=4)
  { t=s;
    s+=*mem++;
    if(s<t) ++s;
  }
  return(s^0xFFFFFFFF);
}


static char *howtouse[]= {
 "KICKFILE",   "/K", "-f", "force next argument to be the kickfile",
 "START",      "/N", "-s", "set begin of fast memory (default: $200000)",
 "END",        "/N", "-e", "set end of fast memory (default: $400000)",
 "TO",         "/K", "-o", "write relocated A1000 kickload file",
 "NORESET",    "/S", "-c", "load kickstart file but don't reboot",
 NULL, NULL, NULL, NULL
};


void main(int argc, char *argv[])
{
  char *kickfile= "DEVS:Kickstart";
  char *outfile= (char *)NULL;
  long startkick= 0x200000;
  long fastend= 0x400000;
  int reboot= 1;
  int badopt= 0;

  if(argc>1)
  {
    while(--argc>0 && !badopt)
    { char *arg= *++argv;
      if(isalpha(*arg))
      { char **aopt= &howtouse[0];
        while(*aopt && stricmp(arg,*aopt))
          aopt= &aopt[4];
        if(*aopt) arg= aopt[2];
      }

      if(*arg=='-')
      {
        switch(*++arg)
        {
/* -f */  case 'f': case 'F':
            if(arg[1]) ++arg;
            else arg= (--argc > 0) ? *(++argv) : (char *)0L;

            if(arg && *arg)
              kickfile= arg;
            else
            { puts("Missing input filename after keyword");
              badopt=1;
            }
            break;
/* -o */  case 'o': case 'O':
            if(arg[1]) ++arg;
            else arg= (--argc > 0) ? *(++argv) : (char *)0L;

            if(arg && *arg)
              outfile= arg;
            else
            { puts("Missing output filename after keyword");
              badopt=1;
            }
            break;

/* -s */  case 's': case 'S':
            if(arg[1]) ++arg;
            else arg= (--argc > 0) ? *(++argv) : (char *)0L;

            if(arg && *arg)
            { if(arg[0]=='$') arg= &arg[1];
              else if(arg[0]=='0' && (arg[1]=='x' || arg[1]=='X'))
                arg=&arg[2];
              sscanf(arg,"%lx",&startkick);
              if(startkick & 1)
              { puts("Address error.");
                badopt=1;
              }
              if(startkick < 0x200000)
              { puts("Can't load Kickstart into CHIP memory.");
                badopt=1;
              }
            }
            else
            { puts("Missing address after keyword");
              badopt=1;
            }
            break;
/* -e */  case 'e': case 'E':
            if(arg[1]) ++arg;
            else arg= (--argc > 0) ? *(++argv) : (char *)0L;

            if(arg && *arg)
            { if(arg[0]=='$') arg= &arg[1];
              else if(arg[0]=='0' && (arg[1]=='x' || arg[1]=='X'))
                arg=&arg[2];
              sscanf(arg,"%lx",&fastend);
              if(fastend & 1)
              { puts("Address error.");
                badopt=1;
              }
            }
            else
            { puts("Missing address after keyword");
              badopt=1;
            }
            break;
/* -c */  case 'c': case 'C':
            reboot= 0;
            break;
          default:
            printf("bad option -%c.\n",*arg);
            badopt=1;
            break;
        }
      }
      else if(*arg=='?')
      { char **usage= &howtouse[0];
        while(*usage)
        { printf("%s%s,",usage[0],usage[1]);
          usage= &usage[4];
        }
        printf("\b:\n\n");
        usage= &howtouse[0];
        while(*usage)
        { printf("%-10s or '%s'  %s\n",usage[0],usage[2],usage[3]);
          usage= &usage[4];
        }
        exit(0);
      }
      else strcpy(kickfile,arg);
    }

    if(!badopt)
    { int freeme=1;

      long *ptr= (long *)AllocMem(KICKSIZE,MEMF_PUBLIC);
      if(!ptr && AvailMem(MEMF_FAST)==0)
      { ptr=(long *)0x200000;
        freeme=0;
      }

      if(ptr)
      { if(kickload(kickfile,(long)ptr))
        { 
          reloc((char *)ptr,startkick);
          patch((long)ptr,startkick,startkick+0x040000,fastend,0x000000);
          ptr[0x3fe00>>2]= checksum(&ptr[0x00000>>2],256*1024);
          ptr[0x7fe00>>2]= checksum(&ptr[0x40000>>2],256*1024);
          if(outfile && *outfile)
            (void)kicksave(outfile,(long)ptr);
          if(reboot) reset((long)ptr,startkick);
        }
        else badopt=1;
        if(freeme) FreeMem(ptr,KICKSIZE);
      }
      else puts("Not enough memory!");
    }
  }
  else /* no args */
  { puts(BANNER);
    puts("(c)Copyright 1992-93 by Tobias Ferber, All Rights Reserved");
    puts("Refer to YKICK.DOC for options.  ? for AmigaDOS help");
  }
  exit(badopt?20:0);
}
