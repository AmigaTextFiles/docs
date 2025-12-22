/* Example56-2 - Script For Showing a Selected Amigaguide Node */

Down = 'a'x

NodeName.1   = 'AmigaDOS'
NodeName.1.1 = 'Amigados'
NodeName.2   = 'Arguments'
NodeName.2.1 = 'Arguments'
NodeName.3   = 'ASCII'
NodeName.3.1 = 'Ascii'
NodeName.4   = 'CLI and Shell'
NodeName.4.1 = 'CLI_&_Shell'
NodeName.5   = 'Directory Utilities'
NodeName.5.1 = 'DirUtility'
NodeName.6   = 'Format Of Instructions'
NodeName.6.1 = 'Format'
NodeName.7   = 'Inter Process Communication'
NodeName.7.1 = 'IPC'
NodeName.8   = 'Logical Devices'
NodeName.8.1 = 'Devices'
NodeName.9   = 'Public Domain'
NodeName.9.1 = 'PD'

/******************************
 * Add the amigaguide.library *
 ******************************/

IF ~EXISTS('Libs:amigaguide.library') THEN DO

  SAY 'Libs: directory does not contain the amigaguide.library file'
  EXIT

END

IF ~SHOW('L','amigaguide.library') THEN DO

  CALL ADDLIB('amigaguide.library',0,-30,0)

END

/*****************
 * Set file name *
 *****************/

FileName = 'ARB:Misc/Glossary'

/************************
 * Check if file exists *
 ************************/

IF ~EXISTS(FileName) THEN DO

  SAY Down||' 'FileName 'not found.'
  EXIT

END

/*****************
 * Get Node Name * 
 *****************/

DO FOREVER

  SAY Down'Press the number of the GLOSSARY item to read or Q to quit'Down

  DO Count = 1 TO 9 ; SAY '   'Count'. 'NodeName.Count ; END

  PULL Count

  IF UPPER(Count) = 'Q' THEN LEAVE

  IF Count < 1 | Count > 9 THEN DO

    SAY Down'Invalid number' count 'entered - try again'
    ITERATE

  END

  /*****************
   * Call Shownode *
   *****************/

  CALL SHOWNODE(,FileName,NodeName.Count.1,,)
  
END

CALL REMLIB('amigaguide.library')
