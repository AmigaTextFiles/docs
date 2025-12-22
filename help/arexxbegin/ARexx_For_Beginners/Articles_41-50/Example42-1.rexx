/* Example 42-1 */

SAY 'c'x'Now Using PUSH:-'||'a'x
DO x = 1 TO 6
  PUSH 'Line number '||x
  IF X = 3 THEN PUSH
END
CALL Output

SAY 'a'x'Now using QUEUE:-'||'a'x
DO x = 1 TO 6
  QUEUE 'Line number '||x
  IF X = 3 THEN QUEUE
END
CALL Output

EXIT

Output:
DO FOR 7
  PARSE PULL In
  SAY In
END
RETURN