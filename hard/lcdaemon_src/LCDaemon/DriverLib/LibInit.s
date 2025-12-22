
; Maxon C++ Compiler
; LibInit.c


	XREF	_LCDDriverBase
	XREF	_ExLibName
	XREF	_ExLibID
	XREF	_Copyright
	XREF	_LIB_VERS
	XREF	_LIB_REV
	XREF	_InitTab
	XREF	_ROMTag
	XREF	_AsmStub

	SECTION ":0",CODE


	XDEF	_INIT_8_LibInit_c
_INIT_8_LibInit_c
L1	EQU	0
L2	EQU	0
;struct ExecBase		*SysBase			=	NULL;
	moveq	#0,d0
	move.b	_LIB_VERS,d0
	move.w	d0,_DataTab-$7FEA(a4)
	move.w	_LIB_REV,_DataTab-$7FE4(a4)
	rts

;ULONG __saveds __stdargs L_OpenLibs(void)
	XDEF	_L_OpenLibs
_L_OpenLibs
L3	EQU	4
L4	EQU	$80
	move.l	d7,-(a7)
;	SysBase = (*((struct ExecBase **) 4));
	move.l	4,_SysBase-$8000(a4)
;	return TRUE|(&ROMTag?TRUE:FALSE);
	moveq	#1,d0
	move.l	#_ROMTag,d7
	beq.b	L5
	moveq	#1,d7
	bra.b	L6
L5
	moveq	#0,d7
L6
	or.l	d7,d0
	move.l	(a7)+,d7
	rts

;void __saveds __stdargs L_CloseLibs(void)
	XDEF	_L_CloseLibs
_L_CloseLibs
L7	EQU	0
L8	EQU	0
	rts

	SECTION ":4",DATA,SMALL

	XDEF	_SysBase
_SysBase
	dc.l	0
	XDEF	_DataTab
_DataTab
	dc.w	$E000,$8,$900
	dc.b	$80,$A
	dc.l	_ExLibName+0
	dc.w	$E000,$E,$600,$D000,$14
	ds.b	2
	dc.w	$D000,$16
	ds.b	2
	dc.b	$80,$18
	dc.l	_ExLibID+0,0

	END
