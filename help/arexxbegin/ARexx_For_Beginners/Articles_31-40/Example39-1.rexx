/* Example39-1 */

IF EXISTS('Libs:rexxsupport.library') = 0 THEN DO
  SAY 'c'x'Sorry - Your Libs: directory does not contain the rexxsupport.library file'
  EXIT
END

IF SHOW('L','rexxsupport.library') = 0 THEN DO
  CALL ADDLIB('rexxsupport.library',0,-30,0)
END

SAY 'c'x'Enter the name of the directory to view using its full path'
SAY 'or just press RETURN with no entry for the current directory.'
PARSE PULL DirName

IF DirName = '' THEN DirName = PRAGMA('D')

SAY 'a'x'Enter:  A - For Files and Directories'
SAY '        F - For Files only'
SAY '        D - For Directories only'

PULL Type

SAY 'a'x'Directory for' DirName 'is:-'||'a'x

SAY SHOWDIR(DirName,Type,'a'x)
