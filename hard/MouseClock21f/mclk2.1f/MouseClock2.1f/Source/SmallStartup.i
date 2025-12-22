; SmallStartup.i  v1.1  by  Adriano De Minicis 
;
; This startup code is Public Domain.
;
; Modified version of easystart.i
; Assembler used: Devpac 3
;
; IMPORTANT: Include this file at the end of include file list, but before
;            the beginning of your program (otherwise don't works!)
;
; This startup opens dos.library, and calls your program with "bsr main",
; with the following variables initialized:
;
; CmdLineLen:   Command line lenght (CLI)
; CmdLinePtr:	Command line pointer (CLI). Points to first non-space char.
;               (Ending spaces are not removed!)
;               Command line is always terminated by $0A (Line feed).
;
; OutputFH:	File handle for CLI output (NULL from WB)
;
; WBenchMsg:    Pointer to WBStartup struct if called from WB,
;               NULL if called from CLI.
;
; _SysBase:	exec.library pointer
; _DOSBase:	dos.library pointer
;
;
; NOTE: Before exiting from main, put in D7 the return code that must be
;       passed to CLI (zero if OK, otherwise error)
;
; NOTE: You can exit at any moment calling Exit (also from nested function
;       calls, because it restore the stack pointer to initial value),
;       but obviously you must close/release all stuff you've opened or
;       allocated (except dos.library).
;       Put in D7 the return code.
;

		IFND	EXEC_EXEC_I
		include	exec/exec.i
		ENDC
		IFND	LIBRARIES_DOSEXTENS_I
		include	libraries/dosextens.i
		ENDC


AbsExecBase	equ	4


EntryPoint	move.l	sp,InitialSP		; save stack pointer
		move.l	d0,CmdLineLen		; and command line
		move.l  a0,CmdLinePtr		; parameters

		move.l	AbsExecBase,_SysBase	; save exec.lib pointer
		lea	DOSName(pc),a1
		moveq	#0,d0
		CALLEXEC OpenLibrary		; open DOS library
		move.l	d0,_DOSBase		; save dos.lib pointer
		beq.s	ByeBye

		sub.l	a1,a1
		CALLEXEC FindTask		; find us
		move.l	d0,a4

		tst.l	pr_CLI(a4)		; run from WB?
		beq.s	RunFromWB
		
RunFromCLI	CALLDOS	Output
		move.l	d0,OutputFH		
		bra.s	CallMain

RunFromWB	lea	pr_MsgPort(a4),a0
		CALLEXEC WaitPort		; wait for a message
		lea	pr_MsgPort(a4),a0
		CALLEXEC GetMsg			; then get it
		move.l	d0,WBenchMsg		; save it for later reply

; ---- Call our program ------------------------------------------------

CallMain	bsr	main

; ---- Returns to here with exit code in d7 ----------------------------

Exit		move.l	_DOSBase(pc),a1
		CALLEXEC CloseLibrary		; Close DOS library

		tst.l	WBenchMsg		; called from CLI?
		beq.s	ByeBye

		CALLEXEC Forbid
		move.l	WBenchMsg(pc),a1	; reply to WB
		CALLEXEC ReplyMsg

ByeBye		move.l	InitialSP,sp		; restore stack pointer
		move.l	d7,d0			; exit code
		rts

;-----  startup code variables  -------------------------------------------

DOSName		dc.b	'dos.library'

_DOSBase	dc.l	0
_SysBase	dc.l	0

WBenchMsg	dc.l	0	; null if called from CLI, or no output
OutputFH	dc.l	0	; null if called from WB

InitialSP	dc.l	0
CmdLineLen	dc.l	0
CmdLinePtr	dc.l	0

; the program starts here
		even

