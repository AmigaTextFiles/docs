/* clockpref.h -- SetClock using i2c RTC,
 *                headerfile to be modified by user if needed
 *                other files shouldn't need modification
 *
 * V2.0 - 28 oct 2003
 *
 * V2.8 - 20 jan 2004
 *              Dallas/Maxim DS1307 added.
 */

#ifndef CLOCK_PREF_H
#define CLOCK_PREF_H


/* select just ONE group of those following, depending on the RTC you are using */

/*
#define CLOCKC                 "PCF8583"
#define RTC_PCF8583            0xA0   */      /* clock address; 0xA2 is also possible */
/*#define PCF8583_YRXREF_RESVLOC 0x10   */      /* This location is reserved (used to test for
                                             * >4 year time */



#define CLOCKC      "DS1629"
#define RTC_DS1629  0x9E            /* clock address */

/*
#define CLOCKC      "DS1307"
#define RTC_DS1307  0xD0       */   /* clock address */

/*
#define CLOCKC      "R2025"
#define RTC_R2025   0x64     */       /* clock address */

#endif
