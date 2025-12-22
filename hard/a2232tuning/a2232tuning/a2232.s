i	opt	l+,c+,e+
**
**	A2232.DEVICE - Replacement device for the a2232 serial board
**
**	$VER: 1.02 (20.02.1997)
**
**	<C> 1997 by Markus Marquardt
**
**
**	History:
**	--------
**	1.00 (10.01.1997)	First version...
**
**	1.01 (21.01.1997)	Many bugfixes...
**				FIRST aminet release
**
**	1.02 (20.02.1997)	Added support for SHARED open, some minor
**				bug fixes
**				SECOND aminet release
**
**	1.03 (29.11.1997)	Some source cleanup
**				THIRD (maybe last) aminet release WITH source
**

	incdir	"include:"

	include exec/types.i
	include exec/lists.i
	include exec/resident.i
	include exec/devices.i
	include exec/execbase.i
	include exec/io.i
	include exec/ports.i
	include exec/initializers.i
	include exec/memory.i
	include exec/errors.i
	include exec/interrupts.i
	include exec/exec_lib.i
	include	libraries/expansion.i
	include	libraries/expansion_lib.i
	include	libraries/configvars.i
	include devices/serial.i
	include	utility/utility.i
	include utility/utility_lib.i

	include "a2232.i"


;
;	Some words about disabling interrupts:
;
;	For short times, the vbi is disabled directly via the hardware
;	register. For longer periods the DisRCnt and DisWCnt counters
;	of the specific unit are used.


******* Constants ***********************************************************

;
;	This Macros is used to generate some delay between accesses to the
;	shared memory on the a2232 which blocks the 6502 cpu on the card.
;
MDELAY	MACRO
	tst.b	$bfe001
	tst.b	$bfe001
	tst.b	$bfe001
	ENDM

;
;	These values are used to check the clock frequency of the ACIAs
;	on the a2232.
;
TimerH_OClk	EQU	$d4
TimerH_DClk	EQU	$ea

;
;	Default values when opening a device unit for the first time.
;
DefReadLen	EQU	8
DefWriteLen	EQU	8
DefStopLen	EQU	1
DefBaud		EQU	9600
DefBufSize	EQU	8192


;
;	Misc.
;
VERSION 	EQU	1
REVISION	EQU	3
DEBUG		EQU	0


	IFGE	DEBUG-1
	XREF	KPrintF
	ENDC


******* Code executed when running from amigados ****************************

	moveq	#-1,d0			; this fails really
	rts


******* Device structure ****************************************************

ROMTag: dc.w	RTC_MATCHWORD
	dc.l	ROMTag
	dc.l	ENDTag
	dc.b	RTF_AUTOINIT
	dc.b	VERSION
	dc.b	NT_DEVICE
	dc.b	0
	dc.l	Name
	dc.l	IDString
	dc.l	Init

Name:
	dc.b	"a2232.device",0

	dc.b	"$VER: "

IDString:
	dc.b	"a2232.device 1.03 (29.11.97)",0
	even


;------ Table for RTF_AUTOINIT ----------------------------------------------

Init:
	dc.l	AS_SizeOf		; DataSize
	dc.l	Init_FuncTable		; Function table
	dc.l	Init_DataTable		; Data table
	dc.l	Init_Func		; Init function


;------ Function table ------------------------------------------------------

Init_FuncTable:
	dc.l	Open			; Open device
	dc.l	Close			; Close device
	dc.l	Expunge 		; Remove device
	dc.l	Null			; Reserved

	dc.l	BeginIO
	dc.l	AbortIO

	dc.l	-1			; End


;------ Data table (initializers) -------------------------------------------

Init_DataTable:
	INITBYTE	LN_TYPE,NT_DEVICE
	INITLONG	LN_NAME,Name
	INITBYTE	LIB_FLAGS,LIBF_SUMUSED|LIBF_CHANGED
	INITWORD	LIB_VERSION,VERSION
	INITWORD	LIB_REVISION,REVISION
	INITLONG	LIB_IDSTRING,IDString
	dc.w		0			; End


;
;	Register fuer Unterroutinen:
;	A5.L = DeviceBase
;	A2.L = IOB
;	A3.L = Unit
;
;

;============================================================================
;   Init_Func : Init function
;
;	   IN : D0.L = Device base
;		A0.L = Dos segment
;
;	  OUT : D0.L = Device ptr, 0 on error
;
;    Register : D0
;
Init_Func:
	PUTDEBUG <"AS: Init: DevBase=$%lx, SegList=$%lx">,d,d0,a,(a0)

	movem.l D1/A0/A1/A5,-(sp)

	move.l	d0,a5			; device base in a5

	move.l	4.w,SysBase		; store execbase for faster access
	move.l	a0,AS_SegList(a5)	; store SegList

	bsr	InitBase		; init device base
	tst.l	d0
	beq	Init_Func_Err		; if error...

	PUTDEBUG <"AS: Init: OK">

	move.l	a5,d0			; return success

Init_Func0:
	movem.l (sp)+,D1/A0/A1/A5
	rts

Init_Func_Err:
	bsr	FreeBase		; free base

	PUTDEBUG <"AS: Init: ERROR">
	moveq	#0,d0			; return error
	bra	Init_Func0


;============================================================================
;	 Open : Open device
;
;	   IN : A6.L = Device base
;		A1.L = IOB
;		D0.L = Unit
;		D1.B = Flags
;
;	  OUT : D0.B = Status
;
;    Register : D0,D1,A0,A1
;
Open:
	PUTDEBUG <"AS: Open: DevBase=$%lx, IOB=$%lx, Unit=%ld, Flags=$%lx">,a,(a6),a,(a1),d,d0,d,d1

	movem.l A2-A6,-(sp)

	move.l	a6,a5			; base in a5
	move.l	a1,a3			; IO in a3
	addq.w	#1,LIB_OPENCNT(a5)	; prevent expunge
;
;	Test if the unit number is ok and if it is already opened
;
	cmp.l	AS_Units(a5),d0 	; unit ok?
	bhs	Open_UnitErr		; if no, branch

	mulu	#ASU_SizeOf,d0		; unit offset in array
	move.l	AS_UnitArray(a5),a2	; get unit array in a2
	add.w	d0,a2			; add offset

	tst.w	ASU_OpenCnt(a2) 	; already opened?
	beq	Open_InitUnit		; if no, branch

	btst	#SERB_SHARED,ASU_IOSerFlags(a2) ; before opened as shared?
	beq	Open_Already		; if not, error

	btst	#SERB_SHARED,IO_SERFLAGS(a3) ; open now as shared?
	beq	Open_Already		; if not, error
;
;	Init IO structure with settings from unit structure
;
	move.l	ASU_RBufLen(a2),IO_RBUFLEN(a3)
	move.b	ASU_IOSerFlags(a2),IO_SERFLAGS(a3)
	move.b	ASU_IOReadLen(a2),IO_READLEN(a3)
	move.b	ASU_IOWriteLen(a2),IO_WRITELEN(a3)
	move.b	ASU_IOStopBits(a2),IO_STOPBITS(a3)
	move.l	ASU_IOBaud(a2),IO_BAUD(a3)

	bra	Open_Shared
;
;	Init unit structure, init IO structure with default params and
;	alloc receive buffer
;
Open_InitUnit:
	move.l	ASU_PV(a2),a4		; hardware
	bsr	InitUnit		; init unit

	move.b	#DefReadLen,IO_READLEN(a3) ; set default params in request
	move.b	#DefWriteLen,IO_WRITELEN(a3)
	move.b	#DefStopLen,IO_STOPBITS(a3)
	move.l	#DefBaud,IO_BAUD(a3)
	move.l	#DefBufSize,IO_RBUFLEN(a3)
	move.l	a3,a1
	bsr	SetUnit 		; set unit params

	tst.b	d0			; status ok?
	bne	Open0			; if no, end
;
;	inc. open counter and set unit in IO structure, clear expunge flag
;
Open_Shared:
	addq.w	#1,LIB_OPENCNT(a5)	; inc device open counter
	addq.w	#1,ASU_OpenCnt(a2)	; inc unit open counter
	move.l	a2,IO_UNIT(a3)		; set unit
	bclr	#LIBB_DELEXP,LIB_FLAGS(a5) ; clear expunge flag
	moveq	#0,d0			; set status to ok

Open0:
	IFGE	DEBUG-1
	moveq	#0,d1
	move.b	d0,d1
	PUTDEBUG <"AS: Open: Return=%ld">,d,d1
	ENDC

	move.b	d0,IO_ERROR(a3) 	; set status in IO
	subq.w	#1,LIB_OPENCNT(a5)	; end of expunge prevention
	movem.l (sp)+,A2-A6
	rts

Open_UnitErr:
	moveq	#IOERR_OPENFAIL,d0
	bra	Open0

Open_Already:
	moveq	#SerErr_DevBusy,d0
	bra	Open0

Open_BufErr:
	moveq	#SerErr_BufErr,d0
	bra	Open0


;============================================================================
;	Close : Close device
;
;	   IN : A6.L = Device base
;		A1.L = IOB
;
;	  OUT : D0.L = SegPtr wenn Unload, sonst 0
;
;    Register : D0,D1,A0,A1
;
Close:
	PUTDEBUG <"AS: Close: DevBase=$%lx, IOB=$%lx">,a,(a1),a,(a6)

	movem.l A2/A3/A5,-(sp)

	move.l	a6,a5			; device base in a5

	move.l	a1,a3			; IO in a3
	move.l	IO_UNIT(a3),a2		; unit in A2

	moveq	#-1,d0
	move.l	d0,IO_UNIT(a3)		; clear unit and device
	move.l	d0,IO_DEVICE(a3)

	subq.w	#1,ASU_OpenCnt(a2)	; dec unit open counter
	bne	Close_NoExpUnit 	; if not null, branch

	bsr	FreeUnit		; free unit

Close_NoExpUnit:
	moveq	#0,d0			; clear status

	subq.w	#1,LIB_OPENCNT(a5)	; dec device open counter
	bne	Close0			; if not null, branche

	btst	#LIBB_DELEXP,LIB_FLAGS(a5) ; delayed expunge?
	beq	Close0			; if not, branch

	bsr	Expunge 		; expunge unit

Close0:
	movem.l (sp)+,A2/A3/A5
	rts


;============================================================================
;     Expunge : Expunge device
;
;	   IN : A6.L = Device base
;
;	  OUT : D0.L = SegPtr if unload, else null
;
;    Register : D0,D1,A0,A1
;
Expunge:
	PUTDEBUG <"AS: Expunge: DevBase=$%lx">,a,(a6)

	tst.w	LIB_OPENCNT(a6) 	; device still opened?
	beq	Expunge_Do		; if not, branch

	bset	#LIBB_DELEXP,LIB_FLAGS(a6) ; set flag for delayed expunge
	moveq	#0,d0			; set return to null
	bra	Expunge0		; end

Expunge_Do:
	exg	a6,a5			; base in a5
	bsr	FreeBase		; free device
	exg	a5,a6			; base in a6

	move.l	a6,-(sp)		; store base on stack
	move.l	AS_SegList(a6),-(sp)	; store SegList on stack

	move.l	a6,a1			; base in a1
	move.l	SysBase(pc),a6		; get execbase
	jsr	_LVORemove(a6)		; remove device node

	move.l	4(sp),a1		; get device base
	moveq	#0,d0			; calc size
	move.w	LIB_NEGSIZE(a1),d0
	move.w	LIB_POSSIZE(a1),d1
	sub.l	d0,a1
	add.w	d1,d0
	jsr	_LVOFreeMem(a6) 	; free device node

	move.l	(sp)+,d0		; get seglist and
	move.l	(sp)+,a6		; base from stack

Expunge0:
	rts


;============================================================================
;	 Null : Do nothing - return 0
;
;	   IN : A6.L = DeviceBase
;
;	  OUT : D0.L = Success
;
;    Register : D0
;
Null:
	moveq	#0,d0
	rts


;============================================================================
;     BeginIO : Start an IO request
;
;	   IN : A6.L = Device base
;		A1.L = IOB
;
;	  OUT :
;
;    Register : D0,D1,A0,A1
;
BeginIO:
	movem.l A2/A5,-(sp)

	move.l	a6,a5			; device base in a5
	move.l	IO_UNIT(a1),a2		; unit in a2

	move.b	#NT_MESSAGE,LN_TYPE(a1) ; set msg type to message
	clr.b	IO_ERROR(a1)		; clear status
	and.b	#~(IOSERF_QUEUED|IOSERF_ACTIVE),IO_FLAGS(a1) ; set flags

	move.w	IO_COMMAND(a1),d0	; get command
	add.w	d0,d0			; *2
	cmp.w	#BeginIO_CTab_End-BeginIO_CTab,d0 ; invalid?
	bhs	BeginIO_InvCmd		; if yes, branch

	move.w	BeginIO_CTab(pc,d0.w),d0 ; get function offset

	move.l	SysBase(pc),a6		; get execbase

	lea	ASU_Semaphore(a2),a0	; obtain semaphore
	jsr	_LVOObtainSemaphore(a6)

	jsr	BeginIO_CTab(pc,d0.w)	; call function

	lea	ASU_Semaphore(a2),a0	; release semaphore
	jsr	_LVOReleaseSemaphore(a6)

	tst.l	d0			; request finished?
	bne	BeginIO_NotDone 	; if not, branch

BeginIO_Done:
	btst	#IOB_QUICK,IO_FLAGS(a1) ; quick?
	bne	BeginIO0		; if yes, end

	jsr	_LVOReplyMsg(a6)	; reply msg

BeginIO_NotDone:
	bclr	#IOB_QUICK,IO_FLAGS(a1) ; if not finished, clear quick flag

BeginIO0:
	move.l	a5,a6			; device base in a6
	movem.l (sp)+,A2/A5
	rts

BeginIO_InvCmd:
	PUTDEBUG <"AS: Invalid command!">
	move.b	#IOERR_NOCMD,IO_ERROR(a1)	; invalid command
	bra	BeginIO_Done

BeginIO_CTab:
	dc.w	CInvalid-BeginIO_CTab	; CMD_INVALID
	dc.w	CReset-BeginIO_CTab	; CMD_RESET
	dc.w	CRead-BeginIO_CTab	; CMD_READ
	dc.w	CWrite-BeginIO_CTab	; CMD_WRITE
	dc.w	CInvalid-BeginIO_CTab	; CMD_UPDATE
	dc.w	CClear-BeginIO_CTab	; CMD_CLEAR
	dc.w	CInvalid-BeginIO_CTab	; CMD_START
	dc.w	CInvalid-BeginIO_CTab	; CMD_STOP
	dc.w	CFlush-BeginIO_CTab	; CMD_FLUSH
	dc.w	CQuery-BeginIO_CTab	; SDCMD_QUERY
	dc.w	CBreak-BeginIO_CTab	; SDCMD_BREAK
	dc.w	CSet-BeginIO_CTab	; SDCMD_SETPARAS
BeginIO_CTab_End:


;============================================================================
;     AbortIO : Abort an IO request.
;
;	   IN : A6.L = Device base
;		A1.L = IOB
;
;	  OUT :
;
;    Register : D0,D1,A0,A1
;
AbortIO:
	IFGE	DEBUG-1
	moveq	#0,d0
	move.w	IO_COMMAND(a1),d0
	move.l	IO_LENGTH(a1),d1
	PUTDEBUG <"AS: AbortIO: IOB=$%lx, CMD=%ld, LENGTH=%ld">,a,(a1),d,d0,d,d1
	ENDC

	move.l	A2,-(sp)
	move.l	A6,-(sp)

	move.l	IO_UNIT(a1),a2		; unit in a2

	move.l	SysBase(pc),a6		; get execbase

	lea	ASU_Semaphore(a2),a0	; obtain semaphore
	jsr	_LVOObtainSemaphore(a6)

	btst	#IOSERB_QUEUED,IO_FLAGS(a1) ; request still in queue?
	bne	AbortIO_Remove		; if yes, remove it

	move.w	IO_COMMAND(a1),d0	; get command
	subq.w	#CMD_READ,d0		; READ?
	beq	AbortIO_Read		; if yes, branch

	subq.w	#CMD_WRITE-CMD_READ,d0	; WRITE?
	beq	AbortIO_Write		; if yes, branch

	subq.w	#SDCMD_BREAK-CMD_WRITE,d0 ; BREAK?
	beq	AbortIO_Break		; if yes, branch

AbortIO0:
	lea	ASU_Semaphore(a2),a0	; release semaphore
	jsr	_LVOReleaseSemaphore(a6)

	move.l	(sp)+,A6
	move.l	(sp)+,A2
	rts

AbortIO_Remove: 			; remove request from queue
	move.l	a1,d0
	REMOVE
	move.l	d0,a1
	bra	AbortIO_Reply

AbortIO_Done:
	btst	#IOSERB_ACTIVE,IO_FLAGS(a1) ; request still active?
	beq	AbortIO0		; if not, branch

AbortIO_Reply:
	move.b	#IOERR_ABORTED,IO_ERROR(a1)	; set status & flags
	move.b	IO_FLAGS(a1),d0
	bset	#IOSERB_ABORT,d0
	and.b	#~(IOSERF_QUEUED|IOSERF_ACTIVE),d0
	move.b	d0,IO_FLAGS(a1)
	btst	#IOB_QUICK,d0		; quick?
	bne	AbortIO0		; if yes, end

	jsr	_LVOReplyMsg(a6)	; reply msg
	bra	AbortIO0		; end


;------ Abort an active read request ----------------------------------------

AbortIO_Read:
	DISVBI				; disable vbi

	btst	#IOSERB_ACTIVE,IO_FLAGS(a1) ; still active?
	beq	AbortIO_Read0		; if not, branch

	clr.l	ASU_ReadReq(a2) 	; clear active read request
	move.l	ASU_ReadPtr(a2),d1	; calc number of bytes already read
	sub.l	IO_DATA(a1),d1
	move.l	d1,IO_ACTUAL(a1)	; as actual

AbortIO_Read0:
	ENAVBI				; enable vbi
	bra	AbortIO_Done		; done


;------ Abort an active write request ---------------------------------------

AbortIO_Write:
	DISVBI				; disable vbi

	btst	#IOSERB_ACTIVE,IO_FLAGS(a1) ; still active?
	beq	AbortIO_Write0		; if not, branch

	clr.l	ASU_WriteReq(a2)	; clear active write request
	clr.l	ASU_WriteCnt(a2)	; clear write count
	move.l	ASU_WritePtr(a2),d1	; calc number of bytes already sent
	sub.l	IO_DATA(a1),d1
	move.l	d1,IO_ACTUAL(a1)	; as actual

AbortIO_Write0:
	ENAVBI				; enable vbi
	bra	AbortIO_Done		; done


;------ Abort a break request (not implemented yet) -------------------------

AbortIO_Break:
	bra	AbortIO_Done		; done


;============================================================================
;    CInvalid : CMD_INVALID: Unknown command
;
;	   IN : A5.L = Device base
;		A6.L = SysBase
;		A1.L = IOB
;		A2.L = Unit
;
;	  OUT : D0.L = 0 -> request finished
;		D0.L != 0 -> request queued
;
;    Register : D0, D1, A0
;
CInvalid:
	PUTDEBUG <"AS: CMD_INVALID: IOB=$%lx">,a,(a1)

	move.b	#IOERR_NOCMD,IO_ERROR(a1) ; set return to error
	moveq	#0,d0			; done
	rts


;============================================================================
;      CReset : CMD_RESET: Reset serial port, abort all active and queued
;		requests, clear receive and send buffer.
;
;	   IN : A5.L = Device base
;		A6.L = SysBase
;		A1.L = IOB
;		A2.L = Unit
;
;	  OUT : D0.L = 0 -> request finished
;		D0.L != 0 -> request queued
;
;    Register : D0, D1, A0
;
CReset:
	PUTDEBUG <"AS: CMD_RESET: IOB=$%lx">,a,(a1)

	move.l	d2,-(sp)
	move.l	a1,-(sp)

	addq.b	#1,ASU_DisRCnt(a2)	; disable read irq
	addq.b	#1,ASU_DisWCnt(a2)	; disable write irq

	bsr	CFlush			; abort all queued requests

	exg	a5,a6			; DevBase in a6

	move.l	ASU_ReadReq(a2),d0	; get active read request
	beq	CReset_NoRead		; if none, branch

	move.l	d0,a1			; request in a1
	bsr	AbortIO 		; abort it

CReset_NoRead:
	move.l	ASU_WriteReq(a2),d0	; get active write request
	beq	CReset_NoWrite		; if none, branch

	move.l	d0,a1			; request in a1
	bsr	AbortIO 		; abort it

CReset_NoWrite:
	exg	a5,a6
	move.l	(sp)+,a1		; io request in a1

	bsr	IClear			; clear receive buffer
	bsr	OClear			; clear send buffer

	bsr	SetUnit 		; set params
	move.b	d0,IO_ERROR(a1) 	; set return

	subq.b	#1,ASU_DisRCnt(a2)	; enable read irq
	subq.b	#1,ASU_DisWCnt(a2)	; enable write irq

	moveq	#0,d0			; done
	move.l	(sp)+,d2
	rts


;============================================================================
;      CFlush : CMD_FLUSH: Abort all queued requests
;
;	   IN : A5.L = Device base
;		A6.L = SysBase
;		A1.L = IOB
;		A2.L = Unit
;
;	  OUT : D0.L = 0 -> request finished
;		D0.L != 0 -> request queued
;
;    Register : D0, D1, A0
;
CFlush:
	PUTDEBUG <"AS: CMD_FLUSH: IOB=$%lx">,a,(a1)

	movem.l D2/A1/A3,-(sp)

	addq.b	#1,ASU_DisRCnt(a2)	; disable read irq
	addq.b	#1,ASU_DisWCnt(a2)	; disable write irq

	lea	ASU_ReadQueue(a2),a3	; read queue
	bsr	CFlush_RA		; reply all requests

	lea	ASU_WriteQueue(a2),a3	; write queue
	bsr	CFlush_RA		; reply all requests

	subq.b	#1,ASU_DisRCnt(a2)	; enable read irq
	subq.b	#1,ASU_DisWCnt(a2)	; enable write irq

	moveq	#0,d0			; done
	movem.l (sp)+,D2/A1/A3
	rts

CFlush_RA:
	move.l	a3,a0			; start of list
	jsr	_LVORemHead(a6) 	; remove first node
	tst.l	d0			; if none,
	beq	CFlush_RA0		; done

	move.l	d0,a1			; node in a1
	bclr	#IOSERB_QUEUED,IO_FLAGS(a1) ; set flags
	move.b	#IOERR_ABORTED,IO_ERROR(a1) ; set status
	jsr	_LVOReplyMsg(a6)	; reply
	bra	CFlush_RA		; next node

CFlush_RA0:
	rts


;============================================================================
;      CClear : CMD_CLEAR: Clear receive buffer
;
;	   IN : A5.L = Device base
;		A6.L = SysBase
;		A1.L = IOB
;		A2.L = Unit
;
;	  OUT : D0.L = 0 -> request finished
;		D0.L != 0 -> request queued
;
;    Register : D0, D1, A0
;
CClear:
	PUTDEBUG <"AS: CMD_CLEAR: IOB=$%lx">,a,(a1)

	bsr	IClear			; clear buffer
	moveq	#0,d0			; done
	rts
;
;	Clear receive buffer and shared ram ring buffer
;
IClear:
	DISVBI				; disable vbi

	move.l	ASU_RBuf(a2),a0 	; begin of receive buffer
	move.l	a0,ASU_RBufInPtr(a2)	; set as "in"
	move.l	a0,ASU_RBufOutPtr(a2)	; and "out"
	move.l	ASU_PV(a2),a0		; get port control block
	move.b	PV_InHead(a0),PV_InTail(a0) ; clear ring buffer

	ENAVBI				; enable vbi
	rts
;
;	Clear send buffer in shared ram
;
OClear:
	move.l	ASU_PV(a2),a0		; get port control block
	st	PV_OutFlush(a0)
	rts


;============================================================================
;	CRead : CMD_READ: Read bytes
;
;	   IN : A5.L = Device base
;		A6.L = SysBase
;		A1.L = IOB
;		A2.L = Unit
;
;	  OUT : D0.L = 0 -> request finished
;		D0.L != 0 -> request queued
;
;    Register : D0, D1, A0
;
CRead:
	IFGE	DEBUG-1
	move.l	IO_DATA(a1),a0
	move.l	IO_LENGTH(a1),d0
	PUTDEBUG <"AS: CMD_READ: DATA=$%lx, LENGTH=%ld">,a,(a0),d,d0
	ENDC

	clr.l	IO_ACTUAL(a1)		; clear number of bytes read
	move.l	IO_LENGTH(a1),d0	; get number of bytes to read
	beq	CRead0			; if null, end

	tst.l	ASU_ReadReq(a2) 	; another read request active?
	bne	CRead_Queue		; if yes, queue this request

	move.l	IO_DATA(a1),ASU_ReadPtr(a2) ; set read ptr
	move.l	d0,ASU_ReadCnt(a2)	; set bytes left

CRead_Loop:
	move.l	a1,-(sp)
	bsr	CopyRead		; copy bytes
	move.l	(sp)+,a1

	PUTDEBUG <"AS: CMD_READ: Copied from buffer. %ld bytes left">,d,d0

	tst.l	d0			; all bytes copied?
	beq	CRead_Done		; if yes, branch

	DISVBI				; disable vbi

	move.l	ASU_RBufInPtr(a2),a0	; new bytes written by irq in buffer?
	cmp.l	ASU_RBufOutPtr(a2),a0
	beq	CRead_SetAct		; branch if not

	ENAVBI				; enable vbi
	bra	CRead_Loop

CRead_SetAct:
	bset	#IOSERB_ACTIVE,IO_FLAGS(a1) ; set active flag
	move.l	a1,ASU_ReadReq(a2)	; set active request

	ENAVBI				; enable vbi

CRead0:
	rts
;
;	read request finished from receive buffer
;
CRead_Done:
	move.l	IO_LENGTH(a1),IO_ACTUAL(a1) ; set number of bytes read
	bra	CRead0			; end
;
;	queue a read request
;
CRead_Queue:
	bset	#IOSERB_QUEUED,IO_FLAGS(a1) ; set queued flag

	lea	ASU_ReadQueue(a2),a0	; read queue
	move.l	a1,d1			; save request

	DISVBI				; disable vbi

	ADDTAIL 			; add node at end

	PUTDEBUG <"AS: CMD_READ: Request queued.">

	ENAVBI				; enable vbi

	move.l	d1,a1

	moveq	#1,d0			; set flag to not done
	bra	CRead0


;============================================================================
;      CWrite : CMD_WRITE: Write bytes
;
;	   IN : A5.L = Device base
;		A6.L = SysBase
;		A1.L = IOB
;		A2.L = Unit
;
;	  OUT : D0.L = 0 -> request finished
;		D0.L != 0 -> request in queued
;
;    Register : D0, D1, A0
;
CWrite:
	IFGE	DEBUG-1
	move.l	IO_DATA(a1),a0
	move.l	IO_LENGTH(a1),d0
	PUTDEBUG <"AS: CMD_WRITE: DATA=$%lx, LENGTH=%ld">,a,(a0),d,d0
	ENDC

	clr.l	IO_ACTUAL(a1)		; clear number of bytes written
	move.l	IO_LENGTH(a1),d0	; get number of bytes to write
	beq	CWrite0 		; if null, end

	tst.l	ASU_WriteReq(a2)	; another write request active?
	bne	CWrite_Queue		; if yes, queue this request

	move.l	A1,-(sp)
	move.l	IO_DATA(a1),ASU_WritePtr(a2) ; set write ptr
	move.l	d0,ASU_WriteCnt(a2)	; set bytes left
	bsr	CopyWrite		; copy bytes
	move.l	(sp)+,A1

	tst.l	d0			; all bytes copied?
	beq	CWrite_Done		; if yes, branch

	bset	#IOSERB_ACTIVE,IO_FLAGS(a1) ; set active flag
	move.l	a1,ASU_WriteReq(a2)	; set active request

CWrite0:
	rts
;
;	write request finished in output buffer
;
CWrite_Done:
	move.l	IO_LENGTH(a1),IO_ACTUAL(a1) ; set number of bytes written
	bra	CWrite0 		; end
;
;	queue a write request
;
CWrite_Queue:
	bset	#IOSERB_QUEUED,IO_FLAGS(a1) ; set queued flag

	lea	ASU_WriteQueue(a2),a0	; write queue
	move.l	a1,d1			; save request

	DISVBI				; disable vbi

	ADDTAIL 			; add node at end

	ENAVBI				; enable vbi

	move.l	d1,a1

	moveq	#1,d0			; set flag to not done
	bra	CWrite0


;============================================================================
;      CQuery : CMD_QUERY: Return status
;
;	   IN : A5.L = Device base
;		A6.L = SysBase
;		A1.L = IOB
;		A2.L = Unit
;
;	  OUT : D0.L = 0 -> request finished
;		D0.L != 0 -> request queued
;
;    Register : D0, D1, A0
;
CQuery:
	moveq	#0,d0
	move.l	ASU_Board(a2),a0	; board address

	move.b	ASU_UnitNum(a2),d1	; get unit number on board
	btst	d1,SR_CDStatus(a0)	; test CD
	beq	1$			; ok

	bset	#5,d0			; set CD in status

1$:
	move.w	d0,IO_STATUS(a1)	; set status

	move.l	ASU_RBufInPtr(a2),d0	; get in ptr
	sub.l	ASU_RBufOutPtr(a2),d0	; calc used bytes
	bpl	2$

	add.l	ASU_RBufLen(a2),d0

2$:
	move.l	d0,IO_ACTUAL(a1)	; set number of bytes in rec buffer

	PUTDEBUG <"AS: SDCMD_QUERY: Ret ACTUAL=%ld">,d,d0

	moveq	#0,d0			; finished
	rts


CBreak:
	PUTDEBUG <"AS: SDCMD_BREAK">
	moveq	#0,d0
	rts


;============================================================================
;        CSet : Set params
;
;	   IN : A5.L = Device base
;		A6.L = SysBase
;		A1.L = IOB
;		A2.L = Unit
;
;	  OUT : D0.L = 0 -> request finished
;		D0.L != 0 -> request queued
;
;    Register : D0, D1, A0
;
CSet:
	PUTDEBUG <"AS: SDCMD_SETPARAMS">

	bsr	SetUnit			; set params
	move.b	d0,IO_ERROR(a1)		; Status setzen

	moveq	#0,d0			; fertig
	rts


;============================================================================
;   CopyWrite : Copy bytes for the active write request from amiga memory
;		into the output ringbuffer of the a2232.
;
;	   IN : A2.L = Unit
;
;	  OUT : D0.L = Number of bytes left to write
;
;    Register : D0,D1,A0,A1
;
CopyWrite:
	movem.l D2/A3,-(sp)

	move.l	ASU_PV(a2),a1		; port control block
	move.l	ASU_WriteCnt(a2),d0	; get write cnt

	moveq	#0,d1
	move.b	PV_OutTail(a1),d1	; tail ptr

	moveq	#0,d2
	move.b	PV_OutHead(a1),d2	; get head ptr

	sub.b	d2,d1			; calc bytes free
	subq.b	#1,d1			; -1 wg. abstand
	subq.w	#1,d1			; -1 wg. dbeq
	bmi	CopyWrite0		; no space

	move.l	ASU_OBuf(a2),a3 	; output ring buffer
	move.l	ASU_WritePtr(a2),a0	; get write ptr

CopyWrite_Loop:
	MDELAY
	move.b	(a0)+,(a3,d2.w) 	; put byte in buffer
	addq.b	#1,d2			; inc ptr
	subq.l	#1,d0			; dec bytes left
	dbeq	d1,CopyWrite_Loop	; next byte

	move.b	d2,PV_OutHead(a1)	; set new head

	move.l	d0,ASU_WriteCnt(a2)	; set bytes left to write
	move.l	a0,ASU_WritePtr(a2)	; set write ptr

CopyWrite0:
	movem.l (sp)+,D2/A3
	rts


;============================================================================
;    CopyRead : Copy data from receiver buffer to destination.
;
;	   IN : A2.L = Unit
;
;	  OUT : D0.L = number of bytes left
;
;    Register : D0,D1,A0,A1
;
CopyRead:
	move.l	d2,-(sp)

	move.l	ASU_ReadCnt(a2),d0	; bytes to read in d0
	move.l	ASU_ReadPtr(a2),a0	; read ptr in a0

	move.l	ASU_RBufOutPtr(a2),a1	; receive buffer "out" ptr
	move.l	ASU_RBufInPtr(a2),d1	; receive buffer "in" ptr
	move.l	ASU_RBufEnd(a2),d2	; receive buffer end address

	PUTDEBUG <"AS: CopyRead: START: Head=%ld Tail=%ld Cnt=%ld">,d,d1,d,a1,d,d0

	bra	CopyRead_InLoop

CopyRead_CopyLoop2:
	swap	d0

CopyRead_CopyLoop:
	move.b	(a1)+,(a0)+		; copy one byte
	cmp.l	d2,a1			; end of buffer?
	bhs	CopyRead_BufEnd 	; if yes, branch

CopyRead_InLoop:
	cmp.l	a1,d1			; buffer empty?
	dbeq	d0,CopyRead_CopyLoop	; next byte
	beq	CopyRead_End		; buffer empty
	swap	d0			; get high word
	dbf	d0,CopyRead_CopyLoop2	; next byte

	moveq	#0,d0			; no bytes left

CopyRead_End:
	move.l	a1,ASU_RBufOutPtr(a2)	; store receive buffer "out"
	move.l	d0,ASU_ReadCnt(a2)	; store bytes left to read
	move.l	a0,ASU_ReadPtr(a2)	; store read ptr

	PUTDEBUG <"AS: CopyRead: END: Head=%ld Tail=%ld Cnt=%ld">,d,d1,d,a1,d,d0

	move.l	(sp)+,D2
	rts

CopyRead_BufEnd:
	move.l	ASU_RBuf(a2),a1
	bra	CopyRead_InLoop


;============================================================================
;    InitBase : Init device base
;		- get number of installed a2232 boards and allocate
;		  appropiate unit array
;		- transfer 6502 driver code to boards
;		- open utility.library
;		- install vbi interrupt server
;
;	   IN : A5.L = Device base
;
;	  OUT : D0.L = Success
;
;    Register : D0,D1,A0,A1
;
InitBase:
	movem.l	D2/A2-A4/A6,-(sp)

	move.l	a5,IntNode+IS_DATA	; set device base as data for int
	move.l	SysBase(pc),a6		; get execBase

;
;	Open libraries
;
	moveq	#0,d0
	lea	UtilityName(pc),a1	; open utility.library
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,AS_UtilityBase(a5)	; store base
	beq	InitBase0		; if error, end

	moveq	#0,d0			; open expansion.library
	lea	ExpansionName(pc),a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,AS_ExpBase(a5)
	beq	InitBase0

;
;	Get addresses of a2232 boards installed
;
	moveq	#0,d2			; board counter
	lea	AS_BoardArray(a5),a2	; destination for board addresses
	move.l	AS_ExpBase(a5),a6	; get expbase
	sub.l	a0,a0			; start from first board

InitBase_BoardLoop:
	move.w	#A2232_Man,d0		; manufacturer
	move.w	#A2232_Prod,d1		; product
	jsr	_LVOFindConfigDev(a6)
	tst.l	d0
	beq	InitBase_BoardEnd	; no more boards

	move.l	d0,a0			; configdev into a0
	move.l	cd_BoardAddr(a0),(a2)+	; store board address
	addq.w	#1,d2			; inc counter
	bra	InitBase_BoardLoop	; next board

InitBase_BoardEnd:
	PUTDEBUG <"AS: InitBase: %ld a2232 boards found.">,d,d2

	move.w	d2,AS_Boards(a5)	; store number of boards
	mulu	#AS_BoardUnits,d2	; calc number of available units
	move.l	d2,AS_Units(a5)		; store it

	PUTDEBUG <"AS: InitBase: Initializing %ld units.">,d,d2

;
;	alloc memory for ASU unit structs and initialize it
;
	mulu	#ASU_SizeOf,d2		; calc bytes for ASU structs
	move.l	d2,d0

	move.l	#MEMF_PUBLIC|MEMF_CLEAR,d1 ; Req.
	move.l	SysBase(pc),a6
	jsr	_LVOAllocMem(a6)	; allocate mem
	move.l	d0,AS_UnitArray(a5)	; set as unit array
	beq	InitBase0		; if error, end

	move.l	d0,a2			; unit array in a2
	lea	AS_BoardArray(a5),a1	; board array in a1
	move.w	AS_Boards(a5),d2	; number of boards
	bra	InitBase_InBLoop	; start loop

InitBase_BLoop:
	move.l	(a1),a0			; board address

	PUTDEBUG <"AS: InitBase: Loading code to board at $%lx.">,a,(a0)

	bsr	LoadCode		; load 65c02 code
	
	moveq	#0,d1			; set unit counter
	lea	SR_OBuf(a0),a3		; unit output buffer
	lea	SR_IBuf(a0),a4		; unit input buffer

InitBase_ULoop:
	PUTDEBUG <"AS: InitBase: Initializing unit at $%lx.">,a,(a2)

	st	ASU_DisRCnt(a2) 	; disable read irq
	st	ASU_DisWCnt(a2) 	; disable write irq

	move.l	(a1),ASU_Board(a2)	; set board address
	move.l	a0,ASU_PV(a2)		; set unit control
	move.l	a3,ASU_OBuf(a2)		; set unit output buffer
	move.l	a4,ASU_IBuf(a2)		; set unit input buffer
	move.b	d1,ASU_UnitNum(a2)	; set unit number on board

	move.b	d0,ASU_Clock(a2)	; set clock type

	lea	PV_SizeOf(a0),a0	; inc addresses
	lea	$100(a3),a3
	lea	$100(a4),a4
	lea	ASU_SizeOf(a2),a2

	addq.b	#1,d1			; next unit
	cmp.b	#AS_BoardUnits,d1	; reached max. on board?
	blo	InitBase_ULoop		; if not, next

	addq.w	#4,a1			; next board address

InitBase_InBLoop:
	dbf	d2,InitBase_BLoop	; next board

;
;	Add vbi server
;
	lea	IntNode(pc),a1		; interrupt node
	moveq	#INTB_VERTB,d0		; interrupt id
	jsr	_LVOAddIntServer(a6)	; add server

	bset	#ASB_IntSet,AS_Flags(a5) ; set flag for server

	moveq	#-1,d0			; return success

InitBase0:
	movem.l	(sp)+,D2/A2-A4/A6
	rts


;============================================================================
;    FreeBase : Remove device:
;		- reset all boards
;		- remove interrupt server
;		- close utility.library
;		- free memory
;
;	   IN : A5.L = Device base
;
;	  OUT :
;
;    Register : D0,D1,A0,A1
;
FreeBase:
	move.l	a6,-(sp)

	move.l	SysBase(pc),a6

	bclr	#ASB_IntSet,AS_Flags(a5) ; interrupt server installed?
	beq	FreeBase_NoInt		; if not, skip this

	lea	IntNode(pc),a1		; node
	moveq	#INTB_VERTB,d0		; id
	jsr	_LVORemIntServer(a6)	; remove it

FreeBase_NoInt:
	moveq	#AS_MaxBoards-1,d0	; reset all boards
	lea	AS_BoardArray(a5),a0	; array with board addrs.

FreeBase_ResLoop:
	move.l	(a0)+,d1		; get board addr.
	beq	FreeBase_EndBoards	; no more boards

	move.l	d1,a1
	add.l	#SR_EnaRes,a1
	tst.w	(a1)			; RESET board

	dbf	d0,FreeBase_ResLoop	; next board

FreeBase_EndBoards:
	move.l	AS_UtilityBase(a5),d0	; get utilitiy libbase
	beq	FreeBase_NoUtilLib	; if not open, branch

	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)	; close library

FreeBase_NoUtilLib:
	move.l	AS_ExpBase(a5),d0	; get expansion libbase
	beq	FreeBase_NoExpLib	; if not open, branch

	move.l	d0,a1
	jsr	_LVOCloseLibrary(a6)

FreeBase_NoExpLib:
	move.l	AS_UnitArray(a5),d0	; get unit array
	beq	FreeBase0		; if not allocated, skip

	move.l	d0,a1			; nach a1
	move.l	AS_Units(a5),d0 	; calc size
	mulu	#ASU_SizeOf,d0
	jsr	_LVOFreeMem(a6) 	; free memory

FreeBase0:
	move.l	(sp)+,a6
	rts


;============================================================================
;    LoadCode : Transfer 65c02 driver code to a2232 board and wait for board
;		startup.
;
;	   IN : A0.L = Board address
;
;	  OUT : D0.B = Status (ClockType)
;
;    Register :
;
LoadCode:
	movem.l A1-A3,-(sp)

	lea	Code6502,a1
	lea	Code6502_End,a2
	lea	$6000(a0),a3
	tst.w	SR_EnaRes-$6000(a3)	; RESET 65c02

	clr.b	SR_TimerH(a0)		; clear timer high

LoadCode_Loop:
	cmp.l	a2,a1			; end of code?
	bhs	LoadCode_end		; if yes, end

	moveq	#0,d0			: get 16bit start address into d0
	move.b	1(a1),d0
	lsl.w	#8,d0
	move.b	(a1),d0
	lea	(a0,d0.l),a3		; map it into amiga address space

	move.b	3(a1),d0		; get length of code segment int d0
	lsl.w	#8,d0
	move.b	2(a1),d0
	addq.w	#4,a1
	bra	LoadCode_InCopy 	; start copy

LoadCode_Copy:
	move.b	(a1)+,(a3)+		; copy
LoadCode_InCopy:
	dbf	d0,LoadCode_Copy

	bra	LoadCode_Loop

LoadCode_end:
	lea	$6000(a0),a3
	tst.w	SR_ResBoard-$6000(a3)	; reset board and startup

LoadCode_Wait:
	move.b	SR_TimerH(a0),d0	; wait for board startup
	beq	LoadCode_Wait

	cmp.b	#TimerH_DClk,d0		; double clock?
	bhs	1$			; if yes, branch

	cmp.b	#TimerH_OClk,d0		; orig. clock?
	bhs	2$			; if yes, branch

	moveq	#ASU_ClockHalf,d0	; clock type

3$:
	movem.l (sp)+,A1-A3
	rts

1$:
	moveq	#ASU_ClockDbl,d0
	bra	3$

2$:
	moveq	#ASU_ClockOrig,d0
	bra	3$


;============================================================================
;    InitUnit : Init device unit
;		- init queues
;		- init control regs
;
;	   IN : A2.L = Unit
;		A5.L = Device base
;
;	  OUT :
;
;    Register : D0,D1,A0,A1
;
InitUnit:
	move.l	a6,-(sp)

;
;	init queues
;
	lea	ASU_ReadQueue(a2),a0
	NEWLIST a0
	lea	ASU_WriteQueue(a2),a0
	NEWLIST a0

;
;	init semaphore
;
	lea	ASU_Semaphore(a2),a0	; Semaphore
	move.l	SysBase(pc),a6
	jsr	_LVOInitSemaphore(a6)	; initialisieren

;
;	allow irq handling
;
	clr.b	ASU_DisRCnt(a2)
	clr.b	ASU_DisWCnt(a2)

	move.l	(sp)+,a6
	rts


;============================================================================
;     SetUnit : Set unit params
;		- allocate receiver buffer
;		- set hardware control regs (mirrored in shared ram)
;
;	   IN : A1.L = IO
;		A2.L = Unit
;		A5.L = Device base
;
;	  OUT : D0.B = Status, if not null an error has occured
;
;    Register : D0,D1,A0
;
SetUnit:
	movem.l D2/A3/A4/A6,-(sp)

	move.l	a1,a3			; IO in a3

	move.l	ASU_PV(a2),a4		; address of port control block

	addq.b	#1,ASU_DisRCnt(a2)	; disable read irq

;
;	alloc receive buffer
;
	move.l	ASU_RBuf(a2),d1 	; get actual buffer address
	beq	SetUnit_AllocBuf	; if null, allocate new

	move.l	ASU_RBufLen(a2),d0	; get actual length
	cmp.l	IO_RBUFLEN(a3),d0	; equal to new one?
	beq	SetUnit_NoBuf		; if yes, alloc no new buffer

SetUnit_AllocBuf:
	move.l	IO_RBUFLEN(a3),d0	; new length
	move.l	#MEMF_PUBLIC,d1
	move.l	SysBase(pc),a6		; get execbase
	jsr	_LVOAllocMem(a6)	; allocate
	tst.l	d0			; ok?
	beq	SetUnit_BufErr		; if not, branch

	move.l	ASU_RBuf(a2),d1 	; switch to new buffer
	move.l	d0,ASU_RBuf(a2)
	add.l	IO_RBUFLEN(a3),d0
	move.l	d0,ASU_RBufEnd(a2)
	move.l	ASU_RBufLen(a2),d0
	move.l	IO_RBUFLEN(a3),ASU_RBufLen(a2)

	tst.l	d1			; free old buffer?
	beq	SetUnit_NoFreeBuf	; if not, branch

	move.l	d1,a1
	jsr	_LVOFreeMem(a6)

SetUnit_NoFreeBuf:
	bsr	IClear			; flush hardware rec buffer

SetUnit_NoBuf:
;
;	set data format
;
	moveq	#0,d0
	move.b	IO_READLEN(a3),d0	; get readlen
	cmp.b	IO_WRITELEN(a3),d0	; equal writelen?
	bne	SetUnit_InvPar		; if not, error

	cmp.b	#8,d0			; len > 8
	bhi	SetUnit_InvPar		; if yes, error

	subq.b	#5,d0			; len < 5 ?
	bmi	SetUnit_InvPar		; if yes, error

	eor.b	#3,d0
	lsl.b	#5,d0

	move.b	IO_STOPBITS(a3),d1	; get num stopbits
	subq.b	#1,d1			; -1
	bmi	SetUnit_InvPar		; < 1 -> error
	cmp.b	#1,d1			; > 1?
	bhi	SetUnit_InvPar		; if yes, error
	
	lsl.b	#7,d1
	or.b	d1,d0
	bset	#4,d0			; use baud gen. for rx clock

	moveq	#0,d1
	move.b	ASU_Clock(a2),d1	; get clocktype
	lsl.w	#6,d1			; x64

	lea	SetUnit_BaudTab(pc),a0	; Baudtab
	add.w	d1,a0			; add offset

	moveq	#15,d1			; counter

SetUnit_BLoop:
	move.l	(a0)+,d2		; get next rate
	cmp.l	IO_BAUD(a3),d2		; rate okay?
	dbeq	d1,SetUnit_BLoop
	bne	SetUnit_BaudErr		; invalid rate

	or.b	d1,d0			; or rate to param
	move.b	d0,PV_Param(a4) 	; set param

	move.b	IO_READLEN(a3),ASU_IOReadLen(a2) ; store par. in unit struct
	move.b	IO_WRITELEN(a3),ASU_IOWriteLen(a2)
	move.b	IO_STOPBITS(a3),ASU_IOStopBits(a2)
	move.l	IO_BAUD(a3),ASU_IOBaud(a2)

	moveq	#$0b,d0			; calc command reg data

	move.b	IO_SERFLAGS(a3),d1	; get serflags
	move.b	d1,ASU_IOSerFlags(a2)	; store in unit structure

	btst	#SERB_PARTY_ON,d1	; parity?
	beq	SetUnit_OddPar		; if not, branch

	bset	#5,d0			; set parity bit

	btst	#SERB_PARTY_ODD,d1	; even/odd parity?
	bne	SetUnit_OddPar

	bset	#6,d0			; set even parity bit

SetUnit_OddPar:
	move.b	d0,PV_Com(a4)		; set command
	st	PV_Setup(a4)		; set setup flag
	moveq	#0,d0			; status okay

SetUnit0:
	subq.b	#1,ASU_DisRCnt(a2)	; enable read irq
	move.l	a3,a1
	movem.l (sp)+,D2/A3/A4/A6
	rts

SetUnit_BufErr:
	moveq	#SerErr_BufErr,d0
	bra	SetUnit0

SetUnit_InvPar:
	moveq	#SerErr_InvParam,d0
	bra	SetUnit0

SetUnit_BaudErr:
	moveq	#SerErr_BaudMismatch,d0
	bra	SetUnit0

SetUnit_BaudTab:

; baud tab for clk = 0.9216 mhz

	dc.l	  9600,  4800,  3600,  2400
	dc.l	  1800,  1200,   900,   600
	dc.l       300,   150,    75,    75
	dc.l        75,    75,    75, 57600

; baud tab for clk = 1.8432 mhz

	dc.l	 19200,  9600,  7200,  4800
	dc.l	  3600,  2400,  1800,  1200
	dc.l	   600,   300,   150,   135
	dc.l	   110,    75,    50,115200
	
; baud tab for clk = 3.6864 mhz

	dc.l	 38400, 19200, 14400,  9600
	dc.l      7200,  4800,  3600,  2400
	dc.l	  1200,   600,   300,   300
	dc.l       300,   150,   150,230400


;============================================================================
;    FreeUnit : Free unit
;		- free receive buffer
;		- reset hardware
;
;	   IN : A2.L = Unit
;		A5.L = Device base
;
;	  OUT :
;
;    Register : D0,D1,A0,A1
;
FreeUnit:
	move.l	a6,-(sp)

	st	ASU_DisRCnt(a2) 	; disable read irq
	st	ASU_DisWCnt(a2) 	; disable write irq

	bsr	OClear			; clear output buffer

	move.l	ASU_PV(a2),a0		; port control block
	moveq	#0,d0
	move.b	d0,PV_Com(a0)
	st	PV_Setup(a0)

	move.l	ASU_RBuf(a2),d0 	; receive buffer
	beq	FreeUnit0		; if not set, end

	move.l	d0,a1
	move.l	ASU_RBufLen(a2),d0
	move.l	SysBase(pc),a6
	jsr	_LVOFreeMem(a6) 	; free buffer

	clr.l	ASU_RBuf(a2)

FreeUnit0:
	move.l	(sp)+,a6
	rts


;============================================================================
;     IntCode : Interrupt Code
;
;		This code does:
;		- check if there are bytes available in the receiver ring
;		  buffer and if so copy them direct in the receive buffer or
;		  if a read request is active directly to destination
;		  address.
;
;		- check if there is an active write request and space in the
;		  output buffer. If so, copy bytes from the request into the
;		  output buffer.
;
;	   IN : A1.L = Data from is_data, that is the device base
;
;	  OUT : z flag is always set
;
;    Register : D0,D1,A0,A1,A5,A6
;
IntCode:
	movem.l D2-D4/A2/A3,-(sp)

	move.l	SysBase(pc),a6
	move.l	AS_UnitArray(a1),a2	; unit array in a2
	move.l	AS_Units(a1),d4		; unit counter
	bra	IntCode_InUnitLoop	; start loop

IntCode_UnitLoop:
	move.l	ASU_PV(a2),a3		; address of port control block

;
;	check for received data
;
IntCode_RecLoop:
	move.b	PV_InTail(a3),d0	; check if there are bytes in the
	cmp.b	PV_InHead(a3),d0	; receiver ring buffer
	beq	IntCode_NoRec		; no

	tst.b	ASU_DisRCnt(a2) 	; read handling disabled?
	bne	IntCode_NoRec		; if yes, skip

	tst.l	ASU_ReadReq(a2) 	; active read request?
	beq	IntCode_RecBuf		; if none, receive to buffer

;
;	copies directly to destination of active read request
;
	bsr	RecReq			; get bytes

	tst.l	d0			; done?
	bne	IntCode_NoRec		; request not done

	move.l	ASU_ReadReq(a2),a1	; get request

	PUTDEBUG <"AS: VBI: Read request done IOB=$%lx">,a,(a1)

	clr.l	ASU_ReadReq(a2) 	; clear active request
	move.l	IO_LENGTH(a1),IO_ACTUAL(a1) ; set received length

	bclr	#IOSERB_ACTIVE,IO_FLAGS(a1) ; clear active flag

	jsr	_LVOReplyMsg(a6)	; reply message

IntCode_CheckQueue:
	lea	ASU_ReadQueue(a2),a1	; read queue
	move.l	(a1),a0 		; get next entry
	move.l	(a0),d0 		; available?
	beq	IntCode_RecBuf		; if not, get additional bytes in buf

	move.l	d0,(a1) 		; remove node from queue
	exg.l	d0,a0
	move.l	a1,LN_PRED(a0)

	move.l	d0,a1
	bclr	#IOSERB_QUEUED,IO_FLAGS(a1) ; clear queued flag
	bset	#IOSERB_ACTIVE,IO_FLAGS(a1) ; set active flag
	move.l	a1,ASU_ReadReq(a2)	; set ptr to request in unit
	move.l	IO_DATA(a1),ASU_ReadPtr(a2) ; set data ptr
	move.l	IO_LENGTH(a1),ASU_ReadCnt(a2) ; set bytes to read
	bra	IntCode_RecLoop 	; try to get additional bytes

;
;	get bytes into receive buffer
;
IntCode_RecBuf:
	bsr	RecBuf

IntCode_NoRec:

;
;	check for data to transmit
;
	tst.b	ASU_DisWCnt(a2) 	; write handling disabled?
	bne	IntCode_NoWrite 	; if yes, skip

	tst.l	ASU_WriteReq(a2)	; active write request?
	beq	IntCode_NoWrite 	; if none, skip

IntCode_WriteLoop:
	bsr	CopyWrite		; copy data

	tst.l	d0			; request finished?
	bne	IntCode_NoWrite 	; if not, skip

	move.l	ASU_WriteReq(a2),a1	; get request

	PUTDEBUG <"AS: VBI: Write request done IOB=$%lx">,a,(a1)

	clr.l	ASU_WriteReq(a2)	; clear active request
	move.l	IO_LENGTH(a1),IO_ACTUAL(a1) ; set sent length

	bclr	#IOSERB_ACTIVE,IO_FLAGS(a1) ; clear active flag

	jsr	_LVOReplyMsg(a6)	; reply message

	lea	ASU_WriteQueue(a2),a1	; write queue
	move.l	(a1),a0 		; get next entry
	move.l	(a0),d0 		; available?
	beq	IntCode_NoWrite 	; if not, end

	move.l	d0,(a1) 		; remove node from queue
	exg.l	d0,a0
	move.l	a1,LN_PRED(a0)

	move.l	d0,a1
	bclr	#IOSERB_QUEUED,IO_FLAGS(a1) ; clear queued flag
	bset	#IOSERB_ACTIVE,IO_FLAGS(a1) ; set active flag
	move.l	a1,ASU_WriteReq(a2)	; set ptr to request in unit
	move.l	IO_DATA(a1),ASU_WritePtr(a2) ; set data ptr
	move.l	IO_LENGTH(a1),ASU_WriteCnt(a2) ; set bytes to write
	bra	IntCode_WriteLoop	; try to send immediately

IntCode_NoWrite:
	lea	ASU_SizeOf(a2),a2	; next unit address

IntCode_InUnitLoop:
	dbf	d4,IntCode_UnitLoop	; next unit

	movem.l (sp)+,D2-D4/A2/A3

	moveq	#0,d0
	rts


;============================================================================
;      RecReq : Copy bytes from the receiver ring buffer to the destination
;		specified by the active read request.
;
;	   IN : A2.L = Device
;		A3.L = PV
;
;	  OUT : D0.l = bytes left to receive
;
;    Register : D0,D1,D2,A0,A1
;
RecReq:
	move.l	ASU_ReadCnt(a2),d0	; number of bytes left to receive
	move.l	ASU_ReadPtr(a2),a0	; destination

	move.l	ASU_IBuf(a2),a1 	; receiver ring buffer
	move.b	PV_InHead(a3),d1	; ring buffer head
	moveq	#0,d2
	move.b	PV_InTail(a3),d2	; ring buffer tail

;	PUTDEBUG <"AS: RecReq: START: Cnt=%ld">,d,d0

	bra	RecReq_InLoop

RecReq_Loop2:
	swap	d0

RecReq_Loop:
	MDELAY
	move.b	(a1,d2.w),(a0)+ 	; copy byte
	addq.b	#1,d2

RecReq_InLoop:
	cmp.b	d1,d2			; reached head?
	dbeq	d0,RecReq_Loop		; next byte
	beq	RecReq_End		; ring buffer empty

	swap	d0			; get high word
	dbf	d0,RecReq_Loop2 	; next byte

	moveq	#0,d0			; all bytes received

RecReq_End:
	move.b	d2,PV_InTail(a3)	; store new tail
	move.l	d0,ASU_ReadCnt(a2)	; store count
	move.l	a0,ASU_ReadPtr(a2)	; and ptr

;	PUTDEBUG <"AS: RecReq: END: Cnt=%ld">,d,d0
	rts


;============================================================================
;      RecBuf : Copy bytes from the receiver ring buffer to the receiver
;		buffer.
;
;	   IN : A2.L = Device
;		A3.L = PV
;
;	  OUT :
;
;    Register : D0,D1,D2,D3,A0,A1
;
RecBuf:
	move.l	ASU_RBufInPtr(a2),a0	; InPtr
	move.l	ASU_RBufOutPtr(a2),d0	; OutPtr
	sub.l	a0,d0			; calc bytes left in buffer
	bgt	1$

	add.l	ASU_RBufLen(a2),d0

1$:
	subq.l	#1,d0			; -1

	move.l	ASU_RBufEnd(a2),d3	; end of receive buffer
	move.l	ASU_IBuf(a2),a1 	; receiver ring buffer

;	PUTDEBUG <"AS: RecBuf: START: Head=%ld Free=%ld">,d,a0,d,d0

	move.b	PV_InHead(a3),d1	; ring buffer head
	moveq	#0,d2
	move.b	PV_InTail(a3),d2	; ring buffer tail
	bra.s	RecBuf_InLoop

RecBuf_Loop2:
	swap	d0

RecBuf_Loop:
	MDELAY
	move.b	(a1,d2.w),(a0)+ 	; copy byte
	cmp.l	d3,a0			; end of buffer?
	bhs	RecBuf_BufEnd		; if yes, branch

RecBuf_Cont:
	addq.b	#1,d2

RecBuf_InLoop:
	cmp.b	d1,d2			; reached head?
	dbeq	d0,RecBuf_Loop		; next byte
	beq	RecBuf_End		; ring buffer empty

	swap	d0			; get high word
	dbf	d0,RecBuf_Loop2 	; next byte

RecBuf_End:
	move.b	d2,PV_InTail(a3)	; store new tail
	move.l	a0,ASU_RBufInPtr(a2)	; store ptr

;	PUTDEBUG <"AS: RecBuf: END: Head=%ld">,d,a0
	rts

RecBuf_BufEnd:
	move.l	ASU_RBuf(a2),a0 	; wrap around the clock
	bra	RecBuf_Cont


******* DATA ****************************************************************

;------ Interrupt server node -----------------------------------------------

IntNode:
	dc.l	0,0
	dc.b	NT_INTERRUPT		; Typ
	dc.b	IntPri			; Prioritaet
	dc.l	Name
	dc.l	0			; Data
	dc.l	IntCode 		; Code


;------ Misc. data ----------------------------------------------------------

SysBase:	dc.l	0		; ExecBase

UtilityName:	UTILITYNAME

ExpansionName:	EXPANSIONNAME


;------ 65c02 driver code ---------------------------------------------------

Code6502:
	incbin	"a2232_6502.o"
Code6502_End:

ENDTag:
