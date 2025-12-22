/* Example31-2 */

NUMERIC DIGITS 6

Number1 = 1.2345
Number2 = 1.2399

DO FuzzNumber = 1 TO 5

  /* Set FUZZ and Display Settings */

  NUMERIC FUZZ FuzzNumber
  CompareDigits = DIGITS()-FUZZ()
  SAY 'a'x'The FUZZ setting is' FUZZ() 'which is' CompareDigits 'less than DIGITS Setting of' DIGITS()

  /* Ordinary Equality Comparisons */

  SAY 'a'x'For ordinary equality only the leftmost' CompareDigits 'digits will be used'
  SAY 'in the comparison so that:-'||'a'x
  IF Number1 = Number2 THEN SAY Number1 '=' Number2
  ELSE SAY Number1 '~= 'Number2

  /* Exact Equality Comparisons */

  SAY 'a'x'For exact equality FUZZ is ignored and all digits will be used'
  SAY 'in the comparison so that:-'||'a'x
  IF Number1 == Number2 THEN SAY Number1 '==' Number2
  ELSE SAY Number1 '~== 'Number2

  /* Press RETURN */

  SAY 'a'x'Press RETURN to continue'
  PULL Trash

END
