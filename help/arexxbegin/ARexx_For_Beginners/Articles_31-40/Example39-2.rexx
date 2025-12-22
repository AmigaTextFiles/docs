/* Example39-2 */

Clear     = 'c'x  /* Clear the window                             */
Count     =       /* Counter for loops                            */
DirName   =       /* Name of directory being read                 */
Dirs      =       /* List of sub directories from SHOWDIR()       */
Down      = 'a'x  /* Move cursor down one line                    */
Files     =       /* List of files from SHOWDIR()                 */
Last      =       /* Previous value of mark                       */
Left      =       /* Left hand marker position in parse           */
Mark      =       /* Counter for loop in function                 */
Name      =       /* Name of dir or file list passed to function  */
Name.     =       /* Names of directories or files in list        */
Number    =       /* Number of entries in Dirs or Files           */
Position  =       /* Number of position of marker in parse symbol */
Position. =       /* Position of marker in parse symbol           */
Right     =       /* Right hand marker in parse                   */

IF EXISTS('Libs:rexxsupport.library') = 0 THEN DO
  SAY Clear'Sorry - Your Libs: directory does not contain the rexxsupport.library file'
  EXIT
END

IF SHOW('L','rexxsupport.library') = 0 THEN DO
  CALL ADDLIB('rexxsupport.library',0,-30,0)
END

SAY Clear'Enter the name of the directory to view using its full path'
SAY 'or just press RETURN with no entry for the current directory.'
PARSE PULL DirName

IF DirName = '' THEN DirName = PRAGMA('D')
Dirs = SHOWDIR(DirName,'D',':')

IF Dirs = '' THEN DO
  Number = 1
  Name.1 = 'No sub directories in' DirName
END
ELSE CALL GetNames(Dirs)

SAY Down||Dirname 'contains these directories:-'||Down
DO Count = 1 to Number
  SAY '  'Name.Count
END

Files = SHOWDIR(DirName,'F',':')

IF Files = '' THEN DO
  Number = 1
  Name.1 = 'No files in' DirName
END
ELSE CALL GetNames(Files)

SAY Down||DirName 'contains these files:-'||Down
DO Count = 1 to Number
  SAY '  'Name.Count
END
SAY
EXIT

GetNames:

  PARSE ARG Name
  Number = 1
  Position = 1
  DO FOREVER
    Position.Number = INDEX(Name,':',Position)
    IF Position.Number = 0 THEN LEAVE
    Position = Position.Number + 1
    Number = Number + 1
  END

  Position.0 = 0
  Position.Number = LENGTH(Name) + 1
  DO Mark = 1 TO Number
    Last = Mark - 1
    Left = Position.Last + 1
    Right = Position.Mark
    PARSE VAR Name =Left Name.Mark =Right
  END
RETURN
