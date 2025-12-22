/* Example14-8.rexx */

DO x = 1 to 3
   DO y = 1 to 2
      IF x = 2 THEN BREAK
      SAY '  This is Y loop' y
   END
   SAY 'From X loop' x ; SAY
END
