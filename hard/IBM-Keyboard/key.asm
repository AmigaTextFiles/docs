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
        .equ    Kswitch,p1.7

        .org    0000h
init:   ljmp    start
        .org    0003h
        ljmp    resetint
        .org    001bh
        ljmp    timer1int

;**************************************************
;*
;*
;* Equates Descriptions:
;* 
;*      Aclk is the line to the Amiga keyboard clock in. (P1.3)
;*      Adat is the line to the Amiga keyboard data in. (P1.4)
;*      Areset is the Amiga Reset line (P1.5) (for the A500)
;*      Kclk is the line to the Keyboard clock out (P1.0)
;*      Kdat is the line to the Keyboard data out (P1.1)
;*      Kstyle is bit defining whether or not the keyboard
;*        is AT or XT. if AT, Kstyle=1
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
        .equ    XT7bit,4ah
        .equ    Kstyle,4bh

        ;byte memory locations:

        .equ    Charbad,50h
        .equ    Oldchar,51h
        .equ    Amigachar,52h

        .org    0200h

start:  mov     tmod,#11h       ;two 16 bit timers
        mov     tcon,#05h	;edge triggered interrupt.
        mov     ie,#00h         ;clear all interrupts
        setb    ea
        setb    et1             ;enable timer 1
        setb    ex0             ;enable external 0
        setb    int0            ;make sure it's high
        setb    pt0		;timer 0 has high priority
        mov     sp,#30h         ;stack somewhere safe.

; set the ports for input
        mov     p1,#255         ;set port1 for read
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
        setb     tr1
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

;**** test for XT keyboard, if Kswitch is low, automatically
;**** jump to XT mode.
;**** otherwise, test to see if Kdat is low and stays there.
;**** If so, it's in XT mode.                                

        jnb     Kswitch,XTPowerup 
        jb      Kdat,ATPowerup
        mov     th0,#0
        mov     tl0,#0
        clr     tf0
        setb    tr0
XTtest: jb      tf0,XTPowerup   ;timer ran out. XT mode.
        jnb     Kdat,XTtest     ;data is low, but for how long?
        clr     tr0
        clr     tf0
        sjmp    ATPowerup
XTPowerup:
        clr     Kstyle          ;XT flag.
        clr     tf0
        clr     Kclk            ;Clock low=Reset for the XT.
XTreset:
        jnb     tf0,XTreset
        setb    Kclk
        clr     tr0
        clr     tf0
ll:     acall   XTgetkey        ;(Should be AA)
        ljmp    XTstyle

;**** sync up the AT and go with it!

ATPowerup:
        setb    Kstyle
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

XTgetkey:
        setb    Kdat            ;let data flow!
        mov     r0,#8
XTw1:   jb      Kclk,XTw1       ;start bit1
XTw2:   jnb     Kclk,XTw2       ;start bit1
XTw3:   jb      Kclk,XTw3       ;start bit2
XTw4:   jnb     Kclk,XTw4       ;start bit2
XTw5:   jb      Kclk,XTw5       ;data bit
        mov     c,Kdat
        rrc     a
XTw6:   jnb     Kclk,XTw6       ;data bit
        djnz    r0,XTw5
        clr     Kdat            ;hold off data
        ret

XTstyle:
        acall   XTgetkey
        cjne    a,#0e1h,XTnE1
        acall   XTgetkey        ;(should be 1d)
        acall   XTgetkey        ;(should be 45)
        acall   XTgetkey        ;(should be e1)
        acall   XTgetkey        ;(should be 9d)
        acall   XTgetkey        ;(should be c5)
        sjmp    XTstyle
XTnE1:
        cjne    a,#0e0h,XTnE0
        acall   XTgetkey
        cjne    a,#0aah,XTnAA
        sjmp    XTstyle
XTnAA:
        cjne    a,#2ah,XTn2A
        sjmp    XTstyle
XTn2A:
        cjne    a,#0b6h,XTnB6
        sjmp    XTstyle
XTnB6:
        cjne    a,#36h,XTn36
        sjmp    XTstyle
XTn36:
        mov     dptr,#XTtb2
XTlookup:
        mov     c,acc.7         ;(1=break)
        mov     XT7bit,c
        clr     acc.7
        movc    a,@a+dptr
        mov     c,XT7bit
        mov     acc.7,c
        acall   transmit
        ljmp    XTstyle
XTnE0:
        mov     dptr,#XTtb1
        sjmp    XTlookup

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
        jnb     Kstyle,XTcap    ;if XT, skip control feature.
        cjne    a,#62h,transok4 ;if not, then it was a control
XTcap:
        clr     Capdown         ;clear flag
        cpl     Capbit          ;toggle down/up-ness of Caplock
        mov     a,#62h
        mov     c,Capbit
        cpl     c
        mov     acc.7,c
        acall   actualtransmit  ;(Caps to Amiga!)
        jnb     Kstyle,skiplights ;(don't do lights if XT)
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
        jnb     Kstyle,noControl
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
        cjne    a,#0eh,noMup    ;special key mouse up
        jnb     Make,kmupdown
kmupup:
        mov     a,#0cch         ;cursor up break
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#0e7h         ;right amiga break
        acall   actualtransmit
        ret
kmupdown:
        mov     a,#67h          ;amiga make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#4ch          ;cursor up make
        acall   actualtransmit
        ret
noMup:
        cjne    a,#1ch,noMdown  ;special key mouse down
        jnb     Make,kmdowndown
kmdownup:
        mov     a,#0cdh         ;cursor down break
        acall   actualtransmit
        mov     a,#0e7h         ;amiga break
        acall   Smalldelay
        acall   actualtransmit
        ret
kmdowndown:
        mov     a,#67h          ;amiga make
        acall   actualtransmit
        acall   Smalldelay      ;cursor down make
        mov     a,#4dh
        acall   actualtransmit
        ret
noMdown:
        cjne    a,#2ch,noMleft  ;special key mouse left
        jnb     Make,kmleftdown
kmleftup:
        mov     a,#0cfh         ;cursor left break
        acall   actualtransmit
        acall   Smalldelay      ;amiga break
        mov     a,#0e7h
        acall   actualtransmit
        ret
kmleftdown:
        mov     a,#67h          ;amiga make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#4fh          ;cursor left make
        acall   actualtransmit
        ret
noMleft:                        ;special key mouse right
        cjne    a,#47h,notspecial
        jnb     Make,kmrhtdown
kmrhtup:
        mov     a,#0ceh         ;cursor right break
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#0e7h         ;amiga break
        acall   actualtransmit
        ret
kmrhtdown:
        mov     a,#67h          ;amiga make
        acall   actualtransmit
        acall   Smalldelay
        mov     a,#04eh         ;cursor right make
        acall   actualtransmit
        ret
Smalldelay:
        mov     th0,#0
        mov     tl0,#0
        clr     tf0
        setb    tr0
small1: jnb     tf0,small1
        clr     tf0
        clr     tr0
        ret
notspecial:
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
dummy:
        reti
resetint:
        acall   dummy
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
        clr     Aclk            ;clear both lines for A500/A1000
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
        .db     5bh             ;F12=right parenthesis
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
        .db     66h             ;Left Ctrl=Left AMIGA
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
        .db     0dh             ;\
        .db     0
        .db     0

        .rs     6
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
        .db     63h             ;Number Lock=CTRL
        .db     5ah             ;F11=( keypad
        .db     5eh             ;+ keypad
        .db     1fh             ;3 keypad
        .db     4ah             ;- keypad
        .db     5dh             ;* keypad
        .db     3fh             ;9 keypad
        .db     67h             ;scroll Lock=Right AMIGA
        .db     0
ATtb2:
        .rs     3
        .db     56h             ;F7
        .db     66h             ;print screen=Left Amiga
        .rs     11

        .db     0
        .db     65h             ;Right ALT
        .db     0
        .db     0
        .db     67h             ;Right CTL=RIGHT AMIGA
        .rs     11

        .rs     10h
        
        .rs     10h

        .rs     10
        .db     5ch             ;/key, supposedly
        .rs     5

        .rs     10
        .db     43h             ;Numeric Enter
        .rs     5

        .rs     9
        .db     1ch             ;End=Mouse down
        .db     0
        .db     4fh             ;Cursor Left
        .db     0eh             ;Home=Mouse up
        .db     0
        .db     0
        .db     63h             ;MACRO key=control

        .db     2ch             ;Insert=Mouse Left
        .db     46h             ;Delete
        .db     4dh             ;Cursor Down
        .db     0
        .db     4eh             ;Cursor Right
        .db     4ch             ;Cursor Up
        .rs     4
        .db     5fh             ;Page Down=Help
        .db     0
        .db     66h             ;print screen=LEFT AMIGA
        .db     47h             ;Page up=mouse right
        .db     40h             ;Break=Space?
        .db     0
XTtb1:
        .db     0
        .db     45h             ;esc
        .db     01h             ;1
        .db     02h             ;2
        .db     03h             ;3
        .db     04h             ;4
        .db     05h             ;5
        .db     06h             ;6
        .db     07h             ;7
        .db     08h             ;8
        .db     09h             ;9
        .db     0ah             ;0
        .db     0bh             ;-
        .db     0ch             ;=
        .db     41h             ;Backspace
        .db     42h             ;Tab

        .db     10h             ;Q
        .db     11h             ;W
        .db     12h             ;E
        .db     13h             ;R
        .db     14h             ;T
        .db     15h             ;Y
        .db     16h             ;U
        .db     17h             ;I
        .db     18h             ;O
        .db     19h             ;P
        .db     1Ah             ;[
        .db     1Bh             ;]
        .db     44h             ;ENTER
        .db     66h             ;L.CTL=LEFT AMIGA
        .db     20h             ;A
        .db     21h             ;S

        .db     22h             ;D
        .db     23h             ;F
        .db     24h             ;G
        .db     25h             ;H
        .db     26h             ;J
        .db     27h             ;K
        .db     28h             ;L
        .db     29h             ;';'
        .db     2Ah             ;'
        .db     00h             ;~
        .db     60h             ;Left Shift
        .db     0dh             ;\
        .db     31h             ;Z
        .db     32h             ;X
        .db     33h             ;C
        .db     34h             ;V

        .db     35h             ;B
        .db     36h             ;N
        .db     37h             ;M
        .db     38h             ;<
        .db     39h             ;>
        .db     3Ah             ;/
        .db     61h             ;Right Shift
        .db     5dh             ;Numeric *
        .db     64h             ;Left Alt
        .db     40h             ;space
        .db     62h             ;CapsLock
        .db     50h             ;F1
        .db     51h             ;F2
        .db     52h             ;F3
        .db     53h             ;F4
        .db     54h             ;F5

        .db     55h             ;F6
        .db     56h             ;F7
        .db     57h             ;F8
        .db     58h             ;F9
        .db     59h             ;F10
        .db     63h             ;Number Lock=Control
        .db     67h             ;Scroll Lock=Right Amiga
        .db     3dh             ;Numeric 7
        .db     3eh             ;* 8
        .db     3fh             ;* 9
        .db     4ah             ;* -
        .db     2dh             ;* 4
        .db     2eh             ;* 5
        .db     2fh             ;* 6
        .db     5eh             ;* +
        .db     1dh             ;* 1

        .db     1eh             ;* 2
        .db     1fh             ;* 3
        .db     0fh             ;* 0
        .db     3ch             ;* .
        .db     63h             ;print screen=CONTROL
        .db     0
        .db     0
        .db     5ah             ;F11=Numeric (
        .db     5bh             ;F12=Numeric )
        .rs     7

        .rs     10h

        .rs     10h
XTtb2:
        .rs     10h

        .rs     12
        .db     43h             ;Numeric Enter
        .db     67h             ;Right Control=RIGHT AMIGA
        .rs     2

        .rs     10h
        
        .rs     5
        .db     5ch             ;Numeric /key
        .db     0
        .db     66h             ;Print Screeen=Left Amiga
        .db     65h             ;Right Alt
        .rs     7

        .rs     6
        .db     5fh             ;BREAK=HELP!
        .db     0eh             ;Home=MOUSE UP
        .db     4ch             ;cursor up
        .db     47h             ;pageup=mouse right
        .db     0
        .db     4fh             ;cursor left
        .db     0
        .db     4eh             ;cursor right
        .db     0
        .db     1ch             ;End=mouse down

        .db     4dh             ;cursor down
        .db     5fh             ;page down=HELP!
        .db     2ch             ;insert=mouse left
        .db     46h             ;delete
        .rs     12
       
        .rs     15
        .db     63h             ;Macro=control

        .rs     10h

        .end    0

