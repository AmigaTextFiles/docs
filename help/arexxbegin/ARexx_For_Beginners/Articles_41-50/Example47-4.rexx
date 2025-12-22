/* Example47-4 */

TRACE('A')
Count = 0

DO FOR 2

  SAY 'Count =' CountIt(Count) ' - Press CTRL-C to ABORT'

END
EXIT

CountIt:
Count = Count + 1
RETURN Count

