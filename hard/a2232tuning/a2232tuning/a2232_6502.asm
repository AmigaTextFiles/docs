;
;	Project: A2232 device - 65c02 code
;
;	Author: Markus Marquardt
;
;	$VER: 1.00 (16.01.97)
;
;	This code is based on the unix a2232 serial board driver written by
;	Jukka Marin (jm) - many thanks to him!
;
;	History:
;
;	03.12.1996	Minimized version of the original source. Converted
;			to dasm source.
;
;	12.01.1997	First release (1.00), removed crystal check
;
;	16.01.1997	Created version for unmodified a2232 boards
;
;	21.01.1997	Version for unmodified a2232 boards deleted, version
;			with auto-detect created ;-)
;
;	09.02.1997	Modified code for clock detection
;
	processor 6502


;****** CONSTANTS ***********************************************************

;
;	ACIA
;
ACIA0		equ	$4400		; start address ACIA0
ACIA1		equ	$4c00		;   "     "  "    " 1
ACIA2		equ	$5400		;   "     "  "    " 2
ACIA3		equ	$5c00		;   "     "  "    " 3
ACIA4		equ	$6400		;   "     "  "    " 4
ACIA5		equ	$6c00		;   "     "  "    " 5
ACIA6		equ	$7400		; start address ACIA6

A_DATA		equ	$00		; ACIA data register
A_SR		equ	$02		; ACIA status register
A_CMD		equ	$04		; ACIA command register
A_CTRL		equ	$06		; ACIA control register

;
;	CIA
;
CIA		equ	$7c00		; start address 8520 CIA

C_PA		equ	$00		; CIA port A data register
C_PB		equ	$02		; CIA port B data register
C_DDRA		equ	$04		; CIA data dir register for port A
C_DDRB		equ	$06		; CIA data dir register for port B
C_TAL		equ	$08		; CIA timer A
C_TAH		equ	$0a
C_TBL		equ	$0c		; CIA timer B
C_TBH		equ	$0e
C_TODL		equ	$10		; CIA TOD LSB
C_TODM		equ	$12		; CIA TOD middle byte
C_TODH		equ	$14		; CIA TOD MSB
C_DATA		equ	$18		; CIA serial data register
C_INTCTRL	equ	$1a		; CIA interrupt control register
C_CTRLA		equ	$1c		; CIA control register A
C_CTRLB		equ	$1e		; CIA control register B


;****** MACROS **************************************************************

;
;	Some macros for "structure definition"
;
		MAC	varbase ; starting_address
_varbase	set	{1}
		ENDM

		MAC	vardef ; name space_needs
{1}		equ	_varbase
_varbase	set	_varbase+{2}
		ENDM

;
;	Macros for the "enhanced" command set of the 65ce02
;
		MAC	stz ; address
		dc.b	$64,{1}
		ENDM

		MAC	stzax  address
		dc.b	$9e,<{1},>{1}
		ENDM


;****** STRUCTURES **********************************************************
;
;	The following data structure exists for every port and acts as a
;	"control block" for this port.
;
		MAC	portvar	; port number
		VARDEF	InHead{1}, 1
		VARDEF	InTail{1}, 1
		VARDEF	OutHead{1}, 1
		VARDEF	OutTail{1}, 1
		VARDEF	OutFlush{1}, 1
		VARDEF	SetUp{1}, 1
		VARDEF	Param{1}, 1
		VARDEF	Com{1}, 1
		ENDM


;****** FUNCTION MACROS *****************************************************


;----------------------------------------------------------------------------
;
; stuff common for all ports, non-critical (run once / loop)
;
		MAC	do_slow

		lda	CIA+C_PA	; get CD status
		sta	CDStatus	; store it for amiga

		ENDM


;----------------------------------------------------------------------------
;
; port specific stuff (no data transfer) - FOR UNMODIFIED BOARDS
;
		MAC	do_port ; port number

		lda	SetUp{1}	; reconfiguration request?
		beq	.NOCONF		; skip if no

		lda	Param{1}	; get parameter
		sta	ACIA{1}+A_CTRL	; store in control register
		stz	SetUp{1}	; no reconfiguration no more

.NOCONF		sec
		lda	InHead{1}	; get write index
		sbc	InTail{1}	; buffer full soon?
		cmp	#240		; 240 chars or more in buffer?
		lda	Com{1}		; get command reg. value
		ora	#[1<<3]		; set rts
		bcc	.NORTS		; room

		and	#255-[1<<3]	; clr rts

.NORTS		sta	ACIA{1}+A_CMD	; set new value

		lda	OutFlush{1}	; request to flush output buffer
		beq	.NOFLUSH	; skip if no

		lda	OutHead{1}	; get head
		sta	OutTail{1}	; save as tail
		stz	OutFlush{1}	; clear request

.NOFLUSH
		ENDM

;----------------------------------------------------------------------------
;
; port specific stuff (no data transfer) - FOR MODIFIED BOARDS
;
		MAC	m_do_port ; port number

		lda	SetUp{1}	; reconfiguration request?
		beq	.NOCONF		; skip if no

		lda	Param{1}	; get parameter
		sta	ACIA{1}+A_CTRL	; store in control register
		lda	Com{1}		; get Command reg value
		sta	ACIA{1}+A_CMD	; set it
		stz	SetUp{1}	; no reconfiguration no more

.NOCONF		sec
		lda	InHead{1}	; get write index
		sbc	InTail{1}	; buffer full soon?
		cmp	#240		; 240 chars or more in buffer?
		lda	CIA+C_PB
		and	#255-[1<<{1}]
		bcc	.NORTS		; room

		ora	#[1<<{1}]

.NORTS		sta	CIA+C_PB

		lda	OutFlush{1}	; request to flush output buffer
		beq	.NOFLUSH	; skip if no

		lda	OutHead{1}	; get head
		sta	OutTail{1}	; save as tail
		stz	OutFlush{1}	; clear request

.NOFLUSH
		ENDM


;----------------------------------------------------------------------------
;
; receive data
;
		MAC	do_rec ; port number

		lda	ACIA{1}+A_SR	; read ACIA status register
		and	#[1<<3]		; something received?
		beq	.NOREC		; skip if no

		ldx	InHead{1}	; get write index
		lda	ACIA{1}+A_DATA	; read received character
		sta	ibuf{1},x	; save char in buffer
		inc	InHead{1}	; update index in RAM

		lda	ACIA{1}+A_SR


.NOREC
		ENDM

;----------------------------------------------------------------------------
;
; send data - FOR UNMODIFIED BOARDS
;
		MAC	do_send ; port number

		ldx	OutTail{1}	; anything to transmit?
		cpx	OutHead{1}
		beq	.NOSEND		; skip if no

		lda	ACIA{1}+A_SR	; transmit register empty?
		and	#[1<<4]
		beq	.NOSEND		; skip if no

		lda	CIA+C_PB	; check CTS signal
		and	#[1<<{1}]	; (for this port only)
		bne	.NOSEND		; if not ready, skip send

		lda	obuf{1},x	; get a char from buffer
		sta	ACIA{1}+A_DATA	; send it away
		inc	OutTail{1}	; update read index

.NOSEND
		ENDM


;----------------------------------------------------------------------------
;
; send data - FOR MODIFIED BOARDS
;
		MAC	m_do_send ; port number

		ldx	OutTail{1}	; anything to transmit?
		cpx	OutHead{1}
		beq	.NOSEND		; skip if no

		lda	ACIA{1}+A_SR	; transmit register empty?
		and	#[1<<4]
		beq	.NOSEND		; skip if no

		lda	ACIA{1}+A_SR
		and	#[1<<6]		; CTS okay?
		bne	.NOSEND		; no

		lda	obuf{1},x	; get a char from buffer
		sta	ACIA{1}+A_DATA	; send it away
		inc	OutTail{1}	; update read index

.NOSEND
		ENDM



;******* DATA ***************************************************************
;
;	Zeropage port control blocks
;
		VARBASE 0		; start variables at address $0000

		PORTVAR 0		; define variables for port 0
		PORTVAR 1		; define variables for port 1
		PORTVAR 2		; define variables for port 2
		PORTVAR 3		; define variables for port 3
		PORTVAR 4		; define variables for port 4
		PORTVAR 5		; define variables for port 5
		PORTVAR 6		; define variables for port 6
;
;	Misc

		VARDEF	CDStatus, 1	; port 0-6 CD status from CIA
		VARDEF	TimerH, 1
		VARDEF	TimerL, 1

		VARDEF DataEnd, 0	; end (size) of data
;
;	$0100 - $01ff stack
;

;
;	I/O Buffers
;
		VARBASE	$0200
		VARDEF	obuf0, 256	; output data
		VARDEF	obuf1, 256
		VARDEF	obuf2, 256
		VARDEF	obuf3, 256
		VARDEF	obuf4, 256
		VARDEF	obuf5, 256
		VARDEF	obuf6, 256

		VARDEF	ibuf0, 256	; input data
		VARDEF	ibuf1, 256
		VARDEF	ibuf2, 256
		VARDEF	ibuf3, 256
		VARDEF	ibuf4, 256
		VARDEF	ibuf5, 256
		VARDEF	ibuf6, 256


;******* MAIN CODE **********************************************************

		seg	code
		org	$3800		; start address for program code

;------- Initialization -----------------------------------------------------

RESET		sei
		ldx	#$ff		; initialize stack pointer
		txs
		cld			; clear dec flag if 6502

		ldx	#0		; clear whole zero page
		lda	#0
M_ClrLoop	sta	0,x
		inx
		bne	M_ClrLoop

;------- Speed check --------------------------------------------------------

DoSpeedy	lda	#%00011010	; 8N1, 1200/2400/4800 bps		;
		sta	ACIA0+A_CTRL	;				;
		lda	#%00001011	; enable DTR			;
		sta	ACIA0+A_CMD	;				;
		lda	ACIA0+A_SR	; read status register		;
					;				;
		lda	#%10000000	; disable all ints (unnecessary);
		sta	CIA+C_INTCTRL	;				;
		lda	#255		; program the timer		;
		sta	CIA+C_TAL	;				;
		sta	CIA+C_TAH	;				;
					;				;
		ldx	#0		;				;
		stx	ACIA0+A_DATA	; transmit a zero		;
		nop			;				;
		nop			;				;
		lda	ACIA0+A_SR	; read status			;
		nop			;				;
		nop			;				;

		stx	ACIA0+A_DATA	; transmit a zero		;
Speedy1		lda	ACIA0+A_SR	; read status			;
		and	#[1<<4]		; transmit data reg empty?	;
		beq	Speedy1		; not yet, wait more		;
					;				;
		lda	#%00010001	; load & start the timer	;
		stx	ACIA0+A_DATA	; transmit one more zero	;
		sta	CIA+C_CTRLA	;				;
Speedy2		lda	ACIA0+A_SR	; read status			;
		and	#[1<<4]		; transmit data reg empty?	;
		beq	Speedy2		; not yet, wait more		;

		stx	ACIA0+A_DATA	; transmit additional zero
Speedy3		lda	ACIA0+A_SR	; read status			;
		and	#[1<<4]		; transmit data reg empty?	;
		beq	Speedy3		; not yet, wait more		;

		stx	CIA+C_CTRLA	; stop the timer		;
					;				;
		lda	CIA+C_TAL	; copy timer value for 68k	;
		sta	TimerL		;				;
		lda	CIA+C_TAH	;				;
		sta	TimerH		;				;

		lda	#0
		sta	ACIA0+A_SR	; reset UART
		lda	ACIA0+A_DATA
		lda	ACIA0+A_DATA

SpeedyEnd

;------- Check for modified a2232 board -------------------------------------

		lda	#%10000000	; set PA7 to output
		sta	CIA+C_DDRA

		lda	#0
		sta	CIA+C_PA	; set PA7 to low

		lda	CIA+C_PB	; get PB7
		and	#%10000000
		bne	NotModified	; still high -> unmodified board

		lda	#%10000000
		sta	CIA+C_PA	; set PA7 to high

		lda	CIA+C_PB	; get PB7
		and	#%10000000
		beq	NotModified	; still low -> unmodified board

;	It's a modified board, so do some additional init

		lda	#$7f		; set PB0..PB6 to output
		sta	CIA+C_DDRB

		lda	#0
		sta	CIA+C_DDRA	; set PA0..PA7 to input
		jmp	M_MLOOP

;	It's an unmodified board... lame.

NotModified
		lda	#0
		sta	CIA+C_DDRA
		jmp	MLOOP


;
;-------------- MAIN LOOP FOR MODIFIED BOARDS -------------------------------

M_MLOOP		DO_SLOW			; do non-critical things

		M_DO_PORT 0		; do all io
		jsr	M_DO_DATA
		M_DO_PORT 1
		jsr	M_DO_DATA
		M_DO_PORT 2
		jsr	M_DO_DATA
		M_DO_PORT 3
		jsr	M_DO_DATA
		M_DO_PORT 4
		jsr	M_DO_DATA
		M_DO_PORT 5
		jsr	M_DO_DATA
		M_DO_PORT 6
		jsr	M_DO_DATA
		jmp	M_MLOOP

M_DO_DATA	DO_REC 0
		M_DO_SEND 0
		DO_REC 1
		M_DO_SEND 1
		DO_REC 2
		M_DO_SEND 2
		DO_REC 3
		M_DO_SEND 3
		DO_REC 4
		M_DO_SEND 4
		DO_REC 5
		M_DO_SEND 5
		DO_REC 6
		M_DO_SEND 6
		rts

;
;-------------- MAIN LOOP FOR UNMODIFIED BOARDS -----------------------------

MLOOP		DO_SLOW			; do non-critical things

		DO_PORT 0		; do all io
		jsr	DO_DATA
		DO_PORT 1
		jsr	DO_DATA
		DO_PORT 2
		jsr	DO_DATA
		DO_PORT 3
		jsr	DO_DATA
		DO_PORT 4
		jsr	DO_DATA
		DO_PORT 5
		jsr	DO_DATA
		DO_PORT 6
		jsr	DO_DATA
		jmp	MLOOP

DO_DATA		DO_REC 0
		DO_SEND 0
		DO_REC 1
		DO_SEND 1
		DO_REC 2
		DO_SEND 2
		DO_REC 3
		DO_SEND 3
		DO_REC 4
		DO_SEND 4
		DO_REC 5
		DO_SEND 5
		DO_REC 6
		DO_SEND 6
		rts


;----------------------------------------------------------------------------
;	ERROR
;
ERROR		inc	$ff
		jmp	ERROR


;----------------------------------------------------------------------------
;
; irq/reset vectors
;
		seg	vector
		org	$3ffa

		dc.w	ERROR
		dc.w	RESET
		dc.w	ERROR
