***************************************************************************
;
; SetMClock v1.23  02-Feb-98  by Adriano De Minicis 
;
;--------------------------------------------------------------------------
; Assembler used: Devpac3
; Link: Blink SetMClock.o lib amiga.lib sc sd nd
;--------------------------------------------------------------------------
; HISTORY:
;
; V1.0  22-Jul-93  First release: ok, but OS1.2 can't see bool tooltypes
; V1.1  29-Jul-93  Changed configuration file name from "clock.config" to
;                  "MClock.upd", changed tooltypes (MODE=load|save|zero)
;                  to maintain compatibility with OS1.2
; V1.2  07-Aug-93  Fixed bug in WBParse with OS1.2
; V1.21 14-Sep-93  Fixed bug in updating "MClock.upd".
;                  Now performs a complete check to the configuration file.
; V1.22 04-May-97  Timeout problems on fast Amigas. Changed timeout from
;                  10000 to 65500
; V1.23 02-Feb-98  Inseriti ulteriori ritardi per aumentare timeout
;--------------------------------------------------------------------------
;
; NOTE: I've used a compact notation to show the content of a register
;       when it contains more than one variable:
;       
;       (x) means x is a byte,   [y] means y is a word
;       
;       Example: d0 = (day)(month)[year] means:
;                     byte #3 (upper) is day, byte #2 is month,
;                     lower word is year
;
***************************************************************************

		opt	l+		; linkable

		include	exec/exec_lib.i
;		include dos/dos_lib.i
;		include	dos/dos.i
		include devices/timer.i
		include	graphics/text.i
		include graphics/rastport.i
		include	intuition/intuition.i
		include	intuition/intuition_lib.i
		include	workbench/workbench.i
		include	workbench/icon_lib.i
		include workbench/startup.i

******  Startup code  *****************************************************
			
		include smallstartup.i

******  Macro definitions  ************************************************

CALL		MACRO
		jsr	_LVO\1(a6)
		ENDM

******  Constants and variables  ******************************************
		
		even

LIBVERS		equ	33		; library version required (v1.2)
ABSEXECBASE	equ	4

ARWIDTH		equ	450		; requester width
ARHEIGHT	equ	37		; requester height

LOAD		equ	'LOAD'		; used as a long value (4 chars)
SAVE		equ	'SAVE'		;             "
ZERO		equ	'ZERO'		;             "

SHORTTIME	equ	100		; delay in microseconds
LONGTIME	equ	1000		; delay in microseconds
STOPTIME	equ	5000		; delay (µs) after bus stop                                      ; and 'load'

CLK_ADDR_RD	equ	%11010011	; I2C address of clock (read)
CLK_ADDR_WR	equ	%11010010	; I2C address of clock (write)

MONTH_MASK	equ	%00011111	; mask for month data (BCD)
DAYHR_MASK	equ	%00111111	; mask for day and hour
MINSEC_MASK	equ	%01111111	; mask for minutes and seconds

TimerPort	dc.l	0		; TimerPort pointer
TimeReq		dc.l	0		; TimeRequest pointer
TimerDevOpen	dc.w	0		; true if timer device opened

_IntuitionBase	dc.l	0
_IconBase	dc.l	0

*---- Days from the beginning of the year ----*

DayMonth	dc.w	0,31,59,90,120,151,181,212,243,273,304,334,365
DayMonthLeap	dc.w	0,31,60,91,121,152,182,213,244,274,305,335,366

*---- Version string ----*

VersionString	dc.b	'$VER: SetMClock 1.23 (2.2.98)',0

*---- String definitions ----*

intui_name	INTNAME
timer_name	TIMERNAME
icon_name	ICONNAME

AROkTxt		dc.b	'OK',0			; Negative text for req.
ToolStr		dc.b	'MODE',0
LoadStr		dc.b	'load',0
SaveStr		dc.b	'save',0
ZeroStr		dc.b	'zero',0
HelpTxt		dc.b	'CLI Usage: SetMClock load|save|zero',$0a
		dc.b	'WB Tooltypes:   MODE=load|save|zero',0
ErrNoTimer	dc.b    'Can''t open timer.device',0
ErrNoClock	dc.b	'Can''t find battery backed up clock',0
ErrBadData	dc.b	'Bad data in S:MClock.upd',0
ErrClkNotSet	dc.b	'Battery backed up clock not set',0
ErrNoConfig	dc.b	'Can''t open S:MClock.upd',0
ErrNoSave	dc.b	'Can''t save '
ConfigFile	dc.b	'S:MClock.upd',0

ConfigModified	dc.b	0	; true if config.file modified

		even
		
*---- Configuration file buffer ----*

ConfigBuffer	dc.b	0	; day (1..31)
		dc.b	0	; month (1..12)
		dc.w	0	; year (1978..2066) (from Amiga0 to Amiga1E6)

		even
		
*---- Intuitexts for AutoRequest ----*

ARBodyIT	dc.b	0,1,RP_JAM2,0
		dc.w	10,8
		dc.l	0		;default font
ARBTxt		dc.l	0,0

ARNegIT		dc.b	0,1,RP_JAM2,0
		dc.w	6,3
		dc.l	0		;default font
		dc.l	AROkTxt, 0	

******  External references for linker  ***********************************

		XREF	_CreatePort		; amiga.lib
		XREF	_DeletePort		; amiga.lib
		XREF	_CreateExtIO		; amiga.lib
		XREF	_DeleteExtIO		; amiga.lib

		XDEF	_SysBase
		XDEF	_DOSBase

******  Main  *************************************************************

		even
		
main		lea	intui_name(pc),a1
		moveq	#LIBVERS,d0
		CALLEXEC OpenLibrary		; open intuition.library
		move.l	d0,_IntuitionBase
		beq	Exit			; exit immediately

GetTimer	moveq	#0,d0
		move.l	d0,-(sp)
		move.l	d0,-(sp)
		jsr	_CreatePort		; create Port for timer
		addq	#8,sp
		move.l	d0,TimerPort
		beq.s	NoTimer
		
		moveq	#IOTV_SIZE,d1
		move.l	d1,-(sp)
		move.l	d0,-(sp)
		jsr	_CreateExtIO		; create ExtIO for timer
		addq	#8,sp
		move.l	d0,TimeReq
		beq.s	NoTimer
		
		lea	timer_name(pc),a0
		move.l	d0,a1
		moveq	#UNIT_MICROHZ,d0
		moveq	#0,d1
		CALLEXEC OpenDevice		; open timer.device (microHz)
		tst.l	d0
		beq.s	TimerOk

NoTimer		lea	ErrNoTimer(pc),a0
		moveq	#RETURN_ERROR,d7
		bra	ErrorExit

TimerOk		move	#-1,TimerDevOpen

******  Parse arguments passed from CLI or WB  ****************************

		move.l	WBenchMsg(pc),d0
		bne	WBParse

*---- Called from CLI ----*

CLIParse	move.l	CmdLinePtr(pc),a0	; pointer to command line
		move.b	(a0)+,d0		; get first char
		asl.w	#8,d0			
		move.b	(a0)+,d0		; get second char
		swap	d0
		move.b	(a0)+,d0		; get third char
		asl.w	#8,d0
		move.b	(a0)+,d0		; get fourth char
		and.l	#$DFDFDFDF,d0		; uppercase the four chars
		
select_choice	cmp.l	#LOAD,d0
		beq	LoadClock
		cmp.l	#SAVE,d0
		beq	SaveClock
		cmp.l	#ZERO,d0
		beq	ZeroClock
		
		lea	HelpTxt(pc),a0		; no match, show help
		moveq	#0,d7			; no error code
		bra	ErrorExit

*---- Called from WB ----*

WBParse		move.l	#LOAD,d5		; d5 = choice (default)

		move.l	d0,a0
		move.l	sm_NumArgs(a0),d1	; d1 = NumArgs
		move.l	sm_ArgList(a0),a1	; a1 = pointer to first WBArg

		cmp	#1,d1			; only one arg?
		bls.s	1$			; yes, skip
		addq	#wa_SIZEOF,a1		; no, get the second
		
1$		move.l	wa_Name(a1),d7		; d7 = icon who called us
		beq	11$
		move.l	wa_Lock(a1),d1		; file lock
		beq	11$
		CALLDOS	CurrentDir		; change to the proper dir.
		move.l	d0,d6			; d6 = old lock
		
		lea	icon_name(pc),a1
		moveq	#LIBVERS,d0
		CALLEXEC OpenLibrary		; open icon.library
		move.l	d0,a6			; save icon.lib pointer
		tst.l	d0			; check if open error
		beq.s	10$

		move.l	d7,a0
		CALL	GetDiskObject		; open icon who called us
		tst.l	d0
		beq.s	9$
		
		move.l	d0,a5			; save pointer to diskobj
		move.l	do_ToolTypes(a5),a0	; a0 = tooltype pointer

		lea	ToolStr(pc),a1
		CALL	FindToolType		; search 'MODE' tooltype
		tst.l	d0
		beq.s	5$			; not found, use default

		move.l	d0,a4			; save toolstring pointer
		move.l	a4,a0
		lea	ZeroStr(pc),a1
		CALL	MatchToolValue		; search 'zero' string
		tst.l	d0
		beq.s	4$			; not found
		move.l	#ZERO,d5		; found: choice = ZERO

4$		move.l	a4,a0
		lea	SaveStr(pc),a1
		CALL	MatchToolValue		; search 'save' string
		tst.l	d0
		beq.s	5$			; not found
		move.l	#SAVE,d5		; found: choice = SAVE

5$		move.l	a5,a0
		CALL	FreeDiskObject		; free icon

9$		move.l	a6,a1
		CALLEXEC CloseLibrary		; close icon.library
10$		move.l	d6,d0
		beq.s	11$
		CALLDOS	CurrentDir		; restore old directory
11$		move.l	d5,d0
		bra	select_choice
		

******  Close and exit  ***************************************************		

*---- Exits with error code in D7 and error string in A0 ----*

ErrorExit	bsr	puts
		bra.s	close

*---- Normal exit code ----*

CloseExit	moveq	#0,d7			; no error code

close		move	TimerDevOpen(pc),d0
		beq.s	1$
		move.l	TimeReq(pc),a1
		CALLEXEC CloseDevice		; close timer device

1$		move.l	TimeReq(pc),d0
		beq.s	2$
		moveq	#IOTV_SIZE,d1
		move.l	d1,-(sp)
		move.l	d0,-(sp)
		jsr	_DeleteExtIO		; delete TimeReq
		addq	#8,sp

2$		move.l	TimerPort(pc),d0
		beq.s	3$
		move.l	d0,-(sp)
		jsr	_DeletePort		; delete TimerPort
		addq	#4,sp
		
3$		move.l	_IntuitionBase(pc),d0
		beq.s	4$
		move.l	d0,a1
		CALLEXEC CloseLibrary		; close intuition library

4$		bra	Exit


******  Print string  *****************************************************   
;
; Prints null terminated string to standard output adding a line feed,
; if called from CLI, or shows a requester if started from WB.
;
; Input: A0 pointer to null terminated string
; Registers used: A0..A3, D0..D3

puts		tst.l	WBenchMsg		; from CLI?
		bne.s	autoreq			; no

		move.l	OutputFH(pc),d1		; d1 = output filehandle
		beq.s	3$			; handle=0 ?, skip

		moveq	#1,d3			; d3 = text lenght
		move.l	a0,d2			; d2 = text pointer
1$		move.b	(a0)+,d0		; current char = 0 ?
		beq.s	2$			; yes, end of text
		addq	#1,d3			; no, inc lenght
		bra.s	1$			;
2$		move.b	#$0a,-(a0)		; add a line feed
		move.l	a0,a3			; save pointer to null char
		CALLDOS	Write			; print text
		move.b	#0,(a3)			; restore null terminator

3$		rts

autoreq		move.l	a0,ARBTxt		; set pointer to my text
		moveq	#0,d0			; no positive IDCMP flags
		moveq	#0,d1			; no negative IDCMP flags
		move.l	#ARWIDTH,d2		; width of autorequester
		moveq	#ARHEIGHT,d3		; heght of autorequester
		move.l	d0,a0			; no window
		move.l	d0,a2			; no positive text
		lea	ARBodyIT(pc),a1		; positive text
		lea	ARNegIT(pc),a3		; negative text
		CALLINT AutoRequest
		rts


******  Read/Write configuration file  ************************************
;
; Input: D4 = Mode: (0=Read, 1=Write)
;        D5 = ErrorCode
;        A5 = ErrorString

OpenConfig	lea	ConfigFile(pc),a0
		move.l	a0,d1
		move.l	#MODE_OLDFILE,d2	; read mode (file must exist)
		tst.l	d4			; read or write ?
		beq.s	1$			; read, ok
		move.l	#MODE_NEWFILE,d2	; save mode (create new file)
1$		CALLDOS	Open			; open config file
		move.l	d0,d7			; d7 = file handle
		bne.s	OpenOk
		
RWError		move.l	a5,a0			; error string
		move.l	d5,d7
		bra	ErrorExit

OpenOk		move.l	d0,d1
		lea	ConfigBuffer(pc),a0
		move.l	a0,d2
		moveq	#4,d3
		tst.b	d4			; read or write ?
		bne.s	1$
		CALL	Read
		bra.s	2$
1$		CALL	Write
2$		move.l	d0,d6
		move.l	d7,d1
		CALL	Close
		cmp	#4,d6
		bne.s	RWError
		rts

******  I2C ROUTINES  *****************************************************

*---- Hardware register for mouse port #2 ----*

CiaA_PortA	equ	$bfe001		; bit 7 = fire, used for
					; SCL line (I2C serial clock)
CiaA_DDRA	equ	$bfe201		; data direction (0=in, 1=out)
					; for CiaA_PortA
PotGo		equ	$dff034		; bit 14 = PotY, bit 15 = OE
					; used for data output (SDA)
Joy1Dat		equ	$dff00c		; bit 1 = /Right (SDA input)
					; bit 9 = /Left (SCL input)

*---- Definitions ----*

I2CStatus	dc.b	0		; Status of I2C: 0=ok
					; bit 0=timeout, bit 1=no ack
		even

POT0		equ	$8000		; value of POTGO for SDA=0
POT1		equ	$C000		; value of POTGO for SDA=1

TIMEOUT		equ	65500		; max timeout loops
MULTIPLY	equ	$AAAA		; per ritardo di moltiplicazione

FIRE		equr	a3
POT		equr	a4
JOY		equr	a5

;-----  Start I2C communications  -----------------------------------------
;
; Call this routine to initialize registers and the I2C bus 
;
; IMPORTANT: registers A3,A4,A5 are used by I2C routines. Do NOT modify
;            them until StopI2C
;
; Register modified: D0..D1, A0..A1, A3..A6 

StartI2C	move.b	#0,I2CStatus	; status ok
		lea	CiaA_PortA,FIRE
		lea	PotGo,POT
		lea	Joy1Dat,JOY
		bset.b	#7,(FIRE)	; set SCL=1
		bset.b	#7,CiaA_DDRA	; set SCL as output
		bsr	sda1
		bsr	sda0
		bsr	scl0
		bra	shortdelay

;-----  Stop I2C communication  -------------------------------------------

StopI2C		bsr	sda0
		bsr	scl1
		bsr	sda1
		bclr.b	#7,CiaA_DDRA	; set SCL as input
		move	#0,(POT)	; set SDA as input (superfluous ?)
		move.l	#STOPTIME,d0	; delay from stop condition
		bra	delay

;-----  Transmit byte in d2 converting to BCD  ----------------------------
; 
; Input: D2 byte to transmit (binary)
; Register modified: D0..D3, A0..A1, A6

TXByteToBCD	moveq	#0,d0		; clear result
		move.b	d2,d0		; d0 = b (byte binary)
		moveq	#10,d1
		divu	d1,d0		; d0 = [b MOD 10][b DIV 10]
		move	d0,d2		; d2 = b DIV 10
		lsl	#4,d2		; d2 = (b DIV 10)*16
		swap	d0
		add	d0,d2		; d2 = (b DIV 10)*16 + (b MOD 10)
		bra.s	TXByte		; transmit


;-----  Receive byte in d4, mask it, and convert from BCD -----------------
;
; Input:  D5 byte mask
; Output: D4 byte received (long)
; Register modified: D0..D4, A0..A1, A6

RXByteFromBCD	bsr.s	RXByte		; d2 = B, byte received (BCD)
		and.b	d5,d4		; mask byte
		move	d4,d0
		and.b	#$0F,d0		; d0 = LSD 
		lsr	#4,d4		; d4 = MSD
		moveq	#10,d1
		mulu	d1,d4		; d4 = MSD*10
		add	d0,d4		; d4 = MSD*10+LSD
		rts

;-----  Transmit byte in d2 -----------------------------------------------
;
; Input: D2 byte to transmit
; Register modified: D0..D3, A0..A1, A6

TXByte		moveq	#7,d3		; bit counter
1$		bsr.s	txbit		
		lsl.b	#1,d2
		dbra	d3,1$
		bsr.s	rxbit		; read ack bit
		btst	#0,d2		; test ack bit
		beq.s	2$		; ack=0, ok
		bset.b	#1,I2CStatus	; ack error
2$		rts

;-----  Receive byte in d4  -----------------------------------------------
;
; Output: D4 byte received (long)
; Register modified: D0..D4, A0..A1, A6

RXByte		moveq	#7,d3		; bit counter
		moveq	#0,d4		; byte to be read
1$		bsr.s	rxbit
		lsl	#1,d4
		or.b	d2,d4
		dbra	d3,1$
		moveq	#0,d2		; transmit ack=0
		bra.s	txbit

******  I2C subroutines  **************************************************

; Transmit bit 7 of register D2

txbit		btst	#7,d2		; Transmit bit 7 of d2
		bne.s	1$
		bsr.s	sda0
		bra.s	2$
1$		bsr.s	sda1
2$		bsr.s	scl1
		bsr	shortdelay
		bra.s	scl0

; Returns bit received in bit 0 of D2

rxbit		move	#POT1,(POT)	; set SDA=1 without feedback
		bsr	longdelay	; wait until SDA=1 (can't check)
		bsr.s	scl1
		bsr	shortdelay
		move	(JOY),d2	; read SDA (bit 1 negated)
		lsr	#1,d2
		not	d2
		and	#1,d2
		bra.s	scl0

sda0		move	#POT0,(POT)	; set SDA=0
		move	#TIMEOUT,d0
1$		jsr	aspetta		; #V1.23# inserire qui il ritardo
		move	(JOY),d1
		btst	#1,d1
		dbne	d0,1$
		bra.s	TimeTest

sda1		move	#POT1,(POT)	; set SDA=1
		move	#TIMEOUT,d0
1$		jsr	aspetta		; #V1.23# inserire qui il ritardo
		move	(JOY),d1
		btst	#1,d1
		dbeq	d0,1$
TimeTest	cmp	#-1,d0		; if d0=-1 there is a timeout
		bne.s	TimeOk
		bset.b	#0,I2CStatus	; timeout error
TimeOk		rts

scl0		bclr.b	#7,(FIRE)	; set SCL=0
		move	#TIMEOUT,d0
1$		jsr	aspetta		; #V1.23# inserire qui il ritardo
		move	(JOY),d1
		btst	#9,d1
		dbne	d0,1$
		bra.s	TimeTest

scl1		bset.b	#7,(FIRE)	; set SCL=0
		move	#TIMEOUT,d0
1$		jsr	aspetta		; #V1.23# inserire qui il ritardo
		move	(JOY),d1
		btst	#9,d1
		dbeq	d0,1$
		bra.s	TimeTest

******  Ritardo per Amiga Veloci (V1.23) **********************************
;
; NB: inserire qui una subroutine di ritardo che alteri SOLO il registro d1
;
; Per aumentare il ritardo, aggiungere altre linee uguali all'interno

aspetta		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		mulu	#MULTIPLY,d1	; #V1.23# inserire qui il ritardo
		rts
		
******  Timer delays  *****************************************************
;
; Register modified: d0,d1,a0,a1

shortdelay	move.l	#SHORTTIME,d0		; short delay entry point
		bra.s	delay
longdelay	move.l	#LONGTIME,d0		; long delay entry point
delay		move.l	TimeReq(pc),a1		; delay in d0 (microsec)
		moveq	#TR_ADDREQUEST,d1
		move.w  d1,IO_COMMAND(a1)
		moveq	#0,d1
		move.l	d1,(IOTV_TIME+TV_SECS)(a1)
		move.l	d0,(IOTV_TIME+TV_MICRO)(a1)
		CALLEXEC DoIO
		rts

******  Save Clock  *******************************************************
;

;-----  Get system time in d0  --------------------------------------------

SaveClock	move.l	TimeReq(pc),a1
		moveq	#TR_GETSYSTIME,d1
		move.w	d1,IO_COMMAND(a1)
		CALLEXEC DoIO
		move.l	TimeReq(pc),a1
		move.l	(IOTV_TIME+TV_SECS)(a1),d0

;-----  Convert system time to date  --------------------------------------
;
; Input:  d0 = system_time.seconds
; Output: d5 = [year][month]
;         d6 = [ hr ][ day ]
;         d7 = [ sec][ min ]

ConvFromSysTime	move.b	d0,d7		; d0 = seconds from Jan,1 78
		and	#3,d7		; d7 = secs mod 4
		lsr.l	#2,d0		; d0 = secs/4
		move	#21600,d1
		divu	d1,d0		; d0 = [secs/4][days]
		
		move.l	d0,d2
		clr	d2
		swap	d2		; d2 = secs/4
		moveq	#15,d1
		divu	d1,d2
		swap	d2		; d2 = [mins][sec/4]
		lsl	#2,d2		; d2 = [mins][sec]
		or	d2,d7		; d7 = sec
		swap	d7		; d7 = [sec][0]
		clr	d2
		swap	d2		; d2 = [0][mins]
		moveq	#60,d1
		divu	d1,d2		; d2 = [min][hr]
		move	d2,d6		; d6 = hr
		swap	d6		; d6 = [hr][0]
		swap	d2		; d2 = [hr][min]
		move	d2,d7		; d7 = [sec][min] - OK
		
		move	#1978,d1	; d0 = days, d1=year
yloop		bsr	LeapCheck	; d2 = # of days of d1
		cmp	d2,d0		; days < days year ?
		bmi.s	yearfound
		sub	d2,d0		; no, subtract days of this year
		addq	#1,d1		; next year
		bra.s	yloop
yearfound	move	d1,d5
		swap	d5		; d5 = [year][?]
		lea	(DayMonth+2)(pc),a0
		cmp	#366,d2		; leap year ?
		bne.s	searchmonth
		lea	(DayMonthLeap+2)(pc),a0
searchmonth	move.w	#1,d5		; d5 = [year][month]
		addq	#1,d0		; days starts from 1..
mloop		cmp	(a0)+,d0	; days <= DayMonth(month) ?
		bls.s	monthfound
		addi.w	#1,d5		; inc month (warning: NO QUICK!)
		bra.s	mloop
monthfound	subq	#4,a0		; a0 points to month-1
		sub	(a0),d0		; d0 = day
		move	d0,d6		; d6 = [hr][day]

;-----  Set configuration date  -------------------------------------------

		move.b	d6,d0		; d0 = (day)
		lsl	#8,d0		; d0 = (day)(0)
		or.b	d5,d0		; d0 = (day)(month)
		swap	d0
		move.l	d5,d1
		swap	d1		; d1 = [month][year]
		move	d1,d0		; d0 = (day)(month)[year]
		move.l	d0,ConfigBuffer ; save to buffer

;-----  Save date/time to battery clock  ----------------------------------

		bsr	StartI2C	; initialize I2C bus
		move.b	#CLK_ADDR_WR,d2 ; write mode
		bsr	TXByte		; transmit address
		move.b	I2CStatus(pc),d0
		bne	I2CErrorStop	; bus error - Stops
		move.b	d5,d2
		bsr	TXByteToBCD	; transmit month
		move.b	d6,d2
		bsr	TXByteToBCD	; transmit day
		swap	d6
		move.b	d6,d2
		bsr	TXByteToBCD	; transmit hour
		move.b	d7,d2
		bsr	TXByteToBCD	; transmit min
		bsr	StopI2C

		move.b	I2CStatus(pc),d0
		bne	I2CError	; error

;-----  Save configuration date  ------------------------------------------

		moveq	#1,d4			; save mode
		moveq	#RETURN_FAIL,d5		; error code
		lea	ErrNoSave(pc),a5	; error string
		bsr	OpenConfig		; save
		bra	CloseExit
		

******  Load Clock  *******************************************************
;
;
;-----  Load date/time from battery clock  --------------------------------

LoadClock	bsr	StartI2C	; initialize I2C bus
		move.b	#CLK_ADDR_RD,d2	; read mode
		bsr	TXByte		; transmit address
		move.b	I2CStatus(pc),d0
		bne.s	I2CErrorStop	; bus error - Stops
		moveq	#MONTH_MASK,d5	; month mask
		bsr	RXByteFromBCD	; receive month
		move	d4,-(sp)	; save month
		moveq	#DAYHR_MASK,d5	; day & hour mask
		bsr	RXByteFromBCD	; recieve day
		move	d4,d6
		swap	d6
		bsr	RXByteFromBCD	; receive hour
		move	d4,d6		; d6 = [day][hr]
		tst.l	d6
		bne.s	ClockSet	; ok, clock is set
ClockNotSet	bsr	StopI2C		; clock is not set (day=0 & hr=0)
		moveq	#RETURN_FAIL,d7
		lea	ErrClkNotSet(pc),a0
		bra	ErrorExit						
ClockSet	moveq	#MINSEC_MASK,d5	; min & sec mask
		bsr	RXByteFromBCD	; receive min
		move	d4,d7
		swap	d7
		bsr	RXByteFromBCD	; receive sec
		move	d4,d7		; d7 = [min][sec]
		move	(sp)+,d5	; d5 = [?][month]
		bsr	StopI2C		; end of I2C communication
		
		move.b	I2CStatus(pc),d0
		beq.s	RConfig			; status ok
		bne.s	I2CError

;-----  I2C error condition  ----------------------------------------------

I2CErrorStop	bsr	StopI2C			; stop I2C and exit
I2CError	moveq	#RETURN_ERROR,d7	; error code
		lea	ErrNoClock(pc),a0	; error string
		bra	ErrorExit

;-----  Read configuration file  ------------------------------------------

RConfig		movem.l	d5-d7,-(sp)		; save clock data
		moveq	#0,d4			; read mode
		moveq	#RETURN_FAIL,d5		; error code
		lea	ErrNoConfig(pc),a5	; error string
		bsr	OpenConfig		; read config
		movem.l	(sp)+,d5-d7		; restore registers

		move.l	ConfigBuffer(pc),d4	; d4 = config data (cxxx)
		
;-----  Test configuration range  -----------------------------------------

		move.l	d4,d3			; d3 = (cday)(cmonth)[cyear]
		cmp	#1978,d3		; cyear < 1978 ?
		bpl	ChkUpYBound		; no

ConfigError	moveq	#RETURN_FAIL,d7		; error code
		lea	ErrBadData(pc),a0	; error string
		bra	ErrorExit
		
ChkUpYBound	cmp	#2067,d3		; cyear >= 2067 ?
		bpl	ConfigError		; yes, error

		swap	d3			; d3 = (cday)(cmonth)
		tst.b	d3			; cmonth = 0 ?
		beq.s	ConfigError
		cmp.b	#12,d3			; cmonth > 12 ?
		bhi.s	ConfigError
		lsr	#8,d3			; d3 = (cday)
		beq.s	ConfigError		; cday = 0 ?
		cmp.b	#31,d3			; cday > 31 ?
		bhi.s	ConfigError
			
		
;-----  Check if configuration file must be updated  ----------------------

		move	d4,d3			; d3 = cyear
		swap	d4			; d4 = (cday)(cmonth)
		cmp.b	d4,d5			; month > cmonth ?
		bhi.s	CheckZero		; yes, ok
		bne.s	UpdateYear		; month < cmonth, update year
		lsr	#8,d4			; d4 = cday
		move.l	d6,d0
		swap	d0			; d0 = [hr][day]
		cmp.b	d4,d0			; day < cday ?
		bmi.s	UpdateYear		; yes, update year

CheckZero	move.b	ConfigModified(pc),d0	; Forced update ? (ZeroClok)
		bne.s	Update			; yes, update
		bra.s	SetYear			; no, skip

UpdateYear	addq	#1,d3			; inc year
Update		move.l	d6,d2
		swap	d2			; d2 = [hr][day]
		lsl	#8,d2			; d2 = (day)(0)
		move.b	d5,d2			; d2 = (day)(month)
		swap	d2
		move	d3,d2			; d2 = current date (config)
		move.l	d2,ConfigBuffer		; save into config buffer
		move.b	#$FF,ConfigModified	; set modified flag

SetYear		swap	d5
		move	d3,d5
		swap	d5			; d5 = [year][month]

;-----  Convert to system time format  ------------------------------------
;
; Input: d5 = [year][month]
;        d6 = [ day][ hr  ]
;        d7 = [ min][ sec ]

				 
ConvToSysTime	moveq	#0,d0		; clear d0
		move	d7,d0		; d0 = [0,sec]
		swap	d7		; d7 = [sec,min]
		move	d6,d2		; d2 = hr
		moveq	#60,d1
		mulu	d1,d2		; d2 = hr*60
		add	d7,d2		; d2 = hr*60+min
		mulu	d1,d2		; d2 = hr*3600+min*60
		add.l	d2,d0		; d0 = seconds from midnight
		
		clr	d6		; d6 = [day,0]
		swap	d6		; d6 = day (long)
		subq	#1,d6		; days start from 0..
		lea	(DayMonth-2)(pc),a0	; array base pointer
		move	d5,d1		; d1 = month
		lsl	#1,d1
		add	(a0,d1.w),d6	; d6 = days from Jan,1 (long)
		move	d5,d3		; d3 = month
		swap	d5		; d5 = [month,year]
		move	d5,d1		; d1 = year
		sub	#1978,d5	; d5 = year-1978
		move	#365,d2
		mulu	d5,d2		; d2 = (year-1978)*365
		add	d2,d6		; d6 = days from Jan,1 1978 (no leap)
		bsr	LeapCheck	; d2 = # of days of current year
		cmp	#365,d2
		beq.s	1$		; normal year
		cmp	#2,d3		; leap year: is month > feb ?
		bls.s	1$
		addq	#1,d6		; yes, add one day for current year
1$		cmp	#2000,d1	; year > 2000 ?
		bls.s	2$		; no
		subq	#1,d6		; yes, sub. one day (2000 isn't leap)
2$		sub	#1977,d1	; compute (year-1977)/4,
		lsr	#2,d1		; number of leap years from 1978
		add	d1,d6		; d6 = # of days from Jan,1 78 - OK
		move	#21600,d2
		mulu	d2,d6
		lsl.l	#2,d6		; d6 converted in secs (*86400)
		add.l	d6,d0		; d0 = # of secs from Jan,1 78 - OK

;-----  Set system time  --------------------------------------------------

SetSystemTime	move.l	TimeReq(pc),a1
		moveq	#TR_SETSYSTIME,d1
		move.w	d1,IO_COMMAND(a1)
		move.l	d0,(IOTV_TIME+TV_SECS)(a1)
		moveq	#0,d1
		move.l	d1,(IOTV_TIME+TV_MICRO)(a1)
		CALLEXEC DoIO

;-----  Check if configuration file must be saved  ------------------------

		move.b	ConfigModified(pc),d0
		beq.s	LBye			; not modified, exits
		moveq	#1,d4			; mode = save
		moveq	#RETURN_WARN,d5		; error code
		lea	ErrNoSave(pc),a5	; error string
		bsr	OpenConfig		; save data
LBye		bra	CloseExit		; exits		
		

******  Zero clock  *******************************************************

ZeroClock	bsr	StartI2C	; initialize I2C bus
		move.b	#CLK_ADDR_WR,d2	; write mode
		bsr	TXByte		; transmit address
		bsr	StopI2C

		move.b	I2CStatus(pc),d0
		bne	I2CError		; error
		
		move.b	#$FF,ConfigModified	; force update
		bra	LoadClock


******  Leap check  *******************************************************
;
; Input : D1 year
; Output: D2 number of days of year D1
; Registers modified: D2

LeapCheck	move.l	d1,-(sp)	; save d1
		move	#365,d2
		cmp	#2000,d1
		beq.s	1$		; year 2000 is not leap
		and	#3,d1		; check if year divisible by 4
		bne.s	1$
		addq	#1,d2		; yes, it's a leap year: 366 days
1$		move.l	(sp)+,d1	; restore d1
		rts

		end
