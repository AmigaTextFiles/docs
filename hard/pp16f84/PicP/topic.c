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
 * 26-Dec-2001; V-1.0; Amiga version
 *
 * Copyright (C) 1996-1998 David Tait.  All rights reserved.
 * Permission is granted to use, modify, or redistribute this software
 * so long as it is not sold or exploited for profit.
 *
 * Amiga version and Silicon Chip "Pic Programmer and Checkerboard"
 * modifications by Ken Tyler.
 *
 * THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "topic.h"
#include "hex.h"
#include "timer.h"
#include "port.h"

#include <hardware/cia.h>

extern volatile struct CIA ciaa, ciab;
char ciaa_ciaddrb_save;
char ciab_ciaddra_save;

int c_bits;
long tdly = TDLY;
int dumpfmt = INHX8M;


void ppdelay(char *s)		/* get delay from environment */
{
    if (s)
	if ((tdly = atoi(s)) < 0 || tdly > 999999)
	    tdly = TDLY;
}

void pphxfmt(char *s)		/* get dump format */
{
    if (s)
	if (atoi(s) == 16)
	   dumpfmt = INHX16;
}


int interact(int wait)
{
    if (wait) {
/*	printf("Insert PIC ... press any key to continue (^C to abort)\n"); */
	printf("Insert PIC ...");
	getch();
	printf("\nTurn on supplies ...");
	getch();
	printf("\n");
    }
    return 0;
}

void run_mode(int mode)
{
#if 0
    reset;
    vppoff, clampon, clkhi, outhi, assert;
#else
    vppoff, vddoff, clkhi, outhi, assert;
/*  us_delay(PWRDLY); */
#endif
    if (mode == GO) {
	us_delay(PWRDLY);
#if 0
	go;
#else
	vppoff, vddon, clkhi, outhi, assert;
	us_delay(PWRDLY);
#endif
    }
}


void prog_mode(void)
{

#if 0
    reset;
    vppon, clampon, clklo, outlo, assert;
#else
    vppoff, vddon, clklo, outlo, assert;
    us_delay(PWRDLY);
    vppon, vddon, clklo, outlo, assert;
#endif
    us_delay(PWRDLY);
#if 0
    go;
#endif
}


static void clock_out(int bit)
{

    bit? outhi : outlo ; clkhi, assert;
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
    return inbit ? 0: 1;
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
    for (b=0; b<14; ++b)
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

    outhi, assert;
    (void) clock_in();
    for (w=0, b=0; b<14; ++b)
	w += clock_in()<<b;
    (void) clock_in();
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
    for (b=0; b<6; ++b)
	clock_out(cmd&(1<<b));
    outhi, assert;
    us_delay(tdly);
}


void cleanup(void)
{
    allhi, assert;
    ciaa.ciaddrb = ciaa_ciaddrb_save;			/* restore parallel port to prior state */
    ciab.ciaddra = ciab_ciaddra_save;			/* and parallel and serial control bits */
    free_port();
    free_timer();
}


void debug(char *s)
{
    if (atoi(s) != 1)
	return;

    vppoff, vddoff, clklo, outlo, assert;

    printf("Debug mode entered ... (^C to exit) ");

    getch();

    printf("\nRemove PIC ... ");
    getch();
    for(;;) {

	vppoff, vddoff, clklo, outlo, assert;
	printf("\n\n/VDD 0V (14), MCLR (4) 0V, RB6 (12) low, RB7 (13) low ... ");
	getch();
	vddon, assert;
	printf("\n/VDD (14) 5V (Red LED on)  ... ");
	getch();
	vppon, assert;
	printf("\n/MCLR (4) between 12V and 14V (Orange LED on) ... ");
	getch();
	clkhi, assert;
	printf("\nRB6 (12) clock high ... ");
	getch();
	clklo, outhi, assert;
	printf("\nRB7 (13) data high ... ");
	getch();
	clklo, outhi, assert;
	printf("\nConnect a 220 ohm resistor from RB7 (13) to GND (5) ... ");
	getch();
	s = inbit ? "OK": "BAD";
	printf("\nInput %s ... ",s);
	getch();
	printf("\nConnect a 220 ohm resistor from RB7 (13) to VDD (14) ... ");
	getch();
	s = inbit ? "BAD": "OK";
	printf("\nInput %s ... ",s);
	printf("\nStart over ... (^C to exit) ");
	getch();
    }
}

    /* setup()
     *
     * Gets exclusive access tp parallel port, sets up a timer, holds
     * PIC in the reset condition, checks hardware, reads tdly from
     * the environment.  Returns -1 if no access tp parallel port
     * -2 if no timer, 1 if the hardware is not connected and 0 otherwise.
     *
     */

int setup(void)
{
   if (get_timer())				/* get a timer */
	return -2;

   if (get_port())				/* get exclusive parallel port access */
	return -1;

    ciaa_ciaddrb_save = ciaa.ciaddrb;
    ciaa.ciaddrb = 0xff;			/* parallel port all outs */

    ciab_ciaddra_save = ciab.ciaddra;
    ciab.ciaddra &= ~CIAF_PRTRBUSY;		/* ensure busy bit is an input */

    ppdelay(getenv("PPDELAY"));
    pphxfmt(getenv("PPDUMP"));
    debug(getenv("PPDEBUG"));

    run_mode(STOP);
 
    outlo, assert;				/* check BUSY follows out */
    us_delay(tdly);
    if (!inbit)
	return 1;
    outhi, assert;
    us_delay(tdly);
    if (inbit)
	return 1;
    outlo, assert;
    us_delay(tdly);
    return 0;
}
