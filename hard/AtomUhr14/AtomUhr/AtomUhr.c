/*
           Dieses Source wurde mit der Programmier-Umgebung CSH V4.17
                   von M.Bühler und S.Glükler geschrieben.

  #########################################################################

   Programmname : AtomUhr
   Version      : 1.4
   Autor        : S. Glükler (gluekler@swissonline.ch)
   Datum        : 29.01.00
   Beschreibung : Einlesen und Dekodieren des DCF77 Empfaenger-Moduls
   Update       : 1.4 Jahr 2000 bugfix

   Compilieren mit Aztec V5.2d :

              cc AtomUhr -md -mc -w0w -wn -wu -wr -wp -pb -sa -sb -sf -sm
              ln AtomUhr +q -lcl

  #########################################################################

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <workbench/startup.h>
#include <hardware/custom.h>
#include <hardware/cia.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/icon_protos.h>
#include <clib/graphics_protos.h>
#include <clib/intuition_protos.h>
#include <clib/alib_protos.h>
#include <pragma/dos_lib.h>
#include <pragma/exec_lib.h>
#include <pragma/icon_lib.h>
#include <pragma/graphics_lib.h>
#include <pragma/intuition_lib.h>


#define WINDOW_GROESSE_X	310	/* Window Groesse-X			*/
#define WINDOW_GROESSE_Y	23	/* Window Groesse-Y			*/

#define DEBUG_WINDOW_GROESSE_Y	28	/* Window Groesse-Y bei Debug-Mode	*/
#define DEBUG_OFFSET_X		5	/* X-Offset der Grafik bei Debug-Mode	*/
#define DEBUG_OFFSET_Y		21	/* Y-Offset der Grafik bei Debug-Mode	*/
#define DEBUG_GROESSE_Y		3	/* Y-Groesse der Grafik bei Debug-Mode	*/

#define DEFAULT_DEBUG		0	/* Debug-Mode nicht aktiv		*/
#define DEFAULT_PORT		0	/* Welcher Pin bei Joystickport		*/
#define DEFAULT_FENSTER_X	30	/* Window X-Kordinate			*/
#define DEFAULT_FENSTER_Y	15	/* Window Y-Kordinate			*/
#define DEFAULT_AUSGABE		1	/* Window-Ausgabe aktiv			*/
#define DEFAULT_VERGLEICH	0	/* Sicherheits-Check aktiv		*/
#define DEFAULT_PRIORITAET	100	/* Prioritaet des Programms		*/
#define DEFAULT_MAX_SUCHEZEIT	600	/* Maximale Suchezeit in [s]		*/
#define DEFAULT_DOS_BEFEHL	""	/* Dos-Ausfuehrung nach dem Erkennen	*/

/* Makro zum setzen und anzeigen des Blockstatus */
#define SET_BLOCKSTATUS(blkstatus)	blockstatus=blkstatus; WriteText(blockstatus_text[blockstatus],3);

/* Makro zum Anzeigen und warten bei einem Fehler */
#define SET_ERRORTEXT(errnr)		WriteText(error_text[errnr],2); Delay(120);

/* Puls-Zeiten */
#define TIMER_DELAY		20	/* Abtastzeit des Ports [ms]		*/
#define TIMER_SYNCHLEN		1500	/* Minimale Synchronationszeit [ms]	*/
#define TIMER_PULS_BIT0_MIN	20	/* Minimale Pulsdauer fuer 0-Bit [ms]	*/
#define TIMER_PULS_BIT0_MAX	120	/* Maximale Plusdauer fuer 0-Bit [ms]	*/
#define TIMER_PULS_BIT1_MIN	140	/* Minimale Plusdauer fuer 1-Bit [ms]	*/
#define TIMER_PULS_BIT1_MAX	240	/* Maximale Plusdauer fuer 1-Bit [ms]	*/

/* Blockstatus */
#define BLOCKSTATUS_VORBEREITUNG  0	/* Vorbereitung 			*/
#define BLOCKSTATUS_SUCHESTART	  1	/* Startpunkt suchen der Zeit		*/
#define BLOCKSTATUS_TIME	  2	/* Zeit-Block				*/
#define BLOCKSTATUS_TIMEOK	  3	/* Zeit-Block fertig uebertragen	*/
#define BLOCKSTATUS_ZEITVERGLEICH 4	/* Zeit-Vergleich			*/
#define BLOCKSTATUS_EXIT	  5	/* Programm Exit			*/

unsigned char *blockstatus_text[] =
{
	"Vorbereitung",				/* Vorbereitung			*/
	"Suche Zeitblock-Anfang ...",		/* Synchsuche			*/
	"Empfange Zeitblock ...",		/* Zeit-Block empfang		*/
	"Zeitblock fertig",			/* Zeit-Block ok		*/
	"Zeitblock für Vergleich ...",		/* Zeit-Vergleich		*/
	"Progamm-Exit"				/* Programm Exit		*/
};

struct bitcodierung
{
	unsigned char  AnzahlBits;	/* Total Anzahl Bits			*/
	unsigned char  AktBit;		/* Akt uebertagenes Bit			*/
	unsigned short ZahlenWert;	/* Akt Zahlenwert			*/
	unsigned char  ParityWert;	/* Paritywert dieses Blockes		*/
};

/* Bitbloecke */
#define ANZAHL_BITBLOECKE	15	/* Anzahl Bitbloecke bei der Codierung	*/

struct bitcodierung BitCodierung[ANZAHL_BITBLOECKE] =
{
	/* Anzahl Bits */
		21,	0,	0,	0,	/* 0.  Sonstiges		*/
		4,	0,	0,	0,	/* 1.  Minuten Low-Byte		*/
		3,	0,	0,	0,	/* 2.  Minuten High-Byte	*/
		1,	0,	0,	0,	/* 3.  Parity 1			*/
		4,	0,	0,	0,	/* 4.  Stunden Low-Byte		*/
		2,	0,	0,	0,	/* 5.  Stunden High-Byte	*/
		1,	0,	0,	0,	/* 6.  Parity 2			*/
		4,	0,	0,	0,	/* 7.  Tag Low-Byte		*/
		2,	0,	0,	0,	/* 8.  Tag High-Byte		*/
		3,	0,	0,	0,	/* 9.  Wochentag 		*/
		4,	0,	0,	0,	/* 10. Monat Low-Byte		*/
		1,	0,	0,	0,	/* 11. Monat High-Byte		*/
		4,	0,	0,	0,	/* 12. Jahr Low-Byte		*/
		4,	0,	0,	0,	/* 13. Jahr High-Byte		*/
		1,	0,	0,	0	/* 14. Parity 3			*/
};

/* Bitblocknummern */
#define BITBLOCK_MIN_LOW	1	/* Blocknummer fuer Minuten Low-Byte	*/
#define BITBLOCK_MIN_HIGH	2	/* Blocknummer fuer Minuten High-Byte	*/
#define BITBLOCK_PARITY_1	3	/* Blocknummer fuer Paritaet 1		*/
#define BITBLOCK_STD_LOW	4	/* Blocknummer fuer Stunden Low-Byte	*/
#define BITBLOCK_STD_HIGH	5	/* Blocknummer fuer Stunden High-Byte	*/
#define BITBLOCK_PARITY_2	6	/* Blocknummer fuer Paritaet 2		*/
#define BITBLOCK_TAG_LOW	7	/* Blocknummer fuer Tag Low-Byte	*/
#define BITBLOCK_TAG_HIGH	8	/* Blocknummer fuer Tag High-Byte	*/
#define BITBLOCK_WOCHENTAG	9	/* Blocknummer fuer Wochentag		*/
#define BITBLOCK_MONAT_LOW	10	/* Blocknummer fuer Monat Low-Byte	*/
#define BITBLOCK_MONAT_HIGH	11	/* Blocknummer fuer Monat High-Byte	*/
#define BITBLOCK_JAHR_LOW	12	/* Blocknummer fuer Jahr Low-Byte	*/
#define BITBLOCK_JAHR_HIGH	13	/* Blocknummer fuer Jahr High-Byte	*/
#define BITBLOCK_PARITY_3	14	/* Blocknummer fuer Paritaet 3		*/

/* Error-Codes */
#define ERROR_NONE			0	/* Kein Fehler			*/
#define ERROR_NO_LIBRARYS		1	/* Kann Library nicht oeffnen	*/
#define ERROR_NO_WINDOW			2	/* Kann Window nicht oeffnen	*/
#define ERROR_NO_TIMERPORT		3	/* Kein Timerport		*/
#define ERROR_NO_TIMERREQUEST		4	/* Kein Timerrequest		*/
#define ERROR_NO_TIMERDEVICE		5	/* Keine Timerdevice		*/
#define ERROR_SET_SYSTEMTIME		6	/* Kann Systemzeit nicht setzen	*/
#define ERROR_ZUWENIG_BITS		7	/* Zuwenig Bits gekommen	*/
#define ERROR_ZUVIEL_BITS		8	/* Zuviel Bits gekommen		*/
#define ERROR_TIME_CHECK_BEREICH	9	/* Time-Check falsch		*/
#define ERROR_TIME_CHECK_PARITY		10	/* Time-Check Parity falsch	*/
#define ERROR_TIME_CHECK_VERGLEICH	11	/* Time-Check vergleich falsch	*/
#define ERROR_BITTIME			12	/* Nicht erkannte Bitzeit	*/
#define ERROR_KEINEZEIT			13	/* Konnte Zeit nicht erkennen	*/
#define ERROR_PARAMTER			14	/* Falscher Parameter in Icon	*/

unsigned char *error_text[] =
{
	"",
	"Error : Kann System-Library nicht öffnen !",
	"Error : Kann Window nicht öffnen !",
	"Error : Kein TimerPort !",
	"Error : Kein TimerRequest !",
	"Error : Keine TimerDevice !",
	"Error : Kann Systemzeit nicht setzen !",
	"Error : Zuwenig Bits !",
	"Error : Zuviel Bits !",
	"Error : Zeitcheck falsch !",
	"Error : Zeitparity falsch !",
	"Error : Zeitvergleich falsch !",
	"Error : Bit nicht erkannt !",
	"Error : Keine gültige Zeit gefunden !",
	"Error : Falscher Parameter im Icon !"
};

/* Window */
struct NewWindow newwindow =
{
	DEFAULT_FENSTER_X,DEFAULT_FENSTER_Y,	/* Left- TopEdge	*/
	WINDOW_GROESSE_X,WINDOW_GROESSE_Y,	/* Width, Height	*/
	0,2,					/* Detail- Blockpen	*/
	CLOSEWINDOW,				/* IDCMP-Flags		*/
	WINDOWDEPTH|WINDOWCLOSE|WINDOWDRAG,	/* Flags		*/
	0,					/* FirstGadget		*/
	0,					/* CheckMark		*/
	"AtomUhr V1.4 (C) Stefan Glükler",	/* Titel		*/
	0,					/* Screen-Pointer	*/
	0,					/* Bitmap-Pointer	*/
	0,0,					/* MinWidth,MinHeight	*/
	0,0,					/* MaxWidth,MaxHeight	*/
	WBENCHSCREEN				/* Window-Type		*/
};

/* Prototypes */
unsigned char	OpenAll(void);
unsigned char	WindowOpen(void);
unsigned char	SetParameter(unsigned char *argument0,unsigned short arg_anz);
void		CloseAll(unsigned char error_nummer);
void		WriteText(unsigned char *text,unsigned short farbe);
void		WriteLine(unsigned short x1,unsigned short y1,unsigned short x2,unsigned short y2,unsigned short farbe);
unsigned char	SetSystem_Time(void);
void		Berechnung_Time(void);
unsigned char	Check_Time(void);
unsigned char	ReadPort(void);

/* Globale Variablen fuer Library & Devices */
unsigned char		open_device_timer	=0;
struct MsgPort		*myTimerPort		=0;
struct timerequest	*myTimer		=0;
struct Window		*window			=0;
struct GfxBase		*GfxBase		=0;
struct IntuitionBase	*IntuitionBase		=0;

/* Globale Variablen fuer aktuelle Zeit */
unsigned short time_sek,time_min,time_std,time_tag,time_monat,time_jahr;

/* Globale Variablen fuer letzte Zeit */
unsigned short letztetime_sek=0,letztetime_min=0,letztetime_std=0,letztetime_tag=0,letztetime_monat=0,letztetime_jahr=0;

/* Globale Variablen fuer Konfiguration */
unsigned char  DEBUG;
unsigned char  PORT;
unsigned char  AUSGABE;
unsigned char  VERGLEICH;
unsigned char  PRIORITAET;
unsigned short FENSTER_X;
unsigned short FENSTER_Y;
unsigned long  MAX_SUCHEZEIT;
unsigned char  DOS_BEFEHL[100];

int main(int argc, char **argv)
{
 struct IntuiMessage *msg;			/* Window-Message		*/
 register unsigned char PulsFlag;		/* Flag fuer Flankenerkennung	*/
 register unsigned long MiliSecZaehler=0;	/* Milisekunden-Zaehler		*/
 register unsigned char BitBlockNummer;		/* Akt. BitBlocknummer		*/
 unsigned char  blockstatus;			/* Aktueller Status		*/
 unsigned long  DifHighTime;			/* Berechnete High Pulslaenge	*/
 unsigned long  DifLowTime;			/* Berechnete Low Pulslaenge	*/
 unsigned long  StartZeit;			/* Startzeit der Flanke		*/
 unsigned long  EndZeit;			/* Endzeit der Flanke		*/
 unsigned char  PortWert;		        /* Portwert			*/
 unsigned char  error;				/* Errorcode			*/
 unsigned short graph_x=DEBUG_OFFSET_X;		/* Debug-Grafik-Ausgabe Kord.-X	*/
 unsigned char  filter_werte[3];		/* Filterwerte fuer Digitalf.	*/

  /* Setzen aller Programm-Parameter */
  if ((error=SetParameter(argv,argc))!=ERROR_NONE) CloseAll(error);

  /* Alles Initialiseren */
  if ((error=OpenAll())!=ERROR_NONE) CloseAll(error);

  /* Setzen der eigenen Taskprioritaet */
  SetTaskPri(FindTask(0),PRIORITAET);

  /* Status = Vorbereitung */
  SET_BLOCKSTATUS(BLOCKSTATUS_VORBEREITUNG);

  while(blockstatus!=BLOCKSTATUS_EXIT)
  {

    myTimer->tr_node.io_Command=TR_ADDREQUEST;
    myTimer->tr_time.tv_secs=0;
    myTimer->tr_time.tv_micro=TIMER_DELAY*1000;
    DoIO(myTimer); /* Warten der Portabtastzeit */

    /* Zeitcounter erhoehen */
    MiliSecZaehler+=TIMER_DELAY;

    if (window)
    {
      /* Abfragen der Window-Operationen */
      while (msg=(struct IntuiMessage *)GetMsg(window->UserPort))
      {
        if (msg->Class==CLOSEWINDOW)
        {
          /* Status = Exit */
          SET_BLOCKSTATUS(BLOCKSTATUS_EXIT);
        }
        ReplyMsg(msg);
      }
    }

    /* Suche Vorbereiten ? */
    if (blockstatus==BLOCKSTATUS_VORBEREITUNG)
    {

      /* Bitkodierungs-Struktur zuruecksetzen */
      for (BitBlockNummer=0;BitBlockNummer<ANZAHL_BITBLOECKE;BitBlockNummer++)
      {
        BitCodierung[BitBlockNummer].AktBit     = 0;  /* Aktuelles Bit          */
        BitCodierung[BitBlockNummer].ZahlenWert = 0;  /* Berechneter Zahlenwert */
        BitCodierung[BitBlockNummer].ParityWert = 0;  /* Berechneter Paritywert */
      }

      /* Filterwerte zuruecksetzen */
      filter_werte[0]=filter_werte[1]=filter_werte[2]=0;

      /* Bit-Blocknummer zurueckstellen */
      BitBlockNummer=0;

      /* Plusflag und Pulszeiten zurueckstellen */
      PulsFlag=0;
      StartZeit=EndZeit=MiliSecZaehler;

      /* Status = SucheStart */
      SET_BLOCKSTATUS(BLOCKSTATUS_SUCHESTART);

    }

    /* Filterwerte umkopieren */
    filter_werte[0]=filter_werte[1];
    filter_werte[1]=filter_werte[2];
    filter_werte[2]=ReadPort();

    /* Filterung */
    if (filter_werte[0]==1 && filter_werte[1]==0 && filter_werte[2]==1)
    {
      filter_werte[1]=1;
    }

    /* Aktueller Portwert setzen */
    PortWert=filter_werte[0];

    /* Debug-Ausgabe */
    if (DEBUG)
    {

      /* Linienfarbe je nach Portwert */
      if (PortWert==1) WriteLine(graph_x,DEBUG_OFFSET_Y,graph_x,DEBUG_OFFSET_Y+DEBUG_GROESSE_Y,2);
      else             WriteLine(graph_x,DEBUG_OFFSET_Y,graph_x,DEBUG_OFFSET_Y+DEBUG_GROESSE_Y,0);

      /* Grafik X-Kodinate erhoehen */
      graph_x++;

      /* Schreibe-Linie */
      WriteLine(graph_x,DEBUG_OFFSET_Y,graph_x,DEBUG_OFFSET_Y+DEBUG_GROESSE_Y,1);

      /* Grafik-X Window-Ende erreicht */
      if (graph_x>WINDOW_GROESSE_X-DEBUG_OFFSET_X-3)
      {
        /* Schreibe-Linie loeschen */
        WriteLine(graph_x,DEBUG_OFFSET_Y,graph_x,DEBUG_OFFSET_Y+DEBUG_GROESSE_Y,0);

        /* Grafik X-Kordinate zuruecksetzen */
        graph_x=DEBUG_OFFSET_X;
      }

    }

    if (PulsFlag==0 && PortWert==1) /* Flag=0 und Port=HIGH -> Flankenbegin */
    {

      PulsFlag=1;                   /* Flag auf Flankenbegin   */
      StartZeit=MiliSecZaehler;     /* Merken der Startzeit    */
      DifLowTime=StartZeit-EndZeit; /* Berechnung der Low-Zeit */

      switch(blockstatus)
      {

        /****************************************************************************/
        case BLOCKSTATUS_SUCHESTART:
        /****************************************************************************/

          /* Synch-Start gefunden */
          if (DifLowTime>TIMER_SYNCHLEN)
          {

            /* Status = Zeit */
            SET_BLOCKSTATUS(BLOCKSTATUS_TIME);

          }

        break;

        /****************************************************************************/
        case BLOCKSTATUS_TIME:
        /****************************************************************************/

          /* Synch-Start gefunden */
          if (DifLowTime>TIMER_SYNCHLEN)
          {

            /* Error = Zuwenig Bits */
            SET_ERRORTEXT(ERROR_ZUWENIG_BITS);

            /* Status = Vorbereitung */
            SET_BLOCKSTATUS(BLOCKSTATUS_VORBEREITUNG);

          }

        break;

        /****************************************************************************/
        case BLOCKSTATUS_TIMEOK:
        /****************************************************************************/

          /* Synch-Start nicht gefunden */
          if (DifLowTime<TIMER_SYNCHLEN)
          {

            /* Error = Zuviele Bits */
            SET_ERRORTEXT(ERROR_ZUVIEL_BITS);

            /* Status = Vorbereitung */
            SET_BLOCKSTATUS(BLOCKSTATUS_VORBEREITUNG);

            break;

          }

          /* Berechnung der Zeit */
          Berechnung_Time();

          /* Checks fehler ...? */
          if ((error=Check_Time())!=ERROR_NONE)
          {

            /* Error = Zeitkodierungsfehler */
            SET_ERRORTEXT(error);

          }
          else /* Checks ok ... */
          {

            /* Soll weiterer Vergleich durchgefuehrt werden ... ? */
            if (VERGLEICH)
            {

              /* Anzahl Vergleiche runterzaehlen */
              VERGLEICH--;

              /* Status = Zeitvergleich */
              SET_BLOCKSTATUS(BLOCKSTATUS_ZEITVERGLEICH);

              /* Status 2 Sekunden anzeigen */
              Delay(100);

            }
            else /* Kein Vergleich mehr ... */
            {

              /* Setzen der System-Zeit */
              SetSystem_Time();

              /* Wurde keine Ausgabe gemacht */
              if (AUSGABE==0)
              {

                /* Window oeffnen */
                WindowOpen();

                /* Status = TimeOk */
                SET_BLOCKSTATUS(BLOCKSTATUS_TIMEOK);

                /* Status 2 Sekunden anzeigen */
                Delay(100);

              }

              /* Status = Exit */
              SET_BLOCKSTATUS(BLOCKSTATUS_EXIT);

              break;

            }

          }

          /* Status = Vorbereitung */
          SET_BLOCKSTATUS(BLOCKSTATUS_VORBEREITUNG);

        break;

      }

    }

    if (PulsFlag==1 && PortWert==0) /* Flag=1 und Port=LOW -> Flankenende */
    {

      PulsFlag=0;                    /* Flag auf Flankenende     */
      EndZeit=MiliSecZaehler;        /* Merken der Stopzeit      */
      DifHighTime=EndZeit-StartZeit; /* Berechnung der High-Zeit */

      switch(blockstatus)
      {

        /****************************************************************************/
        case BLOCKSTATUS_SUCHESTART:
        /****************************************************************************/

        break;

        /****************************************************************************/
        case BLOCKSTATUS_TIME:
        /****************************************************************************/

          if (DifHighTime>=TIMER_PULS_BIT0_MIN && DifHighTime<=TIMER_PULS_BIT0_MAX)
          {
            /* Codiertes 0-Bit */

          }
          else if (DifHighTime>=TIMER_PULS_BIT1_MIN && DifHighTime<=TIMER_PULS_BIT1_MAX)
          {
            /* Codiertes 1-Bit */

            /* Berechnung des Zahlenwertes */
            BitCodierung[BitBlockNummer].ZahlenWert+=1<<BitCodierung[BitBlockNummer].AktBit;

            /* Berechnung der Paritaet */
            BitCodierung[BitBlockNummer].ParityWert^=1;

          }
          else
          {

            /* Error = Bitlaengefehler */
            SET_ERRORTEXT(ERROR_BITTIME);

            /* Status = Vorbereitung */
            SET_BLOCKSTATUS(BLOCKSTATUS_VORBEREITUNG);

            break;

          }

          /* Naechstes Bit */
          BitCodierung[BitBlockNummer].AktBit++;

          /* Anzahl Bits des Blockes erreicht ? */
          if (BitCodierung[BitBlockNummer].AktBit==BitCodierung[BitBlockNummer].AnzahlBits)
          {

            /* Anzahl Bit-Bloecke erreicht ? */
            if (++BitBlockNummer==ANZAHL_BITBLOECKE)
            {

              /* Status = TimeOk */
              SET_BLOCKSTATUS(BLOCKSTATUS_TIMEOK);

            }

          }

        break;

        /****************************************************************************/
        case BLOCKSTATUS_TIMEOK:
        /****************************************************************************/

        break;

      }

    }

    /* Suchezeit abgelaufen */
    if (MiliSecZaehler>MAX_SUCHEZEIT*1000)
    {

      /* Error = Suchezeit abgelaufen */
      SET_ERRORTEXT(ERROR_KEINEZEIT);

      /* Status = Exit */
      SET_BLOCKSTATUS(BLOCKSTATUS_EXIT);

    }

  }

  CloseAll(ERROR_NONE);

  return(0);
}

unsigned char ReadPort(void)
{
 extern volatile struct Custom custom;
 extern volatile struct CIA ciaa;
 extern volatile struct CIA ciab;

  if (PORT==2) return(((~ciab.ciapra)>>5)&0x01);
  if (PORT==1) return((ciaa.ciapra>>7)&0x01);
  return(((~custom.joy1dat)>>8)&0x01);
}

void Berechnung_Time(void)
{
  time_sek   = 0;
  time_min   = BitCodierung[BITBLOCK_MIN_LOW  ].ZahlenWert+BitCodierung[BITBLOCK_MIN_HIGH  ].ZahlenWert*10;
  time_std   = BitCodierung[BITBLOCK_STD_LOW  ].ZahlenWert+BitCodierung[BITBLOCK_STD_HIGH  ].ZahlenWert*10;
  time_tag   = BitCodierung[BITBLOCK_TAG_LOW  ].ZahlenWert+BitCodierung[BITBLOCK_TAG_HIGH  ].ZahlenWert*10;
  time_monat = BitCodierung[BITBLOCK_MONAT_LOW].ZahlenWert+BitCodierung[BITBLOCK_MONAT_HIGH].ZahlenWert*10;
  time_jahr  = BitCodierung[BITBLOCK_JAHR_LOW ].ZahlenWert+BitCodierung[BITBLOCK_JAHR_HIGH ].ZahlenWert*10;
}

unsigned char Check_Time(void)
{
 register unsigned char ParityTotal;
 unsigned short total_time_min,total_letztetime_min;

  /* Parity-1-Check */
  ParityTotal=(BitCodierung[BITBLOCK_MIN_LOW ].ParityWert
              +BitCodierung[BITBLOCK_MIN_HIGH].ParityWert)&1;
  if (BitCodierung[BITBLOCK_PARITY_1].ZahlenWert!=ParityTotal) return(ERROR_TIME_CHECK_PARITY);

  /* Parity-2-Check */
  ParityTotal=(BitCodierung[BITBLOCK_STD_LOW ].ParityWert
              +BitCodierung[BITBLOCK_STD_HIGH].ParityWert)&1;
  if (BitCodierung[BITBLOCK_PARITY_2].ZahlenWert!=ParityTotal) return(ERROR_TIME_CHECK_PARITY);

  /* Parity-3-Check */
  ParityTotal=(BitCodierung[BITBLOCK_TAG_LOW   ].ParityWert
              +BitCodierung[BITBLOCK_TAG_HIGH  ].ParityWert
              +BitCodierung[BITBLOCK_WOCHENTAG ].ParityWert
              +BitCodierung[BITBLOCK_MONAT_LOW ].ParityWert
              +BitCodierung[BITBLOCK_MONAT_HIGH].ParityWert
              +BitCodierung[BITBLOCK_JAHR_LOW  ].ParityWert
              +BitCodierung[BITBLOCK_JAHR_HIGH ].ParityWert)&1;
  if (BitCodierung[BITBLOCK_PARITY_3].ZahlenWert!=ParityTotal) return(ERROR_TIME_CHECK_PARITY);

  /* Grenzen-Check */
  if (time_sek  >59) return(ERROR_TIME_CHECK_BEREICH);
  if (time_min  >59) return(ERROR_TIME_CHECK_BEREICH);
  if (time_std  >23) return(ERROR_TIME_CHECK_BEREICH);
  if (time_tag  >31) return(ERROR_TIME_CHECK_BEREICH);
  if (time_monat>12) return(ERROR_TIME_CHECK_BEREICH);
  if (time_jahr >48) return(ERROR_TIME_CHECK_BEREICH);
  if (time_jahr <0 ) return(ERROR_TIME_CHECK_BEREICH);

  /* Zeitvergleich mit der letzen Zeit */
  if (letztetime_jahr)
  {

    if (letztetime_monat!=time_monat) return(ERROR_TIME_CHECK_VERGLEICH);
    if (letztetime_jahr !=time_jahr)  return(ERROR_TIME_CHECK_VERGLEICH);

    total_time_min      =time_min+time_std*60+time_tag*1440;
    total_letztetime_min=letztetime_min+letztetime_std*60+letztetime_tag*1440;

    if (total_time_min!=total_letztetime_min+2) return(ERROR_TIME_CHECK_VERGLEICH);

  }

  /* Letzte Zeit auf diese Zeit setzen */
  letztetime_sek  =time_sek;
  letztetime_min  =time_min;
  letztetime_std  =time_std;
  letztetime_tag  =time_tag;
  letztetime_monat=time_monat;
  letztetime_jahr =time_jahr;

  return(ERROR_NONE);
}

unsigned char SetSystem_Time(void)
{
 BPTR commandooutput;
 unsigned char doscomando[50];

  sprintf(doscomando,"date %02d-%02d-%02d %02d:%02d:%02d",time_tag,time_monat,time_jahr,time_std,time_min,time_sek);
  if ((commandooutput=Open("T:AtomUhr.tmp",MODE_NEWFILE))==0) return(ERROR_SET_SYSTEMTIME);
  if (Execute(doscomando,0,commandooutput)==0)
  {
    Close(commandooutput);
    return(ERROR_SET_SYSTEMTIME);
  }
  if (strlen(DOS_BEFEHL)>0)
  {
    if (Execute(DOS_BEFEHL,0,commandooutput)==0)
    {
      Close(commandooutput);
      return(ERROR_SET_SYSTEMTIME);
    }
  }
  Close(commandooutput);

  return(ERROR_NONE);
}

void WriteText(unsigned char *text,unsigned short farbe)
{
 unsigned char outtext[40];

  if (window)
  {
    sprintf(outtext,"%-37.37s",text);
    SetAPen(window->RPort,farbe);
    Move(window->RPort,8,18);
    Text(window->RPort,outtext,strlen(outtext));
  }
}

void WriteLine(unsigned short x1,unsigned short y1,unsigned short x2,unsigned short y2,unsigned short farbe)
{
  if (window)
  {
    SetAPen(window->RPort,farbe);
    Move(window->RPort,x1,y1);
    Draw(window->RPort,x2,y2);
  }
}

unsigned char OpenAll(void)
{
  if ((IntuitionBase=(struct IntuitionBase *)OpenLibrary("intuition.library",0))==0) return(ERROR_NO_LIBRARYS);
  if ((GfxBase=(struct GfxBase *)OpenLibrary("graphics.library",0))==0) return(ERROR_NO_LIBRARYS);

  if ((myTimerPort=(struct MsgPort *)CreatePort("AtomUhr.TimerPort",0))==0) return(ERROR_NO_TIMERPORT);
  if ((myTimer=(struct timerequest *)CreateExtIO(myTimerPort,sizeof(struct timerequest)))==0) return(ERROR_NO_TIMERREQUEST);
  if (OpenDevice(TIMERNAME,UNIT_MICROHZ,myTimer,0)!=0) return(ERROR_NO_TIMERDEVICE);
  open_device_timer=1;

  if (AUSGABE) if (WindowOpen()) return(ERROR_NO_WINDOW);

  return(ERROR_NONE);
}

unsigned char WindowOpen(void)
{
  if (DEBUG)
  {
    newwindow.Height=DEBUG_WINDOW_GROESSE_Y;
  }
  else
  {
    newwindow.Height=WINDOW_GROESSE_Y;
  }
  newwindow.LeftEdge = FENSTER_X;
  newwindow.TopEdge  = FENSTER_Y;
  if ((window=OpenWindow(&newwindow))==0) return(1);
  SetBPen(window->RPort,0);
  return(0);
}

void CloseAll(unsigned char error_nummer)
{
  if (error_nummer)
  {
    if (error_nummer<=ERROR_NO_WINDOW)
    {
      printf("\n%s\n\n",error_text[error_nummer]);
    }
    else
    {
      WriteText(error_text[error_nummer],2);
    }
  }

  Delay(100);

  if (window)			CloseWindow(window);
  if (IntuitionBase)		CloseLibrary(IntuitionBase);
  if (GfxBase)			CloseLibrary(GfxBase);
  if (open_device_timer)	CloseDevice(myTimer);
  if (myTimer)			DeleteExtIO(myTimer);
  if (myTimerPort)		DeletePort(myTimerPort);

  exit(0);
}

unsigned char SetParameter(unsigned char *argument0,unsigned short arg_anz)
{
 unsigned char PrgName[120];
 struct DiskObject *myDiskObject;
 struct IconBase *IconBase;
 struct WBStartup *Wbs;
 unsigned char *text_zeiger;

  DEBUG         = DEFAULT_DEBUG;
  PRIORITAET    = DEFAULT_PRIORITAET;
  PORT		= DEFAULT_PORT;
  AUSGABE       = DEFAULT_AUSGABE;
  VERGLEICH     = DEFAULT_VERGLEICH;
  FENSTER_X     = DEFAULT_FENSTER_X;
  FENSTER_Y     = DEFAULT_FENSTER_Y;
  MAX_SUCHEZEIT = DEFAULT_MAX_SUCHEZEIT;
  strcpy(DOS_BEFEHL,DEFAULT_DOS_BEFEHL);

  Wbs=(struct WBStartup *)argument0;
  if (arg_anz==0 && Wbs && Wbs->sm_NumArgs>0 && Wbs->sm_ArgList[Wbs->sm_NumArgs-1].wa_Lock)
  {
    strcpy(PrgName,"");
    NameFromLock(Wbs->sm_ArgList[Wbs->sm_NumArgs-1].wa_Lock,PrgName,sizeof(PrgName));
    if (strlen(PrgName)>0 && PrgName[strlen(PrgName)-1]!=':' && PrgName[strlen(PrgName)-1]!='/') strcat(PrgName,"/");
    strcat(PrgName,Wbs->sm_ArgList[Wbs->sm_NumArgs-1].wa_Name);
  }
  else
  {
    strcpy(PrgName,"");
    GetProgramName(PrgName,sizeof(PrgName));
  }

  if (strlen(PrgName))
  {

    if ((IconBase=(struct IconBase *)OpenLibrary("icon.library",0))==0) return(ERROR_NO_LIBRARYS);

    if (myDiskObject=GetDiskObject(PrgName))
    {
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"PRIORITAET"))!=0)    PRIORITAET    = atoi(text_zeiger);
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"FENSTER_X"))!=0)     FENSTER_X     = atoi(text_zeiger);
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"FENSTER_Y"))!=0)     FENSTER_Y     = atoi(text_zeiger);
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"MAX_SUCHEZEIT"))!=0) MAX_SUCHEZEIT = atoi(text_zeiger);
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"DOS_BEFEHL"))!=0 )   strcpy(DOS_BEFEHL,text_zeiger);
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"AUSGABE"))!=0)
      {
             if (strcmp(text_zeiger,"EIN")==0) AUSGABE=1;
        else if (strcmp(text_zeiger,"AUS")==0) AUSGABE=0;
        else return(ERROR_PARAMTER);
      }
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"VERGLEICH"))!=0)
      {
             if (strcmp(text_zeiger,"EIN")==0) VERGLEICH=1;
        else if (strcmp(text_zeiger,"AUS")==0) VERGLEICH=0;
        else return(ERROR_PARAMTER);
      }
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"DEBUG"))!=0)
      {
             if (strcmp(text_zeiger,"EIN")==0) AUSGABE=DEBUG=1;
        else if (strcmp(text_zeiger,"AUS")==0) DEBUG=0;
        else return(ERROR_PARAMTER);
      }
      if ((text_zeiger=FindToolType(myDiskObject->do_ToolTypes,"PORT"))!=0)
      {
             if (strcmp(text_zeiger,"JOY_PIN1")==0) PORT=0;
        else if (strcmp(text_zeiger,"JOY_PIN6")==0) PORT=1;
        else if (strcmp(text_zeiger,"SER_PIN8")==0) PORT=2;
        else return(ERROR_PARAMTER);
      }

      FreeDiskObject(myDiskObject);

    }

    CloseLibrary(IconBase);

  }

  return(ERROR_NONE);
}

