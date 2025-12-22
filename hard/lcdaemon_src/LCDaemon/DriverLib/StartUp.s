
; Maxon C++ Compiler
; StartUp.c


	XREF	_GetBaseReg
	XREF	_CleanupModules
	XREF	_InitModules
	XREF	_Remove
	XREF	_FreeMem
	XREF	_ExLibName
	XREF	_ExLibID
	XREF	_Copyright
	XREF	_ROMTag
	XREF	_AsmStub

	SECTION ":0",CODE


;struct LCDDriverBase * InitLib( register __a6 struct ExecBase      *
	XDEF	_InitLib
_InitLib
L7	EQU	-$C
	link	a5,#L7+4
L8	EQU	$800
	move.l	a3,-(a7)
; GetBaseReg();
	move.l	d0,-4(a5)
	move.l	a0,-$8(a5)
	jsr	_GetBaseReg
	move.l	-4(a5),d0
	move.l	-$8(a5),a0
; InitModules();
	move.l	d0,-4(a5)
	move.l	a0,-$8(a5)
	jsr	_InitModules
	move.l	-4(a5),d0
	move.l	-$8(a5),a0
; LCDDriverBase = lcddrvb;
	move.l	d0,_LCDDriverBase-$8000(a4)
; LCDDriverBase->lcddrvb_SysBase = sysbase;
	move.l	_LCDDriverBase-$8000(a4),a3
	move.l	a6,$26(a3)
; LCDDriverBase->lcddrvb_SegList = seglist;
	move.l	a0,$22(a3)
; if(L_OpenLibs()) 
	move.l	d0,-4(a5)
	move.l	a0,-$8(a5)
	jsr	_L_OpenLibs
	move.l	-$8(a5),a0
	tst.l	d0
	move.l	-4(a5),d0
	beq.b	L1
; if(L_OpenLibs()) return(LCDDriverBase);
	move.l	d0,-4(a5)
	move.l	_LCDDriverBase-$8000(a4),d0
	movem.l	(a7)+,a3
	unlk	a5
	rts
L1
; L_CloseLibs();
	move.l	d0,-4(a5)
	move.l	a0,-$8(a5)
	jsr	_L_CloseLibs
	move.l	-4(a5),d0
	move.l	-$8(a5),a0
; return(NULL);
	move.l	d0,-4(a5)
	moveq	#0,d0
	move.l	(a7)+,a3
	unlk	a5
	rts

;struct LCDDriverBase * OpenLib( register __a6 struct LCDDriverBase *
	XDEF	_OpenLib
_OpenLib
L9	EQU	0
L10	EQU	0
; GetBaseReg();
	jsr	_GetBaseReg
; LCDDriverBase->lcddrvb_LibNode.lib_OpenCnt++;
	addq.w	#1,$20(a6)
; LCDDriverBase->lcddrvb_LibNode.lib_Flags &= ~LIBF_DELEXP;
	and.b	#$F7,$E(a6)
; return(LCDDriverBase);
	move.l	a6,d0
	rts

;struct SegList * CloseLib( register __a6 struct LCDDriverBase *LCDDr
	XDEF	_CloseLib
_CloseLib
L11	EQU	-$C
	link	a5,#L11+4
L12	EQU	$80
	move.l	d7,-(a7)
; GetBaseReg();
	jsr	_GetBaseReg
; LCDDriverBase->lcddrvb_LibNode.lib_OpenCnt--;
	subq.w	#1,$20(a6)
; if(!LCDDriverBase->lcddrvb_LibNode.lib_OpenCnt)
	tst.w	$20(a6)
	bne.b	L3
;  
;   if(LCDDriverBase->lcddrvb_LibNode.lib_Flags & LIBF_DELEXP)
	moveq	#0,d7
	move.b	$E(a6),d7
	and.l	#$8,d7
	beq.b	L3
;    
;     return( ExpungeLib(LCDDriverBase) );
	move.l	a6,-4(a5)
	move.l	a6,-$8(a5)
	jsr	_ExpungeLib
	move.l	-4(a5),a6
	move.l	(a7)+,d7
	unlk	a5
	rts
;     return( ExpungeLib(LCDDriverBase) );
L2
;     return( ExpungeLib(LCDDriverBase) );
L3
; return(NULL);
	moveq	#0,d0
	move.l	(a7)+,d7
	unlk	a5
	rts

;struct SegList * ExpungeLib( register __a6 struct LCDDriverBase *lcd
	XDEF	_ExpungeLib
_ExpungeLib
L13	EQU	-$2C
	link	a5,#L13+20
L14	EQU	$49C
	movem.l	d2-d4/d7/a2,-(a7)
; struct LCDDriverBase *LCDDriverBase = lcddrvb;
	move.l	a6,a2
; GetBaseReg();
	jsr	_GetBaseReg
; if(!LCDDriverBase->lcddrvb_LibNode.lib_OpenCnt)
	tst.w	$20(a2)
	bne.b	L4
;  
;   UBYTE *negptr = (UBYTE *) LCDDriverBase;
	move.l	a2,-$18(a5)
;   seglist = LCDDriverBase->lcddrvb_SegList;
	move.l	$22(a2),-$8(a5)
;   Remove((struct Node *)LCDDriverBase);
	move.l	a2,-(a7)
	jsr	_Remove
	addq.l	#4,a7
;   L_CloseLibs();
	jsr	_L_CloseLibs
;   negsize  = LCDDriverBase->lcddrvb_LibNode.lib_NegSize;
	moveq	#0,d7
	move.w	$10(a2),d7
	move.l	d7,d2
;   possize  = LCDDriverBase->lcddrvb_LibNode.lib_PosSize;
	moveq	#0,d7
	move.w	$12(a2),d7
	move.l	d7,d4
;   fullsize = negsize + possize;
	move.l	d2,d7
	add.l	d4,d7
	move.l	d7,d3
;   negptr  -= negsize;
	sub.l	d2,-$18(a5)
;   FreeMem(negptr, fullsize);
	move.l	d3,-(a7)
	move.l	-$18(a5),-(a7)
	jsr	_FreeMem
	addq.l	#$8,a7
;   CleanupModules();
	jsr	_CleanupModules
;   return(seglist);
	move.l	-$8(a5),d0
	movem.l	(a7)+,d2-d4/d7/a2
	unlk	a5
	rts
;   return(seglist);
L4
; LCDDriverBase->lcddrvb_LibNode.lib_Flags |= LIBF_DELEXP;
	or.b	#$8,$E(a2)
; return(NULL);
	moveq	#0,d0
	movem.l	(a7)+,d2-d4/d7/a2
	unlk	a5
	rts

;ULONG ExtFuncLib(void)
	XDEF	_ExtFuncLib
_ExtFuncLib
L15	EQU	0
L16	EQU	0
; return(NULL);
	moveq	#0,d0
	rts

;ULONG L_OpenLibs(void)
	XDEF	_L_OpenLibs
_L_OpenLibs
L17	EQU	4
L18	EQU	$80
	move.l	d7,-(a7)
;	SysBase = (*((struct ExecBase **) 4));
	move.l	4,_SysBase-$8000(a4)
;	return TRUE|(&ROMTag?TRUE:FALSE);
	moveq	#1,d0
	move.l	#_ROMTag,d7
	beq.b	L19
	moveq	#1,d7
	bra.b	L20
L19
	moveq	#0,d7
L20
	or.l	d7,d0
	move.l	(a7)+,d7
	rts

;void L_CloseLibs(void)
	XDEF	_L_CloseLibs
_L_CloseLibs
L21	EQU	0
L22	EQU	0
	rts

	SECTION ":4",DATA,SMALL

_LIB_VERS
	dc.b	$25
	CNOP	0,2
_LIB_REV
	dc.w	1
	CNOP	0,4
	XDEF	_DataTab
_DataTab
	dc.w	$E000,$8,$900
	dc.b	$80,$A
	dc.l	_ExLibName
	dc.w	$E000,$E,$600,$D000,$14,$25,$D000,$16
	dc.w	1
	dc.b	$80,$18
	dc.l	_ExLibID,0
	XDEF	_LCDDriverBase
_LCDDriverBase
	dc.l	0
	XDEF	_SysBase
_SysBase
	dc.l	0

	END
