*INTRRUPT       SET     1       ; Remove "*" to enable fake interrupt code

; stack size and priority for the process we will create
MYPROCSTACKSIZE EQU     $800
MYPROCPRI       EQU     0

SECTOR          EQU     512     ; # bytes per sector
SECSHIFT        EQU     9       ; Shift count to convert byte # to sector #
RAMSIZE         EQU     512*200 ; Use this much RAM per unit
IAMPULLING      EQU     7       ; "I am pulling the interrupt" bit of INTCRL1
INTENABLE       EQU     4       ; "Interrupt Enable" bit of INTCRL2
INTCTRL1        EQU     $40     ; Interrupt control register offset on board
INTCTRL2        EQU     $42     ; Interrupt control register offset on board
INTACK          EQU     $50     ; My board's interrupt reset address
;-----------------------------------------------------------------------
;
; device command definitions
;
;-----------------------------------------------------------------------

        DEVINIT
        DEVCMD  CMD_MOTOR       ; control the disk's motor (NO-OP)
        DEVCMD  CMD_SEEK        ; explicit seek (NO-OP)
        DEVCMD  CMD_FORMAT      ; format disk - equated to WRITE for RAMDISK
        DEVCMD  CMD_REMOVE      ; notify when disk changes (NO-OP)
        DEVCMD  CMD_CHANGENUM   ; number of disk changes (always 0)
        DEVCMD  CMD_CHANGESTATE ; is there a disk in the drive? (always TRUE)
        DEVCMD  CMD_PROTSTATUS  ; is the disk write protected? (always FALSE)
        DEVCMD  CMD_RAWREAD     ; Not supported
        DEVCMD  CMD_RAWWRITE    ; Not supported
        DEVCMD  CMD_GETDRIVETYPE; Get drive type
        DEVCMD  CMD_GETNUMTRACKS; Get number of tracks
        DEVCMD  CMD_ADDCHANGEINT; Add disk change interrupt (NO-OP)
        DEVCMD  CMD_REMCHANGEINT; Remove disk change interrupt ( NO-OP)
        DEVCMD  CMD_READCONFIG  ; Read Config from buffer
        DEVCMD  MYDEV_END       ; place marker -- first illegal command #

;-----------------------------------------------------------------------
;
; Layout of parameter packet for MakeDosNode
;
;-----------------------------------------------------------------------

    STRUCTURE MkDosNodePkt,0
        APTR    mdn_dosName     ; Pointer to DOS file handler name
        APTR    mdn_execName    ; Pointer to device driver name
        ULONG   mdn_unit        ; Unit number
        ULONG   mdn_flags       ; OpenDevice flags
        ULONG   mdn_tableSize   ; Environment size
        ULONG   mdn_sizeBlock   ; # longwords in a block
        ULONG   mdn_secOrg      ; sector origin -- unused
        ULONG   mdn_numHeads    ; number of surfaces
        ULONG   mdn_secsPerBlk  ; secs per logical block -- unused
        ULONG   mdn_blkTrack    ; secs per track
        ULONG   mdn_resBlks     ; reserved blocks -- MUST be at least 1!
        ULONG   mdn_prefac      ; unused
        ULONG   mdn_interleave  ; interleave
        ULONG   mdn_lowCyl      ; lower cylinder
        ULONG   mdn_upperCyl    ; upper cylinder
        ULONG   mdn_numBuffers  ; number of buffers
        ULONG   mdn_memBufType  ; Type of memory for AmigaDOS buffers
        STRUCT  mdn_dName,5     ; DOS file handler name "RAM0"
        LABEL   mdn_Sizeof      ; Size of this structure

;-----------------------------------------------------------------------
;
; device data structures
;
;-----------------------------------------------------------------------

; maximum number of units in this device
MD_NUMUNITS     EQU     2

    STRUCTURE MyDev,LIB_SIZE
        ULONG   md_SysLib
        ULONG   md_SegList
        ULONG   md_CAddr
        ULONG   md_Process
        UBYTE   md_Flags
        UBYTE   md_pad
        STRUCT  md_Units,MD_NUMUNITS*4
        STRUCT  md_Base,CurrentBinding_SIZEOF;         Base address of this device's expansion board
        LABEL   MyDev_Sizeof

    STRUCTURE MyDevMsg,MN_SIZE
        APTR    mdm_Device
        APTR    mdm_Unit
        LABEL   MyDevMsg_Sizeof

    STRUCTURE MyDevUnit,UNIT_SIZE
        APTR    mdu_Device
        ULONG   mdu_SigMask             ; Signal these bits on interrupt
        UBYTE   mdu_UnitNum
        UBYTE   mdu_SigBit              ; Signal bit allocated for interrupts
        UBYTE   mdu_UnitMask            ; Mask for drive no.
        LABEL   MyDevUnit_Sizeof

        ;------ state bit for unit stopped
        BITDEF  MDU,STOPPED,2

   STRUCTURE MyProc,UNIT_SIZE
      STRUCT   mp_stack,MYPROCSTACKSIZE
      STRUCT   mp_is,IS_SIZE          ; Interrupt structure
      STRUCT   mp_tcb,TC_SIZE         ; TCB for disk task
      STRUCT   mp_Msg,MyDevMsg_Sizeof
      LABEL    MyProc_Sizeof

