; ide.device read/write-routines     version 1.3 aug 2000

TRUE equ 1
FALSE equ 0
; Configuration:
useinterrupt dc.l FALSE  ; interrupt routines propably don't work now
verifywrites dc.l FALSE  ; if TRUE written data is read back and compared
auto         dc.l TRUE   ; If FALSE following settings will be used
useLBA       dc.l FALSE;TRUE   ; If FALSE then CHS is used, parameters for CHS:
sectors_per_track dc.l 40; 40 sectors/4 heads for CP3044
heads        dc.l 4      ; find correct parameters from drive manual

   xref  _LVOAllocSignal ; external references
   xref  _LVOSignal      ; these will be linked from amiga.lib
   xref  _LVOWait
   xref  _LVOFindTask
   xref  _LVOAddIntServer

   include  "atid500.i" ; defines the Hardware Address of the interface
   include  "ata.i"     ; defines ATA bits and commands


;accesses to ATA-registers are done with macros
;this is for future development of parallel port IDE-interface
RATA macro
   move.b \1,\2
  endm
WATA macro
   move.b \1,\2
  endm
RATAWORD macro
   move.w \1,\2
  endm
RATADATA macro
   move.w #64-1,d0
   move.l #TF_DATA,a0
gre\@
   move.w (a0),(a5)+
   move.w (a0),(a5)+
   move.w (a0),(a5)+
   move.w (a0),(a5)+
   dbra   d0,gre\@
  endm
WATADATA macro
   move.w #256-1,d0
cva\@
   move.w (a5)+,TF_DATA
   dbra  d0,cva\@
 endm


DLY400NS macro ;wait 400 nanoseconds
   move.l   d0,-(sp)
   move.l   #2,d0
atst\@
   sub.l    #1,d0
   bne      atst\@
   move.l   (sp)+,d0
  endm

DLY5US macro ;wait 5 microseconds
   move.l   d0,-(sp)
   move.l   #9,d0
lihkhv\@
   sub.l    #1,d0
   bne      lihkhv\@
   move.l   (sp)+,d0
  endm


CMD_READ    equ 2       ;these are defined better in "exec/io.i"
IO_COMMAND  equ $1c

;some of the error codes rdwt.asm returns:
BADLENGTH   equ -4
BADUNIT     equ -1
;;;BADADDRESS equ -5 ;not needed


   Public   ATIDRdWt

ATIDRdWt:
   ;a0 io data address
   ;a1 iob 
   ;a2 == a1
   ;d0 io length
   ;d1 io offset
   ;d2 unit number
   movem.l  d1-d7/a0-a6,-(sp)
   move.l   d0,d3
   move.l   d0,a3
   move.l   #BADUNIT,d0 ;Check that unit is 0
   cmp.l    #0,d2
   bne      Quits
   move.l   #BADLENGTH,d0 ;check if length is multiple of 512
   move.l   d3,d4
   and.l    #$1ff,d4
   bne      Quits
   lsr.l    #8,d3
   lsr.l    #1,d3; number of sectors
   move.l   #BADLENGTH,d0 ; no sectors ?
   cmp.l    #0,d3
   beq      Quits
   lsr.l    #8,d1
   lsr.l    #1,d1; start block
   move.l   a0,a5
   move.l   d1,d6
   move.l   d3,d7
   cmp.l    #TRUE,firstcalltoATIDRdWt
   bne      jooei
   bsr      wasfirstcall
   cmp.l    #0,d0
   bne      Quits
jooei                ;a2 = iob !
   bsr      doblocks ;a5:startaddress, d6:startblock, d7:numberofblocks
Quits
   cmp.l    #0,d0
   beq      okcode
   bset.b   #1,$bfe001;Amiga power led off if error
okcode
   movem.l  (sp)+,d1-d7/a0-a6
   rts      ; EXIT RDWT.ASM

firstcalltoATIDRdWt dc.l TRUE
wasfirstcall
   RATA     TF_STATUS,d0;clear drive interrupt line
   move.l   #FALSE,firstcalltoATIDRdWt
   WATA     #8+SRST+nIEN,TF_DEVICE_CONTROL; no int., reset ;nIEN=2 SRST=4
   move.w   #50000,d0
vb dbra     d0,vb ;delay
   WATA     #8+nIEN,TF_DEVICE_CONTROL
   move.w   #50000,d0
bv dbra     d0,bv ;delay
 ; enable write cacheing
; bsr      waitreadytoacceptnewcommand
; WATA     #02,TF_FEATURES
; WATA     #ATA_SET_FEATURES,TF_COMMAND
   cmp.l    #TRUE,auto
   bne      notauto
   ;get drive parameters
   move.l   #FALSE,useLBA; presumption
   bsr      waitreadytoacceptnewcommand
   WATA     #DRV0,TF_DRIVE_HEAD
   WATA     #ATA_IDENTIFY_DRIVE,TF_COMMAND ; get drive data
   bsr      waitDRQ
   cmp.l    #0,d0
   beq      noeridd
   rts
noeridd
   RATA     TF_STATUS,d0 ;Clear interrupt
   move.l   A5,-(SP)    ;Let's use the buffer we have got in A5
   bsr      readdata
   move.l   (SP)+,A5    ;restore buffer start
noeritd
   ;IF Y=0 SWAP BYTES IN WORD BECAUSE AMIGA DATA0..7 IS DRIVE DATA8.15
  IFEQ Y,0
   move.l   A5,A0       ;buffer start
   movem.l  d1-d2,-(sp) ;d1-d2 to stack
   move.w   #256-1,d0   ;move.word because dbra uses 16bits of register
lk move.w   (a0),d1
   move.w   d1,d2
   lsl.w    #8,d1
   lsr.w    #8,d2
   and.w    #$ff,d2
   or.w     d2,d1
   move.w   d1,(a0)+
   dbra     d0,lk
   movem.l  (sp)+,d1-d2    ;restore d1-d2
  ENDC
   move.w   49*2(A5),d0 ;Word 49 Capabilities
   and.w    #$200,d0    ;Bit 9 1=LBA Supported
   beq      nolba
   move.w   60*2(a5),d0 ;Words 60-61 # of user addressable sectors (LBA)
   and.w    61*2(a5),d0
   beq      nolba       ;propably no lba support if no lba sectors
   move.l   #TRUE,useLBA
   bra      endauto
nolba; Then it's CHS
   move.w   6*2(a5),d0; Word 6 Default Translation sectors
   and.l    #$ffff,d0
   move.l   d0,sectors_per_track
   move.w   3*2(a5),d0 ;Word 3 Default Translation Mode number of heads
   and.l    #$ffff,d0
   move.l   d0,heads
   ;Conner Peripherals CP3044 lies about its default translation mode
   lea      CP3044txt,a0
   move.l   a5,a1
   add.l    #$50,a1
ko move.b   (a0)+,d0
   beq      wascp3044
   move.b   (a1)+,d1
   cmp.b    d0,d1
   beq      ko
   ;not cp3044
   bra      endauto
wascp3044
   move.l   #4,heads
   move.l   #40,sectors_per_track
   bra      endauto
CP3044txt dc.b  $43,$50,$33,$30,$34,$34,$20,0 ;"CP3044 "
   cnop  0,4
endauto
notauto
   RATA     TF_STATUS,d0 ;clear interrupt line
   cmp.l    #TRUE,useinterrupt
   beq      installinterruptserver
   move.l   #0,d0 ;ok, no interrupt
   rts

installinterruptserver
   RATA     TF_STATUS,d0 ;clear drive interrupt line
   movem.l  d1/a0-a1,-(sp)
   move.l   #-1,d0 ;allocate any signalbit
   move.l   4,a6
   jsr      _LVOAllocSignal(a6)
   cmp.l    #-1,d0 ;no signalbits free
   bne      oosb
   move.l   #12,d0;error
   movem.l  (sp)+,d1/a0-a1
   rts
oosb
   move.l   #0,d1
   bset.l   d0,d1
   move.l   d1,signalmask
   move.l   #0,a1 ;0 = this task
   move.l   4,a6
   jsr      _LVOFindTask(a6)
   move.l   d0,the_task
   move.w   #0,enableflag
   lea      interruptserver,a0
   move.l   a0,is_code ;where the code is
   lea      interruptserverdata,a0
   move.l   a0,is_data
   lea.l    interruptname,a0
   move.l   a0,is_node_ln_namepointer
INTB_EXTER equ 13 ;_INT6   ;these are from "hardware/intbits.i"
INTB_PORTS equ 3  ;_INT2
   move.l   #INTB_PORTS,d0 ;INTB_PORTS if _INT2 is used
   lea      interruptstructure,a1
   move.l   4,a6
   jsr      _LVOAddIntServer(a6)
 WATA #8,TF_DEVICE_CONTROL; enable drive interrupt line
   move.l   #0,d0 ;0=okay
   movem.l  (sp)+,d1/a0-a1
   rts

signalmask  ds.l  1
the_task    ds.l  1

   cnop 0,4
interruptstructure
is_node  ;node_structure
is_node_ln_succ      dc.l 0
is_node_ln_pred      dc.l 0
is_node_ln_type      dc.b  2; node type NT_INTERRUPT = 2
is_node_ln_priority  dc.b  20
is_node_ln_namepointer  dc.l 0
is_data  dc.l  0; datapointer
is_code  dc.l  0; codepointer
is_pad   ds.b  2;
 ds.l 100

   cnop 0,4 ;align to doubleword boundary 
interruptname dc.b  "ide.device",0,0;"IDE-interrupt-server",0,0

   cnop 0,4
interruptserverdata
enableflag  dc.w  0

   cnop 0,4
interruptserver
   RATA     TF_STATUS,d0 ;clear drive interrupt line
   move.l   the_task,a1  ;our ide.device task to be signalled
   move.l   signalmask,d0
   move.l   4,a6
   jsr      _LVOSignal(a6)
   move.l   #0,d0
   rts      ;Zeroflag set, following servers will continue in the chain

;   cmp.w    #0,(a1)  ;a1=interruptserverdata=enableflag
;   bne      cinb
;   rts      ;Zeroflag set, following servers will continue in the chain
;cinb ;interrupt server enabled to cause signal
   ;if enableflag set, ide.device is expecting an interrupt
;   RATA    TF_ALTERNATE_STATUS,d0
;   and.b    #BSY,d0        ;is the drive still BUSY
;   beq      olipsdjia
;   moveq    #0,d0          ;still BUSY, the drive didn't cause interrupt
;   rts      ;Zeroflag set, following servers will continue in the chain
;olipsdjia   ;Let's signal, the drive wasn't BUSY anymore
;   move.w   #0,enableflag  ;clear
;   RATA   TF_STATUS,d0
;  WATA   #8+nIEN,TF_DEVICE_CONTROL
;   move.l   the_task,a1    ;our ide.device task to be signalled
;   move.l   signalmask,d0
;   move.l   4,a6
;   jsr      _LVOSignal(a6)
;  moveq    #0,d0
;;   moveq    #1,d0 ;zfc
;   rts

RWV_READ    equ 11
RWV_WRITE   equ 12
RWV_VERIFY  equ 13
readwriteorverify dc.l 0
doblocks    ;d7=sectors>0 (A5=startaddress, d6=startblock)
   move.l   #RWV_READ,readwriteorverify
   cmp.w    #CMD_READ,IO_COMMAND(a2)
   beq      gsfg
   move.l   #RWV_WRITE,readwriteorverify
gsfg
   movem.l  d6-d7/a5,-(sp)
   bsr      dorwv ;first read or write/format
   movem.l  (sp)+,d6-d7/a5
   cmp.l    #0,d0
   beq      hgnt
   rts      ;error
hgnt
   cmp.l    #RWV_READ,readwriteorverify
   bne      hfdb
   rts      ;was read, so return
hfdb        ;was write/format
   cmp.l    #TRUE,verifywrites
   beq      letsverify
   rts      ;don't verify, so return
letsverify
   move.l   #RWV_VERIFY,readwriteorverify
   bsr      dorwv
   rts      ;d0 not zero means error
dorwv
domore
   move.l   d7,d5
   move.l   d7,d4
   and.l    #$ff,d5
   bne      between1and255
   move.l   #$100,d5 ;256 sectors
between1and255
   move.l   d5,d4 ;d5 is number of sectors in this round
   cmp.l    #RWV_READ,readwriteorverify
   beq      wasread
   cmp.l    #RWV_WRITE,readwriteorverify
   bne      wasverify
   bsr      writesectors ;Format or Write
   cmp.l    #0,d0
   beq      sectoracok
   rts
wasread
   bsr      readsectors
   cmp.l    #0,d0
   beq      sectoracok
   rts
wasverify
   bsr      comparesectors
   cmp.l    #0,d0
   beq      sectoracok
   rts      ;error
sectoracok
   add.l    d5,d6 ;next block number
   sub.l    d5,d7
   bne      domore
   move.l   #0,d0
   rts

readsectors ;d4 is the number of sectors to read (between 1 and 256)
   bsr      waitreadytoacceptnewcommand
   cmp.l    #0,d0
   bne      rsfl
   move.l   d6,d0    ;logical block number
   bsr      issueread
readnextblk
   bsr      waitinterrupt
   bsr      waitDRQ
   cmp.l    #0,d0
   bne      rsfl
   bsr      readdata
   ;wait DRQ go 0
 DLY5US
   sub.l    #1,d4
   bne      readnextblk
   bsr      checkforerrors
   cmp.l    #0,d0
   bne      rsfl
   move.l   #0,d0  ; return value 0 means OK
   rts
rsfl ;some error in reading
   rts

comparesectors ;d4 is the number of sectors to compare (between 1 and 256)
   bsr      waitreadytoacceptnewcommand
   cmp.l    #0,d0
   bne      eico
   move.l   d6,d0
   bsr      issueread
comparenextblk
   bsr      waitinterrupt
   bsr      waitDRQ
   cmp.l    #0,d0
   bne      eico
   bsr      comparedata
;  let DRQ go low
 DLY5US
   bne      eico
   sub.l    #1,d4
   bne      comparenextblk
   move.l   #0,d0  ; return value 0 means OK
   rts
eico ;some error in compare
   rts

writesectors ;d4 is the number of sectors to write (between 1 and 256)
   bsr      waitreadytoacceptnewcommand
   cmp.l    #0,d0
   bne      wekfha
   move.l   d6,d0
   bsr      issuewrite
writenextoneblockki
   bsr      waitDRQ
   cmp.l    #0,d0
   bne      wekfha
   bsr      writedata
   DLY5US   ;BSY will go high within 5 microseconds after filling buffer
   bsr      waitinterrupt
   bsr      checkforerrors
   cmp.l    #0,d0
   bne      wekfha
   sub.l    #1,d4
   bne      writenextoneblockki
   rts      ;d0==0   ok
wekfha rts  ;some error in writing

waitnotbusy
   DLY400NS ;wait BSY go high
fhffs
   RATA     TF_ALTERNATE_STATUS,D0
   and.b    #BSY,d0
   bne      fhffs
   DLY400NS ;wait for other status register bits to get valid
   rts

checkforerrors
   bsr      waitnotbusy
   RATA     TF_ALTERNATE_STATUS,d0
   and.l    #DWF+ERR,d0
   rts

waitDRQ
   bsr      waitnotbusy
wdlp
   RATA     TF_ALTERNATE_STATUS,d0
   and.b    #BSY+DRQ+DWF+ERR,d0
   cmp.b    #DRQ,d0
   bne      ntyt
   move.l   #0,d0
   rts
ntyt
   and.b    #DWF+ERR,d0
   beq      wdlp  ;no errs
   move.l   #-123,d0
   rts

waitinterrupt
   cmp.l    #TRUE,useinterrupt
   beq      wip
   DLY400NS ;wait for BSY go high (400 ns)
ze RATA     TF_STATUS,d0   ;Also clears the disabled interrupt
   and.b    #BSY,d0
   bne      ze
   rts
wip
   move.w   #10,d1
hip   ;wait if we don't need to go to interrupt routines..
   RATA     TF_ALTERNATE_STATUS,d0
   and.b    #BSY,d0
   beq      ze
   dbra     d1,hip

   move.l   signalmask,d0
   move.l   4,a6
   jsr      _LVOWait(a6)
   RATA     TF_ALTERNATE_STATUS,d0
   and.b    #BSY,d0
   bne      wip
   rts
;;_intena equ $dff09a
;;   move.w   #$4000,_intena ;Disable interrupts
;;   move.w   #1,enableflag
;;   move.b #8+0,TF_DEVICE_CONTROL;enable drive interrupt line
;;   move.w   #$C000,_intena ;enable interrupts
;;   ; tell interruptserver to signal if drive not BSY
;;   move.l   signalmask,d0
;;   move.l   4,a6
;; 
;;  jsr      _LVOWait(a6)
;;
;;   ;signal cleared by Wait()
;;   ;enableflag cleared by the server
;;   ;drive interrupt line disabled by the server
;;   ;drive in
;;   rts

waitreadytoacceptnewcommand
fovc
   bsr      waitnotbusy
   RATA     TF_ALTERNATE_STATUS,d0
   and.b    #BSY+DRDY+DWF+ERR,d0
   cmp.b    #DRDY,d0
   bne      oiuy
   move.l   #0,d0
   rts
oiuy
   and.b    #DWF+ERR,d0
   beq      fovc
   move.l   #-865,d0
   rts

readdata
   RATADATA (a5)
   rts

comparedata
   movem.l  d1-d2,-(sp)
   bsr      compura
   movem.l  (sp)+,d1-d2
   rts
compura
   move.w   #256-1,d0
compareloop
   RATAWORD TF_DATA,d1
   move.w   (a5)+,d2
   cmp.w    d1,d2
   bne      compareerrordetected
   dbra     d0,compareloop
   move.l   #0,d0
   rts

compareerrordetected bra vd
compareerrorloop
   RATAWORD TF_DATA,a0
vd dbra     d0,compareerrorloop
   move.l   #432653,d0 ;d0 not 0 == ERROR
   rts

issueread
   cmp.l    #TRUE,useLBA
   beq      issueLBAread
   bsr      getCHS
issueCHSread
   or.b     #DRV0,d2
   WATA     d2,TF_DRIVE_HEAD
   WATA     d4,TF_SECTOR_COUNT
   WATA     d0,TF_CYLINDER_LOW
   WATA     d1,TF_CYLINDER_HIGH
   WATA     d3,TF_SECTOR_NUMBER
   WATA     #ATA_READ_SECTORS,TF_COMMAND
   rts

issueLBAread
   WATA     #DRV0+L+0,TF_DRIVE_HEAD ; L=lba  lba bits 24..27
   WATA     d4,TF_SECTOR_COUNT
   WATA     d0,TF_SECTOR_NUMBER ;lba bits 0..7
   lsr.l    #8,d0
   WATA     d0,TF_CYLINDER_LOW  ;lba bits 8..15
   lsr.l    #8,d0
   WATA     d0,TF_CYLINDER_HIGH ;lba bits 16..23
   WATA     #ATA_READ_SECTORS,TF_COMMAND
   rts


writedata
   WATADATA (a5)
   rts
;;   move.w   #256-1,d0
;;wrdslmu
;;   WATA     (a5)+,TF_DATA
;;   dbra     d0,wrdslmu
;;   rts

issuewrite
   cmp.l    #TRUE,useLBA
   beq      issueLBAwrite
   bsr      getCHS
issueCHSwrite
   or.b     #DRV0,d2
   WATA     d2,TF_DRIVE_HEAD
   WATA     d4,TF_SECTOR_COUNT
   WATA     d0,TF_CYLINDER_LOW
   WATA     d1,TF_CYLINDER_HIGH
   WATA     d3,TF_SECTOR_NUMBER
   WATA     #ATA_WRITE_SECTORS,TF_COMMAND
   rts

issueLBAwrite
   WATA     #DRV0+L+0,TF_DRIVE_HEAD  ;L=lba; lba bits 24..27
   WATA     d4,TF_SECTOR_COUNT
   WATA     d0,TF_SECTOR_NUMBER  ;LBA  bits  0..7
   lsr.l    #8,d0
   WATA     d0,TF_CYLINDER_LOW   ;LBA  bits  8..15
   lsr.l    #8,d0
   WATA     d0,TF_CYLINDER_HIGH  ;LBA  bits  16..23
   WATA     #ATA_WRITE_SECTORS,TF_COMMAND
   rts

getCHS ; convert block number to Cylinder / Head / Sector numbers
   move.l   d0,d3   ;d0 = number of block (block numbers begin from 0)
   move.l   sectors_per_track,d2
   divu     d2,d3
   swap.l   d3
   add.w    #1,d3   ;sector numbers begin at 1
   and.l    #$ff,d3 ;sector number byte
   move.l   sectors_per_track,d2 ;d0 = number of block
   divu     d2,d0
   and.l    #$ffff,d0; 16bit word
   move.l   heads,d2
   divu     d2,d0   ;d0 = cyl
   move.l   d0,d2
   swap.l   d2
   and.l    #$f,d2  ;d2 = head
   move.l   d0,d1
   and.l    #$ff,d0; cylinder low
   lsr.l    #8,d1
   and.l    #$ff,d1; cylinder high
   rts


   END
