/* Example28-2 */

Cls = "c"x
Down = "a"x

ExtFile = "ARB:Articles_21-30/Example28-2-100bytes"
IF EXISTS(ExtFile) = 0 THEN DO
   SAY Filename "is missing!"
   EXIT
END

CALL OPEN('LogFile',ExtFile,'R') /* Open file for reading */

Contents = READLN('LogFile') /* Read contents which are a single line */

Length = SEEK('LogFile',0,'E') /* Get length of file */

SAY Cls"File being read is" ExtFile
SAY "which is exactly" Length "characters, or bytes, long."
SAY "It does NOT have a line feed character at the end."
SAY "It's contents are equal to this single line:-"Down
SAY Contents

SAY Down"I will now set the marker at 4 with SEEK('LogFile',4,'B')"
SAY "and read the 4th character with READCH('LogFile')"
SAY "After READCH() the new marker position = 4 + 1 for the READCH()"
SAY "which I will read with SEEK('LogFile',0,'C')"

CALL SEEK('LogFile',4,'B')
SAY Down"4th character =" READCH('LogFile')
SAY "New marker spot is" SEEK('LogFile',0,'C')

CALL PressReturn

SAY "I will now set the marker at 3 past current spot"
SAY "with SEEK('LogFile',3,'C'). Marker is now 5 + 3 = 8th character"
SAY "I will read the 8th character with READCH('LogFile')"
SAY "After READCH() the new marker position = 8 + 1 for the READCH()"
SAY "which I will read with SEEK('LogFile',0,'C')"

CALL SEEK('LogFile',3,'C')
SAY Down"8th character =" READCH('LogFile')
SAY "New marker spot is" SEEK('LogFile',0,'C')

CALL PressReturn

SAY "I will now set the marker at 5 before current spot"
SAY "with SEEK('LogFile',-5,'C'). Marker is now 9 - 5 = 4th character"
SAY "I will read the 4th character with READCH('LogFile')"
SAY "After READCH() the new marker position = 4 + 1 for the READCH()"
SAY "will be read with SEEK('LogFile',0,'C')"

CALL SEEK('LogFile',-5,'C')
SAY Down"4th character =" READCH('LogFile')
SAY "New marker spot is" SEEK('LogFile',0,'C')

CALL PressReturn

SAY "I will now set the marker at 5 from the end"
SAY "with SEEK('LogFile',-5,'E')"
SAY "Note that the counting from zero starts at the null character"
SAY "to the right of the last real ""real"" character."
SAY "So the character read will be ""E"""
SAY "If we started counting at 0 from the start, this would be"
SAY "the 95th character which will be shown with SEEK('LogFile',0'C')"
SAY "After READCH() the new marker position = 95 + 1 for the READCH()"
SAY "will be read with SEEK('LogFile',0,'C')"

CALL SEEK('LogFile',-5,'E')
SAY Down"Marker position =" SEEK('LogFile',0,'C')
SAY "95th character =" READCH('LogFile')
SAY "New marker spot is" SEEK('LogFile',0,'C')

EXIT

PressReturn:

  SAY Down'Press RETURN To Continue'
  PULL Anything
  SAY Down'Contents of the file are:-'
  SAY Down||contents||Down

RETURN