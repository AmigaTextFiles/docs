/* Example12-6 */
/* This program does not work properly!! */

DO x = 1 TO 10
  IF x > 2 & x < 9 THEN
    IF x % 2 = x / 2 THEN SAY x 'is even'
  ELSE SAY 'X =' x 'which is outside the range 3 - 8'
END
