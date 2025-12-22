REM A simple Frequency Counter using the games port.
REM Original Copyright (C)2002 Barry Walker, G0LCU.
REM Compiled under ~ACE Basic Compiler~, (C) David Benn.
REM Released under the ~GPL~ Licence terms and conditions.
  WINDOW 1,"     Frequency Counter, (Left mouse button to Exit).    ",(0,11)-(480,92),6
  FONT "topaz.font",8
  COLOR 1,0
  CLS

REM Set up the string variables.
  LET a$="(C)2002 B.Walker, G0LCU."
  LET b$=a$
REM Set up the numerical variables.
  LET value0=PEEKL(0)
  LET frequency=0
  LET freq=0
  LET correction=0
  LET hfcorrect=1690
  LET mfcorrect=2060
  LET lfcorrect=5170
  LET calibrate=0

REM Main window setup.
  LOCATE 3,7
  PRINT "Frequency Counter, 100Hz to 10MHz in two ranges."
  LOCATE 5,19
  PRINT a$
  SLEEP FOR 2
  FONT "topaz.font",16
  CLS

REM Load user calibrated values if they exist.
  OPEN "I", #1, "Calibration"
  IF ERR<>0 THEN GOTO failure:
  INPUT #1, b$, hfcorrect,mfcorrect,lfcorrect
  GOTO success:
failure:
  LOCATE 2,6
  PRINT "Using default values."
  SLEEP FOR 2
  GOTO close_channel:
success:
  LOCATE 2,4
  PRINT "Using calibrated values."
  SLEEP FOR 2
close_channel:
  CLOSE #1
  CLS
  LOCATE 2,10
  PRINT "Waiting...."

REM This is the main loop.
main_loop:

REM The critical timer for the games port.
ASSEM

  movem.l        d0-d7/a0-a6,-(sp)  ;Save all registers just in case...
  lea.l          $0,a0              ;Use ~RESET SSP~ for my variable.
                                    ;Who cares about ~ENFORCER HITS~ with
                                    ;a bog standard A1200.
  movea.l        $4,a6              ;Set the ~EXEC~ pointer.
  jsr            -132(a6)           ;Disable interrupts...
  jsr            -120(a6)           ;and tasking.
  move.l         #$0,d0             ;Clear ~d0~ for use.
  move.l         #$0,d1             ;Clear ~d1~ for use.
  move.l         d0,(a0)            ;Empty ~RESET SSP~ for use.
  move.b         d0,$bfd800         ;Clear ~todlo~ and
  move.b         d0,$bfda00         ;clear ~todhi~ and
  move.b         d0,$bfd800         ;ensure ~todlo~ is still clear and
  move.b         d0,$bfd900         ;clear ~todmid~ and
counter_wait1:
  move.b         d0,$bfd800         ;clear ~todlo~ again.
  cmpi.b         #$0,$bfd800        ;Ensure ~todlo~ = 0.
  bne            counter_wait1      ;If NOT then wait until it is...
counter_loop1:
ones_loop1:
  move.b         $bfe001,d1         ;Start with a ~MARK~ of a 50% duty cycle
                                    ;square wave.
  btst           #6,d1              ;Help let me out if I am hung up...
  beq            mouse_exit         ;Just left mouse click.
  btst           #7,d1              ;Check for a ~SPACE~ of a 50% duty cycle
                                    ;square wave. When ~SPACE~ comes exit.
  bne            ones_loop1
zeros_loop1:
  move.b         $bfe001,d1         ;Continue with a ~SPACE~ of a 50% duty
                                    ;cycle square wave.
  btst           #6,d1              ;Help let me out if I am hung up...
  beq            mouse_exit         ;Just left mouse click.
  btst           #7,d1              ;Check for a ~MARK~ of a 50% duty cycle
                                    ;square wave. When ~MARK~ comes exit.
  beq            zeros_loop1
  add.l          #1,d0              ;Increase counter by ~1 CYCLE~.
  move.b         $bfd900,d1         ;Use ~todmid~ as the
  cmpi.b         #$3e,d1            ;coarse timer value...
  bne            counter_loop1
  move.l         d0,(a0)            ;Save my count to location ~0~.
mouse_exit:
  movea.l        $4,a6              ;Set the ~EXEC~ pointer again.
  jsr            -126(a6)           ;Enable tasking...
  jsr            -138(a6)           ;and interrupts.
  movem.l        (sp)+,d0-d7/a0-a6  ;Reload the registers.

  EVEN

END ASSEM

REM Screen display readout.
  LET frequency=PEEKL(0)
  IF frequency>=100 THEN LET correction=INT(frequency/lfcorrect)
  IF frequency>=1000 THEN LET correction=INT(frequency/mfcorrect)
  IF frequency>=10000 THEN LET correction=INT(frequency/hfcorrect)
  LET freq=frequency+correction
  LOCATE 2,9
  COLOR 1,0
  PRINT freq;CHR$(8);
  COLOR 2,0
  PRINT "00";
  COLOR 1,0
  PRINT " Hz.       "
  IF MOUSE(0)=-1 THEN GOTO keyboard_hold:
  GOTO main_loop:

REM The ~Quit~ and ~Calibrate~ window.
keyboard_hold:
  FONT "topaz.font",8
  CLS
  LOCATE 2,19
  PRINT b$
  LOCATE 4,10
  PRINT "~Q~ or ~q~ = Quit the frequency counter.
  LOCATE 5,8
  PRINT "~C~ or ~c~ = Calibrate the frequency counter."
  LOCATE 6,3
  PRINT "~Space Bar~ or ~RETURN/ENTER~ = Return back to counter." 
keyboard_hold1:
  LET a$=INKEY$
  IF a$="c" OR a$="C" THEN LET calibrate=1
  IF a$="q" OR a$="Q" THEN GOTO getout:
  IF a$=" " OR a$=CHR$(13) THEN GOTO reset_screen:
  IF calibrate=1 THEN GOTO calibration:
  GOTO keyboard_hold1:

REM Set the window to dispaly large fonts.
reset_screen:
  FONT "topaz.font",16
  CLS
  LOCATE 2,10
  PRINT "Waiting...."
  LET calibrate=0
  GOTO main_loop:

REM This is the ~Calibration~ window.
calibration:
  FONT "topaz.font",8
  CLS
calibration1:
  LET a$=INKEY$
  IF a$="h" THEN LET hfcorrect=hfcorrect+1
  IF hfcorrect>=65500 THEN LET hfcorrect=65500
  IF a$="H" THEN LET hfcorrect=hfcorrect-1
  IF hfcorrect<=10 THEN LET hfcorrect=10
  IF a$="m" THEN LET mfcorrect=mfcorrect+1
  IF mfcorrect>=65500 THEN LET mfcorrect=65500
  IF a$="M" THEN LET mfcorrect=mfcorrect-1
  IF mfcorrect<=10 THEN LET mfcorrect=10
  IF a$="l" THEN LET lfcorrect=lfcorrect+1
  IF lfcorrect>=65500 THEN LET lfcorrect=65500
  IF a$="L" THEN LET lfcorrect=lfcorrect-1
  IF lfcorrect<=10 THEN LET lfcorrect=10
  LOCATE 1,19
  PRINT b$
  LOCATE 3,13
  PRINT "~H~ or ~h~ = HF fine tuning:-";hfcorrect;CHR$(8);".     "
  LOCATE 4,13
  PRINT "~M~ or ~m~ = MF fine tuning:-";mfcorrect;CHR$(8);".     "
  LOCATE 5,13
  PRINT "~L~ or ~l~ = LF fine tuning:-";lfcorrect;CHR$(8);".     "
  LOCATE 6,9
  PRINT "~W~ or ~w~ = Write/save calibration values."
  LOCATE 7,3
  PRINT "~Space Bar~ or ~RETURN/ENTER~ = Return back to counter."
  IF a$=" " OR a$=CHR$(13) THEN GOTO reset_screen:
  IF a$="w" OR a$="W" THEN GOTO write_calibrate:
  GOTO calibration1:

REM Save any user calibrated values.
write_calibrate:
  OPEN "O", #1, "Calibration"
  WRITE #1, b$, hfcorrect, mfcorrect, lfcorrect
  CLOSE #1
  GOTO reset_screen:

REM Exit routine.
REM Close all open channels in reverse order and reset to standard font.
getout:
  POKE 0,value0
  FONT "topaz.font",8
  WINDOW CLOSE 1
  END
