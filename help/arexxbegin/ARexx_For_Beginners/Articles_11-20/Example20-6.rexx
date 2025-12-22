/* Example 20-6.rexx */

/* The MILLENNIUM Clock - Version 1 */

SAY 'c'x

DO FOREVER

  Days    = 8400 - DATE('I')
  Time = TIME('N')
  Seconds = 60 - RIGHT(Time,2)
  Minutes = 59 - SUBSTR(Time,4,2)
  Hours = 23 - LEFT(Time,2) 
  SAY 'b'x Days 'Days' Hours 'Hours' Minutes 'Minutes' Seconds 'Seconds until the next MILLENNIUM!!    '

END
