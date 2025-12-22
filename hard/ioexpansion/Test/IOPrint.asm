*****************************************************************************
* Program: IOPrint.asm - ©1990 by The Puzzle Factory
*          Prints the register contents for the I/O Expansion board.
*   Usage: 1> IOPrint
* History: 01/22/88 V0.50 Created by Jeff Lavin
*          11/25/90 V0.51 Converted to new syntax, de-ARPed program
*
* [To all: Please don't forget to bump the revision numbers if you do *any*
*          modifications at all.  -Jeff]
*****************************************************************************

;Set Tabs           |       |                 |       |

	exeobj
	objfile	'ram:IOPrint'
	macfile 'Includes:IOexp.i'	;The One & Only include file

IOPrint 	lea	(DosName,pc),a1	;Open DOS library
	moveq	#0,d0
	movea.l (SysBase).w,a6
	SYS	OpenLibrary
	movea.l d0,a6
	tst.l	d0
	bne.b	DoIt
	rts

DoIt	SYS	Output
	move.l	d0,d4
	beq.b	Cleanup

	lea	(Newline,pc),a0
	bsr	Puts
	bsr.b	PrintVIA
	bsr	PrintACIA
Cleanup	movea.l	a6,a1
	movea.l (SysBase).w,a6
	SYS	CloseLibrary
	moveq	#0,d0
	rts

PrintVIA	lea	(VIA_Base+VIA0),a3
	lea	(VIA0.msg,pc),a0
	bsr.b	PrintV0

PrintV1	lea	(VIA_Base+VIA1),a3
	lea	(VIA1.msg,pc),a0
PrintV0	lea	(FmtArgs),a1
	movea.l	a1,a2
	moveq	#0,d1
1$	moveq	#0,d0
	move.b	(a3,d1.w),d0
	move.w	d0,(a2)+
	addi.w	#$0100,d1
	cmpi.w	#$1000,d1
	blo.b	1$	;BLO
	bsr.b	Printf
	rts

PrintACIA	lea	(ACIA_Base+ACIA0),a3
	lea	(ACIA0_1.msg,pc),a0
	bsr.b	PrintA

PrintA02	lea	(ACIA0_2.msg,pc),a0
	bsr.b	PrintA

PrintA11	lea	(ACIA_Base+ACIA1),a3
	lea	(ACIA1_1.msg,pc),a0
	bsr.b	PrintA

PrintA12	lea	(ACIA1_2.msg,pc),a0
PrintA	lea	(FmtArgs),a1
	movea.l	a1,a2
	moveq	#0,d1
1$	moveq	#0,d0
	move.b	(a3,d1.w),d0
	move.w	d0,(a2)+
	addi.w	#$0100,d1
	cmpi.w	#$0400,d1
	blo.b	1$	;BLO
	bsr.b	Printf
	rts

*********************************************************************
* NAME:     Printf()
* FUNCTION: Print formatted strings to stdout.
* INPUTS:   A0 = Format string.
*           A1 = Ptr to arguments.
* RETURN:   None
* SCRATCH:  D0-D1/A0-A1
*********************************************************************

Printf	movem.l	a2-a3/a6,-(sp)
	lea	(KPutChar,pc),a2	;Byte fill routine
	lea	(OutBuf),a3
	move.l	a3,-(sp)
	movea.l	(SysBase).w,a6
	SYS	RawDoFmt	;Do it!
	movea.l	(sp)+,a0
	movem.l	(sp)+,a2-a3/a6
	bsr.b	Puts
	rts

KPutChar	move.b	d0,(a3)+
	rts

*************************************************************************
* NAME:     Puts()
* FUNCTION: Writes a message to stdout.
* INPUTS:   A0 = Ptr to message.
* RETURN:   None
* SCRATCH:  D0-D1/A0-A1
*************************************************************************

Puts	movem.l	d2-d3,-(sp)
	move.l	a0,d3
1$	tst.b	(a0)+
	bne.s	1$
	exg	a0,d3
	sub.l	a0,d3
	subq.l	#1,d3	;Length
	move.l	a0,d2	;Buffer
	move.l	d4,d1	;FileHandle
	SYS	Write
	movem.l	(sp)+,d2-d3
	rts

DosName	cstr	'dos.library'

VIA0.msg	db	'VIA0:  %02x %02x %02x %02x %02x %02x %02x %02x '
	cstr	       '%02x %02x %02x %02x %02x %02x %02x %02x',10
VIA1.msg	db	'VIA1:  %02x %02x %02x %02x %02x %02x %02x %02x '
	cstr	       '%02x %02x %02x %02x %02x %02x %02x %02x',10
ACIA0_1.msg	cstr	'ACIA0, Unit 1: %02x %02x %02x %02x    ',0
ACIA0_2.msg	cstr	       'Unit 2: %02x %02x %02x %02x',10,0
ACIA1_1.msg	cstr	'ACIA1, Unit 1: %02x %02x %02x %02x    ',0
ACIA1_2.msg	db	       'Unit 2: %02x %02x %02x %02x'
Newline	cstr	10

	SECTION mem,BSS

FmtArgs	ds.w	16
OutBuf	ds.b	80

	end
