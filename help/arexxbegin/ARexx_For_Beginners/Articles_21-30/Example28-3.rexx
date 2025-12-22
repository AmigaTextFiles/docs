/* Example28-3.rexx */

/* Strip end of line markers except those at end of paragraph */

SAY 'c'x'This program assumes the file is in the current directory'
OPTIONS PROMPT 'Enter name of file to strip excluding its path:  '
PARSE PULL ExtFile_In

IF EXISTS(ExtFile_In) = 0 THEN DO
  SAY 'a'x||ExtFile_In 'does not exist in current directory. Please try again.'
  EXIT
END

ExtFile_Out = TRIM(LEFT(ExtFile_In,25))||'.conv'

SAY 'a'x'Converted file will have the name' ExtFile_Out 'and will be in Ram:'

IF EXISTS('Ram:'||ExtFile_Out) = 1 THEN DO
  OPTIONS PROMPT 'a'x||ExtFile_Out 'already exists. Overwrite? (Y/N) '
  PULL Which
  IF Which = 'N' THEN DO
    SAY 'O.K. - Bye'
    EXIT
  END
END

CALL OPEN('LogFile_In',ExtFile_In)
CALL OPEN('LogFile_Out','Ram:'||ExtFile_Out,'W')

DO WHILE EOF('LogFile_In') = 0
  Line = READLN('LogFile_In')
  LineEnd = RIGHT(Line,1)
  WRITECH('LogFile_Out',Line)
  Char = READCH('LogFile_In')
  IF Char = 'a'x THEN WRITECH('LogFile_Out','a'x'a'x)
  ELSE DO
    IF LineEnd ~= '20'x THEN WRITECH('LogFile_Out','20'x)
    WRITECH('LogFile_Out',Char)
  END
END

CALL CLOSE('LogFile_In')
CALL CLOSE('LogFile_Out')

SAY 'O.K. - All done'
