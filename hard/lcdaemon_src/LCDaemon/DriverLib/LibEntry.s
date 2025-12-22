
; Maxon C++ Compiler
; LibEntry.c



	SECTION ":0",CODE


;LONG __saveds __asm LibStart(void)
	XDEF	_LibStart
_LibStart
L1	EQU	0
L2	EQU	0
; return(-1);
	moveq	#-1,d0
	rts

	END
