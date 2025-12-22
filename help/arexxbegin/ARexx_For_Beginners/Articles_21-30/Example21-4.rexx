/* Example21-4 */

SAY 'Enter a positive integer number as the random seed'
PULL Number
IF DATATYPE(Number,'W') = 0 THEN CALL Error
IF SIGN(Number) = -1 THEN CALL Error

CALL RANDOM(,,Number)
DO Throw = 1 to 6
  SAY RANDOM(1,6)
END

EXIT

Error:
  SAY Number 'is not a positive integer number!!'
  EXIT
 