INFO_LEVEL      EQU     0    ; Specify amount of debugging info desired

                XREF    KPutFmt
                xref    puthex
                xref    putchar
                xref    putnl

PUTMSG:         MACRO   * level,msg

                IFGE    INFO_LEVEL-\1

                PEA     subSysName(PC)
                MOVEM.L A0/A1/D0/D1,-(SP)
                LEA     msg\@,A0
                LEA     4*4(SP),A1
                JSR     KPutFmt
                MOVEM.L (SP)+,D0/D1/A0/A1
                ADDQ.L  #4,SP
                BRA.S   end\@

msg\@           DC.B    \2
                DC.B    10
                DC.B    0
                DS.W    0
end\@
                ENDC
                ENDM

DMPHEX:         MACRO   * level, ea

                ifge    INFO_LEVEL-\1

                move.l  d0,-(sp)
                move.l  \2,d0
                bsr     puthex
                move.l  (sp)+,d0

                endc
                endm

DMPNL:          MACRO

                ifge    INFO_LEVEL-\1

                bsr     putnl

                endc
                endm

DMPCHR:         MACRO   * level, ea

                ifge    INFO_LEVEL-\1

                move.l  \2,d0
                bsr     putchar

                endc
                endm

