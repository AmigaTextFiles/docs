/* Example29-1.rexx */

/* Scores allocated by another part of program */

Score.1 = 123
Score.2 = 45
Score.3 = 319
Score.4 = 98
Score.5 = 545

/* Display Scores */

SAY "Results are:-"
DO x = 1 to 5
   SAY "Player" x "Score = " Score.x
END
