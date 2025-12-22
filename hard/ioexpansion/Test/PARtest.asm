*****************************************************************************
* Program:  PARtest.asm - Copyright ©1990 by Jeff Lavin
* Function: A test program for the Rockwell 65C22.  This program takes a
*           filespec as its only argument, and stuffs the file out parallel
*           Port 2 (VIA #1, Port A) to a printer.  No devices are involved;
*           this goes right to the hardware.  Also, in this version,
*           interrupts are not used handshaking is accomplished by hardware
*           polling.
*
* Author:   Jeff Lavin
* History:  01/09/91 V0.50 Created
*****************************************************************************

;Set Tabs           |       |                 |       |

	ifnd	__m68
	fail	'Wrong assembler!'
	endc
	exeobj
	macfile 'Includes:IOexp.i' ;The One & Only include file
	objfile	'PARtest'

;This program as written stuffs a file out parallel Port 2 (VIA #1, Port A)
;to a printer.  The parallel interface should be arranged as follows:
;
;   Name    P3   Centronics
;   ====    ==   ==========
;   CA2.3    2   1  STROBE*
;   PA0.3    3   2  DATA0
;   PA1.3    4   3  DATA1
;   PA2.3    5   4  DATA2
;   PA3.3    6   5  DATA3
;   PA4.3    7   6  DATA4
;   PA5.3    8   7  DATA5
;   PA6.3    9   8  DATA6
;   PA7.3   10   9  DATA7
;   CA1.3    1  10  ACK*
;   GND    PAD  16  GND

Error	equr	d6

MyStack	clrfo
DosBase	fo.l	1
BufSiz	fo.l	1
BufPtr	fo.l	1
MS_SIZE	foval

*** Begin Mainline

PARtest	link.w	a5,#MS_SIZE
	movem.l	d0/a0,-(sp)	;Save cmd line
	clr.l	(BufSiz,a5)
	clr.l	(BufPtr,a5)
	moveq	#RETURN_OK,Error

	lea	(DosName,pc),a1
	movea.l	(SysBase).w,a6
	SYS	OldOpenLibrary	;Open dos.library
	movea.l	d0,a6
	move.l	d0,(DosBase,a5)
	bne.b	.Parse
	addq.w	#8,sp
	rts

.Parse	movem.l	(sp)+,d0/a0	;Get cmd line
	lea	(a0,d0.w),a1
..	cmpi.b	#' ',-(a1)	;Eat trailing garbage
	dbhi	d0,..
	blt.w	BadArgs	;If no arguments, quit
	clr.b	(1,a1)	;Null terminate the string

..	move.b	(a0)+,d0
	beq.w	BadArgs	;If no arguments, quit
	cmpi.b	#' ',d0	;Skip leading spaces
	beq.b	..
	cmpi.b	#'?',d0	;User wants help
	beq.w	Instruct
	subq.l	#1,a0	;Adjust ptr
	movea.l	a0,a2	;Save cmd line

	move.l	a2,d1	;FileName
	move.l	#MODE_OLDFILE,d2	;Access mode
	SYS	Open	;Open file
	move.l	d0,d4	;Save filehandle
	bne.b	.GetSize
	bra.w	OpenError

.GetSize	moveq	#OFFSET_END,d3	;Mode
	moveq	#0,d2	;Position
	move.l	d4,d1	;FileHandle
	SYS	Seek
	tst.l	d0
	bmi.b	.SeekErr

	moveq	#OFFSET_BEGINNING,d3 ;Mode
	moveq	#0,d2	;Position
	move.l	d4,d1	;FileHandle
	SYS	Seek
	move.l	d0,d3	;Length of file
	bpl.b	.GetBuffer
.SeekErr	move.l	d4,d1	;FileHandle
	SYS	Close	;Close file
	bra.w	SeekError

.GetBuffer	moveq	#MEMF_PUBLIC,d1
	move.l	d3,d0
	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	SYS	AllocMem	;Allocate a read buffer
	movea.l	(sp)+,a6
	move.l	d0,(BufPtr,a5)
	bne.b	.GotBuffer
	move.l	d4,d1	;FileHandle
	SYS	Close	;Close file
	bra.w	MemError

.GotBuffer	movea.l	d0,a3	;Buffer
	move.l	d3,(BufSiz,a5)

	move.l	a3,d2	;Buffer
	move.l	d4,d1	;FileHandle
	SYS	Read
	cmp.l	d3,d0	;ActualLength
	beq.b	.CloseFile
	move.l	d4,d1	;FileHandle
	SYS	Close	;Close file
	bra.w	ReadError

.CloseFile	move.l	d4,d1	;FileHandle
	SYS	Close	;Close file

* Initialize VIA registers

	lea	(VIA_Base+VIA1),a4	;Get chip base
	move.b	#%10000000,(INTER,a4)	;Disable interrupts
	move.b	#%00001000,(PERCR,a4)	;CA2 = Handshake output
				;CA1 = Negative edge input
	clr.b	(ORA,a4)		;Clear garbage
	move.b	#%11111111,(DDRA,a4)	;All outputs

* Stuff chars out Port A, as fast as the printer'll take 'em.

.StuffLoop	move.b	(a3)+,(ORA,a4)	;Send char & data strobe
	subq.l	#1,d3	;Decrement count
	beq.w	Cleanup	;Zero is all done
.WaitLoop	btst	#1,(INTFR,a4)	;Test CA1 bit for not busy
	beq.b	.WaitLoop	;Wait 'til char is taken
	bra.b	.StuffLoop	;Do it again

BadArgs	lea	(BadArgs.msg,pc),a2
	moveq	#RETURN_WARN,Error
	bra.b	ErrorMsg

Instruct	lea	(Instruct.msg,pc),a2
	bra.b	ErrorMsg

OpenError	lea	(OpenError.msg,pc),a2
	moveq	#RETURN_FAIL,Error
	bra.b	ErrorMsg

SeekError	lea	(SeekError.msg,pc),a2
	moveq	#RETURN_FAIL,Error
	bra.b	ErrorMsg

MemError	lea	(MemError.msg,pc),a2
	moveq	#RETURN_FAIL,Error
	bra.b	ErrorMsg

ReadError	lea	(ReadError.msg,pc),a2
	moveq	#RETURN_FAIL,Error

ErrorMsg	movea.l	(DosBase,a5),a6
	SYS	Output
	move.l	d0,d1	;FileHandle
	beq.b	Cleanup
	move.l	a2,d3
..	tst.b	(a2)+
	bne.s	..
	exg	a2,d3
	sub.l	a2,d3
	subq.l	#1,d3	;Length
	move.l	a2,d2	;Buffer
	SYS	Write

Cleanup	movea.l	(SysBase).w,a6
	move.l	(BufPtr,a5),d0
	beq.b	.CloseDos
	movea.l	d0,a1
	move.l	(BufSiz,a5),d0
	SYS	FreeMem

.CloseDos	move.l	(DosBase,a5),d0
	beq.b	.Exit
	movea.l	d0,a1
	SYS	CloseLibrary

.Exit	unlk	a5
	move.l	Error,d0
	rts

DosName	cstr	'dos.library'
BadArgs.msg	db	'Bad arguments:',10
Instruct.msg	db	'Usage:',10
	cstr	'1> PARtest <filespec>',10
OpenError.msg	cstr	'Couldn''t open file',10
SeekError.msg	cstr	'Seek error on file',10
MemError.msg	cstr	'Couldn''t allocate buffer',10
ReadError.msg	cstr	'Read error on file',10

	end
