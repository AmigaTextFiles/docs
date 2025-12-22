From megalith!CSAA2@uunet.UU.NET Sat Feb 12 02:01:45 1994
Received: from relay2.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.4)
	id AA21790; Sat, 12 Feb 94 02:01:41 PST
Received: from uucp5.uu.net by relay2.UU.NET with SMTP 
	(5.61/UUNET-internet-primary) id AAwcxk06021; Sat, 12 Feb 94 05:01:38 -0500
Received: from megalith.UUCP by uucp5.uu.net with UUCP/RMAIL
        ; Sat, 12 Feb 1994 05:01:40 -0500
Received: by megalith.miami.fl.us (V1.16.20/w5, Dec 29 1993, 21:22:55)
	  id <0jx5@megalith.miami.fl.us>; Sat, 12 Feb 94 04:20:27 EST -0500
Date: Sat, 12 Feb 94 04:20:27 EST -0500
Message-Id: <9402120419.0jx4@megalith.miami.fl.us>
Sender: errors@megalith.miami.fl.us
Errors-To: errors@megalith.miami.fl.us
Warnings-To: warnings@megalith.miami.fl.us
Return-Path: errors@megalith.miami.fl.us
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Reply-To: fnf@fishpond.cygnus.com (Fred Fish)
Message-Number: 696
Newsgroups: comp.sys.amiga.announce
Message-Id: <overlord.0jqp@megalith.miami.fl.us>
From: fnf@fishpond.cygnus.com (Fred Fish) (CSAA)
To: announce@megalith.miami.fl.us
Subject: Updated spec for Product-Info files - Fred Fish
Status: RO

This is an updated version of the specification for Product-Info files
for material submitted to me, or for material already in the library.
I encourage all authors of material already in the library to send me
Product-Info files for their material, to be used on the 1000 disk
archive CD-ROM.

Without a Product-Info file submitted by the author, I will have to
create a minimal one from the information in the "Contents" files.
This will probably be done by some sort of translation program, so it
may not be as complete or accurate as it could be if written by the
author.

The deadline for Product-Info files to reach me is probably going to
be about the end of March, but please send them before then if
possible.

Thanks!

-Fred

---------------------------------------------------------------------------

			 FishROM Database
			 ~~~~~~~~~~~~~~~~
			(Draft #5: 940205)

---------------------------------------------------------------------------

Synopsis of Changes in this Draft:

	1. If .Product-Info is not found, Product-Info is also considered a
	   valid product information file.  See (6) below.
	2. A NEW FIELD (.fullname) is now available.  It is optional but
	   should be used by applications that derive their common name
	   from and abbreviation of their full (complete) name.  As an
	   example, AIBB would have a .fullname of "Amiga Intuition Based
	   Benchmarks"  See the field descriptions, below.
	3. A NEW FIELD (.stored-in) is now available.  It describes where
	   and how the application is stored.  The generation of this field
	   requires some care because it may reference EITHER a directory
	   OR an (archive) file.  See the field descriptions, below.
	4. A NEW FIELD (.submittal) is now available.  It describes who
	   submitted the program or how it came to be placed into the
	   collection.  See the field descriptions, below.
	5. A NEW FIELD (.described-by) is now available.  It specifies who
	   created the Produc-Info file (all those fields) for the program.
	6. New .type keywords have been added according to a list that Fred
	   posted.  This list is open-ended but extensions should be made
	   with care.  Unrestrained expansion could neutralize the use of
	   this field.
	7. The description for the .version field has been altered to
	   indicate that the MAJOR.MINOR format is a suggestion, not a
	   rule.  What any program does with the information is anyhow
	   largely unspecified.  The specs laid down by this draft aim to
	   create law and order (... must be maintained at all times, Ja?)
	   but are NOT meant to impose needless and senseless restrictions.
	   NOTE: nothing hinders you from storing 20 lines of descriptive
	   text in the .version field or leave the .description field
	   entirely blank.  While KingFisher itself will give a hoot, the
	   user will be needlessly confused.  Stick as closely as POSSIBLE
	   to these guidelines to make the overall functionality more and
	   more reliable.

---------------------------------------------------------------------------

NOTE: This document contains some specific information on the KingFisher
      Database, as well as features and design choices of the KingFisher
      2.0 Server.

      The KingFisher 2.0 Server is a program to which client applications
      attach and from which clients may retrieve information.  This allows
      multiple clients nearly unrestrained access to multiple databases.
      Clients may have ARexx, CLI, and/or GUI interfaces, and may have a
      very specific or quite general purpose.


1. A KingFisher 2.0 database is described by a text file whose name ends in
   .kfdb (KingFisher DataBase.)  This file describes everything that the
   KingFisher Server needs to know about the database, especially the names
   of one or more database sections and what range of record numbers each
   contains, the names of primary and secondary index files, as well as
   some other, less vital, information.

2. A database consists of zero or more records spread over one or more
   files and indexed by a single (primary) index file.

3. Each record is an extended ASCII (text) file which may contain standard
   characters of the ISO Latin 1 character set (0x20..0xff) as is the
   standard Amiga symbol set, as well as the ASCII formatting character
   0x1a (newline.)  All other symbols in the range 0x00..0x1f are illegal
   for a record and may or may not produce erratic behavior.

   Expressly forbidden are the NUL (0x00) and the ^N (0x0e) as they have
   special meaning.

   Furthermore, a dot (.) is not permitted as the first character on a line
   unless it preceeds the name of a FIELD (see below.)  A dot leading text
   on a line (rather unusual) may be avoided without loss by placing a \
   (backslash) symbol immediately before it.  KingFisher's formatting
   functions will recognize and adjust for such occurrences, as well as
   other special formatting sequences that begin with a backslash.

   And last, but not least, a record begins with the character string
   ".name" (sans quotes) so that the start of the NEXT record can be easily
   determined by the appearance of this special key string.  No other field
   is special to KingFisher.

   Field name identifiers are not case sensitive.

4. KingFisher places between some records a special marker (^N (0x0e)) line
   to indicate breaks between disks.  This allows reindexing algorithms to
   properly recover information about disk references.  While the new
   .reference field makes this less necessary, it does help in carrying
   over older KingFisher Release 1 databases.

   Suggestion:	You could "misuse" this disk number scheme with a database
		of your own design by assigning it the concept of pages.
		Thus you could store text and filenames in a database and
		use the disk markers as new-page markers, all under the
		control of the KingFisher server, of course.

5. New records (fish) are added to the database at the end.  KingFisher
   maintains a database with variable size records and removal of records
   always truncates the database at that point.  Unlike the original
   KingFisher Release 1, however, the records so truncated will be removed
   from the database.  The interface to the server, however, would allow a
   client application to make prior backup arrangements of the records that
   it wants to delete, in order to undo the truncate operation again.

6. Information in the form of KingFisher Database Records (see (3) above)
   is to accompany an application in the form of a .Product-Info file.
   Unless client applications decide to use a different filename (STRONGLY
   discouraged!) the .Product-Info file is herewith a standard.

   As of draft #5, the leading period on the name .Product-Info is optional
   and may be omitted.  Programs parsing the directory tree should check
   for the presence of the .Product-Info file first, and if not found, try
   to load the Product-Info (no leading period) file.

7. When KingFisher Database Records are transported via electronic mail or
   otherwise embedded within unrelated text (i.e. with news headers and
   personal signatures following) the records MUST BE enclosed in special
   DATA TRANSPORT MARKERS that tell the parsing software what information
   is part of the records and what is not.  Multiple such records may be
   enclosed by only a single pair of markers, or multiple records may be
   enclosed each by a pair of markers with unrelated text before, after,
   and between the markers.

   If a file is being parsed which begins with a line less than or equal to
   30 characters in length, and does not have a special DATABASE HEADER,
   then KingFisher assumes this file to be a KingFisher Release 1 database.
   This assumption can be false, so it remains the user's responsibility to
   assure that no garbage is fed to the parser.

   Note that the DATA TRANSPORT MARKERS are not meant for use in the
   .Product-Info files, although they will be ignored if found.  They would
   simply be wasted, there.

   The following examples are to be read as complete files between the
   lines that look like this: ---------------

   Example 1:  A file containing text in addition to the database record.

	----------------------------------------
	Hello, Joe.  Here is the description of that weird game
        I was telling you about.  See if you can figure out how
        to win this.  Good luck!

	.BEGIN-FISH-DESCRIPTION
	.name
	MonkeyCommand
	.author
	KingKong Industries
	.description
	Lure the lovestruck monster ape back to his island.
	Tools include Fay Wray's torn nightgown, a Fokker
	airplane (you get to pilot it), a compass and a map.
	.path
	FishROM001:games/MonkeyCommand/
	.END-FISH-DESCRIPTION	
	----------------------------------------

   Example 2:  A file containing nothing but two database records.

	----------------------------------------
	.name
	MonkeyCommand
	.author
	KingKong Industries
	.description
	Lure the lovestruck monster ape back to his island.
	Tools include Fay Wray's torn nightgown, a Fokker
	airplane (you get to pilot it), a compass and a map.
	.path
	FishROM001:games/MonkeyCommand/
	.name
	MonkeyCommand II
	.author
	KingKong Industries
	.description
	Keep the captured ape from assaulting the defenses
	of the prison that was erected at the conclusion of
	MonkeyCommand I.  The action consists of coordinating
	the actions of four native tribal leaders and their
	vassals in repairing the damage done by the rampant
	beast.
	.path
	FishROM002:games/MonkeyCommand2/
	----------------------------------------

   Example 3:  A file containing two database records interspersed with
               extraneous text.  The records are protected by DATA
               TRANSPORT MARKERS

	
	----------------------------------------
	Hi Tom,

	Remember that monkey game you told my about?

	.BEGIN-FISH-DESCRIPTION
	.name
	MonkeyCommand
	.author
	KingKong Industries
	.description
	Lure the lovestruck monster ape back to his island.
	Tools include Fay Wray's torn nightgown, a Fokker
	airplane (you get to pilot it), a compass and a map.
	.path
	FishROM001:games/MonkeyCommand/
	.END-FISH-DESCRIPTION

	Well, seems that one wasn't enough and they released
	another one.  We'll have to figure out how to finally
	beat the first one, it seems, before they let us play
	the next.  Maybe we can look through the binary to find
	that code phrase.  Here's the text:

	.BEGIN-FISH-DESCRIPTION
	.name
	MonkeyCommand II
	.author
	KingKong Industries
	.description
	Keep the captured ape from breaking through the defenses
	of the prison that was erected at the conclusion of
	MonkeyCommand I.  The game consists of coordinating the
	actions of four native tribal leaders and their vassals
	in repairing the damage done by the angry beast.
	.restriction
	You need the secret code from the first MonkeyCommand
	which you can only get if you won the game.
	.path
	FishROM002:games/MonkeyCommand2/
	.END-FISH-DESCRIPTION

	(=:Joe:=)
	----------------------------------------

9. The following describes a list of STANDARD fields for the KingFisher 2.0
   database.  Please note that every field begins with a period to
   distinguish it from the field contents.  KingFisher has some very
   specific ideas about what these STANDARD fields may contain.  It is
   important, therefore, that you follow these guidelines.

   In most fields, text on multiple physical lines is considered to be the
   same as if it was all on one long line.  Newlines are simply treated as
   a whitespace.  If you wish to insert special formatting symbols, please
   refer to the section below, titled FORMATTING SYMBOLS, for more
   information.

   While it is possible to omit any field, even those not marked OPTIONAL,
   it is highly recommended to follow the established guidelines!  If
   additional fields are needed because you wish to offer information that
   does not fit within the framework of the existing fields, you are
   perfectly welcome to create additional fields!  They will always be
   treated like free format fields.

================================================================
.name
	PURPOSE:	The proram's name
	FORMAT:		1 line only
	EXAMPLE:	KingFisher
	EXAMPLE:	HomeBase VI
	EXAMPLE:	AIBB
	EXAMPLE:	gcc
	----------------------------------------------------------------
.fullname
	<<<OPTIONAL>>>
	PURPOSE:	The program's full (or complete) name
	FORMAT:		1 line only
	EXAMPLE:	Amiga Intuition Based Benchmarks
	EXAMPLE:	GNU C Compiler
	NOTES:		If the .name is not an abbreviation then omit the
			.fullname.  No sense in giving the name twice!
	----------------------------------------------------------------
.type
	PURPOSE:	A keyword that describes the nature of the program
	FORMAT:		Preferrably a single word or two.
	EXAMPLE:	Database
	EXAMPLE:	Spreadsheet
	EXAMPLE:	Animation Player
	EXAMPLE:	Animation Tools
	EXAMPLE:	Communications
	EXAMPLE:	Display Commodity
	EXAMPLE:	Mouse Commodity
	NOTES:		Avoid abbreviations.  Refer to the list below for
			suggestions.
	----------------------------------------------------------------
.short									<@>
	<<<OPTIONAL>>>
	PURPOSE:	A one-line description, preferrably not exceeding
			40 characters in length.  This description is to
			give a single-glance insight into the program's
			purpose.
	FORMAT:		1 line only.
	EXAMPLE:	Software catalog/search/maintenance tool, multi-user.
	----------------------------------------------------------------
.description
	PURPOSE:	A full-text description of your program, containing
			anything that is NOT ALREADY available through the
			other fields (see above and below.)  The reader
			should gain a good understanding what your program
			can and cannot do.  If you mention other programs
			please do not forget to provide a .reference field
			for each such mention.
	FORMAT:		Any number of lines, treated as one line.
			Formatting is permitted, but generally discouraged.
	NOTES:		Do not indent your text if you choose to format
			your text into multiple paragraphs.  Do not use \t
			as a tab.  Leave paragraph formatting to KingFisher.
	----------------------------------------------------------------
.version
	PURPOSE:	The program's version number
	FORMAT:		MAJOR.MINOR
			1 line only
	EXAMPLE:	37.100
	NOTES:		Please note that the Commodore guidelines specify
			that the number after the period is NOT a FRACTION
			but rather a WHOLE NUMBER!  Thus, the following is
			a valid progression:
				37.1  37.17  37.39  37.100  37.170
			The following are all vastly different versions:
				37.1  37.10  37.100  37.1000
	NOTES:		The format given for this field is really more of a
			SUGGESTION rather than a RULE.  There is no reason
			why you can't store "Today's Version" or "v940205"
			instead of 18.173.  In an ideal world everyone
			would use Commodore guidelines, but there are
			enough exceptions.
	----------------------------------------------------------------
.date
	PURPOSE:	The program's official release date; not the date
			it made it into the database.
	FORMAT:		year.month.day
			1 line only
	EXAMPLE:	1993.09.27
	NOTES:		The date format is chosen to be easily sortable.
			Note the use of leading zeros in month and day.
			The full year is to be given in anticipation of
			the coming change to a new millenium.
	----------------------------------------------------------------
.author
	PURPOSE:	Any and all authors who have a part in the program
	FORMAT:		Any number of lines, treated as one line (\n in the
			text will "break up" the line into multiple visual
			lines.)
	EXAMPLE:	Joe R. User, Tea Rexx.
	EXAMPLE:	J. Jones\n
			Random Hacker\n
			B. Clinton
	NOTES:		Addresses should be placed in the .address field.
			There should be only one .address field for each
			.author field.
			If more than 1 .author field is specified, then the
			same number of .address and .email fields must also
			be given in a 1-to-1 relationship (i.e. the 3rd
			.author field must be associated with the 3rd
			.address, and the 3rd .email field.)
			EX: see the example "Joe R. User, Tea Rexx" above;
			Assume that Joe R. User has long vanished and no
			known address, but that Tea Rexx has supported the
			program for a while.  If an .address and/or .email
			field is available for Tea Rexx, then you must
			specify EMPTY .address and/or .email fields for the
			author listed BEFORE the ones for Tea Rexx.
			Likewise, if the two authors names were reversed,
			you would NOT have to specify blank .address and/or
			.email fields for the second author.  I hope that
			makes sense.
	----------------------------------------------------------------
.restrictions
	PURPOSE:	List restrictions placed upon this program.  These
			should indicate in which way this program has been
			made dysfunctional (for demo purposes), problems
			(bugs) known to exist with this program, or any
			other thing that lets the user know that this
			program, as seen in this distribution, may not
			fully satisfy the user in some form.
	FORMAT:		Free form; see .description for more info.
	EXAMPLE:	Demo version has SAVE and PRINT options disabled.
	EXAMPLE:	The ReadOperatorsMind command fails to work with
			CDTV units.  Incompatible with the Discus Ejector
			utility.
	EXAMPLE:	Crashes if iconified while loading a sample or
			image larger than 64K.
	EXAMPLE:	Requires a PAL display.
	EXAMPLE:	The program is in German but the documentation
			offers translations into English and Swahili on
			a menu-by-menu and gadget-by-gadget basis.
	NOTES:		Do NOT use this field for things like "won't work
			with KS 1.3" or "won't run with less than 2 Megs
			of RAM."
	----------------------------------------------------------------
.requirements
	PURPOSE:	List requirements for your program.  These should
			give the reader enough information to determine if
			the software will run on his/her system or not.
			Be sure to specify operating system versions,
			(hard)disk space requirements, etc.  If your
			program requires any external libraries that are
			not part of the system software, it would be nice
			to list them here and comment on whether or not
			they are included in the archive.
			If your program is known to run on every existing
			(Amiga) platform, state this in this field!
	FORMAT:		Free form; see .description for more info.
	EXAMPLE:	68020, 68030, or 68040 CPU; 3M free RAM; 18M disk
			space; at least 640x480 display capabilities!
	EXAMPLE:	Requires WB2.1 (V38)
	EXAMPLE:	Requires 1024x768 (or larger) display capability.
	EXAMPLE:	Works only with 4096-channel, 230db BLAZETHUNDER
			Audio board.
	EXAMPLE:	Requires MUI (MagicUserInterface) version 5.
	----------------------------------------------------------------
.reference
	<<<OPTIONAL>>>
	PURPOSE:	Full path to where this program's files are stored,
			as well as the version that is stored there.
	FORMAT:		2 lines per reference:  the first line specifies
			the full path (with trailing slash) and the second
			line, the version.
	NOTES:		Multiple such fields may be provided to reference
			previous versions of this program, as well as
			other programs that might be of interest.  The
			versions should be listed in reverse chronological
			order and should NOT include the current entry.
			If this is an original entry and you make no
			references to other programs anywhere, them omit
			this field.
			Please note that it is VERY VERY VERY important
			that you specify the CORRECT PATH!  Without a
			correct path, this entry will be nearly useless!
	EXAMPLE:	FishROM-0002:Productivity/Databases/HomeBase VI/
			417.0
			FishROM-0001:Productivity/Databases/HomeBase VI/
			415.12
----------------------------------------------------------------
.distribution						was: .status in rev 1
	<<<OPTIONAL>>>
	PURPOSE:	Describes the distribution and ownership status
			of this software.  Please see below for a list of
			common (and recommended!) terms to use.
	FORMAT:		1 line
	EXAMPLE:	Shareware
	NOTES:		Please see the table below for descriptions of the
			recommended terms.
	----------------------------------------------------------------
.price
	<<<OPTIONAL>>>
	PURPOSE:	Describes the cost of this program to the user.
	FORMAT:		Any number of lines, treated as one line.
	EXAMPLE:	$50(US), DM75.
	NOTES:		In order to make this field more useful, it is
			strongly recommended that the first currency
			listed is United States Dollars as shown in the
			EXAMPLE above.  This allows a search to be limited
			to a common price base.  If you charge no money
			for this program, omit this field!
	----------------------------------------------------------------
.address
	<<<OPTIONAL>>>
	PURPOSE:	Describe a full postal address of the author, to
			be used if it becomes necessary or desirable to
			contact the author.  Do not specify the author's
                        name, as this is already in the .author field.
	FORMAT:		Multiple lines; formatting symbols \n are not
			required, as physical line breaks are equivalent.
	NOTES:		SEE THE .author FIELD FOR IMPORTANT INFORMATION
	----------------------------------------------------------------
.email
	<<<OPTIONAL>>>
	PURPOSE:        Describe a full electronic mail address.  Make
			sure that this address is complete and reachable
			even from less well-connected sites.  The author
			of KingFisher, for example, can be reached as
			walrus@wam.umd.edu
			It would be an error to specify only "walrus" or
			"walrus@wam" even though these will work within
			the particular organization where this address
			is valid.
	FORMAT:		Multiple lines; formatting symbols \n are not
			required, as physical line breaks are equivalent.
	NOTES:		You may specify multiple electronic mail addresses
			in order of decreasing reliability and permanence,
			each on its own line.
			SEE THE .author FIELD FOR IMPORTANT INFORMATION
	----------------------------------------------------------------
.exectype
	<<<OPTIONAL>>>
	PURPOSE:	Describe the type of executable(s) that make up
			your program.  Examples:  68xxx, AMOS, Script,
			ARexx, Compiled basic, Amigabasic, etc.
	FORMAT:		Free form; see .description for more information.
	EXAMPLE:	AMOS
	EXAMPLE:	68000, 68020, and 68040.
	----------------------------------------------------------------
.installsize
	<<<OPTIONAL>>>
	PURPOSE:	Indicate the minimum and maximum sizes of the
			executable as it is installed.  The minimum size
			should give an indication of how much diskspace
			is required for a minimal installation (perhaps
			lacking help files and miscellaneous tools) while
			the maximum size should indicate the absolutely
			highest amount of diskspace required by the
			program.
	FORMAT:		1 or more lines; Only the first line has a fixed
			format, the rest are free-form.  See examples.
			Always indicate the number scales with a capital
			K (for kilobyte) or M (for megabyte)
	EXAMPLE:	220K - 2M
			Most of the database files can be kept on floppy
			disks, so valuable harddisk space is not wasted.
	EXAMPLE:	18K
	EXAMPLE:	38K - 500K
			Lots of documentation and example scripts make up
			the bulk of the installation.
	----------------------------------------------------------------
.source
	<<<OPTIONAL>>>
	PURPOSE:	Describe what source code is available with this
			program.  If source code is not available then
			omit this field.  The .construction field often
			helps further identify the type of source if you
			omit details here.  How large is the source?
	FORMAT:		Free form; see .description for more information.
	EXAMPLE:	SAS/C,Manx,DICE source (750K) available for $15
	EXAMPLE:	Oberon source included.  85K
	EXAMPLE:	Limited C source (15K) included.
	EXAMPLE:	All source plus custom libraries, included: 12MB
	----------------------------------------------------------------
.construction
	<<<OPTIONAL>>>
	PURPOSE:	Describe the type of language(s) used to create
			this program and the methods used to build the
			final executable.  If possible, include the
			compiler version(s) and possibly important
			options, such as optimization.
	FORMAT:		Free form; see .description for more information.
	EXAMPLE:	SAS/C++ 6.5 with full optimization.
	EXAMPLE:	AdaEd.
	EXAMPLE:	Fortran with self-made compiler.
	EXAMPLE:	AMOS
	----------------------------------------------------------------
.tested
	<<<OPTIONAL>>>
	PURPOSE:	Give an indication of which configurations have
			served as test environments.
	FORMAT:		Free form; see .description for more information.
	EXAMPLE:	A500(512K Chip, 0K Fast, 1 Floppy), A2000(1M Chip,
			2M Fast, 40M HD, 1 Floppy); not tested on 68020+
			CPUs.
	EXAMPLE:	A1000, A500, A600, A2000, A2000/30, A3000, A1200,
			A4000/30, A4000/40 with various amounts of Chip
			and Fast RAM, with and without MMU or FPU.  Found
			to be free of Enforcer hits and able to work with
			virtual memory products; compatible with Retina,
			EGS/Spectrum, and Picasso software.  Also tested
			under V33 through V40 system software.
	----------------------------------------------------------------
.run
	<<<OPTIONAL>>>
	PURPOSE:	Specifies how to start the program.
	FORMAT:		visible=type,command
			Where 'type' is either WB or CLI to indicate the
			required startup environment.
	EXAMPLE:	HomeBase VI=WB,HomeBase VI
			HomeBase VI=CLI,ExecuteMe.HB6
			HomeBase VI Fixer=CLI,ExecuteMe.HB6Fixer
	EXAMPLE:	FishTub=WB,ExecuteMe
	NOTES:		KingFisher requires that this entry strictly
			follows the above format.
			The user is shown all text up to the first equal
			sign (the 'visible' portion.)  The 'type' portion
			must be terminated with a comma (,) and following
			it will be the command to be executed.
			Selecting it will either invoke the program from
			the Workbench (invoking it as if double clicked on
			its icon (if the .info file exists), or execute the
			indicated shell command line as if it has been
			typed at an open console window.
	----------------------------------------------------------------
.docs
	<<<OPTIONAL>>>
        PURPOSE:        List all documentation files, possibly for viewing
                        from within KingFisher for more detailed info.
        FORMAT:         1 line per file
        EXAMPLE:        HomeBase.guide
                        HomeBase.dvi
                        HomeBase.doc
        NOTES:          KingFisher examines the EXTENSION and invokes the
                        appropriate viewing tool: MultiView/AmigaGuide for
                        .guide files, ShowDVI for .dvi files, more for
                        anything else.  These files can also be sent to the
			printer via KingFisher (i.e. print .ps or .doc
			files.)  KingFisher will honor the PAGER
			environment variable (defaults to 'more') to
			display standard text.
	NOTES:		Omit any path to these files, unless it is a
			relative path from within the program's CD-ROM or
			disk directory.  Do not specify these files if
			they are located within archive files; remember:
			the files must exist as they are given here!
	----------------------------------------------------------------
.described-by
	<<<OPTIONAL>>>
	PURPOSE:	Specifies who created the description (Product-Info
			file) for the program.
	FORMAT:		Free form; should include an electronic mail
			address, too, if available.
	EXAMPLE:	Fred Fish (fnf@fishpond.cygnus.com)
	EXAMPLE:	Udo Schuermann <walrus@wam.umd.edu>
	----------------------------------------------------------------
.submittal
	<<<OPTIONAL>>>
	PURPOSE:	Identifies who submitted the program to Fred or
			else how this program came to be on the reference
			disk.
	FORMAT:		Free form; usually one line.
	EXAMPLE:	Submitted on disk directly by the author.
	EXAMPLE:	Downloaded from wuarchive.wustl.edu in pub/aminet/util/misc
	----------------------------------------------------------------
.stored-in
	PURPOSE:	Specifies where and especially HOW the application
			is stored.  This field should specify EITHER the
			name of a directory (ending with a : or a /) OR the
			name of a file (one that does NOT end with : or /)
	FORMAT:		1 or more lines.
	EXAMPLE:	FF1000:Disks701-1000/Disks941-960/Disk950/Enforcer/
			FF1000:BBS/Disks501-1000/Disks941-960/Disk950/Enforcer.lha
	NOTES:		It is up to the particular application to decide
			how to handle this information.  If the extension
			on the file is .lha, .lzh, .Z, .zoo, .pak, .zip,
			etc. then you could, for example, call upon the
			archiver of choice to unpack the application into a
			temporary directory and let the user run the
			program or list the files, or whatever.
	----------------------------------------------------------------
.path
	***** RESERVED FOR INTERNAL USE *****
	PURPOSE:	Specifies absolute path to THIS program, much like
			a .references entry, but without version.  This
			keeps things cleaner and allows electronically
			distributed updates (in text form) to transfer
			information otherwise found out and determined only
			through the add-fish mechanism of the tree-walk on
			the CD-ROM.  (If you understand what is meant by
			this, I'll buy you a drink!)
	FORMAT:		1 line path to the application on the CD-ROM.
			This is the same path as where the .Product-Info
			file was found (i.e. the file you as the submitter
			are to generate using these guidelines.)
	NOTES:		DO NOT SPECIFY THIS YOURSELF (i.e. in a Product-Info
			file.)  KingFisher writes this entry during a
			Database Export operation and reads it during a
			Database Import operation.  KingFisher ignores this
			field during a Database Build operation, so it is a
			total waste except when used during export/import
			operations!  AddFish makes no use of this field.
================================================================

FORMATTING SYMBOLS

KingFisher is font sensitive and able to adapt its display to proportional
fonts as well as non-proportional ones.  If you introduce formatting
symbols you may severely limit KingFisher's ability to effectively display
information for your program.  We ask you, therefore, to exercise restraint
and care.

	\\	A single \ (backslash) symbol.
	\n	End of paragraph.  Text following this symbol is forced
		to the beginning of the next visible line.  Fixes all \=
		tab definitions into place.  The next \= will cause all
		tabs to be cleared and a new one to be set.
	\=	Sets a tab at the current horizontal position.  The next
		\n will fix these tabs into place and prevent further
		additions.
	\t	Tabs to the next tab, regardless if this tab is to the
		left or right of the cursor position!  Do not use tabs
		for paragraph indentation!  Do not indent paragraphs.
	\.	A single . (dot) especially useful if/when such a dot is
		found (against normal practice) at the very beginning of
		a line of text and would then be misunderstood to repre-
		sent a field-name-specifier.

Do not introduce other formatting sequences as future versions of
KingFisher may create new ones for special purposes.

================================================================

EXAMPLES OF "TYPE" WORDS

Action Game		Animation		Animation Player
Animation Tool		Archiver		CLI Tool
Communications		Compiler		Compression
Database		Disk Tool		Display Commodity
Drawing			Image Conversion	Image Processing
Library			Mouse Commodity		Music Composition
OS Utility		Painting		Picture
Printing		Sound Analysis		Sound Editing
Sound Playing		Spreadsheet		Strategy Game
Text			Text Editing		Text Viewer
Thinking Game		Word Processing		Workbench Tool

================================================================

LIST OF SOFTWARE STATUS KEYWORDS

	Commercial	Commercial software is owned and distributed
			through licenses.  It costs money to individual
			end-users and is not freely distributable.
			SUCH PIECES SHOULD NOT APPEAR ON DISKS THAT ARE
			MEANT FOR FREELY DISTRIBUTABLE SOFTWARE!

	Commercial Demo		Represents a demonstration of a commercial
			package.  As such, commercial demos are freely
			distributable and may have limitations as
			described in the .limitations field.

	Shareware	Such software is owned and copyrights are
			held by the author(s).  The software may be
			distributed freely, but not sold for profit,
			of course.  Shareware often specifies a limit
			of some time after which you are requested or
			required to register the software (i.e. pay
			for it.)  This provides you with the means to
			evaluate the software thoroughly before paying
			for it.

	Freeware	Such software is owned and copyrights are
			held by the author(s).  The software may be
			distributed freely, but not sold for profit,
			which would mean the software is no longer
			FREEware.  No payments are required for such
			software.

	Public Domain	Software labeled PD (Public Domain) belongs to
			the public, i.e. ANYONE.  Some people release
			their software into the public domain with the
			mistaken idea that they can continue to own
			and control the program.  Not so.  Software
			that is labeled Public Domain (or said by the
			author to be released into the public domain)
			truly belongs to anyone and everyone.  It is
			quite legal for someone to take such a program
			and sell it for profit as is.  Likewise, it
			it perfectly acceptable to modify public domain
			software to build a better product (or whatever)
			out of it and then sell it for profit.

	GNU Public License	The terms and conditions of this license
			are long and not easily reproduced here.  Suffice
			to say that software released under the GNU Public
			License cannot be sold for profit and must be
			distributed with source code.  They are not
			public domain, however.

#EOT

--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.

====================================================================
This is part of a mailing list gateway maintained by Carlos Amezaga.
Bugs, Comments, Subscribes and UnSubcribes should be sent to
announce-request@cs.ucdavis.edu.



