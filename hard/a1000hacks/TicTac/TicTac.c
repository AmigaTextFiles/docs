/*************************************************************************/
/* TicTac.c     Betriebsprogramm zum Lesen und Stellen einer             */
/*              Hardwareuhr am Joystickport#2 am A1000                   */
/*              c't 1987, Heft 8                                         */
/*                                                                       */
/*              Funktion:                                                */
/*                TicTac         Zeit und Datum des Uhrenchips anzeigen  */
/*                TicTac load    Chip lesen und Systemzeit stellen       */
/*                TicTac save    Systemzeit lesen und Chip stellen       */
/*                                                                       */
/*              Optimierte Version von A. Peter, 10.01.1992              */
/*************************************************************************/


#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/memory.h>
#include <exec/interrupts.h>
#include <exec/libraries.h>
#include <exec/tasks.h>
#include <exec/io.h>
#include <exec/devices.h>
#include <devices/timer.h>
#include <libraries/dos.h>


#define DATRX 0x1000
#define OUTRX 0x2000
#define DATRY 0x4000
#define OUTRY 0x8000

#define OnlyBit7   '\200'
#define AllButBit7 '\177'

#define SELECT          WritePotgo(0x2000,SelectMask)
#define DESELECT        WritePotgo(0x3000,SelectMask)
#define CLOCKHIGH       WritePotgo(0x8000,ClockMask)
#define CLOCKLOW        WritePotgo(0xC000,ClockMask)
#define SETDATATOINPUT  *myddrao &= AllButBit7

struct TimeAndDate {
   int TDhours;
   int TDminutes;
   int TDseconds;
   int TDday_of_week;
   int TDdate;
   int TDmonth;
   int TDyear;
   };

struct DosLibrary *DOSBase;

APTR *PotgoBase;
char *myddrao;
char *myprao;

extern struct MsgPort *CreatePort();
extern struct IORequest *CreateExtIO();

struct TimeAndDate ToBeRead,ToBeWritten;

UWORD allocated,bits;
char  firedata;

SelectMask = DATRX | OUTRX;
ClockMask  = DATRY | OUTRY;

LONG monthseconds[] = {
   0L,0L,      2678400L,  5097600L,  7776000L,
   10368000L, 13046400L, 15638400L, 18316800L,
   20995200L, 23487200L, 26265600L, 28857600L };

void                               /* Routinen zum Datenleitung (FIRE) */
DataHigh()                         /* auf HIGH oder LOW legen          */
   {
      *myddrao |= OnlyBit7;
      *myprao  |= OnlyBit7;
   }

void
DataLow()
   {
      *myddrao |= OnlyBit7;
      *myprao  &= AllButBit7;
   }

char                         
IntToBCD(value)                    /* Umwandlung des Integer-Formats */
   int value;                      /* in für den Chip verständliches */
   {                               /* BCD-Format */

      return((((value % 100 - value %10)/10)<<4)+ value % 10);
   }

int                                /* Gegenteil von IntToBCD()       */
BCDToInt(decimal)
   char decimal;
   {
      return (((decimal >>4)& '\017')*10 + (decimal & '\017'));
   }

void                               /* Löschen des eigenen TimerPorts */
DeleteTimer(tr)
   struct timerequest *tr;
   {
      struct MsgPort *tp;

         tp = tr->tr_node.io_Message.mn_ReplyPort;
         if(tp != NULL)
            DeletePort(tp);
         CloseDevice(tr);
         DeleteExtIO(tr,sizeof(struct timerequest));

   }


struct timerequest *               /* Eigenen TimerPort erstellen    */
CreateTimer(unit)
   ULONG unit;
   {

      int error;
      struct MsgPort *timerport;
      struct timerequest *timermsg;

      timerport = CreatePort(0,0);
      if(timerport == NULL) return(NULL);

      timermsg = (struct timerequest *)
            CreateExtIO(timerport,sizeof(struct timerequest));
      if(timermsg == NULL) return(NULL);

      error = OpenDevice(TIMERNAME,unit,timermsg,0);
      if(error != 0) {
         DeleteTimer(timermsg);
         return(NULL);
      }
      return(timermsg);

   }

int                                 /* Diese Funktion ist für das Timing */
MicroDelay(MicroSeconds)            /* mit dem Chip verantwortlich, sie  */
   int MicroSeconds;                /* wartet ca. 300ms, dann wird der   */
   {                                /* nächste Befehl abgearbeitet       */

      struct timeval currentval;
      struct timerequest *tr;

      currentval.tv_secs = 0;
      currentval.tv_micro = MicroSeconds;

      if((tr = CreateTimer(UNIT_MICROHZ)) == NULL)
         return(-1);
      tr->tr_node.io_Command = TR_ADDREQUEST;
      tr->tr_time = currentval;

      DoIO(tr);
      DeleteTimer(tr);
      return(0);
   }

void        /* Diese Funktion gibt einen Takt aus */
outdata()
   {

      CLOCKHIGH;
      MicroDelay(300);
      CLOCKLOW;
      MicroDelay(300);
   }

void
WriteTicTac()       /* Stellen von TicTac */
   {

      register int i,j;
      char TicTacTime[8];

      TicTacTime[1] = IntToBCD(ToBeWritten.TDhours);
      TicTacTime[2] = IntToBCD(ToBeWritten.TDminutes);
      TicTacTime[3] = IntToBCD(ToBeWritten.TDdate);
      TicTacTime[4] = IntToBCD(ToBeWritten.TDmonth);
      TicTacTime[5] = IntToBCD(ToBeWritten.TDyear);
      TicTacTime[6] = IntToBCD(ToBeWritten.TDday_of_week);
      TicTacTime[7] = IntToBCD(ToBeWritten.TDseconds);

      SELECT;
      MicroDelay(300);
      DataHigh();

      for(i=1;i<4;i++)
         outdata();

      DataLow();
      outdata();

      for(i=1;i<8;i++)
         for(j=0;j<8;j++) {
            if(TicTacTime[i] & ('\001' << 7-j))
               DataHigh();
            else
               DataLow();
            outdata();
         }

      DESELECT;
   }

int               /* Lesen von TicTac */
ReadTicTac()
   {

      register int i,j;
      char TicTacTime[8];

      SELECT;
      MicroDelay(300);
      DataHigh();

      for (i=1;i<6;i++)
         outdata();

      SETDATATOINPUT;

      for(i=1;i<8;i++) {
         TicTacTime[i] = '\000';
         for(j=0;j<8;j++) {
            outdata();
            firedata = *myprao;
            firedata = firedata & OnlyBit7;
            firedata = (firedata >> 7-j) & ('\001'<<j);
            TicTacTime[i] = TicTacTime[i] | firedata;
         }
      }

      DESELECT;

      ToBeRead.TDhours     = BCDToInt(TicTacTime[1]);
      ToBeRead.TDminutes   = BCDToInt(TicTacTime[2]);
      ToBeRead.TDdate      = BCDToInt(TicTacTime[3]);
      ToBeRead.TDmonth     = BCDToInt(TicTacTime[4]);
      ToBeRead.TDyear      = BCDToInt(TicTacTime[5]);
      ToBeRead.TDday_of_week=BCDToInt(TicTacTime[6]);
      ToBeRead.TDseconds   = BCDToInt(TicTacTime[7]);

      if(ToBeRead.TDhours == 165 && ToBeRead.TDyear == 165)
         return(-1);

      return(0);

   }

void                    /* Diese Prozedur wandelt das Systemdatum der */
CalcDate(seconds)       /* Amiga in ein "normales" Datum              */
   LONG seconds;
   {

      int y,year,i;

      year=78;
      y=1;

      while(y==1)
         if (year % 4 == 0 )            /* Schaltjahr */
            if (seconds >= 31622400L) {
              ++year;
              seconds -= 31622400L;
            }
            else
              y = 86400;
         else                           /* kein Schaltjahr */
            if(seconds >= 31536000L) {
                ++year;
                seconds -= 31536000L;
            }
            else
              y = 0;

      ToBeWritten.TDyear = year;

      i = 12;
      do {
           if( i <= 2) y = 0;

           if(seconds >= monthseconds[i]+y)
             year = -1;
           else
             --i;
         }while(year != -1);

      ToBeWritten.TDmonth = i;

      seconds -= (monthseconds[i]+y);

      ToBeWritten.TDdate = seconds / 86400L + 1;
      seconds -= ((ToBeWritten.TDdate-1)*86400L);

      ToBeWritten.TDhours = seconds / 3600;
      seconds -= ToBeWritten.TDhours * 3600;

      ToBeWritten.TDminutes = seconds / 60;
      seconds -= ToBeWritten.TDminutes * 60;

      ToBeWritten.TDseconds = seconds;

      ToBeWritten.TDday_of_week = 0;         /* Wochentag wird ignoriert */

   }

LONG
CalcSeconds(month,year)       /* Umwandlung des Jahres und Monats in  */
   int month,year;            /* Sekunden seit dem 01.01.78           */
   {

      register int y;
      LONG seconds = 0L;

      for(y=78;y<year;y++)
         if(y%4 == 0 )                 /* Schaltjahr */
            seconds += 31622400L;
         else
            seconds += 31536000L;

      if ((y%4 == 0) && (month > 2))
            seconds += 86400L;

      seconds += monthseconds[month];

      return(seconds);
   }

int                  /* SetNewTime() stellt die Uhr der Amiga neu */
SetNewTime(secs)
   LONG secs;
   {

      struct timerequest *tr;

      if((tr = CreateTimer(UNIT_MICROHZ)) == NULL) return(-1);

      tr->tr_node.io_Command = TR_SETSYSTIME;
      tr->tr_time.tv_secs = secs;
      tr->tr_time.tv_micro = 0;

      DoIO(tr);
      DeleteTimer(tr);
      return(0);
   }

int
GetSystemTime(tv)       /* GetSystemTime() liest die Uhr der Amiga */
   struct timeval *tv;
   {

      struct timerequest *tr;
      if((tr = CreateTimer(UNIT_MICROHZ)) == NULL )return(-1);

      tr->tr_node.io_Command = TR_GETSYSTIME;
      DoIO(tr);

      *tv = tr->tr_time;

      DeleteTimer(tr);
      return(0);

   }

char           /* Wird von Ausgabe() zur Konvertierung des TimeAndDate- */
Zehnerrest(a)  /* struct in eine Zeichenkette verwendet */
   int a;

   {
      return(a % 10 + '0');
   }

void           /* Ausgabe() gibt das Datum und die Zeit im deutschen    */
Ausgabe()      /* Format (mit führenden Nullen) aus.                    */
   {

      char Zeile[] = "\n\2331;33mE050-C16\2330m:   .  .    ,   :  .   Uhr\n";
      int z;

      z = ToBeRead.TDdate;
      Zeile[21] = Zehnerrest(z);
      Zeile[20] = Zehnerrest(z/=10);

      z = ToBeRead.TDmonth;
      Zeile[24] = Zehnerrest(z);
      Zeile[23] = Zehnerrest(z/=10);

      z = ToBeRead.TDyear+1900;
      Zeile[29] = Zehnerrest(z);
      Zeile[28] = Zehnerrest(z/=10);
      Zeile[27] = Zehnerrest(z/=10);
      Zeile[26] = Zehnerrest(z/=10);

      z = ToBeRead.TDhours;
      Zeile[33] = Zehnerrest(z);
      Zeile[32] = Zehnerrest(z/=10);

      z = ToBeRead.TDminutes;
      Zeile[36] = Zehnerrest(z);
      Zeile[35] = Zehnerrest(z/=10);

      z = ToBeRead.TDseconds;
      Zeile[39] = Zehnerrest(z);
      Zeile[38] = Zehnerrest(z/=10);

      /* Auf printf() wird verzichtet, da es unnötig Speicher frißt.   */
      /* Statt dessen wird die normale DOS-Funktion Write() verwendet. */
      /* Auch die restlichen Ausgaben erfolgen mit Write()!.           */

      Write(Output(),Zeile,45);

   }


void
main(argc,argv)
   int argc;
   char *argv[];
   {

   struct timeval currentval;
   LONG SysSeconds;
   int ticErr=0;

   myddrao = (char *)0xbfe2ffL;
   myprao =  (char *)0xbfe0ffL;

   if(!(DOSBase = (struct DosLibrary *)
            OpenLibrary("dos.library",0L))) exit(30);

   if((PotgoBase = (APTR *)OpenResource("potgo.resource")) == NULL)
      {
         Write(Output(),"\2331;33mE050-C16\2330m: OpenResource 'potgo.resource' failed.\n",57);
         ticErr = 26;
         goto ErrExit;
      }

   bits = DATRX | DATRY | OUTRX | OUTRY;

   allocated = AllocPotBits(bits);

   if(allocated != bits) {
      Write(Output(),"\2331;33mE050-C16\2330m: AllocPotBits() failed.\n",42);
      ticErr = 21;
      goto ErrExit;
      }

   DESELECT;
   CLOCKLOW;

   if(argc == 1)
    {
      if(ReadTicTac() == -1) {
        Write(Output(),"\2331;33mE050-C16:\2330m\n",19);
        Write(Output(),"TicTac kann Zeit nicht lesen.\n",30);
        ticErr = 11;
        goto ErrExit;
      }

      Ausgabe();

    }
   else if (*argv[1] == 'l' || *argv[1] == 'L') {
      if(ReadTicTac() == -1) {
        Write(Output(),"\2331;33mE050-C16:\2330m\n",19);
        Write(Output(),"TicTac kann Zeit nicht lesen.\n",30);
        Write(Output(),"Systemzeit nicht aktualisiert!\n",31);
        ticErr = 12;
        goto ErrExit;
      }

      SysSeconds =   CalcSeconds(ToBeRead.TDmonth,ToBeRead.TDyear) +
                     (LONG)ToBeRead.TDseconds +
                     (LONG)ToBeRead.TDminutes * 60L +
                     (LONG)ToBeRead.TDhours * 3600L +
                     (LONG)(ToBeRead.TDdate-1)*86400L;

      if(SetNewTime(SysSeconds) == -1) {
        Write(Output(),"\2331;33mE050-C16\2330m: SetSystemTime failed.\n",41);
        ticErr = 13;
        goto ErrExit;
      }

      Ausgabe();

      }
   else if (*argv[1] == 's' || *argv[1] == 'S') {
      if(GetSystemTime(&currentval) == -1) {
        Write(Output(),"\2331;33mE050-C16\2330m: GetSysTime() failed.\n",40);
        ticErr = 10;
        goto ErrExit;
      }

      CalcDate(currentval.tv_secs);
      WriteTicTac();
      Write(Output(),"TicTac gestellt!\n",17);

      }
   else
      Write(Output(),"AUFRUF: TicTac [load][save]\n",28);


ErrExit:
   if(ticErr < 30)
        SETDATATOINPUT;
   if(ticErr < 25)
        FreePotBits(allocated);

   CloseLibrary(DOSBase);

   /****************************************************************/
   /* Fehlercodes:                                                 */
   /* ------------                                                 */
   /*  0:   TicTac ordentlich beendet,                             */
   /* 10:   Systemzeit konnte nicht gelesen werden,                */
   /* 11:   Chip konnte nicht gelen werden (Uhr angeschlossen ?),  */
   /* 12:   dto. beim Versuch Systemzeit nach Chip zu stellen,     */
   /* 13:   Systemzeit konnte nicht verändert werden,              */
   /* 21:   AllocPortBits() lieferte Fehler,                       */
   /* 26:   'potgo.resource' konnte nicht geöffnet werden,         */
   /* 30:   DOS konnte nicht geöffnet werden (?!).                 */
   /****************************************************************/

   exit(ticErr);
   }

