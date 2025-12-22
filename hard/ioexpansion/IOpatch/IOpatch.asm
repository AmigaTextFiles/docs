*****************************************************************************
* Program:  IOpatch.asm - ©1990 by Dan Babcock
* Function: This program patches the exec OpenDevice call, and allows the
*           user to select a serial or parallel unit.
*
* Author:   Dan Babcock
* History:  02/07/90 DB V0.50 Created
*           09/22/90 DB V0.51 Added code to prevent redundant requesters
*                             in certain cases.
*           12/10/90 JL V0.52 Added code to parse the command line, and
*                             allow various arguments (outlined below).
*           01/12/91 DB V0.53 Misc. enhancements
*
* [To all: Please don't forget to bump the revision numbers if you do *any*
*          modifications at all.  -Jeff]
*****************************************************************************
* Program:  SelectWindow - ©1990 by The Puzzle Factory
* Function: Get the users preference for which unit to open.
*
* Author:   Jeff Lavin
* History:  01/29/90 JL V0.50 Created
*           02/07/90 DB V0.51 Modified to include an "Internal" gadget.
*           08/22/90 JL V0.52 Added borders to the gadgets.
*                             Converted to Macro68 & new syntax.
*           09/12/90 JL V0.53 Dynamically size everything now.
*           09/26/90 JL V0.54 Fixed lores display problem.
*           11/16/90 JL V0.55 Rearrainged gadgets; Gadget 0 is now full width.
*
* [To all: Please don't forget to bump the revision numbers if you do *any*
*          modifications at all.  -Jeff]
*****************************************************************************


*****************************************************************************
* NAME
*     IOpatch - This program patches the exec OpenDevice call. The user
*     puts this program in his startup-sequence or whereever before he runs
*     his terminal progs, BBS's and whatnot - if these do not permit the
*     user to change the device/unit info. If they do, this utility is not
*     needed, obviously.
*
* INPUTS
*
*     1> IOpatch       ;Check OpenDevice() calls for serial & parallel device
*     1> IOpatch -a    ;Check OpenDevice() calls for serial & parallel device
*     1> IOpatch -s    ;Check OpenDevice() calls for serial device only
*     1> IOpatch -p    ;Check OpenDevice() calls for parallel device only
*     1> IOpatch -q    ;Replaces previous vector for OpenDevice() calls.
*     1> IOpatch ?     ;Prints these instructions
*
* RESULTS
*     OpenDevice() will use the either:
*
*          the serial.device or the newser.device
*          the parallel.device or the eightbit.device
*
*     with the proper unit number depending on which device was to have been
*     opened, and what the user selected from the requester.
*
* NOTES
*     There is one complication: I noticed during testing that most term
*     programs open and close the serial.device several times during their
*     startup routines. This is rather stupid of them, of course, and it
*     unfortunately results in many redundant requesters.
*     This version tries its best to avoid this problem by keeping track of
*     tasks that have opened the serial/parallel device and re-using
*     previously specified (by the user via the requester) unit number.
* 
*     One last note: this program copies itself into dynamically allocated
*     memory, so the user does not have to "run" it.
*
******************************* tear here ***********************************

;Set Tabs           |       |                 |       |

	ifnd	__m68
	fail	'Wrong assembler!'
	endc
	exeobj
	macfile	'Includes:IOexp.i'	;The One & Only include file
	objfile	'IOpatch'

TASKTABLESIZE	equ	32

Dispatcher	moveq	#-1,d2	;serflag default
	moveq	#-1,d3	;parflag default
	moveq	#0,d6	;quit flag default
	moveq	#0,d5	;Clear WBenchMsg

	movea.l	(SysBase).w,a6
	movea.l	(ThisTask,a6),a2
	tst.l	(pr_CLI,a2)	;Are we a child of WBench?
	bne.b	FromCLI	;Branch if no

	lea	(pr_MsgPort,a2),a0
	SYS	WaitPort
	lea	(pr_MsgPort,a2),a0
	SYS	GetMsg
	move.l	d0,d5	;WBenchMsg
	bra.w	SetPatch	;No args from WBench

FromCLI	lea	(a0,d0.w),a1
..	cmpi.b	#' ',-(a1)	;Eat trailing garbage
	dbhi	d0,..
	blt.b	SetPatch	;If no arguments, don't parse
	clr.b	(1,a1)	;Null terminate the string

Parse	moveq	#0,d0
	move.b	(a0)+,d0
	beq.b	SetPatch	;Null ends
	cmpi.b	#' ',d0	;Skip spaces
	beq.b	Parse
	cmpi.b	#'?',d0	;Instruct?
	beq.b	4$	;"Usage:..."
	cmpi.b	#'-',d0	;Look for "-" char
	bne.b	Parse	;Skip til we find one
	move.b	(a0)+,d0	;Get next char
	beq.b	SetPatch	;Null ends
	cmpi.b	#'a',d0	;Convert to U/C
	blo.s	1$
	cmpi.b	#'z',d0
	bhi.s	1$
	subi.b	#$20,d0

1$	cmpi.b	#'A',d0	;[A]ll
	bne.b	2$
	seq	d2	;serflag
	seq	d3	;parflag
	bra.b	SetPatch

2$	cmpi.b	#'S',d0	;[S]erial only
	bne.b	3$
	seq	d2	;serflag
	sne	d3	;parflag
	bra.b	SetPatch

3$	cmpi.b	#'P',d0	;[P]arallel only
	bne.b	4$
	sne	d2	;serflag
	seq	d3	;parflag
	bra.b	SetPatch

4$	cmpi.b	#'Q',d0	;[Q]uit
	bne.w	Instruct
	seq	d6	;quit flag

;Note that multitasking is disabled (via Forbid) throughout the install
;code for 100% safety.
;First, check to see whether this program has been run before.

SetPatch	lea	(serflag,pc),a0
	move.b	d2,(a0)
	lea	(parflag,pc),a0
	move.b	d3,(a0)

	movea.l	(SysBase).w,a6
	SYS	Forbid

	lea	(portname,pc),a1
	SYS	FindPort
	move.l	d0,d2
	tst.l	d2
	bne.b	installed	;Go if already installed
 
;Not installed, so allocate memory and copy

	move.l	#enddispatchcode-startdispatchcode,d7
	move.l	d7,d0
	moveq	#0,d1	;No special attributes
	SYS	AllocMem
	tst.l	d0
	bne.b	allocok

panic	tst.l	d5	;WBenchMsg
	beq.b	1$
	movea.l	d5,a1	;We're already forbidden
	SYS	ReplyMsg	;Return msg
	bra.b	2$

1$	SYS	Permit
2$	moveq	#-1,d0
	rts

allocok	movea.l	d0,a5
	movea.l	d0,a1
	lea	(startdispatchcode,pc),a0
	move.l	d7,d0
	SYS	CopyMem
	lea	(panic,pc),a4
	jmp	(a5)	;Go to startdispatchcode

installed	tst.b	d6	;Go if already installed
	beq.b	quitdispatch	;& quit flag set

;Remove the patch (port addr in d2)

	movea.l	d2,a2
	movea.l	(MP_SIZE,a2),a3	;Get start addr of res code
	lea	(newopendevice-startdispatchcode,a3),a4 ;Get addr of replacement
	cmpa.l	(_LVOOpenDevice+2,a6),a4 ;Still there?
	bne.b	panic	;No, so can't deinstall
	lea	(newremtask-startdispatchcode,a3),a4 ;Get addr of replacement
	cmpa.l	(_LVORemTask+2,a6),a4 ;Still there?
	bne.b	panic	;No, so can't deinstall

	move.l	(oldopenvec-startdispatchcode,a3),d0
	movea.w	#_LVOOpenDevice,a0
	movea.l	a6,a1
	SYS	SetFunction

	move.l	(oldremtask-startdispatchcode,a3),d0
	movea.w	#_LVORemTask,a0
	movea.l	a6,a1
	SYS	SetFunction

	movea.l	a2,a1	;Deallocate memory etc.
	SYS	RemPort

	moveq	#MP_SIZE+4,d0
	movea.l	a2,a1
	SYS	FreeMem	;Free message port

	move.l	#enddispatchcode-startdispatchcode,d0
	movea.l	a3,a1
	SYS	FreeMem	;Free the code

quitdispatch	tst.l	d5	;WBenchMsg
	beq.b	1$
	movea.l	d5,a1	;We're already forbidden
	SYS	ReplyMsg	;Return msg
	bra.b	2$

1$	SYS	Permit
2$	moveq	#0,d0
	rts

Instruct	tst.l	d5	;WBenchMsg
	beq.b	.OpenDos
	addq.b	#1,(TDNestCnt,a6)	;Forbid so WBench won't
	movea.l	d5,a1	; UnloadSeg() us
	SYS	ReplyMsg	;Return msg
	bra.b	.Exit

.OpenDos	lea	(DosName,pc),a1
	moveq	#0,d0
	SYS	OpenLibrary	;Open dos.library
	tst.l	d0
	beq.b	.Exit	;Failed!

	move.l	a6,-(sp)
	movea.l	d0,a6
	SYS	Output	;Get output filehandle
	move.l	d0,d1	;Filehandle
	beq.b	.CloseDos
	lea	(Help.msg,pc),a0
	move.l	a0,d2	;Buffer
	move.l	#Help_Len,d3	;Length
	SYS	Write	;Help the user

.CloseDos	movea.l	a6,a1
	movea.l	(sp)+,a6
	SYS	CloseLibrary	;Close the dos.library
.Exit	moveq	#0,d0
	rts


;***** All the following code is copied into dynamically allocated mem

;Add a port to indicate that we're installed
;Allocate memory for the port

startdispatchcode	moveq	#MP_SIZE+4,d0	;MsgPort+4 bytes of private info
	moveq	#1,d1
	swap	d1	;CLEAR parm
	SYS	AllocMem
	tst.l	d0
	bne.b	somememleft

	move.l	d7,d0	;Uh oh. The poor user is out of memory.
	move.l	a4,-(sp)	;Return addr
	movea.l	a5,a1
	jmp	(_LVOFreeMem,a6)	;RTS takes us back to 'panic'

somememleft	movea.l	d0,a1
	lea	(portname,pc),a0
	move.l	a0,(LN_NAME,a1) 
	move.l	a5,(MP_SIZE,a1)	;Private info - addr of res code 
	SYS	AddPort

	movea.w	#_LVOOpenDevice,a0 ;Patch into OpenDevice
	movea.l	a6,a1
	lea	(newopendevice,pc),a2
	move.l	a2,d0
	SYS	SetFunction

	lea	(oldopenvec,pc),a0
	move.l	d0,(a0)

	movea.w	#_LVORemTask,a0 ;Patch into RemTask
	movea.l	a6,a1
	lea	(newremtask,pc),a2
	move.l	a2,d0
	SYS	SetFunction
	lea	(oldremtask,pc),a0
	move.l	d0,(a0)

	tst.l	d5	;WBenchMsg
	beq.b	1$
	movea.l	d5,a1	;We're already forbidden
	SYS	ReplyMsg	;Return msg
	bra.b	2$

1$	SYS	Permit 
2$	moveq	#0,d0
	rts


;*** NOTE: A zero TCB (in A1) indicates self removal !!!!
;(this little fact nearly drove me nuts during debugging!)

newremtask:
	move.l	a1,d0
	bne.b	.L2
	move.l	a1,-(sp)
	SYS	FindTask
	movea.l	(sp)+,a1
.L2	move.l	a1,-(sp)
	SYS	Forbid
	movea.l	(sp)+,a1

	moveq	#TASKTABLESIZE-1,d1
	lea	(sertasklist,pc),a0
..	cmp.l	(a0)+,d0
	addq.l	#2,a0
	dbeq	d1,..
	bne.b	.L1
	clr.l	(-6,a0)
.L1

	moveq	#TASKTABLESIZE-1,d1
	lea	(partasklist,pc),a0
..	cmp.l	(a0)+,d0
	addq.l	#2,a0
	dbeq	d1,..
	bne.b	.L3
	clr.l	(-6,a0)
.L3

	move.l	a1,-(sp)
	SYS	Permit
	movea.l	(sp)+,a1
	movea.l	(oldremtask,pc),a0
	jmp	(a0)

newopendevice	movem.l d6-d7/a2-a5,-(sp)
	suba.l	a5,a5	;Sanity check
	tst.l	d0	;Check unit number
	bne	oldopenjump	;If nonzero, skip menu
	lea	(serunitexists,pc),a4
	lea	(serflag,pc),a2
	tst.b	(a2)+	;Want to check serial device?
	beq.b	1$	;Branch if no
	movea.l	a0,a3
..	cmpm.b	(a2)+,(a3)+
	bne.b	1$
	tst.b	(-1,a2)
	bne.b	..
	lea	(newserialname,pc),a5
	moveq	#0,d5
	bra.b	2$

1$	lea	(parflag,pc),a2
	tst.b	(a2)+	;Want to check parallel device?
	beq.b	2$	;Branch if no
	movea.l	a0,a3
..	cmpm.b	(a2)+,(a3)+
	bne.w	nogood
	tst.b	(-1,a2)
	bne.b	..
	lea	(newparallelname,pc),a5
	moveq	#1,d5
	addq.w	#4,a4	;Point to parunitexists

;One last check: if this task has previously opened either the serial.device
;or the parallel.device, use the same unit number (stored in tasklist) rather
;than bothering the user.

2$	cmpa.l	#0,a5	;Sanity check
	beq	nogood	;User has disabled both flags!

	movem.l	d0/d1/a0/a1,-(sp)
	move.l	(ThisTask,a6),d6
	SYS	Forbid
	moveq	#15,d7
	lea	(sertasklist,pc),a2
	tst.l	d5
	beq.b	.skippar
	lea	(partasklist,pc),a2
.skippar:
..	cmp.l	(a2)+,d6	
	addq.l	#2,a2
	dbeq	d7,..
	bne.b	popup
	SYS	Permit
	movem.l	(sp)+,d0/d1/a0/a1
	moveq	#0,d0
	move.w	(-2,a2),d0
	bra.b	skipmenu

popup	SYS	Permit
	movem.l	(sp)+,d0/d1/a0/a1

;pop up a menu

	move.l	(a4),d0	;serunitexists/parunitexists
	movem.l	d1-d7/a0-a6,-(sp)
	bsr	SelWin	;Get input from the user
	movem.l	(sp)+,d1-d7/a0-a6
	tst.l	d0	;Ok?
	bpl.b	contdisp

;The user is out of memory; signal an error

	moveq	#-1,d0 
	move.b	d0,(IO_ERROR,a1)	;Set error in the IO Request
	bra.b	endnewopen

contdisp:

;store the TCB ptr and the unit# in tasklist for future use

;search for an empty slot
	movem.l	d0/d1/a0/a1,-(sp)
	SYS	Forbid
	lea	(sertasklist,pc),a2
	tst.l	d5
	beq.b	.skippar
	lea	(partasklist,pc),a2
.skippar:
	moveq	#TASKTABLESIZE-1,d7
..	tst.l	(a2)+
	addq.w	#2,a2
	dbeq	d7,..
	bne.b	oldtask	;Full! (not likely to happen)
	SYS	Permit
	movem.l	(sp)+,d0/d1/a0/a1
	move.l	d6,(-6,a2)
	move.w	d0,(-2,a2)	
	bra.b	skipmenu
oldtask:
	SYS	Permit
	movem.l	(sp)+,d0/d1/a0/a1

skipmenu:
	tst.l	d0
	beq.b	oldopenjump	;If zero, use std device
	subq.l	#1,d0

oldtask1	movea.l	a5,a0	;newserialname/newparallelname
nogood 
oldopenjump	movea.l	(oldopenvec,pc),a3
	jsr	(a3)
endnewopen	movem.l	(sp)+,d6-d7/a2-a5
	rts
 
oldopenvec	dl	0 
oldremtask	dl	0

;These variables should be set by the code that checks for the presence
;of units 3 and 4.  Right now, they're hard-coded to say that they exist.

serunitexists	dl	1
parunitexists	dl	1

;Note: TASKTABLESIZE entries, arranged like so:
;Ptr to TCB (longword)
;Unit number (word)

sertasklist:
	dcb.l	TASKTABLESIZE,0
	dcb.w	TASKTABLESIZE,0
partasklist:
	dcb.l	TASKTABLESIZE,0
	dcb.w	TASKTABLESIZE,0

portname	cstr	'IOExp dispatcher V1.10 ©1990 by Dan Babcock *INSTALLED*'
serflag	db	$FF	;Default = ON
oldserialname	cstr	'serial.device'
newserialname	MYDEVNAME
parflag	db	$FF	;Default = ON
oldparallelname	cstr	'parallel.device'
newparallelname	PARDEVNAME
DosName	cstr	'dos.library'

Help.msg	db	'I/O Expansion Dispatcher V1.10 ©1990 by Dan Babcock',10
	db	'Usage:',10,10
	db	' IOpatch     ;Check OpenDevice() calls for serial & parallel device',10
	db	' IOpatch -a  ;Check OpenDevice() calls for serial & parallel device',10
	db	' IOpatch -s  ;Check OpenDevice() calls for serial device only',10
	db	' IOpatch -p  ;Check OpenDevice() calls for parallel device only',10
	db	' IOpatch -q  ;Replaces previous vector for OpenDevice() calls.',10
	db	' IOpatch ?   ;Prints these instructions',10,0
Help_Len	equ	*-Help.msg
	quad

*****************************************************************************
* NAME
*     SelectWindow - Get the users preference for which unit to open.
*
* SYNOPSIS
*     SelectWindow (UnitExits)
*          D0          D0
*
*     LONG  UnitExists;
*
* INPUTS
*     UnitExists - Non-zero if units 2 and 3 exist, else 0.
*
* RESULTS
*     A value of 0 if the user didn't select a unit and simply hit the close
*     gadget (unit number then defaults to 0).
*
* -> A value of zero is also returned if the user selects the "Internal"
* -> gadget, indicating that he wants to use "serial.device" rather than
* -> "newser.device", or "parallel.device" rather than "eightbit.device".
*
*     A value of 1-4 is returned if the user has selected a unit.
*     A return value of -1 indicates that an error has occured.
*
* NOTES
*     SelectWindow is both relocatable, and reentrant.
*     SelectWindow is Copyright ©1990 by The Puzzle Factory
*
******************************* tear here ***********************************

MyFeatures	equ	SMART_REFRESH!NOCAREREFRESH!ACTIVATE
MyGadgets	equ	WINDOWDRAG!WINDOWDEPTH!WINDOWCLOSE

MyBase	clrso		;BSS structure
Gfx_Base	so.l	1
Int_Base	so.l	1
FontPtr	so.l	1
ScreenPtr	so.l	1
HiresFlag	so.b	1
LaceFlag	so.b	1
MyWindow	so.b	nw_SIZE
Gadget0	so.b	gg_SIZEOF
Gadget1	so.b	gg_SIZEOF
Gadget2	so.b	gg_SIZEOF
Gadget3	so.b	gg_SIZEOF
Gadget4	so.b	gg_SIZEOF

Gad0.ITxt	so.b	it_SIZEOF
Gad1.ITxt	so.b	it_SIZEOF
Gad2.ITxt	so.b	it_SIZEOF
Gad3.ITxt	so.b	it_SIZEOF
Gad4.ITxt	so.b	it_SIZEOF
MyBorder	so.b	bd_SIZEOF
MyCoords	so.w	10
Border0	so.b	bd_SIZEOF
Coords0	so.w	10
Text_Attr	so.b	ta_SIZEOF
MB_Sizeof	soval

SelWin	move.l	d0,d3	;UnitExists
	moveq	#0,d7	;Default = Nothing
	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	#MB_Sizeof,d0
	movea.l	(SysBase).w,a6
	SYS	AllocMem
	tst.l	d0
	bne.b	1$
	subq.l	#1,d0	;Return -1 for error
	rts

1$	movea.l	d0,a5	;Our relative base
	lea	(GfxName,pc),a1	;Open graphics.library
	moveq	#33,d0

	SYS	OpenLibrary
	move.l	d0,(Gfx_Base,a5)
	beq	Error

	lea	(IntName,pc),a1	;Open intuition.library
	moveq	#33,d0
	SYS	OpenLibrary
	move.l	d0,(Int_Base,a5)
	beq	Error
	movea.l	d0,a6

	lea	(Text_Attr,a5),a1
	lea	(FontName,pc),a0
	move.l	a0,(ta_Name,a1)
	move.w	#8,(ta_YSize,a1)
	move.b	#FS_NORMAL,(ta_Style,a1)
	move.b	#FPF_ROMFONT,(ta_Flags,a1)

	movea.l	(ib_ActiveScreen,a6),a0 ;Get active screen
	move.l	a0,(ScreenPtr,a5)
	move.w	(sc_Width,a0),d0
	cmpi.w	#352,d0	;Check horz resolution
	sge	(HiresFlag,a5)
	btst	#2,(sc_ViewPort+vp_Modes+1,a0)
	sne	(LaceFlag,a5)

	lea	(MyBorder,a5),a1	;Setup default border
	lea	(Border0,a5),a2
	clr.l	(a1)+	;bd_LeftEdge,bd_TopEdge
	clr.l	(a2)+	;bd_LeftEdge,bd_TopEdge

	move.l	#$01000005,d0	;bd_FrontPen,bd_BackPen,bd_DrawMode,bd_Count
	move.l	d0,(a1)+
	move.l	d0,(a2)+
	lea	(MyCoords,a5),a0
	move.l	a0,(a1)+	;bd_XY
	lea	(Coords0,a5),a0
	move.l	a0,(a2)+	;bd_XY

	lea	(Gadget0,a5),a4
	lea	(Gad0.ITxt,a5),a3
	lea	(GadText.tbl,pc),a2
	tst.b	(HiresFlag,a5)
	bne.b	3$
	lea	(LoresText.tbl,pc),a2
3$	moveq	#0,d2

4$	lea	(gg_SIZEOF,a4),a0
	move.l	a0,(a4)+	;gg_NextGadget

	moveq	#7,d0	;0,1,3: LeftEdge=7
	tst.w	d2	;0
	beq.b	5$
	btst	#0,d2	;Even or Odd?
	bne.b	5$
	moveq	#55,d0	;2,4: LeftEdge=55
5$	tst.b	(HiresFlag,a5)
	beq.b	6$
	add.w	d0,d0
6$	move.w	d0,(a4)+	;gg_LeftEdge

	moveq	#18,d0	;0: TopEdge=18
	tst.w	d2
	beq.b	7$
	addi.w	#22,d0	;1,2: TopEdge=40
	cmpi.w	#3,d2
	blt.b	7$
	addi.w	#22,d0	;3,4: TopEdge=62
7$	tst.b	(LaceFlag,a5)
	beq.b	8$
	add.w	d0,d0
8$	move.w	d0,(a4)+	;gg_TopEdge

	moveq	#40,d0	;LORES
	tst.w	d2	;Gadget 0 only
	bne.b	18$
	addq.w	#4,d0
	add.w	d0,d0
18$	tst.b	(HiresFlag,a5)
	beq.b	9$
	add.w	d0,d0	;HIRES
9$	move.w	d0,(a4)+	;gg_Width
	lea	(MyCoords,a5),a0
	tst.w	d2
	bne.b	19$
	lea	(Coords0,a5),a0	;Gadget 0 only
19$	move.w	d0,(4,a0)	;X border coords
	move.w	d0,(8,a0)

	move.w	#18,d0	;NORMAL
	tst.b	(LaceFlag,a5)
	beq.b	10$
	add.w	d0,d0	;LACE
10$	move.w	d0,(a4)+	;gg_Height
	lea	(MyCoords,a5),a0
	tst.w	d2
	bne.b	20$
	lea	(Coords0,a5),a0	;Gadget 0 only
20$	move.w	d0,(10,a0)	;Y border coords
	move.w	d0,(14,a0)

	move.w	#GADGHCOMP,(a4)+	;gg_Flags
	move.w	#GADGIMMEDIATE,(a4)+ ;gg_Activation
	move.w	#BOOLGADGET,(a4)+	;gg_GadgetType
	lea	(MyBorder,a5),a0
	tst.w	d2
	bne.b	21$
	lea	(Border0,a5),a0	;Gadget 0 only
21$	move.l	a0,(a4)+	;gg_GadgetRender
	addq.w	#4,a4	;gg_SelectRender
	move.l	a3,(a4)+	;gg_GadgetText
	addq.w	#8,a4	;gg_MutualExclude,gg_SpecialInfo
	move.w	d2,(a4)+	;gg_GadgetID
	addq.w	#4,a4	;gg_UserData

	move.l	#$01000000,(a3)+	;it_FrontPen,it_BackPen,it_DrawMode

	moveq	#16,d0	;Gad1-4/HIRES=16
	tst.w	d2
	bne.b	23$
	tst.b	(HiresFlag,a5)	;Gadget 0 only
	beq.b	22$
	add.w	d0,d0
	add.w	d0,d0	;Gad0/HIRES=64
	bra.b	11$

22$	addq.w	#4,d0	;Gad0/LORES=20
	bra.b	11$

23$	tst.b	(HiresFlag,a5)	;Gadgets 1-4
	bne.b	11$
	subq.w	#4,d0	;Gad1-4/LORES=12
11$	move.w	d0,(a3)+	;it_LeftEdge

	moveq	#14,d0
	tst.b	(LaceFlag,a5)
	bne.b	12$
	subq.w	#8,d0
12$	move.w	d0,(a3)+	;it_TopEdge

	lea	(Text_Attr,a5),a0
	move.l	a0,(a3)+	;it_TextFont
	move.l	a2,(a3)+	;it_Text
	addq.w	#4,a3	;it_NextText

	addq.w	#7,a2	;Next text
	addq.w	#1,d2	;Next gadget
	cmpi.w	#4,d2	;All the gadgets done?
	ble.w	4$

	clr.l	(Gadget4,a5)	;gg_NextGadget

	lea	(Gadget0,a5),a0
	ori.w	#SELECTED,(gg_Flags,a0)

	tst.l	d3	;Units 2 & 3 exist?
	bne.b	13$	;Branch if yes
	move.w	#GADGDISABLED,d0	;Else, disable gadgets
	lea	(Gadget3,a5),a0
	or.w	d0,(gg_Flags,a0)

	lea	(Gadget4,a5),a0
	or.w	d0,(gg_Flags,a0)

13$	lea	(MyWindow,a5),a0
	movea.l	(ScreenPtr,a5),a2 ;Get active screen
	move.l	a2,(nw_Screen,a0)	;

	move.w	#103,d0	;LORES = 103
	tst.b	(HiresFlag,a5)
	beq.b	14$
	add.w	d0,d0	;HIRES = 206
14$	move.w	d0,(nw_Width,a0)
	move.w	(sc_Width,a2),d1
	lsr.w	#1,d1	;Screen width / 2
	lsr.w	#1,d0	;Window width / 2
	sub.w	d0,d1
	move.w	d1,(a0)	;nw_LeftEdge

	move.w	#88,d0	;NORMAL = 88
	tst.b	(LaceFlag,a5)
	beq.b	15$
	add.w	d0,d0	;LACE = 176
15$	move.w	d0,(nw_Height,a0)
	move.w	(sc_Height,a2),d1
	lsr.w	#1,d1	;Screen height / 2
	lsr.w	#1,d0	;Window height / 2
	sub.w	d0,d1
	move.w	d1,(nw_TopEdge,a0)

	move.b	#-1,(nw_DetailPen,a0)
	move.b	#-1,(nw_BlockPen,a0)
	move.l	#GADGETDOWN!CLOSEWINDOW,(nw_IDCMPFlags,a0)
	move.l	#MyFeatures!MyGadgets,(nw_Flags,a0)
	lea	(Gadget0,a5),a1
	move.l	a1,(nw_FirstGadget,a0)
	lea	(WindowTitle,pc),a1
	tst.b	(HiresFlag,a5)
	bne.b	16$
	lea	(LoresTitle,pc),a1
16$	move.l	a1,(nw_Title,a0)
	move.w	(sc_Flags,a2),d0
	andi.w	#%00001111,d0
	move.w	d0,(nw_Type,a0)
	SYS	OpenWindow	;Open window
	movea.l	d0,a3	;Save window pointer
	tst.l	d0
	beq.b	Error

	movea.l	(Gfx_Base,a5),a6
	lea	(Text_Attr,pc),a0
	SYS	OpenFont
	move.l	d0,(FontPtr,a5)
	beq.b	17$

	movea.l	d0,a0
	movea.l	(wd_RPort,a3),a1
	SYS	SetFont

17$	moveq	#0,d6	;Close flag
	bsr.b	MainLoop
	bra.b	Cleanup

************************************************
*             Termination section              *
************************************************

Error	subq.l	#1,d7
Cleanup	move.l	(Gfx_Base,a5),d2
	beq.b	2$
	move.l	(FontPtr,a5),d0
	beq.b	1$
	movea.l	d0,a1
	movea.l	d2,a6
	SYS	CloseFont

1$	movea.l	d2,a1
	movea.l	(SysBase).w,a6
	SYS	CloseLibrary

2$	move.l	(Int_Base,a5),d2
	beq.b	4$
	move.l	a3,d0
	beq.b	3$
	movea.l d0,a0
	movea.l	d2,a6
	SYS	CloseWindow

3$	movea.l	d2,a1
	movea.l	(SysBase).w,a6
	SYS	CloseLibrary

4$	movea.l	a5,a1
	move.l	#MB_Sizeof,d0
	movea.l	(SysBase).w,a6
	SYS	FreeMem
	move.l	d7,d0	;0-4, or -1 if error.
	rts

************************************************
*             Main Execution Loop              *
************************************************

MainLoop	tst.w	d6	;Flag set?
	beq.b	1$
	rts		;Exit

1$	movea.l (wd_UserPort,a3),a0
	moveq	#0,d0
	moveq	#0,d1
	move.b	(MP_SIGBIT,a0),d1
	bset	d1,d0
	movea.l	(SysBase).w,a6
	SYS	Wait	;Now wait for a message

GetIMsg	movea.l (wd_UserPort,a3),a0
	SYS	GetMsg
	tst.l	d0
	beq.b	MainLoop
	movea.l d0,a1
	move.l	(im_Class,a1),d2
	movea.l	(im_IAddress,a1),a2
	SYS	ReplyMsg

	cmpi.l	#CLOSEWINDOW,d2
	bne.b	CheckGads
	moveq	#-1,d6
	bra.b	GetIMsg

CheckGads	cmpi.w	#GADGETDOWN,d2	;Someone clicked on a gadget
	bne.b	1$	;Unknown class
	moveq	#0,d7
	move.w	(gg_GadgetID,a2),d7 ;ID = Unit number
	lea	(Gadget0,a5),a1	;1st gadget in group

	moveq	#5,d0	;# of gadgets in group
	bsr.b	MutualExclude
1$	bra.b	GetIMsg

*************************************************************************
* NAME:     MutualExclude()
* FUNCTION: Performs a MutualExclude function for Boolean gadgets.
* INPUTS:   A3 = Window
*           A2 = Currently selected gadget
*           A1 = 1st gadget in group
*           D0 = NumGads
* RETURN:   None
* SCRATCH:  D0-D1/A0-A1
*************************************************************************

MutualExclude	move.l	a6,-(sp)
	movea.l	(Int_Base,a5),a6
	movem.l	d0/a1,-(sp)
	movea.l	a3,a0	;Window
	SYS	RemoveGList
	move.l	d0,d4	;Position
	movem.l	(sp),d1/a1
	bra.b	3$

1$	cmp.w	(gg_GadgetID,a1),d7 ;Is this the current gadget?
	seq	d2	;D2 = 1 if TRUE
	btst	#7,(gg_Flags+1,a1)	;Currently selected?
	sne	d3	;D3 = 1 if TRUE
	eor.b	d2,d3
	beq.b	2$
	bchg	#7,(gg_Flags+1,a1)	;Toggle the select flag
2$	movea.l	(a1),a1	;gg_NextGadget
3$	dbra	d1,1$

	bsr.b	ClearScreen

	movea.l	a3,a0	;Window
	move.l	d4,d0	;Position
	movem.l	(sp),d1/a1	;NumGads/Gadget
	SYS	AddGList

	movea.l	a3,a1	;Window
	movem.l	(sp)+,d0/a0	;NumGads/Gadget
	SYS	RefreshGList
	movea.l	(sp)+,a6
	rts

ClearScreen	movem.l	a2/a6,-(sp)
	movea.l	(Gfx_Base,a5),a6
	movea.l	(wd_RPort,a3),a2
	moveq	#0,d0
	movea.l	a2,a1
	SYS	SetAPen

	moveq	#4,d0	;Xmin
	moveq	#14,d1	;Ymin
	moveq	#0,d2
	move.w	(wd_Width,a3),d2
	subq.w	#4,d2	;Xmax
	moveq	#0,d3
	move.w	(wd_Height,a3),d3
	subq.w	#4,d3	;Ymax
	movea.l	a2,a1
	SYS	RectFill

	moveq	#1,d0
	movea.l	a2,a1
	SYS	SetAPen
	movem.l	(sp)+,a2/a6
	rts

Notice	cstr	'SelectWindow ©1990 by The Puzzle Factory',10
GfxName	cstr	'graphics.library'
IntName	cstr	'intuition.library'
FontName	cstr	'topaz.font'
WindowTitle	cstr	'Select Unit:'
LoresTitle	cstr	'Sel Unit:'

GadText.tbl	cstr	'Unit 0'
	cstr	'Unit 1'
	cstr	'Unit 2'
	cstr	'Unit 3'
	cstr	'Unit 4'

LoresText.tbl	cstr	'Unit 0'
	cstr	'U1',0,0,0,0
	cstr	'U2',0,0,0,0
	cstr	'U3',0,0,0,0
	cstr	'U4',0,0,0,0

enddispatchcode	end
