'**************************************************************************
'*                                                                        *
'*                    Programm: Port_Ausgabe_2.bas                        *
'*                                                                        *
'*                      © 1996 Andreas Heinrich                           *
'*                                                                        *
'**************************************************************************
'
'
'        Dieses Programm schreibt an Port 3 den Wert der Variable N
'                   N kann über Input eingegeben werden.
'
'
'**************************************************************************
'
'  A=Port selektieren
'  N=Wert an diesem Port geben
'
'
A=3 : REM       Ausgabeport 3 wird ausgewählt -> IC 4
N=0 : REM       Wert 0 in N
'
GOSUB INIT :    REM    Nach dem Einschalten einmal aufrufen
GOSUB SCHREIBEN
'
'**************************** Hauptprogramm *******************************
'
'
'
DO
PRINT
PRINT "   Gebe eine Zahl ein: ";
'
'     Die Zahl sollte natürlich im 8 Bit - Bereich liegen. ( 0 - 255 )
'
INPUT N
GOSUB SCHREIBEN
PRINT : PRINT "   Das Programm läßt sich mit Crtl-C unterbrechen."
LOOP
'
'
'************************** Unterprogramme ********************************
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
INIT:
'
POKE 12571136&,199 : REM    Busy,P-aus und SEL=Bitmuster Ausgabe
POKE 12570624&,255 : REM    Adresse 7 selektieren (Ready LED ein)
POKE 12575489&,0 :   REM    Port als Eingang schalten
'
RETURN
'
