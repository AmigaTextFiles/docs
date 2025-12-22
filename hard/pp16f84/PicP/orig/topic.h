/*
 * topic.h
 *
 * Header file for hardware-level routines used by the TOPIC project.
 *
 * Revision history:
 *
 * 29-Aug-1996: V-0.0; wrote definitions
 * 03-Apr-1998: V-0.1; renamed and updated for TOPIC V-0.3
 *
 * Copyright (C) 1996-1998 David Tait.  All rights reserved.
 * Permission is granted to use, modify, or redistribute this software
 * so long as it is not sold or exploited for profit.
 *
 * THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */

#ifndef __TOPIC_H
#define __TOPIC_H
#include <dos.h>
#include "timer.h"

#ifdef _MSC_VER                         /* changes for Microsoft C V7.00 */
#define outportb(p,v)        _outp(p,v)
#define inportb(p)           _inp(p)
#endif

#define IN      128
#define VPP     4
#define CLAMP   8
#define CLK     1
#define OUT     2

#define inbit           ((inportb(s_reg)&IN))
#define reset           (outportb(d_reg,1))
#define go              (outportb(d_reg,0))
#define clampon         (c_bits |= CLAMP)
#define clampoff        (c_bits &= ~CLAMP)
#define vppon           (c_bits &= ~VPP)
#define vppoff          (c_bits |= VPP)
#define clkhi           (c_bits &= ~CLK)
#define clklo           (c_bits |= CLK)
#define outhi           (c_bits &= ~OUT)
#define outlo           (c_bits |= OUT)
#define assert          (outportb(c_reg,c_bits))

#define TDLY            TICKS(5)                /* default delay */
#define PWRDLY          TICKS(25000)            /* power-up delay (25 ms) */

#define STOP            0
#define GO              1

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

#endif  /* __TOPIC_H */
