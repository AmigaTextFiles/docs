/* Example27-3.rexx */

DO x = 1 to 5
   SELECT
     WHEN x = 1 THEN SAY x '= 1'
     WHEN x = 2 THEN SAY x '= 2'
     WHEN x = 3 THEN SAY x '= 3'
   END
END
