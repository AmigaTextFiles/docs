/* Example33-3 */

x = 0

Start:
  SIGNAL ON BREAK_C
  DO FOREVER
    x = x + 1
    SAY 'X =' x
  END

Break_C:
  SAY 'a'x'Do you really want to quit? (Y/N)'
  PULL YesNo
  IF YesNo = 'Y' THEN EXIT
  ELSE SIGNAL Start
