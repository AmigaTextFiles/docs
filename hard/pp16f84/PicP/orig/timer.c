/*
 * timer.c
 *
 * Implements small delays using the PC CTC.  The information needed
 * to write this stuff came from Kris Heidenstrom's PC timing FAQ.
 *
 * Revision history:
 *
 * 15-Mar-1996: V-0.0; created for use with pp5x.c
 * 03-Sep-1996: V-0.1; modified version used by pp.c/topic.c
 * 01-Apr-1998: V-0.2; latch correct timer in ms_delay()
 *
 * Copyright (C) 1996-1998 David Tait.  All rights reserved.
 * Permission is granted to use, modify, or redistribute this software
 * so long as it is not sold or exploited for profit.
 *
 * THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */

#include "timer.h"

static char *version = "timer.c V-0.2  Copyright (C) 1996-1998 David Tait";    


/* setup_timer(cmd)
     *
     * Initialise PORTB and CTC.
     *
     */

void setup_timer(int cmd)
{
    asm pushf
    asm cli
    asm in      al,PORTB
    asm and     al,0xFD         /* disable speaker */
    asm or      al,1            /* enable timer 2 gate */
    asm out     PORTB,al
    asm mov     ax,cmd
    asm out     (TIMER+3),al    /* send command */
    asm popf
}



    /* ms_delay(ticks)
     *
     * Returns after roughly ticks*0.8381 microseconds (ticks must
     * be non-negative and less than 32768 therefore the maximum
     * delay is about 27 milliseconds).  On exit, initialises timer 
     * 2 ready for us_delay().
     *
     */

void ms_delay(int ticks)
{
    unsigned hi, lo;

    if ( ticks == 0 ) {
        setup_timer(0x90);      /* timer 2, mode 0, 1-byte reload */
        return;
    }
    
    hi = ticks>>8;
    lo = ticks&0xFF;

    setup_timer(0xB0);          /* timer 2, mode 0, 2-byte reload */

    asm pushf
    asm cli
    asm mov     ax,lo
    asm out     (TIMER+2),al    /* load lo-byte */
    asm in      al,PORTB        /* waste some time */
    asm mov     ax,hi
    asm out     (TIMER+2),al    /* load hi-byte */
    asm popf
mschk:
    asm mov     al,0x80         /* was 0x0 */
    asm out     (TIMER+3),al    /* latch count */
    asm in      al,(TIMER+2)    /* read latch lo-byte */
    asm in      al,PORTB        /* waste some time */
    asm in      al,(TIMER+2)    /* read latch hi-byte */
    asm shl     al,1
    asm jnc     mschk           /* wait until count wraps around  */

    setup_timer(0x90);          /* revert to mode 0, 1-byte reload */
}


    /* us_delay(ticks)
     *
     * Returns after roughly ticks*0.8381 microseconds (ticks must
     * be non-negative and less than 128 therefore the maximum
     * delay is about 107 microseconds).  Can only be called after
     * timer 2 has been initialised.  Slightly more accurate than
     * ms_delay() for short delays on slow machines.  Note, runs with 
     * interrupts off.
     *
     */

void us_delay(int ticks)
{
    if ( ticks == 0 )
        return;

    asm pushf
    asm cli
    asm mov     ax,ticks
    asm out     (TIMER+2),al    /* reload timer 2 */
uschk:
    asm mov     al,0x80
    asm out     (TIMER+3),al    /* latch count */
    asm in      al,(TIMER+2)    /* read latch */
    asm shl     al,1
    asm jnc     uschk           /* wait until count wraps around  */
    asm popf
}


    /* reset_timer()
     *
     * Attempts to restore timer 2 to default state.
     *
     */

void reset_timer(void)
{
    asm pushf
    asm cli
    asm mov     al,0xB6         /* mode 3, two-byte reload */
    asm out     (TIMER+3),al    /* send command */
    asm in      al,PORTB
    asm and     al,0xFC         /* disable speaker */
    asm out     PORTB,al
    asm popf
}
