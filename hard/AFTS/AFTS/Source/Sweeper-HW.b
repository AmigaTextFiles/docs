REM
REM HW constant output audio sweep generator, (C) B.Walker.
REM ACE Basic Compiler, (C) D.Benn.
REM
REM This is the Sweep Generator GUI.

REM Original idea copyright, (C)2004, B.Walker, G0LCU.
REM Now issued under GPL.

  LET version$="$VER: Sweeper-HW_Version_0.92.10_(16-06-2006)."
  WINDOW 9,"Sweep Generator, Hardware.",(200,0)-(640,70),6
  FONT "topaz.font",8
  COLOR 1,0
  CLS

REM Set up the buttons.
  GADGET 255,ON,"10Hz.",(2,1)-(65,17),BUTTON,1,"topaz.font",8,0
  GADGET 254,ON,"50Hz.",(66,1)-(129,17),BUTTON,1,"topaz.font",8,0
  GADGET 253,ON,"100Hz.",(130,1)-(193,17),BUTTON,1,"topaz.font",8,0
  GADGET 252,ON,"500Hz.",(194,1)-(257,17),BUTTON,1,"topaz.font",8,0
  GADGET 247,ON,"Start.",(367,1)-(430,17),BUTTON,1,"topaz.font",8,0
  BEVELBOX (258,1)-(365,16),2
  PENUP
  SETXY 264,11
  PRINT "Sweep Steps.";
  GADGET 251,ON,"Slow.",(2,18)-(65,34),BUTTON,1,"topaz.font",8,0
  GADGET 250,ON,"Medium.",(66,18)-(129,34),BUTTON,1,"topaz.font",8,0
  GADGET 249,ON,"Fast.",(130,18)-(193,34),BUTTON,1,"topaz.font",8,0
  GADGET 248,ON,"Single.",(194,18)-(257,34),BUTTON,1,"topaz.font",8,0
  GADGET 246,ON,"Quit.",(367,18)-(430,34),BUTTON,1,"topaz.font",8,0
  BEVELBOX (258,18)-(365,33),2
  MENU 1,0,1,"Sweep Generator, 100Hz to 5KHz."
  MENU 1,1,1,"HW controlled constant output."
  PENUP
  SETXY 264,28
  PRINT "Sweep Rates.";
  COLOR 3,0
  PENUP
  SETXY 65,45
  PRINT "(C)2004, B.Walker, G0LCU, & A.Hoffman.";
  COLOR 0,0
  SETXY 33,54
  PRINT version$;
  LINE (0,35)-(432,35),2
  LINE (0,36)-(432,36),1
  COLOR 1,0

REM Initial memory setup.
  LET addr&=ALLOC(512,3)
  LET sineaddr&=addr&
  LET sounddata=0
  LET n=0
  FOR n=0 TO 509
  LET dataaddr&=(addr&+n)
  READ sounddata
  POKE dataaddr&,sounddata
  NEXT n
  GOTO variable_list:

REM Sine wave sample 2, 4 Bytes.
  DATA 0,127,0,-128

REM Sine wave sample 3, 8 Bytes.
  DATA 0,90,127,90,0,-90,-128,-90

REM Sine wave sample 4, 16 Bytes.
  DATA 0,49,90,117,127,117,90,49,0,-49,-90,-117,-128,-117,-90,-49

REM Sine wave sample 5, 32 Bytes.
  DATA 0,24,48,70,89,105,117,124,127,124,117,105,89,70,48,24
  DATA 0,-24,-48,-70,-89,-105,-117,-125,-128,-125,-117,-105,-89,-70,-48,-24

REM Sine wave sample 6, 64 Bytes.
  DATA 0,12,24,36,48,59,70,80,89,98,105,112,117,121,124,126,127,126,124,121,117
  DATA 112,105,98,89,80,70,59,48,36,24,12,0,-13,-25,-37,-49,-60,-71,-81,-90
  DATA -99,-106,-113,-118,-122,-125,-127,-128,-127,-125,-122,-118,-113,-106
  DATA -99,-90,-81,-71,-60,-49,-37,-25,-13

REM Sine wave sample 7, 128 Bytes.
  DATA 0,6,12,18,24,30,36,42,48,54,59,65,70,75,80,85,89,94,98,102,105,108,112
  DATA 114,117,119,121,123,124,125,126,126,127,126,126,125,124,123,121,119,117
  DATA 114,112,108,105,102,98,94,89,85,80,75,70,65,59,54,48,42,36,30,24,18,12,6
  DATA 0,-6,-12,-18,-24,-30,-36,-42,-48,-54,-59,-65,-70,-75,-80,-85,-89,-94,-98
  DATA -102,-105,-108,-112,-114,-117,-119,-121,-123,-124,-125,-126,-127,-128
  DATA -127,-126,-125,-124,-123,-121,-119,-117,-114,-112,-108,-105,-102,-98,-94
  DATA -89,-85,-80,-75,-70,-65,-59,-54,-48,-42,-36,-30,-24,-18,-12,-6

variable_list:
  LET a$="(C)2003 B.Walker, G0LCU, and A.Hoffamn."
  LET theGadget=248
  LET n=255
  LET hop=100
  LET delay=0.06
  LET leftbutton=1
  LET singleshot=0
  LET vol1=0
  LET sine1=100
  LET period1=INT(3563220/(128*sine1))

REM Reset audio hardware.
  POKEW 14676118,15                   'Switch off audio dma.
  POKE 12574721,252                   'Enable audio filter.

REM This is the main loop.
main_loop:
  PENUP
  SETXY 264,11
  PRINT "Sweep Steps.";
  PENUP
  SETXY 264,28
  PRINT "Sweep Rates.";
  LET vol1=0
  LET hop=100
  LET delay=0.06
  LET sine1=100
  LET singleshot=0

REM Generate a simple sinewave only, CH0.
  POKEL 14676128,(sineaddr&+124)      'Set address to chip ram.
  POKEW 14676132,64                   'Number of words in data sample.
  POKEW 14676134,period1              'Period of sampling time.
  POKEW 14676136,vol1                 'Volume max 64, min 0.
  POKEW 14676126,255                  'Disable any other modulation.
  POKEW 14676118,33281                'Enable sound on channel 0.
  POKE 12574721,252                   'Enable audio filter.

waitgadget:
  GADGET WAIT 0
  LET theGadget=GADGET(1)
  IF theGadget=255 THEN LET hop=10
  IF theGadget=254 THEN LET hop=50
  IF theGadget=253 THEN LET hop=100
  IF theGadget=252 THEN LET hop=500
  IF theGadget=247 THEN GOTO sweep_loop_setup:
  IF theGadget=251 THEN LET delay=0.12
  IF theGadget=250 THEN LET delay=0.06
  IF theGadget=249 THEN LET delay=0.02
  IF theGadget=248 THEN LET singleshot=1
  IF theGadget=246 THEN GOTO getout:
  GOTO waitgadget:

sweep_loop_setup:
  POKEW 14676118,33281                    'Enable sound on channel 0.
  POKE 12574721,252                       'Enable audio filter.
  PENUP
  SETXY 264,11
  PRINT "            ";
  PENUP
  SETXY 264,28
  IF delay>=0.01 THEN PRINT "    Fast.   ";
  SETXY 264,28
  IF delay>=0.05 THEN PRINT "   Medium.  ";
  SETXY 264,28
  IF delay>=0.11 THEN PRINT "    Slow.   ";
  SETXY 264,28
  IF singleshot=1 THEN PRINT "   Single.  ";
  GOTO sweep_loop_start:
sweep_loop:
  LET a$=INKEY$
  IF a$=" " THEN GOTO main_loop:
  LET leftbutton=MOUSE(0)
  IF leftbutton=-1 THEN GOTO main_loop:
  LET sine1=sine1+hop
sweep_loop_start:
  LET vol1=64
  IF sine1>5000 AND singleshot=1 THEN GOTO main_loop:
  IF sine1>5000 THEN LET sine1=100
  PENUP
  SETXY 264,11
  PRINT " ";sine1;"Hz.  "
  SLEEP FOR delay
  IF sine1>3500 THEN GOTO band1:
  IF sine1>1750 THEN GOTO band2:
  IF sine1>875 THEN GOTO band3:
  IF sine1>440 THEN GOTO band4:
  IF sine1>220 THEN GOTO band5:
  GOTO band6:

REM Frequency range bands.
band1:
  LET period1=INT(3563220/(4*sine1))
  POKEL 14676128,sineaddr&
  POKEW 14676132,2
  POKEW 14676134,period1
  POKEW 14676136,vol1
  GOTO sweep_loop:
band2:
  LET period1=INT(3563220/(8*sine1))
  POKEL 14676128,(sineaddr&+4)
  POKEW 14676132,4
  POKEW 14676134,period1
  POKEW 14676136,vol1
  GOTO sweep_loop:
band3:
  LET period1=INT(3563220/(16*sine1))
  POKEL 14676128,(sineaddr&+12)
  POKEW 14676132,8
  POKEW 14676134,period1
  POKEW 14676136,vol1
  GOTO sweep_loop:
band4:
  LET period1=INT(3563220/(32*sine1))
  POKEL 14676128,(sineaddr&+28)
  POKEW 14676132,16
  POKEW 14676134,period1
  POKEW 14676136,vol1
  GOTO sweep_loop:
band5:
  LET period1=INT(3563220/(64*sine1))
  POKEL 14676128,(sineaddr&+60)
  POKEW 14676132,32
  POKEW 14676134,period1
  POKEW 14676136,vol1
  GOTO sweep_loop:
band6:
  LET period1=INT(3563220/(128*sine1))
  POKEL 14676128,(sineaddr&+124)
  POKEW 14676132,64
  POKEW 14676134,period1
  POKEW 14676136,vol1
  GOTO sweep_loop:

REM Orderly closedown...
getout:
  POKEW 14676118,15     'Turn off audio DMA.
  POKE 12574721,252     'Enable audio filter.
  CLEAR ALLOC
  MENU CLEAR
  FOR n=255 TO 246 STEP -1
  GADGET CLOSE n
  NEXT n
  WINDOW CLOSE 9
REM Beep on a successful exit...
  BEEP
  END
