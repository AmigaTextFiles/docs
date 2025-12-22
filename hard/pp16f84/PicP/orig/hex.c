/*
 * hex.c
 *
 * Load/dump Microchip (Intel) format hex files.  Both INHX8M and INHX16
 * styles are supported.
 *
 * Revision history:
 *
 * 10-Mar-1994: V-0.0; initial routines written for pp.c V-0.3
 * 11-Jul-1996: V-0.1; deals with integrated files, auto-identify format
 *
 * Copyright (C) 1996 David Tait.  All rights reserved.
 * Permission is granted to use, modify, or redistribute this software
 * so long as it is not sold or exploited for profit.
 *
 * THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include "hex.h"

static char *version = "hex.c V-0.1  Copyright (C) 1996 David Tait";

U16 progbuf[MAXPM];
U16 databuf[MAXDM];
U16 idbuf[4];
U16 config;
int pmlast;             /* last program memory address loaded */
int dmlast;             /* last EEDATA memory address loaded */
int id;                 /* base address of ID if loaded, 0 otherwise */
int cf;                 /* base address of config if loaded, 0 otherwise */
int format = UNKNOWN;   /* hex style */

static int check;
static int fail;

static unsigned hexdigit(FILE *fp)
{
   int c;

   if ( fail )
      return 0;

   if ( (c=getc(fp)) == EOF ) {
      fail = HE_EOF;                    /* unexpected EOF */
      return 0;
   }

   c -= c>'9'? 'A'-10: '0';
   if ( c<0 || c>0xF )
      fail = HE_DEX;                    /* hex digit expected */
   return c;
}


static unsigned hexbyte(FILE *fp)
{
   unsigned b;

   b = hexdigit(fp);
   b = (b<<4) + hexdigit(fp);
   check += b;
   return b;
}


static unsigned hexword(FILE *fp)
{
   unsigned w;

   w = hexbyte(fp);
   w = (w<<8) + hexbyte(fp);
   return w;
}


/* identify(fp)
 *
 * Checks whether the hex file is in INHX8M format.  If the file
 * is clearly not INHX8M it is assumed to be INHX16.
 *
 */

static void identify(FILE *fp)
{
    unsigned b;

    fseek(fp, 1L, 0);
    b = hexbyte(fp);                   /* get number of bytes in record */
    fseek(fp, (long) (11+2*b), 0);     /* jump to alleged end of record */
    format = (getc(fp) == '\n')? INHX8M: INHX16;        /* is it there? */
    fseek(fp, 0L, 0);
}


#define HEXBYTE()       hexbyte(fp); if (fail) return fail
#define HEXWORD()       hexword(fp); if (fail) return fail

/* loadhex(fp, psize, dsize, ibase, cbase, dbase)
 *
 * Loads a Microchip hex file.  Words between 0 and psize-1 are stored
 * in the program memory buffer; words between dbase and dbase+dsize-1
 * are stored in the EEDATA buffer; 4 ID words at ibase and above are
 * stored in the ID buffer; and the word at cbase is stored in config.
 * Returns 0 for success, -ve for failure and +ve if any records were
 * out-of-range.  On exit the gobal variable format can be used to
 * determine the style (INHX8M or INHX16) loaded.
 *
 */

int loadhex(FILE *fp, int psize, int dsize, int ibase, int cbase, int dbase)
{
    int address, type, nwords, i, ign = 0;
    unsigned w;

    if ( format == UNKNOWN )
	identify(fp);

    fail = 0;
    pmlast = -1;
    dmlast = -1;
    id = 0;
    cf = 0;
    type = 0;
    while ( type != 1 ) {
	if ( getc(fp) != ':' )
	    return HE_CEX;              /* expected ':' */
	check = 0;
	nwords = HEXBYTE();
	address = HEXWORD();
	if ( format == INHX8M ) {       /* INHX8M lies */
	    nwords /= 2;
	    address /= 2;
	}
	type = HEXBYTE();
	for ( i=0; i<nwords; ++i, ++address ) {
	    w = HEXWORD();
	    if ( format == INHX8M )
		w = SWAB(w);                    /* swap byte order */
	    if ( address >= psize || address < 0 ) {
		if ( address >= ibase && address < (ibase+4) ) {
		    idbuf[address-ibase] = w;
		    id = ibase;
		} else if ( address == cbase ) {
		    config = w;
		    cf = cbase;
		} else if ( address>=dbase && address<(dbase+dsize) ) {
		    databuf[address-dbase] = w;
		    if ( dmlast < address )
			dmlast = address;
		} else
		    ign = 1;                    /* else ignore */
	    } else {
		progbuf[address] = w;
		if ( pmlast < address )
		    pmlast = address;
	    }
      }
      HEXBYTE();                        /* get checksum */
      (void) getc(fp);                  /* discard end-of-line */
      if ( check&0xFF )
	 return HE_CHK;                 /* checksum error */
   }

   return (ign? HE_IGN: 0);
}


static void d_hexbyte(FILE *fp, unsigned b)
{
    fprintf(fp,"%02X",b);
    check += b;
}


static void d_hexword(FILE *fp, unsigned w)
{
    d_hexbyte(fp,w>>8);
    d_hexbyte(fp,w&0xFF);
}


/* d_hexrec(fp, buf, address, nw)
 *
 * Dumps nw words from buf in INHX8M or INHX16 format.
 *
 */

static void d_hexrec(FILE *fp, U16 *buf, int address, int nw)
{
    int i, n;
    unsigned w;

    while ( nw > 0 ) {
	check = 0;
	fprintf(fp,":");
	n = (nw > NWORDS)? NWORDS: nw;
	if ( format == INHX8M ) {
	    d_hexbyte(fp,2*n);
	    d_hexword(fp,2*address);
	} else {
	    d_hexbyte(fp,n);
	    d_hexword(fp,address);
	}
	d_hexbyte(fp,0);
	for ( i=0; i < n; ++i ) {
	    w = *buf++;
	    if ( format == INHX8M )
		w = SWAB(w);                    /* swap byte order */
	    d_hexbyte(fp,w>>8);
	    d_hexbyte(fp,w&0xFF);
	}
	d_hexbyte(fp,(-check)&0xFF);
	fprintf(fp,"\n");
	nw -= NWORDS;
	address += NWORDS;
    }
}


/* dumphex(fp, psize, dsize, ibase, cbase, dbase)
 *
 * Dumps buffers in Microchip format.  Only psize words of program
 * memory and dsize words of EEDATA are dumped.  The ID words at
 * ibase are dumped if ibase is non-zero.  The config word at cbase
 * is dumped if cbase is non-zero.  The global variable format is
 * consulted to determine whether INHX8M or INHX16 style is used.
 *
 */

void dumphex(FILE *fp, int psize, int dsize, int ibase, int cbase, int dbase)
{
    d_hexrec(fp, progbuf, 0, psize);            /* program memory */
    if ( ibase )
	d_hexrec(fp, idbuf, ibase, 4);          /* ID words */
    if ( cbase )
	d_hexrec(fp, &config, cbase, 1);        /* config word */
    d_hexrec(fp, databuf, dbase, dsize);        /* EEDATA */
    fprintf(fp,":00000001FF\n");
}


/* erasehex(psize, dsize, ws)
 *
 * Initialise buffers to imitate the erased state.
 *
 */

void erasehex(int psize, int dsize, int ws)
{
    int i, w;

    w = (ws==12)? 0xFFF: 0x3FFF;

    for ( i=0; i < psize; ++i )
	progbuf[i] = w;

    for ( i=0; i < dsize; ++i )
	databuf[i] = 0xFF;

    for ( i=0; i < 4; ++i )
	idbuf[i] = w;

    config = w;
}


/* errhex(e)
 *
 * Returns a string describing a loadhex() error or warning.
 *
 */

char *errhex(int e)
{
    switch ( e ) {
	case HE_EOF: return "Unexpected EOF";
	case HE_DEX: return "Hex digit expected";
	case HE_CEX: return "':' expected";
	case HE_CHK: return "Checksum error";
	case HE_IGN: return "Some records ignored";
    }
    return "OK";
}

