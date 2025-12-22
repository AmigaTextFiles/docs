/* Example10-8 */

DO x = 1 to 3
   SAY 'Loop Execution Number' x
   DO FOR x * 2
      SAY '*****'
   END
END
