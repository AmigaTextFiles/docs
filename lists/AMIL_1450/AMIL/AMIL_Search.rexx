/*
**---------------------------------------
** 
** AMIL_Search.rexx
**
** Search AMIL.guide for keywords
**
** © 1995-96 Tassos Hadjithomaoglou
**
**----------------------------------------
** $VER: AMIL_Search.rexx V0.3 (20-Nov-95)
**----------------------------------------
**
** History
**
**  0.1 First release.
**  0.3 Added searching in the current directory first and then in AMIL:.
**      That way the AMIL: assign is optional.
**      The search can be aborted anytime by pressing Control+C.
**
**-----------------------------------------------------------------------
*/

/*
** Path for Viewer
**
** Enter here the full path of an AmigaGuide Viewer of your choice
** That's the only thing you should change
*/

Viewer = 'SYS:Utilities/MultiView'

/*
** Please don't change anything after this line
**----------------------------------------------
*/

OPTIONS RESULTS

SIGNAL ON BREAK_C
SIGNAL ON SYNTAX

TRUE=1
FALSE=0

/*
** Check for AMIL.guide first in current directory and then in AMIL:
** If AMIL.guide is found then open it, else inform the user
*/

bool1=OPEN(AMIL_file,'AMIL.guide',R)

IF bool1 = FALSE THEN
DO
   SAY '"AMIL.guide" wasn''t found in the current directory.'

	bool1=OPEN(AMIL_file,'AMIL:AMIL.guide',R)

	IF bool1 = FALSE THEN
	DO
	   SAY '"AMIL.guide" wasn''t found in AMIL: either.'
   	SAY 'Please CD to the directory of AMIL.guide or'
      SAY 'set your AMIL: assign correctly and try again!!!'
	   EXIT
	END
   ELSE
   DO
		AMIL_Path = 'AMIL:AMIL.guide'
   END
END
ELSE
DO
	AMIL_Path = PRAGMA('D')
	IF INDEX(AMIL_Path,':') = LENGTH(AMIL_Path) THEN
		AMIL_Path = AMIL_Path'AMIL.guide'
	ELSE
		AMIL_Path = AMIL_Path'/AMIL.guide'
END

/*
** Check for argument, else ask for one
*/

PARSE ARG Keyword

IF Keyword = '' THEN
DO
   SAY 'Please input word to search for : '
   PARSE PULL Keyword
   IF Keyword = '' THEN
   DO
      SAY 'Search abandoned !!!'
      EXIT 0
   END
END

SAY 'Searching for "'Keyword'"...'

/*
** Initialize variables
*/

Counter = 0
Node_Line = 0
Keyword_Line = 0
Node_Name = ''
AMIL_Line = ''

/*
** Create the AMIL_Search.guide
*/

bool1=OPEN(Search_file,'T:AMIL_Search.guide',W)

WRITELN(Search_file,'@database AMIL_Search')
WRITELN(Search_file,'@node "Main" "AMIL_Search"')
WRITELN(Search_file,'')
WRITELN(Search_file,' The word "@{b}'Keyword'@{ub}" was found in the following nodes :')
WRITELN(Search_file,'')

DO UNTIL EOF(AMIL_file) = TRUE
   AMIL_Line = READLN(AMIL_file)
   Counter = Counter + 1

   IF LEFT(AMIL_Line,5) = '@node' THEN
   DO
      s1 = DELSTR(AMIL_Line,1,7)
      Node_Name = DELSTR(s1,INDEX((s1),'"'))
      Node_Line = Counter
   END

   IF (LEFT(AMIL_Line,1) ~= '@') | (LEFT(AMIL_Line,2) = '@{') THEN
   DO
      IF INDEX(UPPER(AMIL_Line),UPPER(Keyword)) ~= 0 THEN 
      DO
         Keyword_Line = Counter - Node_Line - 2
         AMIL_Search_Line = ' @{"'Node_Name'" link "'AMIL_Path'/'Node_Name'" 'Keyword_Line'}'
         /*
         **-------------
         ** example link 
         **----------------------------
         ** @{"Author" link "Author" 0}
         **----------------------------
         */
         WRITELN(Search_file,AMIL_Search_Line)
         WRITELN(Search_file,'   'AMIL_Line)
         WRITELN(Search_file,COPIES('-',75))
      END
   END
END

WRITELN(Search_file,'')
WRITELN(Search_file,'@endnode')

/*
** Close both files
*/

bool1=CLOSE(AMIL_file)
bool1=CLOSE(Search_file)

/*
** Check for Viewer or MultiView/AmigaGuide
*/

bool1 = EXISTS(Viewer)
IF bool1 = FALSE THEN
DO
   SAY Viewer 'wasn''t found.'
   SAY 'Trying MultiView/AmigaGuide...'
   bool1 = EXISTS('SYS:Utilities/MultiView')
   IF bool1 = FALSE THEN
   DO
      bool1 = EXISTS('SYS:Utilities/AmigaGuide')
      IF bool1 = FALSE THEN
      DO
         SAY 'MultiView/AmigaGuide weren''t found in SYS:Utilities !!!'
         EXIT
      END
      ELSE
      DO
         Viewer = 'SYS:Utilities/AmigaGuide'
      END
   END
   ELSE
   DO
      Viewer = 'SYS:Utilities/MultiView'
   END
END

/*
** View the results from the search
*/

SAY 'Running 'Viewer'...'
ADDRESS COMMAND 'Run >NIL: <NIL:' Viewer 'T:AMIL_Search.guide'

EXIT 0

/*
** End of ARexx script
*/

/*
** Handle the Error condition
*/

SYNTAX:
	bool1=CLOSE(AMIL_file)
	bool1=CLOSE(Search_file)
	ADDRESS COMMAND 'Delete T:AMIL_Search.guide QUIET'
	SAY 'Error at line' SIGL ':' ERRORTEXT(RC)
	SAY 'Please report it to the author'
	EXIT

/*
** Handle the Control C command given by the user
*/

BREAK_C:
	bool1=CLOSE(AMIL_file)
	bool1=CLOSE(Search_file)
	ADDRESS COMMAND 'Delete T:AMIL_Search.guide QUIET'
	SAY 'Search aborted...'
	EXIT
