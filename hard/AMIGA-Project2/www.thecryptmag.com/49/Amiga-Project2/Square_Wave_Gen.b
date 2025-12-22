REM A simple Square Wave Generator.
REM This is ready for ACE Basic Compiler, (C)David Benn.
REM Given to    http://www.thecryptmag.com/    and as PD for all.
REM This will work from OS1.3x to 3.xx without modification.
REM It will also work under WinUAE with full sound enabled.

REM Set up a WorkBench window and fix the font to ~topaz 8~.
  WINDOW 1," A WIDE BAND SQUARE WAVE GENERATOR, (C)1996-2006, B.WALKER, G0LCU.",(0,0)-(640,200),6
  FONT "topaz.font",8
  COLOR 1,0
  CLS

REM Set up variabes.
  LET a$="$VER: Square_Wave_Generator-Version_0.76.64_(C)12-05-1996_G0LCU."
  LET addr&=ALLOC(512,0)
  LET toneaddr&=addr&
  LET pokeaddr&=addr&
  LET dataaddr&=pokeaddr&
  LET n=0
  LET freq=1000
  LET period=INT(3563220/(6*freq))
  LET volume=64

  FOR n=0 TO 201
  LET dataaddr&=(pokeaddr&+n)
  POKE dataaddr&,127
  NEXT n

  POKE (pokeaddr&+1),-128

  FOR n=6 TO 9
  LET dataaddr&=(pokeaddr&+n)
  POKE dataaddr&,-128
  NEXT n

  FOR n=26 TO 41
  LET dataaddr&=(pokeaddr&+n)
  POKE dataaddr&,-128
  NEXT n

  FOR n=106 TO 169
  LET dataaddr&=(pokeaddr&+n)
  POKE dataaddr&,-128
  NEXT n


REM Set up the screen.
screen_setup:
  LOCATE 3,24
  PRINT "SIGNAL OUTPUT LEFT AUDIO CHANNEL."
  LOCATE 6,25
  PRINT "Press the letter in brackets:-"
  LOCATE 7,25
  PRINT "------------------------------"
  LOCATE 9,21
  PRINT "(i) Increase frequency (coarse, 500Hz)."
  LOCATE 10,21
  PRINT "(I) Increase frequency (fine, 10Hz)."
  LOCATE 11,21
  PRINT "(d) Decrease frequency (coarse, 500Hz)."
  LOCATE 12,21
  PRINT "(D) Decrease frequency (fine, 10Hz)."
  LOCATE 13,21
  PRINT "(Q) or (q) Quit the program." 
  LOCATE 16,31
  PRINT "FREQUENCY"
  LOCATE 19,6
  PRINT "Designed range 100Hz to 10KHz SQUARE WAVE. Useful range 10Hz to 30KHz."


REM Generate an audio tone.
  POKEW 14676118,15		'Switch off audio dma.
  POKEL 14676128,toneaddr&	'Set address to chip ram.
  POKEW 14676132,4		'Number of words in data sample.
  POKEW 14676134,period		'Period of sampling time.
  POKEW 14676136,volume		'Volume max 64, min 0.
  POKEW 14676126,255		'Disable any other modulation.
  POKEW 14676118,33281		'Enable sound on CH1.
  POKE 12574721,254		'Disable audio filter.


REM This is the program loop.
key_hold:
  LET a$=INKEY$
  IF a$="q" OR a$="Q" OR a$=" " OR a$=CHR$(27) THEN GOTO cleanup:
  IF a$="i" THEN LET freq=freq+500
  IF a$="I" THEN LET freq=freq+10
  IF a$="d" THEN LET freq=freq-500
  IF a$="D" THEN LET freq=freq-10
  IF a$="o" THEN LET freq=freq+1
  IF a$="O" THEN LET freq=freq-1
  If a$="v" THEN LET volume=volume+1
  IF a$="V" THEN LET volume=Volume-1
  IF a$="m" THEN LET volume=64
  IF a$="M" THEN LET volume=0
  IF a$="f" THEN POKE 12574721,254
  IF a$="F" THEN POKE 12574721,252
  IF freq<=10 THEN LET freq=10
  IF freq>=30000 THEN LET freq=30000
  IF volume<=0 THEN LET volume=0
  IF volume>=64 THEN LET volume=64
  LOCATE 16,40
  PRINT freq;"Hz.";"        "
  IF freq>3520 THEN GOTO band0:
  IF freq>880 THEN GOTO band1:
  IF freq>220 THEN GOTO band2:
  GOTO band3:
  GOTO key_hold:
band0:
  LET period=INT(3563220/(2*freq))
  POKEL 14676128,toneaddr&
  POKEW 14676132,1
  POKEW 14676134,period
  POKEW 14676136,volume
  GOTO key_hold:
band1:
  LET period=INT(3563220/(8*freq))
  POKEL 14676128,(toneaddr&+2)
  POKEW 14676132,4
  POKEW 14676134,period
  POKEW 14676136,volume
  GOTO key_hold:
band2:
  LET period=INT(3563220/(32*freq))
  POKEL 14676128,(toneaddr&+10)
  POKEW 14676132,16
  POKEW 14676134,period
  POKEW 14676136,volume
  GOTO key_hold:
band3:
  LET period=INT(3563220/(128*freq))
  POKEL 14676128,(toneaddr&+42)
  POKEW 14676132,64
  POKEW 14676134,period
  POKEW 14676136,volume
  GOTO key_hold:


REM This is the cleanup routine.
cleanup:
  POKEW 14676118,15		'Turn off audio DMA.
  POKE 12574721,252		'Enable audio filter.
  CLEAR ALLOC			'Reclaim memory.
  WINDOW CLOSE 1		'Close the window.
  END				'Exit without errorcode.
