/* Example21-3.rexx */

CALL PRAGMA('P',-5)

CALL RANDOM(,,TIME('S'))

Min = 1000
Max = 0

DO FOR 10000
  Number = Random(0,999)
  IF Number > Max THEN Max = Number
  IF Number < Min THEN Min = Number
END

SAY 'Max Number recorded was' Max
SAY 'Min Number recorded was' Min
