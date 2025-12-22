'**************************************************************************
'*                                                                        *
'*                    Programm: Port_Ein_Aus_.bas                         *
'*                                                                        *
'*                      © 1996 Andreas Heinrich                           *
'*                                                                        *
'**************************************************************************
'
'
'        Dieses Programm liest den Wert an Port 2 ein und legt
'        ihn in N ab. N wird dann auf Port 3 ausgegeben.
'
'
'**************************************************************************
'
'  A=Port selektieren
'  N=Wert aus diesem Port lesen
'
'
'
GOSUB INIT : REM      Nach dem Einschalten einmal aufrufen
'
'**************************** Hauptprogramm *******************************
'
'
'
ANFANG:
CLS
LOCATE 2,1
PRINT "Wert an Eingangsport = ";
'
A=2 : REM       Eingabeport 2 wird ausgewählt -> IC 2
GOSUB LESEN
PRINT N
A=3 : REM       Ausgabeport 3 wird ausgewählt -> IC 4
GOSUB SCHREIBEN
PRINT
PRINT "Noch einmal? Drücke die Taste > 1 <."
PRINT
PRINT "Oder Abbruch mit Taste > 0 <."
PRINT
'
DO
SLEEP
a$=INKEY$
 SELECT CASE a$
   CASE="1" : GOTO ANFANG :   REM   Und noch einmal
   CASE="0" : PRINT "Ende" : END : REM   Programm beenden
 END SELECT
LOOP

'
'
'************************** Unterprogramme ********************************
'
LESEN:
'
POKE 12575489&,0 :     REM  Port als Eingang schalten
POKE 12570624&,248+A : REM  Adresse A selektieren
N=PEEK(12574977&) :    REM  Wert N einlesen
POKE 12570624&,255 :   REM  Ready LED einschalten
'
RETURN
'
INIT:
'
POKE 12571136&,199 :   REM  Busy,P-aus und SEL=Bitmuster Ausgabe
POKE 12570624&,255 :   REM  Adresse 7 selektieren (Ready LED ein)
POKE 12575489&,0 :     REM  Port als Eingang schalten
'
RETURN
'
SCHREIBEN:
'
POKE 12570624&,248+A : REM  Adresse A selektieren
POKE 12575489&,255 :   REM  Port als Ausgang schalten
POKE 12574977&,N :     REM  Wert N schreiben
POKE 12570624&,255 :   REM  Ready LED einschalten
'
RETURN
'
