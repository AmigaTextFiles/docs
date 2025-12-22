/* Example14-1 */
/* Version 2 of Coin Toss Programm */

Correct = 'You won'
Wrong = 'You lost'
CALL RANDOM(,,TIME('S'))

DO FOREVER
  SAY ; SAY 'Coin Toss Program' ; SAY
  SAY 'Enter your choice: H - Heads, T -Tails,  Q - Quit'
  PULL Choice
  IF Choice = 'Q' THEN DO
     SAY ; SAY 'Quitting Program - Are you sure? (Y/N)'
     PULL yesno
     IF yesno = 'Y' THEN EXIT
     ELSE ITERATE
  END
  ELSE DO
     IF Choice ~= 'H' & Choice ~= 'T' THEN DO
        SAY 'Wrong entry - enter again'
        ITERATE
     END
     Headtail = RANDOM(1,2)
     IF Headtail = 1 THEN DO
        SAY 'HEADS'
        IF Choice = 'H' THEN SAY Correct
        ELSE SAY Wrong
     END
     ELSE DO
        SAY 'TAILS'
        IF Choice = 'T' THEN SAY Correct
        ELSE SAY Wrong
     END
  END
END
