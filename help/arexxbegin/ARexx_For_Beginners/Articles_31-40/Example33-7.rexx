/* Example33-7 */

x = 0

Start:
SIGNAL ON HALT

  DO FOREVER
    x = x + 1
    SAY 'X =' x
  END

  Halt:
  SAY 'a'x'Do you really want to quit? (Y/N)'
  PULL YesNo
  IF YesNo = 'Y' THEN EXIT
  ELSE SIGNAL Start
