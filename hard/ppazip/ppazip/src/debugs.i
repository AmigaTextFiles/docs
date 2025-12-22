;----------------------------------------------------------------------------
;                     Debug Info sent to serial port
;----------------------------------------------------------------------------
;                        by Bruce Abbott 11-4-97
;
; NOTE: If you want to redirect the serial output, execute eg.
;
;       run >nil: sushi >"con:50/50/400/160/sushi /auto" NOPROMPT
;
;----------------------------------------------------------------------------
;
;   types supported  %ld =  32 bit signed decimal
;                    %lx =  32 bit hex
;                    %lc =  32 bit char (eg 'ILBM')
;                    %d  =  16 bit signed decimal
;                    %x  =  16 bit hex
;                    %c  =   8 bit character
;                    %s  =  string pointer (string ends with NULL)
;
;   modifiers        0   =  leading spaces for decimal, 0's for hex
;                  (1-9) =  max number of characters in number
;
;
;   parameters   anything that can be source for 'move.l' instruction
;
;   example  bug <"decimal=%03ld, hex=$%03lx">,#27,#$0000001B
;
;            prints:- 'decimal= 27, hex=$01b'
;
;
;   NOTE: to print a WORD or CHAR, you need to make sure that the
;         value gets into the lower 16/8 bits for a move.l (if in
;         doubt copy the value to a data register before printing it).
;    eg.
;         move.l  myword(a0),d0
;         bug     <"this word = %d",10>
;    or.
;         bug     <"this word = %d",10>,myword-2(a0)
;
;

Bug MACRO   "text",parm1,parm2,parm3,parm4,parm5,parm6,parm7,parm8
    IFD     debug
    ifnc    "","\9"
    move.l  \9,-(sp)
    endc
    ifnc    "","\8"
    move.l  \8,-(sp)
    endc
    ifnc    "","\7"
    move.l  \7,-(sp)
    endc
    ifnc    "","\6"
    move.l  \6,-(sp)
    endc
    ifnc    "","\5"
    move.l  \5,-(sp)
    endc
    ifnc    "","\4"
    move.l  \4,-(sp)
    endc
    ifnc    "","\3"
    move.l  \3,-(sp)
    endc
    ifnc    "","\2"
    move.l  \2,-(sp)
    endc
    bsr     bugprintf
    add.w   #(narg-1)*4,sp
    bra.s   .bugend\@
.bugtext\@:
    dc.b    \1,0
    even
.bugend\@:
    ENDC
    ENDM


 IFD debug

 IFND _LVORawPutChar
_LVORawPutChar = -516
 ENDC


; do NOT include debugs.i before your startup code!

wrongplace:
  moveq   #-1,d0
  rts                   ; abort if start of program!


bugprintf:
  movem.l d0-d7/a0-a6,-(sp)
  move.l  60(sp),a2     ; a2 = pointer to string
  addq.w  #6,a2
  lea     64(sp),a3     ; a3 = parameters on stack
  move.l  4.w,a6
.rawloop:
  move.b  (a2)+,d0      ; get next char in formatting string
  beq     .done
  moveq   #0,d4
  cmp.b   #'%',d0       ; type id ?
  bne     .print
.gettype:
  move.b  (a2)+,d0
  beq     .done
  cmp.b   #'0',d0
  beq.s   .lead0
  cmp.b   #'9',d0
  bhi.s   .type
  sub.b   #'0',d0
  move.b  d0,d4
  bra.s   .gettype
.lead0:
  bset    #31,d4        ; flag LEADING ZEROS
  bra.s   .gettype
.type:
  cmp.b   #'s',d0       ; string ?
  beq     .dostring
  move.b  d0,d5         ; d5 = last char
  cmp.b   #'l',d0
  bne.s   .dotype
  bset    #30,d4        ; flag LONG SIZE
.donum:
  move.b  (a2)+,d0      ; get type after 'l'
  beq     .done
.dotype:
  cmp.b   #'x',d0       ; hex ?
  beq     .hex
  cmp.b   #'d',d0       ; decimal ?
  beq.s   .dec
  cmp.b   #'c',d0
  beq.s   .char
  bra     .print        ; unsupported type so just print it
.char:
  move.l  (a3)+,d0
  cmp.b   #'l',d5
  bne     .print        ; longword char ?
  subq.w  #1,d4
  bmi.s   .nolen
  move.w  d4,d2
  bra.s   .charloop
.nolen:
  moveq   #3,d2         ; default 4 chars
.charloop:
  rol.l   #8,d0
  jsr     _LVORawPutChar(a6)
  dbf     d2,.charloop
  bra     .rawloop
.dec:
  tst.w   d4
  bne.s   .declen
  move.w  #10,d4        ; default 10 digits
.declen:
  move.l  (a3)+,d3      ; get number
  btst    #30,d4
  bne.s   .declong
  ext.l   d3
.declong:
  tst.l   d3
  bmi.s   .negative
  neg.l   d3
  bra.s   .firstdig
.negative
  moveq   #'-',d0
  jsr     _LVORawPutChar(a6)
.firstdig:
  lea     .dectab(pc),a4
  moveq   #9,d5
.getdiv:
  move.l  (a4)+,d2      ; get divisor
  beq.s   .lastdig
  moveq   #-1,d0
.div10:
  add.l   d2,d3
  dbgt    d0,.div10
  sub.l   d2,d3
  addq.w  #1,d0         ; d0 = -digit
  neg.b   d0
  add.b   #'0',d0       ; d0 = char
  cmp.w   d4,d5
  bhi.s   .skipdec
  btst    #29,d4        ; printed a digit yet ?
  bne.s   .printd
  cmp.b   #'0',d0
  bne.s   .printdec
  btst    #31,d4        ; leading spaces ?
  beq.s   .skipdec
  moveq   #' ',d0       ; lead space
  bra.s   .printd
.printdec:
  bset    #29,d4
.printd:
  jsr     _LVORawPutChar(a6)
.skipdec:
  subq.w  #1,d5
  bra.s   .getdiv
.lastdig:
  neg.b   d3
.zero:
  add.b   #'0',d3
  move.b  d3,d0
  bra.s   .print
.hex:
  btst    #30,d4
  bne.s   .hexlong
  tst.w   d4
  bhi.s   .hexword
  move.w  #4,d4         ; default 4 digits in hex word
.hexword:
  moveq   #3,d2
  move.l  (a3)+,d5
  swap    d5
  bra.s   .hexloop
.hexlong
  tst.w   d4
  bhi.s   .gethexlong
  move.w  #8,d4         ; default 8 digits in hex longword
.gethexlong:
  moveq   #7,d2
  move.l  (a3)+,d5
.hexloop:
  rol.l   #4,d5
  move.w  d5,d0
  and.w   #$000f,d0
  move.b  .hextab(pc,d0.w),d0
  cmp.w   d4,d2
  bhs.s   .skiphex
  cmp.b   #'0',d0       ; '0' ?
  bne.s   .printhex
  btst    #31,d4        ; leading 0's wanted ?
  beq.s   .skiphex
.printhex:
  bset    #31,d4
  jsr     _LVORawPutChar(a6)
.skiphex:
  dbf     d2,.hexloop
  bra     .rawloop
.dostring:
  move.l  (a3)+,d5
  beq.s   .strdone
  exg     d5,a2
.strloop:
  move.b  (a2)+,d0
  beq.s   .strdone
  jsr     _LVORawPutChar(a6)
  bra.s   .strloop
.strdone:
  exg     d5,a2
  bra     .rawloop
.print:
  jsr     _LVORawPutChar(a6)
  bra     .rawloop
.done:
  movem.l (sp)+,d0-d7/a0-a6
  rts


.hextab:
  dc.b   "0123456789abcdef"

.dectab:
  dc.l 100000000
  dc.l 10000000
  dc.l 1000000
  dc.l 100000
  dc.l 10000
  dc.l 1000
  dc.l 100
  dc.l 10
  dc.l 0

  cnop 0,4

 ENDC

