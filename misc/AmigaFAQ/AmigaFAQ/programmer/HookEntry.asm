		xdef	_HookEntry

_HookEntry:
		movem.l d2-d7/a2-a6,-(sp)   ;   Preserve regs
					    ;	amiga.lib/HookEntry doesn't
					    ;	do this, but experience has
					    ;	proved that it would better
					    ;	do, as most called functions
					    ;	will initialize the a4
					    ;	register

		move.l	a1,-(a7)            ;   Put args on the stack
		move.l	a2,-(a7)
		move.l	a0,-(a7)
		move.l	12(a0),a0           ;   Call hook
		jsr	(a0)
		lea	12(sp),sp           ;   Restore stack
		movem.l (sp)+,d2-d7/a2-a6   ;   Restore regs
		rts
