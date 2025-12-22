/*
 * pp.c
 *
 * Programs PIC16x8x using generic hardware.  Based on the
 * programming specifications in Microchip data sheets DS30189D
 * and DS30262A.
 *
 * Revision history:
 *
 * ??-Feb-1994: V-0.0; started as a few routines to debug hardware.
 * 07-Mar-1994: V-0.1; first code to successfully program a 16C84.
 * 09-Mar-1994: V-0.2; fuse switches; 7407 support; H/W test.
 * 10-Mar-1994: V-0.3; LPT2, LPT3 and INHX8M support; cosmetic changes.
 * 30-Aug-1996: V-0.4; major re-write (10-Sep-96: added config warning).
 * 03-Apr-1998: V-0.5; 16F8x now default; added -osng switches.
 * 03-Apr-1998: V-0.5; identity and hardware header defined in config.h
 * 26-Dec-2001: V-1.0; Amiga version
 *
 * Copyright (C) 1994-1998 David Tait.  All rights reserved.
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
#include <time.h>
#include "hex.h"
#include "timer.h"
#include "topic.h"
#include "config.h"

#define LDCONF	0		/* serial mode commands */
#define LDPROG	2
#define RDPROG	4
#define INCADD	6
#define BEGPRG	8
#define LDDATA	3
#define RDDATA	5
#define ERPROG	9
#define ERDATA	11

#define PRGDLY	10000		/* programming delay (10000us) */

#define PSIZE	1024		/* PIC16C84 parameters */
#define DSIZE	64
#define IBASE	0x2000
#define CBASE	0x2007
#define DBASE	0x2100

#define CPBITS	0x3FF0		/* config elements */
#define OLDCP	0x10
#define PWRTE	8
#define WDTE	4
#define RC	3
#define HS	2
#define XT	1
#define LP	0

#define SUCCESS 0		/* exit return status */
#define FAIL	1

int valid = 0;			/* true if port, timer and H/W exist*/
int setcfg = 0;			/* true if config set by command-line */
int oldcfg = 0;			/* use old style (16C84) config if true */
int dump = 0;			/* dump PIC to a file if true */
int erase = 0;			/* erase PIC if true */
int verify_only = 0;		/* verify PIC against a file if true */
int wait4pic = 1;		/* wait for PIC insertion */
int silent = 0;			/* run silently if true */
int can_read = 1;		/* can read PIC while programming */
int mode = STOP;		/* let PIC run mode = GO */
int got_file = 0;		/* true if filename given in command line */

char *pname = PNAME;
char *version = VERSION;
char *does = DOES;
char *copyright = COPYRIGHT;
char *email = EMAIL;

#ifdef __SASC
	VOID __regargs
	_CXBRK (VOID) {
	    printf ("break...\n");
	    cleanup();
	    exit (0);
	}
#endif

void quit(char *s, int status)
{
    int i;

    if ( s )
	if (silent)
            for (i = 0 ; i < 5 ; i++) {
		printf("\7");fflush(stdout);
                us_delay(50000);
	    }
	else
	    fprintf(stderr,silent?"":"%s: %s\n",pname,s);

    if ( valid ) {
	if ( erase && !got_file )
	    run_mode(STOP);		/* can't run if PIC erased */
	else
	    run_mode(status==0?mode:STOP);
    } else if (setup() >= 0)		/* call setup again for debugging */
	run_mode(STOP);

    cleanup();
    exit(status);
}


void usage(void)
{
    if ( silent )
	quit(NULL,SUCCESS);

    printf("%s\n%s\n%s\n\n",does,version,copyright);
    printf("Usage: %s  [ -lxhrwpcdevgosn! ] hexfile\n\n",pname);
    printf("        Config:   l = LP,   x = XT,     h = HS,      r = RC\n");
    printf("                  w = WDTE, p = PWRTE,  c = code protect\n");
    printf("        Others:   d = dump, e = erase,  v = verify,  g = go\n");
    printf("                  o = old,  s = silent, n = no read, ! = no wait\n");
    printf("        Defaults: RC, /WDTE, /PWRTE, unprotected,\n");
    printf("                  no erase, stop, new, verbose, read, wait\n\n");
    printf("Amiga bug reports to %s\n",email);
    quit(NULL,SUCCESS);
}


void get_option(char *s)
{
   char *sp;

   for ( sp=s; *sp; ++sp )
	switch ( *sp ) {
		case 'l':
		case 'L': config = (config&0x3FFC) + LP; ++setcfg; break;
		case 'x':
		case 'X': config = (config&0x3FFC) + XT; ++setcfg; break;
		case 'h':
		case 'H': config = (config&0x3FFC) + HS; ++setcfg; break;
		case 'r':
		case 'R': config = (config&0x3FFC) + RC; ++setcfg; break;
		case 'w':
		case 'W': config |= WDTE; ++setcfg; break;
		case 'p':
		case 'P': config &= ~PWRTE; ++setcfg; break;
		case 'c':
		case 'C': config &= ~CPBITS; ++setcfg; break;
		case '2':
		case '3':
		case '8': break;			/* ignore for compatibility with V-0.3 */
		case '!': wait4pic = 0; break;
		case 'e':
		case 'E': erase = 1; break;
		case 'd':
		case 'D': dump = 1; break;
		case 'v':
		case 'V': verify_only = 1; break;
		case 'g':
		case 'G': mode = GO; break;
		case 'o':
		case 'O': oldcfg = 1; break;
		case 's':
		case 'S': silent = 1; wait4pic = 0; break;
		case 'n':
		case 'N': can_read = 0; break;
		case '-':
		case '/': break;
		default: usage();
	}
}


void prog_cycle(U16 w)
{
    out_word(w);
    command(BEGPRG);
    us_delay(PRGDLY);
}


void erase_all(void)
{
   int i;

   prog_mode();
   command(LDCONF);		/* defeat code protection */
   out_word(0x3FFF);
   for ( i=0; i<7; ++i )
	command(INCADD);
   command(1);
   command(7);
   command(BEGPRG);
   us_delay(PRGDLY);
   command(1);
   command(7);

   command(ERPROG);		/* bulk erase program/config memory */
   prog_cycle(0x3FFF);

   command(ERDATA);		/* bulk erase data memory */
   prog_cycle(0x3FFF);
}


void load_conf(int base)
{
    int i, n;

    command(LDCONF);
    out_word(config);

    n = base - IBASE;
    for ( i=0; i<n; ++i )
	command(INCADD);
}


U16 read_conf(void)		/* added for V-0.5 */
{
    int i;

    prog_mode();
    command(LDCONF);
    out_word(0x3FFF);
    for ( i=0; i<7; ++i )
	command(INCADD);
    command(RDPROG);
    return (U16)(in_word() & 0x3FFF);
}


void program(U16 *buf, int n, U16 mask, int ldcmd, int rdcmd, int base, char *s)
{
    int i, change = 0 ;
    U16 r, w;

    prog_mode();

    if ( base >= IBASE && base <= CBASE )
	load_conf(base);

    for ( i=0; i<n; ++i ) {
	w = buf[i]&mask;
	if ( can_read ) {
	    command(rdcmd);
	    r = in_word() & mask;
	    if ( w != r ) {
                change = 1;
		if (!(silent)) {
		    printf("%s 0x%4.4x\r",s, i);
		    fflush(stdout);
		}
		command(ldcmd);
		prog_cycle(w);
		command(rdcmd);
		r = in_word() & mask;
		if ( w != r ) {
		    fprintf(stderr,
			    silent?"":"\n%s: 0x%4.4x: read 0x%4.4x, wanted 0x%4.4x\n",
						 pname,base+i,r,w);
		    quit("Verify failed during programming",FAIL);
		}
	    }
	} else {
	    if (!(silent)) {
		printf("%s 0x%4.4x\r",s, i);
		fflush(stdout);
	    }
	    command(ldcmd);
	    prog_cycle(w);
	}
	command(INCADD);
    }
    if (change)
	printf(silent?"":"\n");
}


void verify(U16 *buf, int n, U16 mask, int rdcmd, int base, char *s)
{
    int i;
    U16 r, w;

    prog_mode();

    if ( base >= IBASE && base <= CBASE )
	load_conf(base);

    for ( i=0; i<n; ++i ) {

	if (!(silent)) {
	    printf("%s 0x%4.4x\r", s, i);
	    fflush(stdout);
	}

	command(rdcmd);
	r = in_word() & mask;
	if ( (w = buf[i]&mask) != r ) {
	    fprintf(stderr,silent?"":"\n%s: 0x%4.4x: read 0x%4.4x, wanted 0x%4.4x\n",
		pname,base+i,r,w);
	    quit("Verify failed",FAIL);
	}
	command(INCADD);
    }
    printf(silent?"":"\n");
}


int read_pic(void)
{
    int i;

    pmlast = -1;
    dmlast = -1;
    id = 0;
    cf = 0;

    prog_mode();
    for ( i=0; i<PSIZE; ++i ) {
	command(RDPROG);
	if ( (progbuf[i] = in_word() & 0x3FFF) != 0x3FFF )
	    pmlast = i;
	 command(INCADD);
    }
    prog_mode();
    for ( i=0; i<DSIZE; ++i ) {
	command(RDDATA);
	if ( (databuf[i] = in_word() & 0xFF) != 0xFF )
	    dmlast = i;
	command(INCADD);
    }
    prog_mode();
    command(LDCONF);
    out_word(0x3FFF);
    for ( i=0; i<4; ++i ) {
	command(RDPROG);
	if ( (idbuf[i] = in_word() & 0x3FFF) != 0x3FFF )
	    id = IBASE;
	command(INCADD);
    }
    for ( i=0; i<3; ++i )
	command(INCADD);
    command(RDPROG);
    if ( (config = in_word() & 0x3FFF) != 0x3FFF )
	cf = CBASE;

    return !(pmlast == -1 && dmlast == -1 && id == 0 && cf == 0 );
}


char *conf_str(U16 cfg)
{
    static char s[5];

    s[0] = (cfg&OLDCP)? '-': 'C';	/* no need to check all CP bits */
    if (oldcfg)
	s[1] = (cfg&PWRTE)? 'P': '-';	/* PWRTE inverted in old config */
    else
	s[1] = (cfg&PWRTE)? '-': 'P';
    s[2] = (cfg&WDTE)? 'W': '-';
    s[3] = "LXHR"[cfg&3];
    s[4] = '\0';

	return s;
}


void main(int argc, char *argv[])
{
    FILE *fp;
    int i, c, e, t;
    char *fn = NULL;

    U16 temp, cfmask;
    time_t start_t;

    erasehex(PSIZE, DSIZE, 14);			/* initialise buffers */
    config = CPBITS | PWRTE | RC;		/* default config */

    for ( i=1; i<argc; ++i ) {
	if ( (c = *argv[i]) == '-' || c == '/' )
	    get_option(++argv[i]);
	else {
	    if ( got_file )
		usage();
	    fn = argv[i];
	    got_file = 1;
	}
    }

    if ( (e = setup()) != 0 ) {
	if ( e == -1 )
	    quit("Can't get parallel port", FAIL);
	else if ( e == -2 )
	    quit("Can't get timer", FAIL);
	else if ( can_read )
	    quit("Hardware not connected",FAIL);
    }
    valid = 1;

    if (!erase && !(mode==GO) && !got_file)	/* no file needed for erase/go */
	usage();

    if ( dump && !got_file )			/* need file for dump */
	usage();

    if ( verify_only && !got_file )		/* need file for verify */
	usage();

    printf(silent?"":"%s\n%s\n%s\n\n",does,version,copyright);

    if ( interact(wait4pic) )			/* allow user to insert PIC */
	quit("Aborted",FAIL);

    if ( dump ) {
	printf(silent?"":"Reading ...\n");
	if ( read_pic() ) {
#if 0
	    if ( (fp = fopen(fn,"r")) != NULL )
		quit("Dump would overwrite existing file",FAIL);
	    fclose(fp);
#endif
	    if ( (fp = fopen(fn,"w")) == NULL )
		quit("Can't create hexfile",FAIL);
	    format = dumpfmt;
	    dumphex(fp, pmlast+1, dmlast+1, id, cf, DBASE);
	    fclose(fp);
	    quit(NULL,SUCCESS);
	}
    quit("PIC is erased - nothing to dump",FAIL);
    }

    if ( got_file ) {
	if ( (fp = fopen(fn,"r")) == NULL )
	    quit("Can't open hexfile",FAIL);
	temp = config;				/* preserve config */
	if ( (e = loadhex(fp, PSIZE, DSIZE, IBASE, CBASE, DBASE)) < 0 )
	    quit(errhex(e),FAIL);
	temp ^= oldcfg?PWRTE:0;			/* invert PWRTE if old style config */
	if ( setcfg )
	    config = temp;			/* use command line config */
	else if ( cf > 0 )
	    ++setcfg;				/* config set by file */
						/* otherwise use default config */
    } else if ( mode == GO )
	quit(NULL,SUCCESS);

    start_t = time(NULL);
    cfmask = oldcfg? 0x1F: 0x3FFF;		/* only 5 bits used in old config */
    if ( verify_only ) {

	printf(silent?"":"Verifying ...\n");

	if ( pmlast >= 0 )
	    verify(progbuf,pmlast+1,0x3FFF,RDPROG,0, "   ... Program");

	if ( dmlast >= 0 )
	    verify(databuf,dmlast-DBASE+1,0xFF,RDDATA,DBASE, "   ... Data   ");

	if ( id > 0 )
	    verify(idbuf,4,0x3FFF,RDPROG,IBASE, "   ... ID     ");

	verify(&config,1,cfmask,RDPROG,CBASE, "   ... Config ");

    } else {
	if ( erase ) {
	    printf(silent?"":"Erasing ...\n");
	    erase_all();
	    if ( !got_file )
		quit(NULL,SUCCESS);
	}
	if ( can_read && (read_conf()&OLDCP) == 0 )
	    quit("PIC is protected - erase before programming",FAIL);

	printf(silent?"":"Programming ...\n");

	if ( pmlast >= 0 )
	    program(progbuf,pmlast+1,0x3FFF,LDPROG,RDPROG,0, "   ... Program");

	if ( dmlast >= 0 )
	    program(databuf,dmlast-DBASE+1,0xFF,LDDATA,RDDATA,DBASE, "   ... Data   ");

	if ( id > 0 )
	    program(idbuf,4,0x3FFF,LDPROG,RDPROG,IBASE, "   ... ID     ");

	if ( !setcfg )
	    printf(silent?"":"Warning - using default config\n");

	printf(silent?"":"Setting config to %s ...\n",conf_str(config));
	program(&config,1,cfmask,LDPROG,RDPROG,CBASE, "   ... Config ");

	if ( can_read )
	    printf(silent?"":"(config now 0x%4.4x)\n",read_conf());
    }
    t = (int) (time(NULL)-start_t);
    printf(silent?"":"Finished in %d sec%c\n",t,(t!=1)? 's': ' ');
    quit(NULL,SUCCESS);
}
