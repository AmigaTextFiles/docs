
	;$VER: TTL-Clock.asm_Version_0.10.00_(C)2007_B.Walker_G0LCU.
	;-----------------------------------------------------------
					;
					;This is an example pf direct HW
					;access using plain assembly. It
					;is the fastest means of generating
					;a TTL level clock pulse for your
					;usage.
					;
					;Assembled with a68k.
					;
	;	http://main.aminet.net/dev/asm/A68kGibbs.lha
					;
					;Linked with blink.
					;
	;	http://main.aminet.net/dev/misc/blink67.lha
					;
					;START...
	movem.l	d0-d7/a0-a6,-(sp)	;Save all registers just in case!
					;
	movea.l	$4,a6			;Set the 'ExecBase' pointer.
	jsr	-132(a6)		;Offset -132 == [_LVO]Forbid()
					;Disable tasking and interrupts
	jsr	-120(a6)		;Offset -120 == [_LVO]Disable()
					;
	bset	#7,$bfe201		;Set pin 6 of the games port to
					;WRITE mode.
lmb:					;
	bchg	#7,$bfe001		;Toggle bit 7 of the games port.
	btst	#6,$bfe001		;Check to see if the left mouse
					;button is pressed to quit.
	bne.s	lmb			;IF NOT then loop until it is.
					;
	bclr	#7,$bfe201		;Reset pin 6 of the games port to
					;READ mode.
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
