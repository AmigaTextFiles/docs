/*
**-----------------------------------------
** 
** AMIL_Contrib.rexx
**
** Contribute entries for AMIL.guide
**
** © 1996 Tassos Hadjithomaoglou
**
**-----------------------------------------
** $VER: AMIL_Contrib.rexx V0.2 (14-Sep-96)
**-----------------------------------------
**
** History
**
**  0.1 First release.
**  0.2 AmigaGuide keywords removed. They were confusing while editing.
**      Header text removed. Not really needed.
**
**------------------------------------------------------------------------
*/

/*
** Path for Editor
**
** Enter here the full path of an Editor of your choice.
** That's the only thing you should change.
** PS: The Editor should be able to run in SYNCHRONOUS mode
*/

Editor = 'C:Ed'


/*
** Please don't change anything after this line
**----------------------------------------------
*/

OPTIONS RESULTS

SIGNAL ON BREAK_C
SIGNAL ON SYNTAX

TRUE=1
FALSE=0

NL='0A'X

/*
** Check for argument, else ask for one
*/

FromAMIL = TRUE

PARSE ARG project

IF project = '' THEN
DO
	FromAMIL = FALSE

   SAY NL'Please choose a project to fill form for : 'NL
	SAY ' 1. Persons/People'
	SAY ' 2. Companies'
	SAY ' 3. Dealers'
	SAY ' 4. Groups/Teams'
	SAY ' 5. BBS'
	SAY ' 6. Mailing Lists'
	SAY ' 7. Newsgroups'
	SAY ' 8. Zines'
	SAY '10. WWW Resources'NL

   PARSE PULL project
   IF project = '' THEN
   DO
      SAY 'Contribution abandoned !!!'
      EXIT 0
   END
END

project = UPPER(project)

/*
** Footer Text
*/

ContribText_Footer=NL'*** mailto : chatasos@cs.teiath.gr ***'NL

/*
** Contribution Texts
*/

ContribText_Persons='Persons/People'NL ||,
NL ||,
'Person Name'NL ||,
' Company  : 'NL ||,
' E-Mail   : 'NL ||,
' WWW      : 'NL ||,
' IRC      : 'NL ||,
' Fidonet  : 'NL ||,
' Notes    : 'NL ||,
' Projects : 'NL


ContribText_Companies='Companies'NL ||,
NL ||,
'Company Name'NL ||,
' E-Mail     : 'NL ||,
' FTP        : 'NL ||,
' WWW        : 'NL ||,
' Fidonet    : 'NL ||,
' Activities : 'NL ||,
' Products   : 'NL


ContribText_Dealers='Dealers/Vendors'NL ||,
NL ||,
'Dealer Name'NL ||,
' E-Mail   : 'NL ||,
' FTP      : 'NL ||,
' WWW      : 'NL ||,
' Fidonet  : 'NL ||,
' Products : 'NL


ContribText_Groups='Groups/Teams'NL ||,
NL ||,
'Group Name'NL ||,
' E-Mail     : 'NL ||,
' FTP        : 'NL ||,
' WWW        : 'NL ||,
' Fidonet    : 'NL ||,
' Activities : 'NL ||,
' Projects   : 'NL


ContribText_BBS='BBS'NL ||,
NL ||,
'BBS Name'NL ||,
' Sysop    : 'NL ||,
' E-Mail   : 'NL ||,
' FTP      : 'NL ||,
' WWW      : 'NL ||,
' Telnet   : 'NL ||,
' Fidonet  : 'NL ||,
' Amiganet : 'NL ||,
' Notes    : 'NL ||,
' Lines    : 'NL


ContribText_Mailing='Mailing Lists'NL ||,
NL ||,
'Mailing List Name'NL ||,
' E-Mail      : 'NL ||,
' SubscribeAd : 'NL ||,
' SubscribeCm : 'NL ||,
' Mail        : 'NL ||,
' FTP         : 'NL ||,
' Notes       : 'NL


ContribText_Newsgroups='Newsgroups'NL ||,
NL ||,
'Newsgroup Name'NL ||,
' News      : 'NL ||,
' Notes     : 'NL ||,
' Moderator : 'NL


ContribText_Zines='Zines'NL ||,
NL ||,
'Zine Name'NL ||,
' E-Mail : 'NL ||,
' WWW    : 'NL ||,
' Editor : 'NL


ContribText_WWW='WWW Resources'NL ||,
NL ||,
'WWW Resource Name'NL ||,
' E-Mail : 'NL ||,
' WWW    : 'NL ||,
' Notes  : 'NL


/*
** Open the Contrib_file and 
** write the right ContribText_* to it
*/

bool1=OPEN(Contrib_file,'T:AMIL_Contrib.txt',W)

SELECT
	WHEN project='1' THEN DO
		WRITELN(Contrib_file,ContribText_Persons)
	END
	WHEN project='2' THEN DO
		WRITELN(Contrib_file,ContribText_Companies)
	END
	WHEN project='3' THEN DO
		WRITELN(Contrib_file,ContribText_Dealers)
	END
	WHEN project='4' THEN DO
		WRITELN(Contrib_file,ContribText_Groups)
	END
	WHEN project='5' THEN DO
		WRITELN(Contrib_file,ContribText_BBS)
	END
	WHEN project='6' THEN DO
		WRITELN(Contrib_file,ContribText_Mailing)
	END
	WHEN project='7' THEN DO
		WRITELN(Contrib_file,ContribText_Newsgroups)
	END
	WHEN project='8' THEN DO
		WRITELN(Contrib_file,ContribText_Zines)
	END
	WHEN project='10' THEN DO
		WRITELN(Contrib_file,ContribText_WWW)
	END
	OTHERWISE DO
		bool1=CLOSE(Contrib_file)
		ADDRESS COMMAND 'Delete T:AMIL_Contrib.txt QUIET'
		SAY 'Wrong choice !!!'
		EXIT
	END
END

WRITELN(Contrib_file,ContribText_Footer)

bool1=CLOSE(Contrib_file)

ADDRESS COMMAND Editor 'T:AMIL_Contrib.txt'

IF ~FromAMIL THEN
DO
	SAY NL'Contribution finished...'NL
	SAY 'Use your favorite mail program to open the file T:AMIL_Contrib.txt'
	SAY 'and send the contribution to me.'NL
END

EXIT 0

/*
** End of ARexx script
*/


/*
** Handle the Error condition
*/

SYNTAX:
	bool1=CLOSE(Contrib_file)
	ADDRESS COMMAND 'Delete T:AMIL_Contrib.txt QUIET'
	SAY 'Error at line' SIGL ':' ERRORTEXT(RC)
	SAY 'Please report it to the author'
	EXIT

/*
** Handle the Control C command given by the user
*/

BREAK_C:
	bool1=CLOSE(Contrib_file)
	ADDRESS COMMAND 'Delete T:AMIL_Contrib.txt QUIET'
	SAY 'Contribution aborted...'
	EXIT
