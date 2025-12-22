/* --------------------------------------------------- */
/* Parallel-Port-Access.rexx, (C)2008 B.Walker, G0LCU. */
/* --------------------------------------------------- */

/* Direct parallel port programming using AREXX. */

/* Set up any constants or variables. */
  mousetrap=1
  portvalue=0
  number='0'
  copyright='     $VER: Parallel-Port-Access.rexx_Version_0.5.00_17-06-2008_(C)G0LCU.'

/* Use ECHO for ordinary printing to the screen and SAY for printing results. */
  DO FOREVER
    ECHO 'c'x
    SAY copyright
    ECHO 'a'x'd'x'9'x'9'x'9'x'1) Read from the parallel port.'
    ECHO '9'x'9'x'9'x'2) Write to the parallel port.'
    ECHO 'a'x'd'x'9'x'9'x'9'x'3) Quit this program.'
    ECHO 'a'x'd'x'9'x'9'x'Type in a number and then press ENTER/RETURN:-'
    PULL number
    IF number='1' THEN CALL readparallelport
    IF number='2' THEN CALL writeparallelport
    IF number='3' THEN CALL getout
  END

/* Set up the parallel port screen. */
parallelportsetup:
  ECHO 'c'x
  ECHO '9'x'9'x'Open the parallel port for access...'
  ECHO 'a'x'd'x'9'x'9'x'Data direction address is at $BFE301...'
/* Click mouse button to exit. */
  ECHO 'a'x'd'x'9'x'9'x'Click left mouse button to exit...'
/* Access the parallel port directly. */
  ECHO 'a'x'a'x'd'x'9'x'9'x'Data transfer address is at $BFE101...'
  ECHO
  RETURN

/* Set the parallel port for read only. */
readparallelport:
  CALL parallelportsetup
/* Set prarllel port data lines to read. */
  EXPORT('00BFE301'x,'00'x,1)
  portvalue=IMPORT('00BFE101'x,1)
/* Read initial value from parallel port. */
  SAY '9'x'9'x'Value at the port is:- '||C2D(portvalue)||'.   '
/* Parallel port reading. */
  DO FOREVER
    portvalue=IMPORT('00BFE101'x,1)
    SAY 'b'x'9'x'9'x'Value at the port is:- '||C2D(portvalue)||'.   '
/* Click left mouse button to exit. */
    DO FOR 250
      mousetrap=IMPORT('00BFE001'x,1)
      IF BITTST(mousetrap,6)=0 THEN RETURN
    END
  END

/* Set the parallel port to write only. */
writeparallelport:
  CALL parallelportsetup
/* Set prarllel port data lines to write. */
  EXPORT('00BFE301'x,'FF'x,1)
  ECHO '9'x'9'x'Value at the port is:- FFH.'
/* Write to the parallel port. */
  DO FOREVER
/* Write the value 85 decimal, (55 Hexadecimal), to the port. */
    ECHO 'b'x'9'x'9'x'Value at the port is:- 55H.'
    DO FOR 10
      EXPORT('00BFE101'x,'55'x,1)
/* Click left mouse button to exit. */
      mousetrap=IMPORT('00BFE001'x,1)
      IF BITTST(mousetrap,6)=0 THEN RETURN
    END
/* Write the value 170 decimal, (AA Hexadecimal), to the port. */
    ECHO 'b'x'9'x'9'x'Value at the port is:- AAH.'
    DO FOR 10
      EXPORT('00BFE101'x,'AA'x,1)
/* Click left mouse button to exit. */
      mousetrap=IMPORT('00BFE001'x,1)
      IF BITTST(mousetrap,6)=0 THEN RETURN
    END
  END


/* Exit the program safely. */
getout:
  EXPORT('00BFE301'x,'FF'x,1)
  EXPORT('00BFE101'x,'FF'x,1)
  ECHO 'c'x
  SAY copyright
  ECHO 'a'x'a'x'a'x'd'x'7'x'9'x'9'x'9'x'Click on CLOSE gadget to Quit.'
  EXIT(0)
