****************************************************************************
*
*   patch -- patch a kickstart file for A1000 WOM usage
*
*   patch(filemem, kickmem, fastbeg, fastend, chipend);
*   void patch(long, long, long, long, long);
*
*   The ZKick file loaded to 'filemem' will be patched to work at
*   'kickmem' with available fast memory from 'fastbeg' to 'fastend'
*   and chipmemory up to 'chipend'.
*   The memory borders are to be valid *AFTER* the kickstart has been
*   installed, i.e. without the 256k occupied by the first part of the
*   kickfile.
*
****************************************************************************

  SECTION code

  XDEF _patch

_patch:
  movem.l D0-D7/A0-A6,-(sp)
  move.l  64(sp),A0            ; current kickstart location
  move.l  68(sp),D0            ; lower 256k block of kickstart
  move.l  72(sp),D1            ; beg of MEMF_FAST (after patch)
  move.l  76(sp),D2            ; end of MEMF_FAST (after patch)
  move.l  80(sp),D3            ; end of MEMF_CHIP (after patch)

  tst.l   D3                   ; expansion at $80000 ?
  bne.s   \chipext             ; MUST be == 0 for default $80000

  cmp.l   #$80000,D0
  ble.s   \kicklast
  cmp.l   D1,D0
  ble.s   \kicklast

  cmp.l   #$80000,D1
  ble.s   \kickfirst
  cmp.l   D0,D1
  ble     \kickfirst

  bra.s   \goon

\kickfirst:
  move.l  D1,$1e6(A0)
  bra.s   \goon

\kicklast: 
  move.l  D0,$1e6(A0)
  bra.s   \goon

\chipext:
  move.l  D3,$1e6(A0)

\goon:

  ; checksum of the lower 256k kickstart only

  move.l  #$74007a00,$de(A0)   ; moveq #1,D2 --> moveq #0,D2 
  move.l  #$fc0044,$3d4(A0)    ; enable reboot after checksum error
  move.l  D1,$2b4(A0)          ; set beg of MEMF_FAST
  move.l  D2,$2ba(A0)          ; set end of MEMF_FAST
  move.l  D1,$2c8(A0)          ; set beg of MEMF_FAST

  sub.l   #$240000,$30c(A0)    ; library search in lower 256k bank
  add.l   D0,$30c(A0)

  move.l  #$f00000,$310(A0)    ; library search in eproms and WOM
  move.l  #$1000000,$314(A0)
  sub.l   #$240000,$410(A0)
  add.l   D0,$410(A0)
  move.l  #$f00000,$414(A0)
  move.l  #$1000000,$418(A0)

  adda.l  #$40004,A0
  sub.l   #$f80000,(A0)        ; new reset vector
  add.l   D0,(A0)

  move.l  80(sp),A0
  adda.l  #$3fe00,A0
  move.l  #$ffffffff,(A0)      ; checksum 1 (initially -1)

  move.l  80(sp),A0
  adda.l  #$7fe00,A0
  move.l  #$ffffffff,(A0)      ; checksum 2 (initially -1)

  movem.l (sp)+,D0-D7/A0-A6
  rts

  END
