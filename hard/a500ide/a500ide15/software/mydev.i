MYPROCSTACKSIZE   EQU   $1800
MYPROCPRI   EQU   5


   DEVINIT
   DEVCMD   CMD_MOTOR    ; control the disk's motor (NO-OP)
   DEVCMD   CMD_SEEK     ; explicit seek (NO-OP)
   DEVCMD   CMD_FORMAT   ; format disk - equated to WRITE for RAMDISK
   DEVCMD   CMD_REMOVE   ; notify when disk changes (NO-OP)
   DEVCMD   CMD_CHANGENUM     ; number of disk changes (always 0)
   DEVCMD   CMD_CHANGESTATE   ; is there a disk in the drive? (always TRUE)
   DEVCMD   CMD_PROTSTATUS    ; is the disk write protected? (always FALSE)
   DEVCMD   CMD_RAWREAD       ; Not supported
   DEVCMD   CMD_RAWWRITE      ; Not supported
   DEVCMD   CMD_GETDRIVETYPE  ; Get drive type
   DEVCMD   CMD_GETNUMTRACKS  ; Get number of tracks
   DEVCMD   CMD_ADDCHANGEINT  ; Add disk change interrupt (NO-OP)
   DEVCMD   CMD_REMCHANGEINT  ; Remove disk change interrupt ( NO-OP)
;  DEVCMD   MYDEV_END   ; place marker -- first illegal command #
MYDEV_END   EQU 29


;-----------------------------------------------------------------------
;
; device data structures
;
;-----------------------------------------------------------------------

; maximum number of units in this device
MD_NUMUNITS   EQU   $10

    STRUCTURE MyDev,LIB_SIZE
   ULONG    md_SysLib
   ULONG    md_DosLib
   ULONG    md_SegList
   ULONG    md_Base      ; Base address of this device's expansion board
   UBYTE    md_Flags
   UBYTE    md_pad
   STRUCT   md_Units,MD_NUMUNITS*4
   LABEL    MyDev_Sizeof

    STRUCTURE MyDevMsg,MN_SIZE
   APTR     mdm_Device
   APTR     mdm_Unit
   LABEL    MyDevMsg_Sizeof

    STRUCTURE MyDevUnit,UNIT_SIZE
   UBYTE    mdu_UnitNum
   UBYTE    mdu_SigBit      ; Signal bit allocated for interrupts
   APTR     mdu_Device
   STRUCT   mdu_stack,MYPROCSTACKSIZE
   STRUCT   mdu_is,IS_SIZE      ; Interrupt structure
   STRUCT   mdu_tcb,TC_SIZE      ; TCB for disk task
   STRUCT   mdu_Msg,MyDevMsg_Sizeof
   ULONG    mdu_SigMask      ; Signal these bits on interrupt
   LABEL    MyDevUnit_Sizeof

   ;------ state bit for unit stopped
   BITDEF   MDU,STOPPED,2

MYDEVNAME   MACRO
      DC.B   'ide.device',0
      ENDM

DOSNAME      MACRO
      DC.B   'dos.library',0
      ENDM
