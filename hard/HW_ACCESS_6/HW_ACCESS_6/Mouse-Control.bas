
REM HW mouse access using standard AmigaBASIC for the HW ACCESS series.
REM Original idea copyright, (C)2009, B.Walker, G0LCU.
REM Left and right mouse buttons and instant keyboard control.
REM Horizontal and vertical mouse counters displayed in real time.

REM This code WILL compile under ACE Basic Compiler, (C)David Benn.

REM This code was developed on WinUAE Version 1.5.3...

REM Set up a standard window.
WINDOW 2,"Mouse Control Test Window...",(0,0)-(580,100),6

REM Set up any variables...
start:
LET n = 0
LET mousebutton = 0
LET horizontalcounter = 0
LET verticalcounter = 0
LET a$ = "(C)2009, B.Walker, G0LCU."
LET copyright$ = "  $VER: Mouse-Control.bas_Version_00-00-10_Public_Domain_2009_G0LCU."

REM Set the mouse counters to zero, 0.
POKEW 14676022&,0

REM Start with a simple startup screen.
CLS
PRINT
PRINT copyright$
PRINT
PRINT "  Press ~Alt D~ to restart."
PRINT
PRINT "  Press ~Alt C~ to quit."
PRINT
PRINT "  Entering mouse controlled loop..."

REM Call the 1 second time delay for demo purposes...
GOSUB timedelay

REM A test loop for checking mouse buttons.
mainloop:
REM Click left mouse button to show.
LET mousebutton = PEEK(12574721&)
IF mousebutton >= 128 THEN LET mousebutton = mousebutton - 128
IF mousebutton <= 63 THEN GOSUB lmb
REM Click right mouse button to show.
LET mousebutton = PEEK(14675990&)
IF mousebutton >= 128 THEN LET mousebutton = mousebutton - 128
IF mousebutton >= 64 THEN LET mousebutton = mousebutton - 64
IF mousebutton >= 32 THEN LET mousebutton = mousebutton - 32
IF mousebutton >= 16 THEN LET mousebutton = mousebutton - 16
IF mousebutton >= 8 THEN LET mousebutton = mousebutton - 8
if mousebutton <= 3 THEN GOSUB rmb
REM Fetch the mouse counter values in real time...
LET verticalcounter = PEEK(14675978&)
LET horizontalcounter = PEEK(14675979&)
REM Print the counter values in real time to the screen...
LOCATE 8,1
PRINT "  Horizontal counter";horizontalcounter;CHR$(8);". Vertical counter";verticalcounter;CHR$(8);".    "
LET a$ = INKEY$
IF a$ = "ç" THEN GOTO getout
IF a$ = "ð" THEN GOTO start
GOTO mainloop

REM Print left mouse button access to the screen...
lmb:
CLS
PRINT
PRINT copyright$
PRINT
PRINT "  Press ~Alt D~ to restart."
PRINT
PRINT "  Press ~Alt C~ to quit."
PRINT
PRINT "  Left mouse button pressed."
GOSUB timedelay
RETURN

REM Print right mouse button access to the screen...
rmb:
CLS
PRINT
PRINT copyright$
PRINT
PRINT "  Press ~Alt D~ to restart."
PRINT
PRINT "  Press ~Alt C~ to quit."
PRINT
PRINT "  Right mouse button pressed."
GOSUB timedelay
RETURN

REM Add a simple time delay as a subroutine.
REM Change this value to suit the machine in question...
timedelay:
FOR n = 1 to 1000000
NEXT n
RETURN

REM Use another instant keyboard access to quit... :)
getout:
CLS
PRINT
PRINT copyright$
PRINT
PRINT "  ~Alt C~ pressed and quitting..."
WINDOW CLOSE 2
END
REM Program end.
