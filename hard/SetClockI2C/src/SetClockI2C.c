/*
 * SetClockI2C.c - main setclock module
 *
 * Set the system clock using Real Time Clock chips:
 *   Phlips PCF8583
 *   Dallas/Maxim DS1629
 *   Ricoh R2025
 *
 * V0.1 - 23 oct 1999
 *          First release
 *
 * V2.0 - 28 oct 2003
 *          Ricoh R2025 added, rewritten using standard amiga functions
 *
 * V2.1 - 31 oct 2003
 *          Leap year aligment corrected. Ds1629 code added.
 *
 * V2.2 - 11 nov 2003
 *          Oscillation adjustment register used on R2025.
 *
 * V2.3 - 11 nov 2003
 *          Some code cleanup: GetSysTime() was missing timer.device base pointer!
 *
 * V2.4 - 13 nov 2003
 *          Some code cleanup and PCF8583 code added.
 *
 * V2.5 - 14 nov 2003
 *          Some code consistency correction.
 *
 * V2.6 - 18 dec 2003
 *          Some cosmetic changes around.
 *
 * V2.7 - 3 jan 2004
 *          Some exit() removed. Some static attributes added.
 *
 * V2.8 - 11 jan 2003
 *          ReadArgs() used. Very nice!
 *
 * V2.9 - 1 apr 2004
 *          Going to a smaller version. Partial rewrite.
 */

#include <stdio.h>

#include <exec/libraries.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>

#include <clib/exec_protos.h>
#include <clib/timer_protos.h>
#include <clib/utility_protos.h>
#include <dos/dos.h>
#include <devices/timer.h>

#include <proto/dos.h>

#include "clockpref.h"
#include "rtcI2C.h"


static UBYTE * VersTag = "\0$VER: SetClockI2C 2.9 (1.4.2004) " CLOCKC " version, by Useless SW";

/* System libraries' interface */
#ifdef MIN_START
struct DosLibrary * DOSBase;
#else
extern struct DosLibrary * DOSBase;
#endif

struct Library * TimerBase;   /* used to call special function */
struct Library * UtilityBase; /* used to call date functions   */


/* some local prototypes */
static int load_systemclockfromRTC(struct timerequest * TR_p, struct ClockData * Ckdata);
static int save_toRTCfromsystemclock(LONG save_flag, struct ClockData * Ckdata);


/* main :) */
int main(int argc, char ** argv)
{
    /* ReadArgs() required variables */
    LONG                 argarray[3] = { 0L, 0L, 0L };
    struct RDArgs      * rdargs;
    LONG                 load, save, reset;

    struct ClockData   * Ckdata;
    struct timerequest * TReq;
    int                  retcode = RETURN_OK;


    /* this part used only in case of minimal startup code */
    #ifdef MIN_START
    DOSBase = (struct DosLibrary *) OpenLibrary("dos.library", 0L);
    if ( DOSBase == NULL )
        retcode = RETURN_FAIL;
    #endif

    if (retcode == RETURN_OK)
    {
        /* check command call correctness */
        rdargs = ReadArgs("LOAD/S,SAVE/S,RESET/S", argarray, NULL);
        if (rdargs == NULL)
        {
            PrintFault(ERROR_TOO_MANY_ARGS, NULL);
            retcode = RETURN_FAIL;
        }
        else {
            load = argarray[0];
            save = argarray[1];
            reset = argarray[2];

            FreeArgs(rdargs);

            if ( (load && save) || (load && reset) || (save && reset) || (!load && !save && !reset) )
                retcode = RETURN_OK;
            else {
                /* Actions common to load an save: open libraries ... */
                if (!open_RTC_libs())
                {
                    /* Could not open RTC lowlevel libraries: error message given by module*/
                    retcode = RETURN_FAIL;
                }
                else {
                    UtilityBase = OpenLibrary("utility.library", 36L);
                    if( UtilityBase == NULL )
                    {
                        Write(Output(), "Could not open utility.library V36+\n", 36);
                        retcode = RETURN_FAIL;
                    }
                    else {
                        /* allocate some memory for a ClockData struct */
                        Ckdata = AllocMem(sizeof(struct ClockData), MEMF_PUBLIC);
                        if (Ckdata == NULL)
                        {
                            #ifdef DEBUG
                                fprintf(stderr, "Couldn't allocate memory for ClockData\n");
                            #endif
                            retcode = RETURN_FAIL;
                        }
                        else {
                            /* Allocate memory for timerequest ... */
                            TReq = AllocMem(sizeof(struct timerequest), MEMF_PUBLIC);
                            if (TReq == NULL)
                            {
                                #ifdef DEBUG
                                    fprintf(stderr, "Couldn't allocate memory for timerequest\n");
                                #endif
                                retcode = RETURN_FAIL;
                            }
                            else {
                                /* ... and open timer.device to do the time request
                                 * (with UNIT_VBLANK, but any unit can be used)
                                 */
                                if (OpenDevice(TIMERNAME, UNIT_VBLANK, (struct IORequest *) TReq, 0L) != 0)
                                {
                                    Write(Output(), "Could not open timer.device!\n", 29);
                                    retcode = RETURN_FAIL;
                                }
                                else {
                                    /* set base pointer to use the special timer function GetSysTime() */
                                    TimerBase = (struct Library *)TReq->tr_node.io_Device;
    
                                    if (load)
                                         retcode = load_systemclockfromRTC(TReq, Ckdata);
                                    else retcode = save_toRTCfromsystemclock(save, Ckdata);
    
                                    if (retcode != RETURN_OK)
                                        Write(Output(), "Can't find battery-backed up clock\n", 35);

                                    CloseDevice(&TReq->tr_node);
                                }
    
                                FreeMem(TReq, sizeof(struct timerequest) );
                            }

                            FreeMem( Ckdata, sizeof(struct ClockData) );
                        }

                        CloseLibrary(UtilityBase);
                    }

                    close_RTC_libs();
                }
            }             /* argument coherence */
        }                 /* ReadArgs() correct */
    }


    /* this part used only in case of minimal startup code */
    #ifdef MIN_START
    if (DOSBase) CloseLibrary( (struct Library *) DOSBase);
    #endif

    return retcode;
}


/* get clock data from RTC and set system clock if data correct
 */
static int load_systemclockfromRTC(struct timerequest * TR_p,  struct ClockData * Ckdata)
{
    int                rc = RETURN_OK;


    /* Set up the time request as needed: i.e. DoIO() without waiting for a reply
     * message, assuming the command has been executed immediately and correctly.
     */
    TR_p->tr_time.tv_micro = 0;
    TR_p->tr_node.io_Message.mn_Node.ln_Type = NT_MESSAGE;
    TR_p->tr_node.io_Message.mn_Node.ln_Name = "";
    TR_p->tr_node.io_Message.mn_ReplyPort = NULL;
    TR_p->tr_node.io_Command = TR_SETSYSTIME;
    TR_p->tr_node.io_Flags = IOF_QUICK;


    /* get clock data from RTC chip */
    if (!read_RTC(Ckdata))
    {
        #ifdef DEBUG
            fprintf(stderr, "RTC data incorrect!\n");
        #endif
        rc = RETURN_FAIL;
    }
    else {
        /* the Clock Data structure is checked for validity and converted to seconds */
        TR_p->tr_time.tv_secs = CheckDate(Ckdata);

        /* set new system time ! */
        if ( DoIO((struct IORequest *)TR_p) )
        {
            #ifdef DEBUG
                printf("SetClockI2C: Couldn't set system time!\n");
            #endif
            rc = RETURN_FAIL;
        }

        #ifdef DEBUG
        printf("rtcI2C: RTC->  sec %d min %d hour %d\n", Ckdata->sec, Ckdata->min, Ckdata->hour);
        printf("               mday %d month %d year %d wday %d\n", Ckdata->mday, Ckdata->month, Ckdata->year, Ckdata->wday);
        printf("               total seconds: %u\n", TR_p->tr_time.tv_secs);
        Amiga2Date(4294967295, Ckdata);
        printf("Date limits:\n");
        printf("4294967295s =  sec %d min %d hour %d\n", Ckdata->sec, Ckdata->min, Ckdata->hour);
        printf("               mday %d month %d year %d wday %d\n", Ckdata->mday, Ckdata->month, Ckdata->year, Ckdata->wday);
        printf("               total seconds: %u\n", CheckDate(Ckdata) );
        Amiga2Date(0, Ckdata);
        printf("         0s =  sec %d min %d hour %d\n", Ckdata->sec, Ckdata->min, Ckdata->hour);
        printf("               mday %d month %d year %d wday %d\n", Ckdata->mday, Ckdata->month, Ckdata->year, Ckdata->wday);
        printf("               total seconds: %u\n", CheckDate(Ckdata) );
        #endif
    }

    return rc;
}


/* get clock data from system and save to battery-back up RTC
 */
static int save_toRTCfromsystemclock(LONG save_flag, struct ClockData * Ckdata)
{
    int                rc = RETURN_OK;
    struct timeval   * TVal;


    /* allocate some memory for a ClockData struct */
    TVal = AllocMem(sizeof(struct timeval), MEMF_PUBLIC);
    if (TVal == NULL)
    {
        #ifdef DEBUG
            fprintf(stderr, "Couldn't allocate memory for timeval\n");
        #endif
        rc = RETURN_FAIL;
    }
    else {
        /* fill the timeval structure with current data */
        if (save_flag)
             GetSysTime(TVal);           /* SAVE current clock */
        else TVal->tv_secs = 0;          /* RESET data in RTC chip */

        /* convert to ClockData structure */
        Amiga2Date(TVal->tv_secs, Ckdata);

        /* ClockData is downloaded to the RTC */
        if (!write_RTC(Ckdata))
        {
            #ifdef DEBUG
                printf("Couldn't write to RTC!\n");
            #endif
            rc = RETURN_FAIL;
        }

        #ifdef DEBUG
            printf("rtcI2C: A2D()  sec %d min %d hour %d\n", Ckdata->sec, Ckdata->min, Ckdata->hour);
            printf("               mday %d month %d year %d wday %d\n", Ckdata->mday, Ckdata->month, Ckdata->year, Ckdata->wday);
        #endif

        FreeMem( TVal, sizeof(struct timeval) );
    }

    return rc;
}

