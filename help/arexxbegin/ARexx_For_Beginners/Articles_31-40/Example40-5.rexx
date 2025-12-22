/* Example40-5 */

IF SHOW('P','Port40-6') = 0 THEN DO WHILE RC ~= 0
  SAY 'Waiting for PORT40-6 to be opened - Please RX Example40-6'
  ADDRESS COMMAND 'WaitForPort Port40-6'
END

SAY'c'x'Type in your messages for Port40-6 and see it appear in the other window.'
SAY 'Enter QUIT to terminate both programs.'

DO FOREVER

  PARSE PULL Text
  ADDRESS 'Port40-6' Text
  IF UPPER(Text) = 'QUIT' THEN LEAVE

END
