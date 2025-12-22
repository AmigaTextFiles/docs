/* Example16-5.rexx */

Value1 = 'VALUE FROM EXAMPLE16-5'
SAY 'I am calling Example16-6 from Example16-5'
SAY 'and I am sending to it the value:-   ' Value1

CALL 'ARB:Articles_11-20/Example16-6.rexx' Value1
SAY 'a'x'I am back to 16-5 from 16-6'
SAY 'The result returned from 16-6 is:-   ' Result
