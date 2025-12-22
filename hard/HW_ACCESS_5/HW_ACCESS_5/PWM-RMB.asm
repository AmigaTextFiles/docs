	;
	;PWM Generator For The Digital To Analogue Converter.
	;----------------------------------------------------
	;
	;$VER: PWM-RMB.asm_Version_0_10_00_(C)2007_B.Walker_G0LCU.
	;
	;Assembled using 'A68k'...
	;A68k -n PWM-RMB.asm<RETURN/ENTER>
	;
	;Linked using 'blink'...
	;blink PWM-RMB.o<RETURN/ENTER>
	;
start:					;START!!!
	movem.l	d0-d7/a0-a6,-(sp)	;Save all registers just in case!
					;
	movea.l	$4,a6			;Set the 'ExecBase' pointer.
	jsr	-132(a6)		;Offset -132 == [_LVO]Forbid()
					;Disable tasking and interrupts
	jsr	-120(a6)		;Offset -120 == [_LVO]Disable()
					;
					;
rmb:					;This is the PWM section.
	move.l	#127,d0			;Set the 'MARK' of the square wave.
markloop:				;
	bset	#7,$bfe001		;Set bit 7 of the games port.
	dbf	d0,markloop		;Do the timer for the 'MARK'.
	btst	#2,$dff016		;Check to see if the right mouse
					;button is pressed.
	bne.s	delay			;IF NOT then continue.
	bra.s	cleanexit		;IF it is then quit.
delay:					;
	move.l	#128,d0			;Set the 'SPACE' of the square wave.
spaceloop:				;
	bclr	#7,$bfe001		;Reset bit 7 of the games port.
	dbf	d0,spaceloop		;Do the timer for the 'SPACE'.
	btst	#2,$dff016		;Check to see if the right mouse
					;button is pressed to quit.
	bne.s	rmb			;IF NOT then loop until it is.
					;
cleanexit:				;
	bclr	#7,$bfe001		;Ensure output is set to zero.
	movea.l	$4,a6			;Set the 'ExecBase' pointer again.
					;NOTE:- This is a double check only!
	jsr	-126(a6)		;Offset -126 == [_LVO]Enable()
					;Enable interrupts and tasking.
	jsr	-138(a6)		;Offset -138 == [_LVO]Permit()
	movem.l	(sp)+,d0-d7/a0-a6	;Restore all registers.
					;
	clr.l	d0			;Ensure return code is 0.
					;
	rts				;Return to calling routine.
					;
	END				;END... SIMPLE EH!
