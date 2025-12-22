REM ***********************************************************************
REM
REM (C)2003 B.Walker, (G0LCU). Team AMIGA...
REM
REM This is ready for ~ACE Basic Compiler~, (C) David Benn.
REM
REM ***********************************************************************

REM Open a standard window under Workbench.
  WINDOW 1,"        Games Port Voltmeter.       ",(0,11)-(320,100),6
  FONT "topaz.font",8
  COLOR 1,0
  CLS

REM Set up any string variables.
  LET a$="(C)2003 B.Walker, G0LCU."
  LET b$=a$

REM Set up any numerical variables.
  LET n=0
  LET m=1
  LET bitseven=0
  LET bitsix=0
  LET bitfive=0
  LET bitfour=0
  LET bitthree=0
  LET bittwo=0
  LET bitone=0
  LET bitzero=0
  LET cal=10
  LET volts=0

REM ~CIAA~ address for register ~pra~.
  LET pra=12574721
REM ~CIAA~ address for direction of port ~pra~, (1=OUTPUT).
  LET ddra=12575233
REM ~POTGOR~ address for the Games Port PIN 9.
  LET potgor=14675990
REM ~POTGO~ address for the Games Port PIN 9.
  LET potgo=14676020

REM Store single byte values of these addresses for future use.
  LET valpra=PEEK(pra)
  LET valddra=PEEK(ddra)
REM Bit 0 of port ~ddra~ DO NOT CHANGE...
REM Bit 1 of port ~ddra~ switches the ~LED~ ON or OFF, (1=ON).
REM Bits 2 to 5 inclusive of port ~ddra~ DO NOT CHANGE...
REM Bits 6 and 7 of port ~ddra~ alter PIN 6 of the mouse/games ports, (1=OUTPUT).

REM Load the calibrated values if they exist.
  OPEN "I", #1, "UAE-ADC.CAL"
  IF ERR<>0 THEN GOTO failure:
  INPUT #1, b$, cal
  GOTO success:
failure:
  LOCATE 4,10
  PRINT "No calibration found."
  LOCATE 6,7
  PRINT "Please run ~UAE-ADC~ first."
  SLEEP FOR 5
  CLOSE #1
  GOTO getout:
success:
  CLOSE #1

REM Set up a simple window.
  CLS
  LOCATE 3,9
  PRINT b$
  LOCATE 5,15
  PRINT "Waiting...."
  LOCATE 7,12
  PRINT "~Q~ or ~q~ to Quit."

REM Wait for a high level before starting the next cycle.
synchronise:
  LET a$=INKEY$
  IF a$="q" OR a$="Q" THEN GOTO getout:
  POKE (potgo+1),192
  LET n=PEEK(potgor)
  IF n<64 THEN GOTO synchronise:

REM Wait for a timing ~pulse~, active LOW.
mainloop:
  LET a$=INKEY$
  IF a$="q" OR a$="Q" THEN GOTO getout:
  POKE (potgo+1),192
  LET n=PEEK(potgor)
  IF n>=64 THEN GOTO mainloop:

REM Read the data in.
  FOR m=1 TO cal
  LET n=PEEK(pra)
  IF n>=128 THEN LET bitseven=1
  IF n<128 THEN LET bitseven=0
  NEXT m
  SLEEP FOR 0.04

  FOR m=1 TO cal
  LET n=PEEK(pra)
  IF n>=128 THEN LET bitsix=1
  IF n<128 THEN LET bitsix=0
  NEXT m
  SLEEP FOR 0.04

  FOR m=1 TO cal
  LET n=PEEK(pra)
  IF n>=128 THEN LET bitfive=1
  IF n<128 THEN LET bitfive=0
  NEXT m
  SLEEP FOR 0.04

  FOR m=1 TO cal
  LET n=PEEK(pra)
  IF n>=128 THEN LET bitfour=1
  IF n<128 THEN LET bitfour=0
  NEXT m
  SLEEP FOR 0.04

  FOR m=1 TO cal
  LET n=PEEK(pra)
  IF n>=128 THEN LET bitthree=1
  IF n<128 THEN LET bitthree=0
  NEXT m
  SLEEP FOR 0.04

  FOR m=1 TO cal
  LET n=PEEK(pra)
  IF n>=128 THEN LET bittwo=1
  IF n<128 THEN LET bittwo=0
  NEXT m
  SLEEP FOR 0.04

  FOR m=1 TO cal
  LET n=PEEK(pra)
  IF n>=128 THEN LET bitone=1
  IF n<128 THEN LET bitone=0
  NEXT m
  SLEEP FOR 0.04

  FOR m=1 TO cal
  LET n=PEEK(pra)
  IF n>=128 THEN LET bitzero=1
  IF n<128 THEN LET bitzero=0
  NEXT m

REM Calculate the 8 bit value as a decimal number.
  LET n=128*bitseven+64*bitsix+32*bitfive+16*bitfour+8*bitthree+4*bittwo+2*bitone+bitzero

REM All other calculations go here.

REM Display routines go here.
  LET volts=n*0.02
  LOCATE 5,10
  PRINT "DC Volts:- 0.00 Volts. "
  FIX -3
  LET a$=STR$(volts)
  LOCATE 5,20
  PRINT a$;

REM Go back and wait for the next timing pulse.
  GOTO synchronise:

REM Exit routine.
REM Reset all of the ports back to their original state.
getout:
  POKE pra,valpra
  POKE ddra,valddra
  WINDOW CLOSE 1
  END
