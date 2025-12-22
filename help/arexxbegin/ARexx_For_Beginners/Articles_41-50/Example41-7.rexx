/* Example41-7 */

DO FOREVER

  SAY 'c'x'Enter a message for Example41-8'
  PARSE PULL Text
  Length = LENGTH(Text)
  MemAdd = GETSPACE(Length)
  CALL EXPORT(MemAdd,Text,Length)
  CALL SETCLIP('Msg1',MemAdd)
  CALL SETCLIP('Msg2',Length)
  IF UPPER(Text) = 'QUIT' THEN LEAVE

END
