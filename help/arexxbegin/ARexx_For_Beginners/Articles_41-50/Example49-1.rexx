/* Example49-1 */

SAY 'Enter TRACE() mode to be used:-'
PULL Mode
CALL TRACE(Mode)

SAY 'Creating file called "Ram:A_Load_Of_Garbage"'

CALL OPEN('IntFile','Ram:A_Load_Of_Garbage','W')
WRITELN('IntFile','This is a file called "Ram:A_Load_Of_Garbage"')
CALL CLOSE('IntFile')

/* lots more programming */

CALL OPEN('IntFile','Ram:A_Load_Of_Garbage','W')

Count = 0
DO FOREVER
  Count = count + 1
  Line = 'Line' Count
  SAY 'Writing' Line
  SAY Line
  CALL WRITELN('IntFile',Line)
  IF Count < 4 THEN EXIT
END

CALL CLOSE('IntFile')
