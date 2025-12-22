/* Example 42-2 */

SAY 'c'x'Now Using PUSH:-'||'a'x
DO x = 1 TO 6
  PUSH 'echo "Line number '||x'"'
  IF X = 3 THEN PUSH
END

SAY 'a'x'Now using QUEUE:-'||'a'x
DO x = 1 TO 6
  QUEUE 'echo "Line number '||x'"'
  IF X = 3 THEN QUEUE
END
