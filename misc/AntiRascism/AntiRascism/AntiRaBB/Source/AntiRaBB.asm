***	BUG: mi_NextSelect wird nicht unterstützt

;;	*****************************************************************
	*	Programm:	AntiRaBB				*
	*			(installiert einen Bootblock, der den	*
	*			 Text "Gegen Rassismus!" ausgibt)	*
	*	Copyright:	Freeware © von Hanns Holger Rutz (Tro-	*
	*			picDesign)				*
	*	History:	30.01.-05.02.1993 erste Version		*
	*			11.04.1993	  minor bug removed	*
	*****************************************************************

;;-- Includes --

		incdir	'sys:asm/inc/'
		include	'devices/bootblock.i'
		include	'devices/trackdisk.i'
		include	'dos/dosextens.i'
		include	'exec/execbase.i'
		include	'exec/memory.i'
		include	'intuition/intuition.i'
		include	'private/exec_lib.i'
		include	'private/gfx_lib.i'
		include	'private/intuition_lib.i'

;;-- Macros --

exec		macro
		if NARG
			move.l	4.w,\1
		else
			movea.l	4.w,lb
		endc
		endm

slib		macro
		if NARG>1
			move.l	gl_\1Base(gl),\2
		else
			movea.l	gl_\1Base(gl),lb
		endc
		endm

fjsr		macro
		jsr	_LVO\1(lb)
		endm

push		macro
		movem.l	\1,-(sp)
		endm

pull		macro
		movem.l	(sp)+,\1
		endm

rsword		macro
.addr		rs.b	0
		rs.b	.addr&1		eventuell auf WORD-Länge aufrunden
		endm

rslong		macro
.addr		rs.b	0
		rs.b	(-.addr)&3	eventuell auf LONG-Länge aufrunden
		endm

version		macro
		dc.b	'1.0b'		Version/Revision des Programms
		endm

sbase		macro
Base		set	*		Basis für soff-Definitionen festlegen
		endm

soff		macro
\1		set	~(*-Base)	=> ~\1+Base = Adresse
		if NARG>1
\2		set	*-Base		=> gl_\1 = gl_SIZE-Off./chip_SIZE-Off.
		endc
		endm

;;-- Konstanten --

lb		equr	a6		Librarybasis
gl		equr	a5		globale Variablen
GADGDISABLEDb	=	8		Bits für
GRELBOTTOMb	=	3		..Gadgetflags
ITEMENABLEDb	=	4		Bits für
COMMSEQb	=	2		..MenuItem-Flags
ITEMTEXTb	=	1
BB_SIZEOF	=	TD_SECTOR*BOOTSECTS	Gesamtgröße des BB

		rsreset			;\
flo_IO		rs.b	IOTD_SIZE	 / IORequest
flo_Port	rs.b	MP_SIZE		ReplyPort
flo_SIZEOF	rs.b	0

;;-- Startup --

_Start		move.w	#((gl_SIZEOF-gl_SIZE)/2)-1,d0
		lea.l	_GfxEnd(pc),a0			variablen Speicher
.SetGlobal	move.w	-(a0),-(sp)			..kopieren
		dbf	d0,.SetGlobal
		move.w	#(gl_SIZE/2)-1,d0
.ClearGlobal	clr.w	-(sp)				globales VarMem anlegen
		dbf	d0,.ClearGlobal
		movea.l	sp,gl
		move.b	#RETURN_FAIL,gl_Return(gl)	CLI-Returncode

		exec
		movea.l	ThisTask(lb),a2
		move.l	a2,gl_Process(gl)	Taskadresse sichern
		tst.l	pr_CLI(a2)
		bne.b	.Cont			..CLI-Start
		lea.l	pr_MsgPort(a2),a0
		fjsr	WaitPort
		lea.l	pr_MsgPort(a2),a0
		fjsr	GetMsg
		move.l	d0,gl_WBMsg(gl)		..WB-Start, Msg sichern
.Cont
		bsr.w	_AllocChip		ChipMem besorgen
		beq.b	_CleanUp		..Fehler
		bsr.w	_OpenLibs		Intui/Gfx-Lib öffnen
		beq.b	_CleanUp		..Fehler
		bsr.w	_OpenTrackDisx		IORequests anlegen
		beq.b	_CleanUp		..keine Unit verfügbar
		bsr.w	_OpenDisplay		Window etc. öffnen
		beq.b	_CleanUp		..Fehler

;;-- Hauptschleife --

_Main		clr.b	gl_Return(gl)		Returncode = RETURN_OK
_MainLoop	movea.l	gl_Window(gl),a0
		bsr.w	_GetMsg			auf Message warten
		cmpi.b	#3,d0
		ble.w	_Install		..Installieren
		subq.b	#4,d0
		beq.w	_Undo			..Rückgängig machen
		subq.b	#2,d0
		beq.w	_Info			..Info
		;||				..Ende
;;-- Aufräumen --

_CleanUp	bsr.w	_CloseDisplay		alles wieder schließen
		bsr.w	_CloseTrackDisx
		bsr.w	_CloseLibs
		bsr.w	_FreeChip

_Quit		move.l	gl_WBMsg(gl),d2
		beq.b	.Cont			..CLI-Start
		exec
		fjsr	Forbid			(ist sicherer)
		movea.l	d2,a1
		fjsr	ReplyMsg		StartupMsg beantworten
.Cont		moveq.l	#0,d0
		move.b	gl_Return(gl),d0	Returncode in d0
		beq.b	.Exit			..alles ok
		movea.l	gl_Process(gl),a0
		move.l	gl_Result2(gl),pr_Result2(a0)	2. Returncode setzen
.Exit		lea.l	gl_SIZEOF(sp),sp		Stack korrigieren
		rts					Programmende

;;-- Globaler Konstantenspeicher --

_Version	dc.b	'$VER: AntiRaBB '
		version
		dc.b	0
		even
_WriteBuf	incdir	'sys:asm/src/'
		incbin	'AntiRaBB.bb'		BootCode (1012 Bytes)

;;-- Informationsrequester --
;	ACHTUNG: nur von _Main über bcc anspringen!

_Info		push	a0/a1
		lea.l	.InfoBody(pc),a0	Text
		movea.l	gl_ChipMem(gl),a1	..und Image
		*lea.l	chip_Tropic(a1),a1	(=NULL)
		bsr.w	_Request		..als Requester darstellen
		pull	a0/a1
		bra.w	_MainLoop

.InfoBody	dc.b	'                    AntiRaBB ist ein',$0a
		dc.b	'                    Freewareprogramm',$0a
		dc.b	'                    © von Hanns Hol-',$0a
		dc.b	'                    ger  Rutz.  Tro-',$0a
		dc.b	'                    picDesign   sind',$0a
		dc.b	'Hanns Holger Rutz  und  Marco Brink-',$0a
		dc.b	'mann.  Lies das Doc-File für weitere',$0a
		dc.b	'Informationen!',$0a
		dc.b	'                           - Holgi -',0
		even

;;-- Undobuffer zurückschreiben --
;	ACHTUNG: nur von _Main über bcc anspringen!

_Undo		push	d0/d1/a0-a2/lb
		bsr.w	_WaitPtr		WaitPointer setzen
		exec
		moveq.l	#0,d0
		move.b	gl_UndoFloppy(gl),d0
		mulu.w	#flo_SIZEOF,d0
		lea.l	gl_Floppy0(gl,d0.w),a2			IORequest
		move.w	#TD_CHANGENUM,flo_IO+IO_COMMAND(a2)
		movea.l	a2,a1
		fjsr	DoIO			Diskwechsel-Zahl holen
		tst.b	d0
		bne.b	.Error			..Fehler
		move.l	flo_IO+IO_ACTUAL(a2),d0
		cmp.l	gl_UndoChange(gl),d0	Buffer gültig?
		bne.b	.Ungultig		..nein
		movea.l	gl_ChipMem(gl),a1
		lea.l	chip_UndoBuf(a1),a1
		movea.l	a2,a0
		bsr.w	_WriteBoot		UndoBuffer auf Disk schreiben
		bne.b	.Error			..Fehler
.Exit		bsr.w	_ClearPtr		Normalpointer setzen
		pull	d0/d1/a0-a2/lb
		bra.w	_MainLoop

.Ungultig	lea.l	gl_SIZE+gfx_UndoItem(gl),a0
		bclr.b	#ITEMENABLEDb,mi_Flags+1(a0)	Undo-Item disablen
		lea.l	.UngText(pc),a1			Fehlertext
		bra.b	.UndoError

.Error		suba.l	a1,a1				kein Fehlertext
.UndoError	lea.l	.UndoText(pc),a0		Fehleraktion
		move.b	gl_UndoFloppy(gl),d1		Unit
		bsr.w	_IOError			Requester darstellen
		bra.b	.Exit

.UndoText	dc.b	'Zurückschreiben',0
.UngText	dc.b	'Undobuffer ist ungültig',0	ACHTUNG: 0Byte vorne!
		even

;;-- Bootblock installieren --
;	ACHTUNG: nur von _Main über bcc anspringen!
;	In:	d0.b = UnitNummer

_Install	push	d0-d2/a0-a2/lb
		bsr.w	_WaitPtr		Waitpointer setzen
		move.b	d0,gl_UndoFloppy(gl)	Unit für Undobuffer merken
		exec
		ext.w	d0
		mulu.w	#flo_SIZEOF,d0
		lea.l	gl_Floppy0(gl,d0.w),a2	IORequest
		movea.l	a2,a0
		bsr.w	_ReadBoot		alten BB lesen
		bne.b	.Error					..Fehler
		move.w	#TD_CHANGENUM,flo_IO+IO_COMMAND(a2)
		movea.l	a2,a1
		fjsr	DoIO			Diskwechsel-Zahl holen
		tst.b	d0
		bne.b	.Error					..Fehler
		move.l	flo_IO+IO_ACTUAL(a2),gl_UndoChange(gl)	Zahl sichern
		lea.l	gl_SIZE+gfx_UndoItem(gl),a0
		bset.b	#ITEMENABLEDb,mi_Flags+1(a0)	Undo-Item enablen

		movea.l	gl_ChipMem(gl),a0
		lea.l	chip_UndoBuf(a0),a1
		lea.l	chip_ReadBuf(a0),a0
		move.w	#BB_SIZEOF/4-1,d0
.UndoLoop	move.l	(a0)+,(a1)+		alten BB in UndoBuffer kop.
		dbf	d0,.UndoLoop

		lea.l	-BB_SIZEOF(a0),a0
		lea.l	_WriteBuf(pc),a1
		move.w	#(BB_SIZEOF-BB_SIZE)/4,d0
		move.l	(a0)+,d1			BB_ID
		addq.l	#4,a0
		add.l	(a0)+,d1		..+BB_DOSBLOCK
		bra.b	.WriteCont
.WriteLoop	move.l	(a1),(a0)+		Bootcode über alten BB kop.
		add.l	(a1)+,d1		Checksumme
.WriteCont	bcc.b	.WriteEnd
		addq.l	#1,d1			..berechnen
.WriteEnd	dbf	d0,.WriteLoop
		not.l	d1

		lea.l	-BB_SIZEOF(a0),a1
		move.l	d1,BB_CHKSUM(a1)	..und eintragen
		movea.l	a2,a0
		bsr.w	_WriteBoot		BB installieren
		bne.b	.Error			..Fehler
.Exit		bsr.w	_ClearPtr		alten Pointer setzen
		pull	d0-d2/a0-a2/lb
		bra.w	_MainLoop

.Error		suba.l	a1,a1			kein Fehlertext
		move.b	3(sp),d1			UnitNummer
.InstallError	lea.l	gl_SIZE+gfx_UndoItem(gl),a0
		bclr.b	#ITEMENABLEDb,mi_Flags+1(a0)	Undo-Item disablen
		lea.l	.InstallText(pc),a0		Fehleraktion
		bsr.b	_IOError		Requester darstellen
		bra.b	.Exit

.InstallText	dc.b	'Installieren',0
		even

;;-- Requester bei DoIO-Fehler darstellen --
;	In:	a0 = *FehlerStelle, a1 = *FehlerText (oder 0, dann d0.b= TDERR)
;		d1.b = Unit
;	ACHTUNG: a0_SIZEOF+a1_SIZEOF darf max. 100 sein!

_IOError	push	d0/d1/a0-a3
		lea.l	-128(sp),sp
		movea.l	sp,a2
		lea.l	.BodyText(pc),a3
.BodyLoop	move.b	(a3)+,(a2)+		'Unit x: Fehler...' kopieren
		bne.b	.BodyLoop
		add.b	d1,5(sp)		UnitNummer korrigieren
		subq.l	#1,a2
.StelleLoop	move.b	(a0)+,(a2)+		Fehleraktion kopieren
		bne.b	.StelleLoop
		move.b	#',',-1(a2)
		move.b	#$0a,(a2)+
		move.l	a1,d1			Fehlertext angegeben?
		beq.b	.CalcFehler		..nein
.FehlerLoop	move.b	(a1)+,(a2)+		..ja, kopieren
		bne.b	.FehlerLoop
		move.b	#'!',-1(a2)
		clr.b	(a2)
		movea.l	sp,a0
		suba.l	a1,a1
		bsr.w	_Request		Requester darstellen
		lea.l	128(sp),sp
		pull	d0/d1/a0-a3
		rts

.CalcFehler	moveq.l	#0,d1
		subi.b	#20,d0
		blt.b	.Calc2			..kein bekannter TDERR
		cmpi.b	#35-20,d0
		bgt.b	.Calc2			.."    "
		moveq.l	#0,d1
		move.b	d0,d1
		lsl.b	#2,d1			Offset berechnen
.Calc2		lea.l	gl_SIZE(gl),a0
		move.l	a0,d0
		lea.l	gl_SIZE+gfx_TDERR20(gl),a0
		add.l	d1,a0				Pointer berechnen
		bsr.w	_Addr			..und korrigieren
		movea.l	a0,a1
		bra.b	.FehlerLoop

.BodyText	dc.b	'Unit 0: Fehler beim ',0
		even

;;-- Bootblock einlesen --
;	In:	a0 = *IORequest
;	Out:	d0.b = IOError, cc=d0.b

_ReadBoot	push	d1/a0-a2/lb
		exec
		movea.l	a0,a2
		movea.l	gl_ChipMem(gl),a0
		lea.l	chip_ReadBuf(a0),a0
		move.l	a0,IO_DATA(a2)			Bufferadresse
		move.l	#BB_SIZEOF,IO_LENGTH(a2)	Größe
		clr.l	IO_OFFSET(a2)			Blockstart
		move.w	#CMD_READ,IO_COMMAND(a2)
		movea.l	a2,a1
		fjsr	DoIO			BB einlesen
		movea.l	a2,a0
		bsr.b	_MotorOff		Motor ausschalten
		tst.b	d0			cc setzen
		pull	d1/a0-a2/lb
		rts

;;-- Bootblock schreiben --
;	In:	a0 = *IORequest, a1 = *BootBlock
;	Out:	d0.b = IOError, cc=d0.b

_WriteBoot	push	d1/a0-a2/lb
		exec
		movea.l	a0,a2
		move.l	a1,IO_DATA(a2)			Buffer
		move.l	#BB_SIZEOF,IO_LENGTH(a2)	Größe
		clr.l	IO_OFFSET(a2)			Blockstart
		move.w	#CMD_WRITE,IO_COMMAND(a2)
		movea.l	a2,a1
		fjsr	DoIO			BB schreiben
		tst.b	d0
		bne.b	.Exit				..Fehler
		move.w	#CMD_UPDATE,IO_COMMAND(a2)
		movea.l	a2,a1
		fjsr	DoIO			TrackBuffer flushen
.Exit		movea.l	a2,a0
		bsr.b	_MotorOff		Motor aus
		tst.b	d0			cc setzen
		pull	d1/a0-a2/lb
		rts

;;-- Motor ausschalten
;	In:	a0 = *IORequest

_MotorOff	push	d0/d1/a0/a1/lb
		exec
		movea.l	a0,a1
		clr.l	IO_LENGTH(a1)			= Motor aus
		move.w	#TD_MOTOR,IO_COMMAND(a1)
		fjsr	DoIO
		pull	d0/d1/a0/a1/lb
		rts

;;-- ChipMem besorgen --
;	Out:	cc=eq, wenn Fehler

_AllocChip	push	d0/d1/a0/a1/lb
		exec
		move.l	#chip_SIZEOF,d0
		moveq.l	#MEMF_CHIP!MEMF_PUBLIC,d1
		fjsr	AllocMem			Speicher holen
		move.l	d0,gl_ChipMem(gl)	..und sichern
		beq.b	.Exit			..Fehler
		movea.l	d0,a0
		lea.l	_ChipStart(pc),a1
		move.w	#chip_SIZE/2-1,d0
.Loop		move.w	(a1)+,(a0)+		existierende Daten umkop.
		dbf	d0,.Loop
		moveq.l	#-1,d0			cc setzen
.Exit		pull	d0/d1/a0/a1/lb
		rts

;;-- ChipMem freigeben --

_FreeChip	push	d0/d1/a0/a1/lb
		exec
		move.l	gl_ChipMem(gl),d0	Speicher allokiert?
		beq.b	.Exit			..nein
		movea.l	d0,a1
		move.l	#chip_SIZEOF,d0
		fjsr	FreeMem			..ja, freigeben
.Exit		pull	d0/d1/a0/a1/lb
		rts

;;-- Libraries öffnen --
;	Out:	cc=eq, wenn Fehler

_OpenLibs	push	d0/d1/a0/a1/lb
		exec
		lea.l	.IntuiName(pc),a1
		moveq.l	#33,d0			(Kickstart 1.2)
		fjsr	OpenLibrary		Intui.lib öffnen
		move.l	d0,gl_IntuiBase(gl)	..und Basis sichern
		beq.b	.Error			..Fehler
		lea.l	.GfxName(pc),a1
		moveq.l	#33,d0
		fjsr	OpenLibrary		Gfx.lib öffnen
		move.l	d0,gl_GfxBase(gl)	..und Basis sichern
		beq.b	.Error			..Fehler
.Exit		pull	d0/d1/a0/a1/lb
		rts

.Error		moveq.l	#ERROR_INVALID_RESIDENT_LIBRARY,d0
		move.l	d0,gl_Result2(gl)			Result2 setzen
		clr.b	d0			cc setzen
		bra.b	.Exit

.IntuiName	INTUINAME
.GfxName	GRAPHICSNAME
		even

;;-- Libraries schließen --

_CloseLibs	push	d0/d1/a0/a1/lb
		exec
		slib	Gfx,d0			Gfx.lib geöffnet?
		beq.b	.CloseIntui		..nein
		movea.l	d0,a1
		fjsr	CloseLibrary		..ja, schließen
.CloseIntui	slib	Intui,d0		Intui.lib geöffnet?
		beq.b	.Exit			..nein
		movea.l	d0,a1
		fjsr	CloseLibrary		..ja, schließen
.Exit		pull	d0/d1/a0/a1/lb
		rts

;;-- Trackdisk-Device für alle 4 Floppys öffnen --
;	Out:	cc=eq, wenn Fehler

_OpenTrackDisx	push	d0/d1/a0
		moveq.l	#%1111,d1		Maske (Bit gesetzt->Drive an)
		moveq.l	#4-1,d0			max. Units
		lea.l	gl_Floppy3(gl),a0
.Loop		bsr.b	_OpenFloppy		IORequest besorgen/Device öff.
		beq.b	.SignalError		..AllocSignal()-Fehler
		bgt.b	.LoopCont		..ok
		bclr.l	d0,d1			..Fehler, entsprechendes Bit=0
.LoopCont	lea.l	-flo_SIZEOF(a0),a0
		dbf	d0,.Loop

		move.b	d1,gl_Floppies(gl)	Maske sichern
		beq.b	.DiskError		..kein Drive aktiv!
.Exit		pull	d0/d1/a0
		rts

.DiskError	move.l	#ERROR_NO_DISK,gl_Result2(gl)	<- der paßt doch :-)
.SignalError	clr.b	d0				cc setzen
		bra.b	.Exit

;;-- Trackdisk-Device öffnen --
;	In:	d0.l = Unit, a0.l = *Floppy-Struktur
;	Out:	cc=eq, wenn kein Signal frei war
;		cc=lt, wenn OpenDevice() fehlschlug

_OpenFloppy	push	d0-d2/a0-a2/lb
		exec
		movea.l	a0,a2
		move.l	d0,d2
		moveq.l	#-1,d0
		fjsr	AllocSignal			SignalBit besorgen
		move.b	d0,flo_Port+MP_SIGBIT(a2)	..und sichern
		blt.b	.SignalError				..Fehler
		move.b	#NT_MSGPORT,flo_Port+LN_TYPE(a2)	weitere
		move.b	#PA_SIGNAL,flo_Port+MP_FLAGS(a2)	..Korrekturen
		move.l	gl_Process(gl),flo_Port+MP_SIGTASK(a2)

		lea.l	flo_Port+MP_MSGLIST(a2),a0	MsgListe
		lea.l	LH_TAILPRED(a0),a1
		move.l	a0,(a1)
		subq.l	#4,a1
		move.l	a1,(a0)				..initialisieren

		move.b	#NT_MESSAGE,flo_IO+LN_TYPE(a2)
		move.w	#IOTD_SIZE,flo_IO+MN_LENGTH(a2)
		lea.l	flo_Port(a2),a0
		move.l	a0,flo_IO+MN_REPLYPORT(a2)
		lea.l	.TrackDiskName(pc),a0
		move.l	d2,d0				Unit
		movea.l	a2,a1
		moveq.l	#0,d1			keine Flags
		fjsr	OpenDevice		Device öffnen
		tst.b	d0			Fehler?
		bne.b	.OpenError		..ja
		moveq.l	#1,d0			..nein, cc setzen
.FloppyExit	pull	d0-d2/a0-a2/lb
		rts

.SignalError	clr.b	d0			cc setzen
		bra.b	.FloppyExit

.OpenError	moveq.l	#-1,d0			cc setzen
		bra.b	.FloppyExit

.TrackDiskName	dc.b	'trackdisk.device',0
		even

;;-- Trackdisk-Device schließen (alle 4 Floppys) --

_CloseTrackDisx	push	d0-d2/a0-a2/lb
		exec
		moveq.l	#4-1,d2			max. Units
		lea.l	gl_Floppy3(gl),a2	Maske der aktiven Drives
.Loop		btst.b	d2,gl_Floppies(gl)	IORequest existent?
		beq.b	.LoopCont		..nein
		movea.l	a2,a1
		fjsr	CloseDevice		..ja, beenden
.LoopCont	moveq.l	#0,d0
		move.b	flo_Port+MP_SIGBIT(a2),d0	Signal belegt?
		ble.b	.LoopCont2			..nein
		fjsr	FreeSignal		..ja, freigeben
.LoopCont2	lea.l	-flo_SIZEOF(a2),a2
		dbf	d2,.Loop

		pull	d0-d2/a0-a2/lb
		rts

;;-- Window öffnen etc. --
;	Out:	cc=eq, wenn Fehler

_OpenDisplay	push	d0/d1/a0-a2/lb
		slib	Intui
		exec	a0
		cmpi.w	#36,LIB_VERSION(a0)
		blt.b	.NoOS2.0		..kleiner als OS2.0

.OS2.0		suba.l	a0,a0
		fjsr	LockPubScreen		default PubScreen holen
		tst.l	d0
		beq.b	.Exit			..Fehler
		movea.l	d0,a2
		move.l	sc_Width(a2),gl_ScrWidth(gl)	Screenbreite,
		movea.l	sc_Font(a2),a0
		move.l	a0,gl_BarFont(gl)		..Font und
		move.w	ta_YSize(a0),gl_BarHeight(gl)	..FontHöhe sichern
		movea.l	a2,a0
		fjsr	GetScreenDrawInfo
		movea.l	d0,a1
		move.l	dri_Pens(a1),a0
		move.b	TEXTPEN*2+1(a0),gl_TextPen(gl)		Farbregister
		move.b	SHINEPEN*2+1(a0),gl_ShinePen(gl)	..sichern
		move.b	SHADOWPEN*2+1(a0),gl_ShadowPen(gl)
		move.b	HIGHLIGHTTEXTPEN*2+1(a0),gl_HiTextPen(gl)
		move.b	BACKGROUNDPEN*2+1(a0),gl_BackPen(gl)
		fjsr	FreeScreenDrawInfo
		moveq.l	#PUBLICSCREEN,d0	ScreenType
		bsr.b	_Layout			Window öffnen etc.
		movea.l	a2,a1
		suba.l	a0,a0
		beq.b	.OS2.0Error		..Fehler
		fjsr	UnlockPubScreen		PubScreen freigeben
		moveq.l	#-1,d0			cc setzen
.Exit		pull	d0/d1/a0-a2/lb
		rts

.OS2.0Error	fjsr	UnlockPubScreen		PubScreen freigeben
		clr.b	d0			cc setzen
		bra.b	.Exit

;	ACHTUNG: Nach dem OpenWB() darf kein anderer Task den Screen schließen!

.NoOS2.0	fjsr	OpenWorkBench		WB-Screen öffnen
		tst.l	d0
		beq.b	.Exit			..Fehler
		movea.l	d0,a0				evtl. ungültig :-(
		move.l	sc_Width(a0),gl_ScrWidth(gl)	Screenbreite etc.
		movea.l	sc_Font(a0),a0			..sichern
		move.l	a0,gl_BarFont(gl)
		move.w	ta_YSize(a0),gl_BarHeight(gl)
		move.b	#1,gl_TextPen(gl)
		move.b	#1,gl_ShadowPen(gl)
		move.b	#2,gl_ShinePen(gl)
		move.b	#2,gl_HiTextPen(gl)
		*clr.b	gl_BackPen(gl)		(ist schon NULL)
		moveq.l	#WBENCHSCREEN,d0	ScreenType
		bsr.b	_Layout			Window öffnen etc.
		bra.b	.Exit

;;-- Window schließen etc. --

_CloseDisplay	push	d0-d2/a0/a1/lb
		move.l	gl_Window(gl),d2	Window geöffnet?
		beq.b	.Exit			..nein
		slib	Intui
		movea.l	d2,a0
		fjsr	ClearMenuStrip
		movea.l	d2,a0
		fjsr	CloseWindow		..ja, schließen
.Exit		pull	d0-d2/a0/a1/lb
		rts

;;-- alle Gadgets/Menüs/Texte layouten & Window öffnen--
;	korrigiert:	gg_NextGG, gg_TopEdge, gg_GGRender, gg_GGText
;			bd_NextBorder, bd_XY, bd_FrontPen
;			it_IText, it_NextText, it_FrontPen
;			ta_Name
;			nw_LeftEdge, nw_TopEdge, nw_Height, nw_Title, nw_Type
;			mu_Width, mu_Height, mu_MenuName, mu_FirstItem
;			mi_Left/TopEdge, mi_Width/Height, mi_ItemFill, mi_SubI.
;			u. v. m.
;	In:	d0 = Window/ScreenTyp (WB oder Public)
;	Out:	cc=eq, wenn Fehler

_Layout		push	d0-d2/a0/a1/lb
		slib	Intui
		lea.l	gl_SIZE(gl),a0		= NewWindow
		move.w	d0,nw_Type(a0)		Typ eintragen
		move.l	a0,d0
		bsr.w	_NewWindow		NewWindow layouten
		beq.b	.Exit				..Fehler
		lea.l	gl_SIZE+gfx_FirstStrip(gl),a0
		bsr.w	_MenuStrip			MenuStrip layouten
		lea.l	gl_SIZE+gfx_DF0Sub(gl),a0
		lea.l	gl_SIZE+gfx_DF0GG(gl),a1
		move.b	gl_Floppies(gl),d0		Drivemaske
.Loop		btst.l	#0,d0			Drive aktiv?
		beq.b	.Cont				..nein
		bclr.b	#GADGDISABLEDb,gg_Flags(a1)	..ja, Gadget und
		bset.b	#ITEMENABLEDb,mi_Flags+1(a0)	..MenuItem enablen
.Cont		movea.l	(a1),a1
		movea.l	(a0),a0
		lsr.b	#1,d0
		bne.b	.Loop

		lea.l	gl_SIZE(gl),a0
		fjsr	OpenWindow		Window öffnen
		move.l	d0,gl_Window(gl)	..und Adresse sichern
		beq.b	.Exit			..Fehler

		lea.l	gl_SIZE(gl),a0
		move.l	a0,d0				Basis
		lea.l	gl_SIZE+gfx_FirstIText(gl),a0
		bsr.w	_IText				IText layouten
		movea.l	a0,a1
		movea.l	gl_Window(gl),a0
		movea.l	wd_RPort(a0),a0
		moveq.l	#0,d0
		move.w	gl_BarHeight(gl),d1
		fjsr	PrintIText			..und ausgeben

		movea.l	gl_Window(gl),a0
		lea.l	gl_SIZE+gfx_FirstStrip(gl),a1
		fjsr	SetMenuStrip			MenuStrip setzen
		tst.l	d0			cc setzen

.Exit		pull	d0-d2/a0/a1/lb
		rts

;;-- Requester darstellen --
;	In:	a0 = *BodyText, a1 = *Image oder NULL
;	BodyText: Text, $0a, Text, $0a, Text..., 0
;	Out:	cc=eq, wenn Fehler
;	ACHTUNG: gfx_TopazFont muß initialisiert sein!

_Request	push	d0-d4/a0-a4/lb
		bsr.w	_WaitPtr
		moveq.l	#0,d2			Zeilenzahl
		moveq.l	#0,d1			max. Spalten
		movea.l	a0,a2
		movea.l	a1,d3
.CalcLoop	moveq.l	#0,d0			aktuelle Spalten
		addq.w	#1,d2			Zeilenzahl++
.CalcLoop2	tst.b	(a0)
		beq.b	.CalcExit		..Textende
		cmpi.b	#$0a,(a0)+
		beq.b	.CalcLoop		..Zeilenende
		addq.w	#1,d0			Spalten++
		cmp.w	d0,d1
		bgt.b	.CalcLoop2
		move.w	d0,d1			evtl. = max. Spalten
		bra.b	.CalcLoop2
.CalcExit	lsl.w	#3,d1			..* 8 = Pixels
		mulu.w	#9,d2			Zeilen * 9 = Pixels
		addi.w	#36,d1			Werte korrigieren
		addi.w	#34-1,d2

		lea.l	gl_SIZE(gl),a0
		move.l	a0,d0				Basis
		lea.l	gl_SIZE+gfx_ReqNewWin(gl),a0
		bsr.w	_ReqWindow			ReqNewWindow layouten
		beq.w	.Error			..Fehler
		slib	Intui
		fjsr	OpenWindow		Window öffnen
		tst.l	d0
		beq.w	.Error			..Fehler
		movea.l	d0,a3
		movea.l	wd_RPort(a3),a4

.DrawinStuff	slib	Gfx
		movea.l	a4,a1
		moveq.l	#RP_JAM1,d0
		fjsr	SetDrMd			DrawMode setzen
		lea.l	.Pattern(pc),a0
		move.l	a0,rp_AreaPtrn(a4)	Füllmuster
		move.b	#1,rp_AreaPtSz(a4)	Musterhöhe-1
		movea.l	a4,a1
		moveq.l	#0,d0
		move.b	gl_ShinePen(gl),d0
		fjsr	SetAPen			Farbe = hell
		movea.l	a4,a1
		moveq.l	#4,d0
		moveq.l	#3,d1
		add.w	gl_BarHeight(gl),d1
		movem.w	wd_Width(a3),d2/d3
		subq.l	#4,d2
		subq.l	#2,d3
		fjsr	RectFill		weiß/grau füllen
		clr.l	rp_AreaPtrn(a4)		normale Musterwerte
		clr.b	rp_AreaPtSz(a4)
		movea.l	a4,a1
		moveq.l	#0,d0
		fjsr	SetAPen				Löschfarbe
		lea.l	gl_SIZE+gfx_ReqXY1(gl),a0
		lea.l	gl_SIZE+gfx_ReqXY2(gl),a1
		moveq.l	#4+5,d0
		moveq.l	#3+2,d1
		add.w	gl_BarHeight(gl),d1
		subq.w	#6,d2
		subi.w	#2+14+2,d3
		move.w	d2,(a0)			Werte für inneren Border
		subq.w	#1,(a0)+		..eintragen
		move.w	d1,(a0)+
		move.w	d0,(a0)+
		move.w	d1,(a0)+
		move.w	d0,(a0)+
		move.w	d3,(a0)
		subq.w	#1,(a0)+
		move.w	d0,(a1)
		addq.w	#1,(a1)+
		move.w	d3,(a1)+
		move.w	d2,(a1)+
		move.w	d3,(a1)+
		move.w	d2,(a1)+
		move.w	d1,(a1)
		addq.w	#1,(a1)
		movea.l	a4,a1
		fjsr	RectFill		Textfeld löschen
		movea.l	a4,a1
		movem.w	wd_Width(a3),d0/d1
		lsr.w	#1,d0
		move.w	d0,d2
		move.w	d1,d3
		subi.w	#38/2,d0
		addi.w	#38/2-1,d2
		subi.w	#2+14+2,d1
		subq.w	#2+3,d3
		move.w	d0,gl_SIZE+gfx_ReqGG+gg_LeftEdge(gl)
		fjsr	RectFill				GGFeld löschen

		slib	Intui
		lea.l	gl_SIZE+gfx_ReqIText(gl),a0
		lea.l	gl_SIZE+gfx_TopazFont(gl),a1	Topaz8 für Text
		move.l	a1,it_ITextFont(a0)		..benutzen
		move.b	gl_TextPen(gl),it_FrontPen(a0)	normale Textfarbe
		move.w	gl_BarHeight(gl),it_TopEdge(a0)
.TextLoop2	move.l	a2,it_IText(a0)			aktuelle Zeile
.TextLoop	move.b	(a2),d0
		beq.b	.TextEnd		..Textende
		cmpi.b	#$0a,d0
		beq.b	.TextEnd		..Zeilenende
		addq.l	#1,a2
		bra.b	.TextLoop
.TextEnd	movea.l	a0,a1
		move.l	a0,-(sp)		IText sichern
		movea.l	a4,a0
		moveq.l	#4+6+8,d0
		moveq.l	#3+3+4,d1
		move.b	(a2),d2			altes Zeichen am Zeilenende
		clr.b	(a2)			..durch NULLByte ersetzen
		fjsr	PrintIText		Text ausgeben
		move.l	(sp)+,a0		IText wieder restoren
		addi.w	#9,it_TopEdge(a0)	Y-Position erhöhen
		move.b	d2,(a2)+		altes Zeilenende zurück
		bne.b	.TextLoop2

		lea.l	gl_SIZE(gl),a0
		move.l	a0,d0				Basis
		lea.l	gl_SIZE+gfx_ReqGG(gl),a0
		bsr.w	_Gadget				Gadget layouten,
		movea.l	a0,a1
		movea.l	a3,a0
		moveq.l	#-1,d0
		move.l	a1,d4
		fjsr	AddGadget		..ins Window hängen
		move.l	d4,a0
		movea.l	a3,a1
		suba.l	a2,a2
		fjsr	RefreshGadgets		..und refreshen
		lea.l	gl_SIZE(gl),a0
		move.l	a0,d0				Basis
		lea.l	gl_SIZE+gfx_ReqBorder(gl),a0
		bsr.w	_Border				Border layouten
		movea.l	a0,a1
		movea.l	a4,a0
		moveq.l	#0,d0
		moveq.l	#0,d1
		fjsr	DrawBorder		..und zeichnen

		move.l	6*4(sp),d0		Image angegeben?
		beq.b	.NoImage		..nein
		movea.l	d0,a1
		lea.l	ig_ImageData(a1),a0	..ja, evtl. Pointer auf
		bsr.w	_Addr			..Graphik korrigieren
		movea.l	a4,a0
		moveq.l	#0,d0
		move.w	gl_BarHeight(gl),d1
		fjsr	DrawImage		Image blitten
.NoImage
		movea.l	a3,a0
		bsr.w	_GetMsg			auf Userreaktion warten

		movea.l	a3,a0
		bsr.w	_ClearPtr		alter Pointer
		fjsr	CloseWindow		ReqWindow schließen
		moveq.l	#1,d0			cc setzen
.Exit		pull	d0-d4/a0-a4/lb
		rts

.Error		slib	Intui			Requester konnte nicht
		movea.l	gl_Window(gl),a0	..dargestellt werden,
		movea.l	wd_WScreen(a0),a0
		fjsr	DisplayBeep		..also beepen wir
		bsr.w	_ClearPtr		alter Pointer
		clr.b	d0			cc setzen
		bra.b	.Exit

.Pattern	dc.w	%1010101010101010
		dc.w	%0101010101010101

;;-- Gadgets layouten --
;	In:	a0 = *FirstGG, d0 = *Basis
;	Gadget muß haben: gg_GGRender(Border!), gg_GGText

_Gadget		push	d1/a0/a1
		movea.l	a0,a1
.Loop		lea.l	gg_GadgetRender(a1),a0
		bsr.w	_Addr			Borderadresse korrigieren
		bge.b	.Next			..GG schon gelayoutet
		bsr.b	_Border			Border layouten
		lea.l	gg_GadgetText(a1),a0
		bsr.w	_Addr			Textadresse korrigieren
		bsr.b	_IText				..und Text layouten
		btst.b	#GRELBOTTOMb,gg_Flags+1(a1)
		bne.b	.Next				..keine absolute YPos
		move.w	gl_BarHeight(gl),d1	YPos
		add.w	d1,gg_TopEdge(a1)	..korrigieren
.Next		movea.l	a1,a0
		bsr.b	_Addr			gg_NextGadget korrigieren
		movea.l	a0,a1
		move.l	a0,d1
		bne.b	.Loop			..weiteres GG
		pull	d1/a0/a1
		rts

;;-- Border layouten --
;	In:	a0 = *FirstBorder, d0 = *Basis
;	Border muß haben: bd_FrontPen = gl_xPen, bd_XY

_Border		push	d1/a0/a1
		movea.l	a0,a1
.Loop		lea.l	bd_XY(a1),a0
		bsr.b	_Addr			Adresse der Koordinaten korr.
		bge.b	.Next			..Border schon gelayoutet
		moveq.l	#0,d1
		move.b	bd_FrontPen(a1),d1
		move.b	(gl,d1.w),bd_FrontPen(a1)	Farbe korrigieren
.Next		lea.l	bd_NextBorder(a1),a0
		bsr.b	_Addr			bd_NextBorder korrigieren
		movea.l	a0,a1
		move.l	a0,d1
		bne.b	.Loop			..weiterer Border
		pull	d1/a0/a1
		rts

;;-- ITexte layouten --
;	In:	a0 = *IText, d0 = *Basis
;	IText muß haben: it_FrontPen = gl_xPen, it_IText

_IText		push	d1/a0/a1
		movea.l	a0,a1
.Loop		lea.l	it_IText(a1),a0
		bsr.b	_Addr			Textadresse korrigieren
		bge.b	.Next			..IText schon gelayoutet
		lea.l	it_ITextFont(a1),a0
		bsr.b	_Addr			TextAttr-Adresse korrigieren
		blt.b	.Cont				..Font angegeben
		move.l	gl_BarFont(gl),it_ITextFont(a1)	..kein Font->DefaultFo.
		bra.b	.Cont2
.Cont		bsr.b	_Addr			ta_Name korrigieren
.Cont2		moveq.l	#0,d1
		move.b	it_FrontPen(a1),d1
		move.b	(gl,d1.w),it_FrontPen(a1)	Farbe korrigieren
.Next		lea.l	it_NextText(a1),a0
		bsr.b	_Addr			it_NextText korrigieren
		movea.l	a0,a1
		move.l	a0,d1
		bne.b	.Loop			..weiterer IText
		pull	d1/a0/a1
		rts

;;-- Adresse korrigieren --
;	In:	a0 = *Adresse (~(RealAddr-Basis)), d0 = Basis
;	Out:	a0 = RealAddr, cc=ge, wenn Adresse schon korrigiert

_Addr		push	d0/d1
		tst.l	(a0)			Adresse schon korrigiert?
		bge.b	.Exit			..ja
		not.l	(a0)			..nein
		add.l	d0,(a0)
		moveq.l	#-1,d0			cc setzen
.Exit		movea.l	(a0),a0			neue Adresse
		pull	d0/d1
		rts

;;-- NewWindow layouten --
;	In:	a0 = *NewWindow, d0 = *Basis
;	NewWindow muß haben: nw_FirstGadget
;	Out:	cc=eq, wenn Dimensionen zu groß

_NewWindow	push	d1/a0/a1
		movea.l	a0,a1
		move.w	gl_BarHeight(gl),d1
		add.w	d1,nw_Height(a1)	Höhe korrigieren
		move.w	gl_ScrHeight(gl),d1
		sub.w	nw_Height(a1),d1
		blt.b	.Error			..Window zu hoch
		lsr.w	#2,d1
		move.w	d1,nw_TopEdge(a1)	1/4 Screenhöhe
		move.w	gl_ScrWidth(gl),d1
		sub.w	nw_Width(a1),d1
		blt.b	.Error			..Window zu breit
		lsr.w	#1,d1
		move.w	d1,nw_LeftEdge(a1)	1/2 Screenbreite
		lea.l	nw_Title(a1),a0
		bsr.b	_Addr			Titeladresse korrigieren
		lea.l	nw_FirstGadget(a1),a0
		bsr.b	_Addr			Gadgetadresse korrigieren
		bsr.w	_Gadget			..und GGs layouten
.Ok		moveq.l	#-1,d1			cc setzen
.Exit		pull	d1/a0/a1
		rts

.Error		clr.b	d0			cc setzen
		bra.b	.Exit

;;-- MenuStrip layouten --
;	In:	a0 = *MenuStrip, d0 = *Basis
;	MenuStrip muß haben: mu_FirstItem, mu_MenuName

_MenuStrip	push	d0/d1/a0-a2/lb
		movea.l	a0,a2
		move.w	gl_BarHeight(gl),mu_Height(a2)	Höhe korrigieren
		lea.l	mu_MenuName(a2),a0
		bsr.b	_Addr			Namensadresse korrigieren

		slib	Intui
		clr.l	-(sp)			it_NextText
		move.l	a0,-(sp)		it_IText (Menuname)
		move.l	gl_BarFont(gl),-(sp)	it_ITextFont (vom Screen)
		clr.l	-(sp)			unwichtig
		clr.l	-(sp)			" "
		movea.l	sp,a0
		fjsr	IntuiTextLength		Breite
		addq.w	#8,d0			..berechnen
		move.w	d0,mu_Width(a2)
		movea.l	sp,a0
		move.w	#'»'<<8!0,-(sp)
		move.l	sp,it_IText(a0)
		fjsr	IntuiTextLength		Breite des '»' Zeichens
		move.w	d0,gl_SubWidth(gl)	..sichern
		lea.l	it_SIZEOF+2(sp),sp
		move.l	(sp),d0			Basis

		lea.l	mu_FirstItem(a2),a0
		bsr.w	_Addr			MenuItem-Adresse korrigieren
		moveq.l	#0,d1			linke Ecke der Items
		bsr.b	_MenuItem		Items layouten
		pull	d0/d1/a0-a2/lb
		rts

;;-- Menu/SubItems layouten --
;	In:	a0 = *FirstItem, d0 = *Basis, d1.w = LeftEdge
;	Item muß haben: mi_ItemFill, mi_ItemFill->it_NextText ('»')
;	mi_Flags ~= ITEMTEXT, wenn Zwischenbar gewünscht

_MenuItem	push	d0-d4/a0-a2/lb
		slib	Intui
		movea.l	a0,a2
		move.w	d1,d2			linke Ecke
		moveq.l	#0,d3			Boxbreite
		moveq.l	#0,d4			aktuelle YPos
.Loop		lea.l	mi_ItemFill(a2),a0
		bsr.w	_Addr			IText/Image-Adresse korrigieren
		bge.b	.Next			..Item schon gelayoutet
		add.w	d4,mi_TopEdge(a2)		YPos eintragen
		btst.b	#ITEMTEXTb,mi_Flags+1(a2)	Zwischenbar?
		bne.b	.Text				..nein
.Image		addq.w	#5,d4			..ja, YPos erhöhen
		bra.b	.Next

.Text		bsr.w	_IText			ITextadresse korrigieren
		fjsr	IntuiTextLength
		tst.l	mi_SubItem(a2)		Subitems?
		beq.b	.NoSub			..nein
		add.w	gl_SubWidth(gl),d0	..ja, Breite für '»' addieren
		addi.w	#10+3,d0
.NoSub		btst.b	#COMMSEQb,mi_Flags+1(a2)	Shortcut?
		beq.b	.NoCommSeq			..nein
		addi.w	#36+3,d0
		move.w	d0,-(sp)			alten Wert sichern
		clr.l	-(sp)
		clr.l	-(sp)
		move.l	gl_BarFont(gl),-(sp)
		clr.l	-(sp)
		clr.l	-(sp)
		movea.l	sp,a0
		move.w	mi_Command(a2),-(sp)
		move.l	sp,it_IText(a0)
		fjsr	IntuiTextLength		zusätzliche Breite berechnen
		lea.l	it_SIZEOF+2(sp),sp
		add.w	(sp)+,d0		Gesamtbreite berechnen
.NoCommSeq	cmpi.w	d0,d3
		bgt.b	.Cont
		move.w	d0,d3			Breite als größte deklarieren
.Cont		move.w	d2,mi_LeftEdge(a2)	XPos
		move.w	gl_BarHeight(gl),d0
		add.w	d0,mi_Height(a2)	..und YPos eintragen
		add.w	d0,d4			YPos erhöhen
.Next		movea.l	a2,a0
		move.l	(sp),d0			Basis
		bsr.w	_Addr			mi_NextItem korrigieren
		movea.l	a0,a2
		move.l	a0,d1
		bne.b	.Loop			..weiteres Item

		addq.w	#2,d3			linker Rand
		movea.l	5*4(sp),a1		FirstItem
.Loop2		move.w	d3,mi_Width(a1)		Breite eintragen
		lea.l	mi_SubItem(a1),a0
		bsr.w	_Addr			evtl. Adresse für Sub korrig.
		bge.b	.CheckBar		..kein Sub
		move.w	d3,d1			..Sub, XPos in d1
		bsr.w	_MenuItem		Subs berechnen (rekursiv :-)
		movea.l	mi_ItemFill(a1),a0
		movea.l	it_NextText(a0),a0
		sub.w	gl_SubWidth(gl),d1
		subq.w	#3,d1
		move.w	d1,it_LeftEdge(a0)		XPos des '»' Zeichens
.CheckBar	btst.b	#ITEMTEXTb,mi_Flags+1(a1)	Zwischenbar?
		bne.b	.Next2				..nein
		movea.l	mi_ItemFill(a1),a0	..ja (Image)
		move.w	d3,d1
		subq.w	#4,d1
		move.w	d1,ig_Width(a0)		Breite eintragen
.Next2		movea.l	(a1),a1
		move.l	a1,d2
		bne.b	.Loop2			..weiteres Item
		pull	d0-d4/a0-a2/lb
		rts

;;-- ReqNewWindow layouten --
;	In:	a0 = *ReqWindow, d0 = *Basis, d1.w = Width, d2.w = Height
;	Out:	cc=eq, wenn Dimensionen zu groß
;	mehrmals aufrufbar mit demselben ReqWindow!

_ReqWindow	push	d1-d6/a0/a1
		movea.l	a0,a1
		add.w	gl_BarHeight(gl),d2	Höhe korrigieren
		movem.w	d1/d2,nw_Width(a1)	Breite/Höhe eintragen
		movem.w	gl_ScrWidth(gl),d3/d4
		sub.w	d1,d3
		blt.b	.Error			..Window zu breit
		sub.w	d2,d4
		blt.b	.Error			..zu hoch

.Left		movea.l	gl_Window(gl),a0
		movea.l	wd_WScreen(a0),a0
		move.l	a0,nw_Screen(a1)	Screenadresse eintragen (PubSc)
		movem.w	sc_MouseY(a0),d5/d6	d5=MouseY, d6=MouseX
		lsr.w	#1,d1
		sub.w	d1,d6
		bgt.b	.LeftCont
		moveq.l	#0,d6			XPos = 0, da MouseX zu klein
		bra.b	.Top
.LeftCont	cmp.w	d3,d6
		blt.b	.Top			XPos = MouseX
		move.w	d3,d6			XPos = rechter Rand,
					       ;..da MouseX zu groß
.Top		subi.w	#2+2+7,d2
		sub.w	d2,d5
		bgt.b	.TopCont
		moveq.l	#0,d5			YPos = 0, da MouseY zu klein
		bra.b	.Cont
.TopCont	cmp.w	d4,d5
		blt.b	.Cont			YPos = MouseY
		move.w	d4,d5			YPos = unterer Rand,
					       ;..da MouseY zu groß
.Cont		move.w	d6,nw_LeftEdge(a1)	Werte eintragen
		move.w	d5,nw_TopEdge(a1)
		lea.l	nw_Title(a1),a0
		bsr.w	_Addr			Titeladresse korrigieren
		moveq.l	#-1,d1			cc setzen
.Exit		pull	d1-d6/a0/a1
		rts

.Error		clr.b	d0			cc setzen
		bra.b	.Exit

;;-- auf IDCMP-Message warten --
;	In:	a0 = *Window
;	Out:	d0.b = Action (0-3 = dfx, 4 = Undo, 6 = Info, 8 = Quit/Exit)

_GetMsg		push	d0/d1/a0-a2/lb
		exec
		movea.l	wd_UserPort(a0),a2
.Flush		movea.l	a2,a0
		fjsr	GetMsg			vorher eingetroffene Messages
		tst.l	d0
		beq.b	.FlushEnd
		movea.l	d0,a1
		fjsr	ReplyMsg		..beantworten
		bra.b	.Flush
.FlushEnd
.Loop		movea.l	a2,a0
		fjsr	WaitPort		auf Msg warten
		movea.l	a2,a0
		fjsr	GetMsg			..und holen
		movea.l	d0,a1
		move.w	im_Class+2(a1),d1
		moveq.l	#GADGETUP,d0
		cmp.w	d0,d1
		beq.b	.Gadget			..GadgetUp
		lsl.w	#2,d0
		cmp.w	d0,d1
		beq.b	.Menu			..MenuPick
		lsl.w	#2,d0
		cmp.w	d0,d1
		beq.b	.RawKey			..RawKey
.Close		move.b	#8,3(sp)		..CloseWindow
.Exit		fjsr	ReplyMsg		Msg beantworten
		pull	d0/d1/a0-a2/lb
		rts

.Gadget		movea.l	im_IAddress(a1),a0
		move.b	gg_GadgetID+1(a0),3(sp)	Returncode = GadgetID
		bra.b	.Exit

.Menu		move.w	im_Code(a1),d1
		move.b	d1,d0
		andi.b	#%11111,d0
		bne.b	.Repeat			..illegaler Strip
		move.w	d1,d0
		lsr.w	#5,d0
		andi.b	#%111111,d0
		beq.b	.SubMenu		..SubMenu
		cmpi.b	#5,d0
		bgt.b	.Repeat			..illegales Item
		addq.b	#3,d0
		move.b	d0,3(sp)		Return = ItemNummer+3
		bra.b	.Exit
.SubMenu	lsl.l	#5,d1
		swap.w	d1
		andi.b	#%11111,d1
		cmpi.b	#3,d1
		bgt.b	.Repeat			..illegales Sub
		move.b	d1,3(sp)		Return = SubNummer
		bra.b	.Exit

.RawKey		move.b	im_Code+1(a1),d0
		cmpi.b	#$44,d0
		beq.b	.Close			..Return
		cmpi.b	#$43,d0
		beq.b	.Close			..Enter
		;||
.Repeat		fjsr	ReplyMsg		Msg beantworten
		bra.w	.Loop			..und wieder warten


;;-- WaitPointer setzen --

_WaitPtr	push	d0-d3/a0/a1/lb
		slib	Intui
		movea.l	gl_Window(gl),a0
		movea.l	gl_ChipMem(gl),a1
		lea.l	chip_Pointer(a1),a1
		moveq.l	#16,d0
		moveq.l	#16,d1
		moveq.l	#-6,d2
		moveq.l	#0,d3
		fjsr	SetPointer		WaitPointer setzen
		pull	d0-d3/a0/a1/lb
		rts

;;-- WaitPointer löschen --

_ClearPtr	push	d0/d1/a0/a1/lb
		slib	Intui
		movea.l	gl_Window(gl),a0
		fjsr	ClearPointer		normalen Pointer setzen
		pull	d0/d1/a0/a1/lb
		rts

;;-- Gadgets & Menüs --
; ACHTUNG: DFx-GGs müssen durch gg_NextGG verbunden sein (DF0<>DF1<>DF2<>DF3)!
;	   Genauso die DFx-Subs!
; DFx-GGs und -Subs müssen DISABLED sein!

_GfxStart	sbase
 soff	NewWin
		dc.w	-1,-1,232+8,32+5
		dc.b	0,1
		dc.l	CLOSEWINDOW!MENUPICK!GADGETUP
		dc.l WINDOWDRAG!WINDOWCLOSE!WINDOWDEPTH!ACTIVATE!SMART_REFRESH
		dc.l	DF0Gadget,0,Title,0,0
		dc.w	232+8-8,32+5-4,-1,-1,-1
 soff	Title
 		dc.b	'AntiRaBB V'
 		version
 		dc.b	0
 		even

 soff	DF0Gadget,gfx_FirstGG
gfx_DF0GG	=	gfx_FirstGG
 		dc.l	DF1Gadget
		dc.w	8+4,16+3,48,12
		dc.w	GADGDISABLED!GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	DFxBorder,0,DF0IText,0,0
		dc.w	0
		dc.l	0

 soff	DF0IText
		dc.b	gl_TextPen,0,RP_JAM1,0
		dc.w	8,2
		dc.l	TopazFont,DF0Text,0

 soff	DF1Gadget
		dc.l	DF2Gadget
		dc.w	64+4,16+3,48,12
		dc.w	GADGDISABLED!GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	DFxBorder,0,DF1IText,0,0
		dc.w	1
		dc.l	0

 soff	DF1IText
		dc.b	gl_TextPen,0,RP_JAM1,0
		dc.w	8,2
		dc.l	TopazFont,DF1Text,0

 soff	DF2Gadget
		dc.l	DF3Gadget
		dc.w	120+4,16+3,48,12
		dc.w	GADGDISABLED!GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	DFxBorder,0,DF2IText,0,0
		dc.w	2
		dc.l	0

 soff	DF2IText
		dc.b	gl_TextPen,0,RP_JAM1,0
		dc.w	8,2
		dc.l	TopazFont,DF2Text,0

 soff	DF3Gadget
		dc.l	0
		dc.w	176+4,16+3,48,12
		dc.w	GADGDISABLED!GADGHCOMP,RELVERIFY,BOOLGADGET
		dc.l	DFxBorder,0,DF3IText,0,0
		dc.w	3
		dc.l	0

 soff	DF3IText
		dc.b	gl_TextPen,0,RP_JAM1,0
		dc.w	8,2
		dc.l	TopazFont,DF3Text,0

 soff	DFxBorder
		dc.w	0,0
		dc.b	gl_ShinePen,0,RP_JAM1,5
		dc.l	ShineXY,ShadowBorder
 soff	ShineXY
		dc.w	47,0, 0,0, 0,11, 1,10, 1,1

 soff	ShadowBorder
		dc.w	0,0
		dc.b	gl_ShadowPen,0,RP_JAM1,5
		dc.l	ShadowXY,0
 soff	ShadowXY
		dc.w	1,11, 47,11, 47,0, 46,1, 46,10

 soff	DF0Text
 		dc.b	'df0:',0
 soff	DF1Text
 		dc.b	'df1:',0
 soff	DF2Text
 		dc.b	'df2:',0
 soff	DF3Text
 		dc.b	'df3:',0
		even

 soff	TopazFont,gfx_TopazFont
		dc.l	TopazName
		dc.w	8
		dc.b	FS_NORMAL,FPF_ROMFONT
 soff	TopazName
 		dc.b	'topaz.font',0
		even

 soff	InstallIText,gfx_FirstIText
		dc.b	gl_HiTextPen,0,RP_JAM1,0
		dc.w	8+4,4+3
		dc.l	TopazFont,InstallText,0
 soff	InstallText
		dc.b	'Installieren auf:',0
		even

 soff	ProjectMenu,gfx_FirstStrip
		dc.l	0
		dc.w	2,0,-1,-1,MENUENABLED
		dc.l	ProjectText,InstallItem
		dc.w	0,0,0,0
 soff	ProjectText
		dc.b	'Projekt',0
		even

 soff	InstallItem
		dc.l	UndoItem
		dc.w	0,0,-1,1,ITEMTEXT!ITEMENABLED!HIGHCOMP
		dc.l	0,InstallIText2,0
		dc.b	0,0
		dc.l	DF0Sub
		dc.w	0

 soff	InstallIText2
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	2,1
		dc.l	0,InstallText2,SubIText
 soff	InstallText2
		dc.b	'Installieren auf',0
		even

 soff	SubIText				'»'-IText
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	-3,1
		dc.l	0,SubText,0
 soff	SubText
		dc.b	'»',0
		even

 soff	UndoItem,gfx_UndoItem
		dc.l	DummyItem1
		dc.w	0,1,-1,1,ITEMTEXT!COMMSEQ!HIGHCOMP
		dc.l	0,UndoIText,0
		dc.b	'U',0
		dc.l	0
		dc.w	0

 soff	UndoIText
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	2,1
		dc.l	0,UndoText,0
 soff	UndoText
		dc.b	'Rückgängig machen',0
		even

 soff	DummyItem1			Zwischenbar-Item
		dc.l	InfoItem
		dc.w	0,2,-1,6,HIGHNONE
		dc.l	0,DummyImage,0
		dc.b	0,0
		dc.l	0
		dc.w	0

 soff	DummyImage
		dc.w	2,2,-1,2,0
		dc.l	0
		dc.b	0,0
		dc.l	0

 soff	InfoItem
		dc.l	DummyItem2
		dc.w	0,3,-1,1,ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP
		dc.l	0,InfoIText,0
		dc.b	'I',0
		dc.l	0
		dc.w	0

 soff	InfoIText
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	2,1
		dc.l	0,InfoText,0
 soff	InfoText
		dc.b	'Information...',0
		even

 soff	DummyItem2			Zwischenbar-Item
		dc.l	QuitItem
		dc.w	0,4,-1,6,HIGHNONE
		dc.l	0,DummyImage,0
		dc.b	0,0
		dc.l	0
		dc.w	0

 soff	QuitItem
		dc.l	0
		dc.w	0,5,-1,1,ITEMTEXT!COMMSEQ!ITEMENABLED!HIGHCOMP
		dc.l	0,QuitIText,0
		dc.b	'Q',0
		dc.l	0
		dc.w	0

 soff	QuitIText
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	2,1
		dc.l	0,QuitText,0
 soff	QuitText
		dc.b	'Ende',0
		even

 soff	DF0Sub,gfx_DF0Sub
		dc.l	DF1Sub
		dc.w	0,0,-1,1,ITEMTEXT!COMMSEQ!HIGHCOMP
		dc.l	0,DF0IText2,0
		dc.b	'0',0
		dc.l	0
		dc.w	0

 soff	DF0IText2
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	2,1
		dc.l	0,DF0Text,0

 soff	DF1Sub
		dc.l	DF2Sub
		dc.w	0,1,-1,1,ITEMTEXT!COMMSEQ!HIGHCOMP
		dc.l	0,DF1IText2,0
		dc.b	'1',0
		dc.l	0
		dc.w	0

 soff	DF1IText2
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	2,1
		dc.l	0,DF1Text,0

 soff	DF2Sub
		dc.l	DF3Sub
		dc.w	0,2,-1,1,ITEMTEXT!COMMSEQ!HIGHCOMP
		dc.l	0,DF2IText2,0
		dc.b	'2',0
		dc.l	0
		dc.w	0

 soff	DF2IText2
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	2,1
		dc.l	0,DF2Text,0

 soff	DF3Sub
		dc.l	0
		dc.w	0,3,-1,1,ITEMTEXT!COMMSEQ!HIGHCOMP
		dc.l	0,DF3IText2,0
		dc.b	'3',0
		dc.l	0
		dc.w	0

 soff	DF3IText2
		dc.b	gl_BackPen,0,RP_JAM1,0
		dc.w	2,1
		dc.l	0,DF3Text,0

 soff	ReqNewWin,gfx_ReqNewWin
		dc.w	-1,-1,-1,-1
		dc.b	0,1
		dc.l	CLOSEWINDOW!GADGETUP!RAWKEY
	dc.l WINDOWDRAG!WINDOWCLOSE!WINDOWDEPTH!ACTIVATE!SMART_REFRESH!RMBTRAP
		dc.l	0,0,ReqTitle,0,0
		dc.w	56,43,$7fff,$7fff,CUSTOMSCREEN
 soff	ReqTitle
 		dc.b	'Nachricht:',0
 		even

 soff	ReqGadget,gfx_ReqGG
		dc.l	0
		dc.w	-1,-1-2-14,38,14,GADGHCOMP!GRELBOTTOM,RELVERIFY
		dc.w	BOOLGADGET
		dc.l	ReqGGBorder1,0,ReqGGIText,0,0
		dc.w	6
		dc.l	0

 soff	ReqGGBorder1
		dc.w	0,0
		dc.b	gl_ShinePen,0,RP_JAM1,3
		dc.l	ReqGGXY1,ReqGGBorder2
 soff	ReqGGXY1
		dc.w	36,0, 0,0, 0,12

 soff	ReqGGBorder2
		dc.w	0,0
		dc.b	gl_ShadowPen,0,RP_JAM1,3
		dc.l	ReqGGXY2,0
 soff	ReqGGXY2
		dc.w	1,13, 37,13, 37,1

 soff	ReqBorder1,gfx_ReqBorder
		dc.w	0,0
		dc.b	gl_ShadowPen,0,RP_JAM1,3
		dc.l	ReqXY1,ReqBorder2
 soff	ReqXY1,gfx_ReqXY1
		dc.w	-1,-1, -1,-1, -1,-1

 soff	ReqBorder2
		dc.w	0,0
		dc.b	gl_ShinePen,0,RP_JAM1,3
		dc.l	ReqXY2,0
 soff	ReqXY2,gfx_ReqXY2
		dc.w	-1,-1, -1,-1, -1,-1

 soff	ReqGGIText
		dc.b	gl_TextPen,0,RP_JAM1,0
		dc.w	3+4,3
		dc.l	TopazFont2,ReqGGText,0
 soff	ReqGGText
		dc.b	'Jöp',0

 soff	TopazFont2			wie TopazFont, allerdings Fettdruck
		dc.l	TopazName
		dc.w	8
		dc.b	FSF_BOLD,FPF_ROMFONT

 soff	ReqIText,gfx_ReqIText		für Requester, nicht mit _IText berech.
		dc.b	-1,0,RP_JAM1,0
		dc.w	0,-1
		dc.l	-1,0,0

 soff	TDERR20,gfx_TDERR20		Zeiger auf die TDERR-Texte
		dc.l	TDERR20Txt
 soff	TDERR21,gfx_TDERR21
		dc.l	TDERR21Txt
 soff	TDERR22,gfx_TDERR22
		dc.l	TDERR22Txt
 soff	TDERR23,gfx_TDERR23
		dc.l	TDERR23Txt
 soff	TDERR24,gfx_TDERR24
		dc.l	TDERR24Txt
 soff	TDERR25,gfx_TDERR25
		dc.l	TDERR25Txt
 soff	TDERR26,gfx_TDERR26
		dc.l	TDERR26Txt
 soff	TDERR27,gfx_TDERR27
		dc.l	TDERR27Txt
 soff	TDERR28,gfx_TDERR28
		dc.l	TDERR28Txt
 soff	TDERR29,gfx_TDERR29
		dc.l	TDERR29Txt
 soff	TDERR30,gfx_TDERR30
		dc.l	TDERR30Txt
 soff	TDERR31,gfx_TDERR31
		dc.l	TDERR31Txt
 soff	TDERR32,gfx_TDERR32
		dc.l	TDERR32Txt
 soff	TDERR33,gfx_TDERR33
		dc.l	TDERR33Txt
 soff	TDERR34,gfx_TDERR34
		dc.l	TDERR34Txt
 soff	TDERR35,gfx_TDERR35
		dc.l	TDERR35Txt

 soff	TDERR20Txt
		dc.b	'Ursache unbekannt',0
 soff	TDERR21Txt
		dc.b	'kein Sectorheader gefunden',0
 soff	TDERR22Txt
		dc.b	'fehlerhafte SectorPreamble',0
 soff	TDERR23Txt
		dc.b	'fehlerhafte SectorID',0
 soff	TDERR24Txt
		dc.b	'falsche Header Checksumme',0
 soff	TDERR25Txt
		dc.b	'falsche Sector Checksumme',0
 soff	TDERR26Txt
		dc.b	'zuwenig Sectoren auf Track',0
 soff	TDERR27Txt
		dc.b	'SectorHeader unlesbar',0
 soff	TDERR28Txt
		dc.b	'Disk ist schreibgeschützt',0
 soff	TDERR29Txt
		dc.b	'keine Disk im Laufwerk',0
 soff	TDERR30Txt
		dc.b	'Lesekopfpositionierung falsch',0
 soff	TDERR31Txt
		dc.b	'kein freier Speicher',0
 soff	TDERR32Txt
		dc.b	'Laufwerk nicht angeschlossen',0
 soff	TDERR33Txt
		dc.b	'unbekannter Laufwerkstyp',0
 soff	TDERR34Txt
		dc.b	'Laufwerk wird gerade benutzt',0
 soff	TDERR35Txt
		dc.b	'illegaler Zugriff nach Reset',0

_GfxEnd

;;-- ChipRam-Daten --

_ChipStart	sbase		\
 soff	ChipImage,chip_Tropic	/
		dc.w	4+5+9,3+2+5,145,38,2
		dc.l	ChipImageData
		dc.b	%11,0
		dc.l	0
 soff	ChipImageData
		incdir	'sys:asm/src/'
		incbin	'TropicDesign.raw'	(145x38x2)

 soff	ChipPtr,chip_Pointer
		dc.w	0,0
		dc.w	%0000010000000000,%0000011111000000
		dc.w	%0000000000000000,%0000011111000000
		dc.w	%0000000100000000,%0000001110000000
		dc.w	%0000000000000000,%0000011111100000
		dc.w	%0000011111000000,%0001111111111000
		dc.w	%0001111111110000,%0011111111101100
		dc.w	%0011111111111000,%0111111111011110
		dc.w	%0011111111111000,%0111111110111110
		dc.w	%0111111111111100,%1111111101111111
		dc.w	%0111111011111100,%1111111111111111
		dc.w	%0111111111111100,%1111111111111111
		dc.w	%0011111111111000,%0111111111111110
		dc.w	%0011111111111000,%0111111111111110
		dc.w	%0001111111110000,%0011111111111100
		dc.w	%0000011111000000,%0001111111111000
		dc.w	%0000000000000000,%0000011111100000
		dc.w	0,0
_ChipEnd

;;-- Weitere Konstanten (Fucking ASM-One will sie hier unten haben) --

		rsreset		;\
gl_Pens		rs.b	0	  \
gl_TextPen	rs.b	1	   \	Farbverteilungen
gl_ShinePen	rs.b	1	    >
gl_ShadowPen	rs.b	1	   /
gl_HiTextPen	rs.b	1	  /
gl_BackPen	rs.b	1	 /
gl_Return	rs.b	1		CLI-Returncode
		rsword
gl_Result2	rs.l	1		2. Returncode
gl_Process	rs.l	1		eigener Process
gl_WBMsg	rs.l	1		Workbench-StartupMsg
gl_IntuiBase	rs.l	1
gl_GfxBase	rs.l	1
gl_Floppy0	rs.b	flo_SIZEOF	\	darf nicht größer als 127 sein!
gl_Floppy1	rs.b	flo_SIZEOF	 \
gl_Floppy2	rs.b	flo_SIZEOF	 /
gl_Floppy3	rs.b	flo_SIZEOF	/
gl_Floppies	rs.b	1		Bit gesetzt=IOReq. exist.,Bit0=df0 etc.
gl_UndoFloppy	rs.b	1		Unitnummer des Undobufferce
		rsword
gl_UndoChange	rs.l	1		DiskChangeCount zur Lese-Zeit
gl_Window	rs.l	1		eigenes Window
gl_BarFont	rs.l	1		TextAttr für Menüs/WindowTitle
gl_BarHeight	rs.w	1		ta_YSize "   "     "
gl_SubWidth	rs.w	1		Breite des '»' Zeichens
gl_ScrWidth	rs.w	1	\	Screen-Dimensionen
gl_ScrHeight	rs.w	1	/
gl_ChipMem	rs.l	1		Zeiger auf chip-Struktur (s. u.)
gl_SIZE		rs.b	0			\
						;\
		rs.b	_GfxEnd-_GfxStart	 /	Gadgets, Menüs etc.
gl_SIZEOF	rs.b	0			/

		rsreset				;\
		rs.b	_ChipEnd-_ChipStart	  >
chip_SIZE	rs.b	0			 /
chip_UndoBuf	rs.b	BB_SIZEOF		Undo-Puffer      <-----\
chip_ReadBuf	rs.b	BB_SIZEOF		gelesener Puffer       |
chip_SIZEOF	rs.b	0
