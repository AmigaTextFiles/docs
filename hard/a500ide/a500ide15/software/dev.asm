;; november1997
;
;
; ////Concurrent copy bug fixed version
; this file is modified from spartan34.4scsi)
;
   SECTION   section

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
;   include "devices/scsidisk.i"
   include   'libraries/expansion.i'
   include 'libraries/configvars.i'
   include 'libraries/configregs.i'

   include "asmsupp.i"
   include "mydev.i"
;   include "scsi.i"

   LIST

   XREF ATIDRdWt
;;   XREF   SCSIRdWt
;;   XREF   SCSIDirectCmd

   ;------ These don't have to be external, but it helps some
   ;------ debuggers to have them globally visible
   XDEF   Init
   XDEF   Open
   XDEF   Close
   XDEF   Expunge
   XDEF   Null
   XDEF   myName
   XDEF   BeginIO
   XDEF   AbortIO

   XLIB   AddIntServer
   XLIB   RemIntServer
   XLIB   Debug
   XLIB   InitStruct
   XLIB   InitCode
   XLIB   OpenLibrary
   XLIB   CloseLibrary
   XLIB   Alert
   XLIB   FreeMem
   XLIB   Remove
   XLIB   AllocMem
   XLIB   AddTask
   XLIB   RemTask
   XLIB   ReplyMsg
   XLIB   Signal
   XLIB   GetMsg
   XLIB   PutMsg
   XLIB   Wait
   XLIB   WaitPort
   XLIB   AllocSignal
   XLIB   SetTaskPri
   XLIB   GetCurrentBinding   ; Get list of boards for this driver
   XLIB   MakeDosNode
   XLIB   AddDosNode
   XLIB   Permit
   XLIB   Forbid

;   INT_ABLES
_intena  equ   $dff09a ;;;ML

FirstAddress:
   CLEAR   d0
   rts


MYPRI   EQU   10;10

initDDescrip:
               ;STRUCTURE RT,0
     DC.W    RTC_MATCHWORD    ; UWORD RT_MATCHWORD
     DC.L    initDDescrip     ; APTR  RT_MATCHTAG
     DC.L    EndCode          ; APTR  RT_ENDSKIP
     DC.B    RTF_AUTOINIT     ; UBYTE RT_FLAGS
     DC.B    VERSION          ; UBYTE RT_VERSION
     DC.B    NT_DEVICE        ; UBYTE RT_TYPE
     DC.B    MYPRI            ; BYTE  RT_PRI
     DC.L    myName           ; APTR  RT_NAME
     DC.L    idString         ; APTR  RT_IDSTRING
     DC.L    Init             ; APTR  RT_INIT
               ; LABEL RT_SIZE


subSysName:
myName:      MYDEVNAME

dosName:   DOSNAME

   ; a major version number.
VERSION:   EQU   34

REVISION:   EQU   5

idString:   dc.b   'Idedevice 1.10-ML (07 Nov 97)',13,10,0

   ; force word allignment
   ds.w   0

Init:
   DC.L   MyDev_Sizeof     ; data space size
   DC.L   funcTable        ; pointer to function initializers
   DC.L   dataTable        ; pointer to data initializers
   DC.L   initRoutine      ; routine to run


funcTable:

   ;------ standard system routines
   dc.l   Open
   dc.l   Close
   dc.l   Expunge
   dc.l   Null

   ;------ my device definitions
   dc.l   BeginIO
   dc.l   AbortIO

   ;------ function table end marker
   dc.l   -1


dataTable:
   INITBYTE   LH_TYPE,NT_DEVICE
   INITLONG   LN_NAME,myName
   INITBYTE   LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
   INITWORD   LIB_VERSION,VERSION
   INITWORD   LIB_REVISION,REVISION
   INITLONG   LIB_IDSTRING,idString
   DC.L   0


initRoutine:
   movem.l  d0-d1/a0-a1/a3-a5,-(sp)   ; Preserve ALL modified registers
   move.l   d0,a5

   ;------ save a pointer to exec
   move.l   a6,md_SysLib(a5)

   ;------ save a pointer to our loaded code
   move.l   a0,md_SegList(a5)

   lea.l    dosName,A1      ; Get expansion lib. name
   moveq    #0,D0
   CALLSYS  OpenLibrary      ; Open the expansion library
   move.l   d0,md_DosLib(a5)
   bne.s    init_end
   ALERT    AG_OpenLib!AO_DOSLib
;   bra   init_error

initDosOK:
;   lea.l   ExLibName,a1
;   moveq   #0,d0
;   CALLSYS   OpenLibrary
;   move.l   d0,a3
;   bne   init_OpSuccess
;   ALERT   AG_OpenLib!AO_ExpansionLib
;   bra   init_error

init_OpSuccess:
;   move.b   #$80,NCR+2   ;Resets SCSI bus
;   move.l   #0,a0
;   move.l   #$3ec,d0
;   move.b   #$0,NCR+2    ;Clear Chip for I/O
;   moveq   #$e,d1
;   move.l   a6,-(a7)
;   move.l   a3,a6
;   CALLSYS   InitCode
;   move.l   (a7)+,a6
;   move.l   d0,a4
;   move.l   $20(a4),d0
;   tst.l   d0
;   beq   init_error
;   move.l   d0,md_Base(a5)
;   bra   init_end
init_error:
   moveq   #0,d0
init_end:
   movem.l   (sp)+,d0-d1/a0-a1/a3-a5
   rts


Open:      ; ( device:a6, iob:a1, unitnum:d0, flags:d1 )
   movem.l  d2/a2-a4,-(sp)
   move.l   a1,a2      ; save the iob

   ;------ see if the unit number is in range
   ;move.l  #1,d0
   ;subq.w  #1,d0
   cmp.l    #MD_NUMUNITS,d0
   bcc.s    Open_Error   ; unit number out of range

   ;------ see if the unit is already initialized
   move.l   d0,d2      ; save unit number
   lsl.l    #2,d0
   lea.l    md_Units(a6,d0.l),a4
   move.l   (a4),d0
   bne.s    Open_UnitOK

   ;------ try and conjure up a unit
   bsr      InitUnit

   ;------ see if it initialized OK
   move.l   (a4),d0
   beq.s    Open_Error

Open_UnitOK:
   move.l   d0,a3      ; unit pointer in a3

   move.l   d0,IO_UNIT(a2)

   ;------ mark us as having another opener
   addq.w   #1,LIB_OPENCNT(a6)
   addq.w   #1,UNIT_OPENCNT(a3)
   ;------ prevent delayed expunges
   bclr     #LIBB_DELEXP,md_Flags(a6)
   moveq.l  #0,d0

Open_End:
   movem.l  (sp)+,d2/a2-a4
   rts

Open_Error:
   movem.l  d0,-(sp)
looop2:     move.l   #1,d0
   cmp.b    #0,d0
   bne      looop2
   movem.l  (sp)+,d0

   move.b   #IOERR_OPENFAIL,IO_ERROR(a2)
   bra.s    Open_End


Close:      ; ( device:a6, iob:a1 )
;   movem.l   d1/a2-a3,-(sp)
;
;   move.l   a1,a2
;
;   move.l   IO_UNIT(a2),a3
;
   ;------ make sure the iob is not used again
;   moveq.l   #-1,d0
;   move.l   d0,IO_UNIT(a2)
;   move.l   d0,IO_DEVICE(a2)
;
   ;------ see if the unit is still in use
;   subq.w   #1,UNIT_OPENCNT(a3)

;   bne.s   Close_Device
;   bsr     ExpungeUnit

Close_Device:
   ;------ mark us as having one fewer openers
;   moveq.l  #0,d0
;   subq.w   #1,LIB_OPENCNT(a6)

   ;------ see if there is anyone left with us open
;   bne.s   Close_End

   ;------ see if we have a delayed expunge pending
;   btst   #LIBB_DELEXP,md_Flags(a6)
;   beq.s   Close_End

   ;------ do the expunge
;   bsr   Expunge

Close_End:
;   movem.l   (sp)+,d1/a2-a3
;   rts


Expunge:   ; ( device: a6 )

;   movem.l   d1/d2/a5/a6,-(sp)   ; Best to save ALL modified registers
;   move.l   a6,a5
;   move.l   md_SysLib(a5),a6
   
   ;------ see if anyone has us open
 ;  tst.w   LIB_OPENCNT(a5)
 ;  beq   1$

   ;------ it is still open.  set the delayed expunge flag
;   bset   #LIBB_DELEXP,md_Flags(a5)
;   CLEAR   d0
;   bra.s   Expunge_End

1$:
   ;------ go ahead and get rid of us.  Store our seglist in d2
;   move.l   md_SegList(a5),d2

   ;------ unlink from device list
;   move.l   a5,a1
;   CALLSYS   Remove
;   move.l   md_DosLib(a5),a1
;   CALLSYS   CloseLibrary
   
   ;
   ; device specific closings here...
   ;

   ;------ free our memory
;   CLEAR   d0
;   CLEAR   d1
;   move.l   a5,a1
;   move.w   LIB_NEGSIZE(a5),d1

;   sub.w   d1,a1
;   add.w   LIB_POSSIZE(a5),d0
;   add.l   d1,d0

;   CALLSYS   FreeMem

   ;------ set up our return value
;   move.l   d2,d0

Expunge_End:
;   movem.l   (sp)+,d1/d2/a5/a6
;   rts


Null:
   CLEAR   d0
   rts


InitUnit:   ; ( d2:unit number, a3:scratch, a6:devptr )

   movem.l  d2-d4/a2,-(sp)

   ;------ allocate unit memory
   move.l   #MyDevUnit_Sizeof,d0
   move.l   #MEMF_PUBLIC!MEMF_CLEAR,d1
   LINKSYS  AllocMem,md_SysLib(a6)

   tst.l    d0
   beq      InitUnit_End

   move.l   d0,a3
   move.b   d2,mdu_UnitNum(a3)   ; initialize unit number
   move.l   a6,mdu_Device(a3)   ; initialize device pointer


   ;------ Initialize the stack information
   lea      mdu_stack(a3),a0   ; Low end of stack
   move.l   a0,mdu_tcb+TC_SPLOWER(a3)
   lea      MYPROCSTACKSIZE(a0),a0   ; High end of stack
   move.l   a0,mdu_tcb+TC_SPUPPER(a3)
   move.l   a3,-(A0)      ; argument -- unit ptr
   move.l   a0,mdu_tcb+TC_SPREG(a3)
   ;------ initialize the unit's list
   lea      MP_MSGLIST(a3),a0
   NEWLIST  a0
   lea      mdu_tcb(a3),a0
   move.l   a0,MP_SIGTASK(a3)
   moveq.l  #0,d0         ; Don't need to re-zero it
   move.l   a3,a2         ; InitStruct is initializing the UNIT
   lea.l    mdu_Init,A1
   LINKSYS  InitStruct,md_SysLib(a6)

   move.l   a3,mdu_is+IS_DATA(a3)   ; Pass int. server unit addr.

;   Startup the task
   lea      mdu_tcb(a3),a1
   lea      Proc_Begin(PC),a2
   move.l   a3,-(sp)      ; Preserve UNIT pointer
   lea      -1,a3         ; generate address error
               ; if task ever "returns"
   CLEAR    d0
   LINKSYS  AddTask,md_SysLib(a6)
   move.l   (sp)+,a3      ; restore UNIT pointer

   ;------ mark us as ready to go
   move.l   d2,d0         ; unit number
   lsl.l    #2,d0
   move.l   a3,md_Units(a6,d0.l)   ; set unit table


InitUnit_End:
   movem.l  (sp)+,d2-d4/a2
   rts
   ;------ got an error.  free the unit structure that we allocated.
InitUnit_FreeUnit:
   bsr      FreeUnit
   bra.s    InitUnit_End

FreeUnit:   ; ( a3:unitptr, a6:deviceptr )
   move.l   a3,a1
   move.l   #MyDevUnit_Sizeof,d0
   LINKSYS  FreeMem,md_SysLib(a6)
   rts


ExpungeUnit:   ; ( a3:unitptr, a6:deviceptr )
 ;  move.l   d2,-(sp)


 ;  lea   mdu_tcb(a3),a1
 ;  LINKSYS   RemTask,md_SysLib(a6)

   ;------ save the unit number
 ;  CLEAR   d2
 ;  move.b   mdu_UnitNum(a3),d2

   ;------ free the unit structure.
 ;  bsr   FreeUnit

   ;------ clear out the unit vector in the device
 ;  lsl.l   #2,d2
 ;  clr.l   md_Units(a6,d2.l)

 ;  move.l   (sp)+,d2

   rts

cmdtable:
   DC.L   Invalid    ; $00000001
   DC.L   MyReset    ; $00000002
   DC.L   RdWt       ; $00000004   Common routine for read/write
   DC.L   RdWt       ; $00000008
   DC.L   Update     ; $00000010
   DC.L   Clear      ; $00000020
   DC.L   MyStop     ; $00000040
   DC.L   Start      ; $00000080
   DC.L   Flush      ; $00000100
   DC.L   Motor      ; $00000200  motor   (NO-OP)
   DC.L   Seek       ; $00000400  seek   (NO-OP)
   DC.L   Format     ; $00000800  format -> WRITE for harddisk
   DC.L   MyRemove   ; $00001000  remove      (NO-OP)
   DC.L   ChangeNum  ; $00002000  changenum      (Returns 0)
   DC.L   ChangeState; $00004000  changestate   (Returns 0)
   DC.L   ProtStatus ; $00008000  protstatus      (Returns 0)
   DC.L   RawRead    ; Not supported   (INVALID)
   DC.L   RawWrite   ; Not supported   (INVALID)
   DC.L   GetDriveType   ; Get drive type   (Returns 1)
   DC.L   GetNumTracks   ; Get number of tracks (Returns NUMTRKS)
   DC.L   AddChangeInt   ; Add disk change interrupt (NO-OP)
   DC.L   RemChangeInt   ; Remove disk change interrupt ( NO-OP)
   DC.L   Invalid      
   DC.L   Invalid      
   DC.L   Invalid     
   DC.L   Invalid   
   DC.L   Invalid  
   DC.L   Invalid 
   DC.L   SCSIDirect ;;;==invalid
cmdtable_end:

; this define is used to tell which commands should not be queued
; command zero is bit zero.
; The immediate commands are Invalid, Reset, Stop, Start, Flush
IMMEDIATES  EQU   $000001c3

; These commands can NEVER be done "immediately" if using interrupts,
; since they would "wait" for the interrupt forever!
; Read, Write, Format
NEVERIMMED  EQU   $0000080C
;
; BeginIO starts all incoming io.  The IO is either queued up for the
; unit task or processed immediately.
;

BeginIO: ; ( iob: a1, device:a6 )
   movem.l  d0/d1/a0/a3,-(sp)

   ;------ bookkeeping
   move.l   IO_UNIT(a1),a3

   ;------ see if the io command is within range
   move.w   IO_COMMAND(a1),d0
   cmp.w    #MYDEV_END,d0
   bcc      BeginIO_NoCmd
   cmp.w    #4,d0
   beq      BeginIO_NoCmd   ;filter UPDATE
   cmp.w    #9,d0
   beq      BeginIO_NoCmd   ;filter MOTOR
   DISABLE  a0

   ;------ process all immediate commands no matter what
   move.w   #IMMEDIATES,d1
   btst     d0,d1
   bne.s    BeginIO_Immediate
;
; !!! These lines are enabled so that all read/write requests would be
;     queued. TM  (A cure for the concurrent copy bug)
;
;  IFD   INTRRUPT ; if using interrupts, ;DEBUG
   ;------ queue all NEVERIMMED commands no matter what
   move.w   #NEVERIMMED,d1
   btst     d0,d1
   bne.s    BeginIO_QueueMsg
;  ENDC

   ;------ see if the unit is STOPPED.  If so, queue the msg.
   btst     #MDUB_STOPPED,UNIT_FLAGS(a3)
   bne.s    BeginIO_QueueMsg

   ;------ this is not an immediate command.  see if the device is
   ;------ busy.
   bset     #UNITB_ACTIVE,UNIT_FLAGS(a3)
   beq.s    BeginIO_Immediate

   ;------ we need to queue the device.  mark us as needing
   ;------ task attention.  Clear the quick flag
BeginIO_QueueMsg:
   BSET     #UNITB_INTASK,UNIT_FLAGS(a3)
   bclr     #IOB_QUICK,IO_FLAGS(a1)

   ENABLE   a0
   move.l   a3,a0
   LINKSYS  PutMsg,md_SysLib(a6)
   bra      BeginIO_End

BeginIO_Immediate:
   ENABLE   a0

   bsr      PerformIO

BeginIO_End:
   movem.l  (sp)+,d0/d1/a0/a3
   rts

BeginIO_NoCmd:
   move.b   #IOERR_NOCMD,IO_ERROR(a1)
   bra.s    BeginIO_End


;
; PerformIO actually dispatches an io request.  It expects a3 to already
; have the unit pointer in it.  a6 has the device pointer (as always).
; a1 has the io request.  Bounds checking has already been done on
; the io request.
;

PerformIO:  ; ( iob:a1, unitptr:a3, devptr:a6 )
   move.l   a2,-(sp)
   move.l   a1,a2

   clr.b    IO_ERROR(a2)      ; No error so far
   move.w   IO_COMMAND(a2),d0
   lsl      #2,d0       ; Multiply by 4 to get table offset
   lea      cmdtable(pc),a0
   move.l   0(a0,d0.w),a0

   jsr      (a0)

   move.l   (sp)+,a2
   rts

;
; TermIO sends the IO request back to the user.  It knows not to mark
; the device as inactive if this was an immediate request or if the
; request was started from the server task.
;

TermIO:     ; ( iob:a1, unitptr:a3, devptr:a6 )
   move.w   IO_COMMAND(a1),d0
   move.w   #IMMEDIATES,d1
   btst     d0,d1
   bne.s    TermIO_Immediate

   ;------ we may need to turn the active bit off.
   btst     #UNITB_INTASK,UNIT_FLAGS(a3)
   bne.s    TermIO_Immediate

   ;------ the task does not have more work to do
   bclr     #UNITB_ACTIVE,UNIT_FLAGS(a3)
TermIO_Immediate:
   ;------ if the quick bit is still set then we don't need to reply
   ;------ msg -- just return to the user.
   btst     #IOB_QUICK,IO_FLAGS(a1)
   bne.s    TermIO_End

   LINKSYS  ReplyMsg,md_SysLib(a6)

TermIO_End:
   rts
   
SCSIDirect:
   bra   Invalid ;;;
;  move.b   #HFERR_BadStatus,IO_ERROR(a1) ; HL Only if not supported
;     bsr   TermIO
;  rts
   movem.l a2-a3/a4/a6/d2/d7,-(sp)
   movem.l a6,-(sp)
   move.l   IO_DATA(a1),a6
   clr.l    IO_ACTUAL(a1)
;   clr.l    scsi_Actual(a6)      ; Initially, no data moved
;   move.l   scsi_Data(a6),a0
;   move.l   scsi_Length(a6),d0
;   move.l   scsi_Command(a6),a2

   move.l   IO_UNIT(a1),a3      ; Get unit pointer

;   move.l   d0,scsi_Actual(a6)
   CLEAR    d2
   move.b   mdu_UnitNum(a3),d2

;   jsr   SCSIDirectCmd

   move.b   d0,IO_ERROR(a1)
;   move.b   d7,scsi_Status(a6)
   movem.l  (sp)+,a6
   bsr   TermIO
   movem.l (sp)+,a2-a3/a4/a6/d2/d7
   rts

AbortIO: 
RawRead:      ; 10 Not supported   (INVALID)
RawWrite:      ; 11 Not supported   (INVALID)
Invalid:
GetNumTracks:
   move.b   #IOERR_NOCMD,IO_ERROR(a1)
   bsr      TermIO
   rts

MyReset:
AddChangeInt:
RemChangeInt:
MyRemove:
Seek:
Motor:
Remove:
ChangeNum:
ChangeState:
ProtStatus:
   clr.l    IO_ACTUAL(a1)   ; Indicate drive isn't protected
   bsr      TermIO
   rts

GetDriveType:
   move.l   #1,IO_ACTUAL(a1)      ; Make it look like 3.5"
   bsr      TermIO
   rts

RdWt:
Format:
   movem.l  a2-a3/a6/d2,-(sp)
   clr.l    IO_ACTUAL(a1)      ; Initially, no data moved
   move.l   IO_DATA(a1),a0
   move.l   IO_LENGTH(a1),d0

   ;------ deal with zero length I/O
   beq.s    RdWt_end


   move.l   IO_UNIT(a1),a3      ; Get unit pointer
   move.l   a1,a2

*      check operation for legality

   move.l   IO_OFFSET(a2),d1
   move.l   d1,d2
   and.l    #$1ff,d2
   bne      Sec_Error


   move.l   d0,IO_ACTUAL(a2)
   CLEAR    d2
   move.b   mdu_UnitNum(a3),d2

   jsr      ATIDRdWt

RdWt_Clean:
   move.b   d0,IO_ERROR(a1)
   bra      RdWt_end
Sec_Error:
   move.b   #$fc,IO_ERROR(a1)
RdWt_end:
   bsr      TermIO
   movem.l  (sp)+,a2-a3/a6/d2
   rts

Update:
Clear:
   bsr      TermIO
   rts

MyStop:
   bset     #MDUB_STOPPED,UNIT_FLAGS(a3)
   bsr      TermIO
   rts
   
Start:
   bsr      InternalStart

;   move.l   a2,a1         ; TM simul bug
   bsr      TermIO

   rts

InternalStart:
   ;------ turn processing back on
   move.l   a1,-(sp)    ; TM simul bug -- save a1
   bclr     #MDUB_STOPPED,UNIT_FLAGS(a3)

   ;------ kick the task to start it moving
;   move.l   a3,a1         ; TM simul bug
   CLEAR    d0
;   move.l   MP_SIGBIT(a3),d1
   move.b   MP_SIGBIT(a3),d1  ;TM
   bset     d1,d0
   LINKSYS  Signal,md_SysLib(a3)
   move.l   (sp)+,a1    ; TM simul bug -- restore a1
   rts


Flush:
   movem.l  d2/a1/a6,-(sp)      ; TM simul bug -- save a1

   move.l   md_SysLib(a6),a6

   bset     #MDUB_STOPPED,UNIT_FLAGS(a3)
   sne      d2

Flush_Loop:
   move.l   a3,a0
   CALLSYS  GetMsg

   tst.l    d0
   beq.s    Flush_End

   move.l   d0,a1
   move.b   #IOERR_ABORTED,IO_ERROR(a1)
   CALLSYS  ReplyMsg

   bra.s    Flush_Loop

Flush_End:

   move.l   d2,d0
   movem.l  (sp)+,d2/a1/a6      ; TM simul bug

   tst.b    d0
   beq.s    1$

   bsr      InternalStart
1$:

;   move.l   a2,a1         ; TM simul bug
   bsr      TermIO

   rts

;   cnop    0,4         ; long word allign
   DC.L     16         ; segment length -- any number will do
myproc_seglist:
   DC.L     0         ; pointer to next segment

; the next instruction after the segment list is the first executable address

Proc_Begin:

   move.l   4,a6

   ;------ Grab the argument
   move.l   4(sp),a3      ; Unit pointer

   move.l   mdu_Device(a3),a5   ; Point to device structure

 

   ;------ Allocate the right signal

   moveq    #-1,d0         ; -1 is any signal at all
   CALLSYS  AllocSignal

   move.b   d0,MP_SIGBIT(a3)
   move.b   #PA_SIGNAL,MP_FLAGS(a3)

   ;------ change the bit number into a mask, and save in d7

   moveq    #0,d7
   bset     d0,d7

   bra.s   Proc_CheckStatus

   ;------ main loop: wait for a new message
Proc_MainLoop:
   move.l   d7,d0
   CALLSYS  Wait

Proc_CheckStatus:
   ;------ see if we are stopped
   btst     #MDUB_STOPPED,UNIT_FLAGS(a3)
   bne.s    Proc_MainLoop      ; device is stopped

   ;------ lock the device
   bset     #UNITB_ACTIVE,UNIT_FLAGS(a3)
   bne.s    Proc_MainLoop      ; device in use
   ;------ get the next request
Proc_NextMessage:
   move.l   a3,a0
   CALLSYS  GetMsg
   tst.l    d0
   beq.s    Proc_Unlock      ; no message?

   ;------ do this request
   move.l   d0,a1
   exg      a5,a6         ; put device ptr in right place
   bsr      PerformIO
   exg      a5,a6         ; get syslib back in a6

   bra.s    Proc_NextMessage

   ;------ no more messages.  back ourselves out.
Proc_Unlock:
   and.b    #$ff&(~(UNITF_ACTIVE!UNITF_INTASK)),UNIT_FLAGS(a3)
   bra      Proc_MainLoop
mdu_Init:
;   ------ Initialize the device

   INITBYTE   MP_FLAGS,PA_IGNORE
   INITBYTE   LN_TYPE,NT_DEVICE
   INITLONG   LN_NAME,myName
   INITBYTE   mdu_Msg+LN_TYPE,NT_MSGPORT ;Unit starts with MsgPort
   INITLONG   mdu_Msg+LN_NAME,myName      
   INITLONG   mdu_tcb+LN_NAME,myName
   INITBYTE   mdu_tcb+LN_TYPE,NT_TASK
   INITBYTE   mdu_tcb+LN_PRI,MYPROCPRI
   INITBYTE   mdu_is+LN_PRI,4      ; Int priority 4
   IFD        INTRRUPT
   INITLONG   mdu_is+IS_CODE,myintr   ; Interrupt routine addr
   ENDC
   INITLONG   mdu_is+LN_NAME,myName
   DC.L   0

EndCode:
   END         ;TM
