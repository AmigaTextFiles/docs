/* Example41-8 */

SAY 'c'x'Waiting for message from Example41-7'
DO FOREVER

  DO WHILE SHOW('C','Msg2') = 0
  END

  MemAdd = GETCLIP('Msg1')
  Length = GETCLIP('Msg2')
  CALL SETCLIP('Msg1')
  CALL SETCLIP('Msg2')
  Text = IMPORT(MemAdd,Length)
  CALL FREESPACE(MemAdd,Length)
  IF UPPER(Text) = 'QUIT' THEN LEAVE
  SAY 'c'x'Message from Program 1 is:- '||'a'x||Text
  
END