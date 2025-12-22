
/*
 *  ADDMEM (c)Copyright 1991 by Tobias Ferber.  Alle Rechte vorbehalten.
 *
 *  Modifiziert am Sat Aug 15 02:19:32 1992
 *   + ADDMEM kann jetzt die vorhanden memory areas ausgeben
 *   + Seit heute steht ADDMEM unter der Obhut von RCS ;)
 *  Sun Feb 14 03:12:23 1993
 *   + cheatboard() added.
 */

#include <exec/types.h>
#include <exec/memory.h>
#include <exec/execbase.h>
#include <libraries/expansion.h>
#include <libraries/configregs.h>
#include <libraries/configvars.h>
#include <stdio.h>

extern struct ExecBase *SysBase;
struct ExpansionBase *ExpansionBase;

BOOL ExistMem(lower,upper)
/*
 *  ExistMem() schaut in der MemList nach ob es bereits einen
 *  Speicherbereich gibt, der die Einbindung eines Bereiches von
 *  <lower> bis <upper> verbietet.  Dies ist genau dann der Fall,
 *  wenn dort ein Speicherbereich S existiert, der Teil- oder
 *  Obermege von [lower..upper] ist.  In diesem Fall ist ExistMem()
 *  TRUE, andrenfalls FALSE.
 */
long lower;  /* untere /         Grenze des zu testenden */
long upper;  /*       /  obere   Bereichs                */
{
  struct MemHeader *mh;
  long u,l;

  BOOL overlap= FALSE;

  Forbid();
  for(mh = (struct MemHeader *)SysBase->MemList.lh_Head;
      mh->mh_Node.ln_Succ;
      mh = (struct MemHeader *)mh->mh_Node.ln_Succ)
  {
    l= (long)mh->mh_Lower;
    u= (long)mh->mh_Upper;

    overlap |= (l< lower && u> lower ||
                l< upper && u> upper ||
                l>=lower && u<=upper );
  }
  Permit();

  return(overlap);
}

BOOL SafeAddMemList(size, attributes, pri, base, name)
/*
 *  SafeAddMemList() klinkt einen Speicherblock in die Liste
 *  des Systempools ein.  Die Parameter und deren Bedeutung
 *  sind die identisch mit denen von EXEC's AddMemList().
 *  Im Unterschied zu AddMemList() wird hier ueberprueft ob
 *  schon Speicher in dem angegebenen Bereich vorhanden ist.
 *  Ausserdem wird der Name des Speicherbereichs in einen
 *  PUBLIC bereich kopiert, kann also nach dem Funktionsaufruf
 *  wieder freigegeben werden.
 */
ULONG size;        /* groesse des Speicherbereichs (in Bytes) */
ULONG attributes;  /* MEMF_XXXX Typ des Pools */
LONG pri;          /* Je hoeher die Prioritaet (CHIP hat -10) desto
                    * naeher liegt der Speicher am Listenkopf
                    */
APTR base;         /* Startadresse des Speicherbereichs */
STRPTR name;       /* (optionaler) Name fuer den Speicherbereich */
{
  BOOL fail= ExistMem((long)base,(long)base+size);
  char *s= (char *)NULL;

  if(!fail)
  {
    if(strlen(name) > 0)
    { s= (char *)AllocMem(strlen(name)+1, MEMF_PUBLIC);  /* + EOS */
      strcpy(s,name);
    }
 
    AddMemList(size,attributes,pri,base,s);
  }

  return(fail);
}


#define EMAX 17  /* max. #of expansions */

void showmem()
{
  struct MemHeader *mh;
  long lower[EMAX],   /* lower memory bound */
       upper[EMAX];   /* upper memory bound */
  short attr[EMAX],   /* characteristics of this region */
        m=0;

  Forbid();
  for (mh = (struct MemHeader *)SysBase->MemList.lh_Head;
       mh->mh_Node.ln_Succ;
       mh = (struct MemHeader *)mh->mh_Node.ln_Succ)
  {
    if(m < EMAX)
    { lower[m]= (long)mh->mh_Lower;
      upper[m]= (long)mh->mh_Upper;
      attr[m]= (short)mh->mh_Attributes;
      ++m;
    }
  }
  Permit();

  while(--m >= 0)
  { printf("$%06lx..$%06lx:  ",lower[m],upper[m]);
    if(attr[m] & MEMF_PUBLIC)   printf("PUBLIC ");
    if(attr[m] & MEMF_CHIP)     printf("CHIP ");
    if(attr[m] & MEMF_FAST)     printf("FAST ");
    if(attr[m] & MEMF_LOCAL)    printf("LOCAL ");
    if(attr[m] & MEMF_24BITDMA) printf("24BITDMA ");
    if(attr[m] & MEMF_KICK)     printf("KICK ");
    if(attr[m]== MEMF_ANY)      printf("ANY");
    putchar('\n');
  }
}


long cheatboard(APTR base, long size)
{
  long panic=-1;

  static char *bsn[8]= {
    "8meg", "64k", "128k","256k", "512k", "1meg", "2meg", "4meg" };

  ExpansionBase= (struct ExpansionBase *)OpenLibrary(EXPANSIONNAME,0L);
  if(ExpansionBase)
  { struct ConfigDev *cd= (struct ConfigDev *)AllocConfigDev();
      /*AllocMem(sizeof(struct ConfigDev),MEMF_PUBLIC|MEMF_CLEAR);*/
    if(cd)
    { panic= ReadExpansionRom(0x200000,cd);

      if(panic==0)
      { cd->cd_BoardAddr = base;
        ConfigBoard(size,cd);
      }
      else
      {
        cd->cd_Flags= CDF_CONFIGME;  /* board needs a driver to claim it */
        cd->cd_Rom.er_Product= 0;    /* number assigned by manufacturer */

        /*
         * We'll use a special "hacker" Manufacturer ID number
         * which is reserved for test use: 2011 (0x07DB = -0xF824)
         * (Unique ID, ASSIGNED BY COMMODORE-AMIGA!)
         */

        cd->cd_Rom.er_Manufacturer= 2011;
        cd->cd_Rom.er_SerialNumber= panic; /* ;) */

        /*
         * board size: 0x00 =   8M
         *             0x01 =  64k
         *             0x02 = 128k
         *             0x03 = 256k
         *             0x04 = 512k
         *             0x05 =   1M
         *             0x06 =   2M
         *             0x07 =   4M
         */

        { long s,t;
          for(s= (size>>16) & 0xFFFF, t=0; s>0; s>>=1, (t++)%=8)
            ;
          cd->cd_Rom.er_Type= t | ERT_NEWBOARD | ERTF_MEMLIST;
        }

        cd->cd_BoardAddr= base;  /* where in mem the board was placed */
        cd->cd_BoardSize= size;  /* size of board in bytes */
        cd->cd_SlotAddr= 0x60;
        cd->cd_SlotSize= 32;

        AddConfigDev(cd);
      }
      printf("%d/%d board cheated @$%06lx w/ %s Mem.\n",
        cd->cd_Rom.er_Manufacturer,
        cd->cd_Rom.er_SerialNumber,
        cd->cd_BoardAddr,
        bsn[cd->cd_Rom.er_Type & 7] );
    }
    CloseLibrary(ExpansionBase);
  }
  return(panic);
}

/*------------------------------------------------------------------------*/

const char *wasgehtdennhier=
  "$Id: addmem.c,v 1.2 93/02/14 04:27:30 tf Exp $\n"
  "(c)Copyright 1991 by Tobias Ferber, All Rights Reserved.\n"
  "ADDMEM <lower-hex> <upper-hex> [-p <pri>] [-n <name>] [-a <attr>]";

/*------------------------------------------------------------------------*/

void main(int argc, char *argv[])
{
  char *name= (char *)NULL;

  long start  = 0,
       end    = 0,
       pri    = 0,
       lie    = 0,
       attr   = MEMF_FAST|MEMF_PUBLIC;

  BOOL fuckit= FALSE;

  if(argc>1)
  { --argc;
    ++argv;

    while(argc>0 && !fuckit)
    { char *arg= argv[0];
      if(*arg=='-')
      { arg++;
        switch(*arg)
/**/    { case 'p': case 'P':
            if(arg[1]) pri= atol(&arg[1]);
            else { argv++;
                   argc--;
                   if(argc>0) pri= atol(argv[0]);
                   else pri=0;
                 }
            if(pri<-128 || pri>127)
            { puts("Invalid priority %d, should be in [-128..127]");
              fuckit=TRUE;
            }
            break;
/**/      case 'a': case 'A':
            if(arg[1]) attr= atol(&arg[1]);
            else { argv++;
                   argc--;
                   if(argc>0) attr= atol(argv[0]);
                   else attr= MEMF_FAST|MEMF_PUBLIC;
                 }
            break;
/**/      case 'n': case 'N':
            if(arg[1]) name= &arg[1];
            else { argv++;
                   argc--;
                   if(argc>0) name= argv[0];
                   else name= (char *)NULL;
                 }
            break;
          case 'b': case 'B':  lie=1;
                               break;
/**/      default:  printf("bad option -%c.\n",*arg);
                    fuckit=TRUE;
                    break;
        }
      }
      else if(*arg=='?')
      { showmem();
        exit(0);
      }
      else if(start==0 || end==0)
      {
        long t;
        if(arg[0]=='$') arg= &arg[1];
        else if(arg[0]=='0' && (arg[1]=='x' || arg[1]=='X')) arg= &arg[2];
        sscanf(arg,"%lx",&t);
        if(t&1) { puts("Address error.");
                  fuckit=TRUE;
                }
        if(start==0) start=t;
        else end=t;
      }
      else fuckit=TRUE;
      --argc;
      ++argv;
    }
    fuckit |= (start==0 || end==0);

    if(!fuckit)
    { if( fuckit= SafeAddMemList( end-start,
                                  MEMF_FAST|MEMF_PUBLIC,
                                  pri,
                                  (APTR)start,
                                  name) )
      { puts("Failure -- memory area already exists.");
        showmem();
      }
      else printf("%ld bytes added to the system free pool.\n",end-start);
      if(lie) cheatboard((APTR)start,end-start);
    }
  }
  else puts(wasgehtdennhier);  /* no args */
  exit(fuckit?20:0);
}
