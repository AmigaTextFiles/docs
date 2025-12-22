/* Example46-2 */

SIGNAL ON SYNTAX

Lines = SOURCELINE()

DO FOR X = 1 TO 10
  SAY 'X =' x
END

Syntax:
  SAY 'You have a syntax error!'
  SAY 'It is Error Number' RC 'in line number' Sigl
  SAY 'which is shown below in reverse video text.'||'a'x
  DO Count = Sigl-2 TO Sigl+2
    IF Count >0 & Count <= Lines THEN DO
      IF Count = Sigl THEN DO
        SAY 'Line' Count '1b'x'[7m'||SOURCELINE(Count)||'1b'x'[0m'
      END
      ELSE DO
        SAY 'Line' Count SOURCELINE(Count)
      END
    END
  END
  SAY 'a'x
