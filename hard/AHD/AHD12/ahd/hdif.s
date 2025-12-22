        include "exec/types.i"
        include "exec/devices.i"
        include "exec/io.i"
        include "exec/initializers.i"
        include "exec/resident.i"
        include "exec/errors.i"

        include "messages.i"

        XDEF    Read
        XDEF    Write
        XDEF    FormatTrk
        XDEF    doreset
        XDEF    doinit
        XDEF    doerror
        XDEF    readsec
        XDEF    writesec
        XDEF    dofmttrk
        XDEF    doseek
        XDEF    hdconfig
        XDEF    _inbuffer

        XREF    _CXD33
        XREF    subSysName

MAXBLK          equ     $20000

        section "hdifcode",code

FormatTrk
        move.l  a1,a3
        bsr     doinit
        bne.s   FormatTrk
        move.l  IO_OFFSET(a3),d0
        bsr     dofmttrk
        bne.s   fmterr
        move.l  IO_DATA(a3),a2
        move.l  IO_OFFSET(a3),d0         ;d5 = IO_OFFSET
        move.l  IO_LENGTH(a3),d1
        beq.s   fmtend
        bsr     writesec
        bne     fmterr
fmtend  move.l  IO_LENGTH(a3),IO_ACTUAL(a3)
        clr.b   IO_ERROR(a3)         ;IO_ERROR = 0
        rts

fmterr  clr.l   IO_ACTUAL(a3)         ;IO_ACTUAL = 0
        move.b  #$17,IO_ERROR(a3)    ;IO_ERROR = TDERR_SeekError
        rts

Write
        move.l  a1,a3
        move.l  IO_DATA(a3),a2
        move.l  IO_OFFSET(a3),d4
        move.l  IO_LENGTH(a3),d5
        beq     wrtend
wnxblk  cmp.l   #MAXBLK,d5
        bhi     wrbig
        move.l  d4,d0
        move.l  d5,d1
        bsr     remap
        bsr     writesec
        bne     writeerr
        beq     wrtend
wrbig   move.l  #MAXBLK,d1
wrb1    move.l  d4,d0
        bsr     remap
        bsr     writesec
        bne     writeerr
        add.l   #MAXBLK,a2
        add.l   #MAXBLK,d4
        sub.l   #MAXBLK,d5
        bra     wnxblk
wrtend  move.l  IO_LENGTH(a3),IO_ACTUAL(a3)
        clr.b   IO_ERROR(a3)         ;IO_ERROR = 0
        rts
writeerr
        clr.l   IO_ACTUAL(a3)
        move.b  #$15,IO_ERROR(a3)    ;IO_ERROR = TDERR_SeekError
        rts

Read
        move.l  a1,a3
rdagain
        clr.l   IO_ACTUAL(a3)
        move.l  IO_DATA(a3),a2
        move.l  IO_OFFSET(a3),d4
        move.l  IO_LENGTH(a3),d5
        beq.s   rdend
rnxblk  cmp.l   #MAXBLK,d5
        bhi.s   rdbig
        move.l  d4,d0
        move.l  d5,d1
        bsr     remap
        bsr     readsec
        bne.s   readerr
        bra.s   rdend
rdbig   move.l  #MAXBLK,d1
rdb1    move.l  d4,d0
        bsr     remap
        bsr     readsec
        bne.s   readerr
        add.l   #MAXBLK,a2
        add.l   #MAXBLK,d4
        sub.l   #MAXBLK,d5
        bra.s   rnxblk
rdend   move.l  IO_LENGTH(a3),IO_ACTUAL(a3)
        clr.b   IO_ERROR(a3)         ;IO_ERROR = 0
        rts

readerr move.b  _inbuffer,d0
        and.b   #$7f,d0
        bne.s   rdrealerr       ; Got a real (non-sync) error

rdsync  bsr     doreset         ; Get in sync with controller
        bsr     doerror
        bne.s   rdsync
        bra.s   rdagain

rdrealerr
        cmp.b   #$18,d0
        beq.s   rdend

rerrnd  clr.l   IO_ACTUAL(a3)
        move.b  #$16,IO_ERROR(a3)    ;IO_ERROR = TDERR_SeekError
        rts

ioport  EQU     $e80001         ; io specific code
status  EQU     $e80003         ; d0-d1/a0-a1 is scratch
select  EQU     $e80005
flags   EQU     $e80007

complete
        DMPCHR  10,#'C'         ; Do completion phase
        move.l  #0,d1
cm05    move.b  status,d0
        and.b   #%00100000,d0   ; Check 4 IRQ flag
        bne.s   cm2
        subq.l  #1,d1
        bne.s   cm05
        bra.s   cm4

cm2     move.b  ioport,d1
        DMPCHR  10,#'R'
        DMPHEX  10,d1
        DMPNL   10
        btst    #1,d1
        bne.s   cm3
        moveq   #0,d0
        rts
cm3     and.b   #$20,d1         ; We got a real (non-sync) error
        move.b  d1,d3
        bsr     doerror
        beq.s   cm1
cm4     bsr     doreset         ; If serious - reset
cm1     moveq   #1,d0
        rts

hardreq
        DMPCHR  20,#'q'         ; Waits 4 REQ & BUSY -
        moveq   #0,d1           ; Worx only in command mode
hr2     move.b  status,d0
        btst    #0,d0           ; Test REQ
        bne.s   hr3
        btst    #3,d0           ; Test BUSY
        beq.s   hr1
        subq.l  #1,d1
        bne.s   hr2
        bra.s   hr1             ; Timeout!

hr3     DMPCHR  20,#'Q'
        moveq   #0,d0
        rts
hr1     moveq   #1,d0
        rts

hardex                          ; a0 = ptr 2 cmd 2 send
        DMPHEX  10,(a0)         ; a1 = ioport on exit
        DMPHEX  10,4(a0)

        move.w  #-1,d1
hdx01   move.b  status,d0
        and.b   #%1001,d0
        beq.s   hdx02
        dbra    d1,hdx01
        bra.s   hdx2

hdx02
        move.b  d0,select       ; Start command mode
        move.b  #$02,flags      ; Enable IRQ

        move.w  #-1,d1
hdx05   move.b  status,d0
        and.b   #$0d,d0
        cmp.b   #$0d,d0
        beq.s   hdx1
        dbra    d1,hdx05
        bra.s   hdx2

hdx1    DMPCHR  10,#'S'
        lea     ioport,a1
        move.b  (a0)+,(a1)
        move.b  (a0)+,(a1)
        move.b  (a0)+,(a1)
        move.b  (a0)+,(a1)
        move.b  (a0)+,(a1)
        move.b  (a0)+,(a1)

        moveq   #0,d0
        rts
hdx2    bsr     doreset         ; Errors here is serious
        moveq   #1,d0
        rts

sendbulk                        ; adress in a0, count-1 in d1
        move.l  d2,-(sp)
        move.w  d1,d2
        lea     ioport,a1
sbk3    bsr     hardreq
        bne.s   sbk2
        move.b  (a0)+,(a1)
        dbra    d2,sbk3

        move.l  (sp)+,d2
        moveq   #0,d0
        rts
sbk2    move.l  (sp)+,d2
        moveq   #1,d0
        rts

;drive commands begin here

doreset
        PUTMSG  90,<'doreset'>
        move.b  #0,_inbuffer    ; So that we can tell apart from real error
        move.b  d0,status
        moveq   #0,d0
dres1   nop
        dbra    d0,dres1
        DMPCHR  10,#'-'
        DMPNL   10
        moveq   #0,d0
        rts

doinit
        PUTMSG  90,<'doinit'>
        lea     initcmd,a0      ;initialize drive parameters
        DMPHEX  90,(a0)
        DMPHEX  90,4(a0)
        DMPHEX  90,8(a0)
        DMPHEX  90,12(a0)
        DMPNL   90
        bsr     unpacsec
        bsr     hardex
        bne.s   di1
        lea     initcmd+6,a0    ; a0 = ptr 2 drive parms
        moveq   #8-1,d1
        bsr     sendbulk
        bne.s   di1
        bsr     complete
        bne.s   di1
        moveq   #0,d0
        rts
di1     moveq   #1,d0
        rts

dofmtone                        ; Format track as described in fmtcmd
        lea     fmtcmd,a0
        bsr     hardex
        bne.s   dfo1
        bsr     complete
        bne.s   dfo1
        moveq   #0,d0
        rts
dfo1    moveq   #1,d0
        rts

doseek                          ; Seek to sector in d0
        lea     seekcmd,a0
        bsr     unpacsec
        bsr     hardex
        bne.s   ds1
        bsr     hardreq
        bne.s   ds1
        bsr     complete
        bne.s   ds1
        moveq   #0,d0
        rts
ds1     moveq   #1,d0
        rts

readsec                         ; d0 = sector, d1 = length, a2 = data
        movem.l d2/a2,-(sp)
        asr.l   #8,d1
        asr.l   #1,d1
        move.l  d1,d2
        move.b  d1,readcmd+4
        lea     readcmd,a0
        bsr     unpacsec

        bsr     hardex
        bne.s   dr1
        subq    #1,d2
dgm2
        bsr     hardreq
        bne.s   dr1
        btst    #5,status       ; Got an interrupt - maybe error $11
        bne.s   rdxt
        move.l  #32-1,d1
dmget   move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        move.b  (a1),(a2)+
        dbra    d1,dmget
        dbra    d2,dgm2

rdxt    bsr     complete
        bne.s   dr1
        movem.l (sp)+,d2/a2
        moveq   #0,d0
        rts
dr1     movem.l (sp)+,d2/a2
        moveq   #1,d0
        rts

writesec
        movem.l d2/a2,-(sp)
        asr.l   #8,d1           ; Offset -> logical sector
        asr.l   #1,d1
        move.l  d1,d2
        move.b  d1,wrtcmd+4
        lea     wrtcmd,a0
        bsr     unpacsec

        bsr     hardex
        bne.s   dw1
        subq    #1,d2
wtmp
        bsr     hardreq
        bne.s   dw1
        btst    #5,status       ; Got an interrupt - maybe error $11
        bne.s   wsxt
        move.l  #32-1,d1
wbk3    move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        move.b  (a2)+,(a1)
        dbra    d1,wbk3
        dbra    d2,wtmp

wsxt    bsr     complete
        bne.s   dw1
        movem.l (sp)+,d2/a2
        moveq   #0,d0
        rts
dw1     movem.l (sp)+,d2/a2
        moveq   #1,d0
        rts

doerror
        PUTMSG  90,<'Error: '>
        lea     getsense,a0
        bsr     unpacsec
        bsr     hardex
        bne.s   de1

        bsr     hardreq
        bne.s   de1

        lea     ioport,a1
        lea     _inbuffer,a0
        move.b  (a1),(a0)+
        move.b  (a1),(a0)+
        move.b  (a1),(a0)+
        move.b  (a1),(a0)+

        bsr     complete
        bne.s   de1
        DMPHEX  1,_inbuffer
        DMPNL   1
        moveq   #0,d0
        rts
de1     moveq   #1,d0
        rts

dofmttrk
        movem.l d2/d6,-(sp)
        lea     fmtcmd,a0
        bsr     unpacsec
        clr.w   d6
dft1    move.l  #0,d0
        bsr     doseek
        bne.s   dft2
        bsr     dofmtone
        bne.s   dft2
        addq    #1,d6
        move.b  d6,fmtcmd+1
        or.b    d3,fmtcmd+1
        cmp.w   heads,d6
        bne.s   dft1
        movem.l (sp)+,d2/d6
        moveq   #0,d0
        rts
dft2    movem.l (sp)+,d2/d6
        moveq   #1,d0
        rts

unpacsec                        ; a0 ptr 2 cmd 2 patch
        movem.l d2,-(sp)
        moveq   #9,d1
        asr.l   d1,d0           ;Patches offset in d0
        move.w  sectors,d1
        beq.s   ups1
        bsr     _CXD33
        move.w  d1,d2           ; rest = sector# in d2
        divu    heads,d0
        swap    d0
        move.b  d0,d1
        clr.w   d0
        swap    d0
        or.b    d3,d1

        move.b  d0,3(a0)     ;cylinder in d0
        and.b   #$3f,d2         ;head & unit in d1
        ror.w   #2,d0           ;sector in d2
        and.b   #$c0,d0
        or.b    d2,d0
        move.b  d0,2(a0)
        move.b  d1,1(a0)

ups1
        movem.l (sp)+,d2
        rts

remap
        rts

hdconfig                        ; buffer to read from in a0
        PUTMSG  90,<'hdconfig'>
        lea     initcmd,a1
        move.w  (a0),d0         ; fix # of cylinders
        move.b  d0,6(a1)        ; lowbyte first
        ror.w   #8,d0
        move.b  d0,7(a1)        ; hibyte last
        move.w  (a0),d0
        subq    #1,d0           ; maxcyl - 1 = last writeable cylinder
        move.b  d0,9(a1)        ; lowbyte first
        ror.w   #8,d0
        move.b  d0,10(a1)       ; hibyte last

        move.w  2(a0),d0        ; fix precomp at ...
        move.b  d0,11(a1)       ; lowbyte first
        ror.w   #8,d0
        move.b  d0,12(a1)       ; hibyte last

        move.b  13(a0),13(a1)   ; set ECC burst length

        move.w  6(a0),heads     ; save # of heads...
        move.b  7(a0),8(a1)     ; ...in initcmd too

        move.w  4(a0),sectors   ; save # of sectors per track

        lea     fmtcmd,a1
        move.b  9(a0),4(a1)     ; save interleave

        move.b  11(a0),d0       ; fix steprate
        move.b  d0,seekcmd+5
        move.b  d0,calcmd+5
        move.b  d0,readcmd+5
        move.b  d0,wrtcmd+5
        move.b  d0,fmtcmd+5
        clr.l   d0
        rts

        section "hdifdata",data

initcmd dc.b    $0c,$00,$00,$00,$00,$00         ;io specific data
        dc.b    $67,$02,$04,$66,$02,$2c,$01,$0b
fmtcmd  dc.b    $06,$00,$00,$00,$02,$03
seekcmd dc.b    $0b,$00,$00,$00,$00,$03
calcmd  dc.b    $01,$00,$00,$00,$00,$03
getsense dc.b   $03,$00,$00,$00,$00,$00
readcmd dc.b    $08,$00,$00,$00,$01,$03
wrtcmd  dc.b    $0a,$00,$00,$00,$01,$03
tdrcmd  dc.b    $00,$00,$00,$00,$00,$00

sectors         dc.w    17      ; Default disktype
heads           dc.w    4

        section "hdifbss",bss

        cnop    0,4

_inbuffer       ds.b    512
endbuf

        end

