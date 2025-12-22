/* Example40-6 */

IF EXISTS('Libs:rexxsupport.library') = 0 THEN DO
  SAY 'c'x'Sorry - Your Libs: directory does not contain the rexxsupport.library file'
  EXIT
END

IF SHOW('L','rexxsupport.library') = 0 THEN DO
  CALL ADDLIB('rexxsupport.library',0,-30,0)
END

CALL OPENPORT('Port40-6')

Count = 0

DO FOREVER

  Count = Count + 1
  SAY 'Doing something else rather than wait for message - Count =' Count
  IF Count // 10 = 0 THEN CALL CheckMessage

END

CheckMessage:

  MsgAdd = GETPKT('Port40-6')
  IF C2X(MsgAdd) = '00000000' THEN RETURN

  Text = GETARG(MsgAdd)
  CALL REPLY(MsgAdd,0)
  IF UPPER(Text) = 'QUIT' THEN EXIT
  SAY 'a'x'Attention HUMAN!! - A message has been received as follows:-'
  SAY 'a'x||Text
  SAY 'a'x'Press RETURN to continue'
  PULL Nothing
  RETURN
