REM ***********************************************************************
REM
REM Games Port WRITE access using STANDARD AmigaBASIC only.
REM
REM Original idea and copyright, (C)1996 B.Walker, (G0LCU).
REM
REM Now PD 2007 via:-     http://www.thecryptmag.com
REM
REM This is ready for AmigaBASIC, an old style A500 and OS1.3x.
REM
REM ***********************************************************************

REM Written so that youngsters can understand it!
REM $VER: TTL-Clock.b_Version_0_78_00_(C)2007_B.Walker_G0LCU.
REM Set up any string variables.
  LET a$="(C)2007 B.Walker, G0LCU."
REM Set up any numerical variables.
  LET n=0

REM ~CIAA~ address for register ~pra~.
  LET pra=12574721
REM ~CIAA~ address for direction of port ~pra~, (1=OUTPUT).
  LET ddra=12575233

REM Store single byte values of these addresses for future use.
  LET valpra=PEEK(pra)
  LET valddra=PEEK(ddra)
REM Bit 0 of port ~ddra~ DO NOT CHANGE...
REM Bit 1 of port ~ddra~ switches the ~LED~ ON or OFF, (1=ON).
REM Bits 2 to 5 inclusive of port ~ddra~ DO NOT CHANGE...
REM Bits 6 and 7 of port ~ddra~ alter PIN 6 of the mouse/games ports, (1=OUTPUT).

REM Generate a simple setup screen.
  COLOR 1,0
  CLS
  LOCATE 4,18
  PRINT "Open the games port for WRITE access..."
  LOCATE 6,18
  PRINT "Data direction address is at 12575233..."
  LOCATE 8,18
  PRINT "Press almost any key to exit..."
  LOCATE 12,18
  PRINT "Data tansfer address is at 12574721..."
  LOCATE 14,18
  PRINT "Value at pin 6 of the games port is:- 1."
  
REM Write ~1~s and ~0~s to PIN 6 of the games port.
REM Force bit 7 of ~pra~ as an OUTPUT.
REM It is assumed that it is ALREADY set as an INPUT!!!
  POKE ddra,(valddra+128)
REM Enter the ~Clock Mode~ loop...
loopit:
  LET n=PEEK(pra)
REM Set bit 7 of ~pra~ to a value of ~1~.
  IF n<=127 THEN POKE pra,(n+128)
  LOCATE 14,56
  PRINT "1"
  LET n=PEEK(pra)
REM Set bit 7 of ~pra~ to a value of ~0~.
  IF n>=128 THEN POKE pra,(n-128)
  LOCATE 14,56
  PRINT "0"
REM Press almost any key to Quit...
  LET a$=INKEY$
  IF a$="" THEN GOTO loopit:

REM Exit routine.
REM Reset all of the registers back to their original state.
  POKE pra,valpra
  POKE ddra,valddra
  END
