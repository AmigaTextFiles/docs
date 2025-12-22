*****************************************************************************
* Program:  newser.asm - Copyright ©1990,91 by Dan Babcock
*
* Permission is given for PERSONAL use of this code. Commercial
* use is of course forbidden. (Without prior permission etc.)
*
* Function: A "serial.device" compatible driver for the Rockwell 65C52
*           based on the 1.3 RKM driver example.
*
* Author:   Dan Babcock
* History:  08/12/90 V0.50 Created
*           09/06/90 V0.51 Cleaned up "eofdump" code.
*           11/04/90 V0.52 Misc. minor changes
*                          [release 1]
*           03/03/91 V1.10 Fixed some bugs, speeded up, & added prefs hook
*           03/08/91 V1.11 Bug fixes
*                          [release 2]
*
* [To all: Please don't forget to bump the revision numbers
*          if you do *any* modifications at all.  -Jeff]
*
* Feel free to contact me:
*
* [School address]               [Permanent address]      People/Link:
*  Dan Babcock                    Dan Babcock              DANBABCOCK
*  63 Atherton Hall               P.O. Box 1532
*  University Park, PA  16802     Southgate, MI  48195
*  Voice: (814)-862-2931
*
* I am also reachable via internet. I read comp.sys.amiga.programming.
*
* General notes
* =============
* The macro "PUTDEBUG" is used to output debugging information via the
* internal serial port at a low level. It may be used anywhere, including
* critical sections, supervisor mode, and interrupt code. If debugging is
* not desired, set the INFO_LEVEL equate to zero. Conversely, if debugging
* is desired, set it to a high value (e.g. 100000)
*
* A consistent (for the most part) usage of registers was employed:
*  A1 - pointer to an IORequest structure
*  A3 - pointer to a unit structure (defined below)
*  A4 - pointer to a serprefs structure (defined below)
*  A5 - pointer to the hardware (one channel, that is)
*  A6 - pointer to the device structure (defined below)
*
* Known difference(s) between this and serial.device are:
*  1. Start/Stop do not send XON/XOFF characters to the outside world
*     as implied in the autodoc (I don't think this is important).
*  2. Newser does not currently send an XOFF or otherwise tell the outside
*     world to "shut up" when the driver's input buffer fills.
*
* Suggestions for enhancements are welcome.
*****************************************************************************
*
* Also, some of the following is:
*
*****************************************************************************
*
* Copyright (C) 1986, Commodore Amiga Inc.  All rights reserved.
* Permission granted for non-commercial use
*
*****************************************************************************

;Set Tabs           |       |                 |

	super	;suppress warnings about supervisor mode
	exeobj
	objfile	'devs:newser.device'
	macfile	'newser.i'	;The One & Only include file for newser.asm

INFO_LEVEL	equ	000000	;Assembly-time options

;*************************** Structures *************************

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
VectorBase	so.l	1
MyPreviousAutoVec:	so.l	1
ScoreBoard	so.w	1
Chip1present	so.w	1
Chip2present	so.w	1
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
timerport	so.b	MP_SIZE
timeriorequest	so.b	IOTV_SIZE

;The -sig lwords must be contiguous
readsig	so.l	1	;Read task signals
readabortsig	so.l	1

tdresig	so.l	1	;Transmit buffer empty - put another byte
dsrsig	so.l	1	;Transition on DSR - used for handshaking (if enabled)
writeabortsig	so.l	1
xonsig	so.l	1	;Comes from read task, and indicates xon received
breaksig	so.l	1	;This is an Exec exception signal

HeadLong	so.w	1	;Ptr to start of circular buffer (logical)
Head	so.w	1
TailLong	so.w	1	;Ptr to end of circular buffer (logical)
Tail	so.w	1
startbuf	so.l	1	;Ptr to physical start of input buffer
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
	BITDEF	MDU,WaitingForChar,4
	BITDEF	MDU,CharAvailable,5

* Bit definitions for ioflags

	BITDEF	ioflags,Active,4	;IO request in progress
	BITDEF	ioflags,Ignore,5	;Ignore this IO request

* Equates & bit defs for IERstate

READINT	equ	$87
READINTMASK	equ	$7

WRITEINT	equ	$C0
WRITEINTMASK	equ	$40

WRITEOFF	equ	$40
WRITEOFFMASK	equ	$BF

MYIDENT	macro
	cstr	'newser.device V1.11 (March 8, 1991)',13,10
	even
	endm

;The first executable location.  This should return an error in case someone
;tried to run us as a program (instead of loading us as a device).

FirstAddress:
	moveq	#-1,d0
	rts

;A romtag structure.  After your driver is brought in from disk, the
;disk image will be scanned for this structure to discover magic constants
;about you (such as where to start running you from...).

initDDescrip:
	dw	RTC_MATCHWORD	;UWORD	RT_MATCHWORD (Magic cookie)
	dl	initDDescrip	;APTR	RT_MATCHTAG  (Back pointer)
	dl	EndCode	;APTR	RT_ENDSKIP   (To end of this hunk)
	db	RTF_AUTOINIT	;UBYTE	RT_FLAGS     (magic-see "Init")
	db	VERSION	;UBYTE	RT_VERSION
	db	NT_DEVICE	;UBYTE	RT_TYPE      (must be correct)
	db	MYPRI	;BYTE	RT_PRI
	dl	myName	;APTR	RT_NAME      (exec name)
	dl	idString	;APTR	RT_IDSTRING  (text string)
	dl	Init	;APTR	RT_INIT

	db	'newser.device - Copyright (c) 1990,91 by Dan Babcock. '
	db	'Contact me on People/Link or Usenet!'
	even

;nasty data area (makes this version non-ROMable)

OldVec:	dc.l	0
Unit0:	dc.l	0
Unit1:	dc.l	0
_Unit2:	dc.l	0	;_ used because of conflict with chip reg addr sym
Unit3:	dc.l	0


;*********************** Tables (constant) **********************

;Note!! Some of these values are depended on in the InitRoutine prefs
;code...i.e. they may not be changed arbitrarily!

defaultprefs:
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

;Table of DACIA base addresses for the 4 units

basetable:

; comment |
	dl	ACIA_Base
	dl	ACIA_Base+UNIT2
	dl	ACIA_Base+ACIA1
	dl	ACIA_Base+ACIA1+UNIT2
;|

 comment |
 dl $80000
 dl $80000
 dl $80000
 dl $80000
|

;List of supported baud rates 

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

timername:
	cstr	'timer.device'

	ifne	INFO_LEVEL	;If any debugging enabled at all
subSysName:
	cstr	'newser'	;This name for debugging use
	endc

myName	MYDEVNAME	;This is the name that the device will have

;This is an identifier tag to help in supporting the device
;format is 'name version.revision (dd MON yyyy)',<cr>,<lf>,<null>

idString	MYIDENT

;The romtag specified that we were "RTF_AUTOINIT".  This means that the
;RT_INIT structure member points to one of these tables below.  If the
;AUTOINIT bit was not set then RT_INIT would point to a routine to run.

Init	dl	MyDev_Sizeof	;data space size
	dl	funcTable	;pointer to function initializers
	dl	dataTable	;pointer to data initializers
	dl	initRoutine	;routine to run

funcTable:
	dl	Open	;standard system routines
	dl	_Close
	dl	Expunge
	dl	Null	;Reserved for future use!
	dl	BeginIO	;my device definitions
	dl	AbortIO
	dl	-1	;function table end marker

;The data table initializes static data structures. The format is
;specified in exec/InitStruct routine's manual pages.  The
;INITBYTE/INITWORD/INITLONG macros are in the file "exec/initializers.i".
;The first argument is the offset from the device base for this
;byte/word/long. The second argument is the value to put in that cell.
;The table is null terminated

dataTable:
	INITBYTE LN_TYPE,NT_DEVICE ;Must be LN_TYPE!
	INITLONG LN_NAME,myName
	INITBYTE LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
	INITWORD LIB_VERSION,VERSION
	INITWORD LIB_REVISION,REVISION
	INITLONG LIB_IDSTRING,idString
	dw	 0	;terminate list

;This routine gets called after the device has been allocated.  The device
;pointer is in D0.  The AmigaDOS segment list is in a0.  If it returns the
;device pointer, then the device will be linked into the device list.  If it
;returns NULL, then the device will be unloaded.
;
;This call is single-threaded by exec; please read the description for
;"Open" below.
;
; Register Usage
; ==============
; a3 -- Points to temporary RAM
; a4 -- Expansion library base
; a5 -- device pointer
; a6 -- Exec base

initRoutine:
	PUTDEBUG 5,<'%s/Init: called'>
	movem.l	d1-d7/a0-a6,-(sp)	;Preserve ALL modified registers

	movea.l	d0,a5
	move.l	a6,(md_SysLib,a5)	;Save a pointer to exec
	move.l	a0,(md_SegList,a5) ;Save pointer to our loaded code

;Check for presence/absence of the 2 serial chips
	moveq	#0,d0
	moveq	#0,d1
	move.l	#ACIA_Base,a4
	move.b	#$83,(FMR,a4)
	move.b	(CSR,a4),d2
	and.b	#3,d2
	cmp.b	#3,d2
	bne.b	.Chip2
	move.b	#$80,(FMR,a4)
	move.b	(CSR,a4),d2
	and.b	#3,d2
	bne.b	.Chip2
	moveq	#-1,d0
.Chip2:
	move.l	#ACIA_Base+ACIA1,a4
	move.b	#$83,(FMR,a4)
	move.b	(CSR,a4),d2
	and.b	#3,d2
	cmp.b	#3,d2
	bne.b	.Done
	move.b	#$80,(FMR,a4)
	move.b	(CSR,a4),d2
	and.b	#3,d2
	bne.b	.Done
	moveq	#-1,d1

.Done:
	move.w	d0,(Chip1present,a5)
	move.w	d1,(Chip2present,a5)

;Take over level 6 autovector
	clr.l	(VectorBase,a5)
	tst.w	(AttnFlags,a6)
	beq.b	.skipvbr

	SYS	SuperState
	dc.l	$4E7AA801	;movec vbr,a2
	bsr	MyUserState

	move.l	a2,(VectorBase,a5)
.skipvbr:
	move.l	(VectorBase,a5),a0
	move.l	($78,a0),(OldVec)
	move.l	#Int0000,($78,a0)
	move.l	#Int0000,(MyPreviousAutoVec,a5)
	move.l	a5,a6
	bsr	SetDefaultPrefs
	move.l	(4).w,a6

;Try to find the prefs in memory
	lea	(MagicPortName,pc),a1
	SYS	FindPort
	tst.l	d0
	beq	.EndInit	;use hard-coded defaults
	move.l	d0,a0
	lea	(MP_SIZE,a0),a3
	move.l	a5,a6
	lea	(prefs_unit0,a6),a2

	moveq	#3,d7	;4 units
	moveq	#0,d5

.OuterLoop:
	move.l	d5,d6
	lsl.w	#3,d6	;Convert unit # to index
	move.l	a3,a1
	lea	(a1,d6.w),a1	;UnitPrefs for this unit
.PrefsLoop:
	moveq	#0,d0
	move.w	#512,d0
	moveq	#0,d1
	move.w	(up_BufSize,a1),d1 ;0-7
	lsl.l	d1,d0
	move.l	d0,(prefs_RBUFLEN,a2)

	lea	(baudtable,pc),a0
	move.w	(up_BaudRate,a1),d0 ;0-15
	add.w	d0,d0
	moveq	#0,d1
	move.w	(a0,d0.w),d1
	move.l	d1,(prefs_BAUD,a2)

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
	move.b	d1,(prefs_READLEN,a2)
	move.b	d1,(prefs_WRITELEN,a2)

	move.b	(up_StopBits,a1),d0 ;0-1
	addq.b	#1,d0
	move.b	d0,(prefs_STOPBITS,a2)

	move.b	(up_Parity,a1),d0
	cmp.b	#4,d0	;none?
	beq.b	.SkipParity
	bset	#SERB_PARTY_ON,(prefs_SERFLAGS,a2)
	cmp.b	#2,d0
	bcc.b	.MarkSpace
	bclr	#SERB_PARTY_ODD,(prefs_SERFLAGS,a2)	;set to even
	tst.b	d0
	bne.b	.SkipParity
	bset	#SERB_PARTY_ODD,(prefs_SERFLAGS,a2)	;set to odd
	bra.b	.SkipParity
.MarkSpace:
	bset	#SEXTB_MSPON,(3+prefs_EXTFLAGS,a2)
	bclr	#SEXTB_MARK,(3+prefs_EXTFLAGS,a2)	;set to space
	cmp.b	#3,d0
	beq.b	.SkipParity
	bset	#SEXTB_MARK,(3+prefs_EXTFLAGS,a2)

.SkipParity:
	move.b	(up_Shake,a1),d0
	cmp.b	#2,d0
	beq.b	.SkipShake
	cmp.b	#1,d0
	bne.b	.SkipXon
	bclr	#SERB_XDISABLED,(prefs_SERFLAGS,a2)
	bra.b	.SkipShake
.SkipXon:
	bset	#SERB_7WIRE,(prefs_SERFLAGS,a2)
.SkipShake:
	addq.l	#1,d5
	add.w	#serprefs_sizeof,a2
	dbra	d7,.OuterLoop

.EndInit:
	move.l	a5,d0	;no error (zero indicates error)
			;MUST return device ptr
	PUTDEBUG 5,<'%s/Init: finished'>
	movem.l	(sp)+,d1-d7/a0-a6
	rts

MagicPortName:	dc.b	'newser_prefs',0
	even

MyUserState:
;(The one in 1.2/1.3 ROM is buggy)
	move.l  (sp)+,d1
	move.l  sp,usp
	movea.l d0,sp
	movea.l a5,a0
	lea     mus(pc),a5
	jmp     -$1E(a6)
mus	movea.l a0,a5
	move.l  d1,$02(sp)
	andi.w  #$DFFF,(sp)
	rte


;Enter with device ptr in a6.

SetDefaultPrefs:
	movem.l	d0/d1/a0/a1,-(sp)
	lea	(prefs_unit0,a6),a1
	moveq	#MD_NUMUNITS-1,d1
1$	move.w	#serprefs_sizeof-1,d0
	lea	(defaultprefs,pc),a0
2$	move.b	(a0)+,(a1)+
	dbra	d0,2$
	dbra	d1,1$
	movem.l	(sp)+,d0/d1/a0/a1
	rts

NewVector:
;Enter with device ptr in a6
;exit with d0=0 if OK, else error!

;uses d0,a0,a1

	movem.l	a0/a1,-(sp)
	move.l	(VectorBase,a6),a1
	move.l	(MyPreviousAutoVec,a6),d0
	cmp.l	($78,a1),d0
	bne.b	.error

	moveq	#0,d0
	move.b	(ScoreBoard,a6),d0
	lsl.l	#2,d0
	lea	(IntRoutines,pc),a0
	move.l	(a0,d0.w),(MyPreviousAutoVec,a6)
	move.l	(a0,d0.w),($78,a1)
	moveq	#0,d0
.endit:
	movem.l	(sp)+,a0/a1
	rts
.error:
	moveq	#1,d0
	bra.b	.endit


;Here begins the system interface commands.  When the user calls OpenDevice/
;CloseDevice/RemDevice, this eventually gets translated into a call to the
;following routines (Open/Close/Expunge).  Exec has already put our device
;pointer in a6 for us.
;
;Open sets the IO_ERROR field on an error. If it was successful, we should
;also set up the IO_UNIT and LN_TYPE fields.  exec takes care of setting up
;IO_DEVICE.
;
;NOTE: We must also copy the current prefs for this unit into the user's
;extended iorequest fields.
;
; Register Usage
; ==============
; d0 -- unitnum
; d1 -- flags
; a1 -- iob
; a6 -- Device ptr

Open:
	addq.w	#1,(LIB_OPENCNT,a6) ;Fake an opener for duration of call
	PUTDEBUG 20,<'%s/Open: called'>
	movem.l	d2/a2-a4,-(sp)
	movea.l	a1,a2	;Save the iob
	cmp.l	#MD_NUMUNITS,d0	;See if the unit number is in range
	bcc	Open_Range_Error	;Unit number out of range (BHS)

;Check to see if the corresponding chip is installed
	lea	(Chip1present,a6),a4
	tst.b	(a4,d0.w)
	beq	Open_Range_Error

	move.l	d0,d2	;Save unit number
	lsl.l	#2,d0	;See if the unit is already initialized
	lea	(md_Units,a6,d0.l),a4
	move.l	(a4),d0
	bne.b	Open_UnitOK
				;Try to conjure up a unit
	bsr	InitUnit	;scratch:a3 unitnum:d2 devpoint:a6
	move.l	(a4),d0	;See if it initialized OK
	beq.w	Open_Error
	movea.l	d0,a3
	bra.b	Open_UnitOK1

Open_UnitOK:
	movea.l	d0,a3	;Unit pointer in a3
	tst.b	(Exclusive,a3)	;Check for an exclusive access violation
	beq	Open_Error
Open_UnitOK1:
	btst	#SERB_SHARED,(IO_FLAGS,a2)
	seq	(Exclusive,a3)
	movea.l	(mdu_prefs,a3),a4	;Set the "7WIRE" flag

	bclr	#SERB_7WIRE,(prefs_SERFLAGS,a4)
	btst	#SERB_7WIRE,(IO_SERFLAGS,a2)
	beq.b	2$
	bset	#SERB_7WIRE,(prefs_SERFLAGS,a4)

2$	movea.l	a2,a1	;Copy the current internal prefs into the iorequest.
	bsr	CopyPrefs
	move.l	d0,(IO_UNIT,a2)
	addq.w	#1,(LIB_OPENCNT,a6)  ;Mark us as having another opener
	addq.w	#1,(UNIT_OPENCNT,a3) ;Internal bookkeeping
	bclr	#LIBB_DELEXP,(md_Flags,a6) ;Prevent delayed expunges
	clr.b	(IO_ERROR,a2)	;no error
	move.b	#NT_REPLYMSG,(LN_TYPE,a2) ;Mark IORequest as "complete"
Open_End:
	subq.w	#1,(LIB_OPENCNT,a6) ;End of expunge protection
	movem.l	(sp)+,d2/a2-a4
	PUTDEBUG 30,<'%s/Open: Finished!'>
	rts

Open_Range_Error:
Open_Error:
	moveq	#IOERR_OPENFAIL,d0
	move.b	d0,(IO_ERROR,a2)
	move.l	d0,(IO_DEVICE,a2)    ;Trash IO_DEVICE on open failure
	PUTDEBUG 2,<'%s/Open: failed'>
	bra.b	Open_End

;Copy prefs from our device struct to an IOrequest.  Enter with IORequest
;in a1 and unit pointer in a3.  All registers are preserved.

CopyPrefs:
	movem.l	d0/a1/a4,-(sp)
	movea.l	(mdu_prefs,a3),a4
	lea	(IO_CTLCHAR,a1),a1
	move.w	#serprefs_sizeof-1,d0
1$	move.b	(a4)+,(a1)+
	dbra	d0,1$
	movem.l	(sp)+,d0/a1/a4
	rts 

;Copy prefs from an IOrequest to our device struct Enter with IORequest
;in a1 and unit pointer in a3.  All registers are preserved.

SetPrefs:
	movem.l	d0/a1/a4,-(sp)
	movea.l	(mdu_prefs,a3),a4
	lea	(IO_CTLCHAR,a1),a1
	move.w	#serprefs_sizeof-1,d0
1$	move.b	(a1)+,(a4)+
	dbra	d0,1$
	movem.l	(sp)+,d0/a1/a4
	rts 

;There are two different things that might be returned from the Close
;routine.  If the device wishes to be unloaded, then Close must return
;the segment list (as given to Init).  Otherwise close MUST return NULL.
; ( device:a6, iob:a1 )

_Close:
	movem.l	a2-a3,-(sp)
	PUTDEBUG 20,<'%s/Close: called'>
	movea.l	a1,a2
	movea.l	(IO_UNIT,a2),a3
	moveq	#-1,d0
	move.l	d0,(IO_UNIT,a2)      ;We're closed...
	move.l	d0,(IO_DEVICE,a2)    ;Customers not welcome at this IORequest!
	subq.w	#1,(UNIT_OPENCNT,a3) ;See if the unit is still in use
	bne.b	Close_Device
	bsr	ExpungeUnit

Close_Device:
	moveq	#0,d0
	subq.w	#1,(LIB_OPENCNT,a6) ;Mark us as having one fewer openers
	bne.b	Close_End	 ;See if there is anyone left with us open
	btst	#LIBB_DELEXP,(md_Flags,a6) ;See if we have a delayed expunge pending
	beq.b	Close_End
	bsr	Expunge	;Do the expunge
Close_End:
	movem.l	(sp)+,a2-a3
	PUTDEBUG 20,<'%s/Close: Finished!'>
	rts		;MUST return either zero or the SegList!

;Expunge is called by the memory allocator when the system is low on
;memory.
;
;There are two different things that might be returned from the Expunge
;routine.  If the device is no longer open then Expunge may return the
;segment list (as given to Init).  Otherwise Expunge may set the
;delayed expunge flag and return NULL.
;
;One other important note: because Expunge is called from the memory
;allocator, it may NEVER Wait() or otherwise take long time to complete.
;
; A6          - library base (scratch)
; D0-D1/A0-A1 - scratch

Expunge:
	PUTDEBUG 10,<'%s/Expunge: called'>
	movem.l	d1/d2/a5/a6,-(sp)	;Save ALL modified registers
	movea.l	a6,a5
	movea.l	(md_SysLib,a5),a6
	tst.w	(LIB_OPENCNT,a5)	;See if anyone has us open
	beq.b	1$
	bset	#LIBB_DELEXP,(md_Flags,a5)	;Set the delayed expunge flag
	moveq	#0,d0
	bra.b	Expunge_End
1$:

;Important: If it's not possible to restore the old autovector, then don't
;expunge!!
;Restore old autovector if possible
	move.l	(MyPreviousAutoVec,a5),a0
	move.l	(VectorBase,a5),a1
	cmp.l	($78,a1),a0
	beq.b	.ok
	moveq	#0,d0
	bra.b	Expunge_End
.ok:
	move.l	(OldVec,pc),($78,a1)

	move.l	(md_SegList,a5),d2 ;Store our seglist in d2
	movea.l	a5,a1	 ;Unlink from device list
	SYS	Remove	 ;Remove first (before FreeMem)

	movea.l	a5,a1	 ;Devicebase
	moveq	#0,d0
	move.w	(LIB_NEGSIZE,a5),d0
	suba.l	d0,a1	;Calculate base of functions
	add.w	(LIB_POSSIZE,a5),d0 ;Calculate size of functions + data area
	SYS	FreeMem
	move.l	d2,d0	;Set up our return value
Expunge_End:
	movem.l	(sp)+,d1/d2/a5/a6
	rts

Null	PUTDEBUG 1,<'%s/Null: called'>
	moveq	#0,d0
	rts		;The "Null" function MUST return NULL.


;This is the main unit initialization routine. It allocates memory for
;the device structure, calls SetUpUnit, then calls InitTask.

; ( d2:unit number, a3:scratch, a6:devptr )

InitUnit:
	PUTDEBUG 30,<'%s/InitUnit: called'>
	movem.l	d0/d1/a4/a2,-(sp)
	move.l	d2,d1
	mulu.w	#serprefs_sizeof,d1
	lea	(prefs_unit0,a6),a4
	adda.l	d1,a4

;Now A4 is a ptr to the prefs for this unit

	move.l	#MyDevUnit_Sizeof,d0 ;Allocate unit memory
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	AllocMem
	movea.l	(sp)+,a6
	movea.l	d0,a3
	tst.l	d0
	bne	continitunit1

;Couldn't init the unit (out of memory).

ReturnVoid:
	move.l	d2,d0	;Unit number
	lsl.l	#2,d0
	clr.l	(md_Units,a6,d0.l) ;Set unit table
	movem.l	(sp)+,d0/d1/a4/a2
	rts

BadSetup:
	bsr	KillTask
	bra.b	ReturnVoid

continitunit1:
	moveq	#0,d0	;Don't need to re-zero it
	movea.l	a3,a2
	lea	(mdu_Init,pc),a1
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	InitStruct
	movea.l	(sp)+,a6

	move.l	a5,-(sp)	;Look up DACIA base address
	lea	(basetable,pc),a0
	moveq	#0,d0
	move.b	d2,d0
	lsl.l	#2,d0
	movea.l	(0,a0,d0.w),a5 
	move.l	a5,(daciabase,a3)

	move.b	#$7f,(IER,a5)	 ;Disable DACIA interrupts

	bset	d2,(ScoreBoard,a6)
	bsr	SetUpUnit
	movea.l	(sp)+,a5
	tst.l	d0
	bne.b	BadSetup

	bsr InitTask	;Set up the two tasks for this unit
	tst.l d0
	beq.b BadSetup

;Done with InitUnit - fill in the proper md_Unit field in the device struct
;and return.
	move.l	d2,d0	;Unit number
	lsl.l	#2,d0
	move.l	a3,(md_Units,a6,d0.l) ;Set unit table
	lea	(Unit0,pc),a2
	move.l	a3,(a2,d0.l)
	movem.l	(sp)+,d0/d1/a4/a2
	PUTDEBUG 30,<'%s/InitUnit: finished! End of silence.'>
	rts

;This routine does the following:
;
;1. Allocate read buffer memory
;2. Initialize all the special MyDevUnit fields (but NOT the signals -
;   they must be allocated in the task's context)
;3. Call InitDACIA [Initialize/set-up DACIA registers (for this unit).]
;4. Install an interrupt server.
;
;Returns failure code in d0 - zero if OK, -1 if out of memory, 1 if
;unable to open timer.device, 2 if invalid parm
;
;SetUpUnit(d2:unit number, a3:unit, a6:devptr)
;AND...ptr to prefs in A4
;uses d1,a0,a1,a2,a6

SetUpUnit:
	PUTDEBUG 30,<'%s/SetUpUnit: called'>
	movem.l	d1/a0/a1/a2,-(sp)

	move.l	#65536,d0	;buffer size
	move.l	d0,(prefs_RBUFLEN,a4)

SUU:
	move.l	#MEMF_PUBLIC,d1
	EXEC	AllocMem
	tst.l	d0
	bne.b	continitunit
	moveq	#-1,d0	;Failed to allocate input buffer memory - exit.
	movem.l	(sp)+,d1/a0/a1/a2
	rts

;Initialize all the special MyDevUnit fields (but NOT the signals -
;they must be allocated in the task's context)

continitunit:
	move.l	d0,(startbuf,a3)
	clr.l	(HeadLong,a3)
	clr.l	(TailLong,a3)

	move.l	a4,(mdu_prefs,a3)
	move.l	(SysBase).w,(mdu_SysLib,a3) 
	lea	(timerport+MP_MSGLIST,a3),a0
	NEWLIST	a0	     ;Init the unit's timer MsgPort's list
	move.b	d2,(mdu_UnitNum,a3)    ;Initialize unit number
	move.l	a6,(mdu_Device,a3)     ;Initialize device pointer
	move.b	#$FF,(xstate,a3)
	move.b	#$80,(frstate,a3)

	lea	(timername,pc),a0	;Open the timer device.
	moveq	#0,d0 ;UNIT_MICROHZ
	lea	(timeriorequest,a3),a1
	moveq	#0,d1 ;no special flags
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	OpenDevice
	movea.l	(sp)+,a6
	tst.l	d0
	bne	OpenTimerFailed

;Initialize/set-up DACIA registers (for this unit).
;(according to the prefs pointed to by a4) 

	bsr	InitDACIA
	tst.l	d0
	bne	InitDACIAfailed 

;Install an interrupt server.

	bsr	NewVector
	tst.l	d0
	bne.b	EndSetUpUnit

	moveq	#0,d0 ;situation under control
	movem.l	(sp)+,d1/a0/a1/a2
	PUTDEBUG 30,<'%s/SetUpUnit: Finished!'>
	rts

InitDACIAfailed:
	moveq	#2,d0
	bra.b	EndSetUpUnit

OpenTimerFailed:
	moveq	#1,d0
EndSetUpUnit:
	move.l	d0,-(sp)
	move.l	(prefs_RBUFLEN,a4),d0
	movea.l	(startbuf,a3),a1
	EXEC	FreeMem
	move.l	(sp)+,d0
	movem.l	(sp)+,d1/a0/a1/a2
	rts

;*** end of SetUpUnit ***

;Initialize/set-up DACIA registers (for this unit).
;(according to the prefs pointed to by a4) 
;d0.b will mirror CTR, d1.b will mirror FMR
;Returns error code in d0 - zero if successful.
;uses d1,d3,d5,a0

InitDACIA:
	PUTDEBUG 30,<'%s/InitDACIA: Called.'>
	movem.l	d1/d3/d5/a0,-(sp)

;"During power-on initialization, all readable registers should be read to
; assure that the status registers are initialized."

	move.b	(ISR,a5),d0
	move.b	(CSR,a5),d0
	move.b	(RDR,a5),d0

	move.b	(frstate,a3),d0	;Set DTR* and RTS* low (assert)
	and.b	#$FC,d0	;Clear bits zero and one
	move.b	d0,(frstate,a3)
	move.b	d0,(FMR,a5)

	moveq	#0,d0
	bset	#6,d0	;Always access ACR, never CDR
	move.b	(frstate,a3),d1
  
	move.l	(prefs_BAUD,a4),d3 ;First, set proper baud rate.

	ifne	INFO_LEVEL	;If any debugging enabled at all
	move.l	d3,-(sp)
	PUTDEBUG	150,<'%s/InitDACIA: %ldbps requested.'>
	addq.l	#4,sp
	endc

	swap	d3
	tst.w	d3
	bne	InvParm
	swap	d3

;Test for (and allow) zero -- this makes Handshake happy
	tst.l	d3
	beq.b	SkipBAUD

	lea	(baudtable,pc),a0
	moveq	#15,d5 
baudloop	cmp.w	(a0)+,d3
	dbeq	d5,baudloop
	bne	InvParm
	not.b	d5
	and.b	#$0F,d5
	or.b	d5,d0    

	ifne	INFO_LEVEL
	clr.l	-(sp)
	move.b	d0,(3,sp)
	PUTDEBUG 30,<'%s/InitDACIA: Baud rate = %lx'>
	addq.l	#4,sp
	endc

SkipBAUD:
	cmpi.b	#1,(prefs_STOPBITS,a4) ;Next, set number of stop bits per character
	beq.b	onestop
	bset	#5,d0
onestop:
	move.b	d0,(CTR,a5)

;set data bits per character
	move.b	(prefs_READLEN,a4),d3
	cmp.b	(prefs_WRITELEN,a4),d3
	bne	InvParm	;We don't support different read & write char lengths
	subq.b	#5,d3
	bmi	InvParm
	cmp.b	#3,d3
	bhi	InvParm
	lsl.b	#5,d3
	and.b	#$80,d1	;bug fix (clear before OR)
	or.b	d3,d1

	btst	#SEXTB_MSPON,(prefs_EXTFLAGS+3,a4) ;Set parity
	beq.b	EvenOdd
	bset	#2,d1
	btst	#SEXTB_MARK,(prefs_EXTFLAGS+3,a4)
	bne.b	UseMark
	or.b	#24,d1	;Use space
	bra.b	NoParity

UseMark	or.b	#16,d1
	bra.b	NoParity

EvenOdd	btst	#SERB_PARTY_ON,(prefs_SERFLAGS,a4)
	beq.b	NoParity
	bset	#2,d1

	btst	#SERB_PARTY_ODD,(prefs_SERFLAGS,a4)
	bne.b	UseOdd
	or.b	#8,d1
UseOdd:
NoParity	move.b	d1,(frstate,a3)
	move.b	d1,(FMR,a5)
	moveq	#0,d0
	movem.l	(sp)+,d1/d3/d5/a0
	PUTDEBUG 30,<'%s/InitDACIA: Finished!'>
	rts

InvParm	PUTDEBUG 30,<'%s/InitDACIA: Invalid Parm!'>
	moveq	#-1,d0
	movem.l	(sp)+,d1/d3/d5/a0
	rts

;*** end of InitDACIA ***

;(this is a subroutine for InitUnit)
;This routine sets up the two tasks (one for reading, one for writing).
;Returns zero in d0.l if an error occured else a ptr to the unit.
;
;uses d1-d4 and a0-a5

InitTask:
	PUTDEBUG 30,<'%s/InitTask: called.'>
	movem.l	d1-d4/a0-a5,-(sp)
	lea	(ReadTask_Begin,pc),a5 ;Set up the read task
	lea	(mdu_rstack,a3),a0
	lea	(mdu_rtcb,a3),a1
	movea.l	a3,a2	;Read message port
	bsr.b	InitTaskStruct

	lea	(WriteTask_Begin,pc),a5 ;Set up the write task
	lea	(mdu_wstack,a3),a0
	lea	(mdu_wtcb,a3),a1
	lea	(mdu_wport,a3),a2
	move.l	a3,(TC_EXCEPTDATA,a1)
	lea	(breakexception,pc),a4
	move.l	a4,(TC_EXCEPTCODE,a1) 
	bsr.b	InitTaskStruct

	move.l	a3,d0	;Mark us as ready to go
	PUTDEBUG 30,<'%s/InitTask: ok'>

;Return zero in d0.l if an error occured, else a ptr to the unit

	movem.l	(sp)+,d1-d4/a0-a5
	rts

;Start up the unit task.  We do a trick here --we set his message port to
;PA_IGNORE until the new task has a change to set it up.  We cannot go to
;sleep here: it would be very nasty if someone else tried to open the unit
;(exec's OpenDevice has done a Forbid() for us --we depend on this to become
;single threaded).
;
;Enter with:
;a0 - ptr to low end of stack
;a1 - ptr to tcb (task control block)
;a3 - unit pointer
;a5 - starting address of task
;a2 - ptr to a (uninitialized) message port
;
;uses a0-a3 and d0,d1

InitTaskStruct:
	movem.l	d0/d1/a0-a3,-(sp)
	move.l	a0,(TC_SPLOWER,a1)	;Initialize the stack information
	lea	(MYPROCSTACKSIZE,a0),a0 ;High end of stack
	move.l	a0,(TC_SPUPPER,a1)
	move.l	a3,-(a0)	;Argument - unit ptr (send on stack)
	move.l	a0,(TC_SPREG,a1)
	move.l	a1,(MP_SIGTASK,a2)

	ifge	INFO_LEVEL-30
	move.l	a1,-(sp)
	move.l	a3,-(sp)
	PUTDEBUG 30,<'%s/InitUnit, unit= %lx, task=%lx'>
	addq.l	#8,sp
	endc

	lea	(MP_MSGLIST,a2),a0
	NEWLIST	a0	;Init the unit's MsgPort's list
	movea.l	a5,a2	;Startup the task
	lea	(-1).l,a3	;generate address error
			;if task ever "returns" (we RemTask() it
			;to get rid of it...)
	moveq	#0,d0
	PUTDEBUG 30,<'%s/About to add task'>
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	AddTask
	movea.l	(sp)+,a6
	movem.l	(sp)+,d0/d1/a0-a3
	rts

;Get rid of the unit's tasks.  We know this is safe because the unit has an
;open count of zero, so it is 'guaranteed' not in use.
;
;Kill the two tasks
; ( a3:unitptr, a6:deviceptr )
;
;uses a0,a1 and d0-d2

KillTask:
	movem.l	a0/a1/d0-d2,-(sp)
	lea	(mdu_rtcb,a3),a1
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	RemTask
	movea.l	(sp)+,a6

	lea	(mdu_wtcb,a3),a1
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	RemTask
	movea.l	(sp)+,a6

	moveq	#0,d2
	move.b	(mdu_UnitNum,a3),d2 ;Save the unit number
	bsr	FreeUnit	;Free the unit structure
	lsl.l	#2,d2
	clr.l	(md_Units,a6,d2.l)	;Clear out the unit vector in the device
	movem.l	(sp)+,a0/a1/d0-d2
	rts

; ( a3:unitptr, a6:deviceptr )
;uses a0,a1,d0,d1

FreeUnit:
	movem.l	a0/a1/d0/d1,-(sp)
	movea.l	a3,a1
	move.l	#MyDevUnit_Sizeof,d0
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	FreeMem
	movea.l	(sp)+,a6
	movem.l	(sp)+,a0/a1/d0/d1
	rts

; ( a3:unitptr, a6:deviceptr )
;
;uses a0,a1,a5,d0-d2

ExpungeUnit:
	movem.l	a0/a1/a5/d0-d2,-(sp)
	PUTDEBUG 10,<'%s/ExpungeUnit: called'>

	movea.l	(daciabase,a3),a5
	move.b	#$7f,(IER,a5)	;shut off all interrupts
	move.b	#$83,(FMR,a5)	;Deassert DTR* and RTS*

	bsr	FreeResources

	lea	(mdu_rtcb,a3),a1
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	RemTask
	movea.l	(sp)+,a6

	lea	(mdu_wtcb,a3),a1
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	RemTask
	movea.l	(sp)+,a6

	moveq	#0,d2
	move.b	(mdu_UnitNum,a3),d2 ;Save the unit number
	bsr	FreeUnit	;Free the unit structure.

	bclr	d2,(ScoreBoard,a6)
	bsr	NewVector
	lsl.l	#2,d2
	clr.l	(md_Units,a6,d2.l) ;Clear out the unit pointer in the device

	movem.l	(sp)+,a0/a1/a5/d0-d2
	rts

;This routines frees up resources specific to this driver (the other
;resources are taken care of by the skeleton).
;Be careful with this routine, so as not to pull the rug out from
;underneath the driver...
;
;If you can expunge you unit, and each unit has it's own interrupts,
;you must remember to remove its interrupt server
;
;Enter with unit ptr in a3 and device ptr in a6
;
;uses a0,a1,a4,d0,d1


FreeResources:
	PUTDEBUG 10,<'%s/FreeResources: called'>
	movem.l	a0/a1/a4/d0/d1,-(sp)
	movea.l	(startbuf,a3),a1	;Free input buffer memory
	movea.l	(mdu_prefs,a3),a4
	move.l	(prefs_RBUFLEN,a4),d0
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	FreeMem
	movea.l	(sp)+,a6

	lea	(timeriorequest,a3),a1 ;Close timer device
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	CloseDevice
	movea.l	(sp)+,a6
	movem.l	(sp)+,a0/a1/a4/d0/d1
	PUTDEBUG 10,<'%s/FreeResources: finished!'>
	rts

;Here begins the device functions
;
;Cmdtable is used to look up the address of a routine that will
;implement the device command.

cmdtable:
	dc.l   Invalid	;$00000001  ;0	CMD_INVALID
	dc.l   MyReset	;$00000002  ;1	CMD_RESET
	dc.l   Read 	;$00000004  ;2	CMD_READ
	dc.l   Write 	;$00000008  ;3	CMD_WRITE
	dc.l   Invalid	;$00000010  ;4	CMD_UPDATE (update has no meaning here)
	dc.l   MyClear	;$00000020  ;5	CMD_CLEAR
	dc.l   MyStop	;$00000040  ;6	CMD_STOP
	dc.l   Start 	;$00000080  ;7	CMD_START
	dc.l   Flush 	;$00000100  ;8	CMD_FLUSH
	dc.l   Query	;$00000200  ;9  SDCMD_QUERY
	dc.l   Break	;$00000400  ;10 SDCMD_BREAK
	dc.l   SetParams	;$00000800  ;11 SDCMD_SETPARAMS
cmdtable_end:

;This define is used to tell which commands should be handled
;immediately (on the caller's schedule).
;
;The immediate commands are Invalid, Reset, Stop, Start, Flush, Clear,
;Query, and SetParams
;
;Note that this method limits you to just 32 device specific commands,
;which may not be enough.

IMMEDIATES	EQU	%00000000000000000000101111110011
;		 --------========--------========
;		 FEDCBA9876543210FEDCBA9876543210

;BeginIO starts all incoming io.  The IO is either queued up for the
;unit task or processed immediately.
;
;BeginIO often is given the responsibility of making devices single
;threaded... so two tasks sending commands at the same time don't cause
;a problem.  Once this has been done, the command is dispatched via
;PerformIO.
;
;There are many ways to do the threading.  This example uses the
;UNITB_ACTIVE bit.  Be sure this is good enough for your device before
;using!  Any method is ok.  If immediate access can not be obtained, the
;request is queued for later processing.
;
;Some IO requests do not need single threading. These can be performed
;immediatley.
;
;IMPORTANT:
; The exec WaitIO() function uses the IORequest node type (LN_TYPE)
; as a flag.  If set to NT_MESSAGE, it assumes the request is
; still pending and will wait.  If set to NT_REPLYMSG, it assumes the
; request is finished.  It's the responsibility of the device driver
; to set the node type to NT_MESSAGE before returning to the user.
;
;Notes: This routine will look at io_command to determine which task
;to use. Break with QUEUEDBRK and Write requests go to the write
;task. Read requests (only) go to the read task. 
;Break requests without QUEUEDBRK initiate a write task exception.
;The actual break job is started, and finished, within that exception.
;At the end of the exception, the write task resumes whatever it was
;doing before the break.
;All other requests are performed immediately, i.e. within the caller's
;context.
;
;This routine uses a3,a4 (and a0/a1/d0/d1, but those do not need to be
;preserved).
; ( iob: a1, device:a6 )

BeginIO:
	ifge	INFO_LEVEL-1
	bchg.b	#1,($bfe001).l	;Blink the power LED
	endc

	ifge	INFO_LEVEL-3
	clr.l	-(sp)
	move.w	(IO_COMMAND,a1),(2,sp) ;Get entire word
	PUTDEBUG 3,<'%s/BeginIO  --  %ld'>
	addq.l	#4,sp
	endc

	move.l	a4,-(sp)
	move.l	a3,-(sp)
	andi.b	#$f,(IO_FLAGS,a1)
	move.b	#NT_MESSAGE,(LN_TYPE,a1) ;So WaitIO() is guaranteed to work
	movea.l	(IO_UNIT,a1),a3	;Bookkeeping -> what unit to play with
	move.w	(IO_COMMAND,a1),d0

;Try to do a quick read
	cmp.w	#CMD_READ,d0
	bne	.NotRead
	move.l	(mdu_prefs,a3),a4
	btst	#SERB_RAD_BOOGIE,(prefs_SERFLAGS,a4) ;Check for RAD_BOOGIE
	beq	.NoBoogie

	bsr	GetBytesInReadBuf
	cmp.l	(IO_LENGTH,a1),d0
	bcs	.NotEnoughDataInBuf

;We can do it! Transfer the data as quickly as possible...

;Uses a1,d2,d4,a2,a4,a6

;	move.w	#$0f00,$dff180

	movem.l	d2/d4/a1/a2/a4/a6,-(sp)
	move.l	(HeadLong,a3),d2
	move.l	(IO_LENGTH,a1),d4
	add.w	d4,(Head,a3)
	move.l	(IO_DATA,a1),a4
	move.l	(startbuf,a3),a2
	move.l	(mdu_SysLib,a3),a6

	move.l	#65536,d0
	sub.l	d2,d0
	cmp.l	d0,d4
	bls.b	.UseIOLength

;Need 2 copy operations
	sub.l	d0,d4
	move.l	a4,a1
	add.l	d0,a4
	lea	(a2,d2.l),a0
	SYS	CopyMem
	move.l	d4,d0
	move.l	a4,a1
	move.l	a2,a0
	SYS	CopyMem
	bra.b	.ReadQuickEnd

.UseIOLength:
	move.l	d4,d0
	move.l	a4,a1
	lea	(a2,d2.l),a0
	SYS	CopyMem
.ReadQuickEnd:
	movem.l	(sp)+,d2/d4/a1/a2/a4/a6

	clr.b	(IO_ERROR,a1)	;No error
	move.l	(IO_LENGTH,a1),(IO_ACTUAL,a1)

	btst	#IOB_QUICK,(IO_FLAGS,a1) 
	bne.b	.TermEnd

	push	a6
	move.l	(4).w,a6
	SYS	ReplyMsg
	pop	a6

.TermEnd:
	move.l	(sp)+,a3
	move.l	(sp)+,a4
	rts


.NoBoogie:

;	move.w	#$00f0,$dff180

.NotEnoughDataInBuf:
.NotRead:

;Do a range check & make sure bad requests are rejected

	move.w	(IO_COMMAND,a1),d0
	cmp.w	#MYDEV_END,d0	;Compare all 16 bits
	bhi	BeginIO_NoCmd	;no, reject it.  (bcc=bhs - unsigned)

;Process all immediate commands no matter what

	move.l	#IMMEDIATES,d1
	Disable	a0	;<-- Ick, nasty stuff, but needed here.
	btst	d0,d1
	bne	BeginIO_Immediate

;See if the unit is STOPPED.  If so, queue the msg.

	btst	#MDUB_STOPPED,(MDU_FLAGS,a3)
	bne	BeginIO_QueueMsg

;This is not an immediate command.  See if the device is busy.  If the device
;is not, do the command on the user schedule.  Else fire up the task.  This
;type of arbitration is essential for a device to reliably work with shared
;hardware.
;
;REMEMBER: Never Wait() on the user's schedule in BeginIO()!  The only
;exception is when the user has indicated it is ok by setting the "quick" bit.
;
;We need to queue the device.  mark us as needing task attention.  Clear the
;quick flag
;
;Note: We handle read, write, and break requests seperately and differently.

BeginIO_QueueMsg:
	bclr	#IOB_QUICK,(IO_FLAGS,a1) ;We did NOT complete this quickly
	cmpi.w	#CMD_READ,(IO_COMMAND,a1)
	bne.b	notread

	bset	#UNITB_INREADTASK,(UNIT_FLAGS,a3)
	Enable	a0

	ifge	INFO_LEVEL-250
	move.l	a1,-(sp)
	move.l	a3,-(sp)
	PUTDEBUG 250,<'%s/PutMsg: Port=%lx Message=%lx'>
	addq.l	#8,sp
	endc

	movea.l	a3,a0
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	PutMsg	;Port=a0, Message=a1
	movea.l	(sp)+,a6
	bra	BeginIO_End	;Return to caller before completing


notread	cmpi.w	#CMD_WRITE,(IO_COMMAND,a1)
	bne.b	handlebreak

queuewrt	bset	#UNITB_INWRITETASK,(UNIT_FLAGS,a3)
	Enable	a0
	lea	(mdu_wport,a3),a0

	ifge	INFO_LEVEL-250
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	PUTDEBUG 250,<'%s/PutMsg: Port=%lx Message=%lx'>
	addq.l	#8,sp
	endc

	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	PutMsg	;Port=a0, Message=a1
	movea.l	(sp)+,a6
	bra	BeginIO_End	;Return to caller before completing

handlebreak:
	btst	#SERB_QUEUEDBRK,(IO_SERFLAGS,a1)
	bne.b	queuewrt	;Handle just like a write request

;This is the tricky case. We initiate the break immediately.  To do this we
;cleverly (?) use the under-documented power of task exceptions.

	btst	#UNITB_INBREAK,(UNIT_FLAGS,a3)
	bne	breakout
	bset	#UNITB_BREAKACTIVE,(UNIT_FLAGS,a3)
	Forbid
	bset	#ioflagsB_Active,(IO_FLAGS,a1)
	move.l	a1,(breakiorequest,a3)
	Permit
	move.l	(breaksig,a3),d0
	lea	(mdu_wtcb,a3),a1
	EXEC	Signal
	Enable	a0
	bra.b	BeginIO_End 

;Do it on the schedule of the calling process

BeginIO_Immediate:
	Enable	a0
	bsr	PerformIO

BeginIO_End:
	PUTDEBUG 200,<'%s/BeginIO_End'>
	movea.l	(sp)+,a3
	move.l	(sp)+,a4
	rts

BeginIO_NoCmd:
	PUTDEBUG 200,<'%s/BeginIO_NoCmd!'>
	move.b	#IOERR_NOCMD,(IO_ERROR,a1)
	bra.b	BeginIO_End

breakout:
	Enable	a0
	bsr	TermIO
	bra	BeginIO_End

;PerformIO actually dispatches an io request.  It might be called from the
;task, or directly from BeginIO (thus on the callers's schedule)
;
;It expects a3 to already have the unit pointer in it.  a6 has the device
;pointer (as always).  a1 has the io request.  Bounds checking has already
;been done on the I/O Request.
;
;This routine itself uses d0,a0,a4,a5. The command it calls may choose
;to use any or all registers.
; ( iob:a1, unitptr:a3, devptr:a6 )

PerformIO:
	ifge	INFO_LEVEL-150
	clr.l	-(sp)
	move.w	(IO_COMMAND,a1),(2,sp)  ;Get entire word
	PUTDEBUG 150,<'%s/PerformIO -- %ld'>
	addq.l	#4,sp
	endc

	movem.l	d0/a0/a4/a5,-(sp)
	movea.l	(mdu_prefs,a3),a4
	movea.l	(daciabase,a3),a5
	moveq	#0,d0
	move.b	d0,(IO_ERROR,a1)     ; No error so far
	move.b	(IO_COMMAND+1,a1),d0 ;Look only at low byte
	lsl.w	#2,d0	   ; Multiply by 4 to get table offset
	lea	(cmdtable,pc),a0
	movea.l	(0,a0,d0.w),a0

	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(a0)    ;iob:a1  unit:a3  devprt:a6
	movem.l	(sp)+,d0-d7/a0-a6
	bsr.b	TermIO
	movem.l	(sp)+,d0/a0/a4/a5
	PUTDEBUG 15,<'%s/PerformIO -- Finished!'>
	rts

;TermIO sends the IO request back to the user.  It knows not to mark
;the device as inactive if this was an immediate request or if the
;request was started from the server task.
;
; ( iob:a1, unitptr:a3 )
;uses d0/d1/a0/a1

TermIO:
	movem.l	d0/d1/a0/a1,-(sp)
	PUTDEBUG 160,<'%s/TermIO'>
	move.w	(IO_COMMAND,a1),d0
	move.w	#IMMEDIATES,d1
	btst	d0,d1
	bne.b	TermIO_Immediate	;IO was immediate, don't do task stuff...

	cmpi.w	#CMD_READ,(IO_COMMAND,a1)
	bne.b	wrtterm

;We may need to turn the active bit off.

	btst	#UNITB_INREADTASK,(UNIT_FLAGS,a3)
	bne.b	TermIO_Immediate	;IO came from task, don't clear ACTIVE...

;The task does not have more work to do

	bclr	#UNITB_READACTIVE,(UNIT_FLAGS,a3)
	bra.b	TermIO_Immediate

;We may need to turn the active bit off.

wrtterm	btst	#UNITB_INWRITETASK,(UNIT_FLAGS,a3)
	bne.b	TermIO_Immediate	;IO came from task, don't clear ACTIVE...

;The task does not have more work to do

	bclr	#UNITB_WRITEACTIVE,(UNIT_FLAGS,a3)


;If the quick bit is still set then we don't need to reply
;- msg - just return to the user.

TermIO_Immediate:
	btst	#IOB_QUICK,(IO_FLAGS,a1)
	bne.b	TermIO_End
	EXEC	ReplyMsg	;a1-message
			;ReplyMsg sets the LN_TYPE to NT_REPLYMSG
TermIO_End:
	movem.l	(sp)+,d0/d1/a0/a1
	rts

;Here begins the functions that implement the device commands
;all functions are called with:
;  a1 -- a pointer to the io request block
;  a3 -- a pointer to the unit
;  a4 -- a pointer to prefs
;  a5 -- a pointer to the unit hardware
;  a6 -- a pointer to the device
;
;Commands that conflict with 68000 instructions have a "My" prepended to them.

;Read: The handshaking lines don't serve any purpose when reading (except
;perhaps to say "shut up" if an exceptional condition occurs).
;
;d5 is used to count the number of bytes transferred

Read:
	moveq	#0,d5
	move.l	(IO_LENGTH,a1),d6
	movea.l	(IO_DATA,a1),a2
	move.l	(readsig,a3),d4
	add.l	(readabortsig,a3),d4

	ifne	INFO_LEVEL	;If any debugging enabled at all
	move.l	d6,-(sp)
	PUTDEBUG 150,<'%s/Read entered -- %ld bytes requested.'>
	addq.l	#4,sp
	endc
 
	bra.b	ReadEntry

readloop:
	move.l	d4,d0
	bset	#MDUB_WaitingForChar,(MDU_FLAGS,a3)
	EXEC	Wait	;Wait for one or more bytes to come in
	and.l	(readabortsig,a3),d0
	bne	readabort
NoErrorAtAll:
	PUTDEBUG 150,<'%s/Read: One or more bytes came in.'>

ReadEntry:
	bsr	GetBytesInReadBuf

	ifne	INFO_LEVEL	;If any debugging enabled at all
	move.l	d0,-(sp)
	PUTDEBUG 150,<'%s/Read: In fact, %ld bytes came in.'>
	addq.l	#4,sp
	endc

	tst.l	d0
	beq	readloop
	cmp.l	d0,d6
	bls.b	AllDone	;Branch if d6 <= d0
	sub.l	d0,d6
	bsr	DumpReadBuf	;Get all the bytes we can
	beq	readloop  
	bra.b	endread	;Go if TermArray caused early exit
 
;The number of bytes in the read buffer equals or exceeds the number of
;bytes the user wants.

AllDone	PUTDEBUG 150,<'%s/Read: AllDone'>
	move.l	d6,d0
	bsr	DumpReadBuf	;Dump d0 bytes of the read buffer into the user's buffer
endread	PUTDEBUG 150,<'%s/Read: Finished!'>
	bclr	#MDUB_V,(MDU_FLAGS,a3)
	beq.b	NoOverflow
	move.b	#SerErr_BufOverflow,(IO_ERROR,a1)
NoOverflow:
	move.l	d5,(IO_ACTUAL,a1)
	rts		;Done with read

;Something exceptional happened.  An informative error code should be
;returned.  first, check for error conditions...  Note that the serial.device
;standard does not provide a way to inform the caller of simultaneous error
;conditions.

readabort:
	PUTDEBUG 150,<'%s/readabort: Something exceptional happened.'>
	Disable
	move.b	(ISRcopy,a3),d2
	move.b	(CSRcopy,a3),d3
	Enable
	btst	#ISRB_PAR,d2
	beq.b	notpar

	move.b	#SerErr_ParityErr,(IO_ERROR,a1) ;parity error
	bra	endread

notpar	btst	#1,d2	;Check for frame err, overrun, & break
	beq	endread	;We infer that an abort has been issued

;This is a check for framing error....it seems to cause problems with
;auto-baud algorithms, so it's commented out for this release.

;	btst	#CSRB_FE,d3	;Probe further...
;	beq.b	noframe

;	move.b	#SerErr_LineErr,(IO_ERROR,a1) ;Framing Error
;	bra	endread

noframe	btst	#CSRB_RBRK,d3
	beq	NoErrorAtAll

;Note that we ignore receive overrun errors. Since there is no error
;code for it, I assume this is what serial.device does too.

	move.b	#SerErr_DetectedBreak,(IO_ERROR,a1) ;Break
	bra	endread 

;d5 is used to count the number of bytes transferred

Write:
	moveq	#0,d5
	move.l	(IO_LENGTH,a1),d6

	ifne	INFO_LEVEL	;If any debugging enabled at all
	move.l	d6,-(sp)
	PUTDEBUG 150,<'%s/Write entered -- %ld bytes requested.'>
	addq.l	#4,sp
	endc

	movea.l	(IO_DATA,a1),a2
	move.l	(tdresig,a3),d4
	add.l	(writeabortsig,a3),d4
	btst	#SERB_7WIRE,(prefs_SERFLAGS,a4)
	bne.b	write.hand
   
;Safety check: if CTS* is not asserted, return with an error code. This
;usually occurs when the port is not connected to anything.
;Interesting note: Commodore connects CTS to an 8520 on their
;serial I/O card, which uses 7 6551s, to avoid this problem.

;Enter with the number of bytes to transmit in d6
;Enter with a pointer to the user's data in a2

write.nohand:
	btst	#CSRB_CTSL,(CSR,a5)
	bne.b	not_connected

	bsr.b	transmit
	subq.l	#1,d6
	bne.b	write.nohand 
endwrite:
	move.l	d5,(IO_ACTUAL,a1)
	rts

not_connected:
	move.b	#SerErr_LineErr,(IO_ERROR,a1)
	bra.b	endwrite

;Enter with the number of bytes to transmit in d6
;Enter with a pointer to the user's data in a2

write.hand:
write.hand.loop:

;The 65C52 halts any transmission until CTS* is asserted, so no code
;is involved. This can also be a curse if you don't desire handshaking.

writehandcont:
	bsr.b	transmit	;Transmit a byte
	subq.l	#1,d6
	bne.b	write.hand.loop
aborthand:
	bra.b	endwrite

;*** Subroutine for the write routines ***
;
;Returns 1 in d6 if aborted.

transmit:
	btst	#ISRB_TDRE,(ISR,a5) ;test TDRE
	bne	oktosend	;If set, we can load up the transmit reg immediately
	PUTDEBUG	150,<'%s/Transmit: Entered.'>
	ori.b	#WRITEINTMASK,(IERstate,a3) 
	move.b	#WRITEINT,(IER,a5)
	move.l	d4,d0
	EXEC	Wait	;Wait for TDRE to be set
	and.l	(writeabortsig,a3),d0
	bne	aborttransmit
	PUTDEBUG	150,<'%s/Transmit: TDRE signal received.'>
	bra	transmit	;Just to be sure

oktosend:
	btst	#SERB_XDISABLED,(prefs_SERFLAGS,a4) ;Handle xoff, if requested
	bne.b	doit
txs:
	tst.b	(xstate,a3)
	bne.b	doit

	PUTDEBUG	5,<'%s/Transmit: Waiting for XON!'>
	move.l	(xonsig,a3),d0
	add.l	(writeabortsig,a3),d0
	EXEC	Wait	;Wait for an x-on signal before sending
	and.l	(writeabortsig,a3),d0
	bne.b	aborttransmit
	bra.b	txs

doit:
	PUTDEBUG	5,<'%s/Transmit: Received XON!'>
	tst.l	d6
	bmi.b	termzero
doit1:
	move.b	(a2)+,(TDR,a5)
	addq.l	#1,d5
	rts

termzero:
	tst.b	(a2)
	bne.b	doit1
aborttransmit:
	moveq	#1,d6
	rts
 
;*** end of write routines ***

;*** Subroutines for the read routine ***
;
;Return with the number of bytes in the read buffer in d0

GetBytesInReadBuf:
	move.l	d1,-(sp)

	movem.l	(HeadLong,a3),d0/d1	;load HeadLong/TailLong

	ifne	INFO_LEVEL	;If any debugging enabled at all
	move.l	d0,-(sp)
	PUTDEBUG	150,<'%s/GetBytesInReadBuf: HeadLong=%ld'>
	addq.l	#4,sp
	endc

	ifne	INFO_LEVEL	;If any debugging enabled at all
	move.l	d1,-(sp)
	PUTDEBUG	150,<'%s/GetBytesInReadBuf: TailLong=%ld'>
	addq.l	#4,sp
	endc


	sub.l	d0,d1
	bpl.b	.skipadd
	add.l	#65536,d1
.skipadd:
	move.l	d1,d0

	move.l	(sp)+,d1
	rts

;Enter with number of bytes to read in d0
;Enter with a pointer to a dump buffer in a2
;the pointer in a2 is updated to reflect the current position
;
;This routine uses as scratch: a0,a6,d0,d1,d3,d6,d7
;and updates the following: d5,a2
;Returns with zero flag set if all is OK, or zero cleared if a TermArray
;match was found.

DumpReadBuf:
	move.l	(HeadLong,a3),d1
	add.w	d0,(Head,a3)
	move.l	(StartBuf,a3),a0

;Note that only the buffer pointers are protected. The main copy loop
;(below) could, however, return somewhat incoherent data if the buffer
;happens to overflow.

	btst	#SERB_EOFMODE,(IO_SERFLAGS,a1)
	bne	eofdump 

drb.loop:
	move.b	(a0,d1.l),d6
	bsr.b	xcode
	move.b	d6,(a2)+
	addq.l	#1,d5
	addq.w	#1,d1	;increment 16-bit head ptr
	subq.l	#1,d0
	bne.b	drb.loop 
	rts


;Check for xon/xoff

xcode	ifne	INFO_LEVEL
	move.l	(prefs_CTLCHAR,a4),-(sp)
	PUTDEBUG 5,<'%s/XCODE: prefs_CTLCHAR = %lx'>
	addq.l	#4,sp
	endc

	ifne	INFO_LEVEL
	clr.l	-(sp)
	move.b	d6,(3,sp)
	PUTDEBUG 5,<'%s/XCODE: Current char = %lx'>
	addq.l	#4,sp
	endc

	cmp.b	(prefs_CTLCHAR,a4),d6	;Xon check
	beq.b	setxon
	cmp.b	(prefs_CTLCHAR+1,a4),d6	;Xoff check
	beq.b	setxoff
	rts

setxon	PUTDEBUG 5,<'%s/XCODE: XON!'>
	tst.b	(xstate,a3)
	bne.b	sxoq	;If already on, don't signal!
	st	(xstate,a3)
	movem.l	d0/d1/a0/a1/a6,-(sp)
	move.l	(xonsig,a3),d0
	lea	(mdu_wtcb,a3),a1
	movea.l	(SysBase).w,a6
	jsr	(_LVOSignal,a6)
	movem.l	(sp)+,d0/d1/a0/a1/a6
sxoq	rts

setxoff	PUTDEBUG 5,<'%s/XCODE: XOFF!'>
	clr.b	(xstate,a3)
	rts

eofdump:
eofdumploop:
	moveq	#7,d7
	lea	(prefs_TERMARRAY,a4),a6
	move.b	(a0,d1.l),d6
	bsr	xcode
..	cmp.b	(a6)+,d6
	dbcc	d7,..eofcmploop
	beq.b	termread    
	move.b	d6,(a2)+
	addq.l	#1,d5
	addq.w	#1,d1
	subq.l	#1,d0
	bne.b	eofdumploop 
	rts

termread:
	moveq	#-1,d0
	rts

;This routine handles queued breaks. Non-queued breaks are handled by an
;exception (which uses similar but not identical code).

Break:
	PUTDEBUG 5,<'%s/Break: called'>
	bset	#UNITB_INBREAK,(UNIT_FLAGS,a3)
	move.b	#2,(ACR,a5) ;start break
	lea	(timeriorequest,a3),a1
	move.w	#TR_ADDREQUEST,(IO_COMMAND,a1)
	clr.l	(TV_SECS,a1)
	move.l	(prefs_BRKTIME,a4),d0
	ori.b	#$FF,d0	;To avoid the V33/V34 bug

	ifne	INFO_LEVEL	;If any debugging enabled at all
	move.l	d0,-(sp)
	PUTDEBUG 5,<'%s/Break: TV_MICRO=%ld'>
	addq.l	#4,sp
	endc

	move.l	d0,(TV_MICRO,a1)
	movea.l	(MN_REPLYPORT,a1),a0
	move.b	(MP_SIGBIT,a0),d2
	EXEC	SendIO
	moveq	#0,d0
	bset	d2,d0
	add.l	(writeabortsig,a3),d0

	PUTDEBUG 5,<'%s/Break: Waiting...'>

	EXEC	Wait
	and.l	(writeabortsig,a3),d0
	beq.b	breakOK1

	PUTDEBUG 5,<'%s/Break: Aborted!'>

	EXEC	AbortIO	;The break was aborted. Clean up.
	EXEC	WaitIO 
 
breakOK1:
	move.b	#0,(ACR,a5) ;stop the break
	bclr	#UNITB_INBREAK,(UNIT_FLAGS,a3)

	PUTDEBUG 5,<'%s/Break: Finished!'>
	rts

;AbortIO() is a REQUEST to "hurry up" processing of an IORequest.
;If the IORequest was already complete, nothing happens (if an IORequest
;is quick or LN_TYPE=NT_REPLYMSG, the IORequest is complete).
;The message must be replied with ReplyMsg(), as normal.
;
;Note that AbortIO is called directly, not via BeginIO/PerformIO.
;The only other direct functions are Open, Close, Expunge, and of course
;BeginIO.
;
; ( iob: a1, device:a6 )
;returns an error code in d0 - zero if successful.
;If sucessful, AbortIO returns IOERR_ABORTED in IO_ERROR and sets bit
;5 of IO_FLAGS.
;
;This routine uses d0/d1/a0, but they do not need to be saved.

AbortIO:
	PUTDEBUG 5,<'%s/AbortIO: called'>
	Forbid
	move.l	a3,-(sp)
	move.b	#IOERR_ABORTED,(IO_ERROR,a1) ;We always say we succeed(ed)
	bset	#5,(IO_FLAGS,a1)
	cmpi.b	#NT_REPLYMSG,(LN_TYPE,a1)	;Already complete?
	beq.b	complete

;Check to see whether or not the IORequest is being processed 

	btst	#ioflagsB_Active,(IO_FLAGS,a1)
	bne.b	inprogress
	bset	#ioflagsB_Ignore,(IO_FLAGS,a1)

complete:
	Permit
	move.l	(sp)+,a3
	moveq	#0,d0
	PUTDEBUG 5,<'%s/AbortIO: Finished!'>
	rts

inprogress:
	movea.l	(IO_UNIT,a1),a3	;IO is in progress - abort it.
	cmpi.w	#CMD_READ,(IO_COMMAND,a1)
	bne	ip1
	move.l	(readabortsig,a3),d0
	lea	(mdu_rtcb,a3),a1
ip0	EXEC	Signal
	bra.b	complete

ip1	cmpi.w	#CMD_WRITE,(IO_COMMAND,a1)
	bne.b	ip2
ip3	move.l	(writeabortsig,a3),d0
	lea	(mdu_wtcb,a3),a1
	bra.b	ip0

;The break command is handled here.
;We use the same abort signal (as write), so handle just as with write.

ip2	bra.b ip3

Invalid	move.b  #IOERR_NOCMD,(IO_ERROR,a1)
	rts

;Clear invalidates all internal buffers.
;
; a1 -- a pointer to the io request block
; a3 -- a pointer to the unit
; a4 -- a pointer to prefs
; a5 -- a pointer to the unit hardware
; a6 -- a pointer to the device

MyClear:
	moveq	#0,d0
	moveq	#0,d1
	movem.l	d0/d1,(HeadLong,a3)
	rts

; a1 -- a pointer to the io request block
; a3 -- a pointer to the unit
; a4 -- a pointer to prefs
; a5 -- a pointer to the unit hardware
; a6 -- a pointer to the device
 
MyReset:
	PUTDEBUG 30,<'%s/MyReset: called'>
	Forbid
	move.b	(IERstate,a3),d7
	clr.b	(IERstate,a3)
	move.b	#$7f,(IER,a5)	;Disable ACIA interrupts
	bsr	Flush	;Flush pending requests

;Abort current IO, if any IO is indeed occuring

	move.l	a1,-(sp)
	btst	#UNITB_BREAKACTIVE,(UNIT_FLAGS,a3)
	beq	NoBreakActive
	movea.l	(breakiorequest,a3),a1
	bsr	AbortIO

NoBreakActive:
	btst	#UNITB_WRITEACTIVE,(UNIT_FLAGS,a3)
	beq	WriteNotActive
	movea.l	(WriteRequestPtr,a3),a1
	bsr	AbortIO

WriteNotActive:
	btst	#UNITB_READACTIVE,(UNIT_FLAGS,a3)
	beq	NothingActive
	movea.l	(ReadRequestPtr,a3),a1
	bsr	AbortIO

NothingActive:
	movea.l	(sp)+,a1 
	bsr	SetDefaultPrefs
	bsr	CopyPrefs  
	bsr	FreeResources
	bsr	SetUpUnit

	tst.l	d0	;Check for a possible error condition
	bmi.b	OutOfMem
	subq.l	#1,d0
	beq.b	TimerError
	subq.l	#1,d0
	beq.b	ParamError
 
	move.b	d7,(IERstate,a3)	;Enable DACIA interrupts again
	bset	#7,d7
	move.b	d7,(IER,a5)
	Permit
	clr.l	(IO_ACTUAL,a1)
	PUTDEBUG 30,<'%s/MyReset: Finished!'>
	rts

ParamError:
	move.b	#SerErr_InvParam,(IO_ERROR,a1)
	bra.b	MyResetFailed

TimerError:
	move.b	#SerErr_TimerErr,(IO_ERROR,a1)
	bra.b	MyResetFailed

OutOfMem:
	move.b	#SerErr_BufErr,(IO_ERROR,a1)
MyResetFailed:
	Permit
	clr.l	(IO_ACTUAL,a1)
	PUTDEBUG 30,<'%s/MyReset: Error!'>
	rts

; a1 -- a pointer to the io request block
; a3 -- a pointer to the unit
; a4 -- a pointer to prefs
; a5 -- a pointer to the unit hardware
; a6 -- a pointer to the device
;
;Return number of chars in buffer in IO_ACTUAL
;Fill in IO_STATUS

Query:
	PUTDEBUG 30,<'%s/Query: called.'>
	bsr	GetBytesInReadBuf
	move.l	d0,(IO_ACTUAL,a1)

	ifne	INFO_LEVEL  ;If any debugging enabled at all
	move.l	d0,-(sp)
	PUTDEBUG 30,<'%s/Query: %ld bytes in buf.'>
	move.l	(sp)+,d0
	endc

	moveq	#0,d0 ;d0 will mirror IO_STATUS
	move.b	(CSR,a5),d1
	btst	#0,d1
	beq.b	Q1
	bset	#6,d0
Q1	btst	#1,d0
	beq.b	Q2
	bset	#7,d0
Q2	btst	#3,d1
	beq.b	Q3
	bset	#3,d0
Q3	btst	#4,d1
	beq.b	Q4
	bset	#5,d0	;carrier detect
Q4	btst	#5,d1
	beq.b	Q5
	bset	#4,d0
Q5	btst	#UNITB_BREAKACTIVE,(UNIT_FLAGS,a3)
	beq.b	NB
	bset	#9,d0
NB	btst	#UNITB_INBREAK,(UNIT_FLAGS,a3)
	beq.b	NB1
	bset	#9,d0
NB1	btst	#2,d1
	beq.b	NRB
	bset	#10,d0
NRB	tst.b	(xstate,a3)
	bne.b	xIsOn
	bset	#11,d0
xIsOn	move.w	d0,(IO_STATUS,a1)
	rts

; a1 -- a pointer to the io request block
; a3 -- a pointer to the unit
; a4 -- a pointer to prefs
; a5 -- a pointer to the unit hardware
; a6 -- a pointer to the device

SetParams:
	bclr	#SERB_XDISABLED,(prefs_SERFLAGS,a4)	;enable
	btst	#SERB_XDISABLED,(IO_SERFLAGS,a1)
	beq.b	SetP1
	bset	#SERB_XDISABLED,(prefs_SERFLAGS,a4)
	st	(xstate,a3)	;set to X-ON state
SetP1:

;Now check to see whether the device is busy, i.e. any current or pending requests.

SetP2	Forbid
	move.b	(UNIT_FLAGS,a3),d0
	and.b	#$3c,d0 ;anything going on at the moment?
	bne	DevBusy
	lea	($14,a3),a0	;Read port - anything there?
	movea.l	(a0),a2
	tst.l	(a2)
	bne	DevBusy
	lea	(mdu_wport+$14,a3),a0 ;Write port - anything there?
	movea.l	(a0),a2
	tst.l	(a2)
	bne	DevBusy

;Ok, the device is not busy. Set all params.

	bsr	SetPrefs	;First copy the data
	move.l	#65536,(prefs_RBUFLEN,a4)

;If boogie is set, it implies a few other things...

	btst	#SERB_RAD_BOOGIE,(IO_SERFLAGS,a1) ;Check for RAD_BOOGIE
	beq.b	.SkipBoogie
	bclr	#SEXTB_MSPON,(prefs_EXTFLAGS+3,a4)
	bclr	#SERB_PARTY_ON,(prefs_SERFLAGS,a4)
	bset	#SERB_XDISABLED,(prefs_SERFLAGS,a4)
	move.b	#8,(prefs_READLEN,a4)
	move.b	#8,(prefs_WRITELEN,a4)
	bra.b	.SkipNext
.SkipBoogie:

;The boogie flag is not set...but maybe it should be...
	btst	#SERB_XDISABLED,(prefs_SERFLAGS,a4)
	beq.b	.nochance
	btst	#SERB_EOFMODE,(prefs_SERFLAGS,a4)
	bne.b	.nochance
	bset	#SERB_RAD_BOOGIE,(prefs_SERFLAGS,a4) ;Set RAD_BOOGIE !

.nochance:
.SkipNext:
	bsr	InitDACIA	;Then set up the chip 
	tst.l	d0
	bne	PInvP

SPLx	Permit
	rts

PInvP	move.b	#SerErr_InvParam,(IO_ERROR,a1)
	bra.b	SPLx

DevBusy	Permit
	move.b	#SerErr_DevBusy,(IO_ERROR,a1)
	rts

;The Stop command stop all future io requests from being processed until a
;Start command is received. The Stop command is NOT stackable: e.g. no matter
;how many stops have been issued, it only takes one Start to restart
;processing.

MyStop:
	PUTDEBUG 30,<'%s/MyStop: called'>
	bset	#MDUB_STOPPED,(MDU_FLAGS,a3)
	rts

Start:
	PUTDEBUG 30,<'%s/Start: called'>
	bsr.b	InternalStart
	rts

;[A3=unit A6=device]

InternalStart:
	PUTDEBUG 30,<'%s/InternalStart: called'>
	movea.l	a1,a2

;Turn processing back on
	bclr	#MDUB_STOPPED,(MDU_FLAGS,a3)

;Kick the tasks to start them moving

	move.b	(MP_SIGBIT,a3),d1	;First the read task...
	moveq	#0,d0
	bset	d1,d0	;Prepared signal mask
	movea.l	(MP_SIGTASK,a3),a1 ;FIXED: marco-task to signal
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	Signal	;FIXED: marco-a6 not a3
	movea.l	(sp)+,a6

	movea.l	a2,a1	;Then the write task
	lea	(mdu_wport,a3),a0
	move.b	(MP_SIGBIT,a0),d1
	moveq	#0,d0
	bset	d1,d0	;Prepared signal mask
	movea.l	(MP_SIGTASK,a0),a1 ;FIXED: marco-task to signal
	move.l	a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	SYS	Signal	;FIXED: marco-a6 not a3
	movea.l	(sp)+,a6
	PUTDEBUG 30,<'%s/InternalStart: Finished!'>
	rts

;Flush pulls all I/O requests off the queue and sends them back.  We must be
;careful not to destroy work in progress, and also that we do not let some io
;requests slip by.
;
;Some funny magic goes on with the STOPPED bit in here.  Stop is defined as
;not being reentrant.  We therefore save the old state of the bit and then
;restore it later.  This keeps us from needing to DISABLE in flush.  It also
;fails miserably if someone does a start in the middle of a flush. (A
;semaphore might help...)


Flush:
	PUTDEBUG 30,<'%s/Flush: called'>
	movem.l	d2/a1/a6,-(sp)
	movea.l	(md_SysLib,a6),a6
	bset	#MDUB_STOPPED,(MDU_FLAGS,a3)
	sne	d2

ReadFlush_Loop:
	movea.l	a3,a0
	SYS	GetMsg	;Steal messages from task's port
	tst.l	d0
	beq.b	WriteFlush_Loop

	movea.l	d0,a1
	move.b	#IOERR_ABORTED,(IO_ERROR,a1)
	SYS	ReplyMsg
	bra.b	ReadFlush_Loop

WriteFlush_Loop:
	lea	(mdu_wport,a3),a0
	SYS	GetMsg	;Steal messages from task's port
	tst.l	d0
	beq.b	Flush_End

	movea.l	d0,a1
	move.b	#IOERR_ABORTED,(IO_ERROR,a1)
	SYS	ReplyMsg
	bra.b	WriteFlush_Loop

Flush_End:
	move.l	d2,d0
	movem.l	(sp)+,d2/a1/a6
	tst.b	d0
	bne.b	1$
	bsr	InternalStart
1$	PUTDEBUG 30,<'%s/Flush: Finished!'>
	rts

;Here begins the task related routines
;
;A Task is provided so that queued requests may be processed at
;a later time.  This is not very justifiable for a ram disk, but
;is very useful for "real" hardware devices.  Take care with
;your arbitration of shared hardware with all the multitasking
;programs that might call you at once.
;
; Register Usage
; ==============
; a3 -- unit pointer
; a6 -- syslib pointer
; a5 -- device pointer
; a4 -- task (NOT process) pointer
; d7 -- wait mask
;----------------------------------------------------------------------
;
;Note: Signals must be allocated within this (the task's) context!
;The task is responsible for enabling the right DACIA interrupts...AFTER
;it has done its setup (like allocating signals).
;
;NOTE: We actually have two tasks, each with their own separate
;      code (but shared data). First comes the read task...:

	cnop	0,4     ;Long word align

ReadTask_Begin:
	PUTDEBUG 35,<'%s/ReadTask_Begin'>
	movea.l	(SysBase).w,a6

;Grab the arguments passed down from our parent

	movea.l	(4,sp),a3	;Unit pointer
	movea.l	(mdu_Device,a3),a5	;Point to device structure

	lea	(readsig,a3),a2
	moveq	#1,d6	;Number of signals to allocate-1
ReadSigLoop:
	moveq	#-1,d0	;-1 is any signal at all
	SYS	AllocSignal	;Allocate signals for I/O interrupts
	moveq	#0,d7	;Convert bit number signal mask
	bset	d0,d7
	move.l	d7,(a2)+	;Save in unit structure
	dbra	d6,ReadSigLoop

	moveq	#-1,d0	;-1 is any signal at all
	SYS	AllocSignal	;Allocate a signal
	move.b	d0,(MP_SIGBIT,a3)
	move.b	#PA_SIGNAL,(MP_FLAGS,a3) ;Make message port "live"

;Change the bit number into a mask, and save in d7

	moveq	#0,d7	;Clear D7
	bset	d0,d7

	ifge	INFO_LEVEL-40
	move.l	($114,a6),-(sp)
	move.l	a5,-(sp)
	move.l	a3,-(sp)
	move.l	d0,-(sp)
	PUTDEBUG 40,<'%s/ReadTask -- Signal=%ld, Unit=%lx Device=%lx Task=%lx'>
	adda.l	#4*4,sp
	endc

;Enable read-related ACIA interrupts

	move.l	a5,-(sp)
	movea.l	(daciabase,a3),a5
	ori.b	#READINTMASK,(IERstate,a3)
	move.b	#READINT,(IER,a5)
	movea.l	(sp)+,a5
	bra.b	ReadTask_StartHere

;OK, kids, we are done with initialization.  We now can start the main loop
;of the driver.  It goes like this.  Because we had the port marked PA_IGNORE
;for a while (in InitUnit) we jump to the getmsg code on entry.  (The first
;message will probably be posted BEFORE our task gets a chance to run).
;  wait for a message
;  lock the device
;  get a message.  If no message, unlock device and loop
;  dispatch the message
;  loop back to get a message

;No more messages.  Back ourselves out.

ReadTask_Unlock	andi.b	#$ff&(~(UNITF_READACTIVE!UNITF_INREADTASK)),(UNIT_FLAGS,a3)

;Main loop: wait for a new message

ReadTask_MainLoop:
	PUTDEBUG 75,<'%s/ReadTask ++Sleep'>
	move.l	d7,d0
	SYS	Wait
	ifge	INFO_LEVEL-5
	bchg.b	#1,($bfe001).l  ;Blink the power LED
	endc

ReadTask_StartHere:
	PUTDEBUG 75,<'%s/ReadTask ++Wakeup'>
	btst	#MDUB_STOPPED,(MDU_FLAGS,a3) ;See if we are stopped
	bne.b	ReadTask_MainLoop	;Device is stopped, ignore messages
	bset	#UNITB_READACTIVE,(UNIT_FLAGS,a3) ;Lock the device
	bne	ReadTask_MainLoop	;Device in use (immediate command?)

ReadTask_NextMessage:
	movea.l	a3,a0
	SYS	GetMsg	;Get the next request
	PUTDEBUG 1,<'%s/ReadTask GotMsg'>
	tst.l	d0
	beq	ReadTask_Unlock ; no message?

	movea.l	d0,a1	;Do this request
	exg	a5,a6	;Put device ptr in right place

	Forbid
	btst	#ioflagsB_Ignore,(IO_FLAGS,a1)
	bne.b	Readignorecmd
	bset	#ioflagsB_Active,(IO_FLAGS,a1)
	move.l	a1,(ReadRequestPtr,a3)
	Permit
	bsr	PerformIO	;Do it!
	bclr	#ioflagsB_Active,(IO_FLAGS,a1)

;No longer active - abort has stopped sending signals. Now we can
;(and should) clear the abort signal.

	moveq	#0,d0
	move.l	(readabortsig,a3),d1
	EXEC	SetSignal
	bra.b	Readconttl

Readignorecmd:
	Permit
	clr.l	(IO_ACTUAL,a1)
	bsr	TermIO
Readconttl:
	exg	a5,a6	;Get ExecBase back in a6
	bra	ReadTask_NextMessage

;**** End of read task code ****

;**** Beginning of write task code ****

	cnop	0,4	;Long word align

; Register Usage
; ==============
; a3 -- unit pointer
; a6 -- syslib pointer
; a5 -- device pointer
; a4 -- task (NOT process) pointer
; d7 -- wait mask

WriteTask_Begin:
	PUTDEBUG 35,<'%s/WriteTask_Begin'>
	movea.l	(SysBase).w,a6

;Grab the arguments passed down from our parent

	movea.l	(4,sp),a3	;Unit pointer
	movea.l	(mdu_Device,a3),a5	;Point to device structure
	lea	(tdresig,a3),a2
	moveq	#4,d6	;Number of signals to allocate-1
WriteSigLoop:
	moveq	#-1,d0	;-1 is any signal at all
	SYS	AllocSignal	;Allocate signals for I/O interrupts
	moveq	#0,d7	;Convert bit number signal mask
	bset	d0,d7
	move.l	d7,(a2)+	;Save in unit structure
	dbra	d6,WriteSigLoop

	move.l	(breaksig,a3),d0
	move.l	d0,d1
	SYS	SetExcept	;Make breaksig an exception-causing signal

;Allocate a signal for the timer message port

	moveq	#-1,d0	;-1 is any signal at all
	SYS	AllocSignal
	lea	(timerport,a3),a2
	move.b	d0,(MP_SIGBIT,a2)
	move.l	a2,(timeriorequest+MN_REPLYPORT,a3)
	suba.l	a1,a1
	SYS	FindTask
	move.l	d0,(MP_SIGTASK,a2)    
	move.b	#PA_SIGNAL,(MP_FLAGS,a2) ;Make message port "live"

;Allocate a signal for the cmd message port

	moveq	#-1,d0	;-1 is any signal at all
	SYS	AllocSignal
	move.b	d0,(mdu_wport+MP_SIGBIT,a3)
	move.b	#PA_SIGNAL,(mdu_wport+MP_FLAGS,a3) ;Make message port "live"

;Change the bit number into a mask, and save in d7

	moveq	#0,d7	;Clear D7
	bset	d0,d7

	ifge	INFO_LEVEL-40
	move.l	(ThisTask,a6),-(sp)
	move.l	a5,-(sp)
	move.l	a3,-(sp)
	move.l	d0,-(sp)
	PUTDEBUG 40,<'%s/WriteTask -- Signal=%ld, Unit=%lx Device=%lx Task=%lx'>
	adda.l	#4*4,sp
	endc

	bra.b	WriteTask_StartHere

;No more messages.  Back ourselves out.

WriteTask_Unlock:
	andi.b	#$ff&(~(UNITF_WRITEACTIVE!UNITF_INWRITETASK)),(UNIT_FLAGS,a3)

;Main loop: wait for a new message

WriteTask_MainLoop:
	PUTDEBUG 75,<'%s/WriteTask ++Sleep'>
	move.l  d7,d0
	SYS	Wait
	ifge INFO_LEVEL-5
	bchg.b	#1,($bfe001).l  ;Blink the power LED
	endc

WriteTask_StartHere:
	PUTDEBUG   75,<'%s/WriteTask ++Wakeup'>
	btst    #MDUB_STOPPED,(MDU_FLAGS,a3) ;See if we are stopped
	bne.b   WriteTask_MainLoop	;Device is stopped, ignore messages
	bset    #UNITB_WRITEACTIVE,(UNIT_FLAGS,a3) ;Lock the device
	bne     WriteTask_MainLoop	;Device in use (immediate command?)

WriteTask_NextMessage:
	lea	(mdu_wport,a3),a0
	SYS	GetMsg	;Get the next request
	PUTDEBUG 1,<'%s/WriteTask GotMsg'>
	tst.l	d0
	beq	WriteTask_Unlock	;No message?
	movea.l	d0,a1	;Do this request
	exg	a5,a6	;Put device ptr in right place

	Forbid
	btst	#ioflagsB_Ignore,(IO_FLAGS,a1)
	bne.b	Writeignorecmd
	bset	#ioflagsB_Active,(IO_FLAGS,a1)
	move.l	a1,(WriteRequestPtr,a3)
	Permit
	bsr	PerformIO	;Do it!
	bclr	#ioflagsB_Active,(IO_FLAGS,a1)

;No longer active - abort has stopped sending signals. Now we can
;(and should) clear the abort signal.

	moveq	#0,d0
	move.l	(writeabortsig,a3),d1
	EXEC	SetSignal
	bra.b	Writeconttl

Writeignorecmd:
	Permit
	clr.l	(IO_ACTUAL,a1)
	bsr	TermIO
Writeconttl:
	exg	a5,a6	; get syslib back in a6
	bra	WriteTask_NextMessage

;***** end of write task code *****

;Exception Handler (performs a break command)
;Note that this code acts as a handler for the write task only; the
;read task has no such handler.
;
;unit ptr in a1, execbase in a6
;All registers are saved/restored by Exec
;Note: Not all the usual newser register conventions are used here

breakexception:
	PUTDEBUG 5,<'%s/BreakException: called'>
	move.l	d0,-(sp)	;Save exception bits
	movea.l	a1,a3
	movea.l	a1,a2
	btst	#UNITB_BREAKACTIVE,(UNIT_FLAGS,a3) ;Sanity check
	beq	endbreakex
	movea.l	(daciabase,a3),a5
	move.b	#2,(ACR,a5) ;start break
	lea	(timeriorequest,a3),a1
	move.w	#TR_ADDREQUEST,(IO_COMMAND,a1)
	movea.l	(mdu_prefs,a3),a4
	clr.l	(TV_SECS,a1)
	move.l	(prefs_BRKTIME,a4),d0
	ori.b	#$FF,d0	;To avoid the V33/V34 bug
	move.l	d0,(TV_MICRO,a1)

	ifne	INFO_LEVEL	;If any debugging enabled at all
	move.l	d0,-(sp)
	PUTDEBUG 5,<'%s/BreakException: TV_MICRO=%ld'>
	addq.l	#4,sp
	endc

	movea.l	(MN_REPLYPORT,a1),a0
	move.b	(MP_SIGBIT,a0),d2
	jsr	(_LVOSendIO,a6)

	ifne	INFO_LEVEL	;If any debugging enabled at all
	clr.l	-(sp)
	move.b	d2,(3,sp)
	PUTDEBUG 5,<'%s/BreakException: Waiting for signal #%ld'>
	addq.l	#4,sp
	endc

;Take note - waiting within an exception is tricky!

	suba.l	a1,a1
	jsr	(_LVOFindTask,a6)
	movea.l	d0,a4	;ThisTask
	moveq	#0,d0
	bset	d2,d0
	add.l	(writeabortsig,a3),d0
	move.l	(TC_SIGWAIT,a4),d3 ;Save this -- very important!!!
	jsr	(_LVOWait,a6)
	move.l	d3,(TC_SIGWAIT,a4) ;Restore -- very important!!!
	and.l	(writeabortsig,a3),d0
	beq.b	breakOK

	PUTDEBUG 5,<'%s/BreakException: Aborted!'>

	lea	(timeriorequest,a3),a1 ;The break was aborted. Clean up.
	jsr	(_LVOAbortIO,a6)

	lea	(timeriorequest,a3),a1
	jsr	(_LVOWaitIO,a6)
 
breakOK	move.b	#0,(ACR,a5)
	movea.l	(breakiorequest,a3),a1
	clr.b	(IO_ERROR,a1)
	btst	#IOB_QUICK,(IO_FLAGS,a1)
	bne.b	endbreakex
	jsr	(_LVOReplyMsg,a6) 
endbreakex:
	move.l	(sp)+,d0 ;restore exception bits
	PUTDEBUG 5,<'%s/BreakException: Finished!'>
	rts

;Initialize the device

mdu_Init:
;Initialize read task message port/tcb
	INITBYTE MP_FLAGS,PA_IGNORE ;Unit starts with a message port
	INITBYTE LN_TYPE,NT_MSGPORT
	INITLONG LN_NAME,myName
	INITLONG mdu_rtcb+LN_NAME,myName
	INITBYTE mdu_rtcb+LN_TYPE,NT_TASK
	INITBYTE mdu_rtcb+LN_PRI,127

;Initialize write task message port/tcb

	INITBYTE mdu_wport+MP_FLAGS,PA_IGNORE ;Unit starts with a message port
	INITBYTE mdu_wport+LN_TYPE,NT_MSGPORT
	INITLONG mdu_wport+LN_NAME,myName
	INITLONG mdu_wtcb+LN_NAME,myName
	INITBYTE mdu_wtcb+LN_TYPE,NT_TASK
	INITBYTE mdu_wtcb+LN_PRI,126

;Initialize timer message port

	INITBYTE timerport+MP_FLAGS,PA_IGNORE ;Unit starts with a message port
	INITBYTE timerport+LN_TYPE,NT_MSGPORT
	INITLONG timerport+LN_NAME,myName

	dc.w	0

;******************** Interrupt code *********************************

;Notes:

;In this version of the driver we use a single interrupt routine for all
;units, and that routine bypasses the usual Exec conventions. Normally
;this would be bad, but the need for speed certainly warrents it in this
;case.

;This is the interrupt routine. It serves three purposes:
;1. Read in a byte if available, store it, and signal the read task
;2. Check for TDRE-empty condition and signal write task
;3. Check for an exceptional condition and signal read task

;Fast int routine
;uses d0,d7,a0,a3,a5

DoInt	macro
	movem.l	d0/d7/a0/a3/a5,-(sp)

	ifge	\1-1
	move.l	(Unit3,pc),a3
	move.l	(daciabase,a3),a5
	move.b	(ISR,a5),d7
	and.b	(IERstate,a3),d7	;Quick check (note that this masking is very
					;important)
	bne	FastInt	;Service it
	endc

	ifge	\2-1
	move.l	(_Unit2,pc),a3
	move.l	(daciabase,a3),a5
	move.b	(ISR,a5),d7
	and.b	(IERstate,a3),d7	;Quick check (note that this masking is very
					;important)
	bne	FastInt	;Service it
	endc

	ifge	\3-1
	move.l	(Unit1,pc),a3
	move.l	(daciabase,a3),a5
	move.b	(ISR,a5),d7
	and.b	(IERstate,a3),d7	;Quick check (note that this masking is very
					;important)
	bne	FastInt	;Service it
	endc

	ifge	\4-1
	move.l	(Unit0,pc),a3
	move.l	(daciabase,a3),a5
	move.b	(ISR,a5),d7
	and.b	(IERstate,a3),d7	;Quick check (note that this masking is very
					;important)
	bne	FastInt	;Service it
	endc

	movem.l	(sp)+,d0/d7/a0/a3/a5
	move.l	(OldVec,pc),-(sp)
	rts

	endm

IntRoutines:
	dc.l	Int0000	;dummy entry for 0
	dc.l	Int0001
	dc.l	Int0010
	dc.l	Int0011
	dc.l	Int0100
	dc.l	Int0101
	dc.l	Int0110
	dc.l	Int0111
	dc.l	Int1000
	dc.l	Int1001
	dc.l	Int1010
	dc.l	Int1011
	dc.l	Int1100
	dc.l	Int1101
	dc.l	Int1110
	dc.l	Int1111

Int0000:
	DoInt	0,0,0,0
Int0001:
	DoInt	0,0,0,1
Int0010:
	DoInt	0,0,1,0
Int0011:
	DoInt	0,0,1,1
Int0100:
	DoInt	0,1,0,0
Int0101:
	DoInt	0,1,0,1
Int0110:
	DoInt	0,1,1,0
Int0111:
	DoInt	0,1,1,1
Int1000:
	DoInt	1,0,0,0
Int1001:
	DoInt	1,0,0,1
Int1010:
	DoInt	1,0,1,0
Int1011:
	DoInt	1,0,1,1
Int1100:
	DoInt	1,1,0,0
Int1101:
	DoInt	1,1,0,1
Int1110:
	DoInt	1,1,1,0
Int1111:
	DoInt	1,1,1,1


;************* Start of fast interrupt routine **************

FastInt:

;Read error condition?
;(We must check this first because a read of the RDR clears the error flags.)

	move.b	d7,d0
	and.b	#6,d0
	bne	ReadErr	;errors

	btst	#ISRB_RDRF,d7	;Test Receive Data Buffer Full
	beq.b	rdrfempty

	PUTDEBUG 75,<'%s/Int: Read.'>

;Store the byte in the circular buffer.  Note that this code *can't* be
;interrupted, so we're safe (that's because CIA B, which we're plugging into,
;is connected to INT6*).

	move.l	(TailLong,a3),d0	;Read and store
	move.l	(StartBuf,a3),a0
	move.b	(RDR,a5),(a0,d0.l)
	addq.w	#1,(Tail,a3)

;Currently waiting for a character?
	btst	#MDUB_WaitingForChar,(MDU_FLAGS,a3)
	bne.b	SignalRead	;yes, signal read task
	bset	#MDUB_CharAvailable,(MDU_FLAGS,a3)

;Return from int routine
	movem.l	(sp)+,d0/d7/a0/a3/a5
	move.w	#$2000,(_custom+intreq)
	rte

SignalRead:
	bclr	#MDUB_WaitingForChar,(MDU_FLAGS,a3)
	bset	#MDUB_CharAvailable,(MDU_FLAGS,a3)
	movem.l	d1/a1/a6,-(sp)
	movea.l	(mdu_SysLib,a3),a6
	move.l	(readsig,a3),d0
	lea	(mdu_rtcb,a3),a1
	jsr	(_LVOSignal,a6)	;Signal the read task
	movem.l	(sp)+,d1/a1/a6
	movem.l	(sp)+,d0/d7/a0/a3/a5
	move.l	(OldVec,pc),-(sp)
	rts

rdrfempty:
;Continue with int routine...

;We can deduce that the interrupt was caused by TDRE
;The TDRE interrupt is only enabled when the write task needs to be
;signaled, so there is no analogue here to the 'MDUB_WaitingForChar' flag
;used when reading.

	PUTDEBUG 75,<'%s/Int: Write signal.'>

	movem.l	d1/a1/a6,-(sp)
	andi.b	#WRITEOFFMASK,(IERstate,a3)
	move.b	#WRITEOFF,(IER,a5)
	move.l	(tdresig,a3),d0
	lea	(mdu_wtcb,a3),a1
	movea.l	(mdu_SysLib,a3),a6
	jsr	(_LVOSignal,a6)	;Signal the write task
	movem.l	(sp)+,d1/a1/a6
	movem.l	(sp)+,d0/d7/a0/a3/a5
	move.l	(OldVec,pc),-(sp)
	rts

;Exceptional conditions handled here....

ReadErr:
;An exceptional condition occured - signal the read task

	movem.l	d1/a1/a6,-(sp)
	move.b	d7,(ISRcopy,a3)	;Useful info
	move.b	(CSR,a5),(CSRcopy,a3) ;More useful info
	move.l	(readabortsig,a3),d0
	lea	(mdu_rtcb,a3),a1
	movea.l	(mdu_SysLib,a3),a6
	jsr	(_LVOSignal,a6)
	move.b	(RDR,a5),d0	;This forces a clear of the error bits
	movem.l	(sp)+,d1/a1/a6
	movem.l	(sp)+,d0/d7/a0/a3/a5
	move.l	(OldVec,pc),-(sp)
	rts

;******* End of fast interrupt routine *********

	ifne	INFO_LEVEL	;If any debugging enabled at all

KPutFmt	move.l	a2,-(sp)
	lea	(KPutChar,pc),a2
	bsr.b	KDoFmt
	movea.l	(sp)+,a2
	rts

KDoFmt	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	jsr	(_LVORawDoFmt,a6)
	movea.l	(sp)+,a6
	rts

KPutChar	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	jsr	(_LVORawPutChar,a6)
	movea.l	(sp)+,a6
	rts

	endc

EndCode:
	end
