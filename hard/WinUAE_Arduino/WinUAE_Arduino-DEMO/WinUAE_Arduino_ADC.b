REM Accessing Arduino as an ADC for WinUAE.
REM This idea copyright, (C)2008, B.Walker, G0LCU.
REM ACE Basic Compiler, (C) David Benn.
REM This is a DEMO only and gives WinUAE another I/O method
REM other than my now ancient WinUAE-ADC.lha on AMINET.
REM
REM $VER: ADC-Arduino_Version_0.00.10_(C)04-10-2008_G0LCU.
REM
REM To be used with the 'Arduino Diecimila' development board.
REM
REM WARNING!!! Do NOT run without the 'Arduino Diecimila' board connected!

REM Generate a simple window.
  WINDOW 2,"WinUAE-Arduino Diecimila ADC DEMO, (C)2008, G0LCU.",(0,0)-(640,200),6
  FONT "topaz.font",8
  COLOR 1,0
  CLS

REM Set up some basic variables.
  LET ser$="0"
  LET a$="(C)2008, B.Walker, G0LCU."

loopit:
REM Open up the serial port for reading. Note, this rate is used purely
REM for simplicity only.
  SERIAL OPEN #3, 0, 1200, "N81", 1

REM Read the 'PORT' for one byte only.
  SERIAL READ #3, ser$, 1

REM IMMEDIATELY close the opened 'PORT' after reading.
  SERIAL CLOSE #3

REM Simple printing to the default window.
  PRINT "Decimal value from Arduino is";ASC(ser$);CHR$(8);".   "

REM Press almost any key to QUIT.
  LET a$=INKEY$
  IF a$="" THEN GOTO loopit:

REM Normal cleanup.
  WINDOW CLOSE 2
  END
