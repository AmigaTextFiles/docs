/* Example34-1 */

String = 'abczzzdefzzghi'
Pattern = 'zz'

Count = 1
Position = 1

DO FOREVER

  Position.Count = INDEX(String,Pattern,Position)
  If Position.Count = 0 THEN LEAVE
  Position = Position.Count + 1
  Count = Count + 1

END

IF Count = 1 & Position.1 = 0 THEN DO
  SAY 'No matches found'
END
ELSE DO
  Count = 1
  DO FOREVER
    IF Position.Count = 0 THEN LEAVE
    SAY 'Match occurred at Position' Position.Count
    Count = Count + 1
  END
END
