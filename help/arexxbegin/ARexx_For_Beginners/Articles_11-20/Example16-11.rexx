/* Example16-11 */

/* Initialise the Program Symbols */

Win = 'You picked a WINNER'       /* String to say if win           */
Lose = 'Your choice was a FIZZER' /* String to say if lose          */
Heads = 0                         /* Keep track of number of heads  */
Tails = 0                         /* Keep track of number of tails  */
Wins = 0                          /* Keep track of number of wins   */
Losses = 0                        /* Keep track of number of losses */
HeadTail = RANDOM(,,TIME('s'))    /* record result of toss          */
YesNo =                           /* record yes or no response      */
Choice =                          /* record choice of H or T or Q   */

/* Main Program Loop */

DO forever
   SAY ; SAY 'Coin Toss Program' ; SAY
   SAY 'Enter your choice: H - Heads, T - Tails, Q - Quit'
   PULL Choice
   IF Choice = 'Q' THEN DO
      SAY ; SAY 'Quitting Program - Are you sure? (Y/N)'
      PULL YesNo
      IF YesNo = 'Y' THEN EXIT
      ELSE ITERATE
   END
   ELSE DO
      IF Choice ~= 'H' & Choice ~= 'T' THEN DO
         SAY 'Wrong entry - enter again'
         ITERATE
      END
      HeadTail = RANDOM(1,2)
      IF HeadTail = 1 THEN DO
         Heads = Heads + 1
         SAY 'The coin came up HEADS'
         IF Choice = 'H' THEN CALL Right
         ELSE CALL Wrong
      END
      ELSE DO
         Tails = Tails + 1
         SAY 'The coin came up TAILS'
         IF Choice = 'T' THEN CALL Right
         ELSE CALL Wrong
      END
   END

   Display_Results:

   SAY ; SAY 'Results to Date are:-' ; SAY
   SAY 'Number of Heads  =' Heads
   SAY 'Number of Tails  =' Tails
   SAY ; SAY 'Number of Wins   =' Wins
   SAY 'Number of losses =' Losses

END

EXIT

/* Functions */

Right:
   SAY Win
   Wins = Wins + 1
RETURN

Wrong:
   SAY Lose
   Losses = Losses + 1
RETURN
