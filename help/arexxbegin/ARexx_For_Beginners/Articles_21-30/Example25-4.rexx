/* Example25-4 */

ADDRESS 'COMMAND'

SAY 'a'x'First Go - FailAt is default 10'
CALL DoIt

OPTIONS FAILAT 0
SAY 'a'x'Second Go - FailAt is now 0'
CALL DoIt

OPTIONS FAILAT 21
SAY 'a'x'Third Go - FailAt is now 21'
CALL DoIt

OPTIONS FAILAT 10
SAY 'a'x'Fourth Go - FailAt is back to default 10'
CALL DoIt

EXIT

DoIt:
  'COPY >nil: Ram:Garbage-1 Ram:Garbage-2'
  'Delete >nil: Ram:Garbage-2'
RETURN
