/* Example16-2.rexx */

SAY 'The 5 times table'

DO x = 1 to 10
   SAY 'Five times' x '=' Multiply(x)
END
EXIT

Multiply:
ARG m
RETURN m*5
