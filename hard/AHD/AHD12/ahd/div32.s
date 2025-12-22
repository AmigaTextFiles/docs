        SECTION   "text",CODE

        xdef    _CXD33
        xdef    _CXD22

;  d0
; ---- = d0 (quotient), d1 (remainder)
;  d1

_CXD33:
        TST.L     D0
        BPL       L000002
        NEG.L     D0
        TST.L     D1
        BPL       L000001
        NEG.L     D1
        BSR       _CXD22
        NEG.L     D1
        RTS
L000001:
        BSR       _CXD22
        NEG.L     D0
        NEG.L     D1
        RTS
L000002:
        TST.L     D1
        BPL       _CXD22
        NEG.L     D1
        BSR       _CXD22
        NEG.L     D0
        RTS
_CXD22:
        MOVE.L    D2,-(A7)
        SWAP.W    D1
        MOVE.W    D1,D2
        BNE       L000004
        SWAP.W    D0
        SWAP.W    D1
        SWAP.W    D2
        MOVE.W    D0,D2
        BEQ       L000003
        DIVU.W    D1,D2
        MOVE.W    D2,D0
L000003:
        SWAP.W    D0
        MOVE.W    D0,D2
        DIVU.W    D1,D2
        MOVE.W    D2,D0
        SWAP.W    D2
        MOVE.W    D2,D1
        MOVE.L    (A7)+,D2
        RTS
L000004:
        MOVE.L    D3,-(A7)
        MOVEQ.L   #16,D3
        CMPI.W    #128,D1
        BCC       L000005
        ROL.L     #8,D1
        SUBQ.W    #8,D3
L000005:
        CMPI.W    #2048,D1
        BCC       L000006
        ROL.L     #4,D1
        SUBQ.W    #4,D3
L000006:
        CMPI.W    #8192,D1
        BCC       L000007
        ROL.L     #2,D1
        SUBQ.W    #2,D3
L000007:
        TST.W     D1
        BMI       L000008
        ROL.L     #1,D1
        SUBQ.W    #1,D3
L000008:
        MOVE.W    D0,D2
        LSR.L     D3,D0
        SWAP.W    D2
        CLR.W     D2
        LSR.L     D3,D2
        SWAP.W    D3
        DIVU.W    D1,D0
        MOVE.W    D0,D3
        MOVE.W    D2,D0
        MOVE.W    D3,D2
        SWAP.W    D1
        MULU.W    D1,D2
        SUB.L     D2,D0
        BCC       L00000A
        SUBQ.W    #1,D3
        ADD.L     D1,D0
L000009:
        BCC.S     L000009
L00000A:
        MOVEQ.L   #0,D1
        MOVE.W    D3,D1
        SWAP.W    D3
        ROL.L     D3,D0
        SWAP.W    D0
        EXG.L     D1,D0
        MOVE.L    (A7)+,D3
        MOVE.L    (A7)+,D2
        RTS

        END

