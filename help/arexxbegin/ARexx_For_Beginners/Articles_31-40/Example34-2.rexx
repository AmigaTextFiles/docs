/* Example34-2 */

Input  = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
Output = 'abcdefghijklmnopqrstuvwxyz'

DO FOREVER
  SAY 'Enter a string to convert to lower case or Q to quit'
  PARSE PULL String
  IF UPPER(String) = 'Q' THEN EXIT
  SAY 'String entered was :-' String
  SAY 'String converted is:-' TRANSLATE(String,Output,Input)
END
