/* Example16-3.rexx */

SAY 'Enter number of Times Table'
PULL Number
SAY 'The' number 'times table'

DO x = 1 to 10
   SAY Number 'times' x '=' Multiply(Number,x)
END
EXIT

Multiply:
ARG m,n
RETURN m*n
