/* Example19-1 */

CALL RANDOM(,,TIME('s'))
Max = 1
Min = 1000

DO FOR 100
  Number = RANDOM(1,1000)
  IF Number > Max THEN Max = Number
  IF Number < Min THEN Min = Number
END

SAY 'Maximum random number generated =' Max
SAY 'Minimum random number generated =' Min
