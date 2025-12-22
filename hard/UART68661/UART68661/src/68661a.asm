
        SECTION 68661a.device,CODE

        incdir  "acom:include/"
        include "exec/initializers.i"
        include "exec/interrupts.i"
        include "exec/resident.i"
        include "exec/devices.i"
        include "exec/errors.i"
        include "libraries/dos_lib.i"
        include "libraries/dosextens.i"
        include "exec/exec_lib.i"
        include "devices/serial.i"

;------------------------------------------------

      STRUCTURE MyDev,LIB_SIZE
           ULONG md_SysLib
           ULONG md_SegList
           LABEL MyDev_SIZE

;----------------------------------------------------------------
        cnop  0,4
_Main
        moveq #-1,d0        ;falls einers device direkt startet
        rts                                
;--------------------
InitTable
        dc.w        RTC_MATCHWORD            ;device kennung ($4c75 oder sowas)
        dc.l        InitTable                ;zeiger auf Anfang der Structur
        dc.l        EndCode
        dc.b        RTF_AUTOINIT             ;Flag fuer init
        dc.b        VERSION
        dc.b        NT_DEVICE                ;3=NodeTyp
        dc.b        0                        ;Prioritaet
        dc.l        Name                     ;DEVICE NAME
        dc.l        idString
        dc.l        Init
;--------------------------------------
         cnop    0,4
Name     dc.b    "68661a.device",0   ;PROB: GROSS/KLEIN SCHREIBUNG
         cnop    0,4
idString dc.b    "V1.00 (15 MAI 1992)",13,10,0
         cnop    0,4
DosName  dc.b    "dos.library",0
         cnop    0,4
_DOSBase dc.l    0
         cnop    0,4
BASIS    equ     $ef0000
VERSION  equ     1
REVISION equ     00

;---------------------------------------------------------------------
        cnop        0,4
Init
        dc.l        MyDev_SIZE
        dc.l        funcTable
        dc.l        dataTable
        dc.l        initRoutine

funcTable

        dc.l        Open                        ;OPEN
        dc.l        Close                       ;CLOSE
        dc.l        Expunge                     ;EXPUNGE
        dc.l        Null                        ;EXTFUNCT
        dc.l        BeginIO                     ;BEGINIO
        dc.l        AbortIO                     ;ABORTIO
        dc.l        -1                          ;ENDE_KENNUNG

dataTable        

        INITBYTE LN_TYPE,NT_DEVICE
        INITLONG LN_NAME,Name 
        INITBYTE LIB_FLAGS,LIBF_SUMUSED!LIBF_CHANGED
        INITWORD LIB_VERSION,VERSION
        INITWORD LIB_REVISION,REVISION
        INITLONG LIB_IDSTRING,idString
        dc.l     0
;---------------------------------------

initRoutine ;d0=device,a0=seglist device,a6=execbase

        movem.l       d0-d7/a0-a6,-(a7)
        move.l        d0,a5
        move.l        a6,md_SysLib(a5)
        move.l        a0,md_SegList(a5)
        move.l        a5,d0

        lea           DosName,a1
        moveq         #0,d0
        CALLEXEC      OpenLibrary
        move.l        d0,_DOSBase

        movem.l       (a7)+,d0-d7/a0-a6
        rts

;----------------------------------------

Open  ;d0=unitnum,d1=flags,a1=ioreq,a6=device!!!

        movem.l  d0-d7/a0-a6,-(a7)

        lea      Name,a1
        CALLEXEC FindTask
        tst.l    d0
        bne      Open1

        move.l   #$8000,d0        ;Lesepuffer
        move.l   #$30001,d1       ;Flags
        CALLEXEC AllocMem
        move.l   d0,Min
        move.l   d0,Pointer
        move.l   d0,Merke
        addi.l   #$8000,d0
        move.l   d0,Max

        move.l   #10000,d4
        move.l   #proc_seglist,d3
        lsr.l    #2,d3
        moveq    #0,d2
        move.l   #Name,d1
        CALLDOS  CreateProc
        move.l   d0,MYPROC

        lea      INT6,a1
        move.l   #13,d0
        CALLEXEC AddIntServer
        move.b   #$4d,BASIS+5     ;
        move.b   #$3c,BASIS+5     ;2400brot
        move.b   #$27,BASIS+7

        move.l   #$11130000,IO_CTLCHAR(a1)
        move.l   #$8000,IO_RBUFLEN(a1)
        move.l   #0,IO_EXTFLAGS(a1)
        move.l   #2400,IO_BAUD(a1)
        move.l   #250000,IO_BRKTIME(a1)
        move.b   #8,IO_READLEN(a1)
        move.b   #8,IO_WRITELEN(a1)
        move.b   #1,IO_STOPBITS(a1)
        move.b   #$B4,IO_SERFLAGS(a1)
Open1
        movem.l  (a7)+,d0-d7/a0-a6


        addq.w   #1,LIB_OPENCNT(a6)
        clr.l    d0
;        move.b   d0,IO_ERROR(a1)
;        move.b   #NT_REPLYMSG,LN_TYPE(a1)
        rts

;---------------------------------------------------
Close   ;a1=ioreq,a6=device,,,,d0=seglist oder 0

        clr.l      d0
        subq.w     #1,LIB_OPENCNT(a6)      ;Zaehler fuer Anzahl der Zugriffe -1
        bsr        Expunge                 ;Device entfernen
        rts
;--------------------------------------------------
Expunge ;a6=device,d0=seglist device

        movem.l    d2/a5-a6,-(a7)          ;Register retten
        move.l     a6,a5                   ;Zeiger auf Device nach a5
        move.l     md_SysLib(a5),a6        ;ExecBase nach a6
        tst.w      LIB_OPENCNT(a5)         ;Zaehler fuer Anzahl der oeffnungen
        beq        1$                      ;Springe, wenn Device entfernt wi
        clr.l      d0                      ;Zeiger auf Segment loechen
        bra        Expunge_end             ;Ruecksprung
1$
        movem.l    d0-d6/a0-a6,-(a7)

        lea        Name,a1
        CALLEXEC   FindTask
        tst.l      d0
        beq        2$

        move.b     #0,BASIS+7              ;rx/tx ausschalten
        lea        INT6,a1
        move.l     #13,d0
        CALLEXEC   RemIntServer

        move.l     Min,a1
        move.l     #$8000,d0
        CALLEXEC   FreeMem

        move.l     MYPROC,a1
        lea       -pr_MsgPort(a1),a1
        CALLEXEC   RemTask
2$
        movem.l    (a7)+,d0-d6/a0-a6

        move.l     md_SegList(a5),d2       ;Zeiger auf Segment Liste holen
        move.l     a5,a1                   ;Zeiger auf Device nach a1
        CALLEXEC   Remove                  ;Device aus Liste loechen
        move.l     _DOSBase,a1
        CALLEXEC   CloseLibrary
        move.l     a5,a1                   ;Zeiger auf Device
        clr.l      d0                      ;d0 loechen
        move.w     LIB_NEGSIZE(a5),d0      ;Negative Groesse holen
        sub.l      d0,a1                   ;Anfang des Speichers fuer Device bestimmen
        add.w      LIB_POSSIZE(a5),d0      ;Laenge von Device bestimmen
        CALLEXEC   FreeMem                 ;Speicher freigeben
        move.l     d2,d0                   ;zeiger auf Segmentliste
Expunge_end
        movem.l    (a7)+,d2/a5-a6          ;Register zurueckschreiben
        rts                        
;----------------------------------------------
Null
        clr.l   d0    ;unused
        rts
;----------------------------------------------
BeginIO ;a1=ioreq,a6=device!!!!!!

        clr.l   d0
        move.w  IO_COMMAND(a1),d0

        cmp.w   #1,d0
        beq     MyReset
        cmp.w   #2,d0
        beq     Read
        cmp.w   #3,d0
        beq     Write
        cmp.w   #4,d0
        beq     Update
        cmp.w   #5,d0
        beq     Clear
        cmp.w   #6,d0
        beq     MyStop
        cmp.w   #7,d0
        beq     Start
        cmp.w   #8,d0
        beq     Flush
        cmp.w   #9,d0
        beq     Query
        cmp.w   #10,d0
        beq     Break
        cmp.w   #11,d0
        beq     SetParams

        move.b  #IOERR_NOCMD,IO_ERROR(a1)
        bsr     TermIO
        rts
;---------------------------------------------
AbortIO

        cmp.w    #2,IO_COMMAND(a1) ;readrequest?
        bne      Abort_end

	movem.l	d0-d6/a0-a6,-(a7)

        move.l   #1,IOABORT
        move.l	SIGTASK,a1
        move.l	SIGMASK,d0
        CALLEXEC	Signal

	movem.l	(a7)+,d0-d6/a0-a6

Abort_end
        moveq    #0,d0
        rts

;---------------------------------------------
TermIO
        btst     #IOB_QUICK,IO_FLAGS(a1)
        bne      TermIO_end  ;bei quick keine ReplyMsg
        move.l   a6,-(a7)
        CALLEXEC ReplyMsg
        move.l   (a7)+,a6
TermIO_end
        rts
;------------------------------------------------------------------
;a1=ioreq,a3=unit,a6=device
;-------------------------------------------------------IO_COMMANDS
Invalid ;0
        move.b   IOERR_NOCMD,IO_ERROR(a1)
        bsr      TermIO
        rts
;---------------------------------------
MyReset ;1#
        clr.b    IO_ERROR(a1)
        bsr      TermIO
        rts
;---------------------------------------
Read    ;2

        bclr     #IOB_QUICK,IO_FLAGS(a1)
        move.l   MYPROC,a0
        move.l   a6,-(sp)
        CALLEXEC PutMsg
        move.l   (sp)+,a6
        rts

;---------------------------------------
Write   ;3

        move.l   IO_DATA(a1),a0
        cmpi.l   #-1,IO_LENGTH(a1)
        beq      Write_null
        move.l   IO_LENGTH(a1),d0
        beq      Write_end

        subq.l   #1,d0

Write1
        move.b   (a0)+,BASIS+1
Write2
        btst     #0,BASIS+3
        beq      Write2
        dbra     d0,Write1

Write_end
        move.b   #0,IO_ERROR(a1)
        move.l   IO_LENGTH(a1),IO_ACTUAL(a1)

        bsr      TermIO
        rts

Write_null
Write3  tst.b    (a0)
        beq      Write_end
        move.b   (a0)+,BASIS+1
Write4  btst     #0,BASIS+3
        beq      Write4
        bra      Write3

;---------------------------------------
Update  ;4
        bra      Invalid
;---------------------------------------
Clear   ;5
        move.l   #0,Count
        move.l   Min,Pointer
        move.l   Min,Merke
        clr.b    IO_ERROR(a1)
        bsr      TermIO
        rts
;---------------------------------------
MyStop  ;6
        bsr      TermIO
        rts
;---------------------------------------
Start   ;7
        bsr      TermIO
        rts
;---------------------------------------
Flush   ;8
        bsr      TermIO
        rts
;---------------------------------------
Query   ;9
        move.l   Count,IO_ACTUAL(a1)
        move.w   #$0020,IO_STATUS(a1)
        btst     #7,BASIS+3 ;eigentlich #6 aber DCD und DSR vertauscht!!
        beq      Query1
        move.w   #$0000,IO_STATUS(a1)
Query1
        move.b   #0,IO_ERROR(a1)
        bsr      TermIO
        rts
;---------------------------------------
Break   ;10
        bsr      TermIO
        rts

;---------------------------------------
SetParams ;CMD_11
          cmpi.l  #300,IO_BAUD(a1)
          bne     Set1200
          move.b  #$4d,BASIS+5
          move.b  #$36,BASIS+5
Set1200   cmpi.l  #1200,IO_BAUD(a1)
          bne     Set2400
          move.b  #$4d,BASIS+5
          move.b  #$39,BASIS+5
Set2400   cmpi.l  #2400,IO_BAUD(a1)
          bne     Set9600
          move.b  #$4d,BASIS+5
          move.b  #$3c,BASIS+5
Set9600   cmpi.l  #9600,IO_BAUD(a1)
          bne     Set19200
          move.b  #$4d,BASIS+5
          move.b  #$3e,BASIS+5
Set19200  cmpi.l  #19200,IO_BAUD(a1)
          bne     Set38400
          move.b  #$4d,BASIS+5
          move.b  #$3f,BASIS+5
Set38400  cmpi.l  #38400,IO_BAUD(a1)
          bne     SetEnd
          move.b  #$4d,BASIS+5
          move.b  #$3f,BASIS+5
SetEnd
          bsr     TermIO
          rts

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        cnop     0,8
proc_seglist
        dc.l     0
proc_begin
        sub.l    a1,a1
        CALLEXEC FindTask
        move.l   d0,SIGTASK
        move.l   d0,a0
        lea      pr_MsgPort(a0),a5

        clr.l    d1
        clr.l    d0
        move.b   MP_SIGBIT(a5),d0
        bset     d0,d1
        move.l   d1,SIGMASK

;--------------------------
proc_main

	move.l	SIGMASK,d0
	CALLEXEC	Wait
 
proc_next
        move.l   a5,a0
        CALLEXEC GetMsg
        tst.l    d0
        beq      proc_main
        move.l   d0,a1
;---------------------

        move.l   IO_DATA(a1),a4
        move.l   IO_LENGTH(a1),d4
        move.l   #0,d3 ;Actual
        bra      proc_read

proc_wait

        move.l   a1,-(sp)

	move.l	SIGMASK,d0
	CALLEXEC	Wait

        move.l   (sp)+,a1

proc_read
        cmpi.l   #1,IOABORT
        beq      proc_end

        tst.l    d4               ;null bytes gefordert?
        beq      proc_end

        cmpi.l   #0,Count
        beq      proc_wait        ;kein byte da

        move.l   Merke,a3
        move.b   (a3)+,(a4)+
        move.l   a3,Merke

        cmpa.l   Max,a3            ;PufferEnde?
        bne      proc5
        move.l   Min,Merke         ;wenn ja: LeseZeiger auf PufferAnfang
proc5

        sub.l    #1,Count
        add.l    #1,d3
        sub.l    #1,d4
        bne      proc_read

proc_end
        move.l   #0,IOABORT
        move.l   d3,IO_ACTUAL(a1)
        CALLEXEC ReplyMsg
        bra      proc_next

IOABORT  dc.l 0
MYPROC   dc.l 0
SIGTASK  dc.l 0
SIGMASK  dc.l 0
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        cnop 0,4
INT6    dc.l 0        ;LN_SUCC
        dc.l 0        ;LN_PRED
        dc.b 2        ;LN_TYPE 2=interrupt
        dc.b 0        ;LN_PRI
        dc.l Name     ;LN_NAME
        dc.l 0        ;IS_DATA
        dc.l Server   ;IS_CODE
        dc.b 0,0      ;Pad
        ds.l 100

        cnop     0,4               ;/INT6 von RxRDY(pin14) ausgeloest.
Server
        movem.l  d0-d6/a0-a6,-(sp)

        btst     #1,BASIS+3        ;RBF?
        beq      ServEnd           ;nein

        addq.l   #1,Count

        move.l   Pointer,a0
        move.b   BASIS+1,(a0)+     ;Speichern und Pointer +1
        move.l   a0,Pointer        ;Pointer sichern

        cmpa.l   Max,a0            ;PufferEnde?
        bne      ServOV
        move.l   Min,Pointer       ;wenn ja: Zeiger auf PufferAnfang
ServOV

;	btst     #0,BASIS+3        ;TBE?
;	beq      Serv2             ;nein

        move.l	SIGTASK,a1
        move.l	SIGMASK,d0
        CALLEXEC	Signal

ServEnd
        movem.l  (sp)+,d0-d6/a0-a6

        moveq    #0,d0
        rts

Pointer dc.l 0               ;Schreibzeiger
Merke   dc.l 0               ;Lesezeiger
Count   dc.l 0               ;Anzahl Bytes
Min     dc.l 0
Max     dc.l 0
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
EndCode END




