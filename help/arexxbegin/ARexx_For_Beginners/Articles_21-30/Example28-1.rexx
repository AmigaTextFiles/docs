/* Example28-1.rexx */

/* Read the startup-sequence file from a disk */

OPTIONS PROMPT 'c'x'Which disk to read? (enter df0: etc.) '
PULL Drive
ExtFile = Drive||'s/startup-sequence'
IF EXISTS(ExtFile) = 0 THEN DO
   SAY 'That disk does not have a startup-sequence file '
   EXIT
END

CALL OPEN('LogFile',ExtFile)
SAY 'The disk in drive' Drive 'has this startup-sequence file '
SAY
DO WHILE EOF('LogFile') = 0
   SAY READLN('LogFile')
END
CALL CLOSE('LogFile')

