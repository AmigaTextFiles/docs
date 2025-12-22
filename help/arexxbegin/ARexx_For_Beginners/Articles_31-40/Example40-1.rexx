/* Example40-1 */

IF SHOW('P','Port40-2') = 0 THEN DO WHILE RC ~= 0
  SAY 'Waiting for PORT40-2 to be opened - Please RX Example40-2'
  ADDRESS COMMAND 'WaitForPort Port40-2'
END

SAY'c'x'Type in your messages for Port40-2 and see it appear in the other window.'
SAY 'Enter QUIT to terminate both programs.'

DO FOREVER

  PARSE PULL Text
  ADDRESS 'Port40-2' Text
  IF UPPER(Text) = 'QUIT' THEN LEAVE

END
