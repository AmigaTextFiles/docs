/*
 * timer.h
 *
 * Header for timer.c routines.
 *
 * Revision history:
 *
 * 15-Mar-1996: V-0.0; created for use with pp5x.c
 * 03-Sep-1996: V-0.1; modified version used by pp.c/topic.c
 *
 * Copyright (C) 1996 David Tait.  All rights reserved.
 * Permission is granted to use, modify, or redistribute this software
 * so long as it is not sold or exploited for profit.
 *
 * THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */


#ifndef __TIMER_H
#define __TIMER_H

#ifdef _MSC_VER
#define asm             __asm
#endif

#define TIMER           0x40                    /* base address of CTC */
#define PORTB           0x61                    /* speaker control port */
#define TICKS(us)       ((unsigned) (1.193182*(us)+1))  /* us to ticks */

void setup_timer(int cmd);
void ms_delay(int ticks);
void us_delay(int ticks);
void reset_timer(void);

#endif /* __TIMER_H */

