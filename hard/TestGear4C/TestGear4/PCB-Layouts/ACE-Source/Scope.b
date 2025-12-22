REM Digital Storage Oscilloscope Software.

REM Open up the parallel port for 8 bit data line reading.
REM Some parts of this routine are NOT required, but have
REM been left in for future use. Note that this is proven.
ASSEM
main_assembler_program:
_LVOOpenResource:       equ   -$1F2
_LVOFreeSignal:         equ   -$150
_LVOAllocSignal:        equ   -$14A
_LVOSignal:             equ   -$144
_ThisTask:              equ   $114
_SysBase:               equ   4
ciab_ddra:              equ   $BFD200
ciaa_ddrb:              equ   $BFE301
_LVOSetICR:             equ   -24
_LVORemICRVector:       equ   -12
_LVOAddICRVector:       equ   -6
_LVOAbleICR:            equ   -18
CIAICRB_FLG:            equ   4
CIAICRF_FLG:            equ   16
_LVOGetMiscResource:    equ   -6
_LVOFreeMiscResource:   equ   -12
MR_PARALLELPORT:        equ   2
MR_PARALLELBITS:        equ   0

      lea        CIAAName,a1
      moveq      #0,d0
      movea.l    _SysBase,a6
      jsr        _LVOOpenResource(a6)
      move.l     d0,_CIAAResource
      bne        ociaa
      moveq      #10,d0
      rts
ociaa:
      lea        MiscName,a1
      moveq      #0,d0
      jsr        _LVOOpenResource(a6)
      move.l     d0,_MiscResource
      bne        omisc
      moveq      #20,d0
      rts
omisc:
      lea        Name,a1
      moveq      #MR_PARALLELPORT,d0
      movea.l    _MiscResource,a6
      jsr        _LVOGetMiscResource(a6)
      move.l     d0,d1
      beq        port
      moveq      #30,d0
      rts
port:
      lea        Name,a1
      moveq      #MR_PARALLELBITS,d0
      jsr        _LVOGetMiscResource(a6)
      move.l     d0,d1
      beq        bits
      moveq      #40,d2
      bra        Free1
bits:
      moveq      #-1,d0
      movea.l    _SysBase,a6
      jsr        _LVOAllocSignal(a6)
      move.b     d0,d7
      bpl        mask
      moveq      #50,d2
      bra        Free2
mask:
      moveq      #0,d1
      Bset.l     d0,d1
      move.l     d1,SigMask
      lea        CIAAInterrupt,a1
      moveq      #CIAICRB_FLG,d0
      movea.l    _CIAAResource,a6
      jsr        _LVOAddICRVector(a6)
      move.l     d0,d1
      beq        hand
      moveq      #50,d2
      bra        Free3
hand:
      moveq      #CIAICRF_FLG,d0
      jsr        _LVOAbleICR(a6)
      move.b     #$0,ciaa_ddrb
      andi.b     #$F8,ciab_ddra
      moveq      #CIAICRF_FLG,d0
      jsr        _LVOSetICR(a6)
      moveq      #0,d0
      move.b     #144,d0
      jsr        _LVOAbleICR(a6)
      jsr        SETSCREEN
      nop
Free5:
      moveq      #0,d2
      moveq      #16,d0
      movea.l    _CIAAResource,a6
      jsr        _LVOAbleICR(a6)
Free4:
      lea        CIAAInterrupt,a1
      moveq      #4,d0
      movea.l    _CIAAResource,a6
      jsr        _LVORemICRVector(a6)
Free3:
      move.b     d7,d0
      movea.l    _SysBase,a6
      jsr        _LVOFreeSignal(a6)
Free2:
      moveq      #MR_PARALLELBITS,d0
      movea.l    _MiscResource,a6
      jsr        _LVOFreeMiscResource(a6)
Free1:
      moveq      #MR_PARALLELPORT,d0
      movea.l    _MiscResource,a6
      jsr        _LVOFreeMiscResource(a6)
      move.l     d2,d0
      bra        leave_program
CIAARoutine:
      move.l     a1,d0
      movea.l    _ThisTask,a1
      movea.l    _SysBase,a6
      jsr        _LVOSignal(a6)
      moveq      #0,d0
      rts
_CIAAResource:
      dc.l       0
_MiscResource:
      dc.l       0
CIAAInterrupt:
      dc.l       0,0
      dc.b       2,0
      dc.l       Name
SigMask:
      dc.l       0
      dc.l       CIAARoutine
IntuitionName:
      dc.b       "intuition.library",0
CIAAName:
      dc.b       "ciaa.resource",0
MiscName:
      dc.b       "misc.resource",0
Name:
      dc.b       "(C) B.Walker, (G0LCU).",0

  EVEN

leave_program:
      nop

END ASSEM

  GOTO getout:


REM Open up the Oscilloscope screen.
REM OK.
setscreen:
  SCREEN 1,320,200,5,1
REM Set the SCREEN to all black.
  GOSUB clear_palette:
  WINDOW 1,,(0,0)-(320,200),32,1
REM Change these lines on completion if required.
  FONT "TestGear.font",8

REM Set the WINDOW to all black for ~Scope.iff~ image import.
  GOSUB clear_palette:
  CLS
REM Import the ~Scope.iff~ image.
REM change this line on completion if required.
  IFF OPEN #1,"Scope.iff"
  IF ERR<>0 THEN GOTO error_exit:
  IFF READ #1,1
  IFF CLOSE #1
REM This ensures the palette registers are set correctly.
  GOSUB set_palette:
  SLEEP FOR 1

REM Check all variables are set.
REM Set up variables here.
  LET address&=ALLOC(65536,3)
  LET waveform_address&=address&+160
  LET a$=" (C)2001 B.Walker,(G0LCU). "
  LET b$="                           "
  LET c$="Oscilloscope Calibration Parameters. (C)2001 B.Walker, G0LCU."
  LET input_mode$=",AC."
  LET input_sensitivity$="Y=30V/Div"
  LET timebase_speed$="X=100uS/Div."
  LET status$=input_sensitivity$+input_mode$+timebase_speed$
  LET n=0
  LET graticule=1
  LET brightness=3
  LET shift=90
  LET waveform=0
  LET supplies=0
  LET multiplier=1
  LET single_shot=1
  LET sync=160
  LET retrace=1
  LET timebase_calibrate=1
  LET timebase_range=6
  LET slow_range_delay=1
  LET range1=410
  LET range2=45
  LET range3=5
  LET range4=108
  LET range5=11
  LET range6=1
  LET xtb=221
  LET oldxtb=xtb
  LET ytb=131
  LET oldytb=ytb
  LET xvolts=279
  LET yvolts=52
  LET oldxvolts=xvolts
  LET oldyvolts=yvolts
  LET xmode=221
  LET ymode=75
  LET oldxmode=xmode
  LET oldymode=ymode
REM The address for I/O control lines = $BFD200, 12571136.
REM The address for writing to these lines = $BFD000, 12570624.
REM The address for reading the 8 data lines = $BFE101, 12574977.
  LET control=PEEK(12571136)
  LET control_value=PEEK(12570624)

REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set up the AC/DC relay to AC mode.
  POKE 12570624,0
REM Reset the vertical range to the DEFAULT 30V/DIV.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to the DEFAULT 30V/DIV.
  POKE 12570624,0
REM The defaults are Y=30V/Div,AC.X=100uS/Div.

REM Import the calibrated values.
  OPEN "I", #1, "Calibration"
  IF ERR<>0 THEN GOTO failure:
  INPUT #1, c$,range1,range2,range3,range4,range5,range6,sync,brightness,single_shot,multiplier,graticule,shift
  GOTO success:
failure:
  LET status$="Using default values."
  GOSUB status_window:
  SLEEP FOR 1
  GOTO close_channel:
success:
  LET status$="Using user preferences."
  GOSUB status_window:
  SLEEP FOR 1
close_channel:
  CLOSE #1
REM Go immediately to scan a trace.
  GOTO aquire_trace:

REM This is the vertical range loop.
main_volts_loop:
  LET status$="Set vertical sensitivity."
  GOSUB status_window:
REM This generates my personalised buttons on the ~Scope~ screen.
  LET oldxvolts=xvolts
  LET oldyvolts=yvolts
vert_buttons:
  LET xvolts=MOUSE(1)
  IF xvolts>=192 AND xvolts<221 THEN LET xvolts=192
  IF xvolts>=221 AND xvolts<250 THEN LET xvolts=221
  IF xvolts>=250 AND xvolts<279 THEN LET xvolts=250
  IF xvolts>=279 AND xvolts<303 THEN LET xvolts=279
  LET yvolts=MOUSE(2)
  IF yvolts>=29 AND yvolts<52 THEN LET yvolts=29
  IF yvolts>=52 AND yvolts<70 THEN LET yvolts=52
  IF xvolts<192 OR xvolts>279 OR yvolts<29 OR yvolts>52 THEN GOTO vert_buttons:
  IF MOUSE(0)=-1 THEN GOTO draw_vert_buttons:
GOTO vert_buttons:
draw_vert_buttons:
REM Disable old button.
  LINE (oldxvolts,oldyvolts)-((oldxvolts+23),oldyvolts),5
  LINE ((oldxvolts+23),oldyvolts)-((oldxvolts+23),(oldyvolts+17)),7
  LINE ((oldxvolts+23),(oldyvolts+17))-(oldxvolts,(oldyvolts+17)),7
  LINE (oldxvolts,(oldyvolts+17))-(oldxvolts,oldyvolts),5
REM Enable new button.
  LINE (xvolts,yvolts)-((xvolts+23),yvolts),7
  LINE ((xvolts+23),yvolts)-((xvolts+23),(yvolts+17)),5
  LINE ((xvolts+23),(yvolts+17))-(xvolts,(yvolts+17)),5
  LINE (xvolts,(yvolts+17))-(xvolts,yvolts),7
  IF xvolts=279 AND yvolts=29 THEN GOTO vert1:
  IF xvolts=250 AND yvolts=29 THEN GOTO vert2:
  IF xvolts=221 AND yvolts=29 THEN GOTO vert3:
  IF xvolts=192 AND yvolts=29 THEN GOTO vert4:
  IF xvolts=279 AND yvolts=52 THEN GOTO vert5:
  IF xvolts=250 AND yvolts=52 THEN GOTO vert6:
  IF xvolts=221 AND yvolts=52 THEN GOTO vert7:
  IF xvolts=192 AND yvolts=52 THEN GOTO vert8:
  GOTO main_volts_loop:

vert1:
  LET input_sensitivity$="Y=300mV/Div"
REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set the vertical mode to AC.
  POKE 12570624,0
REM Reset the vertical range to 30V/DIV,AC.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to 300mV/DIV,AC.
  FOR n=0 TO 3
  POKE 12570624,2
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
  NEXT n
  POKE 12570624,0
  GOTO main_mode_loop:

vert2:
  LET input_sensitivity$="Y=100mV/Div"
REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set the vertical mode to AC.
  POKE 12570624,0
REM Reset the vertical range 30V/DIV,AC.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to 100mV/DIV,AC.
  FOR n=0 TO 4
  POKE 12570624,2
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
  NEXT n
  POKE 12570624,0
  GOTO main_mode_loop:

vert3:
  LET input_sensitivity$="Y=30mV/Div"
REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set the vertical mode to AC.
  POKE 12570624,0
REM Reset the vertical range to 30V/DIV,AC.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to 30mV/DIV,AC
  FOR n=0 TO 5
  POKE 12570624,2
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
  NEXT n
  POKE 12570624,0
  GOTO main_mode_loop:

vert4:
  LET input_sensitivity$="Y=10mV/Div"
REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set the vertical mode to AC.
  POKE 12570624,0
REM Reset the vertical range 30V/DIV,AC.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to 10mV/DIV,AC.
  FOR n=0 TO 6
  POKE 12570624,2
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
  NEXT n
  POKE 12570624,0
  GOTO main_mode_loop:

vert5:
  LET input_sensitivity$="Y=30V/Div"
REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set the vertical mode to AC.
  POKE 12570624,0
REM Set the vertical range to 30V/DIV,AC.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to 30V/DIV,AC.
  POKE 12570624,0
  GOTO main_mode_loop:

vert6:
  LET input_sensitivity$="Y=10V/Div"
REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set the vertical mode to AC.
  POKE 12570624,0
REM Reset the vertical range to 30V/DIV,AC.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to 10V/DIV,AC.
  POKE 12570624,2
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
  POKE 12570624,0
  GOTO main_mode_loop:

vert7:
  LET input_sensitivity$="Y=3V/Div"
REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set the vertical mode to AC.
  POKE 12570624,0
REM Reset the vertical range to 30V/DIV,AC.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to 3V/DIV,AC.
  FOR n=0 TO 1
  POKE 12570624,2
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
  NEXT n
  POKE 12570624,0
  GOTO main_mode_loop:

vert8:
  LET input_sensitivity$="Y=1V/Div"
REM Set /SEL, POUT and BUSY to outputs.
  POKE 12571136,7
REM Set the vertical mode to AC.
  POKE 12570624,0
REM Reset the vertical range 30V/DIV,AC.
  POKE 12570624,4
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
REM Set the vertical range to 1V/DIV,AC.
  FOR n=0 TO 2
  POKE 12570624,2
  SLEEP FOR 0.05
  POKE 12570624,0
  SLEEP FOR 0.05
  NEXT n
  POKE 12570624,0
REM GOTO main_mode_loop:

REM This is the mode loop.
main_mode_loop:
  LET status$="Set vertical mode."
  GOSUB status_window:
REM This generates my personalised buttons on the ~Scope~ screen.
  LET oldxmode=xmode
  LET oldymode=ymode
mode_buttons:
  LET xmode=MOUSE(1)
  IF xmode>=192 AND xmode<221 THEN LET xmode=192
  IF xmode>=221 AND xmode<245 THEN LET xmode=221
  LET ymode=MOUSE(2)
  IF ymode>=75 AND ymode<93 THEN LET ymode=75
  IF xmode<192 OR xmode>221 OR ymode<75 OR ymode>75 THEN GOTO mode_buttons:
  IF MOUSE(0)=-1 THEN GOTO draw_mode_buttons:
  GOTO mode_buttons:
draw_mode_buttons:
REM Disable old button.
  LINE (oldxmode,oldymode)-((oldxmode+23),oldymode),5
  LINE ((oldxmode+23),oldymode)-((oldxmode+23),(oldymode+17)),7
  LINE ((oldxmode+23),(oldymode+17))-(oldxmode,(oldymode+17)),7
  LINE (oldxmode,(oldymode+17))-(oldxmode,oldymode),5
REM Enable new button.
  LINE (xmode,ymode)-((xmode+23),ymode),7
  LINE ((xmode+23),ymode)-((xmode+23),(ymode+17)),5
  LINE ((xmode+23),(ymode+17))-(xmode,(ymode+17)),5
  LINE (xmode,(ymode+17))-(xmode,ymode),7
  IF xmode=192 AND ymode=75 THEN GOTO dc_mode:
  IF xmode=221 AND ymode=75 THEN GOTO ac_mode:
  GOTO main_mode_loop:

REM Change the modes.
ac_mode:
  POKE 12571136,7
  POKE 12570624,0
  LET input_mode$=",AC."
  GOTO mode_exit:
dc_mode:
  POKE 12571136,7
  POKE 12570624,1
  LET input_mode$=",DC."
mode_exit:
  LET status$="Set horizontal mode."
  GOSUB status_window:
  GOTO main_loop1:

REM This is the main loop.
REM OK.
main_loop:
  LET status$=input_sensitivity$+input_mode$+timebase_speed$
  GOSUB status_window:
REM This generates my personalised buttons on the ~Scope~ screen.
REM These are the only buttons available after any scan that has STOPPED.
main_loop1:
  LET oldxtb=xtb
  LET oldytb=ytb
tb_buttons:
  LET xtb=MOUSE(1)
  IF xtb>=192 AND xtb<221 THEN LET xtb=192
  IF xtb>=221 AND xtb<250 THEN LET xtb=221
  IF xtb>=250 AND xtb<279 THEN LET xtb=250
  IF xtb>=279 AND xtb<303 THEN LET xtb=279
  LET ytb=MOUSE(2)
  IF ytb>=108 AND ytb<131 THEN LET ytb=108
  IF ytb>=131 AND ytb<149 THEN LET ytb=131
  IF xtb<192 OR xtb>279 OR ytb<108 OR ytb>131 THEN GOTO tb_buttons:
  IF MOUSE(0)=-1 THEN GOTO draw_tb_buttons:
GOTO tb_buttons:
draw_tb_buttons:
REM Disable old button.
  LINE (oldxtb,oldytb)-((oldxtb+23),oldytb),5
  LINE ((oldxtb+23),oldytb)-((oldxtb+23),(oldytb+17)),7
  LINE ((oldxtb+23),(oldytb+17))-(oldxtb,(oldytb+17)),7
  LINE (oldxtb,(oldytb+17))-(oldxtb,oldytb),5
REM Enable new button.
  LINE (xtb,ytb)-((xtb+23),ytb),7
  LINE ((xtb+23),ytb)-((xtb+23),(ytb+17)),5
  LINE ((xtb+23),(ytb+17))-(xtb,(ytb+17)),5
  LINE (xtb,(ytb+17))-(xtb,ytb),7
  IF xtb=279 AND ytb=131 THEN GOTO main_volts_loop:
  IF xtb=250 AND ytb=131 THEN GOTO keyboard:
  IF xtb=221 AND ytb=131 THEN GOTO range6:
  IF xtb=192 AND ytb=131 THEN GOTO range5:
  IF xtb=279 AND ytb=108 THEN GOTO range4:
  IF xtb=250 AND ytb=108 THEN GOTO range3:
  IF xtb=221 AND ytb=108 THEN GOTO range2:
  IF xtb=192 AND ytb=108 THEN GOTO range1:
  GOTO main_loop1:

REM Cleanup and exit routine.
REM OK.
REM This is required if ~Scope.iff~ is missing.
error_exit:
  IFF CLOSE #1
  GOTO cleanup_code1:
REM These are required to reset the parallel port to the bootup state.
cleanup_code:
  POKE 12570624,control_value
  POKE 12571136,control
REM This is the usual cleanup routine.
cleanup_code1:
  CLEAR ALLOC
  WINDOW CLOSE 1
  SCREEN CLOSE 1
REM A return from subroutine IS required to EXIT the initial assembler.
ASSEM
      rts
END ASSEM
REM Final closedown to WorkBench or the CLI.
getout:
  END
REM This is the end of the program.
REM -------------------------------


REM These are the subroutines.
REM --------------------------

REM Clear trace window and draw the division lines.
REM OK.
clear_window:
  COLOR 2,2
  FOR n=14 TO 173
  LINE (n,26)-(n,152)
  NEXT n
  COLOR brightness,2
  RETURN
set_graticule:
  COLOR 21,2
  FOR n=33 TO 153 STEP 20
  LINE (n,26)-(n,152)
  NEXT n
  FOR n=42 TO 138 STEP 16
  LINE (14,n)-(173,n)
  NEXT n
  COLOR brightness,2
  RETURN

REM Clear palette registers, this sets them all to black.
REM OK.
clear_palette:
  FOR n=0 TO 31
  PALETTE n,0,0,0
  NEXT n
  RETURN

REM Set the palette registers, this ensures the correct colours.
REM OK.
set_palette:
  PALETTE 0,0,0,0
  PALETTE 1,0,0,0
  PALETTE 2,0,0.34,0.34
  PALETTE 3,0,0.67,0.67
  PALETTE 4,0.267,0.133,0
  PALETTE 5,1,0.867,0.734
  PALETTE 6,0.867,0.734,0.6
  PALETTE 7,0.734,0.6,0.467
  PALETTE 8,0.6,0.467,0.333
  PALETTE 9,0.467,0.333,0.2
  PALETTE 10,1,0,0
  PALETTE 11,0,1,0
  PALETTE 12,0,0,1
  PALETTE 13,0,1,1
  PALETTE 14,1,0,1
  PALETTE 15,1,1,0
  PALETTE 16,0,0,0
  PALETTE 17,0.07,0.07,0.07
  PALETTE 18,0.14,0.14,0.14
  PALETTE 19,0.2,0.2,0.2
  PALETTE 20,0.27,0.27,0.27
  PALETTE 21,0.34,0.34,0.34
  PALETTE 22,0.4,0.4,0.4
  PALETTE 23,0.47,0.47,0.47
  PALETTE 24,0.54,0.54,0.54
  PALETTE 25,0.6,0.6,0.6
  PALETTE 26,0.67,0.67,0.67
  PALETTE 27,0.74,0.74,0.74
  PALETTE 28,0.8,0.8,0.8
  PALETTE 29,0.87,0.87,0.87
  PALETTE 30,0.94,0.94,0.94
  PALETTE 31,1,1,1
  RETURN

REM Print the status Window.
REM OK.
status_window:
  COLOR 0,7
  LOCATE 22,3
  PRINT b$
  LOCATE 22,3
  PRINT status$
  COLOR brightness,2
  RETURN

REM This is the keyboard control subroutine.
REM OK.
keyboard:
  LET status$="Keyboard, ~Esc~ to exit."
  GOSUB status_window:
  GOTO parameters:
keyboard1:
  LET status$="Press h, H or ? for HELP."
  GOSUB status_window:

keyboard_controls:
  LET a$=INKEY$
REM The next 7 lines are for insurance only.
  IF shift<=62 THEN LET shift=62
  IF shift>=118 THEN LET shift=118
  IF multiplier=2 THEN LET shift=90
  IF timebase_calibrate<=1 THEN LET timebase_calibrate=1
  IF timebase_calibrate>=500 THEN LET timebase_calibrate=500
  IF sync<=1 THEN LET sync=1
  IF sync>=1600 THEN LET sync=1600
REM The above 7 lines can be removed if required.
  IF a$=CHR$(27) THEN GOTO mode_exit:
  IF a$=CHR$(13) THEN GOTO parameters:
  IF a$=" " OR a$="q" OR a$="Q" THEN GOTO cleanup_code:
  IF a$="a" OR a$="A" THEN GOTO aquire_trace:
  IF a$="b" THEN GOTO normal_brightness:
  IF a$="B" THEN GOTO high_brightness:
  IF a$="c" THEN GOSUB timebase_speed_down:
  IF a$="C" THEN GOSUB timebase_speed_up:
  IF a$="1" THEN LET range1=timebase_calibrate
  IF a$="2" THEN LET range2=timebase_calibrate
  IF a$="3" THEN LET range3=timebase_calibrate
  IF a$="4" THEN LET range4=timebase_calibrate
  IF a$="5" THEN LET range5=timebase_calibrate
  IF a$="6" THEN LET range6=timebase_calibrate
  IF a$="?" OR a$="h" OR a$="H" THEN GOTO help_file:
  IF a$="d" THEN GOTO main_volts_loop:
  IF a$="D" THEN GOTO main_mode_loop:
  IF a$="r" OR a$="R" THEN GOTO retrace:
  IF a$="t" THEN GOSUB set_sync_up:
  IF a$="T" THEN GOSUB set_sync_down:
  IF a$="v" THEN GOSUB shift_up:
  IF a$="V" THEN GOSUB shift_down:
  IF a$="m" THEN GOTO multiplier_off:
  IF a$="M" THEN GOTO multiplier_on:
  IF a$="s" THEN GOTO single_shot_off:
  IF a$="S" THEN GOTO single_shot_on:
  IF a$="g" THEN GOTO graticule_on:
  IF a$="G" THEN GOTO graticule_off:
  IF a$="w" OR a$="W" THEN GOTO write_calibrate:
  GOTO keyboard_controls:

REM This rescans the memory store ONLY and does NOT access the parallel port.
retrace:
  IF retrace=0 THEN GOTO keyboard_controls:
  LET status$="Retrace only."
  GOSUB status_window:
  LET waveform_address&=address&+sync
  GOTO rescan:

REM This is the built in help file. The battery status can be checked
REM at this point and if either or both are flat then the help file
REM will let you know.
help_file:
  GOSUB clear_window:
  COLOR 13,2
REM Check batteries here.
  LET supplies=PEEK(12574977)
  IF supplies>=192 THEN GOTO both_batteries:
  IF supplies>=128 THEN GOTO battery2:
  IF supplies>=64 THEN GOTO battery1:
  IF supplies<=63 THEN GOTO help_list:
both_batteries:
  LOCATE 12,4
  PRINT "BOTH BATTERIES EXHAUSTED."
  GOSUB help_key_hold:
  GOTO help_list:
battery1:
  LOCATE 12,4
  PRINT "POSITIVE RAIL EXHAUSTED."
  GOSUB help_key_hold:
  GOTO help_list:
battery2:
  LOCATE 12,4
  PRINT "NEGATIVE RAIL EXHAUSTED."
  GOSUB help_key_hold:
help_list:
  GOSUB clear_window:
  COLOR 13,2
  LOCATE 5,8
  PRINT "KEYBOARD COMMANDS."
  LOCATE 6,8
  PRINT "------------------"
  COLOR 3,2
  LOCATE 7,4
  PRINT "Esc... to return to Scan."
  LOCATE 8,4
  PRINT "q, Q or Space... to Quit."
  LOCATE 9,4
  PRINT "a or A.. to Aquire trace."
  LOCATE 10,4
  PRINT "b..... Normal brightness."
  LOCATE 11,4
  PRINT "B....... High brightness."
  LOCATE 12,4
  PRINT "c.... Slow dowm timebase."
  LOCATE 13,4
  PRINT "C..... Speed up timebase."
  LOCATE 14,4
  PRINT "?, h or H..... this Help."
  LOCATE 15,4
  PRINT "v........ shift trace Up."
  LOCATE 16,4
  PRINT "V...... shift trace Down."
  LOCATE 17,4
  PRINT "m..... x2 multiplier Off."
  LOCATE 18,4
  PRINT "M...... x2 multiplier On."
  LOCATE 19,4
  PRINT "d..... set vertical Gain."
  GOSUB help_key_hold:
  COLOR 13,2
  LOCATE 5,5
  PRINT "MORE KEYBOARD COMMANDS."
  LOCATE 6,5
  PRINT "-----------------------"
  COLOR 3,2
  LOCATE 7,4
  PRINT "D..... set vertical Mode."
  LOCATE 8,4
  PRINT "g...... set garticule On."
  LOCATE 9,4
  PRINT "G..... set graticule Off."
  LOCATE 10,4
  PRINT "s....... single shot Off."
  LOCATE 11,4
  PRINT "S........ single shot On."
  LOCATE 12,4
  PRINT "r or R....... to Retrace."
  LOCATE 13,4
  PRINT "t... Increase sync point."
  LOCATE 14,4
  PRINT "T... Decrease sync point."
  LOCATE 15,4
  PRINT "ENTER... show Parameters."
  COLOR 0,2
  LOCATE 16,4 
  PRINT "1, 2, 3, 4, 5, 6, W and w"
  LOCATE 17,4
  PRINT "see  main text  for these"
  LOCATE 18,4
  PRINT "commands as they  are for"
  LOCATE 19,4
  PRINT "calibration   use   only."
  GOSUB help_key_hold:
  COLOR 13,2
  LOCATE 5,7
  PRINT "GENERAL MOUSE USAGE."
  LOCATE 6,7
  PRINT "--------------------"
  COLOR 3,2
  LOCATE 7,4
  PRINT "Only  the   bottom  eight"
  LOCATE 8,4
  PRINT "buttons   are   available"
  LOCATE 9,4
  PRINT "from the program startup."
  LOCATE 10,4
  PRINT "SLOW,  1S,  100mS,  10mS,"
  LOCATE 11,4
  PRINT "1mS, 100uS,  KB and VERT."
  LOCATE 13,4
  PRINT "Click on ~KB~ to put into"
  LOCATE 14,4
  PRINT "keyboard  ~COMMAND~ mode."
  LOCATE 15,4
  PRINT "Click on ~VERT~ to set up"
  LOCATE 16,4
  PRINT "the  vertical sensitivity"
  LOCATE 17,4
  PRINT "and vertical  AC/DC mode."
  COLOR 13,2
  LOCATE 19,4
  PRINT "(C)2001 B.Walker,(G0LCU)."
  GOTO keyboard1:
REM Press the ENTER key to return from subroutine.
help_key_hold:
  LET status$="Press ENTER to continue."
  GOSUB status_window:
help_key:
  LET a$=INKEY$
  IF a$=CHR$(13) THEN GOTO help_exit:
  GOTO help_key:
help_exit:
  GOSUB clear_window:
  RETURN

REM This is the Calibrate save routine.
write_calibrate:
  OPEN "O", #1, "Calibration"
  WRITE #1, c$,range1,range2,range3,range4,range5,range6,sync,brightness,single_shot,multiplier,graticule,shift
  CLOSE #1
  GOTO wait_one_second:

REM These are the timebase range routines.
REM OK.
range1:
  LET retrace=0
  LET single_shot=1
  LET timebase_range=1
  LET timebase_speed$="X=SLOW."
  LET timebase_calibrate=range1
  LET status$=input_sensitivity$+input_mode$+timebase_speed$
  GOSUB status_window:
  GOTO aquire_trace:
REM OK.
range2:
  LET retrace=0
  LET single_shot=1
  LET timebase_range=2
  LET timebase_speed$="X=1S/Div."
  LET timebase_calibrate=range2
  LET status$=input_sensitivity$+input_mode$+timebase_speed$
  GOSUB status_window:  
  GOTO aquire_trace:
REM OK.
range3:
  LET retrace=0
  LET timebase_range=3
  LET timebase_speed$="X=100mS/Div."
  LET timebase_calibrate=range3
  LET status$=input_sensitivity$+input_mode$+timebase_speed$
  GOSUB status_window:  
  GOTO aquire_trace:
REM OK.
range4:
  LET retrace=1
  LET timebase_range=4
  LET timebase_speed$="X=10mS/Div."
  LET timebase_calibrate=range4
  LET status$=input_sensitivity$+input_mode$+timebase_speed$
  GOSUB status_window:  
  GOTO aquire_trace:
REM OK.
range5:
  LET retrace=1
  LET timebase_range=5
  LET timebase_speed$="X=1mS/Div."
  LET timebase_calibrate=range5
  LET status$=input_sensitivity$+input_mode$+timebase_speed$
  GOSUB status_window:  
  GOTO aquire_trace:
REM OK.
range6:
  LET retrace=1
  LET timebase_range=6
  LET timebase_speed$="X=100uS/Div."
  LET timebase_calibrate=range6
  LET status$=input_sensitivity$+input_mode$+timebase_speed$
  GOSUB status_window:  
  GOTO aquire_trace:

REM These are the retrace sync routines.
REM OK
set_sync_up:
  LET sync=sync+1
  IF sync>=1600 THEN LET sync=1600
  LET status$="Sync position"+STR$(sync)+". "
  GOSUB status_window:
  RETURN
REM OK
set_sync_down:
  LET sync=sync-1
  IF sync<=1 THEN LET sync=1
  LET status$="Sync position"+STR$(sync)+". "
  GOSUB status_window:
  RETURN

REM These are the brightness routines.
REM OK.
normal_brightness:
  LET brightness=3
  LET status$="Normal display."
  GOSUB status_window:
  GOTO wait_one_second:
REM OK.
high_brightness:
  LET brightness=13
  LET status$="Bright display."
  GOSUB status_window:
  GOTO wait_one_second:

REM These are the scanning mode routines.
REM OK.
single_shot_on:
  LET single_shot=1
  LET status$="Single shot enabled."
  GOSUB status_window:
  GOTO wait_one_second:
REM OK.
single_shot_off:
  LET single_shot=0
  LET status$="Single shot disabled."
  GOSUB status_window:
  GOTO wait_one_second:

REM These are the vertical multiplier routines.
REM OK.
multiplier_off:
  LET multiplier=1
  LET status$="Normal scan height."
  GOSUB status_window:
  GOTO wait_one_second::
REM OK.
multiplier_on:
  LET multiplier=2
  IF multiplier=2 THEN LET shift=90
  LET status$="Double scan height."
  GOSUB status_window:
  GOTO wait_one_second:

REM These are the graticule ON/OFF routines.
REM OK.
graticule_on:
  LET graticule=1
  LET status$="Graticule enabled."
  GOSUB status_window:
  GOTO wait_one_second:
REM OK.
graticule_off:
  LET graticule=0
  LET status$="Graticule disabled."
  GOSUB status_window:
wait_one_second:
  SLEEP FOR 1
  GOTO keyboard1:

REM These are the variable timebase routines.
REM OK.
timebase_speed_up:
  LET timebase_calibrate=timebase_calibrate-1
  IF timebase_calibrate<=1 THEN LET timebase_calibrate=1
  LET status$="Speed up timebase"+STR$(timebase_calibrate)+". "
  GOSUB status_window:
  RETURN
REM OK.
timebase_speed_down:
  LET timebase_calibrate=timebase_calibrate+1
  IF timebase_calibrate>=500 THEN LET timebase_calibrate=500
  LET status$="Slow down timebase"+STR$(timebase_calibrate)+". "
  GOSUB status_window:
  RETURN

REM These are the software controlled vertical shift routines.
REM OK.
shift_up:
  IF multiplier=2 THEN GOTO shift_return:
  LET shift=shift-1
  IF shift<=62 THEN LET shift=62
  LET n=90-shift
  LET status$="Shift "+STR$(n)+" from centreline. "
  GOSUB status_window:
shift_return:
  RETURN
REM OK.
shift_down:
  IF multiplier=2 THEN GOTO shift_return:
  LET shift=shift+1
  IF shift>=118 THEN LET shift=118
  LET n=90-shift
  LET status$="Shift "+STR$(n)+" from centreline. "
  GOSUB status_window:
  RETURN

REM Show the ~Scope~ parameters in the window.
parameters:
  GOSUB clear_window:
  COLOR 13,2
  LOCATE 5,5
  PRINT "OSCILLOSCOPE PARAMETERS."
  LOCATE 6,5
  PRINT "------------------------"
  COLOR 3,2
  LET waveform=PEEK(12574977)
  IF waveform=255 THEN LET a$="Hardware is NOT connected."
  IF waveform<=244 THEN LET a$="Hardware IS connected."
  LOCATE 8,4
  PRINT a$
  IF waveform>63 AND waveform<=244 THEN LET a$="Check batteries."
  IF waveform<=63 THEN LET a$="Batteries are OK."
  LOCATE 9,4
  PRINT a$
REM Do NOT remove this line.
  IF waveform>=63 THEN LET waveform=63
  IF brightness=3 THEN LET a$="Normal brightness."
  IF brightness=13 THEN LET a$="High brightness."
  LOCATE 10,4
  PRINT a$
  IF graticule=0 THEN LET a$="Graticule disabled."
  IF graticule=1 THEN LET a$="Graticule enabled."
  LOCATE 11,4
  PRINT a$
  IF single_shot=1 THEN LET a$="Single shot ON."
  IF single_shot=0 THEN LET a$="Continuous scan ON."
  LOCATE 12,4
  PRINT a$
  IF retrace=0 THEN LET a$="Retrace facility OFF."
  IF retrace=1 THEN LET a$="Retrace facility ON."
  LOCATE 13,4
  PRINT a$
  IF multiplier=1 THEN LET a$="Normal scan height."
  IF multiplier=2 THEN LET a$="Double scan height."
  LOCATE 14,4
  PRINT a$
  LET n=90-shift
  LET a$="Shift "+STR$(n)+" from centreline."
  LOCATE 15,4
  PRINT a$
  LET a$="Sync position"+STR$(sync)+"."
  LOCATE 16,4
  PRINT a$
  COLOR 13,2
  LOCATE 19,4
  PRINT "(C)2001 B.Walker,(G0LCU)."
  SLEEP FOR 1
  GOTO keyboard1:

REM These are the hardware access and store routines.
REM Aquire the waveform and store.
REM OK.
aquire_trace:
  LET status$="Displaying,~ENTER~ to exit."
  GOSUB status_window:
aquire_trace1:
  LET waveform_address&=address&+sync
REM Use memory locations 0 to 3 for parameter passing. This is the
REM ~RESET the SSP~ location and is normally cleared after booting
REM up the AMIGA.
  POKEL 0,address&

REM Assembly subroutine to aquire the parallel port here.
REM OK.
ASSEM
      movem.l   d0-d7/a0-a6,-(sp)        ;Save all registers.
      lea.l     $0,a0                    ;Find my storage "address".
      move.l    (a0),a0                  ;Move contents of a0 to a0 itself.
      move.l    a0,d1                    ;Place this into d1 register.
      movea.l   $4,a6                    ;Move "Exec" pointer to a6.
      jsr       -132(a6)                 ;Disable tasking.
      jsr       -120(a6)                 ;Disable interrupts.
      move.l    #0,d0                    ;Clear d0 for use.
      move.w    #$ffff,d2                ;64KB counter.
port_access_routine:
      move.l    d1,-(sp)                 ;Push "address" onto the stack.
      move.b    $bfe101,d0               ;Read the parallel port.
      andi.b	#$3f,d0                  ;Ensure bottom 6 bits only.
      move.l    (sp)+,a0                 ;Pop the "address" into a0.
      move.b    d0,(a0)                  ;Put d0 value into contents of a0.
      add.l     #1,d1                    ;Increase "address" by one position.
      dbf       d2,port_access_routine   ;Do until countdown is finished.
      movea.l   $4,a6                    ;Move "Exec" pointer to a6.
      jsr       -126(a6)                 ;Enable interrupts.
      jsr       -138(a6)                 ;Enable tasking.
      movem.l   (sp)+,d0-d7/a0-a6        ;Reload all registers.

  EVEN

END ASSEM
REM Assembly routine ends here.

REM Clear memory locations 0 to 3 back to the bootup state.
REM OK.
  POKEL 0,0
rescan:
  GOSUB clear_window:
  COLOR brightness,2
  LINE STEP (n,(shift-(32-waveform)*multiplier))-(14,(shift-(32-waveform)*multiplier)),2
  LET n=14
REM The ~timebase_range~ value determines direct or indirect port access.
start_frame:
  IF timebase_range<=3 THEN GOSUB direct_port_access:
  IF timebase_range>3 THEN GOSUB indirect_port_access:
  LET n=n+1
  IF n>173 THEN GOTO next_frame:
  GOTO start_frame:
next_frame:
  LET a$=INKEY$
  IF a$=CHR$(13) OR single_shot=1 THEN GOTO aquire_exit:
  GOTO aquire_trace1:
aquire_exit:
  IF graticule=1 THEN GOSUB set_graticule:
  GOTO main_loop:

REM This is the routine for the bottom 3 timebase ranges.
REM OK.
direct_port_access:
  LET slow_range_delay=1
REM This address 12574977 is the parallel port.
slow_delay:
  LET waveform=PEEK(12574977)
REM Do NOT remove this line at all.
  IF waveform>=63 THEN LET waveform=63
  IF n=14 THEN LINE STEP (n,(shift-(32-waveform)*multiplier))-(n,(shift-(32-waveform)*multiplier)),2
  IF n=15 THEN LINE STEP (n,(shift-(32-waveform)*multiplier))-(n,(shift-(32-waveform)*multiplier)),2
  LINE STEP (n,(shift-(32-waveform)*multiplier))-(n,(shift-(32-waveform)*multiplier)),brightness
  LET slow_range_delay=slow_range_delay+1
  IF slow_range_delay>=timebase_calibrate THEN GOTO delay_exit:
  GOTO slow_delay:
delay_exit:
  RETURN

REM This is the routine for the top 3 timebase ranges.
REM OK.
indirect_port_access:
  LET waveform=PEEK(waveform_address&)
REM Do NOT remove this line at all.
  IF waveform>=63 THEN LET waveform=63
  IF n=14 THEN LINE STEP (n,(shift-(32-waveform)*multiplier))-(n,(shift-(32-waveform)*multiplier)),2
  IF n=15 THEN LINE STEP (n,(shift-(32-waveform)*multiplier))-(n,(shift-(32-waveform)*multiplier)),2
  LINE STEP (n,(shift-(32-waveform)*multiplier))-(n,(shift-(32-waveform)*multiplier)),brightness
  LET waveform_address&=waveform_address&+timebase_calibrate
  RETURN
