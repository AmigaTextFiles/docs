/* Example27-1.rexx */

DO x = 1 to 10
   SELECT
     WHEN x//2 = 0 THEN SAY x 'is even'
     WHEN x//2 = 1 THEN SAY x 'is odd'
   END
END
