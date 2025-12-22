/* Example13-1.rexx */

SAY 'Testing Logical Operators' ; SAY

SAY 'X  Y  X=2 & Y=2  X=2 | Y=2  X=2 ^ y=2'
SAY '-  -  ---------  ---------  ---------'

DO x = 1 to 3
   DO y = 1 to 2
      IF x = 2 & Y = 2 THEN T1 = 'True '
      ELSE T1 = 'False'
      IF x = 2 | Y = 2 THEN T2 = 'True '
      ELSE T2 = 'False'
      IF x = 2 ^ Y = 2 THEN T3 = 'True '
      ELSE T3 = 'False'
      SAY x '' y ' ' T1 '    ' T2 '    ' T3
   END
END
