/* Example33-2 */

x = 0

SIGNAL ON BREAK_C

Start:
  DO FOREVER
    x = x + 1
    SAY 'X =' x
  END

Break_C:
  SAY 'a'x'Do you really want to quit? (Y/N)'
  PULL YesNo
  IF YesNo = 'Y' THEN EXIT
  ELSE SIGNAL Start
