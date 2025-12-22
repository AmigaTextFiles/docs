*****************************************************************************
* IOTest.asm - ©1990 by The Puzzle Factory
*          Performs some simple tests on the I/O Expansion Board Hardware.
*
* History: 08/15/89 V0.50 Created by Jeff Lavin
*          11/25/90 V0.51 Converted to new syntax, de-ARPed program.
*          12/03/90 V0.52 Killed a small bug.
*
* [To all: Please don't forget to bump the revision numbers if you do *any*
*          modifications at all.  -Jeff]
*
*   Usage: 1> IOTest <Test Number>
*          Where <Test Number> is one of the following:
*                1 = Read  VIA0      2 = Write VIA0
*                3 = Read  VIA1      4 = Write VIA1
*                5 = Read  ACIA0     6 = Write ACIA0
*                7 = Read  ACIA1     8 = Write ACIA1
*                9 = Term  ACIA1
*
*          Typing no arguments, or any non-decimal character will cause these
*          instructions to be printed.
*
* There are no error messages if anything goes wrong.  Feel free to add them.
* Do *not* use 'run' with test 9.  If you need another CLI, use NewCLI.
*
* None of these tests requires any drivers or other software to be used.
* Tests 1-8 do either a read or write of the hardware and after checking for
* a ^C, loop continuously.  These tests are mostly useful for checking if
* chip select signals exist with a logic probe.
*
* Test 9 must be used with a terminal.  The executable is hardwired for 9600
* baud and must be reassembled, or zapped, for other baud rates.  The test
* works as follows:
*
*   1. ACIA0 is initialized for 9600 baud, 1 stop bit, 8 data bits, no parity
*   2. The console is set to RAW mode to allow getting single chars without
*      having to type returns.
*   3. A character is read from the local console (the Amiga).  If the
*      character is an ESC, go to step 9.
*   4. The character is echoed back to the local console.
*   5. The character is then echoed to the terminal.
*   6. A character is read from the terminal.  This function does not block.
*      You should type the character on the terminal *before* you type the
*      character on the console in step 3.
*   7. This character is then echoed to the local console.
*   8. Loop back to step 3.
*   9. Reset console to CON mode, and exit.
*
* Notes:
* RAW modes does not support ^C.  Also, ^C might get eaten if you try running
* this program from a debugger.
*
*****************************************************************************

;Set Tabs           |       |                 |       |

	exeobj
	objfile	'ram:IOTest'
	macfile 'Includes:IOexp.i'	;The One & Only include file

IOTest	movea.l	a0,a2
	move.l	d0,d2	;Save cmd line
 	lea	(DosName,pc),a1	;Open DOS library
	moveq	#0,d0
	movea.l (SysBase).w,a6
	SYS	OpenLibrary
	movea.l d0,a6
	tst.l	d0
	bne.b	1$
	rts

1$	SYS	Input
	move.l	d0,d5
	beq.b	Cleanup

	SYS	Output
	move.l	d0,d6	;Output filehandle
	beq.b	Cleanup

	movea.l	a2,a0	;Get cmd line
	lea	(0,a0,d2.w),a1
2$	cmpi.b	#' ',-(a1)	;Eat trailing garbage
	dbhi	d2,2$
	blt.b	4$	;If no arguments, quit
	clr.b	(1,a1)	;Null terminate the string

	moveq	#0,d0
3$	move.b	(a0)+,d0	;Get a char
	beq.b	4$	;Nothing there
	cmpi.b	#' ',d0	;Skip leading spaces
	bls.b	3$
	subi.b	#'0',d0	;Check values
	bmi.b	4$
	cmpi.b	#9,d0
	bls.b	5$
4$	lea	(HelpMsg,pc),a0
	bsr	Puts
	bra.b	Cleanup

5$	subq.w	#1,d0		;0 to (n-1)
	lsl.w	#1,d0		;WORD index
	move.w	d0,-(sp)
	move.w	(TextTable,pc,d0.w),d0
	lea	(Text1,pc),a0
	lea	(a0,d0.w),a0
	bsr	Puts		;Write test name

	move.w	(sp)+,d0
	move.w	(FuncTable,pc,d0.w),d0
	jsr	(Test1,pc,d0.w)

Cleanup	movea.l	a6,a1
	movea.l (SysBase).w,a6
	SYS	CloseLibrary
	moveq	#0,d0
	rts

TextTable	dw	Text1-Text1
	dw	Text2-Text1
	dw	Text3-Text1
	dw	Text4-Text1
	dw	Text5-Text1
	dw	Text6-Text1
	dw	Text7-Text1
	dw	Text8-Text1
	dw	Text9-Text1

FuncTable	dw	Test1-Test1
	dw	Test2-Test1
	dw	Test3-Test1
	dw	Test4-Test1
	dw	Test5-Test1
	dw	Test6-Test1
	dw	Test7-Test1
	dw	Test8-Test1
	dw	Test9-Test1

Test1	lea	(VIA_Base+VIA0),a5
1$	move.b	(ORB,a5),d0	;Read VIA0
	bsr	CheckAbort
	beq.b	1$
	rts

Test2	lea	(VIA_Base+VIA0),a5
1$	moveq	#0,d0	;Write VIA0
	move.b	d0,(ORB,a5)
	bsr	CheckAbort
	beq.b	1$
	rts

Test3	lea	(VIA_Base+VIA1),a5
1$	move.b	(ORB,a5),d0	;Read VIA1
	bsr	CheckAbort
	beq.b	1$
	rts

Test4	lea	(VIA_Base+VIA1),a5
1$	moveq	#0,d0	;Write VIA1
	move.b	d0,(ORB,a5)
	bsr	CheckAbort
	beq.b	1$
	rts

Test5	lea	(ACIA_Base+ACIA0),a5
1$	move.b	(RDR,a5),d0	;Read ACIA0
	bsr	CheckAbort
	beq.b	1$
	rts

Test6	lea	(ACIA_Base+ACIA0),a5
1$	moveq	#0,d0	;Write ACIA0
	move.b	d0,(TDR,a5)
	bsr	CheckAbort
	beq.b	1$
	rts

Test7	lea	(ACIA_Base+ACIA1),a5
1$	move.b	(RDR,a5),d0	;Read ACIA1
	bsr.b	CheckAbort
	beq.b	1$
	rts

Test8	lea	(ACIA_Base+ACIA1),a5
1$	moveq	#0,d0	;Write ACIA1
	move.b	d0,(TDR,a5)
	bsr.b	CheckAbort
	beq.b	1$
	rts

Test9	lea	(ACIA_Base+ACIA0),a5
	move.b	(ISR,a5),d0	;Term ACIA0
	move.b	(CSR,a5),d0	;Clear garbage
	move.b	(RDR,a5),d0	;Clear RDRF bit
	move.b	#Baud_9600,(CTR,a5) ;9600 baud, 1 stop bit, no echo
	move.b	#FRF_FRMT!WORDLEN_8!PAR_MARK,d0
	move.b	d0,(FMR,a5)	;8 bits, mark par, no par, DTR hi

1$	lea	(Buffer,pc),a2
	bsr	SetRAWmode	;So we can get single chars
	tst.l	d0
	beq.b	4$	;Something failed

2$	move.l	d5,d1	;Filehandle
	move.l	a2,d2	;Buffer
	moveq	#1,d3	;Length
	SYS	Read	;Get a char from keybd
	moveq	#-1,d1	;Check for I/O error
	cmp.l	d0,d1
	beq.b	3$
	move.b	(a2),d0
	cmpi.b	#$1B,d0	;Was an ESC typed?
	beq.b	3$	;Yes, quit

	move.l	d6,d1	;Filehandle
	SYS	Write	;Echo char to local console
	moveq	#-1,d1	;Check for I/O error
	cmp.l	d0,d1
	beq.b	3$

	move.b	(a2),(TDR,a5)	;Echo char to terminal
	move.b	(RDR,a5),(a2)	;Get a char from terminal
	move.l	d6,d1	;Filehandle
	SYS	Write	;Echo char to local console
	moveq	#-1,d1	;Check for I/O error
	cmp.l	d0,d1
	bne.b	2$

3$	bsr	SetCONmode	;Reset console
4$	rts

*************************************************************************
* NAME:     CheckAbort()
* FUNCTION: Check for a ^C, and echo if found.
* INPUTS:   None.
* RETURN:   D0 = 1 if ^C, else 0.
* SCRATCH:  D0-D1/A0-A1
*************************************************************************

CheckAbort	moveq	#0,d0
	move.l	#SIGBREAKF_CTRL_C,d1
	move.l	a6,-(sp)
	movea.l	(SysBase).w,a6
	SYS	SetSignal
	movea.l	(sp)+,a6
	andi.l	#SIGBREAKF_CTRL_C,d0
	beq.b	1$
	lea	(BrkMsg,pc),a0
	bsr.b	Puts
	moveq	#1,d0
1$	rts

*************************************************************************
* NAME:     Puts()
* FUNCTION: Writes a message to stdout.
* INPUTS:   A0 = Ptr to message.
* RETURN:   None
* SCRATCH:  D0-D1/A0-A1
*************************************************************************

Puts	movem.l	d2-d3,-(sp)
	move.l	a0,d3
1$	tst.b	(a0)+
	bne.s	1$
	exg	a0,d3
	sub.l	a0,d3
	subq.l	#1,d3	;Length
	move.l	a0,d2	;Buffer
	move.l	d6,d1	;FileHandle
	SYS	Write
	movem.l	(sp)+,d2-d3
	rts

SetRAWmode	moveq	#DOSTRUE,d0
	bra.b	SendPacket

SetCONmode	moveq	#DOSFALSE,d0

SendPacket	movem.l	d2-d3/a2-a3/a6,-(sp)
	move.l	d0,d2
	moveq	#0,d3	;Default return value
	movea.l	(SysBase).w,a6
	bsr	CreatePort
	movea.l	D0,A3
	tst.l	D0
	beq.b	3$

	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	moveq	#sp_SIZEOF,d0
	SYS	AllocMem
	movea.l	D0,A2
	tst.l	D0
	beq.b	2$

	movea.l	a2,a1	;Message
	movea.l	a2,a0
	adda.l	#sp_Pkt,A0
	move.l	A0,(LN_NAME,A1)
	move.l	A2,(sp_Pkt,A1)
	move.l	A3,(dp_Port,A0)
	move.l	#ACTION_SCREEN_MODE,(dp_Type,A0)
	move.l	d2,(dp_Arg1,A0)
	movea.l	(ThisTask,a6),a0
	cmpi.b	#NT_PROCESS,(LN_TYPE,A0)
	bne.b	1$
	move.l	(pr_ConsoleTask,A0),d0
	beq.b	1$
	movea.l	d0,a0	;Port
	SYS	PutMsg

	movea.l	a3,a0
	SYS	WaitPort

	movea.l	a3,a0
	SYS	GetMsg
	move.l	(sp_Pkt+dp_Res1,A2),d3

1$	movea.l	a2,a1
	moveq	#sp_SIZEOF,d0
	SYS	FreeMem

2$	movea.l	a3,a0
	bsr	DeletePort
	move.l	d3,D0
3$	movem.l	(sp)+,d2-d3/a2-a3/a6
	rts

CreatePort	movem.l	d2/a2/a6,-(sp)
	moveq	#-1,d0
	SYS	AllocSignal
	move.l	d0,d2
	cmpi.l	#-1,d0
	beq.b	2$

	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	moveq	#MP_SIZE,d0
	SYS	AllocMem
	movea.l	d0,a2
	tst.l	d0
	bne.b	1$
	move.l	d2,d0
	SYS	FreeSignal
	bra.b	2$

1$	move.b	#NT_MSGPORT,(LN_TYPE,a2)
	move.b	d2,(MP_SIGBIT,a2)
	move.l	(ThisTask,a6),(MP_SIGTASK,a2)

	lea	(MP_MSGLIST,a2),a0	;NEWLIST
	move.l	a0,(a0)
	addq.l	#LH_TAIL,(a0)
	clr.l	(LH_TAIL,a0)
	move.l	a0,(LH_TAIL+LN_PRED,a0)
	move.l	a2,d0
	bra.b	3$

2$	moveq	#0,d0
3$	movem.l	(sp)+,d2/a2/a6
	rts

DeletePort	movem.l	a2/a6,-(sp)
	movea.l	a0,a2
	move.b	#-1,(LN_TYPE,a2)
	move.l	#-1,(MP_MSGLIST,a2)
	moveq	#0,d0
	move.b	(MP_SIGBIT,a2),d0
	SYS	FreeSignal

	moveq	#MP_SIZE,d0
	movea.l	a2,a1
	SYS	FreeMem
	movem.l	(sp)+,a2/a6
	rts

DosName	cstr	'dos.library'

BrkMsg	cstr	'**** Break',10

HelpMsg	db	10
	db	'Usage:',10
	db	'1> <Test Number>',10
	db	'    1 = Read  VIA0',10
	db	'    2 = Write VIA0',10
	db	'    3 = Read  VIA1',10
	db	'    4 = Write VIA1',10
	db	'    5 = Read  ACIA0',10
	db	'    6 = Write ACIA0',10
	db	'    7 = Read  ACIA1',10
	db	'    8 = Write ACIA1',10
	db	'    9 = Term  ACIA1',10,0

Text1	cstr	'Test1: Read VIA0',10
Text2	cstr	'Test2: Write VIA0',10
Text3	cstr	'Test3: Read VIA1',10
Text4	cstr	'Test4: Write VIA1',10
Text5	cstr	'Test5: Read ACIA0',10
Text6	cstr	'Test6: Write ACIA0',10
Text7	cstr	'Test7: Read ACIA1',10
Text8	cstr	'Test8: Write ACIA1',10
Text9	cstr	'Test9: Term  ACIA0',10

Buffer	dx.b	80

	end
