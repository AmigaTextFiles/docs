/* Example27-4.rexx */

DO x = 0 to 5
   SELECT
     WHEN x = 1 THEN SAY x '= 1'
     WHEN x = 2 THEN SAY x '= 2'
     WHEN x = 3 THEN SAY x '= 3'
     OTHERWISE SAY x 'is not 1, 2 or 3'
   END
END
