/* Example16-8 */

CALL TestFunction 'One',,'','Four'

EXIT

TestFunction:

Arguments = ARG()
SAY 'There are' Arguments 'arguments'

SAY 'a'x'First loop is:-'
DO Count = 1 TO Arguments
  SAY 'Argument' Count '=' ARG(Count)
END

SAY 'a'x'Second loop is:-'

DO Count = 1 to Arguments+1
  IF ARG(Count,'E') = 1 THEN SAY 'Argument' Count 'does exists'
  ELSE SAY 'Argument' Count 'does not exist'
END

SAY 'a'x'Third loop is:-'

DO Count = 1 to Arguments+1
  IF ARG(Count,'O') = 0 THEN SAY 'Argument' Count 'does exists'
  ELSE SAY 'Argument' Count 'does not exist'
END

RETURN
 
