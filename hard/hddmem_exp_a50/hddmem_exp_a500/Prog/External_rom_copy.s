; program for move AMIGA-ROM from $f80000 to $80000 (lenght $80000)
; 1. run program
; 2. switch ROM
; 3. press left joustick button
; flash led
; copy rom
; flash led 
; 4. switch ROM
; 5. press left mouse button

     lea      perex(pc),a4
     move.l   $20,d4
     move.l   a4,$20
perex:move.w  #$2700,sr
     suba.l   #6,a7
     lea      $f80000,a0
     lea      $80000,a1
     move.l   #$40000,d0
lab1:btst     #7,$bfe001
     bne      lab1
     bchg     #1,$bfe001
lab2:nop
     nop
     nop
     nop
     move.w   (a0)+,d1
     nop
     nop
     nop
     nop
     move.w   d1,(a1)+
     subq.l   #1,d0
     bne      lab2
     bchg     #1,$bfe001
lab3:btst     #6,$bfe001
     bne      lab3
     move.l   d4,$20
     move.w   #$0000,sr
     rts

     
