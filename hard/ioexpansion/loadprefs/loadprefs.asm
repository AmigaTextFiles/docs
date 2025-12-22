;loadprefs.asm - loads prefs into memory
;place in startup sequence
;by Dan Babcock, March 1991

	exeobj
	objfile	'loadprefs'

	move.l	(4).w,a6
	moveq	#0,d7

	lea	(MagicPortName,pc),a1
	SYS	FindPort
	move.l	d0,a4
	tst.l	d0
	beq.b	.NotFound
	moveq	#1,d7
	bra.b	.PortFound

.NotFound:
	move.l	#MEMF_CLEAR+MEMF_PUBLIC,d1
	move.l	#MP_SIZE+32+PortNameLength,d0
	SYS	AllocMem
	tst.l	d0
	beq.b	Error
	move.l	d0,a4

;Copy name string
	lea	(MP_SIZE+32,a4),a3
	move.l	a3,a0
	lea	(MagicPortName,pc),a1
	move.w	#PortNameLength-1,d0
..	move.b	(a1)+,(a0)+
	dbra	d0,..

.PortFound:
	lea	(DosName,pc),a1
	SYS	OldOpenLibrary
	move.l	d0,a6
	move.l	#MODE_OLDFILE,d2
	move.l	#FileName,d1
	SYS	Open
	tst.l	d0
	beq.b	Error
	move.l	d0,a5	;file handle
	move.l	a5,d1
	move.l	a4,d2
	add.l	#MP_SIZE,d2
	moveq	#32,d3
	SYS	Read
	tst.l	d0
	bmi	Error

	move.l	a5,d1
	SYS	Close

	move.l	a6,a5
	move.l	(4).w,a6
	tst.l	d7
	bne.b	.CloseUp
	move.l	a3,(LN_NAME,a4)
	move.l	a4,a1
	SYS	AddPort

.CloseUp:
	move.l	a5,a1
	SYS	CloseLibrary
	moveq	#0,d0
	rts

Error:
	lea	(WrongMsg,pc),a0
	bsr.b	Print
	moveq	#100,d0
	rts

Print:
;Output a string to the CLI
;Enter with pointer to a zero-terminated string in a0
;All registers are preserved

	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	a0,a5
	movea.l	(4).w,a6
	lea	(DosName,pc),a1
	SYS	OldOpenLibrary
	tst.l	d0
	beq.b	.PrintEnd
	movea.l	d0,a6
	movea.l	a5,a0
	movea.l	a5,a4
.PrintLine:
	tst.b	(a5)+
	bne.b	.PrintLine
	subq.l	#1,a5
	suba.l	a0,a5
	SYS	Output
	move.l	d0,d1  
	move.l	a4,d2
	move.l	a5,d3
	SYS	Write
	movea.l	a6,a1
	movea.l	(4).w,a6
	SYS	CloseLibrary
.PrintEnd:
	movem.l	(sp)+,d0-d7/a0-a6
	rts

MagicPortName:	dc.b	'newser_prefs',0
PortNameLength	equ	*-MagicPortName
	even
FileName:	dc.b	's:serial-preferences',0
	even
WrongMsg:	dc.b	'Couldn''t load s:serial-preferences !',$a,0
	even
DosName:	dc.b	'dos.library',0
	even

	END
