
        xref    _KPutChar
        xref    _KPutStr

        xdef    putchar
        xdef    puthex
        xdef    putnl

        section "devbugcode",code

KPutStr:
        pea     (a0)
        jsr     _KPutStr
        addq.l  #4,sp
        rts

putchar:
        movem.l a0-a6/d0-d7,-(sp)
        move.l  d0,-(sp)
        jsr     _KPutChar
        add.l   #1,nlcnt
        cmp.l   #80,nlcnt
        bne.s   kpcend
        jsr     putnl
kpcend: move.l  (sp)+,d0
        movem.l (sp)+,a0-a6/d0-d7
        rts

puthex:
        movem.l a0-a6/d0-d7,-(sp)
        move.l  d0,d4
        moveq   #7,d2
phlop:  rol.l   #4,d4
        move.l  d4,d0
        and.l   #$f,d0
        cmp.b   #10,d0
        bcs.s   phchr
        add.b   #7,d0
phchr   add.b   #$30,d0
        jsr     putchar
        dbra    d2,phlop
        move.b  #' ',d0
        jsr     putchar
        movem.l (sp)+,a0-a6/d0-d7
        rts
putnl:
        movem.l a0-a6/d0-d7,-(sp)
        move.l  #13,-(sp)
        jsr     _KPutChar
        addq.l  #4,sp
        move.l  #10,-(sp)
        jsr     _KPutChar
        addq.l  #4,sp
        move.l  #0,nlcnt
        movem.l (sp)+,a0-a6/d0-d7
        rts

        section "devbugbss",bss

nlcnt:          ds.l    1

        end

