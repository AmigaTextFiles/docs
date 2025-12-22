/* rtcI2C.c -- lowlevel I2C RTC I/O module
 *
 * V2.0 - 28 oct 2003
 *          Ricoh R2025 added, rewritten using standard amiga functions
 *
 * V2.1 - 31 oct 2003
 *          Leap year aligment corrected. DS1629 code added (coming from V1).
 *
 * V2.2 - 11 nov 2003
 *          Ricoh R2025 adjustment register added (+3ppm first test value).
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
 * V2.7 - 5 jan 2004
 *          Some "return" removed: now every function has a single entry/single exit point.
 *          This should make debugging easier.
 *          Some static attributes added. Compiler dependences added.
 *
 * V2.8 - 20 jan 2004
 *          Dallas/Maxim DS1307 added.
 *
 * V2.9 - 1 apr 2004
 *              Some code rewrite. Error messages eliminated.
 *
 */

#include <stdio.h>

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <utility/date.h>

#ifdef    __VBCC__
 #include <inline/i2c_protos.h>           /* generated fom .fd file by fd2pragma */
#else                             /*__STORM__ & C.  */
 #include <proto/i2c.h>
#endif

#include "clockpref.h"
#include "rtci2c.h"



/* general use vars */
static struct Library *I2C_Base = NULL;


/* I2C library open/close routines */
void close_RTC_libs(void)
{
    if( I2C_Base )
    {
        CloseLibrary( I2C_Base );
        I2C_Base = NULL;
    }
}

int open_RTC_libs(void)
{
    int retval = TRUE;

    I2C_Base = OpenLibrary( "i2c.library", 39L );
    if( I2C_Base == NULL )
    {
        Write(Output(), "Couldn't open i2c.library V39+\n", 39);
        retval = FALSE;
    }

    return retval;
}



/* general use functions */
static int SendI2C_and_chkerr(UBYTE addr, UWORD num, UBYTE * buf)
{
    int  retval = TRUE;
    ULONG lResult;

    lResult = SendI2C(addr, num, buf);
    if( !(lResult & 0x0F) )
    {
        #ifdef DEBUG
            fprintf(stderr, "I²C bus error writing %s: 0x%06lx, %s\n", CLOCKC, lResult, I2CErrText( lResult ) );
        #endif
        retval = FALSE;
    }
    return retval;
}

static int ReceiveI2C_and_chkerr(UBYTE addr, UWORD num, UBYTE * buf)
{
    int  retval = TRUE;
    ULONG lResult;

    lResult = ReceiveI2C(addr, num, buf);
    if( !(lResult & 0x0F) )
    {
        #ifdef DEBUG
            fprintf(stderr, "I²C bus error reading %s: 0x%06lx, %s\n", CLOCKC, lResult, I2CErrText( lResult ) );
        #endif
        retval = FALSE;
    }
    return retval;
}


/* miscellaneous conversions */
static UWORD bcd2bin(UBYTE *bcd)
{
    UBYTE i,j;

    i = (*bcd) >> 4;
    j = (*bcd) & 0x0F;

    return (UWORD) j+(i*10);
}


 UBYTE bin2bcd(UWORD a)
{
    UBYTE res = 0;

#ifndef MIN_START
    res = (a - (a%10))/10;
    res <<= 4;
    res += a%10;
#else
    int i;
    for (i=0; i <= 9; i+=1)
    {
        if (a <= 9)
        {
            res = (i << 4) + a;
            break;
        }

        a -= 10;
    }
#endif

    return res;
}



/**************************************************************************************
 *                                                                                    *
 *                here starts the device dependent part of the code                   *
 *                                                                                    *
 *              the RTC device should be uniquely defined in clockpref.h              *
 *                                                                                    *
 **************************************************************************************/


/* A. functions only valid in case of Dallas/Maxim DS1629
 */

#ifdef RTC_DS1629
#define DS1629_ACC_CLOCK    0xC0
#define DS1629_STRT_ADDR    0x00
#define DS1629_TXSIZ        9         /* Size of buffer to be sent to RTC chip */
#define DS1629_RXSIZ        7         /* Size of buffer to be received from RTC chip */

int write_RTC(struct ClockData * Ckdata)
{
    int  retcode;
    UBYTE rtcbuf[DS1629_TXSIZ];

    /* 1. fill buffer to be downloaded to RTC
     *      we first write the Access Clock command, then the start address
     *      with clock stopped. After completion we rewrite with clock start command.
     *      the byte order is this:
     * rtcbuf[0] Access Clock command
     * rtcbuf[1] Start address
     * rtcbuf[2] or byte 0x00 - Seconds Counter & Clock START/STOP bit
     * rtcbuf[3] or byte 0x01 - Minutes Counter
     * rtcbuf[4] or byte 0x02 - Hours Counter & 12/24 bit
     * rtcbuf[5] or byte 0x03 - Day-of-week Counter
     * rtcbuf[6] or byte 0x04 - Day-of-month Counter
     * rtcbuf[7] or byte 0x05 - Month Counter
     * rtcbuf[8] or byte 0x06 - Year Counter
     */

    rtcbuf[0] = DS1629_ACC_CLOCK;
    rtcbuf[1] = DS1629_STRT_ADDR;
    rtcbuf[2] = bin2bcd(Ckdata->sec) | 0x80;    /* seconds counter with clock stopped */
    rtcbuf[3] = bin2bcd(Ckdata->min);
    rtcbuf[4] = bin2bcd(Ckdata->hour);          /* 24 hours mode */
    rtcbuf[5] = (UBYTE) (Ckdata->wday);
    rtcbuf[6] = bin2bcd(Ckdata->mday);
    rtcbuf[7] = bin2bcd(Ckdata->month);
    rtcbuf[8] = bin2bcd(Ckdata->year - 1976);   /* clock data is stored relative to the leap
                                                 * year which is closest to 1978 */
    #ifdef DEBUG
    fprintf(stderr,"rtcI2C rtcbuf: %X %X %X %X %X %X %X %X %X\n", rtcbuf[0],rtcbuf[1],rtcbuf[2],rtcbuf[3],rtcbuf[4],rtcbuf[5],rtcbuf[6],rtcbuf[7],rtcbuf[8]);
    #endif

    /* 2. stop clock on RTC, to avoid possible carry due to oscillator still counting */
    if ( retcode = SendI2C_and_chkerr(RTC_DS1629, 3, rtcbuf) )
    {
        /* 3. send data over to I2C RTC while clock is stopped */
        if ( retcode = SendI2C_and_chkerr(RTC_DS1629, DS1629_TXSIZ, rtcbuf) )
        {
            rtcbuf[2] &= 0x7F;               /* Clock enable command */

            /* 4. send clock start over to RTC */
            retcode = SendI2C_and_chkerr(RTC_DS1629, 3, rtcbuf);
        }
    }

    return retcode;
}


int read_RTC(struct ClockData * Ckdata)                   /* DS1629 */
{
    int  retcode;
    UBYTE rtcbuf[DS1629_RXSIZ];
    UBYTE temp;

    /* 1. tell DS1629 we would like to access clock area */
    rtcbuf[0] = DS1629_ACC_CLOCK;
    rtcbuf[1] = DS1629_STRT_ADDR;
    if ( retcode = SendI2C_and_chkerr(RTC_DS1629, 2, rtcbuf) )
    {
        /* 2. fill buffer with RTC data
         *      the byte order is this:
         * rtcbuf[0] or byte 0x00 - Seconds Counter & Clock START/STOP bit
         * rtcbuf[1] or byte 0x01 - Minutes Counter
         * rtcbuf[2] or byte 0x02 - Hours Counter & 12/24 bit
         * rtcbuf[3] or byte 0x03 - Day-of-week Counter
         * rtcbuf[4] or byte 0x04 - Day-of-month Counter
         * rtcbuf[5] or byte 0x05 - Month Counter + Century bit
         * rtcbuf[6] or byte 0x06 - Year Counter
         *
         * please note that this read method is undocumented: the docs only talk about
         * reads done with repeated start condition after a write. Anyway, nothing is said
         * about resetting of the byte address after a stop condition, so we tried this.
         */
        if ( retcode = ReceiveI2C_and_chkerr(RTC_DS1629, DS1629_RXSIZ, rtcbuf) )
        {
            /* mask out meaningless data from hour counter */
            rtcbuf[2] &= 0x3F;

            /* years stored in RTC begin with 1976, the closest leap year preceding 1978.
             * Years 1976 (0) and 1977 (1) are  not valid, so tey are converted to 1978.
             */
            if ( (temp = bcd2bin(rtcbuf+6)) < 2)
                temp = 2;

            /* 3. transfer data to ClockData structure */
            Ckdata->sec   = bcd2bin(rtcbuf);
            Ckdata->min   = bcd2bin(rtcbuf+1);
            Ckdata->hour  = bcd2bin(rtcbuf+2);
            Ckdata->wday  = (UWORD)(rtcbuf[3]);
            Ckdata->mday  = bcd2bin(rtcbuf+4);
            Ckdata->month = bcd2bin(rtcbuf+5);
            Ckdata->year  = 1976 + temp;

            /* Note that stored year can't be beyond system clock limit of 2114
             * because 1976+99 = 2075 :)
             */
        }       /* rtc data received */
    }           /* command received by rtc */

    return retcode;
}
#endif


/* B. functions only valid in case of Dallas/Maxim DS1307
 */

#ifdef RTC_DS1307
#define DS1307_STRT_ADDR    0x00
#define DS1307_TXSIZ        8         /* Size of buffer to be sent to RTC chip */
#define DS1307_RXSIZ        7         /* Size of buffer to be received from RTC chip */

int write_RTC(struct ClockData * Ckdata)
{
    int  retcode;
    UBYTE rtcbuf[DS1307_TXSIZ];

    /* 1. fill buffer to be downloaded to RTC
     *      we first stop the clock, then write correct data. After completion
     *      we rewrite with clock start command. The byte order is this:
     * rtcbuf[0] Start address
     * rtcbuf[1] or byte 0x00 - Seconds Counter & Clock START/STOP bit
     * rtcbuf[2] or byte 0x01 - Minutes Counter
     * rtcbuf[3] or byte 0x02 - Hours Counter & 12/24 bit
     * rtcbuf[4] or byte 0x03 - Day-of-week Counter
     * rtcbuf[5] or byte 0x04 - Day-of-month Counter
     * rtcbuf[6] or byte 0x05 - Month Counter
     * rtcbuf[7] or byte 0x06 - Year Counter
     */

    rtcbuf[0] = DS1307_STRT_ADDR;
    rtcbuf[1] = bin2bcd(Ckdata->sec) | 0x80;    /* seconds counter with clock stopped */
    rtcbuf[2] = bin2bcd(Ckdata->min);
    rtcbuf[3] = bin2bcd(Ckdata->hour);          /* 24 hours mode */
    rtcbuf[4] = (UBYTE) (Ckdata->wday);
    rtcbuf[5] = bin2bcd(Ckdata->mday);
    rtcbuf[6] = bin2bcd(Ckdata->month);
    rtcbuf[7] = bin2bcd(Ckdata->year - 1976);   /* clock data is stored relative to the leap
                                                                                    * year which is closest to 1978 */

    #ifdef DEBUG
    fprintf(stderr,"rtcI2C rtcbuf: %X %X %X %X %X %X %X %X\n", rtcbuf[0],rtcbuf[1],rtcbuf[2],rtcbuf[3],rtcbuf[4],rtcbuf[5],rtcbuf[6],rtcbuf[7]);
    #endif

    /* 2. stop clock on RTC, to avoid possible carry due to oscillator still counting */
    if ( retcode = SendI2C_and_chkerr(RTC_DS1307, 2, rtcbuf) )
    {
        /* 3. send data over to I2C RTC while clock is stopped */
        if ( retcode = SendI2C_and_chkerr(RTC_DS1307, DS1307_TXSIZ, rtcbuf) )
        {
            rtcbuf[1] &= 0x7F;               /* Clock enable command */

            /* 4. send clock start over to RTC */
            retcode = SendI2C_and_chkerr(RTC_DS1307, 3, rtcbuf);
        }
    }

    return retcode;
}


int read_RTC(struct ClockData * Ckdata)                   /* DS1307 */
{
    int  retcode;
    UBYTE rtcbuf[DS1307_RXSIZ];
    UBYTE temp;

    /* 1. tell DS1307 we would like to access clock area */
    rtcbuf[0] = DS1307_STRT_ADDR;
    if ( retcode = SendI2C_and_chkerr(RTC_DS1307, 1, rtcbuf) )
    {
        /* 2. fill buffer with RTC data
         *      the byte order is this:
         * rtcbuf[0] or byte 0x00 - Seconds Counter & Clock START/STOP bit
         * rtcbuf[1] or byte 0x01 - Minutes Counter
         * rtcbuf[2] or byte 0x02 - Hours Counter & 12/24 bit
         * rtcbuf[3] or byte 0x03 - Day-of-week Counter
         * rtcbuf[4] or byte 0x04 - Day-of-month Counter
         * rtcbuf[5] or byte 0x05 - Month Counter + Century bit
         * rtcbuf[6] or byte 0x06 - Year Counter
         *
         */
        if ( retcode = ReceiveI2C_and_chkerr(RTC_DS1307, DS1307_RXSIZ, rtcbuf) )
        {
            /* mask out meaningless data from hour counter */
            rtcbuf[2] &= 0x3F;

            /* years stored in RTC begin with 1976, the closest leap year preceding 1978.
             * Years 1976 (0) and 1977 (1) are  not valid, so tey are converted to 1978.
             */
            if ( (temp = bcd2bin(rtcbuf+6)) < 2)
                temp = 2;

            /* 3. transfer data to ClockData structure */
            Ckdata->sec   = bcd2bin(rtcbuf);
            Ckdata->min   = bcd2bin(rtcbuf+1);
            Ckdata->hour  = bcd2bin(rtcbuf+2);
            Ckdata->wday  = (UWORD)(rtcbuf[3]);
            Ckdata->mday  = bcd2bin(rtcbuf+4);
            Ckdata->month = bcd2bin(rtcbuf+5);
            Ckdata->year  = 1976 + temp;

            /* Note that stored year can't be beyond system clock limit of 2114
             * because 1976+99 = 2075 :)
             */
        }       /* rtc data received */
    }           /* command received by rtc */

    return retcode;
}
#endif


/* C. functions only valid in case of Philips PCF8583
 */

#ifdef RTC_PCF8583
#define PCF8583_CTRL        0x00
#define PCF8583_C_HOLD_CNT  0x60
#define PCF8583_C_STOP_CNT  0x80
#define PCF8583_CTRL_ADDR   0x00
#define PCF8583_TXSIZ       8       /* Size of buffer to be sent to RTC chip */
#define PCF8583_RXSIZ       6       /* Size of buffer to be received from RTC chip */

int write_RTC(struct ClockData * Ckdata)
{
    int  retcode;
    UBYTE rtcbuf[PCF8583_TXSIZ];
    UBYTE c4years, RTC_year, tmp;

    /* 1. fill buffer to be downloaded to RTC
     *      we first stop the clock to avoid FALSE carries. After completion we rewrite
     *      the control register with clock start command.
     *      the byte order is this:
     * rtcbuf[0] Start address (control/status)
     * rtcbuf[1] or byte 0x00 - Control/status register
     * rtcbuf[2] or byte 0x01 - Microseconds
     * rtcbuf[3] or byte 0x02 - Seconds Counter
     * rtcbuf[4] or byte 0x03 - Minutes Counter
     * rtcbuf[5] or byte 0x04 - Hours Counter & 12/24 bit
     * rtcbuf[6] or byte 0x05 - Year/Day-of-month Counter
     * rtcbuf[7] or byte 0x06 - Day-of-week/Month Counter
     */

    rtcbuf[0] = PCF8583_CTRL_ADDR;
    rtcbuf[1] = PCF8583_CTRL | PCF8583_C_STOP_CNT;   /* stop count */
    rtcbuf[2] = 0x00;                                /* microseconds are written as 0 */
    rtcbuf[3] = bin2bcd(Ckdata->sec);
    rtcbuf[4] = bin2bcd(Ckdata->min);
    rtcbuf[5] = bin2bcd(Ckdata->hour);               /* 24 hours mode */

    c4years = Ckdata->year - 1976 ;             /* clock data is stored relative to the leap
                                                 * year which is closest to 1978 */
    RTC_year = c4years & 0x03;         /* this is equivalent to RTC_year = c4years % 4 and
                                        * should be saved in year register AND in xref */
    c4years >>= 2;                     /* this is equivalent to c4years /= 4 and
                                        * should be saved in xref location  */

    rtcbuf[6] = (RTC_year << 6) | bin2bcd(Ckdata->mday);

    tmp = (UBYTE) (Ckdata->wday);
    rtcbuf[7] = (tmp << 5) | bin2bcd(Ckdata->month);

    #ifdef DEBUG
    printf("rtcI2C rtcbuf: %X %X %X %X %X %X %X %X\n", rtcbuf[0],rtcbuf[1],rtcbuf[2],rtcbuf[3],rtcbuf[4],rtcbuf[5],rtcbuf[6],rtcbuf[7]);
    #endif

    /* 2. stop clock on RTC, to avoid possible carry due to oscillator still counting */
    if ( retcode = SendI2C_and_chkerr(RTC_PCF8583, 2, rtcbuf) )
    {
        /* 3. send data to RTC while clock is stopped */
        if ( retcode = SendI2C_and_chkerr(RTC_PCF8583, PCF8583_TXSIZ, rtcbuf) )
        {
            rtcbuf[1] &= 0x00;               /* Clock enable command */

            /* 4. send clock start to RTC */
            if ( retcode = SendI2C_and_chkerr(RTC_PCF8583, 2, rtcbuf) )
            {
                /* 5. Manage data relating to 4-years groups */
                rtcbuf[0] = PCF8583_YRXREF_RESVLOC;
                rtcbuf[1] = (RTC_year << 6) | c4years;

                retcode = SendI2C_and_chkerr(RTC_PCF8583, 2, rtcbuf);
            }
        }
    }

    return retcode;
}


int read_RTC(struct ClockData * Ckdata)            /* PCF8583 */
{
    int  retcode;
    UBYTE rtcbuf[PCF8583_RXSIZ];
    UBYTE cmdbuf[2];
    UBYTE c4years, RTC_year, RTC_saved_year;
    UBYTE tmp;
    UBYTE Ctrl_Reg;


    /* 1.access control/status register and check validity
     */
    cmdbuf[0] = PCF8583_CTRL_ADDR;

    /* tell PCF8583 we would like to look at status register */
    if ( retcode = SendI2C_and_chkerr(RTC_PCF8583, 1, cmdbuf) )
    {
        /* read Control/status register */
        if ( retcode = ReceiveI2C_and_chkerr(RTC_PCF8583, 1, &Ctrl_Reg) )
        {
            if ( Ctrl_Reg & PCF8583_C_HOLD_CNT )
            {
                /* clock have been left in 'store count' condition by a previous read
                 * attempt which went wrong so we first need to re-enable normal
                 * condition */

                 cmdbuf[0] = PCF8583_CTRL_ADDR;
                 cmdbuf[1] = PCF8583_CTRL;
                 retcode = SendI2C_and_chkerr(RTC_PCF8583, 2, cmdbuf);
            }
        }
    }


    /* 2.access extended (beyond 4) year information
     */
    if (retcode)
    {
        cmdbuf[0] = PCF8583_YRXREF_RESVLOC;

        /* retrieve 4-years' groups xref information */
        if ( retcode = SendI2C_and_chkerr(RTC_PCF8583, 1, cmdbuf) )
        {
            if ( retcode = ReceiveI2C_and_chkerr(RTC_PCF8583, 1, &c4years) )
            {
                /* check validity */
                RTC_saved_year = (c4years & 0xC0) >> 6;
                c4years &= 0x3F;

                if ( c4years > 33 )
                {
                    /* stored year information beyond system limits
                     * 1976 + (33*4) + 3 = 2111 < 2114 system limit
                     */
                    c4years = 33;
                }
                else {
                    /* 1976 + 0 and 1976 + 1 are not valid years */
                    if ( (c4years == 0) && (RTC_saved_year < 2) )
                       RTC_saved_year = 2;
                }
            }
        }
    }


    /* 3.retrieve clock data from RTC
     */

    if (retcode)
    {
        cmdbuf[0] = PCF8583_CTRL_ADDR;
        cmdbuf[1] = PCF8583_CTRL | 0x40;

        /* tell PCF8583 to store last count in capture latches */
        if ( retcode = SendI2C_and_chkerr(RTC_PCF8583, 2, cmdbuf) )
        {
            /* fill buffer with RTC data
             *      the byte order is this:
             * rtcbuf[0] or byte 0x01 - Microseconds (ignored)
             * rtcbuf[1] or byte 0x02 - Seconds Counter
             * rtcbuf[2] or byte 0x03 - Minutes Counter
             * rtcbuf[3] or byte 0x04 - Hours Counter & 12/24 bit
             * rtcbuf[4] or byte 0x05 - Year/Day-of-month Counter
             * rtcbuf[5] or byte 0x06 - Day-of-week/Month Counter
             *
             * please note that this read method is undocumented: the docs only talk about
             * reads done with repeated start condition after a write. Anyway, nothing is said
             * about resetting of the word address after a stop condition, so this seems to work.
             */
            if ( retcode = ReceiveI2C(RTC_PCF8583, PCF8583_RXSIZ, rtcbuf) )
            {
                /* release capture latches and restore normal operation
                 * no error checking is performed here, because this operation isn't critical
                 */
                cmdbuf[0] = PCF8583_CTRL_ADDR;
                cmdbuf[1] = PCF8583_CTRL;
                SendI2C_and_chkerr(RTC_PCF8583, 2, cmdbuf);

                /* mask out meaningless data from hour counter */
                rtcbuf[3] &= 0x3F;

                /* transfer data to ClockData structure */
                Ckdata->sec   = bcd2bin(rtcbuf+1);
                Ckdata->min   = bcd2bin(rtcbuf+2);
                Ckdata->hour  = bcd2bin(rtcbuf+3);
                Ckdata->wday  = (UWORD)( (rtcbuf[5] & 0xE0) >> 5 );

                tmp = rtcbuf[4] & 0x3F;          /* day-of-month information extracted */
                Ckdata->mday  = bcd2bin(&tmp);

                tmp = rtcbuf[5] & 0x1F;          /* month information extracted */
                Ckdata->month = bcd2bin(&tmp);

                RTC_year = (rtcbuf[4] & 0xC0) >> 6;

                if (RTC_year != RTC_saved_year)
                {
                    /* update 4-years groups xref information */
                    if (RTC_year > RTC_saved_year)
                        c4years += 1;

                    rtcbuf[0] = PCF8583_YRXREF_RESVLOC;
                    rtcbuf[1] = (RTC_year << 6) | c4years;
                    retcode = SendI2C_and_chkerr(RTC_PCF8583, 2, rtcbuf);
                }

                Ckdata->year = 1976 + (c4years*4) + RTC_year;
            }       /* data received ok from rtc */
        }           /* rtc stored data in capture latch */
    }

    return retcode;
}
#endif


/* D. functions only valid in case of Ricoh R2025
 */
#ifdef RTC_R2025
#define R2025_CTRL1_ADDR  0xE0      /* internal address of Control Register 1 */
#define R2025_CTRL1       0x20      /* Control Register 1 config */
#define R2025_CTRL2       0xA0      /* Control Register 2 config */
#define R2025_ADJ         0x7F      /* Oscillator adjustment: 3 ppm gain */
#define R2025_TXSIZ       11        /* Size of buffer to be sent to RTC chip */
#define R2025_RXSIZ       16        /* Size of buffer to be received from RTC chip */

int write_RTC(struct ClockData * Ckdata)
{
    UBYTE rtcbuf[R2025_TXSIZ];
    int temp;
    UBYTE century;

    /* 1. fill buffer to be downloaded to RTC
     *      we first write the control registers, then index starting at 0x0E will
     *      roll over from 0x0F to 0x00: so the byte order is this:
     * rtcbuf[0] address pointer and transmission format
     * rtcbuf[1] or byte 0x0E - Control Register 1
     * rtcbuf[2] or byte 0xFF - Control Register 2
     * rtcbuf[3] or byte 0x00 - Seconds Counter
     * rtcbuf[4] or byte 0x01 - Minutes Counter
     * rtcbuf[5] or byte 0x02 - Hours Counter
     * rtcbuf[6] or byte 0x03 - Day-of-week Counter
     * rtcbuf[7] or byte 0x04 - Day-of-month Counter
     * rtcbuf[8] or byte 0x05 - Month Counter + Century bit
     * rtcbuf[9] or byte 0x06 - Year Counter
     * rtcbuf[10] or byte 0x07 - Oscillator Adjustment register
     *     bytes 0x08 to 0x0D - Alarm/unused -- NOT written
     */

    rtcbuf[0] = R2025_CTRL1_ADDR;
    rtcbuf[1] = R2025_CTRL1;
    rtcbuf[2] = R2025_CTRL2;
    rtcbuf[3] = bin2bcd(Ckdata->sec);
    rtcbuf[4] = bin2bcd(Ckdata->min);
    rtcbuf[5] = bin2bcd(Ckdata->hour);
    rtcbuf[6] = (UBYTE) (Ckdata->wday);
    rtcbuf[7] = bin2bcd(Ckdata->mday);

    temp = (int) (Ckdata->year - 1976);    /* clock data is stored relative to the leap
                                            * year which is closest to 1978 */

    if ( (temp-100) < 0)
        century = 0x00;
    else {
        century = 0x80;
        temp -= 100;
    }

    rtcbuf[8] = century | bin2bcd(Ckdata->month);
    rtcbuf[9] = bin2bcd(temp);

    rtcbuf[10] = R2025_ADJ;

    #ifdef DEBUG
        printf("rtcI2C rtcbuf: %X %X %X %X %X %X %X %X %X %X\n", rtcbuf[0],rtcbuf[1],rtcbuf[2],rtcbuf[3],rtcbuf[4],rtcbuf[5],rtcbuf[6],rtcbuf[7],rtcbuf[8],rtcbuf[9]);
    #endif

    /* send data over to I2C RTC */
    return SendI2C_and_chkerr(RTC_R2025, R2025_TXSIZ, rtcbuf);
}


int read_RTC(struct ClockData * Ckdata)        /* R2025 */
{
    int retcode;
    UBYTE rtcbuf[R2025_RXSIZ];
    UBYTE temp, tempYr;

    /* 1. fill buffer with RTC data
     *      note that R2025 may be read only 16 bytes at a time, with index starting at
     *      byte 0x0F and rolling over to 00: so the byte order is this:
     * rtcbuf[0] or byte 0x0F - Control Register 2
     * rtcbuf[1] or byte 0x00 - Seconds Counter
     * rtcbuf[2] or byte 0x01 - Minutes Counter
     * rtcbuf[3] or byte 0x02 - Hours Counter
     * rtcbuf[4] or byte 0x03 - Day-of-week Counter
     * rtcbuf[5] or byte 0x04 - Day-of-month Counter
     * rtcbuf[6] or byte 0x05 - Month Counter + Century bit
     * rtcbuf[7] or byte 0x06 - Year Counter
     * rtcbuf[8] or byte 0x07 - Oscillation Adjustment Register
     *     bytes 0x08 to 0x0D - Alarm/unused
     * rtcbuf[15] or byte 0x0E - Control Register 1
     */
    if ( retcode = ReceiveI2C_and_chkerr(RTC_R2025, R2025_RXSIZ, rtcbuf) )
    {
        /* check RTC setup correctness */
        if (rtcbuf[0] != R2025_CTRL2)
        {
            /* ... or some kind of alarm */
            switch (rtcbuf[0] & 0x60)
            {
                case 0x00 : Write(Output(), "R2025 osc halt alarm!\n", 30);
                            break;
                case 0x40 : Write(Output(), "R2025 osc halt due to battery voltage drop below threshold!\n", 68);
                            break;
                case 0x60 : Write(Output(), "R2025 battery voltage drop below thresold!\n", 51);
                            break;
                default   : /* normal condition, no error here */
                            break;
            }
        }

        /* 2. transfer data to ClockData structure after doing some correctness check ...
         */

        /* check RTC data correctness: years stored in RTC begin with 1976, the
         * closest leap year preceding 1978. Years 1976 (0) and 1977 (1) are not valid. */
        if ( (tempYr = bcd2bin(rtcbuf+7)) < 2)
            tempYr = 2;

        /* transfer data to ClockData structure */
        Ckdata->sec   = bcd2bin(rtcbuf+1);
        Ckdata->min   = bcd2bin(rtcbuf+2);
        Ckdata->hour  = bcd2bin(rtcbuf+3);
        Ckdata->mday  = bcd2bin(rtcbuf+5);
        Ckdata->wday  = bcd2bin(rtcbuf+4);

        temp = rtcbuf[6] & 0x1F;          /* exclude century information, retain month */
        Ckdata->month = bcd2bin(&temp);

        temp = (rtcbuf[6] & 0x80) >> 7;   /* exclude month information, retain century */
        Ckdata->year = 1976 + tempYr + (100 * temp);

        /* check that stored year isn't beyond system clock limit ( ULONG = 4294967295s )  */
        if (Ckdata->year >= 2114)
            Ckdata->year = 2113;
    }

    return retcode;
}
#endif

