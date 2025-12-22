/* Example33-6 */

SIGNAL ON SYNTAX

Start:
DO FOR X = 1 TO 10
  SAY 'X =' x
END

Syntax:
  SAY 'You have a syntax error!'
  SIGNAL Start:
