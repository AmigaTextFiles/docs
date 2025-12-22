/* Example29-2.rexx */

/* Names allocated at start of program */

Player.1.Name = "Jane"
Player.2.Name = "Tom"
Player.3.Name = "Dick"
Player.4.Name = "Mary"
Player.5.Name = "Harry"

/* Scores allocated by another part of program */

Player.1.Score = 123
Player.2.Score = 45
Player.3.Score = 319
Player.4.Score = 98
Player.5.Score = 545

/* Display Scores */

SAY "Results are:-"
DO x = 1 to 5
     SAY "Score for" Player.x.Name "is" Player.x.Score
END
