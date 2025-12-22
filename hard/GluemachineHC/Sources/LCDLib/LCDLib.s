**************************************************************
*                           \|/                              *
*                           @ @                              *
*-----------------------ooO-(_)-Ooo--------------------------*
*                                                            *
*                    LCD-display library.                    *
*                        Gluemaster                          *
*                          950708                            *
*                                                            *
*------------------------------------------------------------*
*                                                            *
*                                                            *
**************************************************************
	PROCESSOR 68HC11

	XDEF PutStr
	XDEF InitLCD
	XDEF CGInit

	include "ADEV11:include/hc11reg.i"
	include "ADEV11:include/LCD.i"

	RSEG CODE

DELAY01MS	EQU	17

RW	EQU $10
RS	EQU $20
EN	EQU $40
NEN	EQU $bf

;Delay for X*0.1 ms
Delay:
	pshy
eloop:
	ldy #0
iloop:
	iny
	cpy #DELAY01MS
	bne iloop
	dex
	bne eloop
	puly
	rts


WrCmdNib:
	pshx
	anda #$0f
	staa REGBASE+PORTB
	ldx #2
	jsr Delay
	oraa #EN
	staa REGBASE+PORTB
	ldx #2
	jsr Delay
	anda #NEN
	staa REGBASE+PORTB
	ldx #2
	jsr Delay
	pulx
	rts


WrCmd:
	psha
	rora
	rora
	rora
	rora
;	anda #$0f
	jsr WrCmdNib
	pula
	jsr WrCmdNib
	rts


WrDataNib:
	pshx
	anda #$0f
	oraa #RS
	staa REGBASE+PORTB
	ldx #2
	jsr Delay
	oraa #EN
	staa REGBASE+PORTB
	ldx #2
	jsr Delay
	anda #NEN
	staa REGBASE+PORTB
	ldx #2
	jsr Delay
	pulx
	rts


WrData:
	psha
	rora
	rora
	rora
	rora
;	anda #$0f
	jsr WrDataNib
	pula
	jsr WrDataNib
	rts


;a=address, x=datapointer, $ff terminates
PutStr:
	anda #$7f
	oraa #$80
	jsr WrCmd

LoopPutStr:
	ldaa 0,x
	cmpa #$ff
	beq ExitPutStr
	jsr WrData
	inx
	bra LoopPutStr

ExitPutStr:
	ldaa #$02
	jsr WrCmd

	rts


; Initialization sequence for a 4 bit mode LCD
InitLCD:
	ldx #100
	jsr Delay
	ldaa #$03
	jsr WrCmdNib
	ldx #50
	jsr Delay
	ldaa #$03
	jsr WrCmdNib
	ldx #10
	jsr Delay
	ldaa #$03
	jsr WrCmdNib
	ldx #10
	jsr Delay
	ldaa #$02
	jsr WrCmdNib
	ldx #10
	jsr Delay

	ldaa #$28
	jsr WrCmd

	ldaa #$08
	jsr WrCmd
	ldaa #$01
	jsr WrCmd
	ldaa #$06
	jsr WrCmd

	ldaa #$0c
	jsr WrCmd

	rts


;a=address, b=no. bytes, x=datapointer
CGInit:
	anda #$3f
	oraa #$40
	jsr WrCmd
next:
	ldaa 0,x
	jsr WrData
	inx
	decb
	bne next
	ldaa #$80
	jsr WrCmd
	ldaa #$02
	jsr WrCmd
	rts

**************************************************************
*                                                            *
*-----------------------oooO---Oooo--------------------------*
*                                                            *
**************************************************************
	END
