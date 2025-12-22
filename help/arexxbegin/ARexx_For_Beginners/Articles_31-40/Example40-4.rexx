/* Example40-4 */

IF EXISTS('Libs:rexxsupport.library') = 0 THEN DO
  SAY 'c'x'Sorry - Your Libs: directory does not contain the rexxsupport.library file'
  EXIT
END

IF SHOW('L','rexxsupport.library') = 0 THEN DO
  CALL ADDLIB('rexxsupport.library',0,-30,0)
END

CALL OPENPORT('Port40-4')

SAY 'Waiting for a message from Example40-1'

DO FOREVER
  CALL WAITPKT('Port40-4')
  MsgAdd = GETPKT('Port40-4')
  Text = GETARG(MsgAdd)
  CALL REPLY(MsgAdd,0)
  IF UPPER(Text) = 'QUIT' THEN LEAVE
  INTERPRET Text
END
