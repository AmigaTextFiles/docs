/* Example28-6 */

Down = 'a'x

CALL OPEN('WinFile','CON:0/11/640/100/Test Window/CLOSE')

DO FOREVER

  Line = Down'Please type something in this window (or Q to quit) & press return'Down

  CALL WRITELN('WinFile',Line)

  LineIn = READLN('WinFile')
  IF UPPER(LineIn) = 'Q' THEN LEAVE

  LineOut = Down'You entered this line:-'Down||Down||LineIn
  CALL WRITELN('WinFile',LineOut)

END

CLOSE('WinFile')
