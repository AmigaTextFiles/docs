/* Example47-11 */

CALL TRACE('L')

Start:
SAY 'This is the start of the program'

CALL Middle
SAY Result

End:
SAY 'This is the end of the program'

EXIT

Middle:
RETURN 'This is the middle of the program'
