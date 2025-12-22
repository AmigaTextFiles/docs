;============================================================================
;                        Parallel Port Zip Driver
;============================================================================
;
; 15-Jan-1998 v0.0 created by Bruce Abbott
;
;  8-Feb-1998 v0.1 - now obtaining joystick port via gameport.device
;
; 10-Feb-1998 v0.2 - fixed bug in timedelay (was not freeing memory).
;
; 11-Feb-1998 v0.3 - Split large data transfers into 128K blocks, rather
;                    than using MaxTransfer setting in mountlist. This
;                    circumvents a bug in CrossDOSFileSystem v39.4
;
; 21-Feb-1998 v0.4 - Using TEST_UNIT_READY and READ_SENSE commands to
;                    determine if r/w error is actually no disk in drive.
;
;                  - Increased timeouts up to 3 seconds (greater than
;                    maximum drive spinup time).
;
;                  - Reduced Timer overhead. Now only opening timer.device
;                    once, instead of on every time delay. Allocated ioreqs
;                    static instead of using AllocMem.
;
;  9-Mar-1998 v0.5 - Using 10 byte SCSI read/write commands. Now can
;                    do large transfers (>128K) directly.
;
; 12-Mar-1998 v0.6 - Fixed bug in Autorequest - libray base in wrong
;                    register would cause a Guru if parallel port or
;                    joystick port was not available.
;
;                  - Automatic Diskchange detection implemented.
;
;                  - Asynchronous commands now always queued.
;
;
; 1-Apr-1998 v0.7  - Now tries to avoid forcing the audio filter on.
;
;                  - Better handling of resource allocation failure.
;
; 1-Sep-1998 v0.8  - Added 10ms delay before reading data blocks.
;                    This should reduce errors caused by the drive
;                    not being ready to perform the transfer.
;
;                  - SCSIdirect implemented.
;
;

VERSION     EQU   0
REVISION    EQU   8

; opt d+

;debug = 1
;verbose=1

 output devs:ppazip.device

   include amiga.i              ; 1.3 includes
   include devices/scsidisk.i   ; scsi direct

   include scsi.i               ; standard SCSI stuff

   include debugs.i             ; serial debug messages


EXEC macro
  move.l  a6,-(sp)
  move.l  execbase(pc),a6
  jsr     _LVO\1(a6)
  move.l  (sp)+,a6
  ENDM


; set control port mode without disturbing serial bits

setmode MACRO ; \1 = mode
  move.w  #$4000,_intena
  move.b  ctrlport,d0
  and.b   #~PPBITS,d0
  or.b    #\1,d0
  move.b  d0,ctrlport
  move.w  #$c000,_intena
  ENDM



; ZIP needs a rest after some operations

delay MACRO   \1=time
  IFC "","\1"
    rept 5
     tst.b   $bfe001       ; minimum delay between zip accesses
    endr
  ELSEIF
   move.w  d0,-(sp)
   IFLT    2000,\1
     move.w  #\1-1,d0
.deloop\@:
     tst.b   $bfe001       ; loop for short time delay
     dbf     d0,.deloop\@
   ELSEIF
     move.l  #\1,d0
     bsr     timedelay     ; sleep for long time delay
   ENDC
   move.w  (sp)+,d0
  ENDC
  ENDM

; wait timeouts

COMD_TIMEOUT = 3000000
CNCT_TIMEOUT = 30000
STAT_TIMEOUT = 3000000
MESG_TIMEOUT = 30000
SLCT_TIMEOUT = 100000
DATA_TIMEOUT = 250000
STRT_TIMEOUT = 3000000


; select timeout

SEL_TIMEOUT  = 30000


_intena=$dff09a

; CIA registers

dataport  = $bfe101
dirport   = $bfe301
ctrlport  = $bfd000
ctrldir   = $bfd200

jport     = $bfe001
jdir      = $bfe201

; control register values

BSY    = $01          ; Printer Busy
POUT   = $02          ; Paper Out
SEL    = $04          ; Printer Selected

PPBITS = BSY|POUT|SEL

;          parallel port         zip

PPINIT   =  POUT+SEL         ;  init=0
PPOUT    =  BSY+POUT         ;  selin=0
PPIN     =  BSY+SEL          ;  strobe=0
PPHOST   =  POUT             ;  init,selin=0
PPSTAT   =  BSY+SEL+POUT     ;  all high

; joystick fire used for strobe/ack pulse

JOYBIT  =  7                 ; zip AutofeedXT

; status register values

statport  = $dff00c          ; joystick port


STATMASK    = $0303          ; which joy bits to test

POUTBIT     = 0              ; set at end of xfer
BUSYBIT     = 1              ; set when zip is busy
ACKBIT      = 8              ; set when action completed
SELBIT      = 9              ; set when zip wants to send data

;--------------------------------------------------------
;            status values (busy always low)
;--------------------------------------------------------
;         Value       Meaning         pin(s) high
;
NONE    = $0000    ;     -               -
WRITE   = $0100    ; write block        ack
READ    = $0300    ; read block         ack+sel
COMAND  = $0101    ; write command      ack+pout
STATUS  = $0301    ; read stat byte     ack+pout+sel


; SCSI rd/wr error code bits

SelectErrorBit = 31
PhaseErrorBit  = 30
TimeOutBit     = 29
EarlyStatusBit = 28


MYPROCSTACKSIZE   = $800
MYPROCPRI         =    5
MYDEV_END         =   29

   STRUCTURE MyDev,LIB_SIZE
   ULONG   md_SegList                    ; pointer to our code
   UBYTE   md_Flags
   UBYTE   md_pad
   APTR    md_Unit                       ; pointer to our unit
   LABEL   MyDev_Sizeof

   BITDEF  MD,GOTPAR,4                   ; flags, got parallel resources
   BITDEF  MD,GOTJOY,5                   ; flags, got joyport resources
   BITDEF  MD,INIT,6                     ; flags, zip hardware initialised

   STRUCTURE MyDevUnit,UNIT_SIZE
   APTR    mdu_Device                    ; pointer to our device
   LONG    mdu_changecount               ; number of disk changes
   STRUCT  mdu_removelist,mlh_size       ; list of td_remove ints
   STRUCT  mdu_changelist,mlh_size       ; list of td_addchangeint ioreqs
   STRUCT  mdu_stack,MYPROCSTACKSIZE     ; stack for our task
   STRUCT  mdu_tcb,TC_SIZE               ; TCB for our task
   LABEL   MyDevUnit_Sizeof

; ---- our unit flags ----

   BITDEF   MDU,STOPPED,2          ; state bit for unit stopped

   BITDEF   MDU,READY,3            ; is media ready for access?

   BITDEF   MDU,DISKIN,4           ; media state tracking


MYPRI  =  10         ; device priority



   CODE

FirstAddress:
   moveq   #0,d0
   rts

initDDescrip:
     DC.W    RTC_MATCHWORD      ; UWORD RT_MATCHWORD
     DC.L    initDDescrip       ; APTR  RT_MATCHTAG
     DC.L    EndCode            ; APTR  RT_ENDSKIP
     DC.B    RTF_AUTOINIT       ; UBYTE RT_FLAGS
     DC.B    VERSION            ; UBYTE RT_VERSION
     DC.B    NT_DEVICE          ; UBYTE RT_TYPE
     DC.B    MYPRI              ; BYTE  RT_PRI
     DC.L    myName             ; APTR  RT_NAME
     DC.L    idString           ; APTR  RT_IDSTRING
     DC.L    Init               ; APTR  RT_INIT

Init:
   DC.L   MyDev_Sizeof      ; data space size
   DC.L   funcTable         ; pointer to function initializers
   DC.L   dataTable         ; pointer to data initializers
   DC.L   initRoutine       ; routine to run


funcTable:

   ;------ standard system routines
   dc.l   Open
   dc.l   CloseDev
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


; a0 = seglist, d0 = device data, a6 = execbase

initRoutine:
   move.l   a5,-(sp)                  ; Preserve ALL modified registers
   lea      execbase(pc),a5
   move.l   a6,(a5)                   ; save a pointer to exec
   move.l   d0,a5
   move.l   a0,md_SegList(a5)         ; save a pointer to our loaded code
init_end:
   move.l   (sp)+,a5                  ; Restore All modified registers
   rts

;------------------------------------------------------------------------
;     opendevice ( device:a6, ioreq:a1, unitnum:d0, flags:d1 )
;------------------------------------------------------------------------
;
Open:
   bug     <"ppazip: OpenDevice unit %ld",10>,d0
   movem.l d2/a1-a4,-(sp)
   addq.w  #1,lib_opencnt(a6)            ; prevent expunge while opening
   move.l  a1,a2                         ; a2 = ioreq
   tst.l   d0
   bne     Open_Error                    ; valid unit number ?
   move.l  md_unit(a6),d0
   bne.s   .gotunit
   bsr     InitUnit                      ; create unit
   move.l  md_unit(a6),d0
   beq.s   Open_Error
.gotunit:
   move.l  d0,a3
   bsr     OpenTimer                     ; open timer device
   btst    #MDB_GOTPAR,md_flags(a6)
   bne.s   .gotpar
   bsr     getparallelport
   tst.l   d0                            ; try to obtain printer port
   bne.s   Open_Error
   bset    #MDB_GOTPAR,md_flags(a6)
.gotpar:
   btst    #MDB_GOTJOY,md_flags(a6)
   bne.s   .gotjoy
   bsr     GetGamePort                   ; try to obtain joystick port
   tst.l   d0
   bne.s   Open_Error
   bset    #MDB_GOTJOY,md_flags(a6)
.gotjoy:
   btst    #MDB_INIT,md_flags(a6)
   bne.s   .initok
   bsr     pp_init
   tst.l   d0                            ; try to initialize hardware
   bmi.s   Open_error
   bsr     CheckDisk                     ; get diskchange status
   bmi.s   Open_error
   btst    #MDUB_READY,unit_flags(a3)
   beq.s   .nodisk                       ; sync diskin flag to disk state
   bset    #MDUB_DISKIN,unit_flags(a3)
   bra.s   .initok
.nodisk:
   bclr    #MDUB_DISKIN,unit_flags(a3)
.initok:
   bset    #MDB_INIT,md_flags(a6)        ; hardware init ok
   bra.s   Open_OK
Open_Error:
   bug     <"ppazip: OpenDevice failed!",10,10>
   moveq   #IOERR_OPENFAIL,d0
   move.b  d0,io_error(a2)
   bra.s   Open_End
Open_OK:
   move.l  a3,io_unit(a2)                ; return unit pointer in ioreq
   addq.w  #1,lib_opencnt(a6)            ; mark us as having another opener
   addq.w  #1,unit_opencnt(a3)
   bclr    #LIBB_DELEXP,md_Flags(a6)     ; prevent delayed expunges
   move.b  #NT_REPLYMSG,ln_type(a2)      ; Mark IORequest as "complete"
   moveq   #0,d0
   move.b  d0,io_error(a2)               ; no error
   bug     <"ppazip: OpenDevice OK at $%lx",10>,a6
Open_End:
   subq.w  #1,lib_opencnt(a6)            ; End of expunge protection
   movem.l (sp)+,d2/a1-a4
   rts



CloseDev:      ; ( device:a6, iob:a1 )
   bug     <"ppazip: CloseDevice",10,10>
   movem.l d1/a2-a3,-(sp)
   move.l  a1,a2
   moveq   #-1,d0
   move.l  d0,io_unit(a2)           ; make caller crash if ioreq used again
   ifnd    debug
    move.l  d0,io_device(a2)
   endc
   move.l  md_unit(a6),d0
   beq.s   .close
   move.l  d0,a3
   subq.w  #1,unit_opencnt(a3)         ; is unit still in use ?
   bne.s   .close
   bsr     ExpungeUnit                 ; Expunge Unit
.close:
   moveq   #0,d0
   subq.w  #1,lib_opencnt(a6)          ; mark us as having one fewer openers
   bne.s   .done
   btst    #LIBB_DELEXP,md_Flags(a6)   ; delayed expunge pending ?
   beq.s   .done
   bsr     Expunge                     ; Expunge Device (returns seglist)
.done:
   movem.l (sp)+,d1/a2-a3
   rts


Expunge:   ; ( device: a6 )
   bug      <"ppazip: Expunge ">
   movem.l  d1/d2/a0/a1,-(sp)
   tst.w    lib_opencnt(a6)            ; see if anyone has us open
   beq      .closed
   bset     #LIBB_DELEXP,md_Flags(a6)  ; still open so delay expunge
   bug      <"delayed",10>
   moveq    #0,d0
   bra      .done
.closed:
   move.l   md_SegList(a6),d2          ; seglist in d2
   move.l   a6,a1
   EXEC     Remove                     ; unlink from device list
   ;
   ; device specific closings here...
   ;
   move.b   #$03,jdir                  ; reset joystick FIRE to input mode
   setmode  PPSTAT
   move.b   #$c0,ctrldir               ; restore parallel port
   move.b   #$00,dirport
   btst     #MDB_GOTPAR,md_flags(a6)
   beq.s    .nopar
   bsr      freeParallelport           ; free parallel port
.nopar:
   btst     #MDB_GOTJOY,md_flags(a6)
   beq.s    .nojoy
   bsr      freegameport               ; free joystick port
.nojoy:
   moveq    #0,d0
   moveq    #0,d1
   move.l   a6,a1
   move.w   lib_negsize(a6),d1
   sub.w    d1,a1
   add.w    lib_possize(a6),d0
   add.l    d1,d0                      ; free device memory
   EXEC     FreeMem
   move.l   d2,d0                      ; return seglist for unloading
   bug      <"OK",10,10>
.done:
   movem.l  (sp)+,d1/d2/a0/a1
   rts


Null:
   moveq    #0,d0
   rts


InitUnit:   ; ( a6:devptr )
   bug      <"ppazip: InitUnit   ">
   movem.l  d3-d4/a2/a3,-(sp)
   move.l   #MyDevUnit_Sizeof,d0
   move.l   #MEMF_PUBLIC!MEMF_CLEAR,d1
   EXEC     AllocMem                       ; allocate unit memory
   move.l   d0,md_Unit(a6)
   bne.s    .gotmem
   bug      <"failed!",10>
   bra      .done
.gotmem:
   move.l   d0,a3                          ; a3 = unit
   move.l   a6,mdu_Device(a3)              ; initialize device pointer
   move.b   #NT_MSGPORT,ln_type(a3)
   move.l   #myname,ln_name(a3)            ; init unit's msgport
   move.b   #PA_IGNORE,mp_flags(a3)        ; ignore messages until task runs
   lea      mp_msglist(a3),a0
   NEWLIST  a0
   lea      mdu_tcb(a3),a1                 ; a1 = task
   move.l   a1,mp_sigtask(a3)              ; set sigtask in msgport
   lea      mdu_removelist(a3),a0
   NEWLIST  a0                             ; init td_remove list
   lea      mdu_changelist(a3),a0
   NEWLIST  a0                             ; init td_addchangeint list
   lea      mdu_stack(a3),a0               ; Low end of stack
   move.l   a0,tc_splower(a1)
   lea      MYPROCSTACKSIZE(a0),a0         ; High end of stack
   move.l   a0,tc_spupper(a1)
   move.l   a3,-(a0)                       ; put unit ptr on task's stack
   move.l   a0,tc_spreg(a1)                ; update stack position
   move.l   #myname,ln_name(a1)
   move.b   #NT_TASK,ln_type(a1)
   move.b   #MYPROCPRI,ln_pri(a1)          ; init task listnode
   lea      Proc_Begin(pc),a2
   lea      -1,a3             ; generate address error if task ever "returns"
   moveq    #0,d0
   EXEC     AddTask                        ; Startup the unit task
   bug      <"OK",10>
.done:
   movem.l  (sp)+,d3-d4/a2/a3
   rts

ExpungeUnit:   ; ( a6:deviceptr )
   bug      <"ppazip: ExpungeUnit ">
   move.l   md_unit(a6),d0
   bne.s    .gotunit               ; unit present ?
   bug      <"no unit!",10>
   bra.s    .done
.gotunit:
   move.l   d0,a0
   lea      mdu_tcb(a0),a1
   EXEC     RemTask                ; kill our task
   move.l   md_unit(a6),a1
   move.l   #MyDevUnit_Sizeof,d0
   EXEC     FreeMem                ; free unit memory
   clr.l    md_Unit(a6)
   bug      <"OK",10>
.done:
   rts



;          routine      cmd  immedbit  description
cmdtable:
   DC.L   Invalid      ; 0  $00000001
   DC.L   MyReset      ; 1  $00000002
   DC.L   IORead       ; 2  $00000004  read
   DC.L   IOWrite      ; 3  $00000008  write
   DC.L   Update       ; 4  $00000010
   DC.L   Clear        ; 5  $00000020
   DC.L   MyStop       ; 6  $00000040
   DC.L   Start        ; 7  $00000080
   DC.L   Flush        ; 8  $00000100
   DC.L   Motor        ; 9  $00000200  motor
   DC.L   Seek         ; 10 $00000400  seek
   DC.L   Format       ; 11 $00000800  format -> write
   DC.L   Remove       ; 12 $00001000  remove
   DC.L   ChangeNum    ; 13 $00002000  changenum
   DC.L   ChangeState  ; 14 $00004000  changestate
   DC.L   ProtStatus   ; 15 $00008000  protstatus
   DC.L   RawRead      ; 16 $00010000
   DC.L   RawWrite     ; 17 $00020000
   DC.L   GetDriveType ; 18 $00040000  Get drive type
   DC.L   GetNumTracks ; 19 $00080000  Get number of tracks
   DC.L   AddChangeInt ; 20 $00100000  Add disk change interrupt
   DC.L   RemChangeInt ; 21 $00200000  Remove disk change interrupt
   DC.L   Invalid
   DC.L   Invalid
   DC.L   Invalid
   DC.L   Invalid
   DC.L   Invalid
   DC.L   Invalid
   DC.L   SCSIDirect   ; 28 $10000000  SCSIdirect
cmdtable_end:

; this define is used to tell which commands should not be a queued
; command. command zero is bit zero.
;
IMMEDIATES      EQU     $efcff7f3

; BeginIO starts all incoming IO.  The IO is either queued up for the
; unit task or processed immediately.
;

BeginIO:        ; ( iob: a1, device:a6 )
        movem.l d0/d1/a0/a1/a3,-(sp)
        move.l  io_unit(a1),a3
        ifd  debug
        tst.w   lib_opencnt(a6)
        bgt.s   .ok
        bug     <"ppazip: device not open!",10>
        bra.s   .error
.ok:    move.l  a3,d0
        bgt.s   .ok2
        bug     <"ppazip: ioreq $%lx has no unit pointer!",10>,a1
.error: exec    findtask
        bug     <"------>> Bad Task $%lx!!!",10,10>,d0
        bra.s   BeginIO_End
.ok2:
        endc
        ;------ see if the io command is within range
        move.w  io_command(a1),d0
        cmp.w   #MYDEV_END,d0
        bcc     BeginIO_NoCmd
        ;------ process all immediate commands no matter what
        move.l  #IMMEDIATES,d1
        btst    d0,d1
        bne.s   BeginIO_Immediate
BeginIO_QueueMsg:
        bclr    #IOB_QUICK,io_flags(a1)
        move.l  a3,a0
        EXEC    PutMsg                 ; put ioreq onto unit msgport
        bra     BeginIO_End
BeginIO_NoCmd:
        move.b  #IOERR_NOCMD,io_error(a1)
        bra.s   BeginIO_End
BeginIO_Immediate:
        bsr     PerformIO              ; do ioreq now
BeginIO_End:
        movem.l (sp)+,d0/d1/a0/a1/a3
        rts

;
; PerformIO actually dispatches an io request.  It expects a3 to already
; have the unit pointer in it.  a6 has the device pointer (as always).
; a1 has the iorequest.  Bounds checking has already been done on
; the io request.
;

PerformIO:       ; ( iob:a1, unitptr:a3, devptr:a6 )
        clr.b   io_error(a1)            ; No error so far
        moveq   #0,d0
        move.w  io_command(a1),d0
        lsl.w   #2,d0                   ; Multiply by 4 to get table offset
        lea     cmdtable(pc),a0
        move.l  0(a0,d0.w),a0
        jmp     (a0)

;
; TermIO sends the IO request back to the user.  It knows not to mark
; the device as inactive if this was an immediate request or if the
; request was started from the server task.
;

TermIO: ; ( iob:a1, unitptr:a3, devptr:a6 )
        ;------ if the quick bit is still set then we don't need to reply
        ;------ msg -- just return to the user.
        btst    #IOB_QUICK,IO_FLAGS(a1)
        bne.s   TermIO_End
        EXEC    ReplyMsg
TermIO_End:
        rts

AbortIO:
RawRead:
RawWrite:
Invalid:
GetNumTracks:
   moveq   #0,d0
   move.w  io_command(a1),d0
   bug     <"ppazip: Invalid command = %ld",10>,d0
   move.b  #IOERR_NOCMD,io_error(a1)
   bra     TermIO


Motor:
   ifd     verbose
   bug     <"ppazip: td_motor",10>
   endc
   clr.l   io_actual(a1)
   bra     TermIO


Remove:
   bug     <"ppazip: cmd_remove($%08lx)",10>,io_data(a1)
   move.l  io_data(a1),d0
   beq.s   .noint
   move.l  a1,-(sp)
   lea     mdu_removelist(a3),a0
   move.l  d0,a1
   exec    addhead
   move.l  (sp)+,a1
.noint:
   bra     TermIO


AddChangeInt:
   bug     <"ppazip: td_addchangeint($%08lx)",10>,io_data(a1)
   lea     mdu_changelist(a3),a0
   EXEC    AddHead                        ; add ioreq to changelist
   bclr    #UNITB_ACTIVE,unit_flags(a3)
.done:
   rts                                    ; do NOT return ioreq


RemChangeInt:
   bug     <"ppazip: td_remchangeint",10>
   move.l  a1,-(sp)
   EXEC    Remove                    ; remove ioreq from list
   move.l  (sp)+,a1
   bra     TermIO                    ; return ioreq

MyReset:
   bug     <"ppazip: cmd_reset",10>
   bra     TermIO

Seek:
   bug     <"ppazip: td_seek",10>
   bra     TermIO

ChangeNum:
   bug     <"ppazip: td_changenum",10>
   move.l  mdu_changecount(a3),io_actual(a1)
   bra     TermIO

UpDate:
   ifd verbose
   bug     <"ppazip: cmd_update",10>
   endc
   bra     TermIO

Clear:
   bug     <"ppazip: cmd_clear",10>
   bra     TermIO

ProtStatus:
   bug     <"ppazip: td_protstatus",10>
   clr.l   IO_ACTUAL(a1)           ; not protected
   bra     TermIO

GetDriveType:
   bug     <"ppazip: td_getdrivetype",10>
   move.l  #1,IO_ACTUAL(a1)      ; Make it look like 3.5"
   bra     TermIO


SCSIDirect:
     movem.l a2/a3,-(sp)
     move.l  a1,a3
     move.l  io_data(a3),a2
     move.l  scsi_command(a2),a0
     moveq   #0,d0
     move.w  scsi_cmdlength(a2),d0
     moveq   #0,d1
     bug     <"ppazip: cmdblk ">
     cmp.w   #12,d0
     bhi     .error
     lea     cmdbuf(pc),a1
     bra.s   .copycmd
.ccloop:
     move.b  (a0)+,d1
     move.b  d1,(a1)+
     bug     <" %02lx">,d1
.copycmd:
     dbf     d0,.ccloop
     bug     <10>
     move.b  cmdbuf(pc),d0
     cmp.b   #$1a,d0
     beq     .badcmd                      ; zip chokes on these commands!
     cmp.b   #$37,d0
     beq     .badcmd
     move.l  scsi_data(a2),a0
     move.l  scsi_length(a2),d0
     moveq   #0,d1
     move.b  scsi_flags(a2),d1
     bug     <"ppazip:      = ">,d1
     bsr     DoSCSI
     bug     <"$%08lx",10>,d0
     move.b  d0,io_error(a3)
     swap    d0
     move.b  d0,scsi_Status(a2)
     move.l  d1,scsi_Actual(a2)
     clr.w   scsi_SenseActual(a2)           ; no sense data yet
     btst    #SCSIB_AUTOSENSE,scsi_flags(a2)
     beq.s   .done
     cmp.b   #$02,d0                        ; check condition ?
     beq.s   .done
     bsr     DoSense                        ; read sense data
     tst.l   d1
     beq.s   .done
     move.l  scsi_SenseData(a2),d0
     beq.s   .done                          ; ptr for sense data ?
     move.l  d0,a1
     lea     buffer,a0
     move.w  d1,scsi_SenseActual(a2)
     moveq   #0,d0
.getsense:
     cmp.w   scsi_SenseLength(a2),d0
     beq.s   .done
     cmp.w   d1,d0
     beq.s   .done
     move.b  (a0)+,(a1)+                    ; copy sense data
     addq.w  #1,d0
     bra.s   .getsense
.badcmd:
     bra.s   .done
.error:
     move.b  #IOERR_BADLENGTH,io_error(a3)
.done:
     move.l  a3,a1
     movem.l (sp)+,a2/a3
     bra     TermIO


; check to see if drive has a disk in it

ChangeState:
   bug     <"ppazip: td_changestate()=">
   btst    #MDUB_READY,unit_flags(a3)  ; disk in ?
   beq.s   .nodisk
   clr.l   io_actual(a1)
   bug     <"DISK_IN",10>
   bra.s   .done
.nodisk:
   moveq   #1,d0
   move.l  d0,io_actual(a1)
   bug     <"DISK_OUT",10>
.done:
   bra     Termio


;------------------------------------------------------------------
;                   Check for Disk Ready
;------------------------------------------------------------------
;
; a3 = unit
;
CheckDisk:
   bsr     DoCheck                     ; check condition
   tst.b   d0                          ; error ?
   bne.s   .nodisk
   swap    d0
   tst.b   d0                          ; status=OK ?
   bne.s   .nodisk
.diskin:
   bset    #MDUB_READY,unit_flags(a3)
   bra.s   .done
.nodisk:
   bclr    #MDUB_READY,unit_flags(a3)
.done:
   rts


IORead:
IOWrite:
Format:
   movem.l d2-d7/a2,-(sp)
   clr.l   io_actual(a1)        ; no data moved yet
   move.l  io_data(a1),a2       ; a2 = current position in data buffer
   move.l  io_offset(a1),d6     ; d6 = current offset
   move.l  io_length(a1),d5     ; d5 = io_length
   beq     .done
   move.l  d6,d0
   and.w   #$01ff,d0            ; check for whole sectors
   bne     .secerror
.doblock:
   moveq   #0,d7                ; retries=0
   move.l  d5,d4
   sub.l   io_actual(a1),d4
   cmp.l   #$1fffe00,d4         ; d4 = current blocksize
   bls.s   .doscsi
   move.l  #$1fffe00,d4         ; limit to 32 MegaBytes
.doscsi:
   move.l  a2,a0
   move.l  d6,d0
   move.l  d4,d1
   bsr     SCSI_ReadWrite       ; do SCSI read/write
   swap    d0
   tst.w   d0                   ; any errors ?
   beq     .next
   bsr     DoSense
   move.b  buffer+sns_skey,d0
   and.b   #SDM_SKEY,d0
   cmp.b   #SK_NOT_READY,d0
   beq.s   .diskout
.retry:
   addq.w  #1,d7
   cmp.w   #5,d7
   blo     .doscsi              ; try again
.rwerror
   move.b  #TDERR_NotSpecified,io_error(a1)
   bra.s   .done
.diskout:
   bug     <"ppazip: disk removed!",10>
   move.b  #TDERR_DiskChanged,io_error(a1)
   bclr    #MDUB_READY,unit_flags(a3)
   bra.s   .done
.next:
   add.l   d4,a2                ; data+block
   add.l   d4,d6                ; offset+block
   move.l  io_actual(a1),d0
   add.l   d4,d0                ; actual+block
   move.l  d0,io_actual(a1)
   cmp.l   d5,d0                ; all done?
   blo     .doblock
.ok:
   bset    #MDUB_READY,unit_flags(a3)
   bra.s   .done
.secerror:
   move.b  #IOERR_BADLENGTH,io_error(a1)
.done:
   movem.l (sp)+,d2-d7/a2
   bra     TermIO


MyStop:
   bset    #MDUB_STOPPED,unit_flags(a3)
   bra     TermIO

Start:
   bsr     InternalStart
   bra     TermIO

InternalStart:
   move.l  a1,-(sp)
   bclr    #MDUB_STOPPED,unit_flags(a3)
   moveq   #0,d0
   move.b  mp_sigbit(a3),d1
   bset    d1,d0
   EXEC    Signal                      ; kick the task to start it moving
   move.l  (sp)+,a1
   rts


Flush:
   movem.l d2/a1,-(sp)
   bset    #MDUB_STOPPED,unit_flags(a3)
   sne     d2
Flush_Loop:
   move.l  a3,a0
   EXEC    GetMsg
   tst.l   d0
   beq.s   Flush_End
   move.l  d0,a1
   move.b  #IOERR_ABORTED,io_error(a1)
   EXEC    ReplyMsg
   bra.s   Flush_Loop
Flush_End:
   move.l  d2,d0
   movem.l (sp)+,d2/a1
   tst.b   d0
   beq.s   .termio
   bsr     InternalStart
.termio
   bra     TermIO

;-----------------------------------
;  Init Signalling Message Port
;-----------------------------------
;
; error = InitPort(port)
;   d0              a0
;
InitPort:
  movem.l d2/a2,-(sp)
  move.l  a0,a2
  moveq.l #-1,d0
  exec    AllocSignal                  ; obtain sigbit
  move.l  d0,d2
  bmi.s   .error
  sub.l   a1,a1
  exec    FindTask                     ; find our task
  move.l  d0,mp_sigtask(a2)
  move.b  d2,mp_sigbit(a2)
  move.b  #NT_MSGPORT,ln_type(a2)
  move.b  #PA_SIGNAL,mp_flags(a2)
  lea     mp_msglist(a2),a0
  NEWLIST a0
  moveq   #0,d0
  bra.s   .done
.error:
  moveq   #-1,d0
.done:
  movem.l (sp)+,d2/a2
  rts


;-----------------------------------
;   Free Message Port Resources
;-----------------------------------
; FreePort(port)
;           a0
;
FreePort:
  clr.l   mp_sigtask(a0)
  move.b  mp_sigbit(a0),d0
  bmi.s   .done
  EXEC    FreeSignal
.done:
  rts


; -------------------------- our process -------------------------------

   cnop    0,4                 ; long word align
   dc.l    16                  ; segment length -- any number will do
myproc_seglist:
   dc.l    0                   ; pointer to next segment
Proc_Begin:
   move.l  4(sp),a3            ; a3 = Unit
   moveq   #-1,d0
   EXEC    allocsignal
   move.b  d0,mp_sigbit(a3)
   move.b  #PA_SIGNAL,mp_flags(a3)        ; make msgport 'live'
   moveq   #0,d7
   bset    d0,d7
   lea     timeport(pc),a0
   bsr     initport                       ; init diskchange timer port
   lea     timeport(pc),a0
   move.b  mp_sigbit(a0),d0
   bset    d0,d7
   bsr     Start_Timer                    ; start diskchange timer
   moveq   #0,d6
   bra     Proc_GetIO
Proc_MainLoop:
   move.l  d7,d0
   EXEC    Wait                           ; wait for next message
   move.l  d0,d6
Proc_CheckStatus:
   btst    #MDUB_STOPPED,unit_flags(a3)
   bne.s   Proc_Do_Time                   ; unit stopped ?
Proc_IO:
   move.b  mp_sigbit(a3),d0
   bclr    d0,d6                          ; new ioreq ?
   bne.s   Proc_GetIO
   bra.s   Proc_Timer
Proc_DoIO:
   move.l  d0,a1
   move.l  mdu_Device(a3),a6
   bsr     PerformIO                      ; process the ioreq
Proc_GetIO:
   move.l  a3,a0
   EXEC    GetMsg                         ; get next message
   tst.l   d0
   bne.s   Proc_DoIO                      ; got all messages ?
Proc_Do_Time:
   lea     timeport(pc),a0
   move.b  mp_sigbit(a0),d0
   bclr    d0,d6                          ; signal from timer ?
   beq     Proc_reset_timer
   EXEC    GetMsg                         ; get timer message
Proc_reset_timer:
   bsr     Start_Timer                    ; reset timer after iorequest
   bra     Proc_MainLoop
Proc_Timer:
   lea     timeport(pc),a0                ; no iorequests recently so...
   move.b  mp_sigbit(a0),d0
   bclr    d0,d6                          ; signal from timer ?
   beq     Proc_MainLoop
   EXEC    GetMsg                         ; get timer message
   bsr     ReportChangeState              ; report diskchanges
   bsr     Start_Timer                    ; restart timer
   bra     Proc_MainLoop



;========================= device-specific code ======================

;---------------------------------------------------------------------
;                       Open Timer Device
;---------------------------------------------------------------------
;
OpenTimer:
  move.l   timereq+io_device(pc),d0
  bne.s    .done                         ; already opened ?
  bug      <"ppazip: OpenTimer  ">
  lea      replyport(pc),a0
  bsr      InitPort                      ; init replyport
  moveq    #UNIT_MICROHZ,d0
  moveq    #0,d1
  lea      timername(pc),a0
  lea      delayreq(pc),a1
  EXEC     OpenDevice                    ; open timer device
  tst.l    d0
  bne.s    .error
  lea      delayreq(pc),a0
  lea      timereq(pc),a1
  move.l   io_device(a0),io_device(a1)   ; copy device/unit
  move.l   io_unit(a0),io_unit(a1)
  bug      <"OK",10>
  ifd      debug
  bra.s    .done
  endc
.error:
  bug      <"failed!",10>
.done:
  rts

;---------------------------------------------------------------------
;               Start Timer for DiskChange Polling
;---------------------------------------------------------------------
;
; error = Start_Timer()
;
Start_timer:
  lea      timereq(pc),a1
  move.l   #3,iotv_time+tv_secs(a1)         ; signal after 3 seconds
  move.l   #0,iotv_time+tv_micro(a1)
  move.w   #TR_ADDREQUEST,io_command(a1)
  EXEC     SendIO
  rts


;---------------------------------------------------------------------
;                       Report DiskChanges
;---------------------------------------------------------------------
;
ReportChangeState:
  movem.l d2/a2,-(sp)
  bsr     CheckDisk                    ; 0 = in, -1 = out
  btst    #MDUB_DISKIN,unit_flags(a3)
  bne.s   .wasin
  btst    #MDUB_READY,unit_flags(a3)   ; disk was out and is out ?
  beq     .done
  bra.s   .changed
.wasin:
  btst    #MDUB_READY,unit_flags(a3)   ; disk was in and is in ?
  bne     .done
.changed:
  bchg    #MDUB_DISKIN,unit_flags(a3)
  addq.l  #1,mdu_changecount(a3)
  move.l  mdu_removelist(a3),a2
.nextremove:
  move.l  (a2),d2
  beq     .dochange
  move.l  a2,a1
  bug     <"ppazip: Cause RemoveInt $%08lx",10>,a1
  EXEC    Cause
  move.l  d2,a2
  bra.s   .nextremove
.dochange:
  move.l  mdu_changelist(a3),a2
.nextchange:
  move.l  (a2),d2
  beq.s   .done
  move.l  a2,a1
  move.l  io_data(a1),d0
  beq.s   .noint
  move.l  d0,a1
  bug     <"ppazip: Cause ChangeInt $%08lx",10>,a1
  EXEC    Cause
.noint:
  move.l  d2,a2
  bra.s   .nextchange
.done:
  movem.l (sp)+,d2/a2
  rts


;------------------------------------------------------
;                     Time Delay
;------------------------------------------------------
; in: d0 = delay in uS
;
; NOTE:  - long delays must be single-threaded
;
timedelay:
  movem.l  d0-d2/a0/a1/a6,-(sp)
  tst.l    d0                            ; no do weird delay time!
  ble      .done
  lea      delayreq(pc),a1
  tst.l    io_device(a1)                 ; timer device open ?
  beq      .delayloop
  moveq    #0,d1
  move.l   #1000000,d2
.divide:
  sub.l    d2,d0
  bmi.s    .set
  addq.l   #1,d1                         ; calculate seconds, microseconds
  bra.s    .divide
.set:
  add.l    d2,d0
  move.l   d1,iotv_time+tv_secs(a1)
  move.l   d0,iotv_time+tv_micro(a1)
  move.w   #TR_ADDREQUEST,io_command(a1)
  lea      replyport(pc),a0
  bsr      InitPort                      ; init replyport
  tst.l    d0
  bne.s    .error
  lea      delayreq(pc),a1
  EXEC     DoIO                          ; do time delay
  lea      replyport(pc),a0
  bsr      freeport                      ; free replyport's sigbit
  bra.s    .done
.error:
  bug      <"ppazip: no spare sigbits!",10>      ; eek!
.delayloop:
  tst.b    $bfe001                       ; busy loop
  subq.l   #1,d0
  bne.s    .delayloop
.done:
  movem.l  (sp)+,d0-d2/a0/a1/a6
  rts


;-------------------------------------------------------------
;            Get Exclusive use of Joystick Port
;-------------------------------------------------------------
;
GetGamePort:
  lea     gameio(pc),a1
  lea     gamename(pc),a0
  moveq   #1,d0                          ; unit 1 = joystick port
  moveq   #0,d1
  EXEC    OpenDevice                     ; open gameport.device
  tst.l   d0
  bne     .nodevice
.get:
  EXEC    Forbid                         ; prevent task switching
  lea     gameio(pc),a1
  move.w  #GPD_ASKCTYPE,io_command(a1)
  moveq   #1,d0                          ; 1 byte for joytype
  move.l  d0,io_length(a1)
  lea     joytype(pc),a0
  move.l  a0,io_data(a1)
  move.b  #IOF_QUICK,io_flags(a1)
  EXEC    DoIO                           ; read controller type
  lea     joytype(pc),a0
  moveq   #-1,d0                         ; error if already allocated
  cmp.b   #GPCT_NOCONTROLLER,(a0)
  bne.s   .permit                        ; already allocated ?
  lea     gameio(pc),a1
  move.w  #GPD_SETCTYPE,io_command(a1)
  moveq   #1,d0
  move.l  d0,io_length(a1)
  move.b  #GPCT_ALLOCATED,(a0)           ; allocate gameport
  move.l  a0,io_data(a1)
  move.b  #IOF_QUICK,io_flags(a1)
  EXEC    DoIO                           ; set controller type
  moveq   #0,d0                          ; OK
.permit:
  EXEC    Permit                         ; allow task switching
  tst.l   d0
  beq.s   .done                          ; got it ?
.error:
  clr.b   (a0)                           ; no joytype
  lea     nojoytext(pc),a0
  bsr     AutoRequest                    ; 'joystick port in use' requester
  tst.l   d0
  bne     .get                           ; again if user selected 'retry'
.nodevice:
  moveq   #-1,d0
.done:
  rts



;------------------------------------------------------
;                 Free Joystick Port
;------------------------------------------------------
;
FreeGamePort:
  lea     gameio(pc),a1
  tst.l   io_device(a1)                  ; got the device ?
  beq.s   .done
  move.w  #GPD_SETCTYPE,io_command(a1)
  moveq   #1,d0
  move.l  d0,io_length(a1)
  lea     joytype(pc),a0
  move.b  #GPCT_NOCONTROLLER,(a0)        ; gameport not allocated
  move.l  a0,io_data(a1)
  move.b  #IOF_QUICK,io_flags(a1)
  EXEC    doio                           ; set controller type
  lea     gameio(pc),a1
  EXEC    closedevice                    ; close gameport.device
.done:
  rts

;------------------------------------------------------
;        Get Exclusive use of Parallel Port
;------------------------------------------------------
; Error = getparallelport()
;  D0
;
GetParallelPort:
  move.l  a6,-(sp)
  move.l  miscbase(pc),d0
  bne.s   .getpar
  lea     miscname(pc),a1
  EXEC    openresource               ; open misc.resource
  move.l  d0,miscbase
  beq.s   .nosys
.getpar:
  move.l  d0,a6
  moveq   #MR_PARALLELBITS,d0        ; give us the parallel bits
  lea     myname(pc),a1
  jsr     MR_Allocmiscresource(a6)
  tst.l   d0
  bne.s   .error
  moveq   #MR_PARALLELPORT,d0
  lea     myname(pc),a1
  jsr     MR_Allocmiscresource(a6)   ; give us the parallel port
  tst.l   d0
  beq.s   .done                      ; did we get the port ?
  moveq   #MR_PARALLELBITS,d0
  jsr     MR_Freemiscresource(a6)
.error:
  lea     NoPortText(pc),a0
  bsr     AutoRequest
  tst.l   d0
  bne.s   .getpar
.nosys:
  moveq   #-1,D0                     ; error
.done:
  move.l  (sp)+,a6
  rts

;===========================================
;    display a retry/cancel requester
;===========================================
;  in: a0 = message text
;
; out: d0 = choice
;
AutoRequest:
  movem.l d2/d3/a2/a3/a6,-(sp)
  moveq   #0,d2                      ; default choice = cancel
  move.l  a0,a2
  lea     Intuiname(pc),a1
  moveq   #0,d0
  EXEC    OpenLibrary                ; open intuition library
  tst.l   d0
  beq.s   .nosys
  move.l  d0,a6
  moveq   #0,d0
  move.l  d0,d1
  move.l  d0,a0
  move.l  #300,d2
  move.l  #70,d3
  move.l  a2,a1
  lea     yestext(pc),a2
  lea     notext(pc),a3
  jsr     _LVOAutoRequest(a6)        ; create requester and wait for choice
  move.l  d0,d2
  move.l  a6,a1
  EXEC    CloseLibrary
.nosys:
  move.l  d2,d0                      ; return choice
  movem.l (sp)+,d2/d3/a2/a3/a6
  rts


;------------------------------------------------------
;               Free Parallel Port
;------------------------------------------------------
FreeParallelPort:
  move.l  a6,-(sp)
  move.l  miscbase(pc),d0
  beq.s   .done
  move.l  d0,a6
  moveq   #MR_PARALLELBITS,d0
  jsr     MR_Freemiscresource(A6)
  moveq   #MR_PARALLELPORT,d0
  jsr     MR_Freemiscresource(A6)
.done:
  move.l  (sp)+,a6
  rts



;--------------------------------------------------------
;              do SCSI Read/Write/Format
;--------------------------------------------------------
;
;  in:  a0 = buffer
;       a1 = ioreq
;       d0 = offset
;       d1 = length
;
;  out: d0 = status information
;
;       bits 31-24 = error flags
;            23-16 = status port (if phase error)
;             15-8 = message byte
;              7-0 = status byte
;
SCSI_ReadWrite:
    movem.l d2-d4/a1/a2/a6,-(sp)
    move.l  a0,a2                  ; a2 = buffer
    move.l  d1,d4                  ; d4 = length
    moveq   #0,d2                  ; status = OK
    lea     cmdbuf(pc),a0          ; a0 = SCSI command block
    clr.b   1(a0)
    lsr.l   #8,d0                  ; startsec = offset/512
    lsr.l   #1,d0
    move.l  d0,2(a0)               ; put startsec into command block
    clr.b   6(a0)
    move.l  d4,d0
    lsr.l   #1,d0                  ; numsects=length/512
    lsr.l   #8,d0
    move.b  d0,8(a0)
    lsr.w   #8,d0                  ; put numsects into command block
    move.b  d0,7(a0)
    clr.b   9(a0)
    cmp.w   #CMD_READ,io_command(a1)
    bne.s   .write
.read:
    ifd     verbose
    bug     <"ppazip: cmd_read(%07lx,%06lx)",10>,io_offset(a1),io_length(a1)
    endc
    move.b  #$28,(a0)              ; scsi READ(10) command
    bra.s   .docmd
.write:
    ifd     verbose
    bug     <"ppazip: cmd_write(%07lx,%06lx)",10>,io_offset(a1),io_length(a1)
    endc
    move.b  #$2a,(a0)              ; scsi WRITE(10) command
.docmd:
    bsr     connect                ; SCSI connect
    bsr     pp_select
    tst.l   d0                     ; select SCSI target
    bne.s   .selecterror
    move.l  #SLCT_TIMEOUT,d0
    bsr     pp_wait                ; wait for command phase
    tst.l   d0
    bmi     .badphase
    bsr     pp_command             ; send command string
    tst.l   d0
    bmi     .badphase
    move.l  #DATA_TIMEOUT,d0
    bsr     pp_wait
    cmp.w   #READ,d0               ; data phase (read) ?
    beq     .rd
    cmp.w   #WRITE,d0              ; data phase (write) ?
    beq     .wr
    cmp.w   #STATUS,d0             ; status phase?
    bne     .badphase
    bset    #EarlyStatusBit,d2     ; oops, command not accepted!
    bra     .getstatbyte
.selecterror:
    bset    #SelectErrorBit,d2     ; failed to select drive
    bra     .done
.rd move.w  #0,d3
.waitread:
    move.l  #10000,d0
    bsr     timedelay              ; wait 10ms for data ready
    moveq   #1,d0
    bsr     pp_wait
    cmp.w   #READ,d0               ; still in READ DATA phase ?
    bne     .badphase
    move.l  d4,d0
    move.l  a2,a0
    bsr     getblock               ; read data block
    bra.s   .xfrdone
.wr move.l  d4,d0
    move.l  a2,a0                  ; write data block
    bsr     putblock
.xfrdone:
    moveq   #0,d3
.waitstat:
    move.l  #STAT_TIMEOUT,d0
    bsr     pp_wait                ; wait until r/w completed
    tst.l   d0
    bmi     .timeout
    cmp.w   #STATUS,d0             ; status phase ?
    beq     .getstatbyte
    addq.l  #1,d3                  ; try again
    cmp.w   #1000,d3               ; exceeded max tries?
    blo.s   .waitstat
    bug     <"ppazip: Unexpected Status %03lx",10>,d0
    cmp.w   #READ,d0
    bne.s   .badphase
    moveq   #0,d1
.getjunk:
    bsr     getbyte
    move.l  #STAT_TIMEOUT,d0
    bsr     pp_wait
    tst.l   d0
    bmi.s   .badphase
    addq.l  #1,d1
    cmp.w   #STATUS,d0
    bne.s   .getjunk
    bug     <"ppazip: read %ld extra bytes",10>,d1
    bsr     getbyte
    move.l  #MESG_TIMEOUT,d0
    bsr     pp_wait                ; wait for message byte
    tst.l   d0
    bmi.s   .badphase
    bsr     getbyte
.badphase:
    bset    #PhaseErrorBit,d2      ; invalid phase
    swap    d2
    move.b  d0,d2                  ; return status port bits
    swap    d2
    bra     .done
.getstatbyte:
    bsr     getbyte                ; get status byte
    move.b  d0,d2
.waitmsg:
    move.l  #MESG_TIMEOUT,d0
    bsr     pp_wait                ; wait for message byte
    tst.l   d0
    bge.s   .msg
.timeout:
    bset    #TimeOutBit,d2         ; timed out waiting for msg
    bra.s   .done
.msg:
    bsr     getbyte                ; get message byte
    lsl.w   #8,d0
    or.w    d0,d2
.done:
    bsr     disconnect             ; SCSI disconnect
    move.l  d2,d0
    movem.l (sp)+,d2-d4/a1/a2/a6
    rts


;--------------------------------------------------------------
;               Send a SCSI command string
;--------------------------------------------------------------
;
pp_command:
    lea     cmdbuf(pc),a0
.cmdloop
    moveq   #0,d0
    move.b  (a0)+,d0
    move.b  d0,dataport           ; send command byte
    delay
    bclr    #JOYBIT,jport
    delay                         ; pulse autofeedxt
    bset    #JOYBIT,jport
    delay
    move.l  #COMD_TIMEOUT,d0
    bsr     pp_wait               ; wait for command byte accepted
    tst.l   d0
    bmi.s   .done
    cmp.w   #COMAND,d0
    beq     .cmdloop
.done:
    rts


;--------------------------------------------------------------
;          Select ZIP drive as SCSI device 6
;--------------------------------------------------------------
pp_select:
    move.l  d2,-(sp)
    move.w  #SEL_TIMEOUT,d2
.wait:
    bsr     getstat
    btst    #ACKBIT,d0             ; wait until not selected
    beq.s   .select
.waitns:
    dbf     d2,.wait
    bra     .error                 ; error if timed out
.select:
    setmode PPOUT
    delay
    move.b  #1<<6,dataport         ; send target SCSI address
    delay
    bclr    #JOYBIT,jport
    delay                          ; pulse autofeedxt
    bset    #JOYBIT,jport
    delay
    move.b  #$80,dataport
    delay
    setmode PPHOST                 ; send 'select target' ctrl byte
    delay
    move.w  #SEL_TIMEOUT,d2
.waitdrive:
    bsr     getstat
    btst    #ACKBIT,d0             ; wait until selected
    bne.s   .good
    dbf     d2,.waitdrive
.error:                            ; error if timed out
    moveq   #-1,d2
    bra.s   .done
.good:
    moveq   #0,d2
.done:
    setmode PPOUT
    delay
    move.l  d2,d0
    move.l  (sp)+,d2
    rts



;----------------------------------
;    send SCSI connect request
;----------------------------------
;
connect:
     move.l  d0,-(sp)
     moveq   #$00,d0
     bsr     conbyte
     moveq   #$3c,d0
     bsr     conbyte
     moveq   #$20,d0
     bsr     conbyte
     move.b  #$8f,d0
     bsr     conbyte
     move.l  (sp)+,d0
     rts


;----------------------------------
;      send a connect byte
;----------------------------------
;
;   d0 = connect byte
;
conbyte:
     move.b  d0,dataport
     delay
     setmode PPSTAT
     delay
     bclr    #JOYBIT,jport
     delay
     bset    #JOYBIT,jport
     delay
     setmode PPOUT
     delay
     rts


;----------------------------------
;  send SCSI disconnect request
;----------------------------------
;
disconnect:
     move.l  d0,-(sp)
     moveq   #$00,d0
     bsr     disbyte
     moveq   #$3c,d0
     bsr     disbyte
     moveq   #$20,d0
     bsr     disbyte
     moveq   #$0f,d0
     bsr     disbyte
     move.l  (sp)+,d0
     rts

;---------------------------------
;     send a disconnect byte
;---------------------------------
;
; d0 = disconnect byte
;
disbyte:
     move.b  d0,dataport
     delay
     setmode PPOUT
     delay
     bclr    #JOYBIT,jport
     delay
     bset    #JOYBIT,jport
     delay
     setmode PPSTAT
     delay
     setmode PPOUT
     delay
     rts

;------------------------------------------------------------
;            Get status bits from joystick port
;------------------------------------------------------------
;
getstat:
     moveq   #0,d0
     move.w  statport,d0
     and.w   #STATMASK,d0
     bchg    #9,d0           ; invert SEL
     bne.s   .1
     bchg    #8,d0           ; invert ACK
.1   bchg    #1,d0           ; invert BUSY
     bne.s   .done
     bchg    #0,d0           ; invert POUT
.done:
     rts


;----------------------------------------------------------------
;                    Wait for status bits
;----------------------------------------------------------------
;
;  in: d0 = max time to wait for ready bit
;
;
;  out: d0 = status information.
;
;        WRITE  = ZIP wants more data
;        READ   = ZIP wants to send more data
;        COMAND = ZIP wants another command byte
;        STATUS = end of transfer, ZIP is sending status byte
;        -1     = timeout
;
pp_wait:
      movem.l d1/d2,-(sp)
      move.l  d0,d2              ; d2 = max time to wait
      moveq   #0,d1              ; d1 = timeout counter
.wait bsr     getstat
      btst    #BUSYBIT,d0        ; wait until zip is not busy
      beq.s   .done
      cmp.l   #5000,d1
      blo.s   .short
      delay   5000               ; go to sleep for 5mS
      add.l   #4990,d1
.short:
      add.l   #10,d1             ; timed out ?
      cmp.l   d2,d1
      bls.s   .wait
.timeout:
      bug     <"ppazip: wait(%ld) timeout!",10>,d2
      moveq   #-1,d0             ; return error code -1
.done movem.l (sp)+,d1/d2
      rts


;------------------------------------------
;  Initialise parallel port and ZIP drive
;------------------------------------------
pp_init:
     move.l  a1,-(sp)
     move.b  #$ff,dirport
     move.b  #$ff,dataport
     setmode PPOUT
     move.b  #$c7,ctrldir
     move.b  #$80,jport
     move.b  #$83,jdir
     setmode PPINIT
     delay   1000                    ; send /init
     setmode PPOUT
     delay   100
     bsr     disconnect
     bsr     resetscsi               ; reset scsi bus
     delay   1000
     bsr     DoSense                 ; SCSI read sense info
     tst.b   d0
     bne.s   .error
     bsr     DoStart                 ; Start Media Access
     tst.b   d0
     bne.s   .error
     bsr     DoSense                 ; SCSI read sense info
     tst.b   d0
     bne.s   .error
     bug     <"ppazip: pp_init    OK",10>
     bra.s   .done
.error:
     bug     <"ppazip: init failed, check your hardware!",10>
     moveq   #-1,d0
.done:
     move.l  (sp)+,a1
     rts

resetscsi:
     bsr     connect
     bclr    #JOYBIT,jport
     delay
     bset    #JOYBIT,jport
     delay
     move.b  #$40,dataport           ; reset SCSI bus
     delay
     setmode PPHOST
     delay   30
     setmode PPOUT
     delay   1000
     bsr     disconnect
     rts


;----------------------------------------------------------------
;                Do SCSI 'Check Unit Ready'
;----------------------------------------------------------------
;
DoCheck:
     lea     cmdbuf(pc),a0
     move.l  #$00000000,(a0)       ; TEST_UNIT_READY
     move.w  #$0000,4(a0)
     bra     DoInternalSCSI


;----------------------------------------------------------------
;                Do SCSI 'Start Unit'
;----------------------------------------------------------------
;
DoStart:
     lea     cmdbuf(pc),a0
     move.l  #$1b000000,(a0)       ; START_STOP_UNIT
     move.w  #$0100,4(a0)          ; start
     bra     DoInternalSCSI


;----------------------------------------------------------------
;                Do SCSI 'Read Sense data'
;----------------------------------------------------------------
;
DoSense:
     lea     cmdbuf(pc),a0
     move.l  #$03000000,(a0)       ; READ_SENSE
     move.w  #$1200,4(a0)          ; 18 bytes
     bra     DoInternalSCSI


;----------------------------------------------------------------
;                Do SCSI 'Read Equiry data'
;----------------------------------------------------------------
;
DoEnquiry:
     lea     cmdbuf(pc),a0         ; a0 = SCSI command block
     move.l  #$12000000,(a0)       ; ENQUIRY
     move.w  #$9300,4(a0)          ;

DoInternalSCSI:
     lea     Buffer,a0
     move.l  #512,d0
     moveq   #SCSIF_READ,d1

;----------------------------------------------------------------
;                  Do Direct SCSI Command
;----------------------------------------------------------------
;
;   status, length = DoSCSI(buffer,buflen, flags)
;     d0      d1              a0     d0      d1
;
;   returned status bits:
;
;    0-7 = error code
;  23-16 = status byte
;
DoSCSI:
     movem.l d4-d7/a2,-(sp)
     move.l  a0,a2                 ; a2,d5 = data buf,len
     move.l  d0,d5
     moveq   #0,d6
     move.b  d1,d7
     bsr     connect
     bsr     pp_select             ; select target SCSI address
     moveq   #HFERR_SelTimeout,d4
     tst.l   d0
     bne     .error
     move.l  #STRT_TIMEOUT,d0
     bsr     pp_wait               ; wait for drive ready
     tst.l   d0
     bmi     .error
     bsr     pp_command            ; send SCSI command
     moveq   #HFERR_Phase,d4
     tst.l   d0                    ; command sent OK ?
     bpl.s   .dataphase
     move.l  #STRT_TIMEOUT,d0
     bsr     pp_wait               ; wait for command accepted
     tst.l   d0
     bmi     .error
.dataphase:
     moveq   #HFERR_DMA,d4
     cmp.w   #READ,d0              ; now in READ phase ?
     bne.s   .notread
     btst    #SCSIB_READ_WRITE,d7
     beq     .error                ; should be 1 for read
     move.l  a2,a0
     move.l  d5,d0
     bsr     getbytes              ; read data into buffer
     move.l  d0,d5
     move.l  #DATA_TIMEOUT,d0
     bsr     pp_wait               ; wait for status phase
     tst.l   d0
     bmi.s   .done
     bra.s   .status
.notread:
     cmp.w   #WRITE,d0
     beq.s   .write
     moveq   #0,d5                 ; not read or write so no data
     bra.s   .status
.write:
     btst    #SCSIB_READ_WRITE,d7
     bne.s   .error
     move.l  a2,a0
     move.l  d5,d0
     bug     <"ppazip: put %ld bytes",10>,d0
     bsr     putbytes              ; write data out of buffer
     move.l  d0,d5
     move.l  #DATA_TIMEOUT,d0
     bsr     pp_wait               ; wait for status phase
     tst.l   d0
     bmi.s   .done
.status:
     moveq   #HFERR_Phase,d4
     cmp.w   #STATUS,d0            ; want to read status byte ?
     bne.s   .done
     bsr     getbyte               ; get status byte
     move.b  d0,d6
     move.l  #MESG_TIMEOUT,d0
     bsr     pp_wait
     tst.l   d0
     bmi.s   .done
     bsr     getbyte               ; get message byte
     moveq   #0,d4
     bra.s   .done
.error:
     moveq   #0,d5                 ; no data
.done:
     bsr     disconnect
.ok: moveq   #0,d0
     move.b  d6,d0
     swap    d0
     move.b  d4,d0
     move.l  d5,d1
     movem.l (sp)+,d4-d7/a2
     rts



;--------------------------------------------------------------------
;                     output a block
;--------------------------------------------------------------------
;
;    putblock(buffer,len)
;               a0    d0
putblock:
      movem.l d1-d2/a1-a2,-(sp)
      lea     dataport,a1
      lea     jport,a2
      move.b  (a2),d2
      move.b  d2,d1
      bclr    #JOYBIT,d1
.loop rept  8
        move.b  (a0)+,(a1)
        move.b  d1,(a2)
        move.b  d2,(a2)
      endr
      subq.l  #8,d0
      bne.s   .loop
.done movem.l (sp)+,d1-d2/a1-a2
      rts

;---------------------------------------------------------------------
;                       write some bytes
;---------------------------------------------------------------------
;    actual=putbytes(buffer,numbytes)
;      d0              a0     d0
putbytes:
      bug     <"ppazip: putbytes",10>
      movem.l d2/d3,-(sp)
      move.l  d0,d3
      moveq   #0,d2
.loop move.b  (a0)+,d0
      bsr     putbyte
      addq.l  #1,d2
      bsr     getstat
      cmp.w   #WRITE,d0
      bne.s   .done
      cmp.l   d3,d2
      blo.s   .loop
.done:
      move.l  d2,d0
      movem.l (sp)+,d2/d3
      rts


;--------------------------------------------------------------------
;                      output a single byte
;--------------------------------------------------------------------
;      putbyte(byte)
;               d0
putbyte:
      move.b  d0,dataport
      delay
      bclr    #JOYBIT,jport
      delay
      bset    #JOYBIT,jport
      delay
      rts


;--------------------------------------------------------------------
;                         read a block
;---------------------------------------------------------------------
;    getblock(buffer,len)
;               a0    d0
getblock:
      movem.l d1-d3/a1-a2,-(sp)
      move.l  d0,d3
      lea     dataport,a1
      lea     jport,a2
      move.b  (a2),d2
      move.b  d2,d1
      bclr    #JOYBIT,d1
      move.b  #$00,dirport          ; port direction set to input
      setmode PPIN
      delay
.loop:
      rept 8
        move.b  (a1),(a0)+          ; get byte
        move.b  d1,(a2)
        move.b  d2,(a2)             ; 'data accepted' pulse
      endr
      subq.l  #8,d3
      bne.s   .loop
.done:
      setmode PPSTAT
      move.b  #$ff,dirport          ; port direction set to output
      delay
      setmode PPOUT
      delay
      movem.l (sp)+,d1-d3/a1-a2
      rts


;---------------------------------------------------------------------
;                       read some bytes
;---------------------------------------------------------------------
;    actual=getbytes(buffer,numbytes)
;      d0                a0    d0
;
getbytes:
      movem.l d2/d3,-(sp)
      move.l  d0,d3
      moveq   #0,d2
.loop bsr     getbyte
      move.b  d0,(a0)+
      addq.l  #1,d2
      bsr     getstat
      cmp.w   #READ,d0
      bne.s   .done
      cmp.w   d3,d2
      blo.s   .loop
.done:
      move.l  d2,d0
      movem.l (sp)+,d2/d3
      rts


;---------------------------------------------------------------------
;                     read a single byte
;---------------------------------------------------------------------
;      d0 = getbyte()
;
getbyte:
      move.b  #$00,dirport          ; port direction set to input
      setmode PPIN
      delay
      move.b  dataport,d1           ; get byte
      delay
      bclr    #JOYBIT,jport
      delay                         ; 'data accepted' pulse
      bset    #JOYBIT,jport
      setmode PPSTAT
      move.b  #$ff,dirport          ; port direction set to output
      delay
      setmode PPOUT
      delay
      move.l  d1,d0
      rts



; ---------------- static data -------------------

MyName:
   dc.b 'ppazip.device',0
idString:
   dc.b 'ppazip '
   dc.b (VERSION+"0"),'.',(REVISION+"0"),' '
   dc.b __DATE
   dc.b ' by Bruce Abbott',10,0
miscname
   dc.b 'misc.resource',0
intuiname:
   dc.b 'intuition.library',0
timername:
   dc.b 'timer.device',0
gamename:
   dc.b 'gameport.device',0
   even

Yestext:
  dc.b 2,1
  dc.b 1
  dc.b 0
  dc.w 6,4
  dc.l 0
  dc.l .Text
  dc.l 0

.Text:
  dc.b  "RETRY",0
  even

Notext:
  dc.b 2,1
  dc.b 1
  dc.b 0
  dc.w 6,4
  dc.l 0
  dc.l .Text
  dc.l 0

.Text:
  dc.b  "CANCEL",0
  even


NoPortText:
  dc.b  3,1
  dc.b  1
  dc.b  0
  dc.w  10,20
  dc.l  0
  dc.l  .txt
  dc.l  0
.txt:
  dc.b  'ppazip: parallel port in use!',0

NoJoyText:
  dc.b  3,1
  dc.b  1
  dc.b  0
  dc.w  10,20
  dc.l  0
  dc.l  .txt
  dc.l  0
.txt:
  dc.b  'ppazip: joystick port in use!',0

  even



EndCode:

; ---------------- variable data -----------------

execbase:
   dc.l  0     ; cached execbase
miscbase:
   dc.l  0     ; misc resource


; ---- IO Request for DiskChange Polling ----
;
; NOTE: used only by our task
;
TimeReq:
   dc.l 0           ; ln_head  }         }
   dc.l 0           ; ln_pred  }         }
   dc.b NT_MESSAGE  ; ln_type  } mp_node }
   dc.b 0           ; ln_pri   }         } io_message
   dc.l 0           ; ln_name  }         }
   dc.l timeport    ; mn_replyport       }
   dc.w iotv_size   ; mn_length          }
   dc.l 0           ;                      io_device
   dc.l 0           ;                      io_unit
   dc.w 0           ;                      io_command
   dc.b 0           ;                      io_flags
   dc.b 0           ;                      io_error
   dc.l 0           ;                      tv_secs
   dc.l 0           ;                      tv_micros



; ---- IO Request for Time Delay ----
;
; NOTE: may be used by calling tasks
;
DelayReq:
   dc.l 0           ; ln_head  }         }
   dc.l 0           ; ln_pred  }         }
   dc.b NT_MESSAGE  ; ln_type  } mp_node }
   dc.b 0           ; ln_pri   }         } io_message
   dc.l 0           ; ln_name  }         }
   dc.l replyport   ; mn_replyport       }
   dc.w iotv_size   ; mn_length          }
   dc.l 0           ;                      io_device
   dc.l 0           ;                      io_unit
   dc.w 0           ;                      io_command
   dc.b 0           ;                      io_flags
   dc.b 0           ;                      io_error
   dc.l 0           ;                      tv_secs
   dc.l 0           ;                      tv_micros


; ---- IO Request for Obtaining Joystick Port ----

gameio:
   dc.l 0           ; ln_head  }         }
   dc.l 0           ; ln_pred  }         }
   dc.b NT_MESSAGE  ; ln_type  } mp_node }
   dc.b 0           ; ln_pri   }         } io_message
   dc.l 0           ; ln_name  }         }
   dc.l replyport   ; mn_replyport       }
   dc.w iostd_size  ; mn_length          }
   dc.l 0           ;                      io_device
   dc.l 0           ;                      io_unit
   dc.w 0           ;                      io_command
   dc.b 0           ;                      io_flags
   dc.b 0           ;                      io_error


; ----  Signalling Message Port ----
;
;
TimePort:
   dc.l 0           ; ln_head      }
   dc.l 0           ; ln_pred      }
   dc.b NT_MSGPORT  ; ln_type      } mp_node
   dc.b 0           ; ln_pri       }
   dc.l 0           ; ln_name      }
   dc.b PA_SIGNAL   ;                mp_flags
   dc.b 0           ;                mp_sigbit
   dc.l 0           ;                mp_sigtask
.h dc.l .t          ; lh_head      }
.t dc.l 0           ; lh_tail      }
   dc.l .h          ; lh_tailpred  } mp_msglist
   dc.b 0           ; lh_type      }
   dc.b 0           ; lh_pad       }


; ----  Signalling Message Port ----
;
; NOTE: may be used by calling tasks
;
ReplyPort:
   dc.l 0           ; ln_head      }
   dc.l 0           ; ln_pred      }
   dc.b NT_MSGPORT  ; ln_type      } mp_node
   dc.b 0           ; ln_pri       }
   dc.l 0           ; ln_name      }
   dc.b PA_SIGNAL   ;                mp_flags
   dc.b 0           ;                mp_sigbit
   dc.l 0           ;                mp_sigtask
.h dc.l .t          ; lh_head      }
.t dc.l 0           ; lh_tail      }
   dc.l .h          ; lh_tailpred  } mp_msglist
   dc.b 0           ; lh_type      }
   dc.b 0           ; lh_pad       }


joytype:
   dc.b  0     ; joystick controller type
   even

cmdbuf:
   ds.b 12
   even

    BSS

buffer:
   ds.b  512

   END
