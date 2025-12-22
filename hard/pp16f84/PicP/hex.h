/*
 * hex.h
 *
 * Header file for hex load/dump routines.
 *
 * Revision history:
 *
 * 11-Jul-1996: V-0.0; wrote definitions
 * 14-Jul-1996: V-0.1; created separate header file
 * 26-Dec-2001: V-1.0; Amiga version
 *
 * Copyright (C) 1996 David Tait.  All rights reserved.
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

#ifndef __HEX_H
#define __HEX_H

#define NWORDS	8		/* dump this many words per hex record */

#define MAXPM	4096		/* max size of program memory */
#define MAXDM	64		/* max size of EEDATA memory */

#define UNKNOWN -1		/* hex formats */
#define INHX8M	0
#define INHX16	1

#define HE_EOF	-1		/* unexpected EOF */
#define HE_DEX	-2		/* hex digit required */
#define HE_CEX	-3		/* missing ':' */
#define HE_CHK	-4		/* checksum error */
#define HE_IGN	1		/* warning that some records were ignored */

#define SWAB(w) (((w)>>8) + (((w)&0xFF)<<8))	/* swap byte macro */

typedef unsigned short U16;	 /* should be 2 bytes on most systems */

extern U16 progbuf[MAXPM];	/* program memory */
extern U16 databuf[MAXDM];	/* EEDATA memory */
extern U16 idbuf[4];		/* ID words */
extern U16 config;		/* config word */
extern int pmlast;		/* last program memory address loaded */
extern int dmlast;		/* last EEDATA memory address loaded */
extern int id;			/* base address of ID if loaded, 0 otherwise */
extern int cf;			/* base address of config if loaded, 0 otherwise */
extern int format;		/* determines load/dump style */

int loadhex(FILE *fp, int psize, int dsize, int ibase, int cbase, int dbase);
void dumphex(FILE *fp, int psize, int dsize, int ibase, int cbase, int dbase);
void erasehex(int psize, int dsize, int ws);
char *errhex(int e);

#endif /* __HEX_H */
