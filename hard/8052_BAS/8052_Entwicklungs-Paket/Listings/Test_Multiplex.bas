1      REM ********************************************************
2      REM *
3      REM *   Programm Test_Multiplex
4      REM *   Die 8 Frequenzeingaenge werden
5      REM *   durchgescannt und der gelesene
6      REM *   Wert auf den Monitor ausgegeben.
7      REM *
8      REM ********************************************************
10    XTAL=12000000
15    X=31
20    XBY(0C003H)=X
30    TMOD=80
40    TIMER1=0
50    TIME=0 :  CLOCK 1 :  ONTIME 1,500 :  DO 
490    WHILE TIME
500    REM
501   TEMP=TIMER1
502    GOSUB 1000
505    PRINT "Auf Eingang Nr.",E,"ist ",TEMP,"Hertz     ", CR ,
510   X=X+32
512    IF X>255 THEN X=31
515   XBY(0C003H)=X
545   TIMER1=0
550    ONTIME TIME+1,500 :  RETI 
560    WHILE TIME
1000   IF X=31 THEN E=1
1010   IF X=159 THEN E=2
1020   IF X=95 THEN E=3
1030   IF X=223 THEN E=4
1040   IF X=63 THEN E=5
1050   IF X=191 THEN E=6
1060   IF X=127 THEN E=7
1070   IF X=255 THEN E=8
1100   RETURN 
