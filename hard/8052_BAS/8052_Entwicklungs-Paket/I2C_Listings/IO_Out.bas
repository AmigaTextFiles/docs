1      REM ******************************************************************
2      REM *
3      REM *               Programm IO_Out
4      REM * Der angeschlossene I/O-Chip PCF 8574 P unter der Adresse 4EH
5      REM * wird zur Ausgabe eines 8 Bit Datenwortes gebraucht.
6      REM * Es wird der Wert von 0-255 (0H=0FFH) ausgeben.
7      REM *
8      REM ******************************************************************
9      FOR I=0 TO 255 :  REM     For Next Schleife (0-255)
10    DBY(6CH)=4EH :  REM        Adresse des I/O-Chip
20    DBY(6DH)=1 :  REM          1 Byte schreiben
60    DBY(78H)=I :  REM          I=Wert der geschrieben wird
70     CALL 7E00H :  REM         Aufruf des I2C-Ausgabe-Treibers
75     PRINT I, :  PH0. I :  REM Ausgabe in Dez und Hex
80     NEXT I :  REM             Schleifenende
145    PRINT  :  REM             Leerzeile
500    END  :  REM               Und Tschuess...
