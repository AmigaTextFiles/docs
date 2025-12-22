/* Example28-5.rexx */

/* Read the startup-sequence file from a disk */

OPTIONS PROMPT 'c'x'Which disk to read? (enter df0: etc.) '
PULL Drive
ExtFile = Drive||'s/startup-sequence'
IF EXISTS(ExtFile) = 0 THEN DO
   SAY 'That disk does not have a startup-sequence file '
   EXIT
END

CALL OPEN('LogFile',ExtFile)

OPTIONS PROMPT 'a'x'Send output to <W>indow or <P>rinter? '
PULL Which

IF Which = 'W' THEN DO
  SAY 'The disk in drive' Drive 'has this startup-sequence file '
  SAY
  DO WHILE EOF('LogFile') = 0
     SAY READLN('LogFile')
  END
END
ELSE DO
  IF Which = 'P' THEN DO
    CALL OPEN('PrtFile','Prt:','W')
    DO WHILE EOF('LogFile') = 0
      Line = READLN('LogFile')
      CALL WRITELN('PrtFile',Line)
    END
  END
  ELSE SAY 'You did not enter "W" or "P" - Try again'
END

CALL CLOSE('LogFile')
CALL CLOSE('PrtFile')
