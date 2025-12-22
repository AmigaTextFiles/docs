10 REM A PAL-NTSC switching program for AmigaBASIC on an A600HD.
20 REM Public Domain, 2006, from B.Walker, G0LCU.
30 REM Set up a simple screen using AmigaBASIC's default window.
40 REM Bit 5 of register 0xDFF1DC set to 0 switches the video mode
50 REM to NTSC, reset to 1 switches the video mode to PAL.

60 REM Clear the running window.
70 CLS

80 REM Create a simple menu.
90 PRINT
100 PRINT " PAL-NTSC switching demo, press:-"
110 PRINT
120 PRINT " ~P~ or ~p~ for PAL video."
130 PRINT " ~N~ or ~n~ for NTSC video."
140 PRINT
150 PRINT " ~Q~ or ~q~ to Quit."
160 REM This is the main loop.
170 LET a$=INKEY$
180 IF a$="P" OR a$="p" THEN POKE 14676444&,32
190 IF a$="N" OR a$="n" THEN POKE 14676444&,0
200 IF a$="Q" OR a$="q" THEN GOTO 230
210 GOTO 170

220 REM Quit back to workbench.
230 SYSTEM
