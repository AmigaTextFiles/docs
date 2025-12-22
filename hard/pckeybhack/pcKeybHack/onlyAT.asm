;* these port equates are explained below. Relocate them to any of
;* Port1, pins 0-7 or Port3, pins 0-7, except Port3, pins2 and 3
;* because these are the external interrupts.
;* it doesn't matter as long as you equate the right pin to the right
;* signal.

        .equ    Kclk,p1.0
        .equ    Kdat,p1.1
        .equ    Aclk,p1.3
        .equ    Adat,p1.4
        .equ    Areset,p1.5
        .equ    switch95,p1.6
        .equ    switchMap,p1.7
        .equ    usFlag,p1.2

        .org    0000h

init:   setb    ColdBoot
        ljmp    start
        .org    001bh
        ljmp    timer1int

;**************************************************
;*
;*
;* Equates Descriptions:
;*
;*      Aclk is the line to the Amiga keyboard clock in. (P1.3)
;*      Adat is the line to the Amiga keyboard data in. (P1.4)
;*      Areset is the Amiga Reset line (P1.5)
;*      Kclk is the line to the Keyboard clock out (P1.0)
;*      Kdat is the line to the Keyboard data out (P1.1)
;*		switch95 is the input signal to toggle between 102 and
;*				the 105 AT mapping.
;*		switchMap is the input signal to toggle between mapping
;*				the xtra keys and  sending rawkey codes
;*
;*      Oldchar is the last character typed to go to the Amiga.
;* This is used to tell if the Capslock was Pressed and 
;* Released without pressing any other keys. If this was done, 
;* then it is a "Caps Lock" otherwise, the Caps key functions
;* as the Control Key because of the keyboard remapping.
;*
;*      Capbit is the flag which tells whether the Caps Lock
;* should be down or up.
;*      Capdown is the flag which tells whether the Caps Lock 
;* KEY is presently down or up. The difference between Capdown 
;* and Capbit is that Capdown relates to the KEY. Capbit toggles 
;* once for every "press and release" of the Cap Lock Key. 
;* Press and release Cap Lock Key, and Capbit goes low.....
;* Press and release it again, and Capbit goes high....
;*      Cntldown is the flag which is set and reset when you 
;* press Cap Lock and then another key. Then, Cap Lock Key 
;* functions as the Control Key.
;* LAMIGA,RAMIGA,and CONTROL are all flags that tell if those 
;* keys are being held down. When all three are, the computer
;* will reset.
;*
;* ATparity is the 10th bit that the AT keyboard transmits. It 
;* is SET if the number of DATA bits set is EVEN. Otherwise, its
;* CLEARED.
;*
;**************************************************

        ;bit memory locations:

        .equ    Capbit,42h
        .equ    Capdown,43h
        .equ    Ctrldown,44h
        .equ    CONTROL,45h
        .equ    LAMIGA,46h
        .equ    RAMIGA,47h
        .equ    ATparity,48h
        .equ    Make,49h
         .equ    ColdBoot,50h

        ;byte memory locations:

        .equ    Charbad,50h
        .equ    Oldchar,51h
        .equ    Amigachar,52h
        .equ    tempo,53h
        .equ    mkey,54h
        .equ    scrollKey,55h

        .org    0200h

start:  mov     tmod,#11h       ;two 16 bit timers
        mov     ie,#00h         ;clear all interrupts
        setb    ea              ;allow interrupt
        setb    et1             ;enable timer 1 interrupt
        setb    pt0				;timer 0 has high priority
        mov     sp,#30h         ;stack somewhere safe.

; set the ports for input
        mov     p1,#255         ;set port1 for read
        mov     p3,#255         ;set port 3 for read
        clr     tr1             ;make sure timers are in
        clr     tf1             ;reset state.
        clr     tr0
        clr     tf0

; clear out the miscellaneous flags.
        clr     Capdown         ;Caps is up...
        clr     Ctrldown        ;Control is up
        clr     Capbit          ;Caps light is off.
        setb    CONTROL         ;all reset keys are UP
        setb    LAMIGA
        setb    RAMIGA

;**** sync the controller with the Amiga. clock out
;**** ones until we receive a handshake...
sync:
        mov     tl1,#0          ;set up timer for 143ms
        mov     th1,#0
        mov     r1,#2
        setb    tr1
sync2:
        jb      Adat,sync2      ;wait for handshake
sync3:
        jnb     Adat,sync3      ;wait for end of handshake
        clr     tr1

;**** transmit power up key stream and end key stream.
        mov     a,#0FDh
        acall   actualtransmit
        mov     a,#0FEh
        acall   actualtransmit

;**** sync up the AT and go with it!

ATPowerup:
        mov     a,#0ffh         ;RESET
        acall   SendtoAT
        mov     a,#0f6h         ;DEFAULT
        acall   SendtoAT
        mov     a,#0edh         ;NEXT DATA is FOR LIGHTS
        acall   SendtoAT
        mov     a,#2            ;NUMLOCK ON?
        acall   SendtoAT
        mov     a,#0f4h         ;CLEAR BUFFER
        acall   SendtoAT

;***************************************************
;*  If some pin of P3 are low perform a
;*	Reset after a delay for slow hard drive spin up
;*
;***************************************************

        jnb     ColdBoot,noCold	  ;first boot ?
        clr     ColdBoot

        mov     a,p3
        cjne    a,#255,slowSpinUp   ;any low level on P3
        ljmp    ATstyle

slowSpinUp:
        clr     tr0
        clr     tf0
        cpl     a
        mov     tempo,a
        mov     r1,tempo	;approximatly  (r1) * 72ms
        mov     th0,#0      ;timer 0 will overflow repeatedly
        mov     tl0,#0
        setb    tr0         ; start timer 0
waitReset:
        jnb     tf0,waitReset   ;wait for overflow flag
        clr     tf0             ;clear it again
        djnz    r1,waitReset
        clr     tf0
        clr     tr0             ;stop the timer
        ljmp    resetwarn

noCold:
        ljmp    ATstyle         ;go and parse AT keyboard

;***********************************************
;* ATgetkey
;* ATgetkey
;* ATgetkey
;*
;* ATgetkey looks at the keyboard and waits for a key to be
;* pressed. ATinkey is the actual routine that watched the logic
;* levels of Kdat and Kclk. IF the character's parity is not
;* what it is supposed to be, then the routine will attempt to
;* tell the keyboard to resend.
;*
;* When exiting from this routine, Kclock is pulled low to hold
;* off any more transmissions. You must restore it to 5 volts to
;* receive any more characters later.
;*
;*

ATgetkey:
        mov     r0,#11          ;number of bits
        setb    Kclk
ATwaitC0:
        jb      Kclk,ATwaitC0   ;wait for a clock pulse
        dec     r0              ;decrement clock bit counter
        cjne    r0,#10,ATnstart ;test for startbit
        sjmp    ATwait
ATnstart:
        cjne    r0,#0,ATnstop   ;check for stopbit
ATwaitC1:
        jnb     Kclk,ATwaitC1   ;wait for clock to go high
        clr     Kclk            ;hold off more data
        mov     r0,#20          ;small delay
pause:  djnz    r0,pause
;**** now we check to see if the parity between
;**** Bit register P (which is set if Parity of Acc is odd)
;**** is compared to the received Parity Bit.
        jb      p,parityodd     ;test if parity of DATA is odd
parityeven:
        jnb     ATparity,ATerror
        ret                     ;Okay to return. A=valid
parityodd:
        jb      ATparity,ATerror
        ret                     ;Okay to return. A=valid
ATerror:
        mov     a,#0feh         ;RESEND character
        acall   SendtoAT
        sjmp    ATgetkey        ;now return to caller
ATnstop:
        cjne    r0,#1,ATdatab   ;check for paritybit
        mov     c,Kdat          ;error checking! (AT only)
        mov     ATparity,c
        sjmp    ATwait          ;
ATdatab: 
        mov     c,Kdat          ;get data bit
        rrc     a               ;shift it into accumulator
ATwait: jnb     Kclk,ATwait     ;wait for clock line to go low
        sjmp    ATwaitC0        ;get another bit


;**************************************************
;* AT-STYLE
;*
;*     This waits for a keycode or two from the IBM and then calls
;* the appropriate transmit subroutine. The IBM keyboard sends 
;* out special codes in front of and behind some scancodes. This
;* routine will chop them out before doing a lookup on the
;* code to see what to send to the AMIGA. The scancodes between 
;* the IBM and the AMIGA are of course, not the same!
;*
;**************************************************

ATstyle:
        acall   ATgetkey          ;get one scancode.
        cjne    a,#0e1h,ATnE1
        acall   ATgetkey          ;(should be 14)
        acall   ATgetkey          ;(should be 77)
        acall   ATgetkey          ;(should be E1)
        acall   ATgetkey          ;(should be F0)
        acall   ATgetkey          ;(should be 14)
        acall   ATgetkey          ;(should be F0)
        acall   ATgetkey          ;(should be 77)
        sjmp    ATstyle
;PAUSE was pressed. Just ignore it.
ATnE1:
        mov     dptr,#ATtb1
        cjne    a,#0e0h,ATnE0
        mov     dptr,#ATtb2
        acall   ATgetkey
        cjne    a,#0f0h,ATnE0F0
        acall   ATgetkey
        cjne    a,#12h,ATnEF12
        ljmp    ATstyle         ;(E0F012....ignore it)
ATnEF12:
        cjne    a,#59h,ATup     ;(E0F0mk)
        ljmp    ATstyle         ;(E0F059....ignore it)
ATnE0F0:
        cjne    a,#12h,ATnE012
        ljmp    ATstyle         ;(E012....ignore it)
ATnE012:
        cjne    a,#59h,ATdown   ;(E0mk)
        ljmp    ATstyle         ;(E059....ignore it)
ATnE0:
        cjne    a,#0f0h,ATdown  ;(mk)
        acall   ATgetkey
        sjmp    ATup            ;(F0mk....normal key break)

;**************************************************
;* ATdown and the rest here call a lookup table to change
;* the AT scancodes into AMIGA scancodes. In the "down"
;* routine, the "make" bit is asserted. In the "up" routine
;* it is de-asserted.
;**************************************************
ATdown:
        movc    a,@a+dptr       ;indexed into table
        clr     acc.7           ;clear make/break bit
        acall   transmit        ;transmit it
        ljmp    ATstyle
ATup:
        movc    a,@a+dptr
        setb    acc.7           ;set make/break bit
        acall   transmit        ;transmit it
        ljmp    ATstyle

;**************************************************
;* SendtoAT is the subroutine that sends special codes
;* to the keyboard from the controller. Codes include
;* the command to reset (FF) or the command to change
;* the lights (ED). It is advisable to keep the timing
;* very close to how I have it done in this routine.
;**************************************************

SendtoAT:
        setb    Kclk
        clr     Kdat
        mov     r0,#8
Send4:  jb      Kclk,Send4      ;data bit
        mov     c,acc.0
        mov     Kdat,c
        rr      a 
Send5:  jnb     Kclk,Send5      ;data bit
        dec     r0
        cjne    r0,#0,Send4
        mov     c,p
        cpl     c
Send6:  jb      Kclk,Send6      ;parity bit
        mov     Kdat,c
Send7:  jnb     Kclk,Send7      ;parity bit
Send77: jb      Kclk,Send77     ;stop bit
        setb    Kdat
Send78: jnb     Kclk,Send78     ;stop bit
Send79: jb      Kclk,Send79
Send7a: jnb     Kclk,Send7a
        mov     r0,#8           ;small delay
Send8:  djnz    r0,Send8
        clr     Kclk            ;drive clock low
        mov     r0,#20          ;long delay
Send9:  djnz    r0,Send9
        setb    Kclk
        acall   ATgetkey        ;should check if response isbad.
        ret                     ;who cares if it is? not me!

;**************************************************
;*
;* TRANSMIT first does some checking to take out repeating
;* keys and does the conversion on the Caps Lock Key and
;* then calls Actualtransmit.
;*
;**************************************************

dontrans:                       ;jumps back if key is already
        pop     acc             ;held down.
        ret
transmit:
        cjne    a,Oldchar,transok
        ret
transok:
        cjne    a,#62h,transok2 ;jump if not CapsLock=down
        mov     Oldchar,a
        setb    Capdown         ;set the flags for later
        ret
transok2:                       
        cjne    a,#0e2h,transok3;jump if not CapsLock=up
        mov     a,Oldchar       ;see if Caps was just down
        cjne    a,#62h,transok4 ;if not, then it was a control
XTcap:
        clr     Capdown         ;clear flag
        cpl     Capbit          ;toggle down/up-ness of Caplock
        mov     a,#62h
        mov     c,Capbit
        cpl     c
        mov     acc.7,c
        acall   actualtransmit  ;(Caps to Amiga!)
        mov     a,#0edh         ;set lights on next byte.
        acall   SendtoAT
        mov     a,#2            ;numlock on
        mov     c,Capbit
        mov     acc.2,c
        acall   SendtoAT        ;maybe capslock light
skiplights: 
        ret           
transok4:
        clr     CtrlDown        ;This sends out a Control Up.
        clr     Capdown         ;Caps lock is done functioning as Ctl
        mov     a,#63h          ;Control Key
        setb    acc.7           ;break bit set.
        acall   actualtransmit  ;send to Amiga.
        ret
transok3:
        mov     Oldchar,a
        jnb     Capdown,noControl
        jb      CtrlDown,noControl
        setb    CtrlDown        ;Caps lock is beginning to function
        mov     a,#63h          ;as the Control Key.
        acall   actualtransmit  ;send Control Down to Amiga
        mov     a,Oldchar       ;now send the actual key

noControl:                      ;its not a controlled key
        mov     c,acc.7         ;c=make/break bit
        mov     Make,c          ;will be set if key up
        clr     acc.7           ;test for key only. NO make/break

;************************************
; begin special key test

        jb      switchMap,noRaw ;jump if switchMap
        ljmp    amigaKey

noRaw:
        mov     mKey,#29h
        jb      usFlag,frenchM  ;american or french 'm' ? 
        mov     mKey,#37h
frenchM:
        mov     r3,mKey
        mov     scrollKey,r3    ;prepare the mapping of scrollLock
        jb      switch95,suite  ;jump if switch95 is high
        mov     scrollKey,#18h
suite:

;************************************
; HOME -> control cursor up
;************************************

        cjne    a,#75h,noHome    ;home ?
        jnb     Make,homedown
homeup:
        mov     a,#0cch         ;cursor up break
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#0e3h         ;right control break (cdc 27-5-96))
        acall   actualtransmit
        ret
homedown:
        mov     a,#63h          ;control make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#4ch          ;cursor up make
        acall   actualtransmit
        ret
noHome:

;*************************************
; END -> control cursor down 
;*************************************

        cjne    a,#76h,noEnd  ; end ?
        jnb     Make,enddown
endup:
        mov     a,#0cdh         ;cursor down break
        acall   actualtransmit
        mov     a,#0e3h         ;control break
        acall   Smalldelay
        acall   actualtransmit
        ret
enddown:
        mov     a,#63h          ;control make
        acall   actualtransmit
        acall   Smalldelay      ;cursor down make
        mov     a,#4dh
        acall   actualtransmit
        ret
noEnd:                        

;******************************************
; Page Up -> Rshift cursor up 
;******************************************

        cjne    a,#77h,noPageUp	; pageUp ?
        jnb     Make,pageUpdown
pageUpup:
        mov     a,#0cch         ;cursor up break
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#0e1h         ;Rshift break
        acall   actualtransmit
        ret
pageUpdown:
        mov     a,#61h          ;Rshift make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#04ch         ;cursor up make
        acall   actualtransmit
        ret
noPageUp:

;******************************************
; Page Down -> Rshift cursor down
;******************************************

        cjne    a,#78h,noPageDown  ;PageDow key ?
        jnb     Make,pageDowndown
pageDownup:
        mov     a,#0cdh         ;cursor down break
        acall   actualtransmit
        acall   Smalldelay      
        mov     a,#0e1h			;Rshift break
        acall   actualtransmit
        ret
pageDowndown:
        mov     a,#61h          ;Rshift make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#4dh          ;cursor down make
        acall   actualtransmit
        ret
noPageDown:

;************************************
; F12 -> right Amiga d
;************************************

        cjne    a,#7ah,noF12    ; F12 ?
        jnb     Make,F12down
F12up:
        mov     a,#0a2h         ;'d' break
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#0e7h         ;right Amiga break
        acall   actualtransmit
        ret
F12down:
        mov     a,#67h          ;right Amiga  make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#22h          ;'d' make
        acall   actualtransmit
        ret
noF12:

;************************************
; PrintScreen -> right Amiga /
;************************************

        cjne    a,#7bh,noPscreen    ; printScreen ?
        jnb     Make,pscreendown
pscreenup:
        mov     a,#0dch         ;'/' break
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#0e7h         ;right Amiga break
        acall   actualtransmit
        ret
pscreendown:
        mov     a,#67h          ;right Amiga  make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#5ch          ;'/' make
        acall   actualtransmit
        ret
noPscreen:

;************************************
; ScrollLock -> left Amiga m or o
;************************************

        cjne    a,#7ch,noScroll    ; ScrollLock ?
        jnb     Make,scrolldown
scrollup:
        mov     a,scrollKey         ;key  break
		add		a,#80h
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#0e6h         ;left Amiga break
        acall   actualtransmit
        ret
scrolldown:
        mov     a,#66h          ;left Amiga  make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,scrollKey     ;key  make
        acall   actualtransmit
        ret
noScroll:

;************************************
; F11 -> \ the missing key !!
;************************************

        cjne    a,#79h,noF11	; F11 ?
        jnb     Make,F11down
F11up:
		mov		Oldchar,#8dh	; '\' break
		sjmp	noF11
F11down:
        mov     Oldchar,#0dh    ; '\' make
        ljmp	endSpecial	;
noF11:


amigaKey:
		jnb 	switch95,Keyboard95		; jump if switch95 is low (mean 95 style keyboard)

;******************************************
; Left Control ->  Left Amiga
;******************************************

        cjne    a,#70h,noLctrl  ; left control ?
        jnb     Make,lctrldown
lctrlup:
		mov		Oldchar,#0e6h	; left amiga break
		sjmp	noLctrl
lctrldown:
        mov     Oldchar,#66h    ; left amiga make
		ljmp	endSpecial	;

;******************************************
; Right Control ->  Right Amiga
;******************************************

noLctrl:
        cjne    a,#71h,endSpecial  ;right control key ?
        jnb     Make,rctrldown
rctrlup:
		mov		Oldchar,#0e7h	; right amiga break
		sjmp	endSpecial
rctrldown:
		mov     Oldchar,#67h    ; right amiga make
		ljmp	endSpecial	;


; begin 95 style keyboard special test

Keyboard95:		

;************************************
; windos menu -> Left Amiga m 
;************************************

        cjne    a,#74h,noWinMenu    ; windos menu key ?
        jnb     Make,winMenuDown
winMenuUp:
        mov     a,mKey         ; 'm' break
		add		a,#80h
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#0e6h         ; left Amiga break
        acall   actualtransmit
        ret
winMenuDown:
        mov     a,#66h          ; left Amiga make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,mKey          ; 'm' make
        acall   actualtransmit
        ret
noWinMenu:

;******************************************
; Left Control ->  Control
;******************************************

        cjne    a,#70h,noLctrl95  ; left control ?
        jnb     Make,lctrldown95
lctrlup95:
		mov		Oldchar,#0e3h	; control break
		sjmp	noLctrl95
lctrldown95:
        mov     Oldchar,#63h    ; control make
		sjmp	endSpecial	;
noLctrl95:

;******************************************
; Right Control ->  Control
;******************************************

        cjne    a,#71h,noRctrl95  ;right control ?
        jnb     Make,rctrldown95
rctrlup95:
		mov		Oldchar,#0e3h	; control break
		sjmp	endSpecial
rctrldown95:
		mov     Oldchar,#63h    ; control make
		sjmp	endSpecial	;
noRctrl95:

;******************************************
; Left windows key ->  Left Amiga
;******************************************

        cjne    a,#72h,noLwin  ; left windows key ?
        jnb     Make,lwindown
lwinup:
		mov		Oldchar,#0e6h	; left amiga break
		sjmp	noLwin
lwindown:
        mov     Oldchar,#66h    ; left amiga make
		sjmp	endSpecial	;
noLwin:

;******************************************
; Right windos key ->  Right Amiga
;******************************************

        cjne    a,#73h,endSpecial  	; right windows key ?
        jnb     Make,rwindown
rwinup:
		mov		Oldchar,#0e7h	; right amiga break
		sjmp	endSpecial
rwindown:
		mov     Oldchar,#67h    ; right amiga make
		sjmp	endSpecial


; ************************
Smalldelay:
        mov     th0,#0
        mov     tl0,#0
        clr     tf0
        setb    tr0
small1: jnb     tf0,small1
        clr     tf0
        clr     tr0
        ret
; ************************

endSpecial:
        mov     a,Oldchar
        acall   actualtransmit  ;transmit the keycode
        mov     a,Oldchar       ;get back same keycode, in A.
        mov     c,acc.7         ;put make/break bit in Make
        mov     Make,c
        clr     acc.7           ;start testing for reset keys

        cjne    a,#63h,nrset1   ;held down
        mov     c,Make
        mov     CONTROL,c
        sjmp    trset
nrset1: cjne    a,#66h,nrset2
        mov     c,Make
        mov     LAMIGA,c
        sjmp    trset
nrset2: cjne    a,#67h,trset
        mov     c,Make
        mov     RAMIGA,c
trset:  jnb     CONTROL,maybefree       ;if bit set, this key is up
        jb      CtrlDown,maybefree      ;if bit set, this key is down
        sjmp    free
maybefree:
        jb      LAMIGA,free     ;ditto
        jb      RAMIGA,free     ;ditto
        sjmp    resetwarn       ;OOPS! They are all down!
free:   ret


resetwarn:
        clr     tf0             
        mov     a,78h
        mov     r1,#2           ;set up timer 0 watchdog
        mov     tl0,#0
        mov     th0,#0
        cpl     a               ;invert, don't know why.
        mov     r0,#8
wr1:
        rl      a
        mov     c,acc.7
        mov     Adat,c
        mov     b,#8
wr2:
        djnz    b,wr2             ; transmit it.
        clr     Aclk
        mov     b,#8
wr3:
        djnz    b,wr3
        setb    Aclk
        mov     b,#10
wr4:
        djnz    b,wr4
        djnz    r0,wr1
        setb    Adat
        setb    tr0             ;start watchdog
wr5:
        jnb     Adat,caught1
        jnb     tf0,wr5
        clr     tf0
        djnz    r1,wr5
        sjmp    Hardreset
caught1:
        clr     tr0
        clr     tf0
        mov     a,78h
        mov     r1,#4
        mov     tl0,#0
        mov     th0,#0
        cpl     a    
        mov     r0,#8
wr11:
        rl      a
        mov     c,acc.7
        mov     Adat,c
        mov     b,#8
wr22:
        djnz    b,wr22   
        clr     Aclk
        mov     b,#8
wr33:
        djnz    b,wr33
        setb    Aclk
        mov     b,#10
wr44:
        djnz    b,wr44
        djnz    r0,wr11
        setb    Adat
        setb    tr0             ;start watchdog
wr55:
        jnb     Adat,caught2
        jnb     tf0,wr55
        clr     tf0
        djnz    r1,wr55
        sjmp    Hardreset
caught2:
hold:   jnb     Adat,hold
Hardreset:
        clr     tr0
        clr     tf0
        clr     Areset
        clr     Aclk            ;clear both lines
        mov     r1,#15          ;clock should go low for over 500ms
        mov     th0,#0          ;timer 1 will overflow repeatedly
        mov     tl0,#0
        setb    tr0
hsloop:
        jnb     tf0,hsloop      ;wait for overflow flag
        clr     tf0             ;clear it again
        djnz    r1,hsloop
        clr     tf0
        clr     tr0             ;stop the timer
        ljmp    start

;**************************************************
;*
;* ActualTransmit sends the character out to the Amiga and waits
;* for an acknowledge handshake. If it does not receive one in
;* 143 ms, then it clocks out 1's on the data line until it
;* receives the acknowledge. If the Amiga is not connected up,
;* then it will hang here. The handshake is that the AMIGA
;* drives the clock line low.
;*
;*      The loops with register B are for timing delays.
;* There should be about 20usec between when the Data line is 
;* set, the Clock line is driven low, and the Clock line
;* is driven high.
;*
;**************************************************

actualtransmit:
        mov     Amigachar,a     ;set the character to transmit

        mov     r0,#05          ;do a small delay
dly:
        mov     b,#0
delay:  djnz    b,delay
        djnz    r0,dly

actual2:
        mov     a,Amigachar     ;restore it
        clr     Charbad         ;character is not bad yet
        mov     r1,#2           ;set up timer 0 watchdog
        mov     tl1,#0
        mov     th1,#0
        cpl     a               ;invert, don't know why.
        mov     r0,#8
f:      rl      a
        mov     c,acc.7
        mov     Adat,c
        mov     b,#8
g:      djnz    b,g             ; transmit it.
        clr     Aclk
        mov     b,#8
h:      djnz    b,h
        setb    Aclk
        mov     b,#10
i:      djnz    b,i
        djnz    r0,f
        setb    Adat
        setb    tr1             ;start watchdog
waitshake:
        jb      Adat,waitshake
        clr     tr1             ;stop watchdog
gotit:  jnb     Adat,gotit
        ret

timer1int:
        djnz    r1,t3           ;we wait for 143 ms.
        mov     r1,#2           
        setb    Charbad         ;flag to resend the character
        clr     Adat            ;1 on the data line
        mov     b,#8
tt1:    djnz    b,tt1           ;wait for it
        clr     Aclk            ;clock asserted
        mov     b,#8            ;sync up the controller to the
tt2:    djnz    b,tt2           ;amiga
        setb    Aclk
        mov     b,#10
tt3:    djnz    b,tt3
        setb    Adat
t3:     reti                    ;return and send again.

ATtb1: 
        .db     0               
        .db     58h             ;F9
        .db     0               
        .db     54h             ;F5
        .db     52h             ;F3
        .db     50h             ;F1
        .db     51h             ;F2
        .db     7ah             ;F12= raw 7a (charles)
        .db     0
        .db     59h             ;F10
        .db     57h             ;F8
        .db     55h             ;F6
        .db     53h             ;F4
        .db     42h             ;TAB
        .db     00h             ;~
        .db     0

        .db     0
        .db     64h             ;Left ALT
        .db     60h             ;Left SHIFT
        .db     0
        .db     70h             ;Left Ctrl = raw 70
        .db     10h             ;Q
        .db     01h             ;1
        .db     0
        .db     0
        .db     0
        .db     31h             ;Z
        .db     21h             ;S
        .db     20h             ;A
        .db     11h             ;W
        .db     02h             ;2
        .db     0

        .db     0
        .db     33h             ;C
        .db     32h             ;X
        .db     22h             ;D
        .db     12h             ;E
        .db     04h             ;4
        .db     03h             ;3
        .db     0
        .db     0
        .db     40h             ;SPACE
        .db     34h             ;V
        .db     23h             ;F
        .db     14h             ;T
        .db     13h             ;R
        .db     05h             ;5
        .db     0

        .db     0
        .db     36h             ;N
        .db     35h             ;B
        .db     25h             ;H
        .db     24h             ;G
        .db     15h             ;Y
        .db     06h             ;6
        .db     0
        .db     0
        .db     0
        .db     37h             ;M
        .db     26h             ;J
        .db     16h             ;U
        .db     07h             ;7
        .db     08h             ;8
        .db     0

        .db     0
        .db     38h             ;<
        .db     27h             ;K
        .db     17h             ;I
        .db     18h             ;O
        .db     0Ah             ;0
        .db     09h             ;9
        .db     0
        .db     0
        .db     39h             ;>
        .db     3ah             ;/
        .db     28h             ;L
        .db     29h             ; ';'
        .db     19h             ;P
        .db     0bh             ;-
        .db     0

        .db     0
        .db     0
        .db     2ah             ;'
        .db     0
        .db     1ah             ;[
        .db     0ch             ;=
        .db     0
        .db     0
        .db     62h             ;CAPS LOCK?
        .db     61h             ;Right SHIFT
        .db     44h             ;RETURN
        .db     1bh             ;]
        .db     0
        .db     2bh             ; µ ( put 2b instead d, Charles)
        .db     0
        .db     0
		.db		0
		.db		30h				; < (add by Charles Da Costa)

        .rs     4
        .db     41h             ;Back SPACE
        .db     0
        .db     0
        .db     1dh             ;1 keypad
        .db     0
        .db     2dh             ;4 keypad
        .db     3dh             ;7 keypad
        .db     0
        .db     0
        .db     0

        .db     0fh             ;0 keypad
        .db     3ch             ;dot keypad
        .db     1eh             ;2 keypad
        .db     2eh             ;5 keypad
        .db     2fh             ;6 keypad
        .db     3eh             ;8 keypad
        .db     45h             ;ESCAPE!
        .db     5ah             ;Number Lock=( (Charles)
        .db     79h             ;F11 = raw 79  (Charles)
        .db     5eh             ;+ keypad
        .db     1fh             ;3 keypad
        .db     4ah             ;- keypad
        .db     5dh             ;* keypad
        .db     3fh             ;9 keypad
        .db     7ch             ;scroll Lock raw 7c (Charles)
        .db     0
ATtb2:
        .rs     3
        .db     56h             ;F7
        .db     7bh             ;print screen raw 7b (charles)
        .rs     11
;10
        .db     0
        .db     65h             ;Right ALT
        .db     0
        .db     0
        .db     71h             ;Right CTL = raw 71 (charles)
		.rs		10
		.db		72h				;win95g = raw 72 (charles)
;20
        .rs     7
		.db		73h				;win95d = raw 73 (charles)
		.rs		7
		.db		74h				;menu95 = raw 74 (charles)

;30        
        .rs     10h

        .rs     10
        .db     5ch             ;/key, supposedly
        .rs     5

        .rs     10
        .db     43h             ;Numeric Enter
        .rs     5

        .rs     9
        .db     76h             ;End=control down (Charles 27-5-96)
        .db     0
        .db     4fh             ;Cursor Left
        .db     75h             ;Home=control up (Charles 27-5-96)
        .db     0
        .db     0
        .db     63h             ;MACRO key=control

        .db     5fh             ;Insert=help (Charles 27-5-96)
        .db     46h             ;Delete
        .db     4dh             ;Cursor Down
        .db     0
        .db     4eh             ;Cursor Right
        .db     4ch             ;Cursor Up
        .rs     4
        .db     78h             ;Page Down=shift down (Charles 27-5-96)
        .db     0
        .db     7bh             ;print screen = raw 7b
        .db     77h             ;Page up=shift up (Charles 27-5-96)
        .db     40h             ;Break=Space?
        .db     0

        .end    0
