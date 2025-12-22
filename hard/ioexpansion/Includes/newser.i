*****************************************************************************
* Program:  newser.i - ©1990 by The Puzzle Factory
* Function: The One & Only master include file for the I/O Expansion board.
*
* Author:   Jeff Lavin
* History:  08/23/90 V0.50 Created
*
* [To all: Please don't forget to bump the revision numbers if you do *any*
*          modifications at all.  -Jeff]
*
*****************************************************************************
*
* Some of the following is:
*
*****************************************************************************
*
* Copyright (C) 1985, Commodore Amiga Inc.  All rights reserved.
* Permission granted for non-commercial use
*
* asmsupp.i -- random low level assembly support routines
*              used by the Commodore sample Library & Device
*
*****************************************************************************

;Set Tabs           |       |                 |

	ifeq	__M68
	fail	"Using the wrong assembler"
	endc


;Put a message to the serial port at 9600 baud.  Used as so:
;
;    PUTDEBUG   30,<'%s/Init: called'>
;
;Parameters can be printed out by pushing them on the stack and
;adding the appropriate C printf-style % formatting commands.

PUTDEBUG 	macro		;[level,msg]
	ifge	INFO_LEVEL-\1
	pea	(subSysName,pc)
	movem.l a0/a1/d0/d1,-(sp)
	lea	(msg\@,pc),a0	;Point to static format string
	lea	(4*4,sp),a1	;Point to args
	bsr	KPutFmt
	movem.l (sp)+,d0/d1/a0/a1
	addq.l	#4,sp
	bra.b	end\@

msg\@	cstr	\2,10
	even
end\@
	endc
	endm

*****************************************************************************
*
* Here are the includes for the serial portion of the I/O Expansion Board.
* Everything from here to the end of the file is:
*
*      Copyright (C) 1990 by Jeff Lavin  --  All rights reserved.
*      Permission granted for non-commercial use.
*
*****************************************************************************

*** MACROS ***

;SYS	macro
;	jsr	(_LVO\1,a6)
;	endm

EXEC	macro
	move.l	a1,-(sp)
	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	jsr	(_LVO\1,a6)
	movea.l	(sp)+,a6
	movea.l	(sp)+,a1
	endm

Disable	macro
	ifc	'\1',''
	move.w	#INTF_INTEN,(_intena).l
	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	addq.b	#1,(IDNestCnt,a6)
	movea.l	(sp)+,a6
	endc
	ifnc	'\1',''
	movea.l	(SysBase).w,\1
	move.w	#INTF_INTEN,(_intena).l
	addq.b	#1,(IDNestCnt,\1)
	endc
	endm

Enable	macro
	ifc	'\1',''
	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	subq.b	#1,(IDNestCnt,a6)
	movea.l	(sp)+,a6
	bge.s	.Enable\#
	move.w	#INTF_SETCLR!INTF_INTEN,(_intena).l
.Enable\#
	endc
	ifnc	'\1',''
	movea.l	(SysBase).w,\1
	subq.b	#1,(IDNestCnt,\1)
	bge.s	.Enable\#
	move.w	#INTF_SETCLR!INTF_INTEN,(_intena).l
.Enable\#
	endc
	endm

Forbid	macro
	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	addq.b	#1,(TDNestCnt,a6)
	movea.l	(sp)+,a6
	endm

Permit	macro
	movem.l	d0/d1/a0/a1/a6,-(sp)
	movea.l	(SysBase).w,a6
	SYS	Permit
	movem.l	(sp)+,d0/d1/a0/a1/a6
	endm

PREFFILE	macro
	cstr	'S:Serial-Preferences'
	even
	endm

MYDEVNAME	macro
	cstr	'newser.device'
	even
	endm

MYUNITNAME1         macro
	cstr	'SER1:'
	even
	endm

MYUNITNAME2         macro
	cstr	'SER2:'
	even
	endm

MYUNITNAME3         macro
	cstr	'SER3:'
	even
	endm

MYUNITNAME4         macro
	cstr	'SER4:'
	even
	endm

*** EQUATES ***

MYPROCSTACKSIZE	equ	$900	;Stack size for the task we will create

MYPRI	equ	0	;Used for configuring the roms

VERSION	equ	1	;A major version number.

REVISION	equ	0	;A particular revision

MYDEV_END	equ	CMD_NONSTD+2	;Number of device comands 

MD_NUMUNITS	equ	4	;Maximum number of units in this device

*** New SerialPrefs Structure ***

UnitPrefs	clrso
up_BufSize	so.w	1	;0 to 7
up_BaudRate	so.w	1	;0 to 15
up_WordLen	so.b	1	;0=5, 1=6, 2=7, 3=8
up_StopBits	so.b	1	;0=1, 1=2
up_Parity	so.b	1	;0=Odd, 1=Even, 2=Mark, 3=Space, 4=None
up_Shake	so.b	1	;0=RTS/CTS, 1=xON/xOFF
up_Sizeof	soval

SerialPrefs	clrso
sp_Unit01	so.b	up_Sizeof	;For ACIA 0, Unit 1
sp_Unit02	so.b	up_Sizeof	;For ACIA 0, Unit 2
sp_Unit11	so.b	up_Sizeof	;For ACIA 1, Unit 1
sp_Unit12	so.b	up_Sizeof	;For ACIA 1, Unit 2
serialprefs_Sizeof	soval


*** The Hardware ***

;The ACIAs are located at $400 byte boundaries beginning at ACIA_Base:
;
; Unit1	equ	$BF9000	;65C52 DACIA chip 1, unit 1
; Unit2	equ	$BF9400	;65C52 DACIA chip 1, unit 2
; Unit3	equ	$BF9800	;65C52 DACIA chip 2, unit 1
; Unit4	equ	$BF9C00	;65C52 DACIA chip 2, unit 2

ACIA_Base	equ	$BF9000	;Base address of all units
ACIA1	equ	$800	;Offset of 2nd chip
UNIT2	equ	$400	;Offset of 2nd unit

IER	equ	$0000	;Interrupt Enable Register
ISR	equ	$0000	;Interrupt Status Register
CTR	equ	$0100	;Control Register
FMR	equ	$0100	;Format Register
CSR	equ	$0100	;Control Status Register
CDR	equ	$0200	;Compare Data Register
ACR	equ	$0200	;Auxilliary Control Register
TDR	equ	$0300	;Transmit Data Register
RDR	equ	$0300	;Receive Data Register

* Interrupt Status Registers (ISR1=0, ISR2=4) Read only

	BITDEF	ISR,SETCLR,7	;Any bit set
	BITDEF	ISR,TDRE,6	;Transmit Data Register Empty
	BITDEF	ISR,CTST,5	;Transition on *CTS Line
	BITDEF	ISR,DCDT,4	;Transition on *DCD Line
	BITDEF	ISR,DSRT,3	;Transition on *DSR Line
	BITDEF	ISR,PAR,2	;Parity status
	BITDEF	ISR,FEOB,1	;Frame error, Overrun, Break
	BITDEF	ISR,RDRF,0	;Receive Data Register Full

* Interrupt Enable Registers (IER1=0, IER2=4) Write only

	BITDEF	IER,SETCLR,7	;Same as above
	BITDEF	IER,TDRE,6
	BITDEF	IER,CTST,5
	BITDEF	IER,DCDT,4
	BITDEF	IER,DSRT,3
	BITDEF	IER,PAR,2
	BITDEF	IER,FEOB,1
	BITDEF	IER,RDRF,0

* Control Status Registers (CSR1=1, CSR2=5) Read only

	BITDEF	CSR,FE,7	;Framing Error
	BITDEF	CSR,TUR,6	;Transmitter Underrun
	BITDEF	CSR,CTSL,5	;*CTS Level
	BITDEF	CSR,DCDL,4	;*DCD Level
	BITDEF	CSR,DSRL,3	;*DSR Level
	BITDEF	CSR,RBRK,2	;Receive Break
	BITDEF	CSR,DTRL,1	;*DTR Level
	BITDEF	CSR,RTSL,0	;*RTS Level

* Control Registers (CR1=1, CR2=5) Write only

	BITDEF	CR,CTRL,7	;1=Access FMR,  0=Access CTR
	BITDEF	CR,AUX,6	;1=Access ACR,  0=Access CDR
	BITDEF	CR,STOP2,5	;1=2 stop bits, 0=1 stop bit
	BITDEF	CR,ECHO,4	;1=Echo mode,   0=Echo mode disabled

* Format Registers (FR1=1, FR2=5) Write only

	BITDEF	FR,FRMT,7	;1=Access FR, 0=Access CR

WORDLEN_5	equ	%00000000	;Bits 5-6
WORDLEN_6	equ	%00100000
WORDLEN_7	equ	%01000000
WORDLEN_8	equ	%01100000

PAR_ODD	equ	%00000000	;Bits 3-4
PAR_EVEN	equ	%00001000
PAR_MARK	equ	%00010000
PAR_SPACE	equ	%00011000

	BITDEF	FR,PAR,2	;1=Parity as specified in bits 3-4
	BITDEF	FR,DTR,1	;1=Set DTR hi, 0=Set DTR lo
	BITDEF	FR,RTS,0	;1=Set RTS hi, 0=Set RTS lo

* Compare Data Register  (CDR1=2, CDR2=6) Write only

;Bit 6 of Control Register must be 0.  By writing a value into this
;register, the DACIA is put into the compare mode.  In this mode the Receive
;Data Register Full bit is inhibited until a character is received that
;matches the value in this register.  The next character is then received
;normally.

* Auxiliary Control Registers (ACR1=2, ACR2=6) Write only

;Bit 6 of Control Register must be 1.

	BITDEF	ACR,BRK,1	;Transmit break
	BITDEF	ACR,ARM,0	;Address recognition mode

;End of File
