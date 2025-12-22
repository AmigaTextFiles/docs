1      REM ************************************************
2      REM *
3      REM *   Programm Portausgangstest
4      REM *   Nach dem Start des Programms koennen
5      REM *   durch die Eingabe auf den Tasten 1-10
6      REM *   die folgenden Ausgaben gemacht werden.
7      REM *   Taste 1=Bit 1 usw. / Taste 9 gibt die Werte
8      REM *   binaer hochzaehlend von 0-255 aus.
9      REM *   Taste 0=0
10     REM *
11     REM ************************************************
80    X=0C002H :  REM Diese Adresse ist Ausgangsport 3
90    A=0
100   ABFRAGE=GET
110    IF ABFRAGE=0 GOTO 150
120    IF ABFRAGE=57 THEN  GOSUB 1000
130    IF ABFRAGE=48 THEN A=0 :  GOSUB 2000
131    IF ABFRAGE=49 THEN A=1 :  GOSUB 2000
132    IF ABFRAGE=50 THEN A=2 :  GOSUB 2000
133    IF ABFRAGE=51 THEN A=4 :  GOSUB 2000
134    IF ABFRAGE=52 THEN A=8 :  GOSUB 2000
135    IF ABFRAGE=53 THEN A=16 :  GOSUB 2000
136    IF ABFRAGE=54 THEN A=32 :  GOSUB 2000
137    IF ABFRAGE=55 THEN A=64 :  GOSUB 2000
138    IF ABFRAGE=56 THEN A=128 :  GOSUB 2000
150    GOTO 100
1000   REM
1010   FOR Y=1 TO 255
1100  XBY(X)=Y
1200   PRINT Y, CR ,
1250   FOR B=1 TO 50 :  NEXT B
1300   NEXT Y
1500   RETURN 
2000  XBY(X)=A
2010   PRINT A,"   ", CR ,
2020   RETURN 
