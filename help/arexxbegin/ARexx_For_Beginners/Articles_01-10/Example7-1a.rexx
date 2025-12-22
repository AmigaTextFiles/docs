  /* Example7-1a.rexx */

  /* This is Example7-1 rewritten with the use of a Function */

  CALL Display

  Name1 = Fred Bloggs
  Name2 = 'Fred Bloggs'
  Value1 = 2.35
  Value2 = Value1 + 2.2

  CALL Display

  Name1 = 2.35
  Name2 = Name1 + 2.2
  Value1 = Fred Bloggs
  Value2 = 'Fred Bloggs'

  CALL Display

  EXIT

  Display:

  SAY
  SAY 'Name1  is ' Name1
  SAY 'Name2  is ' Name2
  SAY 'Value1 is ' Value1
  SAY 'Value2 is ' Value2
  RETURN
