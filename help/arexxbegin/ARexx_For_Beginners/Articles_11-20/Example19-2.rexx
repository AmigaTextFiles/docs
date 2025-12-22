/* Example19-2.rexx */
/* Copyright © 1995 Frank Bunton */

/* Symbol Table */

Clear = 'c'x              /* clear the screen            */
Down = 'a'x               /* move cursor down one line   */
LMarg = copies(' ',23)    /* left margin 23 spaces       */
Item =                    /* user's selection from menu  */
Number = 0                /* number to convert           */
ErrMessage =              /* message re incorrect number */
/* Main Program Loop */

DO FOREVER

   SAY Clear||Down||CENTRE(' DECIMAL HEXADECIMAL CONVERTER ',77)

   SAY Down||LMarg 'Enter H for Hex to Dec'
   SAY LMarg 'Enter D for Dec to Hex'
   SAY LMarg 'Enter Q to Quit Program'

   PULL Item

   IF Item = 'Q' THEN EXIT
   IF Item ~= 'H' & Item ~= 'D' THEN DO
      SAY Down||LMarg 'Wrong selection!!'
      CALL PressAny
      ITERATE
   END

   /* Get and Test Number to Convert */

   SAY Down||LMarg 'Enter number to convert'
   PULL Number

   DROP ErrMessage
   IF Item = 'H' THEN DO
      IF LENGTH(Number) > 7 THEN ErrMessage = 'too large'
      IF DATATYPE(Number,'X') = 0 THEN ErrMessage = 'not hexadecimal'
   END
   ELSE DO
      IF DATATYPE(Number,'N') = 0 THEN ErrMessage = 'not a decimal number'
      ELSE DO
         IF DATATYPE(Number,'W') = 0 THEN ErrMessage = 'not an integer'
         IF SIGN(Number) = -1 THEN ErrMessage = 'negative'
         IF Number > 268435455 THEN ErrMessage = 'too large'
      END
   END

   IF SYMBOL('ErrMessage') = 'VAR' THEN DO
      CALL WrongNumber
      ITERATE
   END

   /* Convert & Display Number */

   IF Item = 'H' THEN SAY LMarg 'Hex' Number '= Dec' X2D(Number)
   ELSE SAY LMarg 'Dec' Number '= Hex' D2X(Number)
   CALL PressAny
END

/* End of DO FOREVER - Start of FUNCTIONS */

PressAny:
   SAY Down||LMarg 'Press any key to continue'
   PULL
RETURN

WrongNumber:
   SAY LMarg 'Number is' ErrMessage '- Try again'
   CALL PressAny
RETURN
