
REM PAR: as a VOLUME in continuous READ mode using AmigaBASIC.
REM Original idea copyright, (C)2008, B.Walker, G0LCU.
REM This software is Public Domain and you can do with it as you please.
REM Use a standard AmigaBASIC window.

REM                          !!! CAUTION !!!
REM                          ---------------
REM
REM DO NOT RUN WITHOUT AN EXTERNAL TTL LEVEL CLOCK ON THE ~-ACK~ LINE!!!

REM Set up the required variables.
LET mybyte=0
LET mybyte$="(C)2008, B.Walker, G0LCU."
LET a$="PAR: as a VOLUME in READ mode."

REM Generate a simple usable window
LOCATE 3,24
PRINT a$
LOCATE 5,27
PRINT mybyte$
LOCATE 7,28
PRINT "Press <ENTER> to quit."

REM Enter the continuous loop and press <RETURN/ENTER> to QUIT.
loopit:
REM Open a channel to import the byte from the parallel port.
OPEN "I", #3, "PAR:"
REM Grab that data byte sitting on the parallel port.
LET mybyte$=INPUT$(1,#3)
REM Immediately close the channel after byte access.
CLOSE #3

REM Convert to a [decimal] number.
LET mybyte=ASC(mybyte$)

REM Print the value to the screen.
LOCATE 10,30
PRINT "Byte read is:-";mybyte;CHR$(8);".     "

REM Go and grab another byte unless <RETURN/ENTER> is pressed..."
LET a$=INKEY$
IF a$="" THEN GOTO loopit:

REM Then QUIT the program.
END
