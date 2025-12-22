/* Example21-8.rexx */

CALL RANDU(TIME('S'))

SAY 'c'x'Numbers entered must be positive whole numbers !!!'||'a'x

SAY 'Enter LOWEST number for the series'
PULL Low

SAY 'Enter HIGHEST number for the series'
PULL High

SAY 'Enter number of DECIMAL PLACES'
PULL Places

Min = High
Max = Low

DO Count = 1 TO 100

  Number = MyRandom(High,Low,Places)
  IF Number > Max THEN Max = Number
  IF Number < Min THEN Min = Number

  SAY 'Number' Count '=' Number  'Current Min =' Min 'Current Max =' Max

END

SAY 'a'x'You entered HIGH =' High 'LOW =' Low 'PLACES =' Places||'a'x

SAY 'Max Number recorded was' Max
SAY 'Min Number recorded was' Min

EXIT

MyRandom:
  PROCEDURE
  ARG Low,High,Places
RETURN TRUNC(10**Places*((High-Low)*RANDU()+Low)+.5)/10**Places


