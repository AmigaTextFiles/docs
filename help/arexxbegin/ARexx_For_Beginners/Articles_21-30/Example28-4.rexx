/* Example28-4.rexx */

/* Typing Straight to Printer */

SAY 'c'x'Type in text to send to printer - press return at end of each line.'
SAY 'Enter "QUIT" then RETURN to exit the program'

CALL OPEN('PrtFile','Prt:','W')

DO FOREVER
  PARSE PULL Line
  IF UPPER(Line) = 'QUIT' THEN LEAVE
  CALL WRITELN('PrtFile',Line)
END

CALL CLOSE('PrtFile')
