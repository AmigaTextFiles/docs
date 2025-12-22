
REM PAR: as a VOLUME in ~continuous~ WRITE mode using AmigaBASIC.
REM Original idea copyright, (C)2008, B.Walker, G0LCU.
REM This software is Public Domain and you can do with it as you please.
REM Use a standard AmigaBASIC window.

REM Set up the required variables.
LET mybyte=127
LET a$="PAR: as a VOLUME in WRITE mode."

REM Generate a simple usable window
LOCATE 3,24
PRINT a$
LOCATE 5,27
PRINT "(C)2008, B.Walker, G0LCU."

REM The start of the test loop.
loopit:
REM Show the [decimal] value to be written to the parallel port.
LOCATE 7,29
PRINT "Byte written is:-";mybyte;CHR$(8);".     "
LOCATE 10,28
PRINT "                        "

REM Open up PAR: as a VOLUME in WRITE mode.
OPEN "O", #3, "PAR:"
REM Send the byte value to the parallel port.
PRINT #3,CHR$(mybyte)
REM Immediately close the channel.
CLOSE #3

REM Increase the byte value by one.
LET mybyte=mybyte+1
REM Until a maximum of 255 [decimal] is reached then reset back to zero.
IF mybyte>255 THEN LET mybyte=0

REM Give a simple means of quitting the program.
REM Press <ENTER/RETURN> on its own to continue.
LOCATE 10,29
INPUT "Q or q<ENTER> to quit. ",a$
IF a$="Q" OR a$="q" THEN GOTO getout:
REM Carry on looping.
GOTO loopit:

REM A simple clean exit.
getout:
END
