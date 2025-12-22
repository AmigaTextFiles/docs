/* Example10-13 */

SAY 'The 5 times table'

x = 1
DO FOREVER
   SAY 'Five times' x '=' x * 5
   x = x + 1
   IF x > 10 THEN LEAVE
END
