	IFND	A2232_I
A2232_I	SET	1
**
**	$VER: a2232.i 1.02 (20.02.97)
**
**	Include for a2232 serial board
**
**	<C> 1996 by Markus Marquardt
**


	include	exec/types.i
	include	exec/semaphores.i
	include	exec/libraries.i
	include	dos/dos.i
	include	hardware/custom.i
	include	hardware/intbits.i


******* CONSTANTS ***********************************************************
;
;	Some misc. constants

A2232_Man	EQU	514		; Manufcaturer autoconfig code
A2232_Prod	EQU	70		; Product autoconfig code

AS_BoardUnits	EQU	7		; Number of units on each card
AS_MaxBoards	EQU	8		; Max. number of boards

CustomBase	EQU	$dff000		; Base of custom chips

IntPri		EQU	0		; Priority vbi interrupt server


******* STRUCTURES **********************************************************
;
;	The following data structure exists for every port in the shared ram
;	and acts as a "control block" for this port.

	STRUCTURE PortVar,0

	UBYTE	PV_InHead		; Write ptr in rx ring buffer
	UBYTE	PV_InTail		; Read ptr in rx ring buffer
	UBYTE	PV_OutHead		; Write ptr in tx ring buffer
	UBYTE	PV_OutTail		; Read ptr in tx ring buffer
	UBYTE	PV_OutFlush		; Flag to flush tx buffer
	UBYTE	PV_Setup		; Flag to setup acia parameters
	UBYTE	PV_Param		; Acia parameters for setup
	UBYTE	PV_Com			; Acia command reg.

	LABEL	PV_SizeOf		; Size of structure

;
;	This structure represents the layout of the shared ram between the
;	65c02 on the a2232 and the amiga.

	STRUCTURE SharedRam,0

	STRUCT	SR_PortVars,PV_SizeOf*AS_BoardUnits ; Port control

	UBYTE	SR_CDStatus		; Status of all CD lines
	UBYTE	SR_TimerH		; timer high (speed check)
	UBYTE	SR_TimerL		; timer low     "     "

SOFFSET	SET	$0200			; structure continued on $0200

	STRUCT	SR_OBuf,256*AS_BoardUnits ; Output ring buffers

	STRUCT	SR_IBuf,256*AS_BoardUnits ; Input ring buffers

SOFFSET SET	$3000			; structure continued on $3000

	STRUCT	SR_Code,$1000		; 65c02 driver code

	UWORD	SR_IAck			; Intr. acknowledge

SOFFSET SET	$8000			; structure continued on $8000

	UWORD	SR_EnaRes		; Enable 6502 reset

SOFFSET	SET	$c000			; structure continued on $c000

	UWORD	SR_ResBoard		; Reset a2232


;------ Device structure ----------------------------------------------------

	STRUCTURE ASBase,LIB_SIZE

	APTR	AS_UtilityBase		; UtilityBase
	APTR	AS_ExpBase		; ExpansionBase
	BPTR	AS_SegList		; Segment
	UWORD	AS_Boards		; Number of installed boards
	STRUCT	AS_BoardArray,4*AS_MaxBoards ; Array with board base address
	ULONG	AS_Units		; Number of available units
	APTR	AS_UnitArray		; Ptr to array of ASU structures
	UBYTE	AS_Flags		; Flags (see below)

	LABEL	AS_SizeOf

;	Flags in AS_Flags

	BITDEF	AS,IntSet,0		; Interrupt server initialized


;------ Unit structure ------------------------------------------------------
;
;	This structure exists for every available unit in the unit array.

	STRUCTURE ASU,0

	UBYTE	ASU_DisRCnt		: Count for read irq disable
	UBYTE	ASU_DisWCnt		; Count for write irq disable
	STRUCT	ASU_ReadQueue,MLH_SIZE	; Read queue
	STRUCT	ASU_WriteQueue,MLH_SIZE	; Write queue
	UWORD	ASU_OpenCnt		; OpenCounter
	APTR	ASU_Board		; Base address of a2232 board
	UBYTE	ASU_UnitNum		; Unit number within one a2232 board
	UBYTE	ASU_Clock		; Clock type (see below)
	APTR	ASU_PV			; Address of port control block
	APTR	ASU_OBuf		; Address of port output ring buffer
	APTR	ASU_IBuf		; Address of port input ring buffer
	APTR	ASU_RBuf		; Ptr to rx buffer
	ULONG	ASU_RBufLen		; Len rx buffer
	APTR	ASU_RBufEnd		; Ptr to end of rx buffer
	APTR	ASU_RBufInPtr		; "In" ptr in rx buffer
	APTR	ASU_RBufOutPtr		; "Out" ptr in rx buffer
	APTR	ASU_ReadReq		; Ptr to active read request
	APTR	ASU_ReadPtr		; Actual read destination ptr
	APTR	ASU_ReadCnt		; Number of bytes left to read
	APTR	ASU_WriteReq		; Ptr to active write request
	APTR	ASU_WritePtr		; Actual write source ptr
	APTR	ASU_WriteCnt		; Number of bytes left to write
	STRUCT	ASU_Semaphore,SS_SIZE	; Semaphore
	UBYTE	ASU_IOSerFlags		; Copy of IO_SerFlags
	UBYTE	ASU_IOReadLen		; Copy of IO_ReadLen
	UBYTE	ASU_IOWriteLen		; Copy of IO_WriteLen
	UBYTE	ASU_IOStopBits		; Copy of IO_StopBits
	ULONG	ASU_IOBaud		; Copy of IO_Baud

	LABEL	ASU_SizeOf

;	Clock types in ASU_Clock

ASU_ClockHalf	EQU	0		; Clock rate 1/2 of original
ASU_ClockOrig	EQU	1		; Clock rate original (1.8432 mhz)
ASU_ClockDbl	EQU	2		; Clock rate original x 2


******* MACROS **************************************************************
;
;	Macros to enable/disable the vbi irq
;

DISVBI	MACRO
	move.w	#INTF_INTEN,CustomBase+intena
	ENDM

ENAVBI	MACRO
	move.w	#INTF_SETCLR|INTF_INTEN,CustomBase+intena
	ENDM


******* DEBUG STUFF *********************************************************

PUTDEBUG MACRO ; "msg" [type1] [val1] .. [type5] [val5]
	IFGE	DEBUG-1
DOFF	SET	0
	movem.l	d0/d1/a0/a1,-(sp)
	IFC	'\10','a'
DOFF	SET	DOFF+4
	pea.l	\11
	ENDC
	IFC	'\10','d'
DOFF	SET	DOFF+4
	move.l	\11,-(sp)
	ENDC
	IFC	'\8','a'
DOFF	SET	DOFF+4
	pea.l	\9
	ENDC
	IFC	'\8','d'
DOFF	SET	DOFF+4
	move.l	\9,-(sp)
	ENDC
	IFC	'\6','a'
DOFF	SET	DOFF+4
	pea.l	\7
	ENDC
	IFC	'\6','d'
DOFF	SET	DOFF+4
	move.l	\7,-(sp)
	ENDC
	IFC	'\4','a'
DOFF	SET	DOFF+4
	pea.l	\5
	ENDC
	IFC	'\4','d'
DOFF	SET	DOFF+4
	move.l	\5,-(sp)
	ENDC
	IFC	'\2','a'
DOFF	SET	DOFF+4
	pea.l	\3
	ENDC
	IFC	'\2','d'
DOFF	SET	DOFF+4
	move.l	\3,-(sp)
	ENDC
	lea	DebugMsg\@(pc),a0
	move.l	sp,a1
	bsr	KPrintF

	lea	DOFF(sp),sp
	movem.l	(sp)+,d0/d1/a0/a1
	bra.s	PutDebug\@

DebugMsg\@:
	dc.b	\1,10,0
	even

PutDebug\@:
	ENDC
	ENDM


******* END *****************************************************************

	ENDC
