/* Example 20-7.rexx */

/* The MILLENNIUM Clock - Version 2 */

CALL CLOSE('STDOUT')

CALL OPEN('STDOUT','CON:0/11/640/40/Count Down to New Millennium','W')

DO FOREVER

  Days    = 8400 - DATE('I')
  Time = TIME()
  Seconds = 60 - RIGHT(Time,2)
  Minutes = 59 - SUBSTR(Time,4,2)
  Hours = 23 - LEFT(Time,2) 

  SAY 'b'x Days 'Days' Hours 'Hours' Minutes 'Minutes' Seconds 'Seconds until the next MILLENNIUM!!   '

END