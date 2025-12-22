'***************************************************************************
'*                                                                         *
'*                                LCD.bas                                  *
'*                                                                         *
'*                       © 1996 Andreas Heinrich                           *
'*                                                                         *
'*             Dieses Programm steuert ein LCD-Display an und              *
'*          gibt die ASCII-Codes von 0-255 an das Display weiter.          *
'*                                                                         *
'***************************************************************************
'  A=Adresse
'  N=Wert
'  U=1 = Neue Zeile
'  T=Positionszähler
'  U-Prog. Daten = Datenwort wird über Port 3 an das LCD-Display geschickt
'  U-Prog. Kommando = Steuerwort wird gesendet
'
'
'**************************** Init für In_Out_Board ************************
'
GOSUB INIT
'
'********************** Init Kommandos für LCD - Display *******************
'
N=h38 : REM             Display initialisieren
GOSUB KOMMANDO
N=h1 : REM              Anzeige löschen
GOSUB KOMMANDO
t1=TIMER
WHILE TIMER<=t1+.02 
WEND : REM              Muß hier 1/50 Sekunde warten
'
N=hE : REM              Schreibmarke einschalten
GOSUB KOMMANDO
N=h6 : REM              Cursor an
GOSUB KOMMANDO
'
'**************************** Demo für die Ausgabe **************************
'
'      ( Ab hier können dann eigene Programme eingefügt werden.)
'
'          Gibt die Werte von 0 bis 255 auf die Anzeige
'          Nicht jedem Wert ist auch ein Zeichen zugeordnet
NOCH_EINMAL:
T=1
FOR B=0 TO 255
LOCATE 2,1 : PRINT B, : PRINT CHR$(B) 
 N=B
  GOSUB DATEN
t1=TIMER
WHILE TIMER<=t1+.20
WEND : REM   Hier ist kleine Warteschleife, damit man den Cursor sieht.
T=T+1
'*************** Diese Routine löscht nach 1 Sekunde das Display ************
'
 If T=17
   U=1
    N=hC0
  GOSUB KOMMANDO
END IF
'
IF T=33 AND U=1
  U=0
    T=1
      t1=TIMER
      WHILE TIMER<=t1+1
      WEND       
     N=1
   GOSUB KOMMANDO
END IF
'
'****************************************************************************
'
NEXT B
'
'********************************* Ende *************************************
'
PRINT
PRINT "Ende"
END
'
'******************************* Unterprogramme *****************************
'
SCHREIBEN:
'
POKE 12570624&,248+A : REM  Adresse A selektieren
POKE 12575489&,255 : REM    Port als Ausgang schalten
POKE 12574977&,N : REM      Wert N schreiben
POKE 12570624&,255 : REM    Ready LED einschalten
'
RETURN
'
INIT:
'
'******************** Nach dem Einschalten aufrufen ***********************
'
POKE 12571136&,199 : REM    Busy,P-aus und SEL=Bitmuster Ausgabe
POKE 12570624&,255 : REM    Adresse 7 selektieren (Ready LED ein)
POKE 12575489&,0 : REM      Port als Eingang schalten
'
'**************************************************************************
RETURN
'
KOMMANDO:
'
A=3 : REM Steuerwort an Port 3 senden
GOSUB SCHREIBEN
'
'******************** Umschalten nach Steuerwort **************************
'                          LCD-Freigabe usw.
A=4
N=3
GOSUB SCHREIBEN
'
N=1
GOSUB SCHREIBEN
'
N=2
GOSUB SCHREIBEN
'
N=3
GOSUB SCHREIBEN
'
'**************************************************************************
RETURN
'
DATEN:
A=3 : REM Datenwort nach Port 3
GOSUB SCHREIBEN
'
'*************************** LCD-Freigabe ********************************
'
A=4
N=2
GOSUB SCHREIBEN
'
N=3
GOSUB SCHREIBEN
'*************************************************************************
RETURN
'
