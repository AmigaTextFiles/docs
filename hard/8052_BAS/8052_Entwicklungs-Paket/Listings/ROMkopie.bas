10     REM****************************************************************
20     REM
30     REM                   ROM - Kopier - Programm
40     REM 
50     REM         Zum uebertragen des Interpreters in ein EPROM
60     REM
70     REM       Benoetigt wird der Adaptersockel (siehe Anleitung)
80     REM
90     REM
99     REM****************************************************************
100   XTAL=12000000
110    PRINT  :  PRINT 
120    PRINT  SPC (15),"** Der ROM-Inhalt wird ins RAM kopiert **"
130    PRINT  :  PRINT 
140    PRINT  SPC (23),"Dauert ca. 75 Sekunden"
150    PRINT  :  PRINT 
160   MTOP=1FFFH
170    FOR X=0000H TO 1FFFH
180   A=CBY(X)
190   Z=X+2000H
200   XBY(Z)=A
210    NEXT X
220    REM
230   DBY(18H)=0FFH
240   DBY(19H)=00H
250   DBY(1AH)=7FH
260   DBY(1BH)=20H
270   DBY(1EH)=00H
280   DBY(1FH)=20H
290   W=0.05
300   R=65536-W*XTAL/12
310   DBY(40H)=R/256
320   DBY(41H)=R.AND.0FFH
330   DBY(38)=DBY(38).AND.0F7H
340    REM
350    PRINT  SPC (17),"** Programmierspannung einschalten **"
360    PRINT 
370    PRINT  SPC (15),"Ist Jumper bzw. Schalter S1 geschlossen ?"
380    PRINT  :  PRINT 
390    PRINT  SPC (14),"Enter  druecken, um programmieren zu starten"
400    PRINT  SPC (16),"F7 druecken, um programmieren zu stoppen"
410    PRINT 
420    PRINT  SPC (27),"Enter oder F7"
430   T=GET :  IF T=0 THEN 430
440    IF T<>0DH THEN 430
450    PRINT  :  PRINT 
460    PRINT  :  PRINT 
470    PRINT  SPC (20),"** Programmiervorgang laeuft **"
480    PRINT 
490    PRINT  :  PRINT  SPC (25),"Dauert ca. 7 Minuten"
500    PRINT  :  PRINT  :  PRINT 
510    PGM 
520    PRINT  :  PRINT  :  PRINT 
530   H=DBY(1AH) : L=DBY(18H) : HL=H*256+L
540    IF (DBY(30).OR.DBY(31))<>0 THEN 550 ELSE 560
550    PRINT "Falsche Programmierung auf Epromadresse", PH1. HL :  END 
560    PRINT  SPC (20),"Programmierung beendet und OK"
570    PRINT  :  PRINT  :  PRINT 
580    PRINT  SPC (20),"** Vergleiche Rom - Eprom **" :  PRINT 
590    PRINT 
600    FOR X=0000H TO 1FFFH
610   Y=X+8000H
620   A=CBY(X) : B=XBY(Y)
630    PRINT "Rom", :  PH1. X, :  PRINT " =>", :  PH0. A," =",
640    PH0. B, :  PRINT " <=", :  PH1. Y, :  PRINT " Eprom", CR ,
650    IF A<>B THEN  PRINT "Eprom-Fehler !" :  END 
660    NEXT X :  PRINT  :  PRINT 
670    PRINT "Eprom ist korrekt programmiert" :  PRINT  :  PRINT 
680    PRINT "Programm ist beendet" :  PRINT  :  PRINT 
690    PRINT "Jumper bzw. Schalter S1 entfernen oder oeffnen !"
700    END 
