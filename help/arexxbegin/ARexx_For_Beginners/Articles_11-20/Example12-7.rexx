/* Example12-7 */
/* This is a correction to Example12-6 */

DO x = 1 TO 10
  IF x > 2 & x < 9 THEN
    IF x % 2 = x / 2 THEN SAY x 'is even'
    ELSE NOP
  ELSE SAY 'X =' x 'which is outside the range'
END

