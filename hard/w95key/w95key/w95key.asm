; W95key.asm v1.0

;This PIC code is made by Massimo Gais
;The original sources come from IBMKEY25.ASM, Copyright © 1997 Stephen Marsden
;They have been modified just to:
; 1) made it compilable with PicAsm v1.00-v1.06 by Timo Rossi
; 2) patch an annoying problem with my Italian win 95 keyboard, that is
;    the '/' key on keypad recognized as a '-'. If on your kbd the key 
;    next to the right shift is '-' and not '/', this could be a problem
;    for you, too. 


device PIC16C84
config PWRT=on, OSC=RC, WDT=off

include "pic16c84.h"

Bank0   macro
        bcf     STATUS,RP0
        endm

Bank1   macro
        bsf     STATUS,RP0
        endm

;
;------------------------------------------------------
;Please define ScratchPadRam here:
;If you are using PIC16C5X define "ScratchPadRam equ 0x10" 
;else define "ScratchPadRam equ 0x20"
;-------------------------------------------------------
;
ScrollLock  equ     0x0
NumLock     equ     0x1
CapsLock    equ     0x2
Kclk        equ     0x1
Kdat        equ     0x0
Aclk        equ     0x4
Adat        equ     0x3
Arst        equ     0x2
Ctrlbit     equ     0x0
RAmigabit   equ     0x1
LAmigabit   equ     0x2
Keytype     equ     0x0
Resetype    equ     0x1
;
ScratchPadRam   equ     0x0C
;
Capbit      equ     ScratchPadRam+0x0
Capdown     equ     ScratchPadRam+0x1
CtrlDown    equ     ScratchPadRam+0x2
RESET       equ     ScratchPadRam+0x3
Lights      equ     ScratchPadRam+0x4
Count3      equ     ScratchPadRam+0x5
ATparity    equ     ScratchPadRam+0x6
Make        equ     ScratchPadRam+0x7
Charbad     equ     ScratchPadRam+0x8
Oldchar     equ     ScratchPadRam+0x9
Amigachar   equ     ScratchPadRam+0xA
Count1      equ     ScratchPadRam+0xB
Count2      equ     ScratchPadRam+0xC
ATchar      equ     ScratchPadRam+0xD
tableoffset equ     ScratchPadRam+0xE
AltConfig   equ     ScratchPadRam+0xF
Savechar    equ     ScratchPadRam+0x10
returnvalue equ     ScratchPadRam+0x11
eeaddress   equ     ScratchPadRam+0x12
eedata      equ     ScratchPadRam+0x13
win95       equ     ScratchPadRam+0x14
Savechar2   equ     ScratchPadRam+0x15
;
;        
        org     0x0
        goto    start

ATtb1 
        movwf       PCL                  
        retlw       0x4F            ;F9
        retlw       0x0               
        retlw       0x57            ;F5
        retlw       0x5B            ;F3
        retlw       0x5F            ;F1
        retlw       0x5D            ;F2
        retlw       0x41            ;F12=HELP
        retlw       0x0
        retlw       0x4D            ;F10
        retlw       0x51            ;F8
        retlw       0x55            ;F6
        retlw       0x59            ;F4
        retlw       0x7B            ;TAB
        retlw       0xFF            ;~
        retlw       0x0

        retlw       0x0
        retlw       0x37            ;Left ALT
        retlw       0x3F            ;Left SHIFT
        retlw       0x0
        goto    lctrl               ;Left CTRL
        retlw       0xDF            ;Q
        retlw       0xFD            ;1
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x9D            ;Z
        retlw       0xBD            ;S
        retlw       0xBF            ;A
        retlw       0xDD            ;W
        retlw       0xFB            ;2
        retlw       0x0

        retlw       0x0
        retlw       0x99            ;C
        retlw       0x9B            ;X
        retlw       0xBB            ;D
        retlw       0xDB            ;E
        retlw       0xF7            ;4
        retlw       0xF9            ;3
        retlw       0x0
        retlw       0x0
        retlw       0x7F            ;SPACE
        retlw       0x97            ;V
        retlw       0xB9            ;F
        retlw       0xD7            ;T
        retlw       0xD9            ;R
        retlw       0xF5            ;5
        retlw       0x0

        retlw       0x0
        retlw       0x93            ;N
        retlw       0x95            ;B
        retlw       0xB5            ;H
        retlw       0xB7            ;G
        retlw       0xD5            ;Y
        retlw       0xF3            ;6
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x91            ;M
        retlw       0xB3            ;J
        retlw       0xD3            ;U
        retlw       0xF1            ;7
        retlw       0xEF            ;8
        retlw       0x0

        retlw       0x0
        retlw       0x8F            ;<
        retlw       0xB1            ;K
        retlw       0xD1            ;I
        retlw       0xCF            ;O
        retlw       0xEB            ;0
        retlw       0xED            ;9
        retlw       0x0
        retlw       0x0
        retlw       0x8D            ;>
        retlw       0x8B            ;/
        retlw       0xAF            ;L
        retlw       0xAD            ; ';'
        retlw       0xCD            ;P
        retlw       0xE9            ;-
        retlw       0x0

        retlw       0x0
        retlw       0x0
        retlw       0xAB            ;@
        retlw       0x0
        retlw       0xCB            ;[
        retlw       0xE7            ;=
        retlw       0x0
        retlw       0x0
        retlw       0x3B            ;CAPS LOCK?
        retlw       0x3D            ;Right SHIFT
        retlw       0x77            ;RETURN
        retlw       0xC9            ;]
        retlw       0x0
        retlw       0xA9            ;#=right foreign key
        retlw       0x0
        retlw       0x0

        retlw       0x0
        retlw       0x9F            ;\ (next to left shift on AT keyboard)
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x7D            ;Back SPACE
        retlw       0x0
        retlw       0x0
        retlw       0xC5            ;1 keypad
        retlw       0x0
        retlw       0xA5            ;4 keypad
        retlw       0x85            ;7 keypad
        retlw       0x0
        retlw       0x0
        retlw       0x0

        retlw       0xE1            ;0 keypad
        retlw       0x87            ;. keypad
        retlw       0xC3            ;2 keypad
        retlw       0xA3            ;5 keypad
        retlw       0xA1            ;6 keypad
        retlw       0x83            ;8 keypad
        retlw       0x75            ;ESCAPE!
        retlw       0x4B            ;Num Lock=[ keypad   
        retlw       0xE5            ;F11=\
        retlw       0x43            ;+ keypad
        retlw       0xC1            ;3 keypad
        retlw       0x6B            ;- keypad
        retlw       0x45            ;* keypad
        retlw       0x81            ;9 keypad
        retlw       0x49            ;Scr Lock=] keypad 
        retlw       0x0

ATtb2:
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x53            ;F7
        goto    prtscreen           ;print screen=R Amiga P  
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0

        retlw       0x0
        retlw       0x35            ;Right ALT
        retlw       0x0
        retlw       0x0
        goto    rctrl               ;Right CTRL
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x33            ;Left Win=Left Amiga

        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x31            ;Right Win=Right Amiga
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        goto    swapscreen          ;Menu Key=L-Amiga M
        
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0

        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x47            ;/ Keypad - NOTE: 0x8B is wrong here!!
                                    ;                 0x47 is right code
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0

        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x79            ;Enter Keypad
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0

        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        goto    endkey              ;End=Shift right-cursor  
        retlw       0x0
        retlw       0x61            ;Cursor Left
        goto    home                ;Home=Shift left-cursor  
        retlw       0x0
        retlw       0x0
        retlw       0x63            ;MACRO key=control

        goto    insert              ;Insert=Right Amiga 7
        retlw       0x73            ;Delete
        retlw       0x65            ;Cursor Down
        retlw       0x0
        retlw       0x63            ;Cursor Right
        retlw       0x67            ;Cursor Up
        retlw       0x0
        retlw       0x0
        retlw       0x0
        retlw       0x0
        goto    pagedown            ;Page Down=Shift down-cursor
        retlw       0x0
        goto    prtscreen           ;print screen=Right Amiga P
        goto    pageup              ;Page up=Shift up-cursor
        goto    break               ;Break=Ctrl-C
;        retlw       0x0



; *** Left Control key ***
lctrl
        btfsc   win95,0x0
        retlw   0x39                ; CTRL
        retlw   0x33                ; Left Amiga

; *** Right Control key ***
rctrl
        btfsc   win95,0x0
        retlw   0x39                ; CTRL
        retlw   0x31                ; Right Amiga
        

; *** Menu = Left Amiga-M ***
swapscreen
        movlw   0x33                ; Left Amiga pressed
        call    actualtransmit
        movlw   0x91                ; M pressed & released
        call    sendmessage
        movlw   0x32                ; Left Amiga released
        call    actualtransmit
        retlw   0x0          


; *** Prt Scrn Key = Right Amiga-P ***
prtscreen
        movlw   0x31                ; Right Amiga pressed
        call    actualtransmit
        movlw   0xCD                ; P pressed & released
        call    sendmessage
        movlw   0x30                ; Right Amiga released
        call    actualtransmit
        retlw   0x0          



; *** End Key = Shift right-cursor ***
endkey
        movlw   0x3D                ; Right shift pressed
        call    actualtransmit
        movlw   0x63                ; right-cursor pressed & released
        call    sendmessage
        movlw   0x3C                ; Right shift released
        call    actualtransmit
        retlw   0x0          



; *** Home Key = Shift left-cursor ***
home
        movlw   0x3D                ; Right shift pressed
        call    actualtransmit
        movlw   0x61                ; left-cursor pressed & released
        call    sendmessage
        movlw   0x3C                ; Right shift released
        call    actualtransmit
        retlw   0x0          



; *** PageDown Key = Shift down-cursor ***
pagedown
        movlw   0x3D                ; Right shift pressed
        call    actualtransmit
        movlw   0x65                ; down-cursor pressed & released
        call    sendmessage
        movlw   0x3C                ; Right shift released
        call    actualtransmit
        retlw   0x0          



; *** Pageup Key = Shift up-cursor ***
pageup
        movlw   0x3D                ; Right shift pressed
        call    actualtransmit
        movlw   0x67                ; up-cursor pressed & released
        call    sendmessage
        movlw   0x3C                ; Right shift released
        call    actualtransmit
        retlw   0x0          



; *** Insert Key = Right Amiga 7 ***
insert
        movlw   0x31                ; Right Amiga pressed
        call    actualtransmit
        movlw   0xF1                ; 7 pressed & released
        call    sendmessage
        movlw   0x30                ; Right Amiga released
        call    actualtransmit
        retlw   0x0          



; *** Break Key = Ctrl-C ***
break
        movlw   0x39                ; Ctrl pressed
        call    actualtransmit
        movlw   0x99                ; C pressed & released
        call    sendmessage
        movlw   0x38                ; Ctrl released
        call    actualtransmit
        retlw   0x0          



; *** Wait a long time ***
longdelay
        movwf   Count1
dly
        call    fixeddelay
        decfsz  Count1,F
        goto    dly
        return
;
; *** Wait a short while ***
fixeddelay
        movlw   0xFF
smalldelay
        movwf   Count2
delay
        decfsz  Count2,F
        goto    delay
        return


; *** Send character to Amiga and wait for handshake ***
amigatransmit
        movwf   Amigachar
        subwf   Oldchar,W
        btfsc   STATUS,Z            ; skip if not equal
        return                      ; ignore it
        
        movlw   0x33                ; LAmiga pressed
        subwf   Amigachar,W
        btfsc   STATUS,Z            ; skip if not equal
        bcf     RESET,LAmigabit
        movlw   0x32                ; LAmiga released
        subwf   Amigachar,W
        btfsc   STATUS,Z            ; skip if not equal
        bsf     RESET,LAmigabit
                
        movlw   0x31                ; RAmiga pressed
        subwf   Amigachar,W
        btfsc   STATUS,Z            ; skip if not equal
        bcf     RESET,RAmigabit
        movlw   0x30                ; RAmiga released
        subwf   Amigachar,W
        btfsc   STATUS,Z            ; skip if not equal
        bsf     RESET,RAmigabit
                
        movlw   0x3B                ; jump if not Capslock down
        subwf   Amigachar,W
        btfss   STATUS,Z            ; skip if equal
        goto    transok2            ; ignore it
        bcf     RESET,Ctrlbit
        movf    Amigachar,W
        movwf   Oldchar
        movlw   0xFF
        movwf   Capdown             ; set flags for later
        return
transok2
        movlw   0x3A                ; jump if not Capslock up
        subwf   Amigachar,W
        btfss   STATUS,Z            ; skip if equal
        goto    transok3            ; ignore it

        bsf     RESET,Ctrlbit
        movlw   0x3B                ; see if Capslock was just down
        subwf   Oldchar,W           ; 
        btfss   STATUS,Z            ; skip if equal
        goto    transok4            ; use as Ctrl key
        clrf    Capdown             ; clear flag
        comf    Capbit,F            ; toggle down/upness of caplock
        movlw   0x3B                ; send Capslock down
        btfss   Capbit,0x0
        andlw   0xFE
        call    actualtransmit
; send lights to AT
        movlw   0xED                ; Next data is for lights
        call    SendtoAT
        bsf     Lights,CapsLock     ; Capslock on
        btfss   Capbit,0x0
        bcf     Lights,CapsLock     ; Capslock off
        movf    Lights,W
        call    SendtoAT
        return
transok4
        btfsc   win95,0x0
        return
        clrf    CtrlDown
        clrf    Capdown             ; Capslock has finished acting as ctrl
        movlw   0x38                ; send Ctrl up
        call    actualtransmit
        return
transok3
        movf    Amigachar,W
        movwf   Savechar2
        movwf   Oldchar
        movf    Capdown,F           ; Capslock down?
        btfsc   STATUS,Z            ; skip if non-zero i.e caps pressed
        goto    nocontrol           ; ignore it
        btfsc   win95,0x0
        goto    nocontrol           ; ignore it
        movf    CtrlDown,F
        btfss   STATUS,Z            ; skip if zero i.e caps pressed
        goto    nocontrol           ; ignore it
        movlw   0xFF
        movwf   CtrlDown            ; Caps lock is now Ctrl key
        movlw   0x39                ; send Ctrl down
        call    actualtransmit
        movf    Savechar2,W
        goto    actualtransmit
nocontrol
        movf    Amigachar,W
        andlw   0xFE
        sublw   0x44                ; * (Numkey) released
        btfss   STATUS,Z            ; skip if equal
        clrf    AltConfig
        incf    AltConfig,F

        movlw   0x28                ; 20 th time?
        subwf   AltConfig,W
        btfsc   STATUS,Z            ; skip if not equal
        call    cnfgrt


        movf    Amigachar,W

actualtransmit
        movwf   Amigachar

        movlw   5           ; do a 5x256 delay
        call    longdelay
actual2
        movlw   8
        movwf   Count1
        clrf    Charbad
nextbit
        btfsc   Amigachar,0x7       ; IF bit7=1 THEN Adat=1
        bsf     PORTA,Adat
        btfss   Amigachar,0x7       ; IF bit7=0 THEN Adat=0
        bcf     PORTA,Adat
        movlw   8
        call    smalldelay          ; Allow Adat logic to settle
        bcf     PORTA,Aclk          ; transmit
        movlw   8
        call    smalldelay          ; Allow Aclk logic to settle
        bsf     PORTA,Aclk          ; reset Aclk=1
        movlw   10
        call    smalldelay          ; Allow Aclk logic to settle
        rlf     Amigachar,F
        decfsz  Count1,F            ; Transmit next bit?
        goto    nextbit

        movlw   0xF
        movwf   Count1
        movlw   0xFF
        movwf   Count1
        movwf   Count2

        Bank1          
        bsf     TRISA,Adat          ; Read acknowledge signal
        Bank0          
ack
        decf    Count1,F
        btfsc   STATUS,Z
        decf    Count2,F
        movf    Count2,W            ; Count2=0?
        btfsc   STATUS,Z
        goto    syncup              ; no handshake
        btfsc   PORTA,Adat          ; wait for handshake from amiga
        goto    ack
ready
        btfss   PORTA,Adat          ; wait for handshake to finish
        goto    ready

        bsf     PORTA,Adat          ; reset Adat=1
        Bank1          
        bcf     TRISA,Adat          ; Return to output mode
        Bank0          
        return
syncup
        bcf     PORTA,Aclk          ; send another clock pulse
        movlw   8
        call    smalldelay          ; Allow Aclk logic to settle
        bsf     PORTA,Aclk          ; reset Aclk=1
        movlw   0xFF
        movwf   Count1
        movwf   Count2
        decf    Count3,F
        btfsc   STATUS,Z
        return
        goto    ack                 ; wait for acknowledge again



; *** Send character to AT keyboard and wait for handshake ***
SendtoAT
        movwf   Charbad
resend
        movf    Charbad,W
        movwf   ATchar
        clrf    ATparity
        bsf     PORTB,Kclk          ; Kclk=1 get keyboards attention
        nop
        bcf     PORTB,Kdat          ; Kdat=0 get keyboards attention
        Bank1          
        bcf     TRISB,Kclk          ; Kclk is in output mode
        nop
        bcf     TRISB,Kdat          ; Kdat is in output mode
        Bank0          
        movlw   8
        movwf   Count1
        Bank1          
        bsf     TRISB,Kclk          ; Kclk is in input mode
        Bank0          
Send4   btfsc   PORTB,Kclk          ; wait for keyboard to make Kclk=0
        goto    Send4
        btfsc   ATchar,0x0          ; IF bit0=1 THEN Kdat=1
        bsf     PORTB,Kdat
        btfss   ATchar,0x0          ; IF bit0=0 THEN Kdat=0
        bcf     PORTB,Kdat
        rrf     ATchar,F            ; next bit
        btfsc   STATUS,C            ; test parity of bit shifted out
        incf    ATparity,F
Send5   btfss   PORTB,Kclk          ; wait for keyboard to make Kclk=1
        goto    Send5                
        decfsz  Count1,F
        goto    Send4
Send6   btfsc   PORTB,Kclk          ; wait for keyboard to make Kclk=0
        goto    Send6
        btfsc   ATparity,0x0        ; IF bit0=odd THEN Kdat=0 (odd parity)
        bcf     PORTB,Kdat
        btfss   ATparity,0x0        ; IF bit0=even THEN Kdat=1 (odd parity)
        bsf     PORTB,Kdat
Send7   btfss   PORTB,Kclk          ; wait for keyboard to make Kclk=1
        goto    Send7
Send77  btfsc   PORTB,Kclk          ; wait for keyboard to make Kclk=0
        goto    Send77
        bsf     PORTB,Kdat          ; stop bit
Send78  btfss   PORTB,Kclk          ; wait for keyboard to make Kclk=1
        goto    Send78
        Bank1          
        bsf     TRISB,Kdat          ; reset Kdat back to input mode
        Bank0          
Send79  btfsc   PORTB,Kclk          ; wait for keyboard to make Kclk=0
        goto    Send79
Send7a  btfss   PORTB,Kclk          ; wait for keyboard to make Kclk=1
        goto    Send7a
        movlw   8
        call    smalldelay          ; Allow Kclk logic to settle
        bcf     PORTB,Kclk          ; Kclk=0 Send handshake
        Bank1          
        bcf     TRISB,Kclk          ; Kclk is in output mode
        Bank0          
        movlw   20
        call    smalldelay          ; Allow keyboard chance 
        call    ATgetkey
        movlw   0xFA                ; Was transmission ok
        subwf   ATchar,W
        btfss   STATUS,Z            ; skip if good
        goto    resend
        return
        

; *** Waits for keyboard to send code ***
ATgetkey
        clrf    ATchar
        bsf     PORTB,Kclk          ; Kclk=1 Allow keyboard to talk
        Bank1
        bsf     TRISB,Kclk          ; Kclk is in input mode
        Bank0
skip1st btfsc   PORTB,Kclk          ; wait for keyboard to make Kclk=0
        goto    skip1st
skippy  btfss   PORTB,Kclk          ; wait for keyboard to make Kclk=1
        goto    skippy
        movlw   8
        movwf   Count1
ATwait0
        btfsc   PORTB,Kclk          ; wait for keyboard to make Kclk=0
        goto    ATwait0
        rrf     ATchar,F
        btfsc   PORTB,Kdat
        bsf     ATchar,0x7
        btfss   PORTB,Kdat
        bcf     ATchar,0x7
ATwait1 btfss   PORTB,Kclk          ; wait for keyboard to make Kclk=1
        goto    ATwait1
        decfsz  Count1,F
        goto    ATwait0             ; get all 8 bits of data
parity0 btfsc   PORTB,Kclk          ; wait for keyboard to make Kclk=0
        goto    parity0
parity1 btfss   PORTB,Kclk          ; wait for keyboard to make Kclk=1
        goto    parity1
stop0   btfsc   PORTB,Kclk          ; wait for keyboard to make Kclk=0
        goto    stop0
stop1   btfss   PORTB,Kclk          ; wait for keyboard to make Kclk=1
        goto    stop1
        bcf     PORTB,Kclk          ; Kclk=0 Send handshake
        Bank1
        bcf     TRISB,Kclk          ; Kclk is in output mode
        Bank0
        movlw   20
        call    smalldelay          ; Allow keyboard chance to recieve
        return


; *** Flash Light ***
flash
        movwf   Lights
        movlw   0xED                ; Next data is for lights
        call    SendtoAT
        movf    Lights,W            ; Flash lights
        call    SendtoAT
        movlw   0x25
        call    longdelay     
        movlw   0xED                ; Next data is for lights
        call    SendtoAT
        movlw   0x0                 ; Clear Lights
        call    SendtoAT
        movlw   0x25
        call    longdelay     
                return


; *** Performs reset on Amiga ***
reset
        movlw   Resetype
        call    readdata
        sublw   0x1                 
        btfsc   STATUS,Z            ; skip if not equal
        goto    kill                ; jump if fast reset
        movlw   0x0F                ; Tell amiga we are going to reset it
        call    actualtransmit

                movlw   0x8
        movwf   Count3
strobe  movlw   0x1
        call    flash
        movlw   0x2
        call        flash
        movlw   0x4
        call        flash
        decfsz  Count3,F
        goto    strobe
kill
        movlw   0x70
        call    longdelay     
        bcf     PORTB,Arst          ; Arst=0 Send reset
        Bank1
        bcf     TRISB,Arst          ; Arst is in output mode
        Bank0
        movlw   0xFF
        call    longdelay           ; Wait for Amiga to reset
        goto    start2


; **** Start here ****

start

; *** Allow time for HardDrive to spin upto speed ***
SpinUp
        bcf     PORTB,Arst          ; Arst=0 Send reset
        Bank1
        bcf     TRISB,Arst          ; Arst is in output mode
        Bank0
        movlw   0x30
        movwf   Count3
waitHD
        movlw   0xFF
        call    longdelay           ; Wait for drive to wake up
        decfsz  Count3,F
        goto    waitHD

start2
; *** Setup ports ***
        bsf     PORTA,Aclk          ; transmit
        nop
        bsf     PORTA,Adat
        Bank1          
        movlw   0x7
        movwf   TRISA
        movlw   0xFF
        movwf   TRISB
        Bank0          


; *** Clear out miscellaneous flags ***
        clrf    Capdown
        clrf    CtrlDown
        clrf    Capbit
        clrf    Oldchar
        clrf    AltConfig
        movlw   0x7
        movwf   RESET

; *** See what sort of keyboard is attached ***
        clrf    win95
        movlw   Keytype
        call    readdata
        sublw   0x2                 
        btfsc   STATUS,Z            ; skip if not equal
        comf    win95               ; win95=true or false

; *** Wait for AT keyboard to power up ***
waitAT
        btfss   PORTB,Kdat         ; wait for AT keyboard
        goto    waitAT
        
; *** Reset AT keyboard ***
;        movlw   0xFF            ; Reset
;        call    SendtoAT
        movlw   0xF6            ; Default
        call    SendtoAT
        movlw   0x7
        call    flash
        movlw   0xED            ; Next data is for lights
        call    SendtoAT
        movlw   0x2
        movwf   Lights
        call    SendtoAT
        movlw   0xF4            ; Clear buffer
        call    SendtoAT


ATstyle
        movf    RESET,F
        btfsc   STATUS,Z
        goto    reset
        call    ATgetkey
        movlw   0xE1
        subwf   ATchar,W
        btfss   STATUS,Z            ; skip if equal
        goto    ATnE1        
        call    ATgetkey            ; should be $14
        call    ATgetkey            ; should be $77
        call    ATgetkey            ; should be $E1
        call    ATgetkey            ; should be $F0
        call    ATgetkey            ; should be $14
        call    ATgetkey            ; should be $F0
        call    ATgetkey            ; should be $77
        goto    ATstyle
ATnE1
        clrf    tableoffset
        movlw   0xE0
        subwf   ATchar,W
        btfss   STATUS,Z            ; skip if equal
        goto    ATnE0        
        movlw   0x80
        movwf   tableoffset
        call    ATgetkey
        movlw   0xF0
        subwf   ATchar,W
        btfss   STATUS,Z            ; skip if equal
        goto    ATnE0F0        
        call    ATgetkey
        movlw   0x12
        subwf   ATchar,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; E0F012 ignore it
ATnEF12
        movlw   0x59
        subwf   ATchar,W
        btfss   STATUS,Z            ; skip if equal
        goto    ATup        
        goto    ATstyle             ; E0F059 ignore it
ATnE0F0
        movlw   0x12
        subwf   ATchar,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; E012 ignore it
ATnE012
        movlw   0x59
        subwf   ATchar,W
        btfss   STATUS,Z            ; skip if equal
        goto    ATdown        
        goto    ATstyle             ; E059 ignore it
ATnE0
        movlw   0xF0
        subwf   ATchar,W
        btfss   STATUS,Z            ; skip if equal
        goto    ATdown        
        call    ATgetkey
        goto    ATup                ; F0= key released
ATdown        
        incf    ATchar,W
        addwf   tableoffset,W
        call    ATtb1
        addlw   0x0                 ; test W
        btfss   STATUS,Z
        call    amigatransmit
        goto    ATstyle
ATup        
        incf    ATchar,W
        addwf   tableoffset,W
        movwf   tableoffset

        movlw   0xAF+1              ; menu key
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movlw   0x84+1              ; PrtScrn
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movlw   0xE9+1              ; End
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movlw   0xEC+1              ; Home
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movlw   0xF0+1              ; Insert
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movlw   0xFA+1              ; PageDown
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movlw   0xFC+1              ; PrtScrn
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movlw   0xFD+1              ; PageUp
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movlw   0xFE+1              ; Break
        subwf   tableoffset,W
        btfsc   STATUS,Z            ; skip if not equal
        goto    ATstyle             ; ignore it

        movf    tableoffset,W
        call    ATtb1
        andlw   0xFE                ; clear bit 0
        call    amigatransmit
        goto    ATstyle
        

; *** Change configuration ***
cnfgrt
        clrf    eeaddress
        movlw   0x3B                ; CAPSLOCK ON
        call    actualtransmit
        
        call    say_select          ; Select Type of
        call    say_key             ; key
        movlw   0x95                ; b
        call    sendmessage
        movlw   0xCF                ; o
        call    sendmessage
        movlw   0xBF                ; a
        call    sendmessage
        movlw   0xD9                ; r
        call    sendmessage
        movlw   0xBB                ; d
        call    sendmessage
        call    say_option1         ; 1=
        call    say_uk10            ; uk 10
        movlw   0xFB                ; 2
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        call    say_key             ; key
        call    say_option2         ; 2=
        call    say_uk10            ; uk 10
        movlw   0xF5                ; 5
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        call    say_key             ; key
        movlw   0x7F                ; space
        call    sendmessage
        movlw   0xDD                ; w
        call    sendmessage
        movlw   0xD1                ; i
        call    sendmessage
        movlw   0x93                ; n
        call    sendmessage
        movlw   0xED                ; 9
        call    sendmessage
        movlw   0xF5                ; 5
        call    sendmessage
        movlw   0x77                ; return 
        call    sendmessage
        call    getselection
        movwf   eedata
        movf    eedata,W
        btfsc   STATUS,Z            ; skip if not zero
        goto    cnfgrt              ; bad choice, try again
        call    writedata        
        call    say_ok
        clrf    win95
        movlw   Keytype
        call    readdata
        sublw   0x2                 
        btfsc   STATUS,Z            ; skip if not equal
        comf    win95               ; win95=true or false

        incf    eeaddress
askreset
        call    say_select          ; Select Type of
        call    say_reset           ; reset
        call    say_option1         ; 1=
        movlw   0xB9                ; f
        call    sendmessage
        movlw   0xBF                ; a
        call    sendmessage
        movlw   0xBD                ; s
        call    sendmessage
        movlw   0xD7                ; t
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        call    say_reset           ; reset
        call    say_option2         ; 2=
        movlw   0xBD                ; s
        call    sendmessage
        movlw   0xAF                ; l
        call    sendmessage
        movlw   0xCF                ; o
        call    sendmessage
        movlw   0xDD                ; w
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        call    say_reset           ; reset
        movlw   0x77                ; return 
        call    sendmessage

        call    getselection
        movwf   eedata
        movf    eedata,W
        btfsc   STATUS,Z            ; skip if not zero
        goto    askreset            ; bad choice, try again
        call    writedata        
        call    say_ok

        clrf    AltConfig
        movlw   0x7E                ; space up
        movf    Capdown,F           ; Capslock down?
        btfsc   STATUS,Z            ; skip if non-zero i.e caps pressed
        movlw   0x3A                ; Caps up
        movwf   Amigachar
        return
        
say_select
        movlw   0x77                ; return x2
        call    sendmessage
        call    sendmessage
        movlw   0xBD                ; s
        call    sendmessage
        movlw   0xDB                ; e
        call    sendmessage
        movlw   0xAF                ; l
        call    sendmessage
        movlw   0xDB                ; e
        call    sendmessage
        movlw   0x99                ; c
        call    sendmessage
        movlw   0xD7                ; t
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        movlw   0xD7                ; t
        call    sendmessage
        movlw   0xD5                ; y
        call    sendmessage
        movlw   0xCD                ; p
        call    sendmessage
        movlw   0xDB                ; e
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        movlw   0xCF                ; o
        call    sendmessage
        movlw   0xB9                ; f
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        return

say_key
        movlw   0xB1                ; k
        call    sendmessage
        movlw   0xDB                ; e
        call    sendmessage
        movlw   0xD5                ; y
        call    sendmessage
        return

say_option1
       movlw   0x77                ; return x2
        call    sendmessage
        call    sendmessage
        movlw   0xFD                ; 1
        call    sendmessage
        movlw   0xE7                ; =
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        return

say_option2
        movlw   0x77                ; return 
        call    sendmessage
        movlw   0xFB                ; 2
        call    sendmessage
        movlw   0xE7                ; =
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        return

say_uk10
        movlw   0xD3                ; u
        call    sendmessage
        movlw   0xB1                ; k
        call    sendmessage
        movlw   0x7F                ; space
        call    sendmessage
        movlw   0xFD                ; 1
        call    sendmessage
        movlw   0xEB                ; 0
        call    sendmessage
        return

say_ok
        movlw   0xCF                ; o
        call    sendmessage
        movlw   0xB1                ; k
        call    sendmessage
        movlw   0x77                ; return
        call    sendmessage
        return

say_reset
        movlw   0xD9                ; r
        call    sendmessage
        movlw   0xDB                ; e
        call    sendmessage
        movlw   0xBD                ; s
        call    sendmessage
        movlw   0xDB                ; e
        call    sendmessage
        movlw   0xD7                ; t
        call    sendmessage
        return


sendmessage
        movwf   Savechar
        call    actualtransmit
        movf    Savechar,W
        andlw   0xFE
        call    actualtransmit
        movf    Savechar,W
        return        

getselection
        call    ATgetkey
        call    ATgetkey
        call    ATgetkey
        movlw   0x16                ; was key 1 pressed and released
        subwf   ATchar,W
        btfsc   STATUS,Z            ; skip if not equal
        retlw   0x1     
        movlw   0x1E                ; was key 2 pressed and released
        subwf   ATchar,W
        btfsc   STATUS,Z            ; skip if not equal
        retlw   0x2        
        retlw   0x0

writedata
        movf    eeaddress,W
        movwf   EEADR
        movf    eedata,W
        movwf   EEDATA
        Bank1
        bsf     EECON1,WREN         ; EEPROM write enable
        movlw   0x55
        movwf   EECON2
        movlw   0xAA
        movwf   EECON2
        bsf     EECON1,EWR
wait_write
        btfss   EECON1,EEIF         ; wait for write to finish
        goto    wait_write
        clrf    EECON1              ; EEPROM write disable & int accept
        Bank0
        return

readdata
        movwf   EEADR
        Bank1
        bsf     EECON1,ERD           ; EEPROM read
        Bank0
        movf    EEDATA,W
        return

        end

; **** EOF ****