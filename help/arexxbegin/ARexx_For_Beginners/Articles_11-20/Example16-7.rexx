/* Example16-7.rexx */

SAY 'Enter number of Times Table'
PULL number
SAY 'The' number 'times table'

DO x = 1 to 10
   SAY Number 'times' x '=' multiply(number,x)
END
EXIT

Multiply:
RETURN number*x
