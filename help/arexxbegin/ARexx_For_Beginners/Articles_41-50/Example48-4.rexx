/* Example48-4 */

CALL TRACE('B')

COUNT = 0

DO FOREVER
  Count = Count + 1
  SAY 'Example48-4 has background tracing set. Count =' Count
END
