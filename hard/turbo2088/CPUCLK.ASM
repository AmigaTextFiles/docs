
        NAME    CPUCLK
        TITLE   CPUCLK -- Switch clock speed of 8088/V20 on A2088 bridgeboard.
        PAGE    58,132
;..............................................................................
;
;       CPUCLK sets the clock speed of the 8088/V20 on the A2088 bridgeboard
;       by writing to the (write only) configuration register (port 63h) of
;       the Faraday FE2010A chip. This program will only work with a FE2010A!
;       The register is defined as follows:
;
;       Bit  Use
;        0    Disable parity
;        1    8087 Present (Enable 8087 NMI)
;        2    1 bank of 256K RAM's
;        3    lock register
;        4    ---
;        5    Semi-Fast
;        6    7.15MHz clock
;        7    9.54MHz clock
;
;
;       Written by Eddy Olk, 1991. This source is public domain and may be
;       freely distributed and used for non-commercial purposes.
;..............................................................................

cseg    SEGMENT
        ASSUME  cs:cseg

        ORG     100h

start:  mov     al,ds:[0080h]    ;get length of command line
        or      al,al
        jz      usage            ;no argument given
        mov     ah,ds:[0082h]    ;get 1st char of command line
        mov     al,03h
        cmp     ah,'0'
        jz      setclk
        mov     al,43h
        cmp     ah,'1'
        jz      setclk
        mov     al,83h
        cmp     ah,'2'
        jz      setclk

usage:  mov     dx,offset message
        mov     ah,9             ;good old CP/M print string
        int     21h
        int     20h              ;exit

setclk: out     63h,al
        int     20h              ;exit

message:
        db      "CPUCLK: set cpu clock speed of A2088."
        db      0dh,0ah
        db      "Usage: CPUCLK <0|1|2>"
        db      0dh,0ah,0ah
        db      "0 = 4.77 MHz, 1 = 7.15 MHz, 2 = 9.54 MHz"
        db      0dh,0ah,'$'

cseg    ENDS

        END     start

