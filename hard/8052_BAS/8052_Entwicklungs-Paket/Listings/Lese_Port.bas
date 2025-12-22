1      REM ************************************************************
2      REM *
3      REM *   Programm Lese_Port
4      REM *   Nach dem Start des Programms kann der Wert
5      REM *   der am Eingangsport Adresse 0C004 Hex anliegt
6      REM *   gelesen und auf dem Monitor gebracht werden.
7      REM *
8      REM ************************************************************
100    REM Programmhauptschleife
110   CHAR=GET
120    IF CHAR=0 GOTO 200
140    IF CHAR=36 THEN  GOSUB 9000
200    GOTO 100
9000   REM Unterprogramm liest den Wert in Variable MESS ein
9010  MESS=XBY(0C004H)
9020   PRINT MESS
9030   RETURN 
