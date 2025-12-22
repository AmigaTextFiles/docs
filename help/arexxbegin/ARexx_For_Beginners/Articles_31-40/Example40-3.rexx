/* Example40-3 */

IF SHOW('P','Port40-4') = 0 THEN DO WHILE RC ~= 0
  SAY 'Waiting for PORT40-4 to be opened - Please RX Example40-4'
  ADDRESS COMMAND 'WaitForPort Port40-4'
END

SAY'c'x'Type in your messages for Port40-4 and see it appear in the other window.'
SAY 'Enter QUIT to terminate both programs.'

DO FOREVER

  PARSE PULL Text
  ADDRESS 'Port40-4' Text
  IF UPPER(Text) = 'QUIT' THEN LEAVE

END
