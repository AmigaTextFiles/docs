  move.l #0,$ffffe8
  lea $f80000,a0
  moveq.l #$ff,d1
  moveq.l #1,d2
  moveq.l #0,d5
xxx:add.l (a0)+,d5
  bcc xxx1
  addq.l #1,d5
xxx1:dbf d1,xxx
  dbf d2,xxx
  move.l d5,$100
  not.l d5
  move.l d5,$104
  move.l d5,$ffffe8
  moveq.l #0,d0
  rts


