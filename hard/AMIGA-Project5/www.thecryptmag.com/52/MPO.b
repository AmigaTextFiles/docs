
REM MPO, Morse Practice Oscillator.
REM (C)2007, B.Walker, G0LCU.
REM ACE Basic Compiler, (C)David Benn.
REM Originally written for <http://www.thecryptmag.com> the online magazine.
REM $VER: MPO_Version_0.52.00_(C)2007_B.Walker_G0LCU.

REM Setup a simple window.
  WINDOW 2,"Morse Practice Oscillator.",(0,0)-(320,100),6
  FONT "topaz.font",8
start:
  COLOR 1,0
  CLS
  LET a$="(C)2007, B.Walker, G0LCU."
  LOCATE 2,8
  PRINT a$
  LOCATE 6,1
  PRINT "(Q) to Quit, any other key to continue."

REM Hold using KB.
keyloop:
  LET a$=INKEY$
  IF a$="Q" OR a$="q" THEN GOTO safeclosedown:
  IF a$="" THEN GOTO keyloop:

REM Main operating instructions.
  CLS
  LOCATE 2,8
  PRINT "(C)2007, B.Walker, G0LCU."
  LOCATE 5,3
  PRINT "Push the button to generate a tone."
  COLOR 2,0
  LOCATE 8,3
  PRINT "Push the Left Mouse Button to Quit."
  COLOR 1,0

REM The multitasking assembler routine.
ASSEM
	movem.l	d0-d7/a0-a6,-(sp)	;Save all registers just in case.
	movea.l	$4,a6			;Set ~execbase~.
	moveq	#16,d0			;Length of sine wave data.
	moveq	#2,d1			;Set to chip ram.
	jsr	-198(a6)		;Allocate memory for the task.
	beq	getout			;On error, Quit.
	move.l	d0,a0			;Set address in chip ram.
	lea.l	audiodata,a1		;Set pointer for data.
	moveq	#15,d1			;Set counter for data.
loop:
	move.b	(a1)+,(a0)+		;Move data to chip ram.
	dbf	d1,loop			;Do it.
	lea	$dff000,a5		;Set HW register base.
	move.w	#$000f,$96(a5)		;Disable audio DMA.
	move.l	d0,$a0(a5)		;Set address of audio data.
	move.w	#8,$a4(a5)		;Set length in words.
	move.w	#64,$a8(a5)		;Set volume to maximum.
	move.w	#250,$a6(a5)		;Set the period.
	move.w	#$00ff,$9e(a5)		;Disable any modulation.
	move.w	#$8201,$96(a5)		;Enable audio DMA.
notone:
	move.w	#0,$a8(a5)		;Set volume to minimum.
wait:	
	btst	#6,$bfe001		;If LMB pressed then Quit.
	beq.s	closeme			;Do it.
	btst	#7,$bfe001		;If morse key not pressed...
	bne.s	wait			;Wait until it is then...
	move.w	#64,$a8(a5)		;Set volume to maximum.
tone:
	btst	#7,$bfe001		;If button is pressed...
	beq.s	tone			;play the tone until it is released...
	bra.s	notone			;then return to notone mode.
closeme:
	move.w	#$000f,$96(a5)		;Disable audio DMA.
	move.l	d0,a1			;Address of the sine wave data.
	moveq	#16,d0			;The data length to recover.
	jsr	-210(a6)		;Free assigned memory.
	bra.s	getout			;Always go to a clean exit.
audiodata:
	dc.b	0,49
	dc.b	90,117
	dc.b	127,117
	dc.b	90,49
	dc.b	0,-49
	dc.b	-90,-117
	dc.b	-127,-117
	dc.b	-90,-49
getout:
	movem.l	(sp)+,d0-d7/a0-a6	;Restore all registers.
	clr.l	d0			;Set return code OK.
	even
END ASSEM
  GOTO start:

safeclosedown:
  WINDOW CLOSE 2
  END
