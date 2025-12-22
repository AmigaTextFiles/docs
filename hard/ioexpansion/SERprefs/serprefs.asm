*****************************************************************************
*
*  Program:  Prefs.asm ©1990,91 by The Puzzle Factory
* Function:  Select serial preferences for ACIA's on I/O Expansion Board.
*
*   Author: Jeff Lavin
*  History: 08/21/89  V0.50 Created
*           09/10/90  V0.51 Updated code for M68
*                           Added another handshake gadget
*           03/03/91  V1.0  Fixed initialization bug & made it useful
*
* [To all: Please don't forget to bump the revision numbers if you do *any*
*          modifications at all.  -Jeff]
*
*****************************************************************************

;Set Tabs           |       |                 |

	exeobj
	objfile	'c:SerPrefs'
	macfile	'NewSER.i'

*** Macros

sett	macro		;Set Text coords
	dw	\1,\2	;LeftEdge, BaseLine
	dl	\3	;TextPtr
	endm

;*** Equates

TRUE	equ	1
FALSE	equ	0

;*** Begin Mainline

	lea	(DT),a5	;BSS relative base
	lea	(BSS_Start-DT,a5),a0
	move.w	#BSS_Len-1,d1
1$	clr.b	(a0)+	;Clear BSS area
	dbra	d1,1$

	lea	(DosName,pc),a1	;Open dos.library
	moveq	#33,d0	;V1.2 or later
	movea.l	(SysBase),a6
	SYS	OpenLibrary
	move.l	d0,(Dos_Base-DT,a5)
	beq.b	2$

	movea.l	d0,a6
	SYS	Output
	move.l	d0,(stdout-DT,a5)

	lea	(IntName,pc),a1	;Open intuition.library
	moveq	#33,d0	;V1.2 or later
	movea.l	(SysBase),a6
	SYS	OpenLibrary
	move.l	d0,(Int_Base-DT,a5)
2$	beq.b	Cleanup

	lea	(GfxName,pc),a1	;Open graphics.library
	moveq	#33,d0	;V1.2 or later
	SYS	OpenLibrary
	move.l	d0,(Gfx_Base-DT,a5)
	beq.b	Cleanup

	movea.l	(ThisTask,a6),a3	;Our process base
	tst.l	(pr_CLI,a3)	;From the CLI?
	bne.b	FromCLI

FromWBench:
	lea	(pr_MsgPort,a3),a0
	SYS	WaitPort	;Get a msg from WBench
	lea	(pr_MsgPort,a3),a0
	SYS	GetMsg
	move.l	d0,(WBenchMsg-DT,a5) ; and save for later return.

FromCLI	movea.l	(Int_Base-DT,a5),a6
	lea	(MyScreen-DT,a5),a0
	SYS	OpenScreen
	move.l	d0,(ScreenPtr-DT,a5) ;Save ptr to my picture screen
	beq.b	Cleanup	;Error while opening

	lea	(MyWindow-DT,a5),a0
	move.l	d0,(nw_Screen,a0)	;Point NewWindow to this screen
	SYS	OpenWindow
	move.l	d0,(WindowPtr-DT,a5) ;Save window pointer
	beq.b	Cleanup	;Error while opening

	movea.l	d0,a0
	move.l	(wd_UserPort,a0),(PortPtr-DT,a5)
	move.l	(wd_RPort,a0),(RastPtr-DT,a5)
	move.l	a0,(pr_WindowPtr,a3) ;Make requesters appear here

;	rts

	bsr	SetupScreen	;Create display

;	rts

	bsr.b	MainLoop	;When finished, we'll fall thru

************************************************
*             Termination section              *
************************************************

* It's time to quit, close everything and say good-night, Gracie.

Cleanup:
	movea.l	(Int_Base-DT,a5),a6
	move.l	(WindowPtr-DT,a5),d0 ;Close Window
	beq.b	1$
	movea.l	(SysBase),a3
	movea.l	(ThisTask,a3),a1
	clr.l	(pr_WindowPtr,a1)
	movea.l	d0,a0
	SYS	CloseWindow

1$	move.l	(ScreenPtr-DT,a5),d0 ;Close Screen
	beq.b	2$
	movea.l	d0,a0
	SYS	CloseScreen

2$	movea.l	a3,a6
	move.l	(WBenchMsg-DT,a5),d2
	beq.b	3$
	SYS	Forbid	;So WBench won't UnLoadSeg us
	movea.l	d2,a1
	SYS	ReplyMsg	;Return msg to WBench

3$:
	move.l	(Dos_Base-DT,a5),a1
	move.l	a1,d0
	beq.b	.SkipDos
	SYS	CloseLibrary
.SkipDos:
	move.l	(Int_Base-DT,a5),a1
	move.l	a1,d0
	beq.b	.SkipInt
	SYS	CloseLibrary
.SkipInt:
	move.l	(Gfx_Base-DT,a5),a1
	move.l	a1,d0
	beq.b	.SkipGfx
	SYS	CloseLibrary
.SkipGfx:

	moveq	#0,d0
	rts

************************************************
*              Main Execution Loop             *
************************************************

* Wait for a msg, execute appropriate routine.

MainLoop:
	tst.b	(CloseFlag-DT,a5)	;Flag set?
	beq.b	1$
	rts		;Exit

1$	movea.l	(PortPtr-DT,a5),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	(MP_SIGBIT,a0),d1
	bset	d1,d0
	movea.l	(SysBase),a6
	SYS	Wait	;Now wait for a message

GetIMsg	movea.l	(PortPtr-DT,a5),a0
	movea.l	(SysBase),a6
	SYS	GetMsg	;Did we get one?
	tst.l	d0
	beq.b	MainLoop	;No
	movea.l	d0,a1
	move.l	(im_Class,a1),d2	;Yes, get info
	movea.l	(im_IAddress,a1),a2
	SYS	ReplyMsg	;Return msg

CheckGads	cmpi.w	#GADGETDOWN,d2	;Someone clicked on a gadget
	beq.b	1$
	cmpi.w	#GADGETUP,d2	;May be either type
	bne.b	2$
1$	lea	(FirstGadget-DT,a5),a1 ;Save some code for ME
	move.w	(gg_GadgetID,a2),d1
	movea.l	(gg_UserData,a2),a0 ;Get action address
	jsr	(a0)
2$	bra.b	GetIMsg	;Unknown class

BufUP01	move.w	(_BufSize01-DT,a5),d0
	addq.w	#1,d0
	bra.b	CkBuf01

BufDN01	move.w	(_BufSize01-DT,a5),d0
	subq.w	#1,d0
CkBuf01	cmpi.w	#GADGETDOWN,d2	;Ignore GADGETUP msgs, we just
	beq.b	DoBuf01	; need them for GADGHCOMP.
	rts

DoBuf01	andi.w	#%00000111,d0	;Modulo 8
	move.w	d0,(_BufSize01-DT,a5) ;Save new value
	moveq	#26,d1	;BaseLine for Text
	bra	BufStrings	;Clear old text & write new

BaudUP01	move.w	(_BaudRate01-DT,a5),d0
	addq.w	#1,d0
	bra.b	CkBaud01

BaudDN01	move.w	(_BaudRate01-DT,a5),d0
	subq.w	#1,d0
CkBaud01	cmpi.w	#GADGETDOWN,d2	;Ignore GADGETUP msgs
	beq.b	DoBaud01
	rts

DoBaud01	andi.w	#%00001111,d0	;Modulo 16
	move.w	d0,(_BaudRate01-DT,a5)
	moveq	#41,d1	;BaseLine for Text
	bra	BaudStrings

WordLen01	subq.w	#4,d1		 ;ID(thisGad)-ID(1stGad) =
	move.b	d1,(_WordLen01-DT,a5)	 ; SerialPref value.
	lea	(WordLen01.0_gad-DT,a5),a0 ;1st gadget in this group
	moveq	#4,d0		 ;# of gadgets in this group
	bsr	MutualExclude		 ;Hilite this gadget
	rts

StopBit01	subq.w	#8,d1
	move.b	d1,(_StopBits01-DT,a5)
	lea	(StopBit01.0_gad-DT,a5),a0
	moveq	#2,d0
	bsr	MutualExclude
	rts

Parity01	subi.w	#10,d1
	move.b	d1,(_Parity01-DT,a5)
	lea	(Parity01.0_gad-DT,a5),a0
	moveq	#5,d0
	bsr	MutualExclude
	rts

Shake01	subi.w	#15,d1
	move.b	d1,(_Shake01-DT,a5)
	lea	(Shake01.0_gad-DT,a5),a0
	moveq	#3,d0
	bsr	MutualExclude
	rts

BufUP02	move.w	(_BufSize02-DT,a5),d0
	addq.w	#1,d0
	bra.b	CkBuf02

BufDN02	move.w	(_BufSize02-DT,a5),d0
	subq.w	#1,d0
CkBuf02	cmpi.w	#GADGETDOWN,d2	;Ignore GADGETUP msgs
	beq.b	DoBuf02
	rts

DoBuf02	andi.w	#%00000111,d0	;Modulo 8
	move.w	d0,(_BufSize02-DT,a5)
	moveq	#66,d1	;BaseLine for Text
	bra	BufStrings

BaudUP02	move.w	(_BaudRate02-DT,a5),d0
	addq.w	#1,d0
	bra.b	CkBaud02

BaudDN02	move.w	(_BaudRate02-DT,a5),d0
	subq.w	#1,d0
CkBaud02	cmpi.w	#GADGETDOWN,d2	;Ignore GADGETUP msgs
	beq.b	DoBaud02
	rts

DoBaud02	andi.w	#%00001111,d0	;Modulo 16
	move.w	d0,(_BaudRate02-DT,a5)
	moveq	#81,d1	;BaseLine for Text
	bra	BaudStrings

WordLen02	subi.w	#20+4,d1
	move.b	d1,(_WordLen02-DT,a5)
	lea	(WordLen02.0_gad-DT,a5),a0
	moveq	#4,d0
	bsr	MutualExclude
	rts

StopBit02	subi.w	#20+8,d1
	move.b	d1,(_StopBits02-DT,a5)
	lea	(StopBit02.0_gad-DT,a5),a0
	moveq	#2,d0
	bsr	MutualExclude
	rts

Parity02	subi.w	#20+10,d1
	move.b	d1,(_Parity02-DT,a5)
	lea	(Parity02.0_gad-DT,a5),a0
	moveq	#5,d0
	bsr	MutualExclude
	rts

Shake02	subi.w	#20+15,d1
	move.b	d1,(_Shake02-DT,a5)
	lea	(Shake02.0_gad-DT,a5),a0
	moveq	#3,d0
	bsr	MutualExclude
	rts

BufUP11	move.w	(_BufSize11-DT,a5),d0
	addq.w	#1,d0
	bra.b	CkBuf11

BufDN11	move.w	(_BufSize11-DT,a5),d0
	subq.w	#1,d0
CkBuf11	cmpi.w	#GADGETDOWN,d2	;Ignore GADGETUP msgs
	beq.b	DoBuf11
	rts

DoBuf11	andi.w	#%00000111,d0	;Modulo 8
	move.w	d0,(_BufSize11-DT,a5)
	moveq	#106,d1	;BaseLine for Text
	bra	BufStrings

BaudUP11	move.w	(_BaudRate11-DT,a5),d0
	addq.w	#1,d0
	bra.b	CkBaud11

BaudDN11	move.w	(_BaudRate11-DT,a5),d0
	subq.w	#1,d0
CkBaud11	cmpi.w	#GADGETDOWN,d2	;Ignore GADGETUP msgs
	beq.b	DoBaud11
	rts

DoBaud11	andi.w	#%00001111,d0	;Modulo 16
	move.w	d0,(_BaudRate11-DT,a5)
	moveq	#121,d1	;BaseLine for Text
	bra	BaudStrings

WordLen11	subi.w	#40+4,d1
	move.b	d1,(_WordLen11-DT,a5)
	lea	(WordLen11.0_gad-DT,a5),a0
	moveq	#4,d0
	bsr	MutualExclude
	rts

StopBit11	subi.w	#40+8,d1
	move.b	d1,(_StopBits11-DT,a5)
	lea	(StopBit11.0_gad-DT,a5),a0
	moveq	#2,d0
	bsr	MutualExclude
	rts

Parity11	subi.w	#40+10,d1
	move.b	d1,(_Parity11-DT,a5)
	lea	(Parity11.0_gad-DT,a5),a0
	moveq	#5,d0
	bsr	MutualExclude
	rts

Shake11	subi.w	#40+15,d1
	move.b	d1,(_Shake11-DT,a5)
	lea	(Shake11.0_gad-DT,a5),a0
	moveq	#3,d0
	bsr	MutualExclude
	rts

BufUP12	move.w	(_BufSize12-DT,a5),d0
	addq.w	#1,d0
	bra.b	CkBuf12

BufDN12	move.w	(_BufSize12-DT,a5),d0
	subq.w	#1,d0
CkBuf12	cmpi.w	#GADGETDOWN,d2	;Ignore GADGETUP msgs
	beq.b	DoBuf12
	rts

DoBuf12	andi.w	#%00000111,d0	;Modulo 8
	move.w	d0,(_BufSize12-DT,a5)
	move.w	#146,d1	;BaseLine for Text

BufStrings	bsr	Clear	;Clear old text from area
	lea	(BufTxt.tbl,pc),a0
	bra.b	String_In

BaudUP12	move.w	(_BaudRate12-DT,a5),d0
	addq.w	#1,d0
	bra.b	CkBaud12

BaudDN12	move.w	(_BaudRate12-DT,a5),d0
	subq.w	#1,d0
CkBaud12	cmpi.w	#GADGETDOWN,d2	;Ignore GADGETUP msgs
	beq.b	DoBaud12
	rts

DoBaud12	andi.w	#%00001111,d0	;Modulo 16
	move.w	d0,(_BaudRate12-DT,a5)
	move.w	#161,d1	;BaseLine for Text

BaudStrings	bsr	Clear	;Clear old text from area
	lea	(BaudTxt.tbl,pc),a0
String_In	lsl.w	#2,d0	;LONG index
	movea.l	(0,a0,d0.w),a0	;Get new text based on index
	bsr	strlen
	lsl.w	#2,d0	;PixelLen=(strlen*charwidth)/2
	moveq	#111,d2	;Center of text space
	sub.w	d0,d2	;LeftEdge=Xcoord-(PixelLen/2)
	move.w	d2,d0
	bsr	Text	;Go write it
	rts

WordLen12	subi.w	#60+4,d1
	move.b	d1,(_WordLen12-DT,a5)
	lea	(WordLen12.0_gad-DT,a5),a0
	moveq	#4,d0
	bsr	MutualExclude
	rts

StopBit12	subi.w	#60+8,d1
	move.b	d1,(_StopBits12-DT,a5)
	lea	(StopBit12.0_gad-DT,a5),a0
	moveq	#2,d0
	bsr	MutualExclude
	rts

Parity12	subi.w	#60+10,d1
	move.b	d1,(_Parity12-DT,a5)
	lea	(Parity12.0_gad-DT,a5),a0
	moveq	#5,d0
	bsr	MutualExclude
	rts

Shake12	subi.w	#60+15,d1
	move.b	d1,(_Shake12-DT,a5)
	lea	(Shake12.0_gad-DT,a5),a0
	moveq	#3,d0
	bsr	MutualExclude
	rts

SaveGad:
	bsr	MakePointer
	bsr	PutFile	;Save file & fall thru
	bsr	RemPointer

;********************************************************
;Ok, now send the prefs to the driver, one way or another
;********************************************************

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

UseGad:

	Forbid
	lea	(MySerPrefs-DT,a5),a2
	move.l	(4).w,a6
	lea	(MagicPortName,pc),a1
	SYS	FindPort
	move.l	d0,a4
	tst.l	d0
	bne.b	.PortFound

;Create a prefs port
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	move.l	#MP_SIZE+32+PortNameLength,d0
	SYS	AllocMem
	tst.l	d0
	beq	PrefsError
	move.l	d0,a4

;Copy name string
	lea	(MP_SIZE+32,a4),a3
	move.l	a3,a0
	lea	(MagicPortName,pc),a1
	move.w	#PortNameLength-1,d0
..	move.b	(a1)+,(a0)+
	dbra	d0,..

	move.l	a3,(LN_NAME,a4)
	move.l	a4,a1
	move.l	(4).w,a6
	SYS	AddPort

.PortFound:
	lea	(MP_SIZE,a4),a3
	moveq	#32/4-1,d0
..	move.l	(a2)+,(a3)+
	dbra	d0,..

	Permit

;Ok, memory has been updated....now update the driver internally,
;if it happens to be resident.

	lea	($015E,A6),A0	;device list
	lea	(NewSerName,pc),a1
	SYS	FindName
	tst.l	d0
	beq	.NotResident

;First, set up some structures for IO

	lea	(myunit,pc),a2
	lea	(replyport,pc),a3
	move.l	a3,(MN_REPLYPORT,a2)

;Initialize the ReplyPort

	sub.l	a1,a1
	SYS	FindTask
	move.l	d0,(MP_SIGTASK,a3)
	moveq	#-1,d0
	SYS	AllocSignal
	move.b	d0,(MP_SIGBIT,a3)
	move.b	#NT_MSGPORT,(LN_TYPE,a3)
	lea	(MP_MSGLIST,a3),a0
	NEWLIST	a0

	lea	(MySerPrefs-DT,a5),a4
	moveq	#0,d7	;unit number
.MainLoop:
	move.l	a2,a1
	moveq	#0,d1
	move.l	d7,d0
	lea	(NewSerName,pc),a0
	SYS	OpenDevice
	tst.l	d0
	bne	.OpenError

;Preset prefs (the prefs-building routine, unfortuntely, depends on this.)

	lea	(IO_CTLCHAR,a2),a1
	move.w	#serprefs_sizeof-1,d0
	lea	(Preset,pc),a0
..	move.b	(a0)+,(a1)+
	dbra	d0,..

;Build the prefs structure
	move.l	a4,a1
	moveq	#0,d0
	move.w	#512,d0
	moveq	#0,d1
	move.w	(up_BufSize,a1),d1 ;0-7
	lsl.l	d1,d0
	move.l	d0,(IO_RBUFLEN,a2)

	lea	(baudtable,pc),a0
	move.w	(up_BaudRate,a1),d0 ;0-15
	add.w	d0,d0
	moveq	#0,d1
	move.w	(a0,d0.w),d1
	move.l	d1,(IO_BAUD,a2)

	moveq	#5,d1	;5 bit word
	move.b	(up_WordLen,a1),d0
	beq.b	.WordLen	;up_WordLen=0
	addq.b	#1,d1	;6 bit word
	subq.b	#1,d0
	beq.b	.WordLen	;up_WordLen=1
	addq.b	#1,d1	;7 bit word
	subq.b	#1,d0
	beq.b	.WordLen	;up_WordLen=2
	addq.b	#1,d1	;8 bit word
.WordLen:
	move.b	d1,(IO_READLEN,a2)
	move.b	d1,(IO_WRITELEN,a2)

	move.b	(up_StopBits,a1),d0 ;0-1
	addq.b	#1,d0
	move.b	d0,(IO_STOPBITS,a2)

	move.b	(up_Parity,a1),d0
	cmp.b	#4,d0	;none?
	beq.b	.SkipParity
	bset	#SERB_PARTY_ON,(IO_SERFLAGS,a2)
	cmp.b	#2,d0
	bcc.b	.MarkSpace
	bclr	#SERB_PARTY_ODD,(IO_SERFLAGS,a2)	;set to even
	tst.b	d0
	bne.b	.SkipParity
	bset	#SERB_PARTY_ODD,(IO_SERFLAGS,a2)	;set to odd
	bra.b	.SkipParity
.MarkSpace:
	bset	#SEXTB_MSPON,(3+IO_EXTFLAGS,a2)
	bclr	#SEXTB_MARK,(3+IO_EXTFLAGS,a2)	;set to space
	cmp.b	#3,d0
	beq.b	.SkipParity
	bset	#SEXTB_MARK,(3+IO_EXTFLAGS,a2)

.SkipParity:
	move.b	(up_Shake,a1),d0
	cmp.b	#2,d0
	beq.b	.SkipShake
	cmp.b	#1,d0
	bne.b	.SkipXon
	bclr	#SERB_XDISABLED,(IO_SERFLAGS,a2)
	bra.b	.SkipShake
.SkipXon:
	bset	#SERB_7WIRE,(IO_SERFLAGS,a2)
.SkipShake:

;Now send an SDCMD_SETPARAMS command to the device...

	move.l	a2,a1
	move.w	#SDCMD_SETPARAMS,(IO_COMMAND,a1)
	SYS	DoIO

	move.l	a2,a1
	SYS	CloseDevice

.OpenError:
	addq.l	#8,a4
	addq.l	#1,d7
	cmp.w	#4,d7
	bne	.MainLoop

.NotResident:
CancelGad:
	bset	#0,(CloseFlag-DT,a5)
	rts

LastSavedGad:
	st	(MemRes)
	bsr	SetupScreen	;Create display (& a lot more!)
	rts

PrefsError:
	Permit
	bra.b	CancelGad

MagicPortName:	dc.b	'newser_prefs',0
PortNameLength	equ	*-MagicPortName
ResName:	dc.b	'newser.device',0
NewSerName:	dc.b	'newser.device',0
	even

myunit:	dcb.b	IOEXTSER_SIZE,0
replyport:	dcb.b	MP_SIZE,0
Preset:
	dl	SER_DEFAULT_CTLCHAR ;prefs_CTLCHAR
	dl	64*1024	;prefs_RBUFLEN
	dl	0	;prefs_EXTFLAGS
	dl	9600	;prefs_BAUD
	dl	250000	;prefs_BRKTIME
	dl	0	;prefs_TERMARRAY
	dl	0	;prefs_TERMARRAY
	db	8	;prefs_READLEN
	db	8	;prefs_WRITELEN
	db	1	;prefs_STOPBITS
;Note: RAD_BOOGIE must NOT be set here
	db	$88	;prefs_SERFLAGS
baudtable:
	dw	50
	dw	110
	dw	135
	dw	150
	dw	300
	dw	600
	dw	1200
	dw	1800
	dw	2400
	dw	3600
	dw	4800
	dw	7200
	dw	9600
	dw	19200
	dw	38400
	dw	31250	;MIDI (external clock)

MemRes:	dc.w	0

****************************************
*              SubRoutines             *
****************************************

*************************************************************************
* NAME:	GetFile()
* FUNCTION:	Read prefs file into memory.
* INPUTS:	None
* RETURN:	D0 = TRUE if success, else FALSE.
* SCRATCH:	D0-D5/A0-A2/A6
*************************************************************************

GetFile:
	movea.l	(Dos_Base-DT,a5),a6
	lea	(FileName,pc),a2
	moveq	#SHARED_LOCK,d2	;Does file exist?
	move.l	a2,d1
	SYS	Lock
	move.l	d0,d5	;Lock
	beq.b	3$	;No, we'll create it later

	move.l	#MODE_OLDFILE,d2
	move.l	a2,d1	;Yes, use it
	SYS	Open
	move.l	d0,d4	;FileHandle
	bne.b	1$
	move.l	d5,d1	;Lock
	SYS	UnLock
	lea	(OpenErr.msg,pc),a0 ;Couldn't open file
	bra.b	2$

1$:
	moveq	#32,d3
	lea	(MySerPrefs-DT,a5),a0
	move.l	a0,d2	;Buffer
	move.l	d4,d1	;FileHandle
	SYS	Read	;Finally, read it in
	move.l	d0,-(sp)
	move.l	d4,d1	;FileHandle
	SYS	Close	;Close the file
	move.l	d5,d1	;Lock
	SYS	UnLock	;Release the lock
	cmpi.l	#32,(sp)+	;Read it all in?
	beq.b	4$	;Yes, read it all
	lea	(ReadErr.msg,pc),a0 ;No, couldn't reach eof

2$	bsr	strlen
	move.l	d0,d3	;Length
	move.l	a0,d2	;Buffer
	move.l	(stdout-DT,a5),d1	;FileHandle
	beq.b	3$
	SYS	Write
3$	moveq	#FALSE,d0
	bra.b	5$

4$	moveq	#TRUE,d0
5$	rts

FileName	PREFFILE

OpenErr.msg cstr 'SerialPrefs: Error opening S:Serial-Preferences',$a
ReadErr.msg cstr 'SerialPrefs: Error reading S:Serial-Preferences',$a
MakeErr.msg cstr 'SerialPrefs: Error creating S:Serial-Preferences',$a
WritErr.msg cstr 'SerialPrefs: Error writing S:Serial-Preferences',$a
	even

*************************************************************************
* NAME:	PutFile()
* FUNCTION:	Save prefs to file.
*	If file does not exist, it will be created.
* INPUTS:	None
* RETURN:	D0 = TRUE if success, else FALSE.
* SCRATCH:	D0-D5/A0-A2/A4/A6
*************************************************************************

PutFile:
	movea.l	(Dos_Base-DT,a5),a6
	lea	(FileName,pc),a2
	moveq	#SHARED_LOCK,d2	;Does file exist?
	move.l	a2,d1
	SYS	Lock
	move.l	#MODE_OLDFILE,d2
	move.l	d0,d5	;Lock
	bne.b	1$	;Yes, use it

	move.l	#MODE_NEWFILE,d2	;No, create a new one
1$	move.l	a2,d1
	SYS	Open
	move.l	d0,d4	;FileHandle
	bne.b	2$
	move.l	d5,d1	;Lock
	SYS	UnLock
	lea	(MakeErr.msg,pc),a0 ;Couldn't create file
	bra.b	3$

2$	moveq	#32,d3	;Length
	lea	(MySerPrefs-DT,a5),a0
	move.l	a0,d2	;Buffer
	move.l	d4,d1	;FileHandle
	SYS	Write	;Finally, write it out
	move.l	d0,-(sp)
	move.l	d4,d1	;FileHandle
	SYS	Close	;Close the file
	move.l	d5,d1	;Lock
	SYS	UnLock	;Release the lock
	cmpi.l	#32,(sp)+	;Wrote it all out?
	beq.b	5$	;Yes, wrote it all
	lea	(WritErr.msg,pc),a0 ;No, error

3$	bsr	strlen
	move.l	d0,d3	;Length
	move.l	a0,d2	;Buffer
	move.l	(stdout-DT,a5),d1	;FileHandle
	beq.b	4$
	SYS	Write
4$	moveq	#FALSE,d0
	bra.b	6$

5$	moveq	#TRUE,d0
6$	rts

*************************************************************************
* Name:	MutualExclude()
* Function:	Perform mutual exclude function for gadgets.
*
* Cur  Cur | Comp   If the gadget is the current one AND it is already
* Gad  Col | Gad?   selected, don't change it.  If the gadget is not the
* ---------------   current one, AND it is NOT selected, don't change it.
*  0    0  |  0     In both other cases, complement it's current state.
*  0    1  |  1     D2 and D3 are TRUE or FALSE depending on these two
*  1    0  |  1     conditions.  EOR'ing them, gives our response:  If
*  1    1  |  0     TRUE, complement.  Else, don't.
*
* Input:	D0 = Number of gadgets in this group.
*	A0 = Ptr to 1st gadget in this group.
*	A2 = Ptr to gadget that was just selected.
* Results:	None
* Scratch:	D0-D1/A0-A1
*************************************************************************

MutualExclude:
	movem.l	d2-d4/a2-a6,-(sp)
	movea.l	(Gfx_Base-DT,a5),a6
	movea.l	(RastPtr-DT,a5),a3	;RastPort
	movea.l	a0,a4	;1st gadget in group
	move.w	d0,d4	;Numgads
	subq.w	#1,d4

	moveq	#1,d0
	movea.l	a3,a1
	SYS	SetAPen

	moveq	#RP_COMPLEMENT,d0
	movea.l	a3,a1
	SYS	SetDrMd

1$	move.w	(gg_GadgetID,a2),d0 ;ID of selected gadget
	cmp.w	(gg_GadgetID,a4),d0 ;Is this the current gadget?
	seq	d2	  ;D2 = 1 if TRUE
	move.w	(gg_LeftEdge,a4),d0
	move.w	(gg_TopEdge,a4),d1
	movea.l	a3,a1
	movem.w	d0-d1,-(sp)	;Save Left & Top
	SYS	ReadPixel
	cmpi.w	#3,d0	;This color means complemented
	seq	d3	;D3 = 1 if TRUE
	movem.w	(sp)+,d0-d1
	eor.b	d2,d3
	beq.b	2$

	move.w	d0,d2	;Xmin
	move.w	d1,d3	;Ymin
	add.w	(gg_Width,a4),d2
	subq.w	#2,d2	;Xmax
	add.w	(gg_Height,a4),d3
	subq.w	#1,d3	;Ymax
	movea.l	a3,a1
	SYS	RectFill

2$	moveq	#0,d2	;Clear for next gadget
	moveq	#0,d3
	movea.l	(gg_NextGadget,a4),a4
	dbra	d4,1$

	movem.l	(sp)+,d2-d4/a2-a6
	rts

*************************************************************************
* NAME:	MakePointer()
* FUNCTION:	Disallow any user selections.  Make a "sleepy" pointer
*	for the window.
* INPUTS:	None
* RETURN:	Modifies Pointer & IDCMP
* SCRATCH:	None
*************************************************************************

MakePointer:
	tst.b	(ZZZFlag-DT,a5)	;Already modified?
	bne.b	1$

	movem.l	d0-d3/a0-a1/a6,-(sp)
	movea.l (WindowPtr-DT,a5),a0
	move.l	a0,-(sp)
	moveq	#SIZEVERIFY,d0	;So we'll never get a message
	movea.l	(Int_Base-DT,a5),a6
	SYS	ModifyIDCMP	; while we/re busy.

	movea.l (sp)+,a0	;Window
	lea	(SpriteData),a1	;Already in CHIP mem
	moveq	#24,d0	;Height
	moveq	#16,d1	;Width
	moveq	#-8,d2	;XOffset
	moveq	#-8,d3	;YOffset
	SYS	SetPointer	;Change sprite into ZZZ pointer

	move.b	#1,(ZZZFlag-DT,a5)
	movem.l	(sp)+,d0-d3/a0-a1/a6
1$	rts

*************************************************************************
* NAME:	RemPointer()
* FUNCTION:	Restore normal pointer and user selections to window.
* INPUTS:	None
* RETURN:	Modifies Pointer & IDCMP
* SCRATCH:	None
*************************************************************************

RemPointer:
	tst.b	(ZZZFlag-DT,a5)	;Normal now?
	beq.b	1$

	movem.l	d0-d1/a0-a1/a6,-(sp)
	movea.l	(WindowPtr-DT,a5),a0 ;Change sprite back to normal
	move.l	a0,-(sp)
	movea.l	(Int_Base-DT,a5),a6
	SYS	ClearPointer

	movea.l	(sp)+,a0
	moveq	#GADGETDOWN!GADGETUP,D0 ;Now we want messages again
	SYS	ModifyIDCMP

	clr.b	(ZZZFlag-DT,a5)
	movem.l	(sp)+,d0-d1/a0-a1/a6
1$	rts

*************************************************************************
* NAME:	SetupScreen()
* FUNCTION:	Create display.  Link gadgets to window.
* INPUTS:	None
* RETURN:	None
* SCRATCH:	D0-D4/A0-A2/A6
*************************************************************************

SetupScreen:
	movea.l	(Gfx_Base-DT,a5),a6
	movea.l	(RastPtr-DT,a5),a2
	moveq	#2,d0	;Color background
	movea.l	a2,a1
	SYS	SetAPen

	moveq	#RP_JAM1,d0
	movea.l	a2,a1
	SYS	SetDrMd

	moveq	#2,d0	;Xmin
	moveq	#1,d1	;Ymin
	move.w	#637,d2	;Xmax
	move.w	#188,d3	;Ymax
	movea.l	a2,a1
	SYS	RectFill

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	lea	(FirstGadget-DT,a5),a0
1$	move.w	(gg_LeftEdge,a0),d0
	subq.w	#2,d0
	move.w	(gg_TopEdge,a0),d1
	subq.w	#1,d1
	move.w	(gg_Width,a0),d2
	addq.w	#2,d2
	move.w	(gg_Height,a0),d3
	addq.w	#1,d3
	bsr	Box	;Draw gadget boxes
	move.l	(gg_NextGadget,a0),d0
	movea.l	d0,a0
	bne.b	1$

	lea	(TextCoords,pc),a0
	moveq	#8-1,d4
2$	move.w	(a0)+,d0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	move.w	(a0)+,d3
	bsr	Box	;Draw text boxes
	dbra	d4,2$

	lea	(Text.tbl,pc),a1
3$	move.w	(a1)+,d0
	beq.b	4$
	move.w	(a1)+,d1
	movea.l	(a1)+,a0
	bsr	Text	;Draw all the text
	bra.b	3$

4$	movea.l	(WindowPtr-DT,a5),a1
	movea.l	(wd_FirstGadget,a1),a0
	suba.l	a2,a2
	movea.l	(Int_Base-DT,a5),a6
	SYS	RefreshGadgets	;Redraw gadgets

	bsr	MakePointer

;Check for memory resident prefs
	tst.w	(MemRes)
	beq.b	.Normal
	clr.w	(MemRes)
	bra.b	.NotFound

.Normal:
	push	a6
	move.l	(4).w,a6
	lea	(MagicPortName,pc),a1
	Forbid
	SYS	FindPort
	Permit
	pop	a6
	move.l	d0,a0
	lea	(MP_SIZE,a0),a0
	tst.l	d0
	beq.b	.NotFound
	lea	(MySerPrefs-DT,a5),a1
	moveq	#32/4-1,d0
..	move.l	(a0)+,(a1)+
	dbra	d0,..
	moveq	#1,d0	;success
	bra.b	.PortFound

.NotFound:
	bsr	GetFile	;Try to get our file

.PortFound:
	bsr	RemPointer
	tst.l	d0	;If no file, or error
	bne.b	5$	; reading, set defaults

	moveq	#1,d0	;1024 byte default
	move.w	d0,(_BufSize01-DT,a5)
	move.w	d0,(_BufSize02-DT,a5)
	move.w	d0,(_BufSize11-DT,a5)
	move.w	d0,(_BufSize12-DT,a5)

	moveq	#6,d0	;1200 baud default
	move.w	d0,(_BaudRate01-DT,a5)
	move.w	d0,(_BaudRate02-DT,a5)
	move.w	d0,(_BaudRate11-DT,a5)
	move.w	d0,(_BaudRate12-DT,a5)

	moveq	#3,d0	;8 bits default
	move.b	d0,(_WordLen01-DT,a5)
	move.b	d0,(_WordLen02-DT,a5)
	move.b	d0,(_WordLen11-DT,a5)
	move.b	d0,(_WordLen12-DT,a5)

	moveq	#0,d0	;1 bit default
	move.b	d0,(_StopBits01-DT,a5)
	move.b	d0,(_StopBits02-DT,a5)
	move.b	d0,(_StopBits11-DT,a5)
	move.b	d0,(_StopBits12-DT,a5)

	moveq	#4,d0	;No parity default
	move.b	d0,(_Parity01-DT,a5)
	move.b	d0,(_Parity02-DT,a5)
	move.b	d0,(_Parity11-DT,a5)
	move.b	d0,(_Parity12-DT,a5)

	moveq	#0,d0	;RTS/CTS default
	move.b	d0,(_Shake01-DT,a5)
	move.b	d0,(_Shake02-DT,a5)
	move.b	d0,(_Shake11-DT,a5)
	move.b	d0,(_Shake12-DT,a5)

5$	move.w	(_BufSize01-DT,a5),d0 ;Whether by prefs file
	bsr	DoBuf01	    ;or by defaults, set strings.
	move.w	(_BufSize02-DT,a5),d0
	bsr	DoBuf02
	move.w	(_BufSize11-DT,a5),d0
	bsr	DoBuf11
	move.w	(_BufSize12-DT,a5),d0
	bsr	DoBuf12

	move.w	(_BaudRate01-DT,a5),d0
	bsr	DoBaud01
	move.w	(_BaudRate02-DT,a5),d0
	bsr	DoBaud02
	move.w	(_BaudRate11-DT,a5),d0
	bsr	DoBaud11
	move.w	(_BaudRate12-DT,a5),d0
	bsr	DoBaud12

	lea	(WordLen01.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_WordLen01-DT,a5),d0
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#4,d0
	bsr	MutualExclude

	lea	(StopBit01.0_gad-DT,a5),a0
	movea.l	a0,a2	 ;0 offset = 1 Bit
	tst.b	(_StopBits01-DT,a5)
	beq.b	9$
	lea	(gg_SIZEOF,a2),a2	;1 offset = 2 bits
9$	moveq	#2,d0
	bsr	MutualExclude

	lea	(Parity01.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_Parity01-DT,a5),d0 ;Value = offset
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#5,d0
	bsr	MutualExclude

	lea	(Shake01.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_Shake01-DT,a5),d0 ;Value = offset
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#3,d0
	bsr	MutualExclude

	lea	(WordLen02.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_WordLen02-DT,a5),d0
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#4,d0
	bsr	MutualExclude

	lea	(StopBit02.0_gad-DT,a5),a0
	movea.l	a0,a2	  ;0 offset = 1 Bit
	tst.b	(_StopBits02-DT,a5)
	beq.b	11$
	lea	(gg_SIZEOF,a2),a2	;1 offset = 2 bits
11$	moveq	#2,d0
	bsr	MutualExclude

	lea	(Parity02.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_Parity02-DT,a5),d0 ;Value = offset
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#5,d0
	bsr	MutualExclude

	lea	(Shake02.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_Shake02-DT,a5),d0 ;Value = offset
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#3,d0
	bsr	MutualExclude

	lea	(WordLen11.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_WordLen11-DT,a5),d0
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#4,d0
	bsr	MutualExclude

	lea	(StopBit11.0_gad-DT,a5),a0
	movea.l	a0,a2	  ;0 offset = 1 Bit
	tst.b	(_StopBits11-DT,a5)
	beq.b	13$
	lea	(gg_SIZEOF,a2),a2	;1 offset = 2 bits
13$	moveq	#2,d0
	bsr	MutualExclude

	lea	(Parity11.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_Parity11-DT,a5),d0 ;Value = offset
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#5,d0
	bsr	MutualExclude

	lea	(Shake11.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_Shake11-DT,a5),d0 ;Value = offset
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#3,d0
	bsr	MutualExclude

	lea	(WordLen12.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_WordLen12-DT,a5),d0
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#4,d0
	bsr	MutualExclude

	lea	(StopBit12.0_gad-DT,a5),a0
	movea.l	a0,a2	  ;0 offset = 1 Bit
	tst.b	(_StopBits12-DT,a5)
	beq.b	15$
	lea	(gg_SIZEOF,a2),a2	;1 offset = 2 bits
15$	moveq	#2,d0
	bsr	MutualExclude

	lea	(Parity12.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_Parity12-DT,a5),d0 ;Value = offset
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#5,d0
	bsr	MutualExclude

	lea	(Shake12.0_gad-DT,a5),a0
	moveq	#0,d0
	move.b	(_Shake12-DT,a5),d0 ;Value = offset
	mulu.w	#gg_SIZEOF,d0
	lea	(0,a0,d0.w),a2
	moveq	#3,d0
	bsr	MutualExclude
	rts

*************************************************************************
* NAME:	Box()
* FUNCTION:	Draws a box with double verticals for 640x200 mode.
* INPUTS:	D0:16 = LeftEdge, D1:16 = TopEdge
*	D2:16 = Width,    D3:16 = Height
* RETURN:	None
* SCRATCH:	None
*************************************************************************

Box	movem.l	d0-d3/a0-a2/a6,-(sp)
	movea.l	(Gfx_Base-DT,a5),a6
	movea.l (RastPtr-DT,a5),a2
	add.w	d0,d2	;LeftEdge + Width = Xmax
	add.w	d1,d3	;TopEdge + Height = Ymax
	movem.l d0-d3,-(sp)

	moveq	#1,d0	;Do outside rect w/color #1
	movea.l	a2,a1
	SYS	SetAPen

	movem.l (sp),d0-d3
	movea.l	a2,a1
	SYS	RectFill

	moveq	#0,d0	;Do inside rect w/color #0
	movea.l	a2,a1
	SYS	SetAPen

	movem.l (sp)+,d0-d3
	addq.w	#2,d0
	subq.w	#2,d2
	addq.w	#1,d1
	subq.w	#1,d3
	movea.l	a2,a1
	SYS	RectFill
	movem.l	(sp)+,d0-d3/a0-a2/a6
	rts

*************************************************************************
* NAME:	Clear()
* FUNCTION:	Clear BufSize or BaudRate text area.
* INPUTS:	D1:16 = BaseLine
* RETURN:	None
* SCRATCH:	D2-D3
*************************************************************************

Clear	movem.l	d0-d1/a0-a2/a6,-(sp)
	movea.l	(Gfx_Base-DT,a5),a6
	movea.l	(RastPtr-DT,a5),a2
	moveq	#77,d0	;Xmin
	move.w	d0,d2
	addi.w	#68,d2	;Xmax
	move.w	d1,d3
	subq.w	#8,d1	;Ymin
	addq.w	#3,d3	;Ymax
	movem.l	d0-d1/a0,-(sp)

	movea.l	a2,a1
	SYS	Move

	moveq	#0,d0
	movea.l	a2,a1
	SYS	SetAPen

	moveq	#RP_JAM1,d0
	movea.l	a2,a1
	SYS	SetDrMd

	movem.l	(sp)+,d0-d1/a0
	movea.l	a2,a1
	SYS	RectFill
	movem.l	(sp)+,d0-d1/a0-a2/a6
	rts

*************************************************************************
* NAME:	Text()
* FUNCTION:	Writes text to the screen.
* INPUTS:	D0:16 = LeftEdge
*	D1:16 = TopEdge
*	A0    = Ptr to text.
* RETURN:	None
* SCRATCH:	None
*************************************************************************

Text	movem.l	d0-d1/a0-a2/a6,-(sp)
	movea.l	(Gfx_Base-DT,a5),a6
	movea.l (RastPtr-DT,a5),a2
	move.l	a0,-(sp)
		
	movea.l	a2,a1
	SYS	Move

	moveq	#1,d0
	movea.l	a2,a1
	SYS	SetAPen

	moveq	#RP_JAM1,d0
	movea.l	a2,a1
	SYS	SetDrMd

	movea.l	(sp)+,a0
	bsr.b	strlen
	movea.l	a2,a1
	SYS	Text
	movem.l	(sp)+,d0-d1/a0-a2/a6
	rts

strlen	move.l	a0,d0
1$	tst.b	(a0)+
	bne.b	1$
	exg	a0,d0
	sub.l	a0,d0
	subq.l	#1,d0
	rts

TextCoords	dw	75,16,72,15		;ACIA 0,UNIT 1:BufSize Box
	dw	75,31,72,15		;ACIA 0,UNIT 1:BaudRate Box

	dw	75,56,72,15		;ACIA 0,UNIT 1:BufSize Box
	dw	75,71,72,15		;ACIA 0,UNIT 1:BaudRate Box

	dw	75,96,72,15		;ACIA 0,UNIT 1:BufSize Box
	dw	75,111,72,15		;ACIA 0,UNIT 1:BaudRate Box

	dw	75,136,72,15		;ACIA 0,UNIT 1:BufSize Box
	dw	75,151,72,15		;ACIA 0,UNIT 1:BaudRate Box

Text.tbl	sett	82,12,BufSize.txt	;All window text coords & ptrs
	sett	87,176,BaudRate.txt
	sett	188,12,WordLen.txt
	sett	293,12,StopBits.txt
	sett	405,12,Parity.txt
	sett	531,12,Handshak.txt

	sett	12,34,UNIT1.txt
	sett	12,74,UNIT2.txt
	sett	12,114,UNIT3.txt
	sett	12,154,UNIT4.txt
	dw	0

BufTxt.tbl	dl	Buf512.txt	;Text ptrs for BufSize
	dl	Buf1024.txt
	dl	Buf2048.txt
	dl	Buf4096.txt
	dl	Buf8192.txt
	dl	Buf16384.txt
	dl	Buf32768.txt
	dl	Buf65536.txt

BaudTxt.tbl	dl	Baud50.txt	;Text ptrs for BaudRate
	dl	Baud110.txt
	dl	Baud134.txt
	dl	Baud150.txt
	dl	Baud300.txt
	dl	Baud600.txt
	dl	Baud1200.txt
	dl	Baud1800.txt
	dl	Baud2400.txt
	dl	Baud3600.txt
	dl	Baud4800.txt
	dl	Baud7200.txt
	dl	Baud9600.txt
	dl	Baud19200.txt
	dl	Baud38400.txt
	dl	BaudMIDI.txt

UNIT1.txt	cstr	'UNIT 1'	;All program text
UNIT2.txt	cstr	'UNIT 2'
UNIT3.txt	cstr	'UNIT 3'
UNIT4.txt	cstr	'UNIT 4'
BufSize.txt	cstr	'Buffer Size'
BaudRate.txt	cstr	'Baud Rate'
WordLen.txt	cstr	'Word Length'
StopBits.txt	cstr	'Stop Bits'
Parity.txt	cstr	'Parity'
Handshak.txt	cstr	'Handshaking'
Buf512.txt	cstr	'512'
Buf1024.txt	cstr	'1024'
Buf2048.txt	cstr	'2048'
Buf4096.txt	cstr	'4096'
Buf8192.txt	cstr	'8192'
Buf16384.txt	cstr	'16384'
Buf32768.txt	cstr	'32768'
Buf65536.txt	cstr	'65536'
Baud50.txt	cstr	'50'
Baud110.txt	cstr	'110'
Baud134.txt	cstr	'134'
Baud150.txt	cstr	'150'
Baud300.txt	cstr	'300'
Baud600.txt	cstr	'600'
Baud1200.txt	cstr	'1200'
Baud1800.txt	cstr	'1800'
Baud2400.txt	cstr	'2400'
Baud3600.txt	cstr	'3600'
Baud4800.txt	cstr	'4800'
Baud7200.txt	cstr	'7200'
Baud9600.txt	cstr	'9600'
Baud19200.txt	cstr	'19200'
Baud38400.txt	cstr	'38400'
BaudMIDI.txt	cstr	'MIDI'
Len5.txt	cstr	'5'
Len6.txt	cstr	'6'
Len7.txt	cstr	'7'
Len8.txt	cstr	'8'
Stop1.txt	cstr	'1'
Stop2.txt	cstr	'2'
ParEven.txt	cstr	'Even'
ParOdd.txt	cstr	'Odd'
ParMark.txt	cstr	'Mark'
ParSpace.txt	cstr	'Space'
ParNone.txt	cstr	'None'
RTS_CTS.txt	cstr	'RTS/CTS'
xON_xOFF.txt	cstr	'Xon/Xoff'
Save.txt		cstr	'Save'
Cancel.txt	cstr	'Cancel'
Use.txt		cstr	'Use'
LastSaved.txt	cstr	'Last Saved'

DosName	cstr	'dos.library'
IntName	cstr	'intuition.library'
GfxName	cstr	'graphics.library'
FontName	cstr	'topaz.font'
ScreenTtl	cstr	'SerialPrefs - ©1990,91 The Puzzle Factory'

	SECTION	sprite,DATA,CHIP

UpData	dw	%0000000000011100,%0000000000000000
	dw	%0000000001111111,%0000000000000000
	dw	%0000000111111111,%1100000000000000
	dw	%0000011111111111,%1111000000000000
	dw	%0001111111111111,%1111110000000000
	dw	%0000000000000000,%0000000000000000

DownData	dw	%0001111111111111,%1111110000000000
	dw	%0000011111111111,%1111000000000000
	dw	%0000000111111111,%1100000000000000
	dw	%0000000001111111,%0000000000000000
	dw	%0000000000011100,%0000000000000000
	dw	%0000000000000000,%0000000000000000

SpriteData	dw	0,0
	dw	%0000000000000000,%0000000000000000
	dw	%0000000000000000,%0000000000000000
	dw	%0000011100100000,%0000011100100000
	dw	%0000111111100000,%0000111111100000
	dw	%0011111111110000,%0011111111110000
	dw	%0111111111110000,%0110000111110000
	dw	%0111111111111000,%0111101111111000
	dw	%0111111111111100,%0111011111111100
	dw	%1111111111111100,%1110000111111100
	dw	%0011111111111110,%0011111111111110
	dw	%0111111111111111,%0111111100001111
	dw	%0011111111111110,%0011111111011110
	dw	%0111111111111110,%0111111110111110
	dw	%0011111111111100,%0011111100001100
	dw	%0001111111111000,%0001111111111000
	dw	%0000011111110000,%0000011111110000
	dw	%0000000111000000,%0000000111000000
	dw	%0000011100000000,%0000011100000000
	dw	%0000111111000000,%0000111111000000
	dw	%0000010110000000,%0000010110000000
	dw	%0000000000000000,%0000000000000000
	dw	%0000000011000000,%0000000011000000
	dw	%0000000011100000,%0000000011100000
	dw	%0000000001000000,%0000000001000000
	dw	0,0

	SECTION	vars,DATA

DT:

MyTextAttr:
	dl	FontName	;Topaz 8 font
	dw	8
	db	FS_NORMAL
	db	FPF_ROMFONT

MyScreen:
	dw	0,0,640,200,2
	db	0,1
	dw	V_HIRES
	dw	CUSTOMSCREEN
	dl	MyTextAttr,ScreenTtl,0,0

MyWindow:
	dw	0,10,640,190
	db	0,1
	dl	GADGETDOWN!GADGETUP
	dl	SMART_REFRESH!NOCAREREFRESH!ACTIVATE
	dl	FirstGadget,0,0,0,0
	dw	0,0,0,0,CUSTOMSCREEN

FirstGadget:
BufUP01_gad	dl	BufDN01_gad
	dw	148,17,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyUpImage,0,0,0,0
	dw	0
	dl	BufUP01	;00=ACIA 0,UNIT 1:BufSize/UP

BufDN01_gad	dl	BuadUP01_gad
	dw	148,24,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyDownImage,0,0,0,0
	dw	1
	dl	BufDN01	;01=ACIA 0,UNIT 1:BufSize/DN

BuadUP01_gad	dl	BuadDN01_gad
	dw	148,32,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyUpImage,0,0,0,0
	dw	2
	dl	BaudUP01	;02=ACIA 0,UNIT 1:BaudRate/UP

BuadDN01_gad	dl	WordLen01.0_gad
	dw	148,39,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyDownImage,0,0,0,0
	dw	3
	dl	BaudDN01	;03=ACIA 0,UNIT 1:BaudRate/DN

WordLen01.0_gad	dl	WordLen01.1_gad
	dw	200,17,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len5.ITxt,0,0
	dw	4
	dl	WordLen01	;04=ACIA 0,UNIT 1:WordLen/5

WordLen01.1_gad	dl	WordLen01.2_gad
	dw	234,17,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len6.ITxt,0,0
	dw	5
	dl	WordLen01	;06=ACIA 0,UNIT 1:WordLen/6

WordLen01.2_gad	dl	WordLen01.3_gad
	dw	200,32,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len7.ITxt,0,0
	dw	6
	dl	WordLen01	;05=ACIA 0,UNIT 1:WordLen/7

WordLen01.3_gad	dl	StopBit01.0_gad
	dw	234,32,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len8.ITxt,0,0
	dw	7
	dl	WordLen01	;07=ACIA 0,UNIT 1:WordLen/8

StopBit01.0_gad	dl	StopBit01.1_gad
	dw	291,17,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Stop1.ITxt,0,0
	dw	8
	dl	StopBit01	;08=ACIA 0,UNIT 1:StopBit/1

StopBit01.1_gad	dl	Parity01.0_gad
	dw	291,32,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Stop2.ITxt,0,0
	dw	9
	dl	StopBit01	;09=ACIA 0,UNIT 1:StopBit/2

Parity01.0_gad	dl	Parity01.1_gad
	dw	457,17,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParEven.ITxt,0,0
	dw	10
	dl	Parity01	;13=ACIA 0,UNIT 1:Parity/O

Parity01.1_gad	dl	Parity01.2_gad
	dw	349,17,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParOdd.ITxt,0,0
	dw	11
	dl	Parity01	;10=ACIA 0,UNIT 1:Parity/E

Parity01.2_gad	dl	Parity01.3_gad
	dw	349,32,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParMark.ITxt,0,0
	dw	12
	dl	Parity01	;11=ACIA 0,UNIT 1:Parity/M

Parity01.3_gad	dl	Parity01.4_gad
	dw	457,32,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParSpace.ITxt,0,0
	dw	13
	dl	Parity01	;14=ACIA 0,UNIT 1:Parity/S

Parity01.4_gad	dl	Shake01.0_gad
	dw	403,17,53,29
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParNone.ITxt,0,0
	dw	14
	dl	Parity01	;12=ACIA 0,UNIT 1:Parity/N

Shake01.0_gad	dl	Shake01.1_gad
	dw	536,17,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,RTS_CTS.ITxt,0,0
	dw	15
	dl	Shake01	;15=ACIA 0,UNIT 1:RTS/CTS

Shake01.1_gad	dl	Shake01.2_gad
	dw	536,27,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,xON_xOFF.ITxt,0,0
	dw	16
	dl	Shake01	;16=ACIA 0,UNIT 1:xON/xOFF

Shake01.2_gad	dl	BufUP02_gad
	dw	536,37,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,NoShake.ITxt,0,0
	dw	17
	dl	Shake01	;16=ACIA 0,UNIT 1:None

BufUP02_gad	dl	BufDN02_gad
	dw	148,57,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyUpImage,0,0,0,0
	dw	20
	dl	BufUP02	;17=ACIA 0,UNIT 2:BufSize/UP

BufDN02_gad	dl	BuadUP02_gad
	dw	148,64,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyDownImage,0,0,0,0
	dw	21
	dl	BufDN02	;18=ACIA 0,UNIT 2:BufSize/DN

BuadUP02_gad	dl	BuadDN02_gad
	dw	148,72,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyUpImage,0,0,0,0
	dw	22
	dl	BaudUP02	;19=ACIA 0,UNIT 2:BaudRate/UP

BuadDN02_gad	dl	WordLen02.0_gad
	dw	148,79,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyDownImage,0,0,0,0
	dw	23
	dl	BaudDN02	;20=ACIA 0,UNIT 2:BaudRate/DN

WordLen02.0_gad	dl	WordLen02.1_gad
	dw	200,57,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len5.ITxt,0,0
	dw	24
	dl	WordLen02	;21=ACIA 0,UNIT 2:WordLen/5

WordLen02.1_gad	dl	WordLen02.2_gad
	dw	234,57,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len6.ITxt,0,0
	dw	25
	dl	WordLen02	;23=ACIA 0,UNIT 2:WordLen/6

WordLen02.2_gad	dl	WordLen02.3_gad
	dw	200,72,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len7.ITxt,0,0
	dw	26
	dl	WordLen02	;22=ACIA 0,UNIT 2:WordLen/7

WordLen02.3_gad	dl	StopBit02.0_gad
	dw	234,72,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len8.ITxt,0,0
	dw	27
	dl	WordLen02	;24=ACIA 0,UNIT 2:WordLen/8

StopBit02.0_gad	dl	StopBit02.1_gad
	dw	291,57,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Stop1.ITxt,0,0
	dw	28
	dl	StopBit02	;25=ACIA 0,UNIT 2:StopBit/1

StopBit02.1_gad	dl	Parity02.0_gad
	dw	291,72,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Stop2.ITxt,0,0
	dw	29
	dl	StopBit02	;26=ACIA 0,UNIT 2:StopBit/2

Parity02.0_gad	dl	Parity02.1_gad
	dw	457,57,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParEven.ITxt,0,0
	dw	30
	dl	Parity02	;30=ACIA 0,UNIT 2:Parity/O

Parity02.1_gad	dl	Parity02.2_gad
	dw	349,57,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParOdd.ITxt,0,0
	dw	31
	dl	Parity02	;27=ACIA 0,UNIT 2:Parity/E

Parity02.2_gad	dl	Parity02.3_gad
	dw	349,72,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParMark.ITxt,0,0
	dw	32
	dl	Parity02	;28=ACIA 0,UNIT 2:Parity/M

Parity02.3_gad	dl	Parity02.4_gad
	dw	457,72,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParSpace.ITxt,0,0
	dw	33
	dl	Parity02	;31=ACIA 0,UNIT 2:Parity/S

Parity02.4_gad	dl	Shake02.0_gad
	dw	403,57,53,29
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParNone.ITxt,0,0
	dw	34
	dl	Parity02	;29=ACIA 0,UNIT 2:Parity/N

Shake02.0_gad	dl	Shake02.1_gad
	dw	536,57,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,RTS_CTS.ITxt,0,0
	dw	35
	dl	Shake02	;32=ACIA 0,UNIT 2:RTS/CTS

Shake02.1_gad	dl	Shake02.2_gad
	dw	536,67,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,xON_xOFF.ITxt,0,0
	dw	36
	dl	Shake02	;33=ACIA 0,UNIT 2:xON/xOFF

Shake02.2_gad	dl	BufUP11_gad
	dw	536,77,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,NoShake.ITxt,0,0
	dw	37
	dl	Shake02	;16=ACIA 0,UNIT 2:None

BufUP11_gad	dl	BufDN11_gad
	dw	148,97,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyUpImage,0,0,0,0
	dw	40
	dl	BufUP11	;34=ACIA 1,UNIT 1:BufSize/UP

BufDN11_gad	dl	BuadUP11_gad
	dw	148,104,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyDownImage,0,0,0,0
	dw	41
	dl	BufDN11	;35=ACIA 1,UNIT 1:BufSize/DN

BuadUP11_gad	dl	BuadDN11_gad
	dw	148,112,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyUpImage,0,0,0,0
	dw	42
	dl	BaudUP11	;36=ACIA 1,UNIT 1:BaudRate/UP

BuadDN11_gad	dl	WordLen11.0_gad
	dw	148,119,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyDownImage,0,0,0,0
	dw	43
	dl	BaudDN11	;37=ACIA 1,UNIT 1:BaudRate/DN

WordLen11.0_gad	dl	WordLen11.1_gad
	dw	200,97,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len5.ITxt,0,0
	dw	44
	dl	WordLen11	;38=ACIA 1,UNIT 1:WordLen/5

WordLen11.1_gad	dl	WordLen11.2_gad
	dw	234,97,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len6.ITxt,0,0
	dw	45
	dl	WordLen11	;40=ACIA 1,UNIT 1:WordLen/6

WordLen11.2_gad	dl	WordLen11.3_gad
	dw	200,112,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len7.ITxt,0,0
	dw	46
	dl	WordLen11	;39=ACIA 1,UNIT 1:WordLen/7

WordLen11.3_gad	dl	StopBit11.0_gad
	dw	234,112,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len8.ITxt,0,0
	dw	47
	dl	WordLen11	;41=ACIA 1,UNIT 1:WordLen/8

StopBit11.0_gad	dl	StopBit11.1_gad
	dw	291,97,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Stop1.ITxt,0,0
	dw	48
	dl	StopBit11	;42=ACIA 1,UNIT 1:StopBit/1

StopBit11.1_gad	dl	Parity11.0_gad
	dw	291,112,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Stop2.ITxt,0,0
	dw	49
	dl	StopBit11	;43=ACIA 1,UNIT 1:StopBit/2

Parity11.0_gad	dl	Parity11.1_gad
	dw	457,97,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParEven.ITxt,0,0
	dw	50
	dl	Parity11	;47=ACIA 1,UNIT 1:Parity/O

Parity11.1_gad	dl	Parity11.2_gad
	dw	349,97,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParOdd.ITxt,0,0
	dw	51
	dl	Parity11	;44=ACIA 1,UNIT 1:Parity/E

Parity11.2_gad	dl	Parity11.3_gad
	dw	349,112,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParMark.ITxt,0,0
	dw	52
	dl	Parity11	;45=ACIA 1,UNIT 1:Parity/M

Parity11.3_gad	dl	Parity11.4_gad
	dw	457,112,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParSpace.ITxt,0,0
	dw	53
	dl	Parity11	;48=ACIA 1,UNIT 1:Parity/S

Parity11.4_gad	dl	Shake11.0_gad
	dw	403,97,53,29
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParNone.ITxt,0,0
	dw	54
	dl	Parity11	;46=ACIA 1,UNIT 1:Parity/N

Shake11.0_gad	dl	Shake11.1_gad
	dw	536,97,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,RTS_CTS.ITxt,0,0
	dw	55
	dl	Shake11	;49=ACIA 1,UNIT 1:RTS/CTS

Shake11.1_gad	dl	Shake11.2_gad
	dw	536,107,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,xON_xOFF.ITxt,0,0
	dw	56
	dl	Shake11	;50=ACIA 1,UNIT 1:xON/xOFF

Shake11.2_gad	dl	BufUP12_gad
	dw	536,117,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,NoShake.ITxt,0,0
	dw	57
	dl	Shake11	;16=ACIA 1,UNIT 1:None

BufUP12_gad	dl	BufDN12_gad
	dw	148,137,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyUpImage,0,0,0,0
	dw	60
	dl	BufUP12	;51=ACIA 1,UNIT 2:BufSize/UP

BufDN12_gad	dl	BuadUP12_gad
	dw	148,144,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyDownImage,0,0,0,0
	dw	61
	dl	BufDN12	;52=ACIA 1,UNIT 2:BufSize/DN

BuadUP12_gad	dl	BuadDN12_gad
	dw	148,152,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyUpImage,0,0,0,0
	dw	62
	dl	BaudUP12	;53=ACIA 1,UNIT 2:BaudRate/UP

BuadDN12_gad	dl	WordLen12.0_gad
	dw	148,159,26,7
	dw	GADGIMAGE!GADGHCOMP
	dw	GADGIMMEDIATE!RELVERIFY
	dw	BOOLGADGET
	dl	MyDownImage,0,0,0,0
	dw	63
	dl	BaudDN12	;54=ACIA 1,UNIT 2:BaudRate/DN

WordLen12.0_gad	dl	WordLen12.1_gad
	dw	200,137,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len5.ITxt,0,0
	dw	64
	dl	WordLen12	;55=ACIA 1,UNIT 2:WordLen/5

WordLen12.1_gad	dl	WordLen12.2_gad
	dw	234,137,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len6.ITxt,0,0
	dw	65
	dl	WordLen12	;57=ACIA 1,UNIT 2:WordLen/6

WordLen12.2_gad	dl	WordLen12.3_gad
	dw	200,152,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len7.ITxt,0,0
	dw	66
	dl	WordLen12	;56=ACIA 1,UNIT 2:WordLen/7

WordLen12.3_gad	dl	StopBit12.0_gad
	dw	234,152,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Len8.ITxt,0,0
	dw	67
	dl	WordLen12	;58=ACIA 1,UNIT 2:WordLen/8

StopBit12.0_gad	dl	StopBit12.1_gad
	dw	291,137,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Stop1.ITxt,0,0
	dw	68
	dl	StopBit12	;59=ACIA 1,UNIT 2:StopBit/1

StopBit12.1_gad	dl	Parity12.0_gad
	dw	291,152,33,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,Stop2.ITxt,0,0
	dw	69
	dl	StopBit12	;60=ACIA 1,UNIT 2:StopBit/2

Parity12.0_gad	dl	Parity12.1_gad
	dw	457,137,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParEven.ITxt,0,0
	dw	70
	dl	Parity12	;64=ACIA 1,UNIT 2:Parity/O

Parity12.1_gad	dl	Parity12.2_gad
	dw	349,137,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParOdd.ITxt,0,0
	dw	71
	dl	Parity12	;61=ACIA 1,UNIT 2:Parity/E

Parity12.2_gad	dl	Parity12.3_gad
	dw	349,152,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParMark.ITxt,0,0
	dw	72
	dl	Parity12	;62=ACIA 1,UNIT 2:Parity/M

Parity12.3_gad	dl	Parity12.4_gad
	dw	457,152,53,14
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParSpace.ITxt,0,0
	dw	73
	dl	Parity12	;65=ACIA 1,UNIT 2:Parity/S

Parity12.4_gad	dl	Shake12.0_gad
	dw	403,137,53,29
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,ParNone.ITxt,0,0
	dw	74
	dl	Parity12	;63=ACIA 1,UNIT 2:Parity/N

Shake12.0_gad	dl	Shake12.1_gad
	dw	536,137,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,RTS_CTS.ITxt,0,0
	dw	75
	dl	Shake12	;66=ACIA 1,UNIT 2:RTS/CTS

Shake12.1_gad	dl	Shake12.2_gad
	dw	536,147,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,xON_xOFF.ITxt,0,0
	dw	76
	dl	Shake12	;67=ACIA 1,UNIT 2:xON/xOFF

Shake12.2_gad	dl	Save_gad
	dw	536,157,78,9
	dw	GADGHNONE
	dw	GADGIMMEDIATE
	dw	BOOLGADGET
	dl	0,0,NoShake.ITxt,0,0
	dw	77
	dl	Shake12	;16=ACIA 1,UNIT 2:None

Save_gad	dl	Cancel_gad
	dw	200,173,40,12
	dw	GADGHCOMP
	dw	RELVERIFY
	dw	BOOLGADGET
	dl	0,0,Save.ITxt,0,0
	dw	80
	dl	SaveGad	;68=Save

Cancel_gad:
	dl	Use_gad
	dw	255,173,56,12
	dw	GADGHCOMP
	dw	RELVERIFY
	dw	BOOLGADGET
	dl	0,0,Cancel.ITxt,0,0
	dw	81
	dl	CancelGad	;69=Cancel

Use_gad	dl	LastSaved_gad
	dw	326,173,32,12
	dw	GADGHCOMP
	dw	RELVERIFY
	dw	BOOLGADGET
	dl	0,0,Use.ITxt,0,0
	dw	81
	dl	UseGad	;70=Cancel

LastSaved_gad:
	dl	0
	dw	373,173,88,12
	dw	GADGHCOMP
	dw	RELVERIFY
	dw	BOOLGADGET
	dl	0,0,LastSaved.ITxt,0,0
	dw	81
	dl	LastSavedGad	;70=Cancel

Len5.ITxt	db	1,0,RP_JAM1,0
	dw	12,4
	dl	MyTextAttr,Len5.txt,0

Len6.ITxt	db	1,0,RP_JAM1,0
	dw	12,4
	dl	MyTextAttr,Len6.txt,0

Len7.ITxt	db	1,0,RP_JAM1,0
	dw	12,4
	dl	MyTextAttr,Len7.txt,0

Len8.ITxt	db	1,0,RP_JAM1,0
	dw	12,4
	dl	MyTextAttr,Len8.txt,0

Stop1.ITxt	db	1,0,RP_JAM1,0
	dw	12,4
	dl	MyTextAttr,Stop1.txt,0

Stop2.ITxt	db	1,0,RP_JAM1,0
	dw	12,4
	dl	MyTextAttr,Stop2.txt,0

ParEven.ITxt	db	1,0,RP_JAM1,0
	dw	10,4
	dl	MyTextAttr,ParEven.txt,0

ParOdd.ITxt	db	1,0,RP_JAM1,0
	dw	12,4
	dl	MyTextAttr,ParOdd.txt,0

ParMark.ITxt	db	1,0,RP_JAM1,0
	dw	10,4
	dl	MyTextAttr,ParMark.txt,0

ParSpace.ITxt	db	1,0,RP_JAM1,0
	dw	6,4
	dl	MyTextAttr,ParSpace.txt,0

ParNone.ITxt	db	1,0,RP_JAM1,0
	dw	8,11
	dl	MyTextAttr,ParNone.txt,0

RTS_CTS.ITxt	db	1,0,RP_JAM1,0
	dw	8,1
	dl	MyTextAttr,RTS_CTS.txt,0

xON_xOFF.ITxt	db	1,0,RP_JAM1,0
	dw	6,1
	dl	MyTextAttr,xON_xOFF.txt,0

NoShake.ITxt	db	1,0,RP_JAM1,0
	dw	22,1
	dl	MyTextAttr,ParNone.txt,0

Save.ITxt	db	1,0,RP_JAM1,0
	dw	4,2
	dl	MyTextAttr,Save.txt,0

Cancel.ITxt:
	db	1,0,RP_JAM1,0
	dw	4,2
	dl	MyTextAttr,Cancel.txt,0

Use.ITxt:
	db	1,0,RP_JAM1,0
	dw	4,2
	dl	MyTextAttr,Use.txt,0

LastSaved.ITxt:
	db	1,0,RP_JAM1,0
	dw	4,2
	dl	MyTextAttr,LastSaved.txt,0

MyUpImage	dw	0,1,25,6,1	;Left,Top,Width,Height,Depth
	dl	UpData	;*ImageData
	db	%0001,%0000	;PlanePick,PlaneOnOff
	dl	0	;*NextImage

MyDownImage	dw	0,1,25,6,1
	dl	DownData
	db	%0001,%0000
	dl	0

BSS_Start:
Dos_Base	dx.l	1	;Ptr to dos.library
stdout	dx.l	1	;FileHandle
Int_Base	dx.l	1	;Ptr to intuition.library
Gfx_Base	dx.l	1	;Ptr to graphics.library
WBenchMsg	dx.l	1	;Initial WBench msg
ScreenPtr	dx.l	1	;Ptr to Screen structure
WindowPtr	dx.l	1	;Ptr to Window structure
RastPtr	dx.l	1	;Ptr to Window's RastPort
PortPtr	dx.l	1	;Ptr to Window's UserPort

*** New SerialPrefs Structure ***

MySerPrefs:			;For ACIA 0, Unit 1
_BufSize01	dx.w	1	;0-7
_BaudRate01	dx.w	1	;0-15
_WordLen01	dx.b	1	;0=5, 1=6, 2=7, 3=8
_StopBits01	dx.b	1	;0=1, 1=2
_Parity01	dx.b	1	;0=Odd, 1=Even, 2=Mark, 3=Space, 4=None
_Shake01	dx.b	1	;0=RTS/CTS, 1=xON/xOFF, 2=None

_BufSize02	dx.w	1	;Same for ACIA 0, Unit 2
_BaudRate02	dx.w	1
_WordLen02	dx.b	1
_StopBits02	dx.b	1
_Parity02	dx.b	1
_Shake02	dx.b	1

_BufSize11	dx.w	1	;Same for ACIA 1, Unit 1
_BaudRate11	dx.w	1
_WordLen11	dx.b	1
_StopBits11	dx.b	1
_Parity11	dx.b	1
_Shake11	dx.b	1

_BufSize12	dx.w	1	;Same for ACIA 1, Unit 2
_BaudRate12	dx.w	1
_WordLen12	dx.b	1
_StopBits12	dx.b	1
_Parity12	dx.b	1
_Shake12	dx.b	1

CloseFlag	dx.b	1	;0=OK, 1=Close program
ZZZFlag	dx.b	1	;1=Mouse ptr is currently a ZZZ cloud
BSS_Len	equ	*-BSS_Start

	end
