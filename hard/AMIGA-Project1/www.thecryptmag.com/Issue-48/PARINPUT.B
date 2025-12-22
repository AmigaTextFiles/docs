10 REM Using AmigaBASIC to access the parallel port for the Event Detector.
20 REM It uses PAR: as a VOLUME in READ mode. (C)2006, B.Walker, G0LCU.
30 REM This is Public Domain, and is ENTIRELY for Workbench 1.3x users.
40 REM An old style STANDARD A500 is all that is required.

60 REM Setup a simple screen.
70 CLS
80 CLEAR
90 PRINT "                   Event detector, (C)2006, B.Walker, G0LCU."
100 PRINT
110 PRINT "                         Use ~Esc~ to exit or quit."
120 PRINT
130 PRINT "                              No event detected."

140 REM Set up the required variables.
150 LET count=0
160 LET mybyte=0
170 LET mybyte$="(C)2006, B.Walker, G0LCU."
180 LET a$=""

200 REM Open a channel and import the byte from the parallel port.
210 OPEN "PAR:" FOR INPUT AS #3 LEN=1
220 LET mybyte$=INPUT$(1,#3)
230 CLOSE #3
240 REM Immediately close the channel after byte access.
240 LET a$=a$+mybyte$
250 IF a$="" THEN LET a$=CHR$(255)
260 LET mybyte=ASC(mybyte$)

270 REM Do a bit test to check for an arming of any channel.
280 GOSUB 500

290 REM After a period of time of NO activity...
300 REM RESET to the start of the program.
310 LET count=count+1
320 IF count>=100 THEN GOTO 10
330 LET a$=INKEY$
340 If a$=CHR$(27) THEN GOTO 400
350 GOTO 160

400 REM Quit the program.
410 SYSTEM

500 REM Test multiple bits to set up any alarms.
510 LET mybyte=255-mybyte
520 IF mybyte>=128 AND mybyte<=254 THEN GOSUB 8000
530 IF mybyte>=128 AND mybyte<=254 THEN LET mybyte=mybyte-128
540 IF mybyte>=64 AND mybyte<=127 THEN GOSUB 7000
550 IF mybyte>=64 AND mybyte<=127 THEN LET mybyte=mybyte-64
560 IF mybyte>=32 AND mybyte<=63 THEN GOSUB 6000
570 IF mybyte>=32 AND mybyte<=63 THEN LET mybyte=mybyte-32
580 IF mybyte>=16 AND mybyte<=31 THEN GOSUB 5000
590 IF mybyte>=16 AND mybyte<=31 THEN LET mybyte=mybyte-16
600 IF mybyte>=8 AND mybyte<=15 THEN GOSUB 4000
610 IF mybyte>=8 AND mybyte<=15 THEN LET mybyte=mybyte-8
620 IF mybyte>=4 AND mybyte<=7 THEN GOSUB 3000
630 IF mybyte>=4 AND mybyte<=7 THEN LET mybyte=mybyte-4
640 IF mybyte>=2 AND mybyte<=3 THEN GOSUB 2000
650 IF mybyte>=2 AND mybyte<=3 THEN LET mybyte=mybyte-2
660 IF mybyte=1 THEN GOSUB 1000
670 RETURN

1000 REM Test for Bit 0 set, channel 1.
1010 LET count=0
1020 CLS
1030 BEEP
1040 PRINT "ALARM!!! Channel 1 fired."
1999 RETURN

2000 REM Test for Bit 1 set, channel 2.
2010 LET count=0
2020 CLS
2030 BEEP
2040 PRINT "ALARM!!! Channel 2 fired."
2999 RETURN

3000 REM Test for Bit 2 set, channel 3.
3010 LET count=0
3020 CLS
3030 BEEP
3040 PRINT "ALARM!!! Channel 3 fired."
3999 RETURN

4000 REM Test for Bit 3 set, channel 4.
4010 LET count=0
4020 CLS
4030 BEEP
4040 PRINT "ALARM!!! Channel 4 fired."
4999 RETURN

5000 REM Test for Bit 4 set, channel 5.
5010 LET count=0
5020 CLS
5030 BEEP
5040 PRINT "ALARM!!! Channel 5 fired."
5999 RETURN

6000 REM Test for Bit 5 set, channel 6.
6010 LET count=0
6020 CLS
6030 BEEP
6040 PRINT "ALARM!!! Channel 6 fired."
6999 RETURN

7000 REM Test for Bit 6 set, channel 7
7010 LET count=0
7020 CLS
7030 BEEP
7040 PRINT "ALARM!!! Channel 7 fired."
7999 RETURN

8000 REM Test for Bit 7 set, channel 8.
8010 LET count=0
8020 CLS
8030 BEEP
8040 PRINT "ALARM!!! Channel 8 fired."
8999 RETURN
