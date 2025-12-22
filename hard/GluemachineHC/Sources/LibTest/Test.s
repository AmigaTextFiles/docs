**************************************************************
*                           \|/                              *
*                           @ @                              *
*-----------------------ooO-(_)-Ooo--------------------------*
*                                                            *
*                Use the Simple serial line.                 *
*                    Use the LCD library.                    *
*                        Gluemaster                          *
*                          950708                            *
*                                                            *
*------------------------------------------------------------*
*                                                            *
*                                                            *
**************************************************************
	PROCESSOR 68HC11

	include "ADEV11:include/hc11reg.i"
	include "ADEV11:include/LCD.i"
	include "ADEV11:include/Ser.i"

	RSEG.U ZPAGE
Position:
	RMB 1
Char:
	RMB 1
Dead:
	RMB 1

	RSEG CODE
Start:
	lds #$ff

	jsr InitLCD

	ldaa #0
	ldx #String
	jsr PutStr

	ldaa #BAUD9600
	jsr InitSer

	clr Position
	ldaa #$ff
	staa.z Dead
EEver:
	jsr RecSer

	jsr TransSer
	jsr TransSer
	jsr TransSer
	jsr TransSer
	jsr TransSer

	staa.z Char

	ldaa.z Position
	adda #40
	ldx #Char
	jsr PutStr

	inc Position
	ldaa.z Position
	cmpa #20
	blo GoodOne
	clr Position

GoodOne:
	bra EEver

String:
	dc.b "  -= 9600:8:1:N =-  ",$ff

**************************************************************
*                           \|/                              *
*                           @ @                              *
*-----------------------ooO-(_)-Ooo--------------------------*
*                                                            *
*                         Vectors.                           *
*                        Gluemaster                          *
*                          950503                            *
*                                                            *
*------------------------------------------------------------*
*                                                            *
*                                                            *
**************************************************************

BadInt:
	rti				; Set all unused vectors here

	RSEG VECTORS		;Interrupt vectors

	dc.w	BadInt		; $FFC0	Reserved
	dc.w	BadInt		; $FFC2	Reserved
	dc.w	BadInt		; $FFC4	Reserved
	dc.w	BadInt		; $FFC6	Reserved
	dc.w	BadInt		; $FFC8	Reserved
	dc.w	BadInt		; $FFCA	Reserved
	dc.w	BadInt		; $FFCC	Reserved
	dc.w	BadInt		; $FFCE	Reserved
	dc.w	BadInt		; $FFD0	Reserved
	dc.w	BadInt		; $FFD2	Reserved
	dc.w	BadInt		; $FFD4	Reserved

	dc.w	BadInt		; $FFD6	SCI Serial System
	dc.w	BadInt		; $FFD8	SPI Serial Transfer Complete
	dc.w	BadInt		; $FFDA	Pulse Accumulator Input Edge
	dc.w	BadInt		; $FFDC	Pulse Accumulator Overflow
	dc.w	BadInt		; $FFDE	Timer Overflow
	dc.w	BadInt		; $FFE0	In Capture 4/Output Compare 5 (TI4O5)
	dc.w	BadInt  	; $FFE2	Timer Output Compare 4 (TOC4)
	dc.w	BadInt		; $FFE4	Timer Output Compare 3 (TOC3) 
	dc.w	BadInt		; $FFE6	Timer Output Compare 2 (TOC2)
	dc.w	BadInt		; $FFE8	Timer Output Compare 1 (TOC1)
	dc.w	BadInt		; $FFEA	Timer Input Capture 3 (TIC3)
	dc.w	BadInt		; $FFEC	Timer Input Capture 2 (TIC2)
	dc.w	BadInt		; $FFEE	Timer Input Capture 1 (TIC1)
	dc.w	BadInt		; $FFF0	Real Time Interrupt (RTI)
	dc.w	BadInt		; $FFF2	External Pin or Parallel I/O (IRQ)
	dc.w	BadInt		; $FFF4	Pseudo Non-Maskable Interrupt (XIRQ)
	dc.w	BadInt		; $FFF6	Software Interrupt (SWI)
	dc.w	BadInt		; $FFF8	Illegal Opcode Trap ()
	dc.w	BadInt		; $FFFA	COP Failure (Reset) ()
	dc.w	BadInt		; $FFFC	COP Clock Monitor Fail (Reset) ()
	dc.w	Start		; $FFFE	/RESET

**************************************************************
*                                                            *
*-----------------------oooO---Oooo--------------------------*
*                                                            *
**************************************************************


	END
