1      REM *************************************************************
2      REM *
3      REM *                 Programm Scan_Test
4      REM * Das Programm versucht auf dem I2C-Bus ein Dummy-Byte
5      REM * an Adresse 0-255 (0H-FFH) zu schreiben.
6      REM * Ist auf der Adresse 6EH der Wert 00H konnte ein Chip mit 
7      REM * der Adresse die in 6CH geschrieben, angesprochen werden.
8      REM *
9      REM *************************************************************
10    DBY(6DH)=1 :  REM       1 Byte schreiben
20    DBY(78H)=0 :  REM       Dummy-Byte gleich 0
30     FOR I=0 TO 0FFH :  REM For Next Schleife (0-255)
40    DBY(6CH)=I :  REM       I = von 0 hochzaehlend
50     CALL 7E00H :  REM      Aufruf des I2C-Ausgabe-Treibers
60     IF DBY(6EH)=0 THEN  PH0. I :  REM Wenn auf Adr. 6EH=0
65     REM                    dann Ausgabe der Adresse I in Hex
70     NEXT I :  REM          Schleifenende
100    END  :  REM            Und Tschuess
