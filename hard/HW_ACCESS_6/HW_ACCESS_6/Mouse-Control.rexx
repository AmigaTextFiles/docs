
/* HW mouse access using standard ARexx for the HW ACCESS series. */
/* Original idea copyright, (C)2009, B.Walker, G0LCU. */
/* Left and right mouse buttons and instant keyboard control. */
/* Horizontal and vertical mouse counters displayed in real time. */
/* Use ECHO for ordinary printing to the screen and SAY to print */
/* lines with any variables inside. */

/* This code was developed on WinUAE Version 1.5.3... */

/* Use SIGNAL ON BREAK_? for instant keyboard access... ;) */
/* Using SIGNAL ON BREAK_C to quit this program... */
SIGNAL ON BREAK_C

/* Using SIGNAL ON BREAK_D to do an internal program jump. */
/* Similarly for SIGNAL ON BREAK_E and SIGNAL ON BREAK_F. */
/* IMPORTANT NOTE:- SIGNAL ON BREAK_D calls _SELF_ to set itself */
/* again after pressing the Ctrl and D keys simultaneously. */
Break_D:
SIGNAL ON BREAK_D

/* Set up any variables... */
mousebutton = 0
horizontalcounter = 0
verticalcounter = 0
copyright = '  $VER: Mouse-Control.rexx_Version_00-00-10_Public_Domain_2009_G0LCU.'

/* Set the mouse counters to zero, 0. */
EXPORT('00DFF036'x, '0000'x, 2)

/* Start with a simple startup screen. */
ECHO 'c'x
SAY copyright
ECHO ''
ECHO '  Press ~Ctrl D~ to restart.'
ECHO ''
ECHO '  Press ~Ctrl C~ to quit.'
ECHO ''
ECHO '  Entering mouse controlled loop...'

/* Call the 1 second time delay for demo purposes... */
CALL timedelay

/* A test loop for checking mouse buttons. */
DO FOREVER
/* Click left mouse button to show. */
  mousebutton = IMPORT('00BFE001'x,1)
  IF BITTST(mousebutton,6) = 0 THEN CALL lmb
/* Click right mouse button to show. */
  mousebutton = IMPORT('00DFF016'x,1)
  IF BITTST(mousebutton,2) = 0 THEN CALL rmb
/* Fetch the mouse counter values in real time... */
  verticalcounter = IMPORT('00DFF00A'x, 1)
  horizontalcounter = IMPORT('00DFF00B'x, 1)
/* Print the counter values in real time to the screen... */
  ECHO 'b'x'b'x
  SAY '  Horizontal counter '||C2D(horizontalcounter)||'. Vertical counter '||C2D(verticalcounter)||'.    '
END

/* Print left mouse button access to the screen... */
lmb:
ECHO 'c'x
SAY copyright
ECHO ''
ECHO '  Press ~Ctrl D~ to restart.'
ECHO ''
ECHO '  Press ~Ctrl C~ to quit.'
ECHO ''
ECHO '  Left mouse button pressed.'
CALL timedelay
RETURN

/* Print right mouse button access to the screen... */ 
rmb:
ECHO 'c'x
SAY copyright
ECHO ''
ECHO '  Press ~Ctrl D~ to restart.'
ECHO ''
ECHO '  Press ~Ctrl C~ to quit.'
ECHO ''
ECHO '  Right mouse button pressed.'
CALL timedelay
RETURN

/* Add a simple 1 second time delay as a subroutine. */
timedelay:
ADDRESS COMMAND 'C:Wait 1'
RETURN

/* Use another instant keyboard access to quit... :) */
Break_C:
ECHO 'c'x
SAY copyright
ECHO ''
ECHO '  Ctrl C pressed and quitting...'
EXIT(0)
/* Program end. */
