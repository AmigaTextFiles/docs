
/* ----------------------------------------------- */
/* 8 channel input detector using the PAR: device. */
/*            (C)2005, B.Walker, G0LCU.            */
/* ----------------------------------------------- */
/* Use ECHO for printing to the screen and SAY for */
/*      printing any variables to the screen.      */
/* ----------------------------------------------- */
/*   IMPORTANT!!!, run ONLY from a SHELL or CLI.   */
/* From a Shell, type:-   RX PARINPUT.rexx<RETURN> */
/* ----------------------------------------------- */


/* Show my version number and (C) for one line only. */
/* (Note these two lines can be omitted.) */
    ECHO 'c'x
    ECHO '$VER: PARINPUT.rexx_Version_0.80.00_(C)01-06-2006_B.Walker_G0LCU.'
    ECHO
    ECHO 'Press ~Ctrl C~ to quit the program...'


/* Set up any variables. */
    ParaByte = ''
    MyByte = ''


/* Set the signal for breaking the script, ~Ctrl C~. */
    SIGNAL ON BREAK_C


/* ------------------------------------------------------------------- */
/* This is the main working loop for accessing the parallel port. */
    DO FOREVER

/* Open up a channel for reading from the parallel port. */
    OPEN(ParaByte, 'PAR:', 'R')

/* Read a single binary character from the port. */
    MyByte = READCH(ParaByte, 1)

/* If MyByte is a NULL then this corresponds to the EOF, 0, so correct */
/* it by making sure ALL NULLs are given the value of 0. */
    IF MyByte = '' THEN MyByte = 0

/* All major data access done, NOW IMMEDIATELY close the channel. */
    CLOSE(ParaByte)

/* Test each data bit and IF SET to 0 then trigger the hideous voice. */
    IF BITTST(MyByte, 0) = 0 THEN ADDRESS COMMAND 'SYS:Utilities/Say "WARNING!!!, channel ONE armed."'
    IF BITTST(MyByte, 1) = 0 THEN ADDRESS COMMAND 'SYS:Utilities/Say "WARNING!!!, channel TWO armed."'
    IF BITTST(MyByte, 2) = 0 THEN ADDRESS COMMAND 'SYS:Utilities/Say "WARNING!!!, channel THREE armed."'
    IF BITTST(MyByte, 3) = 0 THEN ADDRESS COMMAND 'SYS:Utilities/Say "WARNING!!!, channel FOUR armed."'
    IF BITTST(MyByte, 4) = 0 THEN ADDRESS COMMAND 'SYS:Utilities/Say "WARNING!!!, channel FIVE armed."'
    IF BITTST(MyByte, 5) = 0 THEN ADDRESS COMMAND 'SYS:Utilities/Say "WARNING!!!, channel SIX armed."'
    IF BITTST(MyByte, 6) = 0 THEN ADDRESS COMMAND 'SYS:Utilities/Say "WARNING!!!, channel SEVEN armed."'
    IF BITTST(MyByte, 7) = 0 THEN ADDRESS COMMAND 'SYS:Utilities/Say "WARNING!!!, channel EIGHT armed."'
    END
/* ------------------------------------------------------------------- */


/* Cleanup and exit from the script. */
Break_C:
    ECHO 'c'x'7'x
    ECHO 'Ctrl C detected program closing down...'
    EXIT
