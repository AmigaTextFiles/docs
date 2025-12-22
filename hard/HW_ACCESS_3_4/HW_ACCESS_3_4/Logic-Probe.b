10 REM Simple games port pin 6 READ access, Games Port Logic Probe. 
20 REM Public Domain, original copyright, (C)2006, B.Walker, G0LCU.
30 REM Written for - http://www.thecryptmag.com - as a simple project.
40 REM This project is for ALL ages.
50 REM See the drawing for the circuit.

100 REM Set up a simple window.
110 WINDOW 1,"Games Port Logic Probe.",(0,0)-(462,64),6
120 CLS

130 REM Set up any variables.
140 LET a$="(C)2006, B.Walker, G0LCU."
150 LET version$=" $VER: Logic-Probe.B_Version_0.80.00_(C)29-09-2006_G0LCU."
150 LET state=1

190 REM Set up the display.
200 PRINT
210 PRINT version$
220 PRINT
230 PRINT "         Press the SPACE BAR or Esc keys to Quit."
240 LOCATE 7,23
250 PRINT "Logic state";state;CHR$(8);".  "

390 REM This is the main loop.
400 LET a$=INKEY$
410 IF a$=" " OR a$=CHR$(27) THEN GOTO 1000
420 LET state=PEEK(12574721&)
430 IF state>=128 THEN LET state=1
440 IF state=1 THEN GOTO 460
450 IF state<=127 THEN LET state=0
460 LOCATE 7,23
470 PRINT "Logic state";state;CHR$(8);".  "
500 GOTO 400

990 REM Safe exit from the program.
1000 WINDOW CLOSE 1
1010 SYSTEM
