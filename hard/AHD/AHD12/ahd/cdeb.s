        xdef    _cputstr
        xdef    _SysBase
        xdef    _ExpansionBase

        xref    KPutStr

        section "cdebcode",code

_cputstr:
        move.l  4(sp),a0
        jmp     KPutStr(pc)

        section "cdebbss",bss

_SysBase        ds.l    1
_ExpansionBase  ds.l    1

        end

