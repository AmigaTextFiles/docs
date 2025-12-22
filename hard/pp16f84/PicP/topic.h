/*
 * topic.h
 *
 * Header file for hardware-level routines used by the TOPIC project.
 *
 * Revision history:
 *
 * 29-Aug-1996: V-0.0; wrote definitions
 * 03-Apr-1998: V-0.1; renamed and updated for TOPIC V-0.3
 * 26-Dec-2001: V-1.0; Amiga version
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


#ifndef __TOPIC_H
#define __TOPIC_H
#include <dos.h>

#define IN		128
#define OUT		1
#define CLK		2
#define VDD		4
#define VPP		8

#define inbit		(((ciab.ciapra & CIAF_PRTRBUSY) ? 0 : 1))

#define vddon		(c_bits &= ~VDD)	/* D2 lo */
#define vddoff		(c_bits |= VDD)		/* D2 hi */
#define vppon		(c_bits &= ~VPP)	/* D3 lo */
#define vppoff		(c_bits |= VPP)		/* D3 hi */
#define clkhi		(c_bits |= CLK)		/* D1 hi */
#define clklo		(c_bits &= ~CLK)	/* D1 lo */
#define outhi		(c_bits |= OUT)		/* D0 hi */
#define outlo		(c_bits &= ~OUT)	/* D0 lo */
#define allhi		(c_bits = 0xff)		/* D0-D7 hi */
#define assert		(ciaa.ciaprb=c_bits)

#define TDLY		5			/* default delay 5 */
#define PWRDLY		25000			/* power-up delay (25 ms) */

#define STOP		0
#define GO		1

extern int d_reg;
extern int dumpfmt;

int interact(int wait);
void run_mode(int mode);
void prog_mode(void);
void out_word(int w);
int in_word(void);
void command(int cmd);
void cleanup(void);
int setup(void);

#endif /* __TOPIC_H */
