/* Example26-5 */

CALL PRAGMA('W','N')

/* programming requiring suppression of requesters */

CALL PRAGMA('W','W')

SAY 'c'x'For the purpose of this demonstration'
SAY 'Please make sure that there is a write protected blank disk in df0:'
SAY 'Press RETURN when ready'
PULL Anything

CALL OPEN('IntFile','df0:MyTestFile','W')
CALL WRITELN('IntFile','This is a line of garbage')
CALL CLOSE('IntFile')
