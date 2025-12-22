/* Example 47-2 */

IF SHOW('F','STDERR') = 1 THEN DO
  SAY 'GTC window is open. Closing it now'
  ADDRESS 'COMMAND'
  'TCC'
  'WAIT 1 SECS'
END

SAY 'Opening own STDERR window'
CALL OPEN('STDERR','CON:0/11/640/130/THIS IS MY OWN TRACING WINDOW/CLOSE/WAIT','W')

CALL TRACE('R')

DO Count = 1 to 10
  SAY 'Count =' Count
END
