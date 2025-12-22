1      REM **************************************************************
2      REM *
3      REM *            Programm DA-Wandler
4      REM *   Der angeschlossene A/D-D/A I2C-Chip PCF 8591 P
5      REM *   auf Adresse 9EH wird auf Analog-Ausgabe eingestellt.
6      REM *   Der Binaerwert z.B. von 255 hat eine Spannung von
7      REM *   Uref*255/256 am Ausgang zur Folge.
8      REM *
9      REM **************************************************************
10    DBY(6CH)=9EH :  REM Adresse des I2C-Chip
20    DBY(6DH)=2 :  REM   Uebertragung von 2 Bytes
30    DBY(78H)=64 :  REM  I2C-Chip auf Analog-Ausgabe einstellen
40     PRINT "Gebe einen Wert zwischen 0-255 ein:",
50     INPUT V :  REM     Wert in V uebernehmen
60    DBY(79H)=V :  REM   und den Wert nach 79H schreiben
70     CALL 7E00H :  REM  Aufruf des I2C-Ausgabe-Treibers
80    VOLT=3.8/256*V :  PRINT "Ausgabe =", :  PRINT VOLT, :  PRINT "Volt"
85     PRINT 
90     GOTO 10 :  REM     Und noch einmal von vorne...
