*****************************************************************************
* Time.asm - ©1990,91 by The Puzzle Factory
*          Real-Time Clock/Calendar driver.
*
*   Usage: 1> Time S=SET	;Sets clock from system date.
*          1> Time R=READ	;Sets system date from clock.
* History: 01/25/88 V0.50 Created by Jeff Lavin
*          11/25/90 V0.51 Converted to new syntax
*
* [To all: Please don't forget to bump the revision numbers if you do *any*
*          modifications at all.  -Jeff]
*
* Notes:
* There are several places in this program where small delays that are needed
* by the clock chip are created by the use of one or two 'NOP' instructions.
* These delays are calculated for a 7Mhz 68000 and may not work on a faster
* or different processor.  If you experience problems, try doubling the
* number of 'NOPs'.  I realize that this isn't good code, but I don't feel
* that the extra work is warranted in this particular case.  Feel free to add
* any improvements that you like.
*
* When setting the clock from system time, you would enter the date and time
* with the 'DATE' command, and then type 'Time SET'.  Be aware that when
* setting the clock, seconds are considered to be zero.  In order to get the
* most accurate time, set the clock just as system time passes the minute so
* that seconds really are zero.
*
*****************************************************************************

;Set Tabs	|	|	|	|

	exeobj
	objfile	'ram:Time'
	macfile 'Includes:IOexp.i'	;The One & Only include file

*  CLOCK / CALENDAR DRIVER PROGRAM
*  for OKI MSM5832 MICROPROCESSOR
*    Real-Time Clock / Calendar
*
* Copyright ©1990,91 The Puzzle Factory - All rights reserved
* This program may not be used commercially without prior
* written permission from the author.
*
* The clock/calendar is driven by a VIA.
* The port bit assignments are as follows:
*
*   PORT A bits	  PORT B bits
* 7 6 5 4 3 2 1 0	7 6 5 4 3 2 1 0
* ---------------------------------
* D D D D A A A A	      T|A|R|W|H
* 3 2 1 0 3 2 1 0	      E|D|E|R|O
*	      S|J|A|I|L
*	      T   D|T|D
*		    E
*
*              ________________________________________
*             |				 |
*  HOLD  _____|				 |_____
*                ____________________________________
*               |			       |
*  READ  _______|			       |_______
*        ________  _________  _________  _________  _________
*                \/ 	\/         \/	    \/
*  A0-A3 ________/\_________/\_________/\_________/\_________
*        __________  _________  _________  _________  _______
*  Data Out        \/	  \/         \/	      \/
*  D0-D3 __________/\_________/\_________/\_________/\_______
* 
*	     R E A D   C Y C L E
* 
*              ________________________________________
*             |				 |
*  HOLD  _____|				 |_____
*        ________  _________  _________  _________  _________
*                \/ 	\/         \/	    \/
*  A0-A3 ________/\_________/\_________/\_________/\_________
*        ________  _________  _________  _________  _________
*  Data In       \/ 	\/         \/	    \/
*  D0-D3 ________/\_________/\_________/\_________/\_________
*	 _____      _____      _____
*	/     \    /     \    /	  \
*  WRITE __________/       \__/       \__/	   \___________
* 
*	    W R I T E   C Y C L E
*
*
* The registers assignments are:
*
* REG: $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C
* --------------------------------------------------------
* CNT: 01S 10S 01M 10M 01H 10H DoW D01 D10 M01 M10 Y01 Y10
*
*       5   3   6	2   9	8   2   4   2   1   0   9   8
*
* This example would be:  09:26:35 TUESDAY JAN 24 1989
*
* Bit 7 of 10H is: 0 = 12 hr format, 1 = 24 hr format

dat_Format	equ	$0C	;Arp DateTime Structure
dat_Flags	equ	$0D
dat_StrDay	equ	$0E
dat_StrDate	equ	$12
dat_StrTime	equ	$16
dat_SIZEOF	equ	$1A

LEN_DATSTRING	equ	10
FORMAT_USA	equ	2
DTB_FUTURE	equ	2

SECONDS_PER_DAY	equ	1440
SECONDS_PER_MINUTE	equ	60

*** Begin Mainline

Time	movem.l	d0/a0,-(sp)
	lea	(ArpName,pc),a1	;Open arp.library
	moveq	#34,d0	;Version 34 or later
	movea.l	(SysBase).w,a6
	SYS	OpenLibrary
	tst.l	d0
	bne.b	OK_Go	;Got arp, run program
	lea	(DosName,pc),a1	;Else, open dos.library
	SYS	OpenLibrary
	tst.l	d0
	beq.b	1$
	movea.l	d0,a6
	SYS	Output	; and get output filehandle
	move.l	d0,d1
	beq.b	1$
	move.l	#alibmsg,d2
	moveq	#aliblng,d3
	SYS	Write	; so we can complain
1$	addq.w	#8,SP	; and exit.
	rts

DosName	cstr	'dos.library'
alibmsg	db	'you need '
ArpName	db	'arp.library',0,0
	db	' V34+',10
aliblng	equ	*-alibmsg

OK_Go	movea.l	d0,a6	;ArpBase
	lea	(DT),a4	;Setup BSS base register
	lea	(VIA_Base),a5	;Setup I/O base register
	movem.l	(sp)+,d0/a0
	lea	(Help.msg,pc),a1
	lea	(ArgArray-DT,a4),a2
	lea	(Template,pc),a3
	SYS	GADS
	cmpi.w	#1,d0	;Count of args, must = 1
	bne.b	1$	;Instruct & quit

	lea	(DateTime-DT,a4),a3
	move.b	#FORMAT_USA,(dat_Format,a3)
	bset	#DTB_FUTURE,(dat_Flags,a3)
	move.l	#DayStr,(dat_StrDay,a3)
	move.l	#DateStr,(dat_StrDate,a3)
	move.l	#TimeStr,(dat_StrTime,a3)

	tst.l	(Arg2-DT,a4)	;Is 'SET' argument on?
	bmi.b	SetTime	;Yes, set clock from SysTime
	tst.l	(Arg1-DT,a4)	;Is 'READ' argument on?
	bmi	ReadTime	;Yes, read clock to SysTime
1$	bra	ArgErr	;Must be R or S, instruct & quit

*** Set Hardware Clock from System Time

SetTime	move.l	a3,d1	;Ptr to DateTime structure
	SYS	DateStamp	;Get system time
	movea.l	a3,a0
	SYS	StamptoStr
	tst.l	d0
	bne	DateErr	;Couldn't read DateStamp, exit

	move.b	#$FF,(DDRB,a5)	;Set to all outputs
	move.b	#$FF,(DDRA,a5)	;Set to all outputs
	move.b	#1,(ORB,a5)	;Set HOLD high
	bsr	Wait	;150 usec HOLD setup time

	lea	(DateStr-DT,a4),a0 ;Date from StampToString
	lea	(Str_order,pc),a1	;Order of string bytes to read
	lea	(Reg_order,pc),a2	;Order of registers to write
	moveq	#0,d2	;Index
	moveq	#0,d3	;Index
SetLoop	move.b	(0,a1,d3.w),d2	;Which string byte to read
	move.b	(0,a0,d2.w),d0	;Get date/time data
	lsl.b	#4,d0	;Shift data to upper nibble
	move.b	(0,a2,d3.w),d1	;Which register to write
	or.b	d1,d0	;Combine register addr in lower nibble
	move.b	d0,(ORA,a5)	;Send the whole mess to the clock
	nop		;Data setup time
	nop
	move.b	#3,(ORB,a5)	;Raise WRITE line
	nop		;WRITE pulse width
	move.b	#1,(ORB,a5)	;Lower WRITE line

	addq.w	#1,d3
	cmpi.w	#12,d3
	bhs.b	1$
	cmpi.w	#6,d3	;If <> 6, do next whatever
	bne.b	SetLoop	;Else, we finished the date
	lea	(TimeStr-DT,a4),a0 ;So start on the time
	bset.b	#3,(0,a0)	;Mark 10 Hour for 24 hr mode
	bra.b	SetLoop

1$	lea	(Day_index,pc),a3	;Index into table
	lea	(Day_table,pc),a2	;Table of day strings
	moveq	#0,d2	;Loop Counter & Day of Week for clock
2$	lea	(DayStr-DT,a4),a0	;Ptr to Day of Week string (system)
	moveq	#0,d1
	move.b	(0,a3,d2.w),d1	;Offset to string
	lea	(0,a2,d1.w),a1	;Ptr to Day of Week string (table)
	SYS	Strcmp
	beq.b	3$
	addq.w	#1,d2
	cmpi.w	#7,d2
	blo.b	2$
	bra	DateErr	;Can't match system string

3$	lsl.b	#4,d2	;Shift data to upper nibble
	ori.b	#6,d2	;Combine register addr in lower nibble
	move.b	d2,(ORA,a5)	;Send the whole mess to the clock
	nop		;Data setup time
	nop
	move.b	#3,(ORB,a5)	;Raise WRITE line
	nop		;WRITE pulse width
	move.b	#1,(ORB,a5)	;Lower WRITE line
	nop		;DATA hold time
	move.b	#0,(ORB,a5)	;Reset HOLD low & Fall thru

*** Read Hardware Clock and Set System Time

ReadTime	move.b	#$FF,(DDRB,a5)	;Set to all outputs
	move.b	#$0F,(DDRA,a5)	;Hi-nibble=inputs, lo-nibble=outputs
	move.b	#1,(ORB,a5)	;Set HOLD high
	bsr	Wait	;150 usec HOLD setup time
	move.b	#5,(ORB,a5)	;Set for READ mode

	lea	(DateStr-DT,a4),a0 ;Date for StrDate
	lea	(TimeStr-DT,a4),a1 ;Time for StrTime
	move.b	#'-',(2,a0)	;Initialize separators
	move.b	#'-',(5,a0)
	move.b	#':',(2,a1)
	move.b	#':',(5,a1)

	lea	(Str_order,pc),a1	;Order of string bytes to write
	lea	(Reg_order,pc),a2	;Order of registers to read
	lea	(DataMask,pc),a3	;Mask for unwanted bits
	moveq	#0,d1	;Index
	moveq	#0,d2	;Index

ReadLoop	move.b	(0,a2,d2.w),(ORA,a5) ;Get next register
	nop		;READ access time
	moveq	#0,d0
	move.b	(ORA,a5),d0	;Get clock data
	lsr.b	#4,d0	;Shift into lower nibble
	and.b	(0,a3,d2.w),d0	;Mask off unwanted info
	addi.b	#$30,d0	;Make ASCII
	move.b	(0,a1,d2.w),d1	;Which string byte to write
	move.b	d0,(0,a0,d1.w)	;Put clock data in date/time string

	addq.w	#1,d2
	cmpi.w	#12,d2
	bhs.b	1$
	cmpi.w	#6,d2	;If <> 6, do next whatever
	bne.b	ReadLoop	;Else, we finished the date
	lea	(TimeStr-DT,a4),a0 ;So start on the time
	bra.b	ReadLoop

1$	move.b	#6,(ORA,a5)	;Day of Week register
	nop		;READ access time
	moveq	#0,d0
	move.b	(ORA,a5),d0	;Get clock data
	move.b	#0,(ORB,a5)	;Reset HOLD low
	lsr.b	#4,d0	;Shift into lower nibble
	andi.w	#%00000111,d0	;Mask off unwanted info

	lea	(DateTime-DT,a4),a3 ;Ptr to DateTime structure
	movea.l	(dat_StrDay,a3),a2
	lea	(Day_table,pc),a1	;Table of day strings
	lea	(Day_index,pc),a0	;Index into table
	moveq	#0,d1
	move.b	(0,a0,d0.w),d1	;Where string[D0] starts
2$	move.b	(0,a1,d1.w),(a2)+	;Move Day of Week string to target
	addq.l	#1,a1
	bne.b	2$

	tst.l	(Arg2-DT,a4)	;Is 'SET' argument on?
	bmi.b	3$	;Yes, don't set SysTime, just print

	movea.l	a3,a0
	SYS	StrtoStamp	;Convert clock strings
	bne	ConvErr	;Can't convert DateStamp

* Formula:  (((ds_Days * 1440) + ds_Minute) * 60) + (ds_Tick / 50)

	move.l	(ds_Days,a3),d0	;# of Days since 01/01/78
	mulu.w	#SECONDS_PER_DAY,d0
	add.l	(ds_Minute,a3),d0	;# of Minutes since midnight
	move.l	d0,d1
	mulu.w	#SECONDS_PER_MINUTE,d1 ;Lower 16 bits
	swap	d0
	mulu.w	#SECONDS_PER_MINUTE,d0 ;Upper 16 bits
	swap	d0
	add.l	d1,d0	;Add 'em
	move.l	(ds_Tick,a3),d1	;# of Seconds since midnight
	divu.w	#TICKS_PER_SECOND,d1
	ext.l	d1
	add.l	d1,d0	;# of seconds since 01/01/78
	bsr.b	SetSysTime
	lea	(Read.msg,pc),a0	;Print "System Time set to..."
	bra.b	4$

3$	lea	(Set.msg,pc),a0	;Print "Clock Time set to..."
4$	lea	(PArgs-DT,a4),a1
	movea.l	a1,a2
	lea	(dat_StrDay,a3),a3
	move.l	(a3)+,(a2)+	;Move ptrs to strings for Printf
	move.l	(a3)+,(a2)+
	move.l	(a3)+,(a2)+
	moveq	#RETURN_OK,d3
	moveq	#0,d2
	bra	Exit

*** Subroutines

Wait	moveq	#40,d1	;Approx. 150 usec
1$	subq.l	#1,d1
	bpl.b	1$	;So it's a cpu hog - how often do
	rts		; you read/set the clock, anyway?

SetSysTime	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	moveq	#0,d2
	move.l	d0,d3	;[D0] = # of seconds
	suba.w	#IOTV_SIZE,sp
	movea.l	a6,a0
	movea.l	(ThisTask,a0),a0
	lea	(pr_MsgPort,a0),a0
	move.l	a0,(MN_REPLYPORT,sp)
	lea	(TimerName,pc),a0
	move.l	#0,d0
	movea.l	sp,a1
	moveq	#0,d1
	SYS	OpenDevice
	tst.l	d0
	bne.b	1$
	move.w	#TR_SETSYSTIME,(IO_COMMAND,sp)
	clr.l	(IOTV_TIME+TV_MICRO,sp)
	move.l	d3,(IOTV_TIME+TV_SECS,sp)
	movea.l	sp,a1
	SYS	DoIO
	movea.l	sp,a1
	SYS	CloseDevice
1$	adda.w	#IOTV_SIZE,sp
	movea.l	(sp)+,a6
	rts

TimerName	cstr	'timer.device'
	even

ArgErr	lea	(Help.msg,pc),a0	;Print instructions
	moveq	#RETURN_WARN,d3
	moveq	#ERROR_LINE_TOO_LONG,d2
	bra.b	Quit

MemErr	lea	(NoMem.msg,pc),a0	;Print "No memory"
	moveq	#RETURN_FAIL,d3
	moveq	#ERROR_NO_FREE_STORE,d2
	bra.b	Quit

ConvErr	lea	(Stamp1.msg,pc),a0 ;Print "Can't convert to DateStamp"
	bra.b	Err.1

DateErr	lea	(Stamp2.msg,pc),a0 ;Print "Can't read system time"
Err.1	moveq	#RETURN_FAIL,d3
	move.l	#200,d2	;Internal error

Quit	lea	(NULLBYT,pc),a1	;Null arg
Exit	SYS	Printf	;Write message
	move.l	d3,d0	;D0 = ReturnCode, D2 = Fault
	SYS	ArpExit

Help.msg	db	'Time V1.0 - ©1990,91 by The Puzzle Factory',10
	db	'Time S/SET  sets clock from system date.',10
	db	'Time R/READ sets system date from clock.',10
NULLBYT	db	0

Template	cstr	'R=READ/S,S=SET/S'

NoMem.msg	cstr	'Can''t allocate memory.',10
Stamp1.msg	cstr	'Can''t convert to DateStamp.',10
Stamp2.msg	cstr	'Can''t read system time.',10

Set.msg	cstr	'Clock Time set to: %s %s %s',10
Read.msg	cstr	'System Time set to: %s %s %s',10

;		M10 M01 D10 D01 Y10 Y01 10H 01H 10M 01M 10S 01S
Reg_order	db	$0A,$09,$08,$07,$0C,$0B,$05,$04,$03,$02,$01,$00
DataMask	db	$01,$0F,$03,$0F,$0F,$0F,$03,$0F,$07,$0F,$07,$0F 
Str_order	db	$00,$01,$03,$04,$06,$07,$00,$01,$03,$04,$06,$07

Day_index	db	Day0-Day0,Day1-Day0,Day2-Day0,Day3-Day0
	db	Day4-Day0,Day5-Day0,Day6-Day0
Day_table
Day0	cstr	'Sunday'
Day1	cstr	'Monday'
Day2	cstr	'Tuesday'
Day3	cstr	'Wednesday'
Day4	cstr	'Thursday'
Day5	cstr	'Friday'
Day6	cstr	'Saturday'

DT
ArgArray
Arg1	dx.l	1
Arg2	dx.l	1

PArgs	dx.l	3

DateTime	dx.b	dat_SIZEOF
DayStr	dx.b	LEN_DATSTRING
DateStr	dx.b	LEN_DATSTRING
TimeStr	dx.b	LEN_DATSTRING

	end
