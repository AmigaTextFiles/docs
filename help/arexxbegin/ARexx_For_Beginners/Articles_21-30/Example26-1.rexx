/* Example26-1 */

SAY 'Current Directory is:' PRAGMA('D')

OPTIONS PROMPT 'Enter new directory name: '
PULL DirName

IF EXISTS(DirName) = 0 THEN DO
   SAY 'Directory you entered: ' DirName ' does not exist.'
   EXIT
END

CALL PRAGMA('D',DirName)
SAY 'Current Directory is:' PRAGMA('D')
