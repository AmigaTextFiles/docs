   move.b #$ff,$da3018
   move.b #$00,$da3018
   bsr get_ready
   move.b #$10,$da201c
   bsr get_ready
   move.b #$20,$da201c
   bsr get_ready
   btst #6,$bfe001
   beq read_podrjad
   lea $da2000,a0
   lea $f0000,a1
   move.w #$00ff,d0
   btst #3,d7
   bne loop1a
loop1:
   btst #7,$bfe001
   beq  exit
   btst #3,$da201c
   beq loop1
loop1a:move.w (a0),(a1)+
   dbf d0,loop1
   bra exit

read_podrjad:
   lea $da2000,a0
   lea $f0000,a1
   move.w #$001f,d0
   btst #3,d7
   bne loop3
loop2:
   btst #7,$bfe001
   beq  exit
   btst #3,$da201c
   beq loop2
loop3:
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   move.w (a0),(a1)+
   dbf d0,loop3
   bra exit

exit:moveq.l #0,d0
   rts

get_ready:
   btst #7,$bfe001
   beq  exit_ret
   move.b $da201c,d7
   btst  #7,d7
   bne   get_ready
exit_ret:
   rts
