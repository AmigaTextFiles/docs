1      REM ***************************************************************
2      REM *
3      REM *       Programm Temperaturmessung
4      REM *       liest den Wert der an T1 anliegt
5      REM *       und gibt diesen auf das LCD
6      REM *       und auf das Terminal aus.
7      REM *
8      REM ***************************************************************
10    XTAL=12000000 :  REM   Quarzfrequenz einstellen
20     GOSUB 9200 :  REM     LCD Display initialisieren
30    TMOD=80 :  REM         Register fuer externen Timer einstellen
40    TIMER1=0 :  REM        Externen Timer auf 0 setzen
45    A=0 :  REM             Variable A auf 0
47     REM                   Interner Timer gibt jede Sekunde den Befehl
48     REM                   nach Zeile 500 zu springen
50    TIME=0 :  CLOCK 1 :  ONTIME 1,500 :  DO 
60     WHILE TIME
500    REM
501   TEMP=TIMER1
502   N=3 :  GOSUB 9000 :  REM Zeile auf Display loeschen
505    PRINT TEMP, CR , :  REM Messwert Seriell ausgeben
506    REM       Fuer die LCD-Ausgabe sind ein paar Berechnungen noetig
507   A=INT(TEMP/100)
510   N=48+A/10
512    GOSUB 9100 :  REM     Schreibe Tausender
515   N=48+A-10*INT(A/10)
517    GOSUB 9100 :  REM     Schreibe Hunderter
518   A=INT(TEMP/10)
520   N=48+A-10*INT(A/10)
525    GOSUB 9100 :  REM     Schreibe Zehner
530   N=48+TEMP-10*INT(TEMP/10)
535    GOSUB 9100 :  REM     Schreibe Einer
545   TIMER1=0 :  REM        Externen Zaehler wieder auf 0 setzen
550    ONTIME TIME+1,500 :  RETI  :  REM Ruecksprung
8980   REM
8990   REM         Die folgenden Zeilen sind nur fuer die LCD-Ausgabe
8995   REM
9000   REM----- Kommando -----
9010  XBY(0C000H)=N
9020  XBY(0C001H)=192
9030  XBY(0C001H)=128
9040  XBY(0C001H)=64
9050  XBY(0C001H)=192
9060   RETURN 
9100   REM----- Daten -----
9110  XBY(0C000H)=N
9120  XBY(0C001H)=64
9130  XBY(0C001H)=192
9140   RETURN 
9200   REM----- Init -----
9210  N=38H
9220   GOSUB 9000
9230  N=12
9240   GOSUB 9000
9250  N=1
9260   GOSUB 9000
9290   RETURN 
