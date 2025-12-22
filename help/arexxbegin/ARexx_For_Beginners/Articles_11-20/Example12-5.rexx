/* Example12-5 */
/* Version 1 of Coin Toss Program */

correct = 'You won'
wrong = 'You lost'
CALL RANDOM(,,TIME('s'))

SAY 'c'x'Coin Toss Program' ; SAY
SAY 'Enter your choice - H for Heads or T for Tails' ; SAY
PULL choice
IF choice ~= H & choice ~= T THEN DO
   SAY ; SAY 'Wrong entry'
   EXIT
END

headtail = RANDOM(1,2)
IF headtail = 1 THEN DO
   SAY ; SAY 'HEADS'
   IF choice = H THEN SAY correct
   ELSE SAY wrong
END
ELSE DO
   SAY ; SAY 'TAILS'
   IF choice = T THEN SAY correct
   ELSE SAY wrong
END
