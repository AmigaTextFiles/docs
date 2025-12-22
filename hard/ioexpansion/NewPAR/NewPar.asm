*****************************************************************************
* Program:  eightbit.asm - Copyright ©1990,91 DigiSoft
* Function: A "parallel.device" compatible driver for the Rockwell 65C22
*
* Author:   Paul Coward       ©1990 DigiSoft
* History:  11/12/90 PC V0.50 Adapted from Sharer project to suit independent
*                             IO PD project initiated by Jeff Lavin.
*           01/14/91 PC V0.53 Finally !!!
*
* [To all: Please don't forget to bump the revision numbers
*          if you do *any* modifications at all.  -Jeff]
*****************************************************************************

**	Tabstops : 8
**	Assemble with Macro68


	ifnd	__m68
	fail	'Wrong assembler!'
	endc
	exeobj
	incpath	Includes:
	macfile IOexp.i		;The One & Only include file
	objfile	ram:eightbit.device

;   Name    P2   Centronics	(VIA_1)
;   ====    ==   ==========
;   CA2.2    2   1  STROBE*
;   PA0.2    3   2  DATA0
;   PA1.2    4   3  DATA1
;   PA2.2    5   4  DATA2
;   PA3.2    6   5  DATA3
;   PA4.2    7   6  DATA4
;   PA5.2    8   7  DATA5
;   PA6.2    9   8  DATA6
;   PA7.2   10   9  DATA7
;   CA1.2    1  10  ACK*
;   GND    PAD  16  GND

*****************************************************************************
*     Everything in this block will eventually be transferred to ioexp.i    *
*****************************************************************************

PVERSION	equ	1	;major version number
PREVISION	equ	6	;minor version number

pcrBits	equ	%10101010	;pulse output
ierABits	equ	%00000010	;CA1
ierBBits	equ	%00010000	;CB1

IOR	equ	0
DDR	equ	DDRA-ORA

cdPri	equ	5
mduStackSize	equ	$200
mdTaskPri	equ	5


; --- Unit flags - pdu_devFlags

	BITDEF	rw,EOFMODE,0	;unit read/write flag
	BITDEF	rw,NULLMODE,1	;unit read/write null terminated flag
	BITDEF	io,SHARED,2	;unit shared access allowed

; my device data area structure

	setso	LIB_SIZE
dev_Flags	so.b	1
dev_MyFlags	so.b	1
dev_SegList	so.l	1
dev_Units	so.b	MD_NUMUNITS*4
dev_SizeOf	soval


	setso	UNIT_SIZE
pdu_UnitNum	so.b	1
pdu_devFlags	so.b	1
pdu_IOparFlags	so.b	1
	alignso	0,4
pdu_stack	so.b	mduStackSize
pdu_tcb	so.b	TC_SIZE
pdu_Device	so.l	1
pdu_HardwareBase	so.l	1
pdu_IOReg	so.w	1
pdu_ifrMask	so.w	1
pdu_SigMask	so.l	1
pdu_is	so.b	IS_SIZE
pdu_rwBufferLocation so.l	1
pdu_lengthCounter	so.l	1
pdu_CurrentIOB	so.l	1
pdu_TermArray	soval
pdu_TermArray_0	so.b	(PTERMARRAY_SIZE/2)
pdu_TermArray_1	so.b	(PTERMARRAY_SIZE/2)
pdu_Sizeof	soval

	BITDEF	DEV,ACTIVE,0	;device active flag
	BITDEF	UNIT,STOPPED,2	;status bit flag for unit stopped

*****************************************************************************
*                    These will be local to this program                    *
*****************************************************************************

	ifne	PTERMARRAY_SIZE-8
	fail	'Commodore has changed PTERMARRAY size'
	endc

INFO_LEVEL	equ	0

***************************************

;The first executable location.  This should return an error in case someone
;tried to run us as a program (instead of loading us as a device).

	moveq	#-1,d0
	rts

;A romtag structure.  After your driver is brought in from disk, the
;disk image will be scanned for this structure to discover magic constants
;about you (such as where to start running you from...).

initDevDescript:
	dw	RTC_MATCHWORD
	dl	initDevDescript
	dl	EndCode
	db	RTF_AUTOINIT	;RT_FLAGS
	db	PVERSION
	db	NT_DEVICE
	db	cdPri	;RT_PRI
	dl	cdName
	dl	cdIDString
	dl	DevInit	;RT_INIT

cdName:	PARDEVNAME	;This is the name that the device will have

;This is an identifier tag to help in supporting the device
;format is 'name version.revision (dd MON yyyy)',<cr>,<lf>,<null>

cdIDString:
	PARIDENT

;The romtag specified that we were "RTF_AUTOINIT".  This means that the
;RT_INIT structure member points to one of these tables below.  If the
;AUTOINIT bit was not set then RT_INIT would point to a routine to run.

DevInit:
	dl	dev_SizeOf	;data space size
	dl	funcTable	;pointer to function initializers
	dl	dataTable	;pointer to data initializers
	dl	initRoutine	;routine to run

funcTable:
	dl	Open	;standard system routines
	dl	Close
	dl	Expunge
	dl	ExtFunc	;Reserved for future use!
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
	INITBYTE LH_TYPE,NT_DEVICE
	INITLONG LN_NAME,cdName
	INITBYTE LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
	INITWORD LIB_VERSION,PVERSION
	INITWORD LIB_REVISION,PREVISION
	INITLONG LIB_IDSTRING,cdIDString
	dl	 0	;terminate list


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

initRoutine:	movea.l	d0,a1		;get device pointer
	move.l	a0,(dev_SegList,a1)	;save a pointer to our loaded code
	rts


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

Open:	pushm	d2/a2-a4
	PUTDEBUG 1,<10,10,'STARTING NEW DEBUG RUN',10,10>
	movea.l	a1,a2	;save the iob
	moveq	#MD_NUMUNITS,d2	;see that the unit number is in range
	cmp.l	d2,d0
	bcc.b	.openError
	move.l	d0,d2	;see if the unit is already initialized
	lsl.l	#2,d0
	lea	(dev_Units,a6,d0.l),a4
	move.l	(a4),d0
	beq.b	1$	;unit not open - so open it
	movea.l	d0,a0
	btst	#ioB_SHARED,(pdu_devFlags,a0)	;see if unit allows shared access
	beq.b	.openError	;error if not
	btst	#PARB_SHARED,d1	;see if the open request allows shared access
	bne.b	.openUnitOK
	bra.b	.openError	;unit can have only ONE client
1$	bsr	InitUnit	;try and conjure up a unit
	move.l	(a4),d0	;see if it opened ok
	beq.b	.openError
.openUnitOK:	movea.l	d0,a3	;unit pointer
	move.l	d0,(IO_UNIT,a2)
	addq.w	#1,(LIB_OPENCNT,a6)	;mark us as having another customer
	addq.w	#1,(UNIT_OPENCNT,a3)
	bclr	#LIBB_DELEXP,(dev_Flags,a6)	;prevent delayed expunges
	btst	#PARB_SHARED,d1	;see if the open request allows shared access
	beq.b	2$
	bset	#ioB_SHARED,(pdu_devFlags,a3)	;unit allows shared access
2$	clr.b	(IO_ERROR,a2)
	btst	#PARB_EOFMODE,(IO_PARFLAGS,a2)	;eof enabled mode set ?
	beq.b	.openEnd
	move.l	(pdu_TermArray,a3),(IO_PTERMARRAY+PTERMARRAY_0,a2)
	move.l	(pdu_TermArray+4,a3),(IO_PTERMARRAY+PTERMARRAY_1,a2)
.openEnd:	popm	d2/a2-a4
	rts

.openError:	move.b	#IOERR_OPENFAIL,(IO_ERROR,a2)
	PUTDEBUG 95,<'Open device routine exiting with error'>
	bra.b	.openEnd



;--------------------------------------------------------------
; --- initunit initializes a device unit and starts up the 
; --- associated unit task
;--------------------------------------------------------------

; --- (unit number:D2 scratch:A3 device:A6)

InitUnit:	pushm	d2/a2/a5-a6
	PUTDEBUG 90,<'InitUnit routine called'>
	movea.l	a6,a5		;device pointer
	movea.l	(SysBase).w,a6
	move.l	#pdu_Sizeof,d0
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	jsr	(_LVOAllocMem,a6)
	tst.l	d0
	beq	.initUnitEnd

	movea.l	d0,a3
	movea.l	a3,a2		;for InitStruct
	moveq	#0,d0		;don't 0 the rest
	lea	(UnitInitStruct,pc),a1
	jsr	(_LVOInitStruct,a6)
	move.b	d2,(pdu_UnitNum,a3)	;initialize unit number
	move.l	a5,(pdu_Device,a3)
	lea	(pdu_stack,a3),a0
	move.l	a0,(pdu_tcb+TC_SPLOWER,a3)
	lea	(mduStackSize,a0),a0
	move.l	a0,(pdu_tcb+TC_SPUPPER,a3)
	move.l	a3,-(a0)	;pass unit pointer on the stack
	move.l	a0,(pdu_tcb+TC_SPREG,a3)
	lea	(pdu_tcb,a3),a0
	move.l	a0,(MP_SIGTASK,a3)
	lea	(MP_MSGLIST,a3),a0
	NEWLIST	a0
	lea	(pdu_tcb,a3),a1
	lea	(mdTask_Start,pc),a2	;for AddTask
	PUSH	a3
	suba.l	a3,a3
	subq.l	#1,a3		;force odd address GURU if the task ever exits
	moveq	#0,d0
	jsr	(_LVOAddTask,a6)
	POP	a3
	lsl.l	#2,d2
	move.l	a3,(dev_Units,a5,d2.l)	;put unit pointer into device structure
	add.w	d2,d2
	move.w	(hardwareBaseArray,pc,d2.l),(pdu_IOReg,a3)
	move.w	(hardwareBaseArray+2,pc,d2.l),(pdu_ifrMask,a3)
	move.l	(hardwareBaseArray+4,pc,d2.l),(pdu_HardwareBase,a3)
	move.l	a3,(pdu_is+IS_DATA,a3)
	move.l	#InterruptCode,(pdu_is+IS_CODE,a3)
	movea.l	(pdu_HardwareBase,a3),a0
	move.b	(pdu_ifrMask+1,a3),(INTER,a0)	;make sure interrupts are off
	move.b	#pcrBits,(PERCR,a0)	;set up the controll register (both ports - dosn't matter)
.initUnitEnd:	popm	d2/a2/a5-a6
	rts


;Table of VIA base addresses for the 4 units

hardwareBaseArray:
	dw	ORA	;register offset from hardware base
	dw	ierABits	;interrupt flag mask
	dl	VIA_Base+VIA0	;base address for hardware unit 0
	dw	ORB	;register offset from hardware base
	dw	ierBBits	;interrupt flag mask
	dl	VIA_Base+VIA0	;base address for hardware unit 1
	dw	ORA	;register offset from hardware base
	dw	ierABits	;interrupt flag mask
	dl	VIA_Base+VIA1	;base address for hardware unit 2
	dw	ORB	;register offset from hardware base
	dw	ierBBits	;interrupt flag mask
	dl	VIA_Base+VIA1	;base address for hardware unit 3


; --- (unitptr:A3 deviceptr:A6)

FreeUnit:	movea.l	a3,a1
	PUTDEBUG 85,<'FreeUnit routine called'>
	move.l	#pdu_Sizeof,d0
	push	a6
	movea.l	(SysBase).w,a6
	jsr	(_LVOFreeMem,a6)
	pop	a6
ExtFunc:	moveq	#0,d0
	rts


; --- (unitptr:A3 deviceptr:A6)

ExpungeUnit:	push	d2
	PUTDEBUG 85,<'ExpungeUnit routine called'>
	lea	(pdu_tcb,a3),a1
	push	a6
	movea.l	(SysBase).w,a6
	jsr	(_LVORemTask,a6)
	pop	a6
	moveq	#0,d2
	move.b	(pdu_UnitNum,a3),d2	;save the unit number
	bsr	FreeUnit	;free the unit structure
	lsl.l	#2,d2
	clr.l	(dev_Units,a6,d2.l)	;clear the unit vector from the device
	pop	d2
	rts

;There are two different things that might be returned from the Close
;routine.  If the device wishes to be unloaded, then Close must return
;the segment list (as given to Init).  Otherwise close MUST return NULL.
; ( device:a6, iob:a1 )

Close:	pushm	a2-a3
	PUTDEBUG 80,<'Close device routine called'>
	movea.l	a1,a2		;save iob pointer
	movea.l	(IO_UNIT,a2),a3
	moveq	#-1,d0		;make sure that the iob is not used again
	move.l	d0,(IO_UNIT,a2)
	move.l	d0,(IO_DEVICE,a2)
	subq.w	#1,(UNIT_OPENCNT,a3)	;see if the unit is still in use
	bne.b	.closeDevice
	bsr	ExpungeUnit
.closeDevice:	subq.w	#1,(LIB_OPENCNT,a6)
	bne.b	.closeEnd
	btst	#LIBB_DELEXP,(pd_Flags,a6)
	beq.b	.closeEnd
	bsr	Expunge
.closeEnd:	popm	a2-a3
	rts

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

Expunge:	pushm	d2/a5/a6
	moveq	#0,d2
	movea.l	a6,a5
	movea.l	(SysBase).w,a6
	tst.w	(LIB_OPENCNT,a5)	;any users left ?
	beq.b	1$
	bset	#LIBB_DELEXP,(pd_Flags,a5)	;if there then delay the expunge
	bra.b	.expungeEnd

1$	move.l	(dev_SegList,a5),d2
	movea.l	a5,a1
	jsr	(_LVORemove,a6)		;unlink from the library list
	moveq	#0,d0		;release our memory
	movea.l	a5,a1
	move.w	(LIB_NEGSIZE,a5),d0
	suba.l	d0,a1
	add.w	(LIB_POSSIZE,a5),d0
	jsr	(_LVOFreeMem,a6)
.expungeEnd:	move.l	d2,d0		;set up our return value
	popm	d2/a5/a6
	rts

;------------------------------------------------------------------------------
;
;	Here begins the real device stuff
;
;------------------------------------------------------------------------------

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
; ( iob: a1, device:a6 )

AbortIO:	clr.b	(IO_ERROR,a1)
	movea.l	(IO_UNIT,a1),a0
	cmpa.l	(pdu_CurrentIOB,a0),a1
	bne.b	1$
	clr.l	(pdu_CurrentIOB,a0)
1$	rts


;This define is used to tell which commands should be handled
;immediately (on the caller's schedule).
;
;The immediate commands are Invalid, Reset, Stop, Start, Flush, Clear,
;Query, and SetParams
;
;Note that this method limits you to just 32 device specific commands,
;which may not be enough.

IMMEDIATES	equ	%00000000000000000000000111000011
;		 --------========--------========
;		 FEDCBA9876543210FEDCBA9876543210

VIATASK	equ	$0000000C


BeginIO:	push	a4
	clr.b	(IO_ERROR,a1)
	move.b	#NT_MESSAGE,(LN_TYPE,a1)
	movea.l	(IO_UNIT,a1),a4
	move.w	(IO_COMMAND,a1),d0
	cmpi.w	#PDCMD_SETPARAMS,d0
	bgt	.noCmd
	PUTDEBUG 75,<'BeginIO -- got a valid command'>
	Disable	a0
	move.w	#IMMEDIATES,d1
	btst	d0,d1
	bne	.immediate
	move.w	#VIATASK,d1
	btst	d0,d1
	bne	.queueMsg
	btst	#UNITB_STOPPED,(UNIT_FLAGS,a4)
	bne.b	.queueMsg
	bset	#UNITB_ACTIVE,(UNIT_FLAGS,a4)
	beq.b	.immediate
.queueMsg:	bset	#UNITB_INTASK,(UNIT_FLAGS,a4)
	bclr	#IOB_QUICK,(IO_FLAGS,a1)
	Enable	a0
	movea.l	a4,a0
	push	a6
	movea.l	(SysBase).w,a6
	jsr	(_LVOPutMsg,a6)
	pop	a6
	bra.b	.end
.immediate:	Enable	A0
	bsr	PerformIO
.end:	pop	a4
	rts

.noCmd:	move.b	#IOERR_NOCMD,(IO_ERROR,a1)
	bra.b	.end

;Cmdtable is used to look up the address of a routine that will
;implement the device command.

cmdtable:
	dw	Invalid-cmdtable
	dw	MyReset-cmdtable
	dw	Read-cmdtable
	dw	Read-cmdtable
	dw	Invalid-cmdtable
	dw	Clear-cmdtable
	dw	MyStop-cmdtable
	dw	Start-cmdtable
	dw	Flush-cmdtable
	dw	Query-cmdtable
	dw	SetParams-cmdtable


PerformIO:	pushm	a2-a3
	movea.l	a1,a2
	movea.l	(pdu_HardwareBase,a4),a3
	move.w	(IO_COMMAND,a2),d0
	ifge	INFO_LEVEL-65
	push	d0
	push	a1
	PUTDEBUG 65,<'PerformIO --- IOB @ $%lx --- Command =%ld'>
	addq.w	#8,sp
	endc
	add.w	d0,d0
	lea	(cmdtable,pc),a0
	adda.w	(0,a0,d0.w),a0
	jsr	(a0)

; --- (iob:A2 unitptr:A4 device:A6)

TermIO:	move.w	(IO_COMMAND,a2),d0
	move.w	#IMMEDIATES,d1
	btst	d0,d1
	bne.b	.termIOimmediate
	btst	#UNITB_INTASK,(UNIT_FLAGS,a4)
	bne.b	.termIOimmediate
	bclr	#UNITB_ACTIVE,(UNIT_FLAGS,a4)
.termIOimmediate:
	btst	#IOB_QUICK,(IO_FLAGS,a2)
	bne.b	.termIOend
	ifge	INFO_LEVEL-70
	push	a2
	PUTDEBUG 70,<'TermIO --- Reply msg IOB @ $%lx'>
	addq.w	#4,sp
	endc
	movea.l	a2,a1
	push	a6
	movea.l	(SysBase).w,a6
	jsr	(_LVOReplyMsg,a6)
	pop	a6
.termIOend:	popm	a2-a3
	rts

;------------------------------------------------------------------------------
; --- Invalid command sent to this device - return error
; --- Clear - do nothing - not supported
;------------------------------------------------------------------------------

Invalid:	move.b	#IOERR_NOCMD,(IO_ERROR,a1)
Clear:	rts

;------------------------------------------------------------------------------
; --- Reset the hardware for this unit
;------------------------------------------------------------------------------

MyReset:	bsr.b	Flush
	move.b	#pcrBits,(PERCR,a3)
	move.b	(pdu_ifrMask+1,a4),(INTFR,a3)
	move.b	(pdu_ifrMask+1,a4),(INTER,a3)
	rts

;------------------------------------------------------------------------------
; --- Stop the unit
; --- Start the unit
;------------------------------------------------------------------------------

MyStop:	bset	#UNITB_STOPPED,(UNIT_FLAGS,a4)
	clr.l	(IO_ACTUAL,a1)
	rts

Start:	bsr.b	InternalStart
	movea.l	a2,a1
	clr.l	(IO_ACTUAL,a1)
	rts

InternalStart:	bclr	#UNITB_STOPPED,(UNIT_FLAGS,a4)	;turn processing back on
	movea.l	a4,a1		;kick the task to start it moving
	moveq	#0,d0
	move.b	(MP_SIGBIT,a4),d1
	bset	d1,d0
	push	a6
	movea.l	(SysBase).w,a6
	jsr	(_LVOSignal,a6)
	pop	a6
	rts

;------------------------------------------------------------------------------
; --- Flush pulls all io requests off the que and sends them back.
; -- We must be carefull not to destroy work in progress, and also
; -- that we do not let some io requests slip by.
;
; --- Some funny magic goes on with the STOPPED bit in here.  Stop is
; -- defined as not being reentrant.  We therefore save the old state
; -- of the bit and then restore it later.  This keeps us from needing
; -- to DISABLE in flush.  It also fails miserably if someone does a
; -- start in the middle of a flush.
;------------------------------------------------------------------------------

Flush:	pushm	d2/a6
	clr.l	(pdu_CurrentIOB,a4)
	movea.l	(SysBase).w,a6
	bset	#UNITB_STOPPED,(UNIT_FLAGS,a4)
	sne	d2
Flush_Loop:	movea.l	a4,a0
	jsr	(_LVOGetMsg,a6)
	tst.l	d0
	beq.b	Flush_End
	movea.l	d0,a1
	move.b	#IOERR_ABORTED,(IO_ERROR,a1)
	jsr	(_LVOReplyMsg,a6)
	bra.b	Flush_Loop
Flush_End:	move.l	d2,d0
	popm	d2/a6
	tst.b	d0
	beq.b	1$
	bsr	InternalStart
1$	movea.l	a2,a1
	rts

;------------------------------------------------------------------------------
; --- Query the parallel device unit status
;------------------------------------------------------------------------------

Query:	clr.b	(IO_PARSTATUS,a1)	;return the current status
	rts

;------------------------------------------------------------------------------
; --- Set the parallel device unit parameters
;------------------------------------------------------------------------------

SetParams:	btst	#UNITB_ACTIVE,(pdu_devFlags,a4)
	beq.b	.modeIsCorrect
	move.b	#1,(IO_ERROR,a1)
	bra.b	.return
.modeIsCorrect:	move.b	(IO_PARFLAGS,a1),(pdu_IOparFlags,a4)
	btst	#PARB_EOFMODE,(pdu_IOparFlags,a4)
	beq.b	.return
	move.l	(IO_PTERMARRAY+PTERMARRAY_0,a1),(pdu_TermArray_0,a4)
	move.l	(IO_PTERMARRAY+PTERMARRAY_1,a1),(pdu_TermArray_1,a4)
.return:	rts

;------------------------------------------------------------------------------
; --- Read/Write
;------------------------------------------------------------------------------

Read:	tst.l	(IO_LENGTH,a1)
	bne.b	.performIO
	clr.l	(IO_ACTUAL,a1)
	rts

.performIO:	push	a6
	PUTDEBUG 50,<'Read/Write'>
	move.w	(pdu_IOReg,a4),d7
	bclr	#rwB_NULLMODE,(pdu_devFlags,a4)
	bset	#IOPARB_ACTIVE,(IO_FLAGS,a1)	;active
	move.l	(IO_DATA,a1),(pdu_rwBufferLocation,a4)	;initialize buffer pointer
	clr.l	(pdu_lengthCounter,a4)	;clear buffer counter
	move.l	a1,(pdu_CurrentIOB,a4)	;store the current IOB structure
	tst.l	(IO_LENGTH,a1)	;a -1 here means read to eof
	bpl.b	.notEOFmode
	bset	#rwB_NULLMODE,(pdu_devFlags,a4)
.notEOFmode:	lea	(0,a3,d7.w),a0
	cmpi.w	#CMD_READ,(IO_COMMAND,a1)
	beq.b	.setDataDirectionIN
.setDataDirectionOUT:
	move.b	#0,(IOR,a0)
	move.b	#-1,(DDR,a0)
	bra.b	.letTheInterruptWork

.setDataDirectionIN:
	move.b	#0,(IOR,a0)	;just for the hell of it
	move.b	#0,(DDR,a0)

.letTheInterruptWork:
	move.w	(pdu_ifrMask,a4),d0
	move.b	d0,(INTFR,a3)	;clear the interrupt bit
	lea	(pdu_is,a4),a1
	moveq	#INTB_EXTER,d0	;(level 6) interrupt
	movea.l	(SysBase).w,a6
	jsr	(_LVOAddIntServer,a6) 
	Disable
	move.w	(pdu_ifrMask,a4),d0
	ori.w	#$80,d0
	move.b	d0,(INTER,a3)	;enable chip interrupt
	move.l	(pdu_SigMask,a4),d0
	ifge	INFO_LEVEL-50
	push	d0
	push	(ThisTask,a6)
	PUTDEBUG 50,<'Task @ $%lx waiting -- sigmask = $%lx'>
	addq.w	#8,sp
	endc
	jsr	(_LVOWait,a6)	;sleep while the interrupt does the work
	PUTDEBUG 70,<'Got signal'>
	Enable
	lea	(pdu_is,a4),a1
	moveq	#INTB_EXTER,d0
	jsr	(_LVORemIntServer,a6)	;remove the interrupt server
	PUTDEBUG 50,<'Read/Write finished'>
	pop	a6
	rts

****************************************
***   ===   INTERRUPT DRIVER   ===   ***
****************************************

InterruptCode:	pushm	d1-d7/a0-a6
	movea.l	a1,a4
	movea.l	(pdu_HardwareBase,a4),a3
	move.b	(INTFR,a3),d7
	and.w	(pdu_ifrMask,a4),d7
	bne.b	.isMine
	popm	d1-d7/a0-a6
	moveq	#0,d0
	rts

.isMine:	move.l	(pdu_CurrentIOB,a4),d0
	beq	.noCurrentIOB
	movea.l	d0,a1
	move.w	(pdu_IOReg,a4),d7
.read_write:	movea.l	(pdu_rwBufferLocation,a4),a0
	btst	#IOPARB_ABORT,(IO_FLAGS,a1)
	bne	.rwFINISHED
	cmpi.w	#CMD_WRITE,(IO_COMMAND,a1)
	bne.b	.READdata
	ifge	INFO_LEVEL-200
	pea	(IOR,a3,d7.w)
	moveq	#0,d0
	move.b	(a0),d0
	push	d0
	PUTDEBUG 100,<'Writing byte $%lx to IOR @ $%08lx'>
	addq.w	#8,sp
	endc
	move.b	(a0)+,(IOR,a3,d7.w)
	bne	.updateCounters
	btst	#rwB_NULLMODE,(pdu_devFlags,a4)
	beq.b	.updateCounters
	bra	.rwFINISHED

.READdata:	move.b	(IOR,a3,d7.w),d0
	bne.b	.notNullCharRead
	ifge	INFO_LEVEL-200
	pea	(IOR,a3,d7.w)
	andi.l	#$ff,d0
	push	d0
	PUTDEBUG 100,<'Read non-zero byte = $%08lx from IOR @ $%lx'>
	addq.w	#8,sp
	endc
	btst	#rwB_NULLMODE,(pdu_devFlags,a4)
	bne	.rwFINISHED
.notNullCharRead:
	movea.l	(pdu_rwBufferLocation,a4),a0
	move.b	d0,(a0)+
.updateCounters:
	move.l	a0,(pdu_rwBufferLocation,a4)
	addq.l	#1,(pdu_lengthCounter,a4)
	btst	#PARB_EOFMODE,(IO_PARFLAGS,a1)	;test EOF mode enabled bit in IOB
	beq.b	.noTermArraySet
	lea	(IO_PTERMARRAY+PTERMARRAY_0,a1),a0
	moveq	#8-1,d1
.checkForTermMatch:
	cmp.b	(a0)+,d0
	dbcc	d1,.checkForTermMatch
	beq.b	.rwFINISHED
.noTermArraySet:
	move.l	(IO_LENGTH,a1),d0
	bmi	.rwUntilNullTerm
	cmp.l	(pdu_lengthCounter,a4),d0
	bgt	.rwUntilNullTerm

.rwFINISHED:	move.l	(pdu_lengthCounter,a4),(IO_ACTUAL,a1)
	bclr	#IOPARB_ACTIVE,(IO_FLAGS,a1)	;clear request queued or current bit
.noCurrentIOB:	bclr	#rwB_NULLMODE,(pdu_devFlags,a4)
	bclr	#DEVB_ACTIVE,(pdu_devFlags,a4)
	clr.l	(pdu_CurrentIOB,a4)
	movea.l	(SysBase).w,a6
	move.l	(pdu_SigMask,a4),d0
	lea	(pdu_tcb,a4),a1
	ifge	INFO_LEVEL-50
	push	d0
	push	a0
	PUTDEBUG 65,<'Signaling task @ $%lx with signal $%lx'>
	addq.w	#8,sp
	endc
	jsr	(_LVOSignal,a6)
	move.b	(pdu_ifrMask+1,a4),(INTER,a3)	;disable chip interrupt
.rwUntilNullTerm:
	popm	d1-d7/a0-a6
	moveq	#1,d0		;terminate the interrupt chain
	rts


;------------------------------------------------------------------------------
; --- Sub-task related stuff
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------
;
;	Register Usage
;		A6 = exec pointer
;		A5 = device pointer
;		A4 = unit pointer
;		D7 = wait mask
;
;------------------------------------------------------------------------------
;------------------------------------------------------------------------------


mdTask_Start:	movea.l	(SysBase).w,a6
	movea.l	(4,sp),a4	;unit pointer
	movea.l	(pdu_Device,a4),a5	;device pointer
	moveq	#-1,d0		;-1 is any signal at all
	jsr	(_LVOAllocSignal,a6)
	moveq	#0,d7
	bset	d0,d7
	move.l	d7,(pdu_SigMask,a4)	;signal for when interrupt is finished
	moveq	#-1,d0		;-1 is any signal at all
	jsr	(_LVOAllocSignal,a6)
	move.b	d0,(MP_SIGBIT,a4)
	move.b	#PA_SIGNAL,(MP_FLAGS,a4)
	moveq	#0,d7
	bset	d0,d7
	bra.b	.checkStatus

.unlock:	andi.b	#$FF&(~(UNITB_ACTIVE!UNITB_INTASK)),(UNIT_FLAGS,a4)
.mainLoop:	move.l	d7,d0
	jsr	(_LVOWait,a6)
.checkStatus:	btst	#UNITB_STOPPED,(UNIT_FLAGS,a4)	;see if we are stopped
	bne.b	.mainLoop
	bset	#UNITB_ACTIVE,(UNIT_FLAGS,a4)
	bne.b	.mainLoop	;device in use
.nextMessage:	movea.l	a4,a0
	jsr	(_LVOGetMsg,a6)
	tst.l	d0
	beq.b	.unlock		;no message ?
	movea.l	d0,a1		;IOB
	exg	a5,a6		;put the device pointer in right register
	bsr	PerformIO
	PUTDEBUG 100,<'Unit Task --- returned from PerformIO'>
	exg	a5,a6		;get exec back in A6
	bra.b	.nextMessage

*******************************************************************************

UnitInitStruct:
	INITBYTE LH_TYPE,NT_DEVICE
	INITBYTE LIB_FLAGS,LIBF_CHANGED
	INITWORD LIB_VERSION,PVERSION
	INITWORD LIB_REVISION,PREVISION
	INITBYTE pdu_is+LN_TYPE,NT_INTERRUPT
	dc.l	 0

;------------------------------------------------------------------------------
;EndCode is a marker that shows the end of your code.  Make sure that it
;does not span sections nor is before the rom tag in memory!  It is ok to
;put it right after the rom tag -- that way you are always safe.  I put it
;here because it is the right thing to do, and i know that it is safe in
;this case	
;------------------------------------------------------------------------------

	ISDEBUG	'eightbit'

EndCode:

*******************************************************************************

	end
