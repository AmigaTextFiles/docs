
/* Logic Probe using the ARexx interpreter. */

/* ---------------------------------------- */
/* LP.rexx, (C)01-10-2006, B.Walker, G0LCU. */
/* ---------------------------------------- */
/*    Released as Public Domain Software.   */
/* ---------------------------------------- */

/* Set up any constants or variables. */
  state=1
  logic='1'
  copyright='9'x'$VER: Logic-Probe.rexx_Version_0.80.00_01-10-2006_(C)G0LCU.'

/* Use ECHO for ordinary printing to the screen and SAY for printing results. */
/* Set up the games port logic probe screen. */
  ECHO 'c'x
  ECHO 'd'x'9'x'9'x'9'x'Click left mouse button to Quit.'
  ECHO 'a'x'9'x'9'x'   Logic Probe using pin 6 of the games port.'
  ECHO 'a'x'a'x'9'x'9'x'9'x'        Logic state = 1.'

/* This is the main loop. */
  DO FOREVER
/* Read the 'pra' register for bit 7, pin 6 of the games port. */
/* ALSO bit 6, pin 6 of the mouse port from the same register... :) */
    state=IMPORT('00BFE001'x,1)
    IF BITTST(state,7)=1 THEN logic='1'
    IF BITTST(state,7)=0 THEN logic='0'
/* Left mouse button to quit the program. */
    IF BITTST(state,6)=0 THEN CALL getout
/* Print the results to the screen. */
    SAY 'b'x'9'x'9'x'9'x'        Logic state = '||logic
  END

/* Exit the program safely. */
getout:
  EXPORT('00BFE001'x,'FC'x,1)
  ECHO 'c'x
  SAY copyright
  EXIT(0)
