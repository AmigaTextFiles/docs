1      REM *************************************************************
2      REM *
3      REM *                 Programm LED-Anzeige-Test
4      REM * Das Programm schreibt 1 2 3 4 und einen Dezimalpunkt
5      REM * auf die Digits. Danach wird ein kompletter Segment-Test
6      REM * gemacht, wobei alles leuchten sollte. Zum Schluss wird 
7      REM * die Helligkeit erhoeht und das Programm beginnt von vorne.
8      REM *
9      REM *************************************************************
10    DBY(6CH)=76H :  REM    Adresse des SAA 1064
20    DBY(6DH)=6 :  REM      6 Bytes uebertragen
30    DBY(78H)=0 :  REM      1.Byte = 0 fuer das Kontrollregister
40    DBY(79H)=23 :  REM     2.Byte Aktiviere Digits 1&3, 2&4 mit 3mA
50    DBY(7AH)=6 :  REM      Steht fuer die 1
60    DBY(7BH)=91 :  REM     Steht fuer die 2
70    DBY(7CH)=79 :  REM     Steht fuer die 3
80    DBY(7DH)=102 :  REM    Steht fuer die 4
90     CALL 7E00H :  REM     Aufruf des I2C-Ausgabe-Treibers
100    PRINT "Schreibe 1 2 3 4 auf die Digits." :  PRINT 
110    FOR X=1 TO 1000 :  NEXT X
120    PRINT "Jetzt setze ich bei der 2 den Dezimalpunkt." :  PRINT 
130   DBY(6CH)=76H :  REM    Adresse des SAA 1064
140   DBY(6DH)=4 :  REM      4 Bytes uebertragen
150   DBY(78H)=0 :  REM      0 fuer das Kontrollregister
160   DBY(79H)=23 :  REM     Digits 1&3, 2&4 mit 3 mA
170   DBY(7AH)=6 :  REM      Steht fuer die 1
180   DBY(7BH)=91+128 :  REM 91("2")+128 werden dazu addiert fuer den .
190    CALL 7E00H :  REM     Aufruf des I2C-Ausgabe-Treibers
200    FOR X=1 TO 1000 :  NEXT X
210    PRINT "Kleiner Segmenttest:" :  PRINT 
220    PRINT "Brennen alle Segmente ?" :  PRINT 
230   DBY(6CH)=76H :  REM    Adresse
240   DBY(6DH)=2 :  REM      ? Bytes
250   DBY(78H)=0 :  REM      Kontrollregister
260   DBY(79H)=31 :  REM     Segmenttest mit 3 mA
270    CALL 7E00H
280    FOR X=1 TO 1000 :  NEXT X
290    PRINT "Ein bisschen heller ?"
300   DBY(6CH)=76H :  REM    Adresse 
310   DBY(6DH)=2 :  REM      ? Bytes
320   DBY(78H)=0 :  REM      Kontrollregister
330   DBY(79H)=63 :  REM     Segmenttest mit 6 mA
340    CALL 7E00H
350    FOR X=1 TO 1000 :  NEXT X
360    PRINT  :  PRINT "Noch heller ?"
370   DBY(6CH)=76H :  REM    Adresse 
380   DBY(6DH)=2 :  REM      ? Bytes
390   DBY(78H)=0 :  REM      Kontrollregister
400   DBY(79H)=127 :  REM    Segmenttest mit 12 mA
410    CALL 7E00H
420    FOR X=1 TO 1000 :  NEXT X
430    PRINT  :  PRINT "Und wieder von vorne..." :  PRINT 
440    GOTO 10 :  REM        Und wieder von vorne... Ab dafuer!
499    END 
