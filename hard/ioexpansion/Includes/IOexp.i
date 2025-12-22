*****************************************************************************
* Program:  newser.i - ©1990 by The Puzzle Factory
* Function: The One & Only master include file for the I/O Expansion board.
*
* Author:   Jeff Lavin
* History:  08/23/90 JL V0.50 Created
*           11/25/90 JL V0.51 Started to add parallel stuff
*           12/10/90 JL V0.51 Added some more parallel stuff
*           01/13/91 JL V0.52 Changed PUTDEBUG macro slightly
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

;Set Tabs           |       |                 |       |

	ifeq	__M68
	fail	"Using the wrong assembler!"
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
	lea	(.msg\@,pc),a0	;Point to static format string
	lea	(4*4,sp),a1	;Point to args
	bsr	KPutFmt
	movem.l (sp)+,d0/d1/a0/a1
	addq.w	#4,sp
	bra.b	.end\@

.msg\@	cstr	'%s/',\2,10
	even
.end\@
	endc
	endm

ISDEBUG	macro
	ifne	INFO_LEVEL	;If any debugging enabled at all
KPutFmt	move.l	a2,-(sp)
	lea	(KPutChar,pc),a2
	bsr.b	KDoFmt
	movea.l	(sp)+,a2
	rts

KDoFmt	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	SYS	RawDoFmt
	movea.l	(sp)+,a6
	rts
KPutChar:
	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	SYS	RawPutChar
	movea.l	(sp)+,a6
	rts

subSysName	cstr	\1	;This name for debugging use
	even
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

	ifnd	SYS
SYS	macro
	jsr	(_LVO\1,a6)
	endm
	endc

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


MYIDENT	macro
	cstr	'newser alpha test version 1.0 (17 Aug 1990)',13,10
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

PARDEVNAME	macro
	cstr	'eightbit.device'
	even
	endm


PARIDENT	macro
	cstr	'eightbit alpha test version 1.0 (10 Dec 1990)',13,10
	even
	endm

PARUNITNAME1	macro
	cstr	'PAR1:'
	even
	endm

PARUNITNAME2	macro
	cstr	'PAR2:'
	even
	endm

PARUNITNAME3	macro
	cstr	'PAR3:'
	even
	endm

PARUNITNAME4	macro
	cstr	'PAR4:'
	even
	endm

*** EQUATES ***

	ifnd	SysBase
SysBase	equ	4
	endc

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
sp_Sizeof	soval

serprefs	clrso
prefs_CTLCHAR	so.l	1	;Control char's (order = xON,xOFF,rsvd,rsvd)
prefs_RBUFLEN	so.l	1	;Length in bytes of serial port's read buffer
prefs_EXTFLAGS	so.l	1	;Additional serial flags
prefs_BAUD	so.l	1	;Baud rate requested (true baud)
prefs_BRKTIME	so.l	1	;Duration of break signal in MICROseconds
prefs_TERMARRAY	so.b	TERMARRAY_SIZE	;Termination character array
prefs_READLEN	so.b	1	;Bits per read char (bit count)
prefs_WRITELEN	so.b	1	;Bits per write char (bit count)
prefs_STOPBITS	so.b	1	;Stopbits for read (count)
prefs_SERFLAGS	so.b	1	;See SERFLAGS bit definitions
serprefs_sizeof	soval

MyDev	setso	LIB_SIZE
md_Flags	so.b	1
md_Pad1	so.b	1
md_SysLib	so.l	1
md_SegList	so.l	1
md_Units	so.b	MD_NUMUNITS*4
prefs_unit0	so.b	serprefs_sizeof	;The reason why prefs are in this
prefs_unit1	so.b	serprefs_sizeof	;structure instead of the unit structure
prefs_unit2	so.b	serprefs_sizeof	;is that the pref settings should be saved
prefs_unit3	so.b	serprefs_sizeof	;across CloseDevice calls (which usually
MyDev_Sizeof	soval		;causes the unit to be dumped).

MyDevUnit	setso	UNIT_SIZE	;Odd # longwords
mdu_wport	so.b	MP_SIZE	;MsgPort for write task
MDU_FLAGS	so.b	1
IERstate	so.b	1	;Current state of IER used as a mask
mdu_UnitNum	so.b	1
frstate	so.b	1	;This var mirrors a write-only register
mdu_SysLib	so.l	1	;Copy of location 4
mdu_Device	so.l	1	;Ptr to main device struct
mdu_rstack	so.b	MYPROCSTACKSIZE	;For read task
mdu_wstack	so.b	MYPROCSTACKSIZE	;For write task
mdu_rtcb	so.b	TC_SIZE	;Task Control Block (TCB) for read task
mdu_wtcb	so.b	TC_SIZE	;Task Control Block (TCB) for write task
mdu_is	so.b	IS_SIZE	;Interrupt structure
timerport	so.b	MP_SIZE
timeriorequest	so.b	IOTV_SIZE
AltBuf	so.b	64	;64-byte alternate buffer
readsig	so.l	1	;Read task signals
readabortsig	so.l	1
tdresig	so.l	1	;Transmit buffer empty - put another byte
dsrsig	so.l	1	;Transition on DSR - used for handshaking (if enabled)
writeabortsig	so.l	1
xonsig	so.l	1	;Comes from read task, and indicates xon received
breaksig	so.l	1	;This is an Exec exception signal
head	so.l	1	;Ptr to start of circular buffer (logical)
tail	so.l	1	;Ptr to end of circular buffer (logical)
startbuf	so.l	1	;Ptr to physical start of input buffer
endbuf	so.l	1	;Ptr to physical end of input buffer
ReadRequestPtr	so.l	1
WriteRequestPtr	so.l	1
breakiorequest	so.l	1
xstate	so.b	1	;Zero if 'x-off' received, else $FF
ISRcopy	so.b	1	;Used for read error diagnosis
CSRcopy	so.b	1	;Used for read error diagnosis
Exclusive	so.b	1	;True if someone has exclusive access to this unit
daciabase	so.l	1
mdu_prefs	so.l	1	;Ptr to prefs for this unit (in MyDev)
MyDevUnit_Sizeof	soval

;Note that we have a single unit structure used by both the read and write
;tasks (and the interrupt routine).

* UNIT_FLAG definitions:

	BITDEF	UNIT,INREADTASK,0    
	BITDEF	UNIT,INWRITETASK,1
	BITDEF	UNIT,READACTIVE,2
	BITDEF	UNIT,WRITEACTIVE,3
	BITDEF	UNIT,BREAKACTIVE,4
	BITDEF	UNIT,INBREAK,5

;INBREAK is used by the queued break routine to protect against immediate breaks
;(a rather unlikely scenereo, but it might happen; who knows?)

* Bit definitions for MDU_FLAGS

	BITDEF	MDU,STOPPED,2	;State bit for unit stopped
	BITDEF	MDU,V,3	;Buffer overflow flag - set in int routine if an overflow occurs

* Bit definitions for ioflags

	BITDEF	ioflags,Active,4	;IO request in progress
	BITDEF	ioflags,Ignore,5	;Ignore this IO request

* Equates & bit defs for IERstate

READINT	equ	$87
READINTMASK	equ	$7

HANDINT	equ	$88
HANDINTMASK	equ	$8

WRITEINT	equ	$C0
WRITEINTMASK	equ	$40

WRITEOFF	equ	$40
WRITEOFFMASK	equ	$BF

*** The Hardware ***

_custom	equ	$DFF000
_intena	equ	_custom+intena

;The ACIAs are located at $400 byte boundaries beginning at ACIA_Base:
;
; Unit1	equ	$BF9000	;65C52 DACIA chip 1, unit 1
; Unit2	equ	$BF9400	;65C52 DACIA chip 1, unit 2
; Unit3	equ	$BF9800	;65C52 DACIA chip 2, unit 1
; Unit4	equ	$BF9C00	;65C52 DACIA chip 2, unit 2

ACIA_Base	equ	$BF9000	;Base address of all units
ACIA0	equ	$0000	;Offset of 1st chip
ACIA1	equ	$0800	;Offset of 2nd chip
UNIT2	equ	$0400	;Offset of 2nd unit

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

Baud_50	equ	%00000000	;Bits 3-0
Baud_110	equ	%00000001
Baud_134	equ	%00000010
Baud_150	equ	%00000011
Baud_300	equ	%00000100
Baud_600	equ	%00000101
Baud_1200	equ	%00000110
Baud_1800	equ	%00000111
Baud_2400	equ	%00001000
Baud_3600	equ	%00001001
Baud_4800	equ	%00001010
Baud_7200	equ	%00001011
Baud_9600	equ	%00001100
Baud_19200	equ	%00001101
Baud_38400	equ	%00001110
Baud_EXT	equ	%00001111

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

*****************************************************************************
*
* Here are the includes for the parallel portion of the I/O Expansion Board.
*
*****************************************************************************

VIA_Base	equ	$BF1000	;Base address of all units
VIA0	equ	$0000	;VIA #0 Base offset
VIA1	equ	$4000	;VIA #1 Base offset

ORB	equ	$0000	;I/O Register B
ORA	equ	$0100	;I/O Register A
DDRB	equ	$0200	;Data Direction Register B
DDRA	equ	$0300	;Data Direction Register A
T1CL	equ	$0400	;Timer #1 Counter (lower 8 bits)
T1CH	equ	$0500	;Timer #1 Counter (upper 8 bits)
T1LL	equ	$0600	;Timer #1 Latch (lower 8 bits)
T1LH	equ	$0700	;Timer #1 Latch (upper 8 bits)
T2CL	equ	$0800	;Timer #2 Counter (lower 8 bits)
T2CH	equ	$0900	;Timer #2 Counter (upper 8 bits)
SHFTR	equ	$0A00	;Shift Register
AUXCR	equ	$0B00	;Auxiliary Control Register
PERCR	equ	$0C00	;Peripheral Control Register
INTFR	equ	$0D00	;Interrupt Flag Register
INTER	equ	$0E00	;Interrupt Enable Register
ORAF	equ	$0F00	;I/O Register A (no handshake)

;End of File
