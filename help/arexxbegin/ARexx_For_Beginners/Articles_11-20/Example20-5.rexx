/* Example20-5.rexx */

/* Reaction time Tester */

CALL RANDOM(,,TIME('S'))

DO FOREVER

  SAY 'a'x'Test your reaction time by pressing RETURN when so requested'
  Delay = RANDOM(1,10)
  CALL TIME('R')
  DO UNTIL TIME('E') > Delay
  END

  SAY 'a'x'Press RETURN'
  CALL TIME('R')
  PULL AnyKey
  Time = TIME('E')

  SAY 'Your reaction time was' Time 'seconds'

  SAY 'a'x'Another Test? (N or RETURN=Y)'
  PULL AnyKey
  IF AnyKey = 'N' THEN EXIT

END