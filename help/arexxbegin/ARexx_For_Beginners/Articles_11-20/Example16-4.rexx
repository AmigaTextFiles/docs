/* Example 16-4.rexx */

SAY 'Enter number of Times Table'
PULL Number
SAY 'The' Number 'times table'

DO x = 1 to 10
  CALL Multiply Number,x
  SAY Number 'times' x '=' Result
END
EXIT

Multiply:
  ARG m,n
RETURN m*n

