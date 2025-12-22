1      REM *************************************************************
2      REM *
3      REM *                 Programm LED-Zaehler
4      REM * Das Programm gibt die Ziffern von 0000-9999 auf die Digits.
5      REM * Die Adresse des I2C-Modul mit dem SAA 1064 liegt auf 76H.
6      REM * Das Programm war eigentlich nur zum Geschwindigkeitstest 
7      REM * der Ausgabe gedacht. Die PRINT-Ausgabe bremst es aus.
8      REM *
9      REM *************************************************************
10    DBY(6CH)=76H :  REM Adresse des SAA 1064
20    DBY(6DH)=6 :  REM   6 Bytes uebertragen
30    DBY(78H)=0 :  REM   1.Byte Kontrollregister
40    DBY(79H)=55 :  REM  Registersteuerwort zum initialisieren der 4 Digits
45     REM                Display erstmal nullen
50    DBY(7AH)=63 :  REM  1.Digit = 0
60    DBY(7BH)=63 :  REM  2.Digit = 0
70    DBY(7CH)=63 :  REM  3.Digit = 0
80    DBY(7DH)=63 :  REM  4.Digit = 0
90     CALL 7E00H :  REM  Aufruf des I2C-Ausgabe-Treibers
95    A=0
96    B=0
97    C=0
98    D=0
100   X=X+1
110   A=X
120    GOSUB 500
130   DBY(7DH)=LED :  REM 4.Ziffer
140    IF X=10 THEN B=B+1 :  GOSUB 700
468   DBY(6DH)=6
469   DBY(6CH)=76H
470    CALL 7E00H
490    GOTO 100
499    END 
500    REM                Zahlentabelle
510    IF A=0 THEN LED=63
520    IF A=1 THEN LED=6
530    IF A=2 THEN LED=91
540    IF A=3 THEN LED=79
550    IF A=4 THEN LED=102
560    IF A=5 THEN LED=109
570    IF A=6 THEN LED=125
580    IF A=7 THEN LED=7
590    IF A=8 THEN LED=127
600    IF A=9 THEN LED=111
610   A=0
620    RETURN 
700   A=B
705    IF A=10 THEN A=0 : B=0 : C=C+1 :  GOSUB 800
710    GOSUB 500
720   DBY(7CH)=LED :  REM 3.Ziffer
730   X=0
740   DBY(7DH)=63
790    RETURN 
800   A=C
810    IF A=10 THEN A=0 : B=0 : C=0 : D=D+1 :  GOSUB 900
820    GOSUB 500
830   DBY(7BH)=LED :  REM 2.Ziffer
840   X=0
880    RETURN 
900   A=D
910    IF A=10 THEN A=0 : B=0 : C=0 : D=0
920    GOSUB 500
930   DBY(7AH)=LED :  REM 1.Ziffer
940   X=0
980    RETURN 
