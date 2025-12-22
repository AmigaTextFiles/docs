/*
 * topic.c
 *
 * Hardware level routines used by the TOPIC project.  Information
 * about the parallel port was taken from Zhahai Stewart's PC printer
 * port FAQ.
 *
 * Revision history:
 *
 * 29-Aug-1996: V-0.0; created (partly based on pp.c V-0.3).
 * 03-Sep-1996: V-0.1; now uses timer.c routines
 * 03-Apr-1998: V-0.2; changed clock_in() to agree with pphw.c
 * 03-Apr-1998: V-0.3; renamed and added interact() for TOPIC V-0.3
 * 06-Jun-1998: V-0.3; added debug()
 *
 * Copyright (C) 1996-1998 David Tait.  All rights reserved.
 * Permission is granted to use, modify, or redistribute this software
 * so long as it is not sold or exploited for profit.
 *
 * THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "topic.h"
#include "hex.h"

static char *version = "topic.c V-0.3  Copyright (C) 1996-1998 David Tait";

int c_bits;
int d_reg;
int s_reg;
int c_reg;
int tdly = TDLY;
int dumpfmt = INHX8M;


void ppdelay(char *s)           /* get delay from environment */
{
    if ( s )
	if ( (tdly = atoi(s)) < 0 || tdly > 127 )
	    tdly = TDLY;
}


void pphxfmt(char *s)           /* get dump format */
{
    if ( s )
	if ( atoi(s) == 16 )
	   dumpfmt = INHX16;
}


int interact(int wait)         /* no interaction required */
{

   return wait^wait;           /* always 0 - just wanted to use wait :-) */
}


void run_mode(int mode)
{
   reset;
   vppoff, clampon, clkhi, outhi, assert;
   if ( mode == GO ) {
       ms_delay(PWRDLY);
       go;
   }
}


void prog_mode(void)
{
   reset;
   vppon, clampon, clklo, outlo, assert;
   ms_delay(PWRDLY);
   go;
}


static void clock_out(int bit)
{
   bit? outhi: outlo; clkhi, assert;
   us_delay(tdly);
   clklo, assert;
   us_delay(tdly);
   outlo, assert;
}


static int clock_in(void)
{
   clkhi, assert;
   us_delay(tdly);
   clklo, assert;
   us_delay(tdly);
   return inbit? 0: 1;
}


    /* out_word(w)
     *
     * Write a 14-bit value to the PIC.
     *
     */

void out_word(int w)
{
   int b;

   clock_out(0);
   for ( b=0; b<14; ++b )
     clock_out(w&(1<<b));
   clock_out(0);
}

    /* in_word()
     *
     * Obtain a 14-bit value from the PIC.
     *
     */

int in_word(void)
{
   int b, w;

   clampoff, outhi, assert;
   (void) clock_in();
   for ( w=0, b=0; b<14; ++b )
     w += clock_in()<<b;
   (void) clock_in();
   clampon, assert;

   return w;
}


    /* command(cmd)
     *
     * Send a 6-bit command to the PIC.
     *
     */

void command(int cmd)
{
   int b;

   outlo, assert;
   us_delay(tdly);
   for ( b=0; b<6; ++b )
      clock_out(cmd&(1<<b));
   outhi, assert;
   us_delay(tdly);
}


void cleanup(void)
{
    reset_timer();
}


void debug(char *s)
{
    if ( atoi(s) != 1 )
	return;
	
    printf("Debug mode entered ... (^C to exit) ");
    if ( getch() == 3 ) {
	printf("\n\n");
	exit(1);
    }
    printf("\nRemove PIC ... ");
    getch();
    for(;;) {
	reset;
	vppoff, clampon, clklo, outlo, assert;
	printf("\n\n/MCLR (4) 0V, RB6 (12) low, RB7 (13) low ... "); 
	getch();
	go;
	printf("\n/MCLR (4) 5V ... ");
	getch();
	vppon, assert;
	printf("\n/MCLR (4) between 12V and 14V (LED on) ... ");
	getch();
	reset;
	vppoff, clkhi, assert;
	printf("\nRB6 (12) high ... ");
	getch();
	clklo, outhi, assert;
	printf("\nRB7 (13) high ... ");
	getch();
	clampoff, assert;
	printf("\nConnect a 220 ohm resistor from RB7 (13) to GND (5) ... ");
	getch();
	s = inbit? "OK": "BAD";
	printf("\nInput %s ... ",s);
	getch();
	printf("\nConnect a 220 ohm resistor from RB7 (13) to VDD (14) ... ");   
	getch();
	s = inbit? "BAD": "OK";
	printf("\nInput %s ... ",s);
	printf("\nStart over ... (^C to exit) ");
	if (getch() == 3) {
	    printf("\n\n");
	    exit(1);
	}
    }
}

    /* setup()
     *
     * Finds printer port address, initialises timer and holds the
     * PIC in the reset condition, checks hardware, reads tdly from
     * the environment.  Returns -1 if LPT port address is non-standard,
     * 1 if the hardware is not connected and 0 otherwise.
     *
     */

int setup(void)
{
   char *s;
   int b, lpt = 1;

   if ( (s = getenv("PPLPT")) != NULL )
       if ( (lpt = atoi(s)) < 1 || lpt > 3 )
	   lpt = 1;

   d_reg = *(((int far *) 0x408) + lpt-1);  /* base address of LPT port */
   s_reg = d_reg+1;
   c_reg = s_reg+1;

   switch ( d_reg ) {                   /* check port address is valid */
       case 0x3BC:
       case 0x378:
       case 0x278: break;
	  default: return -1;
   }

   ms_delay(0);                         /* dummy call to setup CTC */

   ppdelay(getenv("PPDELAY"));
   pphxfmt(getenv("PPDUMP"));
   debug(getenv("PPDEBUG"));

   run_mode(STOP);                      /* check SEL is connected to BUSY */
   clampoff, assert;
   us_delay(tdly);
   b = inbit;
   clampon, assert;
   us_delay(tdly);
   if ( b == inbit )
       return 1;

   return 0;
}
