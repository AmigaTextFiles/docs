MYDEVNAME       MACRO
                DC.B    'ahd.device',0
                ENDM

FASTBOOT        equ     1      ;If defined ahd will not reset controller
                                ;at boottime

        SECTION section

        NOLIST
        include "exec/types.i"
        include "exec/nodes.i"
        include "exec/lists.i"
        include "exec/libraries.i"
        include "exec/devices.i"
        include "exec/io.i"
        include "exec/alerts.i"
        include "exec/initializers.i"
        include "exec/memory.i"
        include "exec/resident.i"
        include "exec/ables.i"
        include "exec/errors.i"
        include "exec/tasks.i"
        include "libraries/expansionbase.i"
        include "libraries/expansion.i"
        include "libraries/configvars.i"
        include "libraries/configregs.i"
        include "libraries/romboot_base.i"

        include "asmsupp.i"
        include "messages.i"

        include "mydev.i"

        xdef    myName
        xdef    subSysName
        XREF    _AbsExecBase

;
; Imports from assembly module hdif.asm
;

        XREF    Read
        XREF    Write
        XREF    FormatTrk
        XREF    doreset
        XREF    doinit
        XREF    doseek
        XREF    readsec
        XREF    doerror
        XREF    putchar
        XREF    puthex
        XREF    hdconfig
        XREF    _inbuffer

;
; Imports from C module auto.c
;

        XREF    _config

;
; Imports from assembly module cdeb.asm
;

        XREF    _SysBase

;
; Imports for this module
;

        XLIB    AddDevice
        XLIB    Enqueue
        XLIB    AddIntServer
        XLIB    RemIntServer
        XLIB    Debug
        XLIB    InitStruct
        XLIB    MakeLibrary
        XLIB    OpenLibrary
        XLIB    CloseLibrary
        XLIB    Alert
        XLIB    FreeMem
        XLIB    Remove
        XLIB    AllocMem
        XLIB    AddTask
        XLIB    PutMsg
        XLIB    RemTask
        XLIB    ReplyMsg
        XLIB    Signal
        XLIB    GetMsg
        XLIB    Wait
        XLIB    WaitPort
        XLIB    AllocSignal
        XLIB    SetTaskPri
        XLIB    GetCurrentBinding       ; Get list of boards for this driver
        XLIB    MakeDosNode
        XLIB    AddDosNode

        INT_ABLES


        ; The first executable location.  This should return an error
        ; in case someone tried to run you as a program (instead of
        ; loading you as a library).
FirstAddress:
        CLEAR   d0
        rts

;-----------------------------------------------------------------------
; A romtag structure.  Both "exec" and "ramlib" look for
; this structure to discover magic constants about you
; (such as where to start running you from...).
;-----------------------------------------------------------------------

        ; Most people will not need a priority and should leave it at zero.
        ; the RT_PRI field is used for configuring the roms.  Use "mods" from
        ; wack to look at the other romtags in the system
MYPRI   EQU     20

initDDescrip:
                                        ;STRUCTURE RT,0
          DC.W    RTC_MATCHWORD         ; UWORD RT_MATCHWORD
          DC.L    initDDescrip          ; APTR  RT_MATCHTAG
          DC.L    EndCode               ; APTR  RT_ENDSKIP
          dc.b    RTF_AUTOINIT
          DC.B    VERSION               ; UBYTE RT_VERSION
          DC.B    NT_DEVICE             ; UBYTE RT_TYPE
          DC.B    MYPRI                 ; BYTE  RT_PRI
          DC.L    myName                ; APTR  RT_NAME
          DC.L    idString              ; APTR  RT_IDSTRING
          DC.L    Init                  ; APTR  RT_INIT
                                        ; LABEL RT_SIZE


        ; this is the name that the device will have
_myName:          ; For C
subSysName:
myName:         MYDEVNAME

        ; a major version number.
VERSION:        EQU     1

        ; A particular revision.  This should uniquely identify the bits in the
        ; device.  I use a script that advances the revision number each time
        ; I recompile.  That way there is never a question of which device
        ; that really is.
REVISION:       EQU     2

        ; this is an identifier tag to help in supporting the device
        ; format is 'name version.revision (dd MON yyyy)',<cr>,<lf>,<null>
idString:       dc.b    'ahd.device 1.2 (10 Oct 1988)',13,10,0

        ; force word allignment

        cnop    0,4

        ; The romtag specified that we were "RTF_AUTOINIT".  This means
        ; that the RT_INIT structure member points to one of these
        ; tables below.  If the AUTOINIT bit was not set then RT_INIT
        ; would point to a routine to run.

Init:
        DC.L    MyDev_Sizeof            ; data space size
        DC.L    funcTable               ; pointer to function initializers
        DC.L    dataTable               ; pointer to data initializers
        DC.L    initRoutine             ; routine to run


funcTable:

        ;------ standard system routines
        dc.l    Open
        dc.l    Close
        dc.l    Expunge
        dc.l    Null

        ;------ my device definitions
        dc.l    BeginIO
        dc.l    AbortIO

        ;------ function table end marker
        dc.l    -1


        ; The data table initializes static data structures.
        ; The format is specified in exec/InitStruct routine's
        ; manual pages.  The INITBYTE/INITWORD/INITLONG routines
        ; are in the file "exec/initializers.i".  The first argument
        ; is the offset from the device base for this byte/word/long.
        ; The second argument is the value to put in that cell.
        ; The table is null terminated
dataTable:
        INITBYTE        LH_TYPE,NT_DEVICE
        INITLONG        LN_NAME,myName
        INITBYTE        LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
        INITWORD        LIB_VERSION,VERSION
        INITWORD        LIB_REVISION,REVISION
        INITLONG        LIB_IDSTRING,idString
        DC.L    0


        ; This routine gets called after the device has been allocated.
        ; The device pointer is in D0.  The segment list is in a0.
        ; If it returns non-zero then the device will be linked into
        ; the device list.
initRoutine:

; Register Usage
; ==============
; a3 -- Points to tempory RAM
; a4 -- Expansion library base
; a5 -- device pointer
; a6 -- Exec base
;
;----------------------------------------------------------------------
        ;------ get the device pointer into a convenient A register
        PUTMSG  80,<'--- %s/Init: called'>
        movem.l d1-d7/a0-a5,-(sp)       ; Preserve ALL modified registers
        move.l  d0,a5

        ;------ save a pointer to exec
        move.l  a6,md_SysLib(a5)
        move.l  a6,_SysBase

        ;------ save a pointer to our loaded code
        move.l  a0,md_SegList(a5)

        ; You would normally set d0 to a NULL if your initialization failed,
        ; but I'm not doing that for this demo, since it is unlikely
        ; you actually have a board with this particular manufacturer ID
        ; installed when running this demo.
        ;

        DMPNL   10
        moveq   #0,d3           ; Default device is drive 0

        ifd     FASTBOOT

        lea     _inbuffer,a2    ; Try to read sec 0 off of that drive
        move.l  #0,d0
        move.l  #512,d1
        bsr     readsec
        beq.s   awake           ; If controller already awake - yahoo

        endc

        bsr     doreset         ; Reset the drive if hung
        bne     ir_int

        lea     _inbuffer,a2    ; Try to read sec 0 off of that drive
        move.l  #0,d0
        move.l  #512,d1
        bsr     readsec
        bne.s   noparms         ; If sec 0 gives error - boot with default

awake:
        PUTMSG  5,<'Reading config data'>
        lea     _inbuffer,a0
        bsr     hdconfig        ; Set parms as read
noparms:
        bsr     doinit          ; Send drive parms
        bne.s   ir_int

        bsr     _config

        PUTMSG  80,<'%s/Init: succeeded'>
        move.l  a5,d0
        movem.l (sp)+,d1-d7/a0-a5
        rts
ir_int:
        PUTMSG  80,<'%s/Init: failed'>
        move.l  #0,d0
        movem.l (sp)+,d1-d7/a0-a5
        rts

;----------------------------------------------------------------------
;
; here begins the system interface commands.  When the user calls
; OpenLibrary/CloseLibrary/RemoveLibrary, this eventually gets translated
; into a call to the following routines (Open/Close/Expunge).  Exec
; has already put our device pointer in a6 for us.  Exec has turned
; off task switching while in these routines (via Forbid/Permit), so
; we should not take too long in them.
;
;----------------------------------------------------------------------


        ; Open sets the IO_ERROR field on an error.  If it was successfull,
        ; we should set up the IO_UNIT field.

Open:           ; ( device:a6, iob:a1, unitnum:d0, flags:d1 )
        PUTMSG  80,<'%s/Open: called'>
        movem.l d2/a2/a3/a5,-(sp)

        move.l  a1,a2           ; save the iob

        ;------ see if the unit number is in range
        subq    #1,d0           ; Unit ZERO isn't allowed
        cmp.l   #MD_NUMUNITS,d0
        bcc.s   Open_Error      ; unit number out of range

        ;------ see if the unit is already initialized
        move.l  d0,d2           ; save unit number
        lsl.l   #2,d0
        lea.l   md_Units(a6,d0.l),a5
        move.l  (a5),d0
        bne.s   Open_UnitOK

        ;------ try and conjure up a unit
        bsr     InitUnit

        ;------ see if it initialized OK
        move.l  (a5),d0
        beq.s   Open_Error

Open_UnitOK:
        move.l  d0,a3           ; unit pointer in a3

        move.l  d0,IO_UNIT(a2)

        ;------ mark us as having another opener
        addq.w  #1,LIB_OPENCNT(a6)
        addq.w  #1,UNIT_OPENCNT(a3)

        ;------ prevent delayed expunges
        bclr    #LIBB_DELEXP,md_Flags(a6)
        moveq.l #0,d0

Open_End:

        movem.l (sp)+,d2/a2/a3/a5
        PUTMSG  80,<'Open - End'>
        rts

Open_Error:
        move.b  #IOERR_OPENFAIL,IO_ERROR(a2)
        move.b  #IOERR_OPENFAIL,d0
        bra.s   Open_End

        ; There are two different things that might be returned from
        ; the Close routine.  If the device is no longer open and
        ; there is a delayed expunge then Close should return the
        ; segment list (as given to Init).  Otherwise close should
        ; return NULL.

Close:          ; ( device:a6, iob:a1 )
        movem.l d1/a2-a3,-(sp)
        PUTMSG  80,<'%s/Close: called'>

        move.l  a1,a2

        move.l  IO_UNIT(a2),a3

        ;------ make sure the iob is not used again
        moveq.l #-1,d0
        move.l  d0,IO_UNIT(a2)
        move.l  d0,IO_DEVICE(a2)

        ;------ see if the unit is still in use
        subq.w  #1,UNIT_OPENCNT(a3)

;        bne.s   Close_Device
;        bsr     ExpungeUnit

Close_Device:
        ;------ mark us as having one fewer openers
        moveq.l #0,d0
        subq.w  #1,LIB_OPENCNT(a6)

        ;------ see if there is anyone left with us open
        bne.s   Close_End

        ;------ see if we have a delayed expunge pending
        btst    #LIBB_DELEXP,md_Flags(a6)
        beq.s   Close_End

        ;------ do the expunge
        bsr     Expunge

Close_End:
        movem.l (sp)+,d1/a2-a3
        rts


        ; There are two different things that might be returned from
        ; the Expunge routine.  If the device is no longer open
        ; then Expunge should return the segment list (as given to
        ; Init).  Otherwise Expunge should set the delayed expunge
        ; flag and return NULL.
        ;
        ; One other important note: because Expunge is called from
        ; the memory allocator, it may NEVER Wait() or otherwise
        ; take long time to complete.

Expunge:        ; ( device: a6 )
        PUTMSG  80,<'%s/Expunge: called'>

        movem.l d1/d2/a5/a6,-(sp)       ; Best to save ALL modified registers
        move.l  a6,a5
        move.l  md_SysLib(a5),a6

        ;------ see if anyone has us open
        tst.w   LIB_OPENCNT(a5)
;        beq     1$

        ;------ it is still open.  set the delayed expunge flag
        bset    #LIBB_DELEXP,md_Flags(a5)
        CLEAR   d0
        bra.s   Expunge_End

1$:
        ;------ go ahead and get rid of us.  Store our seglist in d2
        move.l  md_SegList(a5),d2

        ;------ unlink from device list
        move.l  a5,a1
        CALLSYS Remove

        ;
        ; device specific closings here...
        ;

        ;------ free our memory
        CLEAR   d0
        CLEAR   d1
        move.l  a5,a1
        move.w  LIB_NEGSIZE(a5),d1

        sub.w   d1,a1
        add.w   LIB_POSSIZE(a5),d0
        add.l   d1,d0

        CALLSYS FreeMem

        ;------ set up our return value
        move.l  d2,d0

Expunge_End:
        movem.l (sp)+,d1/d2/a5/a6
        rts


Null:
        PUTMSG  30,<'%s/Null: called'>
        CLEAR   d0
        rts


InitUnit:       ; ( d2:unit number, a3:scratch, a6:devptr )
        PUTMSG  80,<'%s/InitUnit: called'>
        movem.l d2-d4/a2/a4,-(sp)

        ;------ allocate unit memory
        move.l  #MyDevUnit_Sizeof,d0
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        LINKSYS AllocMem,md_SysLib(a6)

        tst.l   d0
        beq     InitUnit_End

        PUTMSG  80,<'Allocated memory for Unit ok'>

        move.l  d0,a3
        move.b  d2,mdu_UnitNum(a3)      ; initialize unit number
        move.l  a6,mdu_Device(a3)       ; initialize device pointer

        tst.l   d2
        bne.s   iu_Unit1
        move.b  #0,mdu_UnitMask(a3)
        bra.s   iu_Unit2
iu_Unit1:
        move.b  #$20,mdu_UnitMask(a3)
iu_Unit2:

        tst.l   md_Process(a6)
        bne     iu_NoProc

        ;------ start up the unit process.  We do a trick here --
        ;------ we set his message port to PA_IGNORE until the
        ;------ new process has a change to set it up.
        ;------ We cannot go to sleep here: it would be very nasty
        ;------ if someone else tried to open the unit
        ;------ (exec's OpenDevice has done a Forbid() for us --
        ;------ we depend on this to become single threaded).

        move.l  #MyProc_Sizeof,d0
        move.l  #MEMF_PUBLIC!MEMF_CLEAR,d1
        LINKSYS AllocMem,md_SysLib(a6)

        move.l  d0,a4
        move.l  a4,md_Process(a6)

        ;------ Initialize the stack information
        lea     mp_stack(a4),a0        ; Low end of stack
        move.l  a0,mp_tcb+TC_SPLOWER(a4)
        lea     MYPROCSTACKSIZE(a0),a0  ; High end of stack
        move.l  a0,mp_tcb+TC_SPUPPER(a4)
        move.l  a6,-(A0)                ; argument -- device ptr
        move.l  a0,mp_tcb+TC_SPREG(a4)
        ;------ initialize the unit's list
        lea     MP_MSGLIST(a4),a0
        NEWLIST a0
        lea     mp_tcb(a4),a0
        move.l  a0,MP_SIGTASK(a4)
        moveq.l #0,d0                   ; Don't need to re-zero it
        move.l  a4,a2                   ; InitStruct is initializing the UNIT
        lea.l   mdu_Init,A1
        LINKSYS InitStruct,md_SysLib(a6)

        move.l  a4,mp_is+IS_DATA(a4)   ; Pass int. server unit addr.

;       Startup the task
        lea     mp_tcb(a4),a1
        lea     Proc_Begin(PC),a2
        move.l  a4,-(sp)                ; Preserve UNIT pointer
        lea     -1,a4                   ; generate address error
                                        ; if task ever "returns"
        CLEAR   d0
        LINKSYS AddTask,md_SysLib(a6)
        move.l  (sp)+,a4                ; restore UNIT pointer

        PUTMSG  80,<'AddTask done'>

iu_NoProc:
        ;------ mark us as ready to go
        move.l  d2,d0                   ; unit number
        lsl.l   #2,d0
        move.l  a3,md_Units(a6,d0.l)    ; set unit table


InitUnit_End:
        movem.l (sp)+,d2-d4/a2/a4
        rts

        ;------ got an error.  free the unit structure that we allocated.
InitUnit_FreeUnit:
        bsr     FreeUnit
        bra.s   InitUnit_End

FreeUnit:       ; ( a3:unitptr, a6:deviceptr )
        move.l  a3,a1
        move.l  #MyDevUnit_Sizeof,d0
        LINKSYS FreeMem,md_SysLib(a6)
        rts


ExpungeUnit:    ; ( a3:unitptr, a6:deviceptr )
        PUTMSG  80,<'%s/ExpungeUnit: called'>
        move.l  d2,-(sp)

        move.l  md_Process(a6),a4
;
; If you can expunge you unit, and each unit has it's own interrups,
; you must remember to remove its interrupt server
;

        IFD     INTRRUPT
        lea.l   mp_is(a4),a1           ; Point to interrupt structure
        moveq   #3,d0                   ; Portia interrupt bit 3
        LINKSYS RemIntServer,md_SysLib(a6) ;Now remove the interrupt server
        ENDC

        ;------ get rid of the unit's task.  We know this is safe
        ;------ because the unit has an open count of zero, so it
        ;------ is 'guaranteed' not in use.
        lea     mp_tcb(a4),a1
        LINKSYS RemTask,md_SysLib(a6)

        ;------ save the unit number
        CLEAR   d2
        move.b  mdu_UnitNum(a3),d2

        ;------ free the unit structure.
        bsr     FreeUnit

        ;------ clear out the unit vector in the device
        lsl.l   #2,d2
        clr.l   md_Units(a6,d2.l)

        move.l  (sp)+,d2

        rts

;----------------------------------------------------------------------
;
; here begins the device specific functions
;
;----------------------------------------------------------------------

; cmdtable is used to look up the address of a routine that will
; implement the device command.
cmdtable:
        DC.L    Invalid         ; $00000001
        DC.L    MyReset         ; $00000002
        DC.L    hdRead          ; $00000004     Common routine for read/write
        DC.L    hdWrite         ; $00000008
        DC.L    Update          ; $00000010
        DC.L    Clear           ; $00000020
        DC.L    MyStop          ; $00000040
        DC.L    Start           ; $00000080
        DC.L    Flush           ; $00000100
        DC.L    Motor           ; $00000200  motor      (NO-OP)
        DC.L    Seek            ; $00000400  seek       (NO-OP)
        DC.L    hdFormat        ; $00000800  format -> WRITE for RAMDISK
        DC.L    MyRemove        ; $00001000  remove             (NO-OP)
        DC.L    ChangeNum       ; $00002000  changenum          (Returns 0)
        DC.L    ChangeState     ; $00004000  changestate        (Returns 0)
        DC.L    ProtStatus      ; $00008000  protstatus         (Returns 0)
        DC.L    RawRead         ; Not supported (INVALID)
        DC.L    RawWrite        ; Not supported (INVALID)
        DC.L    GetDriveType    ; Get drive type        (Returns 1)
        DC.L    GetNumTracks    ; Get number of tracks (Returns NUMTRKS)
        DC.L    AddChangeInt    ; Add disk change interrupt (NO-OP)
        DC.L    RemChangeInt    ; Remove disk change interrupt ( NO-OP)
        dc.l    ReadConfig      ; Read config from io_Data
cmdtable_end:

; this define is used to tell which commands should not be queued
; command zero is bit zero.
; The immediate commands are Invalid, Reset, Stop, Start, Flush
IMMEDIATES      EQU     $000001c3

; These commands can NEVER be done "immediately" if using interrupts,
; since they would "wait" for the interrupt forever!
; Read, Write, Format
NEVERIMMED      EQU     $0040080C

; BeginIO starts all incoming io.  The IO is either queued up for the
; unit task or processed immediately.
;

BeginIO:        ; ( iob: a1, device:a6 )
        PUTMSG  80,<'%s/BeginIO: called'>
        movem.l d1/a0/a3/a4,-(sp)

        ;------ bookkeeping
        move.l  IO_UNIT(a1),a3
        move.l  md_Process(a6),a4

        ;------ see if the io command is within range
        move.w  IO_COMMAND(a1),d0
        cmp.w   #MYDEV_END,d0
        bcc     BeginIO_NoCmd

        DISABLE a0

        ;------ process all immediate commands no matter what
        move.l  #IMMEDIATES,d1
        btst    d0,d1
        bne.s   BeginIO_Immediate

        IFD     INTRRUPT        ; if using interrupts,
        ;------ queue all NEVERIMMED commands no matter what
        move.l  #NEVERIMMED,d1
        btst    d0,d1
        bne.s   BeginIO_QueueMsg
        ENDC

        ;------ see if the unit is STOPPED.  If so, queue the msg.
        btst    #MDUB_STOPPED,UNIT_FLAGS(a4)
        bne.s   BeginIO_QueueMsg

        ;------ this is not an immediate command.  see if the device is
        ;------ busy.
        bset    #UNITB_ACTIVE,UNIT_FLAGS(a4)
        beq.s   BeginIO_Immediate

        ;------ we need to queue the device.  mark us as needing
        ;------ task attention.  Clear the quick flag
BeginIO_QueueMsg:
        BSET    #UNITB_INTASK,UNIT_FLAGS(a4)
        bclr    #IOB_QUICK,IO_FLAGS(a1)

        ENABLE  a0

        move.l  a4,a0
        LINKSYS PutMsg,md_SysLib(a6)
        bra     BeginIO_End

BeginIO_Immediate:
        ENABLE  a0

        bsr     PerformIO

BeginIO_End:
        movem.l (sp)+,d1/a0/a3/a4
        rts

BeginIO_NoCmd:
        move.b  #IOERR_NOCMD,IO_ERROR(a1)
        bra.s   BeginIO_End


;
; PerformIO actually dispatches an io request.  It expects a3 to already
; have the unit pointer in it.  a6 has the device pointer (as always).
; a1 has the io request.  Bounds checking has already been done on
; the io request.
;

PerformIO:      ; ( iob:a1, unitptr:a3, devptr:a6 )
        PUTMSG  80,<'PerformIO: called'>
        move.l  a2,-(sp)
        move.l  a1,a2

        clr.b   IO_ERROR(A2)            ; No error so far
        move.w  IO_COMMAND(a2),d0
        lsl     #2,d0                   ; Multiply by 4 to get table offset
        lea     cmdtable(pc),a0
        move.l  0(a0,d0.w),a0

        jsr     (a0)

        move.l  (sp)+,a2
        rts

;
; TermIO sends the IO request back to the user.  It knows not to mark
; the device as inactive if this was an immediate request or if the
; request was started from the server task.
;

TermIO:         ; ( iob:a1, unitptr:a3, devptr:a6 )
        PUTMSG  80,<'%s/TermIO: called'>
        move.w  IO_COMMAND(a1),d0
        move.w  #IMMEDIATES,d1
        btst    d0,d1
        bne.s   TermIO_Immediate

        ;------ we may need to turn the active bit off.
        btst    #UNITB_INTASK,UNIT_FLAGS(a4)
        bne.s   TermIO_Immediate

        ;------ the task does not have more work to do
        bclr    #UNITB_ACTIVE,UNIT_FLAGS(a4)

TermIO_Immediate:
        ;------ if the quick bit is still set then we don't need to reply
        ;------ msg -- just return to the user.
        btst    #IOB_QUICK,IO_FLAGS(a1)
        bne.s   TermIO_End

        LINKSYS ReplyMsg,md_SysLib(a6)

TermIO_End:
        rts


        ; ( iob: a1, device:a6 )
;----------------------------------------------------------------------
;
; here begins the functions that implement the device commands
; all functions are called with:
;       a1 -- a pointer to the io request block
;       a2 -- another pointer to the iob
;       a3 -- a pointer to the unit
;       a6 -- a pointer to the device
;
; Commands that conflict with 68000 instructions have a "My" prepended
; to them.
;----------------------------------------------------------------------
AbortIO:
RawRead:                ; 10 Not supported      (INVALID)
RawWrite:               ; 11 Not supported      (INVALID)
Invalid:
        move.b  #IOERR_NOCMD,IO_ERROR(a1)
        bsr     TermIO
        rts

MyReset:
AddChangeInt:
RemChangeInt:
MyRemove:
Seek:
Motor:
ChangeNum:
ChangeState:
ProtStatus:
        clr.l   IO_ACTUAL(a1)   ; Indicate drive isn't protected
        bsr     TermIO
        rts

GetDriveType:
        move.l  #1,IO_ACTUAL(a1)                ; Make it look like 3.5"
        bsr     TermIO
        rts

GetNumTracks:
        move.l  #615,IO_ACTUAL(a1)     ; Number of 10 sector tracks
        bsr     TermIO
        rts

hdRead:
        movem.l d0-d7/a0-a6,-(sp)
        move.b  mdu_UnitMask(a3),d3
        PUTMSG  30,<'hdRead: called'>
        bsr     Read
        movem.l (sp)+,d0-d7/a0-a6
        bsr     TermIO
        rts
hdWrite:
        movem.l d0-d7/a0-a6,-(sp)
        move.b  mdu_UnitMask(a3),d3
        PUTMSG  30,<'hdWrite: called'>
        bsr     Write
        movem.l (sp)+,d0-d7/a0-a6
        bsr     TermIO
        rts
hdFormat:
        movem.l d0-d7/a0-a6,-(sp)
        PUTMSG  30,<'hdFormat: called'>
        move.b  mdu_UnitMask(a3),d3
        bsr     FormatTrk
        movem.l (sp)+,d0-d7/a0-a6
        bsr     TermIO
        rts

ReadConfig:
        movem.l d0-d7/a0-a6,-(sp)
        PUTMSG  30,<'ReadConfig: called'>
        move.l  IO_DATA(a1),a0
        move.b  mdu_UnitMask(a3),d3
        bsr     hdconfig
        bsr     doreset
        bsr     doinit
        movem.l (sp)+,d0-d7/a0-a6
        bsr     TermIO
        rts
;
; Update and Clear are internal buffering commands.  Update forces all
; io out to its final resting spot, and does not return until this is
; done.  Clear invalidates all internal buffers.  Since this device
; has no internal buffers, these commands do not apply.
;

Update:
        PUTMSG  80,<'%s/Update: called'>
        bra     Invalid
Clear:
        PUTMSG  80,<'%s/Clear: called'>
        bra     Invalid

;
; the Stop command stop all future io requests from being
; processed until a Start command is received.  The Stop
; command is NOT stackable: e.g. no matter how many stops
; have been issued, it only takes one Start to restart
; processing.
;

MyStop:
        PUTMSG  80,<'%s/MyStop: called'>
        bset    #MDUB_STOPPED,UNIT_FLAGS(a4)

        bsr     TermIO
        rts

Start:
        PUTMSG  80,<'%s/Start: called'>
        bsr     InternalStart

        move.l  a2,a1
        bsr     TermIO

        rts

InternalStart:
        ;------ turn processing back on
        bclr    #MDUB_STOPPED,UNIT_FLAGS(a4)

        ;------ kick the task to start it moving
        move.l  a4,a1
        CLEAR   d0
        move.l  MP_SIGBIT(a4),d1
        bset    d1,d0
        LINKSYS Signal,md_SysLib(a6)

        rts

;
; Flush pulls all io requests off the queue and sends them back.
; We must be careful not to destroy work in progress, and also
; that we do not let some io requests slip by.
;
; Some funny magic goes on with the STOPPED bit in here.  Stop is
; defined as not being reentrant.  We therefore save the old state
; of the bit and then restore it later.  This keeps us from
; needing to DISABLE in flush.  It also fails miserably if someone
; does a start in the middle of a flush.
;

Flush:
        PUTMSG  80,<'%s/Flush: called'>
        movem.l d2/a6,-(sp)

        move.l  md_SysLib(a6),a6

        bset    #MDUB_STOPPED,UNIT_FLAGS(a4)
        sne     d2

Flush_Loop:
        move.l  a4,a0
        CALLSYS GetMsg

        tst.l   d0
        beq.s   Flush_End

        move.l  d0,a1
        move.b  #IOERR_ABORTED,IO_ERROR(a1)
        CALLSYS ReplyMsg

        bra.s   Flush_Loop

Flush_End:

        move.l  d2,d0
        movem.l (sp)+,d2/a6

        tst.b   d0
        beq.s   1$

        bsr     InternalStart
1$:

        move.l  a2,a1
        bsr     TermIO

        rts

;
; Foo and Bar are two device specific commands that are provided just
; to show you how to add your own commands.  The currently return that
; no work was done.
;

Foo:
Bar:
        CLEAR   d0
        move.l  d0,IO_ACTUAL(a1)

        bsr     TermIO
        rts

;----------------------------------------------------------------------
;
; here begins the process related routines
;
; A Process is provided so that queued requests may be processed at
; a later time.
;
;
; Register Usage
; ==============
; a3 -- unit pointer
; a6 -- syslib pointer
; a5 -- device pointer
; a4 -- task (NOT process) pointer
; d7 -- wait mask
;
;----------------------------------------------------------------------

; some dos magic.  A process is started at the first executable address
; after a segment list.  We hand craft a segment list here.  See the
; the DOS technical reference if you really need to know more about this.

        cnop    0,4                     ; long word allign
        DC.L    16                      ; segment length -- any number will do
myproc_seglist:
        DC.L    0                       ; pointer to next segment

; the next instruction after the segment list is the first executable address

Proc_Begin:

        move.l  _AbsExecBase,a6

        PUTMSG  80,<'Process started'>

        ;------ Grab the argument
        move.l  4(sp),a5                ; Unit pointer

        move.l  md_Process(a5),a4       ; Point to device structure

        IFD     INTRRUPT
        ;------ Allocate a signal for "I/O Complete" interrupts
        moveq   #-1,d0                  ; -1 is any signal at all
        CALLSYS AllocSignal
        move.b  d0,mp_SigBit(A4)       ; Save in unit structure

        moveq   #0,d7                   ; Convert bit number signal mask
        bset    d0,d7
        move.l  d7,mp_SigMask(A4)      ; Save in unit structure

        lea.l   mp_is(a4),a1           ; Point to interrupt structure
        moveq   #3,d0                   ; Portia interrupt bit 3
        CALLSYS AddIntServer            ; Now install the server

        move.l  md_Base(a5),a0          ; Get board base address
        bset.b  #INTENABLE,INTCTRL2(a0) ; Enable interrupts
        ENDC

        ;------ Allocate the right signal

        moveq   #-1,d0                  ; -1 is any signal at all
        CALLSYS AllocSignal

        move.b  d0,MP_SIGBIT(a4)
        move.b  #PA_SIGNAL,MP_FLAGS(a4)

        ;------ change the bit number into a mask, and save in d7

        moveq   #0,d7
        bset    d0,d7

        ;------
        ;------ OK, kids, we are done with initialization.  We now
        ;------ can start the main loop of the driver.  It goes
        ;------ like this.  Because we had the port marked PA_IGNORE
        ;------ for a while (in InitUnit) we jump to the getmsg
        ;------ code on entry.
        ;------
        ;------         wait for a message
        ;------         lock the device
        ;------         get a message.  if no message unlock device and loop
        ;------         dispatch the message
        ;------         loop back to get a message
        ;------

        bra.s   Proc_CheckStatus

        ;------ main loop: wait for a new message
Proc_MainLoop:
        PUTMSG  80,<'Process waiting'>
        move.l  d7,d0
        CALLSYS Wait

Proc_CheckStatus:
        ;------ see if we are stopped
        btst    #MDUB_STOPPED,UNIT_FLAGS(a4)
        bne.s   Proc_MainLoop           ; device is stopped

        ;------ lock the device
        bset    #UNITB_ACTIVE,UNIT_FLAGS(a4)
        bne.s   Proc_MainLoop           ; device in use

        ;------ get the next request
Proc_NextMessage:
        move.l  a4,a0
        CALLSYS GetMsg
        tst.l   d0
        beq.s   Proc_Unlock             ; no message?

        ;------ do this request
        move.l  d0,a1
        move.l  IO_UNIT(a1),a3
        exg     a5,a6                   ; put device ptr in right place
        bsr     PerformIO
        exg     a5,a6                   ; get syslib back in a6

        bra.s   Proc_NextMessage

        ;------ no more messages.  back ourselves out.
Proc_Unlock:
        and.b   #$ff&(~(UNITF_ACTIVE!UNITF_INTASK)),UNIT_FLAGS(a4)
        bra     Proc_MainLoop

;
; Here is a dummy interrupt handler, with some crucial components commented
; out.  If the IFD INTRRUPT is enabled, this code will cause the device to
; wait for a level two interrupt before it will process each request
; (pressing a key on the keyboard will do it).  This code is normally
; disabled, and must fake or omit certain operations since there  isn't
; really any hardware for this driver.  Similiar code has been used
; successfully in other, "REAL" device drivers.
;

        IFD     INTRRUPT
;       A1 should be pointing to the unit structure upon entry!

myintr:         move.l  mdu_Device(a1),a0       ; Get device pointer
                move.l  md_SysLib(a0),a6        ; Get pointer to system
                move.l  md_Base(a0),a0          ; point to board base address
                btst.b  #IAMPULLING,INTCTRL1(a0);See if I'm interrupting
                beq.s   myexnm                  ; if not set, exit, not mine
                move.b  #0,INTACK(a0)           ; toggle controller's int2 bit

;               ------ signal the task that an interrupt has occured

                move.l  mdu_SigMask(a1),d0
                lea     mdu_tcb(a1),a1
                CALLSYS Signal

;
;               now clear the zero condition code so that
;               the interrupt handler doesn't call the next
;               interrupt server.
;
                moveq   #1,d0                   clear zero flag
                bra.s   myexit                  now exit
;
;               this exit point sets the zero condition code
;               so the interrupt handler will try the next server
;               in the interrupt chain
;
myexnm          moveq   #0,d0                   set zero condition code
;
myexit          rts
        ENDC

mdu_Init:
;       ------ Initialize the device

        INITBYTE        MP_FLAGS,PA_IGNORE
        INITBYTE        LN_TYPE,NT_DEVICE
        INITLONG        LN_NAME,myName
        INITBYTE        mp_Msg+LN_TYPE,NT_MSGPORT;Unit starts with MsgPort
        INITLONG        mp_Msg+LN_NAME,myName
        INITLONG        mp_tcb+LN_NAME,myName
        INITBYTE        mp_tcb+LN_TYPE,NT_TASK
        INITBYTE        mp_tcb+LN_PRI,5
        INITBYTE        mp_is+LN_PRI,4         ; Int priority 4
        IFD     INTRRUPT
        INITLONG        mp_is+IS_CODE,myintr   ; Interrupt routine addr
        ENDC
        INITLONG        mp_is+LN_NAME,myName
        DC.L    0

*mdn_Init:
*       ;------ Initialize packet for MakeDosNode

        INITLONG        mdn_execName,myName     ; Address of driver name
        INITLONG        mdn_tableSize,11        ; # long words in AmigaDOS env.
        INITLONG        mdn_dName,$52414d00     ; Store 'RAM' in name
        INITLONG        mdn_sizeBlock,128       ; # longwords in a block
        INITLONG        mdn_numHeads,1          ; RAM disk has only one "head"
        INITLONG        mdn_secsPerBlk,1        ; secs/logical block, must = "1"
        INITLONG        mdn_blkTrack,10         ; secs/track (must be reasonable)
        INITLONG        mdn_resBlks,1           ; reserved blocks, MUST > 0!
        INITLONG        mdn_upperCyl,615        ; upper cylinder
        INITLONG        mdn_numBuffers,1        ; # AmigaDOS buffers to start
        DC.L    0

;HDDosNode:
                                  ;STRUCTURE MkDosNodePkt,0
;        dc.l    DosDevName          ;APTR    mdn_dosName
;        dc.l    myName              ;APTR    mdn_execName
;        dc.l    1                   ;ULONG   mdn_unit
;        dc.l    0                   ;ULONG   mdn_flags
;        dc.l    12                  ;ULONG   mdn_tableSize
;        dc.l    128                 ;ULONG   mdn_sizeBlock
;        dc.l    0                   ;ULONG   mdn_secOrg
;        dc.l    4                   ;ULONG   mdn_numHeads
;        dc.l    1                   ;ULONG   mdn_secsPerBlk
;        dc.l    17                  ;ULONG   mdn_blkTrack
;        dc.l    2                   ;ULONG   mdn_resBlks
;        dc.l    0                   ;ULONG   mdn_prefac
;        dc.l    0                   ;ULONG   mdn_interleave
;        dc.l    2                   ;ULONG   mdn_lowCyl
;        dc.l    40                  ;ULONG   mdn_upperCyl
;        dc.l    10                  ;ULONG   mdn_numBuffers
;        dc.l    1                   ;ULONG   mdn_memBufType
                                    ;STRUCT  mdn_dName,5
                                    ;LABEL   mdn_Sizeof
*DosDevName:
        dc.b    'SFS',0

;----------------------------------------------------------------------
; EndCode is a marker that show the end of your code.
; Make sure it does not span sections nor is before the
; rom tag in memory!  It is ok to put it right after
; the rom tag -- that way you are always safe.  I put
; it here because it happens to be the "right" thing
; to do, and I know that it is safe in this case.
;----------------------------------------------------------------------
EndCode:

        END
