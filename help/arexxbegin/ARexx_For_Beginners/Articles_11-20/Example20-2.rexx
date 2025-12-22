/* Example20-2.rexx                */
/* Copyright © 1995 Frank Bunton    */

/* How Many Days to a Given Date   */

DO FOREVER

  SAY 'c'x'Please enter a date at the prompts'

  /* The following DO-END loop asks the user to enter a year then calls  */
  /* "CheckDate" internal function to make sure it is a legitimate year. */
  /* "CheckDate" is sent two arguments -  The Year, Month or Day entered */
  /* Plus an indicator "Y", "M" or "D" to tell the function which type   */
  /* to check for. If "Result" is not "OK" then there has been an error  */
  /* in entry and loop must be iterated.                                 */

  /* Re the DO FOREVER loops for Year, Month, Date - we need keep going  */
  /* around these loops until a correct entry is made so use forever and */
  /* LEAVE only when correct entry made.                                 */

  DO FOREVER
    OPTIONS PROMPT 'a'x'Enter YEAR between 1978 and 2099 using 4 digits:  '
    PULL Year
    CALL CheckDate(Year,'Y')
    IF Result ~= 'OK' THEN ITERATE  /* error so do again      */
    ELSE LEAVE                      /* no error so go to next */
  END

  /* The next DO-END is the same as for year but gets a month */

  DO FOREVER
    OPTIONS PROMPT 'a'x'Enter MONTH using 1 or 2 digits:  '
    PULL Month
    CALL CheckDate(Month,'M')
    IF Result ~= 'OK' THEN ITERATE /* error so do again      */
    ELSE LEAVE                     /* no error so go to next */
  END

  /* The next DO-END is the same as for year but gets a day */

  DO FOREVER
    OPTIONS PROMPT 'a'x'Enter DAY using 1 or 2 digits:  '
    PULL Day
    CALL CheckDate(Day,'D')
    IF Result ~= 'OK' THEN ITERATE /* error so do again      */
    ELSE LEAVE                     /* no error so go to next */
  END

  /* Now we add a zero to the start of the month and day */
  /* if they are only 1 digit long                       */

  Month = RIGHT(Month,2,'0')
  Day = RIGHT(Day,2,'0')

  /* Next we build up string in "Date" symbol */
  /* to hold the full date in "Sorted" format */

  Date = Year||Month||Day

  D1   = DATE('I')           /* "Internal" days at current date */
  D2   = DATE('I',Date,'S')  /* "Internal" days at date entered */
  Diff = D2 - D1             /* Difference is number of days to date */

  /* Now display today's date as the weekday followed by "Normal" date */

  SAY 'a'x'Today''s date is' DATE('W') DATE('N')

  /* Now display entered date in same format but to do this we need to */
  /* tell ARexx to use the date entered (D2) in "Internal" format      */

  SAY 'Date entered is' DATE('W',D2,'I') DATE('N',Date,'S')

  /* Display the difference in the dates but if today's date entered */
  /* then tell user. */

  IF Diff = 0 THEN SAY 'You entered today''s date!!'
  IF SIGN(Diff) =  1 THEN SAY 'Which is' Diff 'days in the future'
  IF SIGN(Diff) = -1 THEN SAY 'Which is' ABS(Diff) 'days in the past'

  /* check if user wants another date check */

  OPTIONS PROMPT 'a'x'Another Date? (N or Y=Return)'
  PULL Which
  IF Which = 'N' THEN EXIT

END /* End of FOREVER loop */

CheckDate:
  ARG Number,Type

  /* Function to check the entries of the date                      */
  /* Each time this function is called, we send it two arguments:   */
  /* the number entered - a year, month or day and an indicator     */
  /* as to number type - 'Y' for year, 'M' for Month or 'D' for Day */

  /* Set up a DO FOR 1 loop. Even though it will be operated only once  */
  /* we need to have an iterative loop so that we can LEAVE it if there */
  /* is an error. No point in more checking once first error found!     */
  /* Note that this could be a lot simpler if we had already learned    */
  /* using SELECT...WHEN methods!                                       */

  DO FOR 1

    /* check for a legitimate positive integer */

    IF DATATYPE(Number,'W') = 0 THEN DO   /* is it a whole number? */
      Error = 'Entry not a valid number.'
      LEAVE
    END
    IF SIGN(Number) < 1 THEN DO           /* is it a positive number? */
      Error = 'Negative or Zero Number.'
      LEAVE
    END

    /* Check The Year Entered */

    IF Type = 'Y' THEN DO
      IF LENGTH(Number) ~= 4 THEN DO    /* was a 4 digit number entered? */
        Error = 'Year must have 4 digits.'
        LEAVE
      END
      IF Number < 1978 | Number > 2099 THEN DO
        Error = 'Year must not be less than 1978 or more than 2099.'
        LEAVE
      END
    END     /* End of Year Check */

    /* Check The Month Entered */

    IF Type = 'M' & Number > 12 THEN DO   /* more than 12 months!! */
      Error = 'Month must not be more than 12.'
      LEAVE
    END       /* End of Month Check */

    /* Check The Day Entered - This is more complex!! */

    IF Type = 'D' THEN DO

      /* First make sure not more than 31 days */

      IF Number > 31 THEN DO
        Error = 'Day' Day 'is incorrect for Month' Month
        LEAVE
      END

      /* now check for entry of 31 days for months 4, 6, 9 or 11 */

      IF Number > 30 & (Month = 4 | Month = 6 | Month = 9 | Month = 11) THEN DO
        Error = 'Day' Day 'is incorrect for Month' Month
        LEAVE
      END

      /* now check for > 28 days in Feb in a non leap year */

      IF Number > 28 & Month = 2 & Year//4 ~= 0 THEN DO
        Error = 'Day' Day 'is incorrect for February in Year' Year
        LEAVE
      END

      /* now check for > 29 days in Feb in a leap year */

      IF Number > 29 & Month = 2 & Year//4 = 0 THEN DO
        Error = 'Day' Day 'is incorrect for February in Year' Year
        LEAVE
      END
    END    /* End of Day Check */

    /* if reach here then all checks have come out O.K.    */
    /* So set Error symbol to 'OK'                         */
    /* but have to use LEAVE to escape the DO FOREVER loop */

  Error = 'OK'
/*   LEAVE */
END          /* end the do forever */

/* Now display the error message if there is one */

IF Error ~= 'OK' THEN SAY 'a'x'ERROR IN ENTRY!! -' Error
RETURN Error 

/* return to the main program with the value held by "Error" in the */
/* "Result" symbol so that main program can check for an incorrect  */
/* entry                                                            */
