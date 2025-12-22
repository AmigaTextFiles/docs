
REM PWM Digital To Analogue Converter using ACE Basic Compiler.
REM ACE Basic Compiler, (C)David benn.
REM
REM Original idea copyright, (C)2007, B.Walker, G0LCU.
REM
REM Written for kids to understand.

REM Open up a standard Workbench window.
  WINDOW 1,"Pulse Width Modulator D-A Converter.",(0,0)-(640,200),6
  FONT "topaz.font",8
  COLOR 1,0
  CLS

REM Set up an array for ~binary storage~.
  DIM code%(54)
  FOR n=1 TO 54
  READ code%(n)
  NEXT n
  GOTO begin:

REM Machine code to be poked into memory.
  DATA &H48E7, &HFFFE, &H2C79, &H0000, &H0004, &H4EAE, &HFF7C, &H4EAE
  DATA &HFF88, &H203C, &H0000, &H0000, &H08F9, &H0007, &H00BF, &HE001
  DATA &H51C8, &HFFF6, &H0839, &H0002, &H00DF, &HF016, &H6602, &H601C
  DATA &H203C, &H0000, &H00FF, &H08B9, &H0007, &H00BF, &HE001, &H51C8
  DATA &HFFF6, &H0839, &H0002, &H00DF, &HF016, &H66C6, &H08B9, &H0007
  DATA &H00BF, &HE001, &H2C79, &H0000, &H0004, &H4EAE, &HFF82, &H4EAE
  DATA &HFF76, &H4CDF, &H7FFF, &H4280, &H4E75, &H4E71

REM Set up ALL variables.
begin:
  LET version$="$VER: PWM-RMB_Version_0_20_00_(C)2007_B.Walker_G0LCU."
  LET thegadget=255
  LET peak=0
  LET trough=255
  LET n=0
  LET bitseven=0
  LET pwmaddr&=16777212&

REM Set pin 6 of the games port to WRITE mode.
  POKE 12575233&,131

REM Point to the machine code routine.
  LET pwmaddr&=VARPTR(code%(1))

REM Set up a slider and fixed 'QUIT' gadget(s).
  GADGET 255,1,255,(28,70)-(595,80),4,0
  GADGET 254,1,"Quit.",(274,93)-(344,109),BUTTON,1,"topaz.font",8,0
REM Set up a fake MENU.
  MENU 1,0,1,"(C)2007, G0LCU."
  MENU 1,1,1,"Barry Walker."

REM This is the startup screen and user loop.
  COLOR 0,0
  LOCATE 2,12
  PRINT version$
  COLOR 1,0
  LOCATE 4,13
  PRINT "Pulse Width Modulated Digital To Analogue Converter."
  LOCATE 5,13
  PRINT "----------------------------------------------------"
  LOCATE 8,28
  PRINT "(C)2007 B.Walker G0LCU."
  LOCATE 10,3
  PRINT "0"
  LOCATE 10,76
  PRINT "255"
  SLEEP FOR 1
  GOTO setzero:

REM Wait for a gadget event.
loopit:
  GADGET WAIT 0
  LET thegadget=GADGET(1)
  IF thegadget=255 THEN LET peak=GADGET(3)
  IF thegadget=254 THEN GOTO getout:

REM Poke into the machine code routine directly!!!
  LET trough=255-peak
  POKE (pwmaddr&+23),peak
  POKE (pwmaddr&+53),trough
  LET peak=PEEK(pwmaddr&+23)
  IF peak=0 THEN GOTO setzero:
  IF peak=255 THEN GOTO setone:

REM Print the mark to space values, IF ANY.
  LOCATE 8,28
  IF peak>=1 AND peak<=254 THEN PRINT "Mark =";peak;CHR$(8);", Space =";trough;CHR$(8);".        "

REM Print a help line.
  COLOR 1,0
  LOCATE 16,15
  PRINT "Press the ";
  COLOR 2,0
  PRINT "RIGHT";
  COLOR 1,0
  PRINT " mouse button to set a new value!"

REM Call the machine code routine.
REM The RMB MUST be pressed to exit the 'CALL' routine!!!
  CALL pwmaddr&

REM Clear the help line.
  COLOR 1,0
  LOCATE 16,15
  PRINT "                                                 "

REM Deliberately set the output to minimum on 'CALL' exit.
setzero:
  LET bitseven=PEEK(12574721&)
  IF bitseven>=128 THEN POKE 12574721&,(bitseven-128)
  POKE (pwmaddr&+23),0
  POKE (pwmaddr&+53),255
  LOCATE 8,28
  PRINT "Output set to minimum.        "
  GOTO loopit:

REM Set maximum directly.
setone:
  LET bitseven=PEEK(12574721&)
  IF bitseven<=127 THEN POKE 12574721&,(bitseven+128)
  POKE (pwmaddr&+23),255
  POKE (pwmaddr&+53),0
  LOCATE 8,28
  PRINT "Output set to maximum.       "
holdmax:
  IF MOUSE(0)=0 THEN GOTO holdmax:
  GOTO setzero:

REM Simple cleanup and exit.
getout:
REM Clear the menus.
  MENU CLEAR
REM Close the gadgets.
  GADGET CLOSE 254
  GADGET CLOSE 255
REM Set pin 6 of the games port back to READ mode.
  POKE 12575233&,3
REM Close down the window.
  WINDOW CLOSE 1
  END
