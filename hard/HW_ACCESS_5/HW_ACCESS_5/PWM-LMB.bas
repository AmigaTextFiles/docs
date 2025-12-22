
REM PWM Digital To Analogue Converter using AmigaBASIC.
REM Original idea copyright, (C)2007, B.Walker, G0LCU.
REM
REM Written for kids to understand.
REM
REM Use AmigaBASIC's default winodw.
REM This WILL compile under ACE Basic Compiler, (C)David Benn.

REM Set up an array for ~binary storage~.
  DIM code%(54)
  FOR n=1 TO 54
  READ code%(n)
  NEXT n
  GOTO begin:

REM Poke the machine code into memory.
  DATA &H48E7, &HFFFE, &H2C79, &H0000, &H0004, &H4EAE, &HFF7C, &H4EAE
  DATA &HFF88, &H203C, &H0000, &H0000, &H08F9, &H0007, &H00BF, &HE001
  DATA &H51C8, &HFFF6, &H0839, &H0006, &H00BF, &HE001, &H6602, &H601C
  DATA &H203C, &H0000, &H00FF, &H08B9, &H0007, &H00BF, &HE001, &H51C8
  DATA &HFFF6, &H0839, &H0006, &H00BF, &HE001, &H66C6, &H08B9, &H0007
  DATA &H00BF, &HE001, &H2C79, &H0000, &H0004, &H4EAE, &HFF82, &H4EAE
  DATA &HFF76, &H4CDF, &H7FFF, &H4280, &H4E75, &H4E71

REM Set up all variables.
begin:
  LET version$="$VER: PWM-LMB.bas_Version_0_10_00_(C)2007_B.Walker_G0LCU."
  LET a$="(C)2007 B.Walker G0LCU."
  LET peak$="0"
  LET peak=0
  LET trough=255
  LET n=0
  LET bitseven=0
  LET pwmaddr&=16777212&

REM Set up the games port, pin 6, for writing.
  POKE 12575233&,131

REM Point to the machine code routine.
  LET pwmaddr&=VARPTR(code%(1))
  GOTO setzero:

REM This is the user loop.
loopit:
  CLS
  COLOR 2,0
  LOCATE 2,10
  PRINT version$
  COLOR 1,0
  LOCATE 4,13
  PRINT "Pulse Width Modulated Digital To Analogue Converter."
  LOCATE 5,13
  PRINT "----------------------------------------------------"
  LOCATE 8,28
  PRINT a$
  LOCATE 10,6

  INPUT "Set output level; ~0~ minimum to ~255~ maximum, ~QUIT~ to quit:- ",peak$
  IF peak$="QUIT" OR peak$="EXIT" THEN GOTO getout:
  IF peak$="" THEN LET peak$="0"
REM Convert ANY string to a number and DO NOT ALLOW an error.
  LET peak=VAL(peak$)
  LET peak=INT(peak)
  IF peak<=0 THEN LET peak=0
  IF peak>=255 THEN LET peak=255
  IF peak=0 THEN GOTO setzero:
  IF peak=255 THEN GOTO setone:
  LET trough=255-peak

REM Poke into the machine code routine directly!!!
  POKE (pwmaddr&+23),peak
  POKE (pwmaddr&+53),trough

REM Print the mark to space values, IF ANY.
  LOCATE 8,28
  IF peak>=1 AND peak<=254 THEN PRINT "Mark =";peak;CHR$(8);", Space =";trough;CHR$(8);"."
  COLOR 3,0
  LOCATE 10,1
  PRINT "              Press the left mouse button to set a new value...              "

REM Call the machine code routine.
  CALL pwmaddr&

REM Set minimum directly and ALWAYS on the 'CALL' return.
setzero:
  LET bitseven=PEEK(12574721&)
  IF bitseven>=128 THEN POKE 12574721&,(bitseven-128)
  POKE (pwmaddr&+23),0
  POKE (pwmaddr&+53),255
  LET a$="Output set to minimum."
  GOTO loopit:

REM Set maximum directly.
setone:
  LET bitseven=PEEK(12574721&)
  IF bitseven<=127 THEN POKE 12574721&,(bitseven+128)
  POKE (pwmaddr&+23),255
  POKE (pwmaddr&+53),0
  LET a$="Output set to maximum."
  GOTO loopit:

REM Simple cleanup and exit.
getout:
REM Set the games port, pin 6 back to read.
  POKE 12575233&,3
  END
