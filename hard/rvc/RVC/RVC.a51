;The Remote Volume Control (RVC). Code voor 8051-achtige controllers.
;_____________________________________________________________________________
;            |                                                          |
; 25-05-1994 | Eerste schreden van de code.                             | V1.0
; 01-06-1994 | Veranderen startup-output. Verkorten code.               | V1.1
; 03-03-1995 | Idle mode buiten RS232. Bewaren laatste volume.          | V1.2
; 06-03-1995 | Inbouwen buffer voor actuele nivo's.                     | V1.2
; 07-03-1995 | Verzenden van actueel nivo in Serial interrupt.          | V1.2
; 08-03-1995 | Actueel nivo nu buiten interrupt. foutje uit nivo-send.  | V1.2
; 16-04-1995 | LED wordt nu via de controller bestuurd (Actief LAAG)    | V1.3

;Mogelijke RVC commandos:
;-----------------------------------------------------------------------------

;Instellen van nivo:
;========================================
;INPUT:         <esc>, '1', rechts, links
;OUTPUT:        '.'

;Opvragen van actueel nivo:
;========================================
;INPUT:         <esc>, '2'
;OUTPUT:        '>', rechts, links


;-----------------------------------------------------------------------------
; Data declaratie.

DSEG            AT      30h
Vol_Rechts:     DS      1               ;Nivo voor rechts.
Vol_Links:      DS      1               ;Nivo voor links.
STACKBASE       EQU     $               ;Hier begint de stack.

;-----------------------------------------------------------------------------
; Adressen en instellingen.

BaudRateDiv     EQU     6
DEFVOL          EQU     0C0h            ;Default nivo links en rechts.
VOLOKAY         EQU     '.'             ;Output op esc-1
VOLCODE         EQU     '>'             ;Beginkarakter volume output (esc-2).

NotMute         BIT     P1.7            ;Active low mute (CS3310).
SClock          BIT     P1.5            ;Serial clock (CS3310).
SData           BIT     P1.4            ;Serial data in (CS3310).
CS              BIT     P1.2            ;Chip enable (CS3310).
PowerLED        BIT     P1.3            ;LED. Actief LAAG.

Heb_Esc         BIT     20h.1           ;Onthouden of escape al binnen.
Heb_Vol         BIT     20h.2           ;Onthouden of juiste code al binnen.
Heb_Rechts      BIT     20h.3           ;Onthouden of rechter byte al binnen.
Vol_Send        BIT     20h.4           ;Verzend de volume code.

;-----------------------------------------------------------------------------
; Verschillende sprong vectoren.

CSEG AT 0000h
                JMP     START
CSEG AT 0023h
                PUSH    PSW
                JMP     SERVICE_SERIO

;============================================================================
; De main loop. Na initialisatie doet 'ie niks meer.

CSEG AT 0100h

START:          CLR     NotMute                 ;Potmeter geheel dicht.
                CLR     PowerLED                ;Doe de LED aan.
                MOV     SP,#STACKBASE           ;Set de stacks basis.
                ACALL   INIT                    ;Initializeer wat (RS232).
                ACALL   SEND_STRING             ;Zend een string via RS232.
                SETB    CS                      ;Disable mbv chipselect.
                SETB    NotMute                 ;Potmeter weer open.

;Reset de CS3310 naar de waarde van 0dB.

                CLR     CS                      ;Enable de chip.
                MOV     A,#DEFVOL               ;Zet rechtse nivo default.
                MOV     Vol_Rechts,A            ;Bewaar actueel nivo.
                CALL    Send_Pot                ;Zend het rechtse byte.
                MOV     A,#DEFVOL               ;Zet linkse nivo default.
                MOV     Vol_Links,A             ;Bewaar actueel nivo.
                CALL    Send_Pot                ;Zend het linkse byte.
                SETB    CS                      ;Disable de chip weer.

;Zend als nodig de actuele levels over RS232.

LOOP:           JNB     Vol_Send,LOOP           ;Verzenden van levels?
                CLR     Vol_Send                ;Gehoord. Vlag kan weer laag.
		MOV	A,#VOLCODE		;Begin met volume code.
		CALL	Send_S			;Wegzenden die code.
		MOV	A,Vol_Rechts		;Daarna het rechtse nivo.
		CALL	Send_S			;Wegzenden die code.
		MOV	A,Vol_Links		;Afsluitend het linkse nivo.
		CALL	Send_S			;Wegzenden die code.

;Klaar? Naar idle schakelen.

;               MOV     PCON,#01h               ;Breng controller in idle mode.
                NOP                             ;Gebruik wat tijd.
                NOP                             ;idem.
                NOP                             ;idem.
                NOP                             ;Een meer dan recommendation.
                JMP     LOOP                    ;Schop weer naar idle.


;============================================================================
; Initialiseer de hard- en software.

INIT:           MOV     PCON,#10000000b         ;SMOD = 1.
                MOV     TMOD,#00100000b         ;T1 -> auto-reload.
                MOV     TH1,#256-BaudRateDiv    ;BaudRate initializatie.
                MOV     TL1,#256-BaudRateDiv    ;Idem.
                SETB    TCON.6                  ;Baudrate generator aan.
                MOV     SCON,#01010010b         ;MODE = 1. REN=1, TI=1, RI=0.
                CLR     Heb_Rechts              ;Geen eerste byte binnen.
                CLR     Heb_Esc                 ;Nog GEEN escape ontvangen.
                CLR     Vol_Send                ;Zend nog geen levels.
                MOV     IE,#10010000b           ;RS232 interrupt aan.
                RET


;============================================================================
; Verzend identificatie string via RS232.

SEND_STRING:    MOV     DPTR,#IString           ;APTR Te zenden string in DPTR.
STR_Loop:       CLR     A                       ;Wis de accu.
                MOVC    A,@A+DPTR               ;Letter -> A(=0) + DPTR naar A.
                JZ      STR_Einde               ;Byte nul? Einde string!
                INC     DPTR                    ;APTR naar volgende letter.
                ACALL   Send_S                  ;Verzend letter in A.
                JMP     STR_LOOP                ;Herhaal voor volgende letter.
STR_Einde:      RET                             ;Einde string = Einde routine.


;-----------------------------------------------------------------------------
; Verzenden van een karakter via RS232.

Send_S:         JNB     TI,Send_S               ;Interrupt still busy? Wait!
                CLR     TI                      ;Interrupt will be busy.
                MOV     SBUF,A                  ;Write char to RS232.
                RET                             ;End of Send_S.


;=============================================================================
; De serial-interrupt handler voor RS232

SERVICE_SERIO:  PUSH    ACC                     ;Bewaar de accumulator.
                JB      RI,SIO_Receive          ;Wordt er dan ontvangen?
SIO_END:        POP     ACC                     ;Haal de accu weer op.
                POP     PSW                     ;Stond ook nog op stack.
                RETI                            ;Einde van de interrupt.


;-----------------------------------------------------------------------------
; Karakter is ontvangen. Welk?

SIO_Receive:    CPL     PowerLED                ;Switch LED status.
                MOV     A,SBUF                  ;Lees ontvangen karakter in.
	        CLR     RI                      ;Karakter is ontvangen.
                JB      Heb_Rechts,SIO_Volume   ;Alles binnen? Zenden!
                JB      Heb_Vol,SIO_RByte       ;Al een volume-code binnen?
                JB      Heb_Esc,SIO_Code        ;De escape al binnen?
                CJNE    A,#1Bh,SIO_END          ;Geen escape? Onbelangrijk!
                SETB    Heb_Esc                 ;Onthoud: Escape al ontvangen.
                JMP     SIO_END                 ;Einde van de interrupt.

SIO_Code:       CJNE    A,#'2',SIO_Esc1         ;Controleer of anders Esc1.
                SETB    Vol_Send                ;Levels mogen verzonden worden.
                JMP     SIO_STOP                ;Klaar!
SIO_Esc1:       CJNE    A,#'1',SIO_STOP         ;Geen nieuw volume? Afgelopen!
                SETB    Heb_Vol                 ;Onthoud: juiste code binnen.
                JMP     SIO_END                 ;Einde van de interrupt.

SIO_RByte:      MOV     Vol_Rechts,A            ;Bewaar de byte.
                SETB    Heb_Rechts              ;Onthoud: Rechterbyte ontvangen.
                JMP     SIO_END                 ;Einde van de interrupt.


;-----------------------------------------------------------------------------

SIO_Volume:     MOV     Vol_Links,A             ;Bewaar waarde voor links.
                PUSH    ACC                     ;Bewaar de laatste byte.
                CLR     CS                      ;Enable de chip.
                MOV     A,Vol_Rechts            ;Het rechtse byte naar de accu.
                CALL    Send_Pot                ;Zend het rechtse byte.
                POP     ACC                     ;haal de linkse byte van stack.
                CALL    Send_Pot                ;Zend het linkse byte.
                SETB    CS                      ;Disable de chip weer.
                MOV     A,#VOLOKAY              ;Output naar accu.
                CALL    Send_S                  ;Send accu via RS232.
                JMP     SIO_STOP                ;Alles is geregeld. Stop!


;-----------------------------------------------------------------------------

SIO_STOP:       CLR     Heb_Esc                 ;Geen escape meer ontvangen.
                CLR     Heb_Vol                 ;Geen volume data verwacht.
                CLR     Heb_Rechts              ;Geen eerste byte binnen.
                CLR     PowerLED                ;En de LED gaat aan...
                JMP     SIO_END                 ;Einde interrupt.


;-----------------------------------------------------------------------------

Send_Pot:       MOV     r7,#8                   ;Reset teller (aantal bits).
                CLR     SClock                  ;Klok omlaag.
SP_Loop:        RLC     A                       ;Rol rechts over de carry.
                JC      SP_One                  ;Carry gezet?
                CLR     SData                   ;Nee? Zend een nul(0).
                SJMP    SP_ClockIt              ;Verzorg de clock.
SP_One:         SETB    SData                   ;Ja? Zend een een (1).
SP_ClockIt:     SETB    SClock                  ;Klok omhoog.
                CLR     SClock                  ;Klok omlaag.
                DJNZ    r7,SP_Loop              ;Loop als er nog bits zijn.
                RET                             ;Klaar met zenden.


;============================================================================
; De identificatie string.

IString:        DB      0dh,0ah
                DB      'ETO Remote Volume Control V1.3 (15-04-95) by E. Th. van den Oosterkamp.',0dh,0ah
                DB      0dh,0ah,0dh,0ah
                DB      'COMMANDS - Set levels: "1Bh, 31h, <rightlevel>, <leftlevel>".',0dh,0ah
                DB      '               result: "',VOLOKAY,'"',0dh,0ah,0dh,0ah
                DB      '         - Get levels: "1Bh, 32h".',0dh,0ah
                DB      '               result: "',VOLCODE,' ,<rightlevel>, <leftlevel>".',0dh,0ah
                DB      0dh,0ah,0dh,0ah
                DB      'LEVELS   : 01h -> -95.5 dB',0dh,0ah
                DB      '         : 02h -> -95.0 dB',0dh,0ah
                DB      '         : C0h ->   0.0 dB',0dh,0ah
                DB      '         : FFh -> +31.5 dB',0dh,0ah
                DB      '         : 00h -> Mute',0dh,0ah,0dh,0ah
                DB      0


;============================================================================
                END

