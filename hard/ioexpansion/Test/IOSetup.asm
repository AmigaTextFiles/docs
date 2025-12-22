*****************************************************************************
* IOSetup.asm - ©1990 by The Puzzle Factory
*          Initializes the register contents for the I/O Expansion board
*          to specific values, so that you can see if the hardware is working.
*   Usage: 1> IOSetup
* History: 01/22/88 V0.50 Created by Jeff Lavin
*          11/25/90 V0.51 Converted to new syntax
*
* [To all: Please don't forget to bump the revision numbers if you do *any*
*          modifications at all.  -Jeff]
*
*****************************************************************************

;Set Tabs           |       |                 |       |

	exeobj
	objfile	'ram:IOSetup'
	macfile 'Includes:IOexp.i'	;The One & Only include file

IOSetup	lea	(VIA_Base+VIA0),a0
	move.b	#$FF,(DDRB,a0)		;All outputs
	move.b	#$FF,(DDRA,a0)		;All outputs
	move.b	#$12,(ORB,a0)		;Recognizable pattern
	move.b	#$34,(ORA,a0)		;Recognizable pattern

	lea	(VIA_Base+VIA1),a0
	move.b	#$FF,(DDRB,a0)		;All outputs
	move.b	#$FF,(DDRA,a0)		;All outputs
	move.b	#$56,(ORB,a0)		;Recognizable pattern
	move.b	#$78,(ORA,a0)		;Recognizable pattern

	lea	(ACIA_Base+ACIA0),a0
	bsr.b	SetupACIA

	lea	(UNIT2,a0),a0
	bsr.b	SetupACIA

	lea	(ACIA_Base+ACIA1),a0
	bsr.b	SetupACIA

	lea	(UNIT2,a0),a0
SetupACIA	move.b	(ISR,a5),d0		;Clear garbage
	move.b	(CSR,a5),d0
	move.b	(RDR,a5),d0		;Clear RDRF bit
	move.b	#Baud_2400,(CTR,a0)	;2400 baud, 1 stop bit, no echo
	move.b	#FRF_FRMT!WORDLEN_8!PAR_MARK,(FMR,a0) ;8 bits, mark par, no par, DTR hi
	move.b	#$0D,(TDR,a0)		;Stick a CR in there
	moveq	#0,d0
	rts

	end
