/* Example16-10.rexx */

MyName = 'Fred Bloggs'
HisName = 'Jack Spratt'

SAY 'My  Name is' MyName
SAY 'His name is' HisName

CALL Function

SAY 'My  Name is' MyName
SAY 'His name is' HisName

EXIT

Function:
PROCEDURE EXPOSE HisName
MyName = 'Nothing'
HisName = 'Nothing'
RETURN
