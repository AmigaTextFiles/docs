'**************************************************************************
'*                                                                        *
'*                    Programm: Port_Ausgabe_1.bas                        *
'*                                                                        *
'*                      © 1996 Andreas Heinrich                           *
'*                                                                        *
'**************************************************************************
'
'
'        Dieses Programm schreibt an Port 3 den Wert der Variable N
'             Dabei wird N hochgezählt bis 255 erreicht wird.
'
'
'**************************************************************************
'
'  A=Port selektieren
'  N=Wert an diesem Port geben
'
'
A=3 : REM         Ausgabeport 3 wird ausgewählt -> IC 4
N=0 : REM         Wert 0 in N
'
GOSUB INIT      : REM  Nach dem Einschalten einmal aufrufen
GOSUB SCHREIBEN : REM  Wert 0 an Port 3 schreiben
'
'**************************** Hauptprogramm *******************************
'
'               Und hier wird an Port 3 der Wert N hochgezählt
'
NOCH_EINMAL:
CLS
FOR X=0 TO 255
N=X
LOCATE 2,1
PRINT N :             REM  N auf Bildschirm ausgegeben
GOSUB SCHREIBEN
'
t1=TIMER
WHILE TIMER<=t1+.25 : REM  Zur besseren Kontrolle wird das Programm gebremst.
'                          Um volle Geschwindigkeit zu bekommen, die
'                          While und Wend - Anweisung herausnehmen.
WEND
NEXT X
'
PRINT
PRINT "Noch einmal ? Dann die Taste > 1 < drücken."
PRINT
PRINT
PRINT "Oder Abbruch mit Taste > 0 <."
PRINT
PRINT
'                 Warten bis Taste gedrückt.
'
DO
SLEEP
a$=INKEY$
 SELECT CASE a$
   CASE="1" : GOTO NOCH_EINMAL :   REM   Und noch einmal
   CASE="0" : PRINT "Ende" : END : REM   Programm beenden
 END SELECT
LOOP
'
'
'************************** Unterprogramme ********************************
'
SCHREIBEN:
'
POKE 12570624&,248+A : REM  Adresse A selektieren
POKE 12575489&,255   : REM  Port als Ausgang schalten
POKE 12574977&,N     : REM  Wert N schreiben
POKE 12570624&,255   : REM  Ready LED einschalten
'
RETURN
'
INIT:
'
POKE 12571136&,199 : REM    Busy,P-aus und SEL=Bitmuster Ausgabe
POKE 12570624&,255 : REM    Adresse 7 selektieren (Ready LED ein)
POKE 12575489&,0   : REM    Port als Eingang schalten
'
RETURN
'
