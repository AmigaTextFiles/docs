*
*  This code is Copyright by Bernd Harder.
*  Slightly modified by Tobias Ferber on 23.02.1993
*

  SECTION code

  XDEF _reset

_SysBase         EQU 4
_LVODisable      EQU -120 
_LVOForbid       EQU -132
_LVOCopyMem      EQU -624

_reset:
  move.l 4(sp),src       ;current location of complete kickfile
  move.l 8(sp),dst       ;where to copy lower 256k bank

  move.l (_SysBase).W,A6
  jsr _LVODisable(a6)
  jsr _LVOForbid(a6)

  ; change the ColdCapture vector

  lea.l coldice,a0
  move.l a0,42(a6)       ;SysBase->ColdCapture

  ; we must adjust the ChkSum after changing this vector

  lea $22(a6),a0         ;&SysBase->SoftVer (version number)
  moveq.l #$16,d0        ;summation over $16 words
  moveq.l #0,d1
\chksum:
  add.w (a0)+,d1
  dbra d0,\chksum
  not.w d1
  move.w d1,$52(a6)      ;SysBase->ChkSum

  ; become Supervisor to change the WOM (BootROM visible at $f80000)

  lea \trap,a0
  move.l a0,$80          ;MC680x0 TRAP0 vector
  trap #0

  CNOP 0,4  ;IMPORTANT! Longword align!

\trap:
  move.l src,a0
  move.l dst,a1
  move.l #$40000,d0      ;move a complete kickstart to dst
  jsr _LVOCopyMem(a6)

coldreboot:
  lea $1000000,a0   ;End of Kickstart ROM
  sub.l -$14,a0     ;Offset from end of ROM to Kickstart size
  move.l 4(a0),a0   ;Get Initial Program Counter
  subq #2,a0        ;now points to second RESET
  reset             ;first RESET instruction      \  MUST share
  jmp (a0)          ;CPU Prefetch executes this   /  one longword

;-------------------------------------------------ColdCapture---------------

  CNOP 0,4

  ; ColdCapture routine (kickstart part 2 --> WOM)

coldice:
  move.l src,a0          ;we'll find a complete kickstart here
  adda.l #$40000,a0      ;look at the 2nd part (upper 256k)
  lea.l	$fc0000,a1
\womit:
  move.l (a0)+,(a1)+
  cmp.l #$1000000,a1
  bne.s \womit
  move.l #0,4
  move.w #0,$f80000      ;protect the A1000 bootrom
  lea $fc0004,a0
  subq.l #2,a0
  jmp (a0)               ;jump into kickstart

;---------------------------------------------------------------------------

src:
  dc.l 0
dst:
  dc.l 0

  END
