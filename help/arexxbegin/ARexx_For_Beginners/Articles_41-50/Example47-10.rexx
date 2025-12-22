/* Example47-10.rexx */

OPTIONS FAILAT 21

CALL TRACE('N')

ADDRESS 'COMMAND'

SAY 'Copying 1 real file'
'COPY S:Startup-Sequence Ram:'
'List Ram:Startup-Sequence'

SAY 'Copying 1 non existing file'
'COPY Ram:NonExistentCommand Ram:Nothing'

'Ram:NonExistentCommand'

SAY 'Checking assignment of NonExistentAssignment:'
'Assign NonExistentAssignment: Exists'

'Delete Ram:Startup-Sequence'