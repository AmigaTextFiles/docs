/*
**---------------------------------------
** 
** Library_Search.rexx V1.2 - 14.11.96
**
** Search Libraries.guide for keywords
**
** © 1996 Heiko Schröder         e-mail: age@thepentagon.com
** You need LIBS: RexxTricks.library
**
** Inspirations by Tassos Hadjithmomaoglou
** AMIL_Search.rexx V0.3  © 1995
**
**----------------------------------------
** $VER: Library_Search.rexx  V1.2 (14-Nov-96)
**----------------------------------------
**
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

R="0A"X
say "›32mSearchIn»Libraries.guide« V1.2 - © Heiko Schröder - 14.11.96 -›m"
say "›33mIf you use ·PowerGuide· you dont need this script."
say "Use instead the »Search«-Button...›m"||R
IF ~show('L',"rexxtricks.library") then do
   IF ~addlib('rexxtricks.library',0,-30,0) then do
      say "Sorry, but I need the rexxtricks.library in LIBS: ..."
      say "Copy it from Libs-Drawer at this directory"
      say "to your LIBS: directory."||R
      SAY "Press »Return« to end."
      PARSE PULL Keyword
      exit
   end
end

/*
** Check for Libraries.guide in current directory 
** If Libraries.guide is found then open it, else inform the user
*/

bool1=OPEN(AMIL_file,'Libraries.guide',"R")

IF bool1 = FALSE THEN
DO
   SAY '"Libraries.guide" wasn''t found in the current directory.'
   SAY "Press »Return« to end."
   PARSE PULL Keyword
   EXIT
END
AMIL_Path = 'LibGuide:Libraries.guide'

/*
** Check for argument, else ask for one
*/

PARSE ARG Keyword

IF Keyword = '' THEN
DO
   SAY 'Please input word to search for: (without wildcards) '
   PARSE PULL Keyword
   IF Keyword = '' THEN
   DO
      SAY 'Search abandoned !!!'
      EXIT 0
   END
END

SAY d2c(11)||'Searching for "'Keyword'"...'

/*
** Initialize variables
*/

Counter = 0
Node_Line = 0
Keyword_Line = 0
Node_Name = ''
AMIL_Line = ''

/*
** Create the Library_Search.guide
*/

if exists("c:search") then do
   address command "c:search >T:node search @node Libraries.guide"
   address command "c:search >T:word search "d2c(34)||Keyword||d2c(34)" Libraries.guide"
end
else do
   say "Sorry, but i need program »SEARCH« in the C: drawer!"||R
   SAY "Press »Return« to end."
   PARSE PULL Keyword
   exit
end

say "Creating the guide... Wait one second..."

open("test","T:word")
a=readln("test")
if eof("test") then call Ende
close("test")
ReadFile("T:node","liste")            /*Read the T:node in Stem-Variable*/
ReadFile("T:word","wordl")            /*Read the T:word in Stem-Variable*/

if wordl.0="0" then
   say "The "||Keyword||" was not found in Libraries.guide!"
else do
   bool1=OPEN(Search_file,'T:Libraries_Search.guide',W)

   WRITELN(Search_file,'@database Library_Search')
   WRITELN(Search_file,'@node "Main" "Library_Search V1.2  - 14.11.96 - by Heiko Schröder"')
   WRITELN(Search_file,'')
   WRITELN(Search_file,' The word "@{fg fill}'Keyword'@{fg text}" was found in the following lines:')
   WRITELN(Search_file,'')

   i=1
   z=1
   do while 1
      ist1  = liste.i
      ist   = Value(Compress(DelStr(ist1,7)))         /*Linenumber of @node*/
      n=i+1
      next1 = liste.n
      next  = Value(Compress(DelStr(next1,7)))        /*Linenumber of next @node*/
      zeile1= wordl.z
      zeile = Value(Compress(DelStr(zeile1,7)))       /*Linenumber of Keyword*/

      if next=0 then next=zeile+1                     /*found KeyWord after last @node*/

      if ist>zeile then do                            /*found KeyWord before @node*/
         z=z+1                                        /*next KeyWord*/
      end

      if zeile>next then do                           /*found KeyWord after next @node*/
         i=i+1                                        /*next @node*/
      end

      if ist<=zeile & zeile<=next then do             /*KeyWord between two @node s*/
         AMIL_Line = ist1                             /*read @node*/
         s1 = DELSTR(DELSTR(AMIL_Line,1,7),1,7)
         Node_Name = DELSTR(s1,INDEX((s1),'"'))
         Node_Line = ist

         Search_Line = Delstr(zeile1,1,7)             /*read KeyWord*/
         IF (LEFT(Search_Line,1) ~= '@') | (LEFT(Search_Line,2) = '@{') THEN
         DO
            Counter=Counter+1
            Keyword_Line = zeile - Node_Line
            wo=Index(Upper(Search_Line),Upper(KeyWord))
            l=Length(Keyword)
            vor=DelStr(Search_Line,wo)
            nach=DelStr(Search_Line,1,wo+l-1)
            AMIL_Search_Line = '@{"*" link "LibGuide:Libraries.guide/'Node_Name'" 'Keyword_Line'} 'vor||'@{fg shine}'||KeyWord||'@{fg text}'||nach
            WRITELN(Search_File,AMIL_Search_Line||R||COPIES('-',77))
         END
         z=z+1                                /*next KeyWord*/
         if z>wordl.0 then leave              /*end, if no more KeyWord was found*/
      end
   end
end

WRITELN(Search_file,"I have found "||Counter||" possibilities.")

WRITELN(Search_file,"@endnode")


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

SAY 'Running 'Viewer'...'||R
ADDRESS COMMAND 'Run >NIL: <NIL:' Viewer 'T:Libraries_Search.guide'
SAY "Press »Return« to end."
PARSE PULL Keyword
ADDRESS COMMAND 'Delete T:Libraries_Search.guide QUIET'
ADDRESS COMMAND 'Delete T:node QUIET'
ADDRESS COMMAND 'Delete T:word QUIET'
ADDRESS COMMAND 'Assign LibGuide: REMOVE'

EXIT 0

/*
** End of ARexx script
*/
Ende:
   say "Sorry, but »"||KeyWord||"« was not found."||R
   close("test")
	ADDRESS COMMAND 'Delete T:node QUIET'
	ADDRESS COMMAND 'Delete T:word QUIET'
   SAY "Press »Return« to end."
   PARSE PULL Keyword
   ADDRESS COMMAND 'Assign LibGuide: REMOVE'
   EXIT

/*
** Handle the Error condition
*/

SYNTAX:
	bool1=CLOSE(AMIL_file)
	bool1=CLOSE(Search_file)
	ADDRESS COMMAND 'Delete T:Libraries_Search.guide QUIET'
	ADDRESS COMMAND 'Delete T:node QUIET'
	ADDRESS COMMAND 'Delete T:word QUIET'
	SAY R||'Error at line' SIGL ':' ERRORTEXT(RC)
	SAY 'Please report it to the author'||R
   SAY "Press »Return« to end."
   PARSE PULL Keyword
   ADDRESS COMMAND 'Assign LibGuide: REMOVE'
	EXIT

/*
** Handle the Control C command given by the user
*/

BREAK_C:
	bool1=CLOSE(AMIL_file)
	bool1=CLOSE(Search_file)
	ADDRESS COMMAND 'Delete T:Libraries_Search.guide QUIET'
	ADDRESS COMMAND 'Delete T:node QUIET'
	ADDRESS COMMAND 'Delete T:word QUIET'
	SAY 'Search aborted...'||R
   SAY "Press »Return« to end."
   PARSE PULL Keyword
   ADDRESS COMMAND 'Assign LibGuide: REMOVE'
	EXIT
