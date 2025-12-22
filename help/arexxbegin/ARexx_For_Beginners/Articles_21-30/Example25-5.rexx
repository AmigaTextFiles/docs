/* Example25-5 */

IF SHOW('P','Ed') = 0 THEN DO
  SAY 'The primary "ED" window is NOT open'
  SAY 'a'x'Opening Primary "ED" window now'||'a'x
  ADDRESS 'COMMAND' 'Run >Nil: Ed Dummy'
END
ELSE SAY 'The primary "ED" window IS already open'||'a'x

WAITFORPORT 'Ed'

ADDRESS 'Ed'

'sm "This is a status line message"'

SAY 'Value of RESULT before "OPTIONS RESULTS =' Result

OPTIONS RESULTS

'sm "ANOTHER STATUS LINE MESSAGE"'

SAY 'Value of RESULT after  "OPTIONS RESULTS =' Result
