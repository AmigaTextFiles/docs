
DEBUGBOOL		=	0	(DEBUG-Modus bei TRUE an)

;;	*****************************************************************
	*	Programm:	AntiRaBB.bb				*
	*			BBCode für AntiRaBB			*
	*	Copyright:	PD von Hanns Holger Rutz/TropicDesign	*
	*	last changez:	10.02.1993				*
	*****************************************************************

;;- Includes --------------------------

		incdir	'sys:asm/inc/'
		include	'devices/trackdisk.i'
		include	'exec/memory.i'
		include	'exec/resident.i'
		include	'hardware/custom.i'
		include	'private/dos_lib.i'
		include	'private/exec_lib.i'
		include	'private/expansion_lib.i'
		include	'private/gfx_lib.i'

;;- Konstanten ------------------------

eb_Flags	=	34
Time		=	4	Sekunden, die gewartet wird
width		=	256	muß durch 32 teilbar sein
height		=	29
HStart		=	208	"   "     "  "       "
VStart		=	150
DiWStrt		=	VStart<<8!HStart
DiWStop		=	(VStart+height)<<8!((HStart+width/2)&$ff)
DDFStrt		=	(HStart/2-4)&$fffc
DDFStop		=	(HStart/2-4)&$fffc+(width/4-8)

		rsreset
cp_Color00	rs.w	2	Hintergrundfarbe
cp_Color01	rs.w	2	Schriftfarbe
cp_Plane0	rs.w	2*2	BitplanePointer
cp_END		rs.w	2	$fffffffe
cp_SIZEOF	rs.b	0

;;- Bootblock-Header (wird von Installer init.)

*_BBHeader	dc.l	'DOS'<<8!1,0,880	(wird vom Installer init.)

;;- Hauptprogramm ---------------------
;	In:	a1 = *TrackDiskIO, a6 = *ExecBase

_Start		movem.l	d2-d7/a2/a3/a5/a6,-(sp)
		lea.l	$dff000+dmacon,a5
		moveq.l	#0,d6
		move.w	dmaconr-dmacon(a5),d5
		move.l	#(width/8*height)+cp_SIZEOF,d4

_MotorOff	clr.l	IO_LENGTH(a1)
		move.w	#TD_MOTOR,IO_COMMAND(a1)
		jsr	_LVODoIO(a6)			Motor ausschalten

_GetPlane	move.l	d4,d0
		moveq.l	#MEMF_CHIP!MEMF_PUBLIC,d1
		jsr	_LVOAllocMem(a6)		Bitplane+CopList holen
		move.l	d0,d3
		beq.w	_GfxDone			..Fehler
		movea.l	d0,a3
		adda.l	d4,a3				a3=EOCopList
		moveq.l	#$fffffffe,d1
		move.l	d1,-(a3)			CopListe-Ende
		move.w	d0,-(a3)			BPl0PtL
		move.w	#bplpt+$02,-(a3)
		swap.w	d0
		move.w	d0,-(a3)			BPl0PtH
		move.w	#bplpt+$00,-(a3)
		clr.w	-(a3)				Color01
		move.w	#color+$02,-(a3)
		clr.w	-(a3)				Color00
		move.w	#color+$00,-(a3)

_OpenGfxLib	lea.l	_GfxName(pc),a1
		moveq.l	#33,d0
		jsr	_LVOOpenLibrary(a6)		Gfx.library öffnen
		move.l	d0,d7
		beq.w	_GfxDone			..Fehler

_DecrunchGfx	lea.l	_Gfx(pc),a1
		lea.l	_GfxEnd(pc),a2
		movea.l	d3,a0
.Loop		moveq.l	#0,d1
		move.b	(a1)+,d1
		blt.b	.Crunched			..gecruncht
.Loop2		move.b	(a1)+,(a0)+			..direkt kopieren
		dbf	d1,.Loop2
		bra.b	.Cont
.Crunched	move.b	(a1)+,d0			sich wiederholend. Byte
		neg.b	d1
.Loop3		move.b	d0,(a0)+			..x-mal kopieren
		dbf	d1,.Loop3
.Cont		cmpa.l	a1,a2
		bgt.b	.Loop				..Schleife

_StartCopper	move.w	#%0000001110100000,(a5)
		move.l	a3,cop1lc-dmacon(a5)
		move.w	d6,copjmp1-dmacon(a5)
		move.l	#DiWStrt<<16!DiWStop,diwstrt-dmacon(a5)
		move.l	#DDFStrt<<16!DDFStop,ddfstrt-dmacon(a5)
		move.l	#%1001001000000000<<16!0,bplcon0-dmacon(a5)
		move.w	d6,bpl1mod-dmacon(a5)
		move.w	#%1000001111000000,(a5)		alle benötigten DMAs an

		btst.b #6,$bfe001
		beq.b  _ActivateStdCop			..linker Mausknopf
_Fade		move.w	#$111,d0
		bsr.b	_FadeIt				einfaden
		moveq.l	#Time*25-1,d2
		bsr.b	_Wait				warten
		neg.w	d0
		bsr.b	_FadeIt				ausfaden

_ActivateStdCop	movea.l	d7,a1				GfxBase
		move.w	#%0000001111000000,(a5)
		move.l	gb_copinit(a1),cop1lc-dmacon(a5)	StdCopList
		move.w	d6,copjmp1(a5)
		ori.w	#%1000001000000000,d5
		move.w	d5,(a5)				alte DMAs ein
		jsr	_LVOCloseLibrary(a6)		Gfx.library schließen

_FreePlane	move.l	d4,d0
		movea.l	d3,a1
		jsr	_LVOFreeMem(a6)			Bitplane+Cop. freigeben
_GfxDone	movem.l	(sp)+,d2-d7/a2/a3/a5/a6
		;||
;;- (Fast) normaler OS2.0 Bootblock ----------
;	In:	a6 = *ExecBase

_StdBootCode	lea.l	_ExpansionName(pc),a1
		moveq.l	#37,d0
		jsr	_LVOOpenLibrary(a6)
		tst.l	d0
		beq.b	_Quit
		movea.l	d0,a1
		bset.b	#6,eb_Flags(a1)		wahrscheinlich KICKBACK37
		jsr	_LVOCloseLibrary(a6)
_Quit		lea.l	_DOSName(pc),a1
		move.w	#'do',(a1)		-> dos.library
		jsr	_LVOFindResident(a6)
		tst.l	d0
		beq.b	_NoDOS
		movea.l	d0,a0
		movea.l	RT_INIT(a0),a0
		moveq.l	#0,d0
		rts
_NoDOS		moveq.l	#-1,d0
		rts

;;- Faden -----------------------------
;	In:	d0.w = $111 (einfaden) oder -$111 (ausfaden)
;	Out:	d1/d2 = zerstört

_FadeIt		moveq.l	#15-1,d1
.Loop		moveq.l	#1,d2
		bsr.b	_Wait
		add.w	d0,cp_Color01+2(a3)
		dbf	d1,.Loop
		rts

;;- Warten ----------------------------
;	In:	d2.w = 25stel Sek. -1

_Wait
.Loop		btst.b	#0,vposr+1-dmacon(a5)
		beq.b	.Loop
.Loop2		btst.b	#0,vposr+1-dmacon(a5)
		bne.b	.Loop2
		dbf	d2,.Loop
		rts

;;- Konstantenspeicher ----------------

_Gfx		incdir	'sys:asm/src/'
		incbin	'AntiRa.raw'		ByteRun1-gecrunchte Bitplane
_GfxEnd		odd
_GfxName	dc.b	'graph'		\
_DOSName	dc.b	'ics.library',0	/	<- wird zu 'dos.library'
			;^-- muß GERADE Adresse sein!
_ExpansionName	EXPANSIONNAME
		even

;;- Debugstuff ------------------------

		if DEBUGBOOL
		  printt  'Freie Bytes:'
		  printv  1012-(*-_Start)
		endc

;;- Fehlerabfang ----------------------

_End		iflt 1012-(*-_Start)
		  fail
		endc
		rept	100
		dc.b	'Holgi/'
		endr
