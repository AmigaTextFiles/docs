*****************************************************************************
*  Program: ioexp-handler.asm
*  Descrip: Port handler for the newser.device and eightbit.device
*           for use with the I/O Expansion Board.
*    Usage: Place the executable PortHandler in your L: directory
*           and create the following MountList entries:
*
*           A sample MountList entries for this handler follows:
*
*           SER1: Handler   = L:ioexp-handler
*                 StackSize = 2000
*                 Priority  = 5
*                 GlobVec   = -1
*           #
*
*  History:     1988 AF V1.00 Written in C ©1988 Commodore-Amiga, Inc.
*           12/22/90 JL V1.01 Translated into assembly.
*           01/09/91 JL V1.02 Added exit code for more cases.
*****************************************************************************

;Set Tabs           |       |                 |       |

	ifnd	__m68
	fail	'Wrong assembler!'
	endc
	exeobj
	macfile	'Includes:IOexp.i' ;The One & Only include file
	objfile	'ram:ioexp-handler'

DOS_FALSE	equ	0
DOS_TRUE	equ	-1

OpenForInput	equr	d5	;Flag for ?
OpenForOutput	equr	d6	;Flag for ?
Error	equr	d7	;Flag for OpenDevice()

INFO_LEVEL	equ	0	;Assembly-time option

*** Begin mainline

MainStack	clrfo
openstring	fo.l	1	;Ptr to logical device name
node	fo.l	1	;Our device node
inp	fo.b	dp_SIZEOF	;DosPacket
inpkt	fo.l	1	;DosPacket
out	fo.b	dp_SIZEOF	;DosPacket
outpkt	fo.l	1	;DosPacket
readPkt	fo.l	1	;DosPacket
writePkt	fo.l	1	;DosPacket
iob	fo.l	1	;IOStdReq
iobo	fo.l	1	;IOStdReq
devport	fo.l	1	;Process MsgPort
MS_SIZE	foval

IOExpHandler	link.w	a5,#MS_SIZE
	movem.l	d2-d7/a2-a3/a6,-(sp)
	moveq	#0,OpenForInput
	moveq	#0,OpenForOutput
	moveq	#0,Error

	clr.l	(readPkt,a5)
	clr.l	(writePkt,a5)
	clr.l	(iob,a5)

	PUTDEBUG 5,<'handler started'>

	movea.l	(SysBase).w,a6
	movea.l	(ThisTask,a6),a0
	lea	(pr_MsgPort,a0),a0
	move.l	a0,(devport,a5)	;Save ptr to our proc MsgPort

	lea	(inp,a5),a0
	move.l	a0,(inpkt,a5)
	lea	(out,a5),a0
	move.l	a0,(outpkt,a5)

	bsr.w	WaitMsg	;Wait for parm packet

	PUTDEBUG 5,<'Recvd parm packet'>

* Openstring tells which we are supposed to be...PAR1, SER2, etc.

	movea.l	d0,a3
	move.l	(dp_Arg1,a3),d0
	lsl.l	#2,d0
	addq.l	#1,d0	;Skip length byte
	move.l	d0,(openstring,a5)

	ifne	INFO_LEVEL
	move.l	d0,-(sp)
	PUTDEBUG 5,<'openstring = "%s"'>
	addq.w	#4,sp
	endc

	move.l	(dp_Arg3,a3),d0
	lsl.l	#2,d0
	move.l	d0,(node,a5)	;Save ptr to our DeviceNode

	movea.l	(openstring,a5),a0
	lea	(NewSerName,pc),a2
	moveq	#0,d2
	moveq	#IOEXTSER_SIZE,d3
	lea	(SER1name,pc),a1
	bsr.w	strUcmp
	beq.w	FoundName

	moveq	#1,d2
	lea	(SER2name,pc),a1
	bsr.w	strUcmp
	beq.w	FoundName

	moveq	#2,d2
	lea	(SER3name,pc),a1
	bsr.w	strUcmp
	beq.w	FoundName

	moveq	#3,d2
	lea	(SER4name,pc),a1
	bsr.w	strUcmp
	beq.b	FoundName

	lea	(EightBitName,pc),a2
	moveq	#0,d2
	moveq	#IOEXTPar_SIZE,d3
	lea	(PAR1name,pc),a1
	bsr.w	strUcmp
	beq.b	FoundName

	moveq	#1,d2
	lea	(PAR2name,pc),a1
	bsr.w	strUcmp
	beq.b	FoundName

	moveq	#2,d2
	lea	(PAR3name,pc),a1
	bsr.w	strUcmp
	beq.b	FoundName

	moveq	#3,d2
	lea	(PAR4name,pc),a1
	bsr.w	strUcmp
	beq.b	FoundName

	PUTDEBUG 100,<'strUcmp() failed'>

	movea.l	a3,a0	;Not a name we know
	moveq	#DOS_FALSE,d0
	moveq	#(ERROR_ACTION_NOT_KNOWN/2),d1
	add.w	d1,d1
	bra.w	Die

* Set up the input IOReq and the output IOReq

FoundName	move.l	#MEMF_PUBLIC!MEMF_CLEAR,d1
	move.l	d3,d0
	add.l	d0,d0
	SYS	AllocMem
	move.l	d0,(iob,a5)
	bne.b	CreateIOReq

	PUTDEBUG 100,<'AllocMem() failed'>

	movea.l	a3,a0	;Can't get memory
	moveq	#DOS_FALSE,d0
	moveq	#ERROR_NO_FREE_STORE,d1
	bra.w	Die

CreateIOReq	movea.l	d0,a1	;IORequest
	move.b	#NT_MESSAGE,(LN_TYPE,a1)
	move.w	d3,(MN_LENGTH,a1)
	move.l	(devport,a5),(MN_REPLYPORT,a1)
	add.l	d3,d0
	move.l	d0,(iobo,a5)

	movea.l	a2,a0	;Device name
	move.l	d2,d0	;Device unit
	moveq	#0,d1	;Flags
	SYS	OpenDevice
	move.l	d0,Error
	beq.b	CopyIOReq

	PUTDEBUG 5,<'OpenDevice() failed'>

	movea.l	a3,a0	;Multiple readers not allowed
	moveq	#DOS_FALSE,d0
	moveq	#(ERROR_OBJECT_IN_USE/2),d1
	add.w	d1,d1
	bra.w	Die

CopyIOReq	movea.l	(iob,a5),a0
	movea.l	(iobo,a5),a1
	moveq	#(IOSTD_SIZE/4)-1,d1
..	move.l	(a0)+,(a1)+
	dbra	d1,..

* Patch outselves into the system

	PUTDEBUG 5,<'patching outselves into system'>

	movea.l	(outpkt,a5),a0
	move.l	#ACTION_WRITE_RETURN,(dp_Type,a0)
	movea.l	(inpkt,a5),a0
	move.l	#ACTION_READ_RETURN,(dp_Type,a0)
	movea.l	(node,a5),a0
	move.l	(devport,a5),(dn_Task,a0)

* Finished with parameter packet...send back.

	PUTDEBUG 5,<'returning initial packet'>

	movea.l	a3,a0
	moveq	#DOS_TRUE,d0
	move.l	(dp_Res2,a0),d1	;Tell DOS we're all set
	bsr.w	ReturnPkt

	PUTDEBUG 5,<'starting MainLoop'>

***************************************************************************
***                           Main Event Loop                           ***
***************************************************************************

MainLoop	bsr.w	WaitMsg	;Wait for a new DOS packet
	movea.l	d0,a0
	move.l	(dp_Type,a0),d0	;Find what action to perform

	ifne	INFO_LEVEL
	move.l	d0,-(sp)
	PUTDEBUG 5,<'Got new packet = %ld'>
	addq.w	#4,sp
	endc

FindInput	cmpi.l	#ACTION_FINDINPUT,d0
	bne.b	FindOutput
	move.l	(dp_Arg1,a0),d0	;filehandle
	lsl.l	#2,d0
	movea.l	d0,a1

	tst.w	OpenForInput
	beq.b	1$
	moveq	#DOSFALSE,d0	;Multiple readers not allowed
	moveq	#(ERROR_OBJECT_IN_USE/2),d1
	add.w	d1,d1
	bra.b	2$

1$	moveq	#DOS_TRUE,d0
	move.w	d0,OpenForInput
	move.l	d0,(fh_Interactive,a1)	;Now mark as interactive
	move.l	#ACTION_FINDINPUT,(fh_Arg1,a1)
	moveq	#0,d1
2$	bsr.w	ReturnPkt
	bra.w	CheckAction

FindOutput	cmpi.l	#ACTION_FINDOUTPUT,d0
	bne.b	ActionEnd
	move.l	(dp_Arg1,a0),d0	;filehandle
	lsl.l	#2,d0
	movea.l	d0,a1

	tst.w	OpenForOutput
	beq.b	1$
	moveq	#DOSFALSE,d0	;Multiple writers not allowed
	moveq	#(ERROR_OBJECT_IN_USE/2),d1
	add.w	d1,d1
	bra.b	2$

1$	moveq	#DOS_TRUE,d0
	move.w	d0,OpenForOutput
	move.l	d0,(fh_Interactive,a1)	;Now mark as interactive
	move.l	#ACTION_FINDOUTPUT,(fh_Arg1,a1)
	moveq	#0,d1
2$	bsr.w	ReturnPkt
	bra.w	CheckAction

ActionEnd	cmpi.l	#ACTION_END,d0
	bne.b	IntRead
	move.l	(dp_Arg1,a0),d0
	cmpi.l	#ACTION_FINDINPUT,d0
	bne.b	1$
	moveq	#0,OpenForInput
	bra.b	2$

1$	moveq	#0,OpenForOutput

2$	tst.w	OpenForInput
	bne.b	3$
	tst.w	OpenForOutput
	bne.b	3$
	movea.l	(node,a5),a1
	clr.l	(dn_Task,a1)

3$	moveq	#DOSTRUE,d0
	moveq	#0,d1
	bsr.w	ReturnPkt
	bra.w	CheckAction

IntRead	cmpi.l	#ACTION_READ_RETURN,d0
	bne.b	IntWrite
	move.l	a0,(inpkt,a5)
	movea.l	(readPkt,a5),a0
	movea.l	(iob,a5),a1
	bsr.w	handleReturn
	bra.w	CheckAction

IntWrite	cmpi.l	#ACTION_WRITE_RETURN,d0
	bne.b	ActionRead
	move.l	a0,(outpkt,a5)
	movea.l	(writePkt,a5),a0
	movea.l	(iobo,a5),a1
	bsr.w	handleReturn
	bra.w	CheckAction

ActionRead	moveq	#'R',d1
	cmp.l	d1,d0
	bne.b	ActionWrite
	move.l	a0,(readPkt,a5)
	movea.l	(iob,a5),a1
	moveq	#CMD_READ,d0
	movea.l	(inpkt,a5),a2
	bsr.w	handleRequest
	clr.l	(inpkt,a5)
	bra.b	CheckAction

ActionWrite	moveq	#'W',d1
	cmp.l	d1,d0
	bne.b	DefaultAction
	move.l	a0,(writePkt,a5)
	movea.l	(iobo,a5),a1
	moveq	#CMD_WRITE,d0
	movea.l	(outpkt,a5),a2
	bsr.w	handleRequest
	clr.l	(outpkt,a5)
	bra.b	CheckAction

DefaultAction	tst.w	OpenForInput
	bne.b	1$
	tst.w	OpenForOutput
	bne.b	1$
	movea.l	(node,a5),a1
	clr.l	(dn_Task,a1)

1$	moveq	#DOSFALSE,d0	;Default behaviour
	moveq	#(ERROR_ACTION_NOT_KNOWN/2),d1
	add.w	d1,d1
	bsr.w	ReturnPkt

CheckAction	tst.w	OpenForInput
	bne.b	1$
	tst.w	OpenForOutput
	bne.b	1$
	tst.l	(outpkt,a5)
	beq.b	1$
	tst.l	(inpkt,a5)
	bne.b	Exit
1$	bra.w	MainLoop

***************************************************************************
***                          Termination Code                           ***
***************************************************************************

Die	bsr.w	ReturnPkt	;Fall through to Exit

Exit	move.l	(iob,a5),d2
	beq.b	2$
	tst.l	Error
	bne.b	1$
	movea.l	d2,a1
	SYS	CloseDevice

1$	movea.l	d2,a1
	moveq	#0,d0
	move.w	(MN_LENGTH,a1),d0
	add.l	d0,d0
	SYS	FreeMem

* This looks funny, but works because DOS is not part of the code being unloaded

2$	lea	(DosName,pc),a1
	SYS	OldOpenLibrary
	movea.l	a6,a0
	movea.l	d0,a6

	addq.b	#1,(TDNestCnt,a0)
	movea.l	(node,a5),a2
	move.l	(dn_SegList,a2),d1
	SYS	UnLoadSeg

	movea.l	a6,a1
	movea.l	(SysBase).w,a6
	SYS	CloseLibrary

	clr.l	(dn_SegList,a2)

	PUTDEBUG 5,<'exit'>

	movem.l	(sp)+,d2-d7/a2-a3/a6
	unlk	a5
	rts

*****************************************************************************
* NAME:     handleRequest(rp, iob, command, tp)
* FUNCTION: Handle an IO request. Passed command, transmission packet (tp)
*           and request packet (rp). rp contains buffer and length in arg2/3.
* INPUTS:   A0 = Ptr to request packet.
*           A1 = Ptr to IOReq.
*           A2 = Ptr to transmission packet.
*           D0 = Command.
* RETURN:   None
* SCRATCH:  D0-D1/A0-A1
*****************************************************************************

handleRequest	PUTDEBUG 100,<'handleRequest() called'>

	move.w	d0,(IO_COMMAND,a1)
	move.l	(dp_Arg2,a0),(IO_DATA,a1)
	move.l	(dp_Arg3,a0),(IO_LENGTH,a1)
	move.l	a2,(LN_NAME,a1)
	move.l	a1,(dp_Link,a2)
	SYS	SendIO
	rts

*****************************************************************************
* NAME:     handleReturn(packet, iob)
* FUNCTION: Handle a returning IO request. The user request packet is passed
*           as packet, and must be returned with success/failure message.
* INPUTS:   A0 = Ptr to packet.
*           A1 = Ptr to IOReq.
* RETURN:   None
* SCRATCH:  D0-D1/A0-A1
*****************************************************************************

handleReturn	PUTDEBUG 100,<'handleReturn() called'>

	moveq	#0,d1
	move.b	(IO_ERROR,a1),d1
	bne.b	1$
	move.l	(IO_ACTUAL,a1),d0
	moveq	#0,d1
	bra.b	ReturnPkt

1$	moveq	#DOS_TRUE,d0	;Fall thru to ReturnPkt

*****************************************************************************
* NAME:     ReturnPkt(packet, res1 res2)
* FUNCTION: Return a DosPacket with arguments.
* INPUTS:   A0 = Ptr to packet.
*           D0 = Res1.
*           D1 = Res2.
* RETURN:   None
* SCRATCH:  D0-D1/A0-A1
*****************************************************************************

ReturnPkt	PUTDEBUG 100,<'ReturnPkt() called'>

	move.l	a2,-(sp)
	move.l	d0,(dp_Res1,a0)
	move.l	d1,(dp_Res2,a0)
	movea.l	(dp_Port,a0),a2
	move.l	(devport,a5),(a2)
	movea.l	(dp_Link,a0),a1	;Message
	move.l	a0,(LN_NAME,a1)
	clr.l	(LN_SUCC,a1)
	clr.l	(LN_PRED,a1)
	movea.l	a2,a0	;ReplyPort
	SYS	PutMsg
	movea.l	(sp)+,a2
	rts

*****************************************************************************
* NAME:     WaitMsg()
* FUNCTION: Waits for a message to arrive at the port and returns
*           the packet address.
* INPUTS:   None
* RETURN:   D0 = Ptr to Packet.
* SCRATCH:  D0-D1/A0-A1
*****************************************************************************

WaitMsg	PUTDEBUG 100,<'WaitMsg() called'>

	move.l	#1<<8,d2
	moveq	#0,d0
	move.l	d2,d1
	SYS	SetSignal
	bra.b	2$

1$	move.l	d2,d0
	SYS	Wait

2$	movea.l	(devport,a5),a0
	SYS	GetMsg
	tst.l	d0
	beq.b	1$
	movea.l	d0,a0
	move.l	(LN_NAME,a0),d0
	rts

*****************************************************************************
* NAME:     strUcmp(str1, str2)
* FUNCTION: Compare U/C chars of string1 and string2.
* INPUTS:   A0 = String1 (preserved).
*           A1 = String2
* RETURN:   Z  = 1 if strings are equal, else Z = 0.
* SCRATCH:  D0-D1/A1
*****************************************************************************

strUcmp	move.l	a0,-(sp)
1$	move.b	(a0)+,d0
	cmpi.b	#'a',d0
	blo.s	2$
	cmpi.b	#'z',d0
	bhi.s	2$
	subi.b	#$20,d0
2$	move.b	(a1)+,d1
	cmp.b	d0,d1
	bne.s	3$
	tst.b	(-1,a1)
	bne.b	1$
3$	movea.l	(sp)+,a0
	rts

	ISDEBUG	'handler'	;This name for debugging use

DosName	cstr	'dos.library'
NewSerName	MYDEVNAME
EightBitName	PARDEVNAME
SER1name	MYUNITNAME1
SER2name	MYUNITNAME2
SER3name	MYUNITNAME3
SER4name	MYUNITNAME4
PAR1name	PARUNITNAME1
PAR2name	PARUNITNAME2
PAR3name	PARUNITNAME3
PAR4name	PARUNITNAME4

	end
