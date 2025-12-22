/*
 * timer.h
 *
 * Header for timer.c routines.
 *
 * Orignal Copyright (C) 1996-1998 David Tait.  All rights reserved.
 * Permission is granted to use, modify, or redistribute this software
 * so long as it is not sold or exploited for profit.
 *
 * Amiga version and Silicon Chip "Pic Programmer and Checkerboard"
 * modifications by Ken Tyler.
 *
 * 26-dec-2001: V-1.0; Amiga version
 *
 * THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */

#ifndef __TIMER_H
#define __TIMER_H

void setup_timer(int cmd);
int get_timer(void);
void free_timer(void);
void us_delay(unsigned long u_secs);

#endif /* __TIMER_H */
