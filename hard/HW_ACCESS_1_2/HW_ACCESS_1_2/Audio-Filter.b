10 REM This is a simple keyboard switch to turn the audio filter ON/OFF.
20 REM Each line/part has a comment above it as to what it does.
30 REM Use the AmigaBASIC interpreter's window for DEMO purposes.
40 REM Public Domain, 2006, from B.Walker, G0LCU.
50 REM Registers CIAA ~ddra~ and CIAA ~pra~ will be accessed for this task.
60 REM Register CIAA ~ddra~ is the data direction register, 1 = OUTPUT.
70 REM Register CIAA ~pra~ is the programmable register we use for the filter.
80 REM Register CIAA ~ddra~ is 12575233 decimal, (0xBFE201 hexadecimal).
90 REM Register CIAA ~pra~ is 12574721 deciaml, (0xBFE001 hexadecimal).
100 REM Register CIAA ~ddra~ has to be set to write to CIAA ~pra~ Bit 1, the LED.

110 REM Save register values.
120 LET ddra=12575233
130 LET pra=12574721
140 LET valddra=PEEK(ddra)
150 LET valpra=PEEK(pra)

160 REM Set CIAA ~ddra~ to write on bits 0 and 1, the bootup default.
170 POKE ddra,3

180 REM Clear the running window.
190 CLS

200 REM Create a simple menu.
210 PRINT
220 PRINT " Filter switching demo, press:-"
230 PRINT
240 PRINT " ~l~ to turn on audio filter and power light."
250 PRINT " ~L~ to turn off audio filter and power light."
260 PRINT
270 PRINT " ~Q~ or ~q~ to Quit."

280 REM This is the main loop.
290 LET a$=INKEY$
300 IF a$="l" THEN POKE pra,252
310 IF a$="L" THEN POKE pra,254
320 IF a$="Q" OR a$="q" THEN GOTO 350
330 GOTO 290

340 REM Cleanup and Quit.
350 POKE pra,valpra
360 POKE ddra,valddra
370 SYSTEM
