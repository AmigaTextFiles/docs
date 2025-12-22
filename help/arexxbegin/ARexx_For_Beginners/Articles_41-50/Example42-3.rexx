/* Example 42-3 */

SAY 'c'x'Now Using PUSH:-'||'a'x
DO x = 1 TO 6
  PUSH 'Line number '||x
  IF X = 3 THEN PUSH
END
SAY 'Lines waiting in STDIN =' LINES('STDIN')
CALL Output

EXIT

Output:
DO FOR 7
  PARSE PULL In
  SAY In
END
RETURN