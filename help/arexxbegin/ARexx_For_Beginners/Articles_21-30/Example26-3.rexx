/* Example 26-3 */

SAY 'First  call for directory of Garbage_Disk:'
CALL PRAGMA('D','Garbage_Disk:')
CALL PressReturn

SAY 'Second call for directory of Garbage_Disk:'
CALL PRAGMA('W','N')
CALL PRAGMA('D','Garbage_Disk:')
CALL PressReturn

SAY 'Third  call for directory of Garbage_Disk:'
CALL PRAGMA('W','W')
CALL PRAGMA('D','Garbage_Disk:')
CALL PressReturn

EXIT

PressReturn:
  SAY 'a'x'Press RETURN to continue.'||'a'x
  PULL Anything
  RETURN
