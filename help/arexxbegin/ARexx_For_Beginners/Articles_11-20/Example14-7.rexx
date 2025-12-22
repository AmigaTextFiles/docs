/* Example14-7.rexx */

DO x = 1 to 10
   IF x//2 = 0 THEN DO
      SAY x 'is an EVEN number'
      IF x//4 ~= 0 THEN BREAK
      SAY x 'is also divisible by 4'
   END
END
