/* Example16-1.rexx */

SAY 'The 5 times table'

DO x = 1 to 10
   CALL Multiply
   SAY 'Five times' x '=' Result
END
EXIT

Multiply:
RETURN x*5
