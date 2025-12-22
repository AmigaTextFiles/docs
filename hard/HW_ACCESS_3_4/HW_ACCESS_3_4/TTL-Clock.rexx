/* ------------------------------------------ */
/*  TTL-Clock.rexx, (C)2006 B.Walker, G0LCU.  */
/* ------------------------------------------ */
/* Direct games port programming using AREXX. */
/* ------------------------------------------ */

/* This simple program generates a square wave at approximately 5Hz on */
/* a stock A1200(HD) with 4MB of FastRam at TTL level. */
/* Use an Oscilloscope to check that this works. */
/* Written so that youngsters can understand it! */

/* Set up any constants or variables. */
  mousetrap=1
  copyright='9'x'$VER: TTL-Clock.rexx_Version_0.92.00_(C)2006_B.Walker_G0LCU.'

/* Set up the games port screen. */
  ECHO 'c'x
  ECHO '9'x'9'x'Open the games port for WRITE access...'
  ECHO 'a'x'd'x'9'x'9'x'Data direction address is at $BFE201...'
/* Click mouse button to exit. */
  ECHO 'a'x'd'x'9'x'9'x'Click left mouse button to exit...'
/* Access the games port directly. */
  ECHO 'a'x'a'x'd'x'9'x'9'x'Data transfer address is at $BFE001...'
  ECHO

/* Set up games port pin 6 for write only. */
  EXPORT('00BFE201'x,'83'x,1)
  ECHO '9'x'9'x'Value at pin 6 is:- 1.'

/* This is the main loop. */
  DO FOREVER
/* Set pin 6 of the games port to 0. */
    ECHO 'b'x'9'x'9'x'Value at pin 6 is:- 0.'
    EXPORT('00BFE001'x,'7C'x,1)
/* Click left mouse button to exit. */
    mousetrap=IMPORT('00BFE001'x,1)
    IF BITTST(mousetrap,6)=0 THEN CALL getout
/* Reset pin 6 of the games port to 1. */
    ECHO 'b'x'9'x'9'x'Value at pin 6 is:- 1.'
    EXPORT('00BFE001'x,'FC'x,1)
  END

/* Exit the program safely. */
getout:
/* Reset pin 6 of the games port back to TTL logic 1. */
  EXPORT('00BFE001'x,'FC'x,1)
/* Set pin 6 of the games port back to READ mode. */ 
  EXPORT('00BFE201'x,'03'x,1)
  ECHO 'c'x
  SAY copyright
  EXIT(0)
