        xref    readsec
        xref    writesec
        xref    dofmttrk
        xref    doinit
        xref    doreset
        xref    hdconfig

        xdef    _readhardsec
        xdef    _writehardsec
        xdef    _fmthard
        xdef    _doinit
        xdef    _doreset
        xdef    _hdconfig

        section "gluecode",code

_readhardsec:           ; int readhardsec(data, offset, length);
        link    a5,#0
        move.l  8(a5),a2        ; char *data
        move.l  12(a5),d0       ; ULONG offset
        move.l  16(a5),d1       ; ULONG length
        move.b  #0,d3

        jsr     readsec

        unlk    a5
        rts

_writehardsec:           ; int writehardsec(data, offset, length);
        link    a5,#0
        move.l  8(a5),a2        ; char *data
        move.l  12(a5),d0       ; ULONG offset
        move.l  16(a5),d1       ; ULONG length
        move.b  #0,d3

        jsr     writesec

        unlk    a5
        rts

_fmthard:               ; int fmthard(offset);
        link    a5,#0
        move.l  8(a5),d0
        move.b  #0,d3

        jsr     dofmttrk

        unlk    a5
        rts

_doinit:                ; int doinit(void);
        move.b  #0,d3
        jmp     doinit

_doreset:               ; int doreset(void);
        move.b  #0,d3
        jmp     doreset

_hdconfig:              ; int hdconfig(short *);
        link    a5,#0
        move.l  8(a5),a0
        move.b  #0,d3

        jsr     hdconfig

        unlk    a5
        rts

        end

