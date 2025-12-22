; -------------------------------------
;  PS/2 Mouse to Amiga Mouse Converter
; -------------------------------------
;
; Version: V1.0 (30-Jun-2001)
; Author : N. Baricevic <nogoth@yahoo.com>
;


; ------------------------------------------
;  includes
; ------------------------------------------

W               equ     0x00
F               equ     0x01
STATUS          equ     0x03
PORTA           equ     0x05
PORTB           equ     0x06
TRISA           equ     0x05
TRISB           equ     0x06
RP0             equ     0x05
Z               equ     0x02
C               equ     0x00

; ------------------------------------------


        list    p=pic16c84


; ---------- registers definition -----------

byte    equ     0x0c            ; byte to receive or send
parity  equ     0x0d            ; parity bit is held here
parcnt  equ     0x0e            ; counter for calculating parity
roller  equ     0x0f            ; help for 8 data bits to byte conversion
pack1   equ     0x10            ; 1st byte of mouse data packet
pack2   equ     0x11            ; 2nd byte of mouse data packet
pack3   equ     0x12            ; 3rd byte of mouse data packet
xrot    equ     0x13            ; rotation byte for H and HQ
yrot    equ     0x14            ; rotation byte for V and VQ
delcnt  equ     0x15            ; delay counter

; --------- main routine -----------

        org     0

main:   bsf     STATUS,RP0      ; page 1
        bsf     TRISA,0         ; port A, bit 0 is input
        bsf     TRISA,1         ; port A, bit 1 is input
        clrf    TRISB           ; port B is all outputs
        bcf     STATUS,RP0      ; page 0
        movlw   0xff
        movwf   PORTB           ; port B all pins to 1
        movlw   0x2d            ; put b'00101101' to xrot and yrot
        movwf   xrot
        movwf   yrot
        call    REC             ; receive byte from mouse
        call    INHIB           ; pull CLK low to inhibit furhter sending
        movf    byte,W
        xorlw   0xaa            ; if it's $AA mouse self test passed
        btfss   STATUS,Z
        goto    IERROR
        call    REL             ; release CLK (allow mouse to send)
        call    REC             ; receive byte from mouse
        call    INHIB
        movf    byte,W
        xorlw   0x00            ; mouse ID code should be $00
        btfss   STATUS,Z
        goto    IERROR
        movlw   0xf4            ; "Enable Data Reporting" command to mouse
        movwf   byte
        call    NEWPAR          ; get parity for $F4
        call    REL
        call    DEL200
        call    SEND            ; send command to mouse
        call    REC             ; receive acknowledge ($FA) from mouse)
        call    INHIB
        movf    byte,W
        xorlw   0xfa
        btfss   STATUS,Z
        goto    IERROR
        call    REL
CHK:    call    REC             ; receive byte1 from mouse packet
        call    INHIB
        movf    byte,W
        movwf   pack1
        call    REL
        call    REC             ; receive byte2 from mouse packet
        call    INHIB
        movf    byte,W
        movwf   pack2
        call    REL
        call    REC             ; receive byte3 from mouse packet
        call    INHIB
        movf    byte,W
        movwf   pack3
        call    CONV
        call    REL
        goto    CHK             ; receive another packet

; --------------------------------------------------------

PERROR: nop
RERROR: nop
IERROR: bcf     PORTB,7
E_LOOP: goto    E_LOOP

; --------------------------------------------------------

DEL10:  nop                     ; delay 10us
        return
DEL200: movlw   0x32            ; delay 200us
        movwf   delcnt
DEL2:   decfsz  delcnt
        goto    DEL2
        return

; --------- byte receiving subroutine -------------

REC:    btfsc   PORTA,0         ; wait clock (start bit)
        goto    REC
RL1:    btfss   PORTA,0
        goto    RL1
        call    RECBIT          ; receive 8 data bits
        call    RECBIT
        call    RECBIT
        call    RECBIT
        call    RECBIT
        call    RECBIT
        call    RECBIT
        call    RECBIT
RL2:    btfsc   PORTA,0         ; receive parity bit
        goto    RL2
        btfsc   PORTA,1
        goto    RL3
        bcf     parity,0
RL4:    btfss   PORTA,0         ; receive stop bit
        goto    RL4
STP:    btfsc   PORTA,0
        goto    STP
        btfss   PORTA,1
        goto    RERROR
RL8:    btfss   PORTA,0
        goto    RL8
        return
RL3:    bsf     parity,0
        goto    RL4

; ---------- bit receiving subroutine ------------

RECBIT: btfsc   PORTA,0
        goto    RECBIT
        movf    PORTA,W
        movwf   roller
        rrf     roller
        rrf     roller
        rrf     byte
RL5:    btfss   PORTA,0
        goto    RL5
        return

; ---------- subroutines -----------------

INHIB:  call    CLKLO           ; inhibit mouse sending (CLK low)
        call    DEL200
        return
REL:    call    CLKHI           ; allow mouse to send data
        return
CLKLO:  bsf     STATUS,RP0      ; CLK low
        bcf     TRISA,0
        bcf     STATUS,RP0
        bcf     PORTA,0
        return
CLKHI:  bsf     STATUS,RP0      ; CLK high
        bsf     TRISA,0
        bcf     STATUS,RP0
        return
DATLO:  bsf     STATUS,RP0      ; DATA low
        bcf     TRISA,1
        bcf     STATUS,RP0
        bcf     PORTA,1
        return
DATHI:  bsf     STATUS,RP0      ; DATA high
        bsf     TRISA,1
        bcf     STATUS,RP0
        return

; ------------- send to mouse --------------

SEND:   call    INHIB           ; CLK low
        call    DEL10
        call    DATLO           ; DATA low
        call    DEL10
        call    REL             ; CLK high
SL1:    btfsc   PORTA,0         ; wait for CLK
        goto    SL1
        call    SNDBIT          ; send 8 data bits
SS1:    btfss   PORTA,0
        goto    SS1
SS2:    btfsc   PORTA,0
        goto    SS2
        call    SNDBIT
SS3:    btfss   PORTA,0
        goto    SS3
SS4:    btfsc   PORTA,0
        goto    SS4
        call    SNDBIT
SS5:    btfss   PORTA,0
        goto    SS5
SS6:    btfsc   PORTA,0
        goto    SS6
        call    SNDBIT
SS7:    btfss   PORTA,0
        goto    SS7
SS8:    btfsc   PORTA,0
        goto    SS8
        call    SNDBIT
SS9:    btfss   PORTA,0
        goto    SS9
SS10:   btfsc   PORTA,0
        goto    SS10
        call    SNDBIT
SS11:   btfss   PORTA,0
        goto    SS11
SS12:   btfsc   PORTA,0
        goto    SS12
        call    SNDBIT
SS13:   btfss   PORTA,0
        goto    SS13
SS14:   btfsc   PORTA,0
        goto    SS14
        call    SNDBIT
SS15:   btfss   PORTA,0
        goto    SS15
SS16:   btfsc   PORTA,0
        goto    SS16
        call    SNDPAR          ; send parity bit
SS17:   btfss   PORTA,0
        goto    SS17
SS18:   btfsc   PORTA,0
        goto    SS18
        call    DATHI           ; release bus
SL4:    btfss   PORTA,0
        goto    SL4
SL5:    btfsc   PORTA,0
        goto    SL5
        btfsc   PORTA,1
        goto    RERROR
SL7:    btfss   PORTA,0
        goto    SL7
SL8:    btfss   PORTA,1
        goto    SL8
        return

; -------------- subroutines --------------

SNDBIT: rrf     byte            ; send data bit
        btfsc   STATUS,C
        goto    DHIGH
        call    DATLO
SL2:    return
DHIGH:  call    DATHI
        goto    SL2
SNDPAR: btfsc   parity,0        ; send parity bit
        goto    PHIGH
        call    DATLO
SP1:    return
PHIGH:  call    DATHI
        goto    SP1
CLCPAR: movlw   0               ; calculate parity bit
        movwf   parcnt
        btfsc   byte,0
        incf    parcnt
        btfsc   byte,1
        incf    parcnt
        btfsc   byte,2
        incf    parcnt
        btfsc   byte,3
        incf    parcnt
        btfsc   byte,4
        incf    parcnt
        btfsc   byte,5
        incf    parcnt
        btfsc   byte,6
        incf    parcnt
        btfsc   byte,7
        incf    parcnt
        return
NEWPAR: call    CLCPAR
        btfss   parcnt,0
        goto    PARONE
        bcf     parity,0
        return
PARONE: bsf     parity,0
        return
CHKPAR: call    CLCPAR          ; check parity
        movf    parcnt,W
        andlw   0x01
        movwf   parcnt
        movf    parity,W
        xorwf   parcnt
        btfss   STATUS,Z
        return
        call    PERROR
        return

; --------------- conversion to Amiga format --------------

CONV:   btfsc   pack1,0         ; left button
        goto    LPRESS
        bsf     PORTB,6
CON1:   btfsc   pack1,1         ; right button
        goto    RPRESS
        bsf     PORTB,0
CON2:   btfsc   pack1,2         ; middle button
        goto    MPRESS
        bsf     PORTB,1
MOVE:   movf    pack2,W         ; movement conversion
        andlw   0xff
        btfss   STATUS,Z
        call    MOVEX
        movf    pack3,W
        andlw   0xff
        btfss   STATUS,Z
        call    MOVEY
        return
LPRESS: bcf     PORTB,6
        goto    CON1
RPRESS: bcf     PORTB,0
        goto    CON2
MPRESS: bcf     PORTB,1
        goto    MOVE
MOVEX:  btfss   pack1,4
        goto    LEFT
        goto    RIGHT
MOVEY:  btfss   pack1,5
        goto    DOWN
        goto    UP
LEFT:   call    DEL200          ; send H and HQ for left movement
        rlf     xrot
        btfss   STATUS,C
        goto    LH0
        goto    LH1
LH0:    bcf     xrot,0
        bcf     PORTB,4
        goto    LHQ
LH1:    bsf     xrot,0
        bsf     PORTB,4
LHQ:    rlf     xrot
        btfss   STATUS,C
        goto    LHQ0
        goto    LHQ1
LHQ0:   bcf     xrot,0
        bcf     PORTB,2
        goto    LONE
LHQ1:   bsf     xrot,0
        bsf     PORTB,2
LONE:   decfsz  pack2
        goto    LEFT
        return
RIGHT:  call    DEL200          ; send H and HQ for right movement
        rrf     xrot
        btfss   STATUS,C
        goto    RHQ0
        goto    RHQ1
RHQ0:   bcf     xrot,7
        bcf     PORTB,2
        goto    RH
RHQ1:   bsf     xrot,7
        bsf     PORTB,2
RH:     rrf     xrot
        btfss   STATUS,C
        goto    RH0
        goto    RH1
RH0:    bcf     xrot,7
        bcf     PORTB,4
        goto    RONE
RH1:    bsf     xrot,7
        bsf     PORTB,4
RONE:   incfsz  pack2
        goto    RIGHT
        return
UP:     call    DEL200          ; send V and VQ for up movement
        rlf     yrot
        btfss   STATUS,C
        goto    UV0
        goto    UV1
UV0:    bcf     yrot,0
        bcf     PORTB,5
        goto    UVQ
UV1:    bsf     yrot,0
        bsf     PORTB,5
UVQ:    rlf     yrot
        btfss   STATUS,C
        goto    UVQ0
        goto    UVQ1
UVQ0:   bcf     yrot,0
        bcf     PORTB,3
        goto    UONE
UVQ1:   bsf     yrot,0
        bsf     PORTB,3
UONE:   incfsz  pack3
        goto    UP
        return
DOWN:   call    DEL200          ; send V and VQ for down movement
        rrf     yrot
        btfss   STATUS,C
        goto    DVQ0
        goto    DVQ1
DVQ0:   bcf     yrot,7
        bcf     PORTB,3
        goto    DV
DVQ1:   bsf     yrot,7
        bsf     PORTB,3
DV:     rrf     yrot
        btfss   STATUS,C
        goto    DV0
        goto    DV1
DV0:    bcf     yrot,7
        bcf     PORTB,5
        goto    DONE
DV1:    bsf     yrot,7
        bsf     PORTB,5
DONE:   decfsz  pack3
        goto    DOWN
        return
        end

