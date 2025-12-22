From megalith!overlord@uunet.UU.NET Tue Jan 11 01:49:37 1994
Received: from relay2.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.4)
	id AA28943; Tue, 11 Jan 94 01:49:30 PST
Received: from spool.uu.net (via LOCALHOST) by relay2.UU.NET with SMTP 
	(5.61/UUNET-internet-primary) id AA10530; Tue, 11 Jan 94 04:47:41 -0500
Received: from megalith.UUCP by uucp5.uu.net with UUCP/RMAIL
	(queueing-rmail) id 023559.8549; Tue, 11 Jan 1994 02:35:59 EST
Received: by megalith.miami.fl.us (V1.16.20/w5, Dec 29 1993, 21:22:55)
	  id <0668@megalith.miami.fl.us>; Tue, 11 Jan 94 00:18:23 EST -0500
Date: Tue, 11 Jan 94 00:18:23 EST -0500
Message-Id: <9401110017.0667@megalith.miami.fl.us>
Sender: errors@megalith.miami.fl.us
Errors-To: errors@megalith.miami.fl.us
Warnings-To: warnings@megalith.miami.fl.us
Return-Path: errors@megalith.miami.fl.us
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Reply-To: fnf@fishpond.cygnus.com (Fred Fish)
Message-Number: 662
Newsgroups: comp.sys.amiga.announce
Message-Id: <overlord.063p@megalith.miami.fl.us>
From: fnf@fishpond.cygnus.com (Fred Fish) (CSAA)
To: announce@megalith.miami.fl.us
Subject: Fred Fish -- Floppy/CD-ROM database info
Status: RO

Even before I started putting the first Freshfish CD-ROM together, I
realized that one of the challenges of doing CD-ROM distributions right
would be to make it easy for people to find specific programs, or types of
programs (or other material) that they were interested in.  The amount of
information that can be put on a CD-ROM is overwhelming.

I was not able to directly address this issue for the first two Freshfish
CD-ROM's, but that doesn't mean it was forgotten.  I have been working with
Udo Schuermann, the author of the well-known KingFisher program, to develop
a strategy, and eventually software, for organizing the CD-ROM's and making
it easy to find things that you are interested in, both on a single CD-ROM
as well as across a set of CD-ROMs.

When I first approached Udo with the idea of encapsulating interesting
information about material in an extensible, easy to parse, text formatted
file that would be included with the material and processed by various
tools, one of which could be an extended version of KingFisher, he was
quite enthusiastic.  He took a fairly general initial specification that my
brother had put together and greatly expanded both the scope and level of
detail of that specification.  The current result of that work is included
below.

It is my intention to start using this specification to generate the
description files (".Product-Info" files) for new material on the next
Freshfish CD-ROM, and subsequent CD-ROM's.  I will also work to generate
the .Product-Info files for the already published Oct93 and Dec93 Freshfish
CD-ROMs, so that this data can become part of the database generated for
the advanced version of KingFisher, once it is available.

I would like to solicit some help from the user community to generate
accurate .Product-Info files for as much of the previously published (and
newly submitted) material as possible.  Specifically:

    o	If you have authored a program that has appeared anywhere in my
	floppy or CD-ROM distribution, it would be very useful to me if
	you could generate a .Product-Info file that describes each
	inclusion of the material and forward that one to me.

    o	If you have not authored a program, but would like to participate
	in this rather huge undertaking, simply pick some block of
	material at random (disks 104, 342, 864, 912 for example) and
	generate some .Product-Info files for this material.  The
	chances are pretty good that you won't pick the same set of
	material as too many other people.  However a small amount of
	duplication is not necessarily bad, since I will attempt to
	do comparison of duplicates to arrive at a "mutually voted
	upon description".

I will reward outstanding contributers to this effort with one or more free
CD-ROM's.  I can't at this time specify what "outstanding" might mean in
terms of quantity or quality of the submitted .Product-Info files, but I'm
sure that there will be a few people who are obvious candidates.  The
boundary point for crossing over from "helpful" to "outstanding" is
probably somewhere between 50 and 100 description files that show an obvious
attention to accuracy and completeness, if you must have some sort of rough
guideline.

Oh yes, because the file format is free-form, and unrecognized fields are
simply ignored, it just occured to me that one useful piece of information
that could be entered into the description file is the name of the person
that generated it. Let's agree to use the field ".described-by" for this
for now, and its contents will be a newline separated list of names and
optional internet addresses or other contact information.  I.E.

	.described-by
	Fred Fish (fnf@fishpond.cygnus.com)
	John Hacker (jacker@nowhere.edu)
	I. M. Isolated (+99 12 345-5498)

-Fred

===========================================================================

			FishROM Database
			~~~~~~~~~~~~~~~~
			   (draft #3)


1. The database is formed into a single file (probably splittable like the
   KingFisher 1.x database) from the individual descriptions in the sub-
   directories of the CD-ROM.  This decision has been made for basically
   two reasons:
      a) Access from a single, indexed file is significantly faster than
         if a directory tree has to be walked and files opened and closed
         incessantly, and
      b) I/O from a CD-ROM may not always be desirable, meaning that the
         database (as distributed on the CD-ROM) could be copied to a
         faster harddisk for quicker on-line searches.  A side-effect of
         this is the fact that the database can be distributed by
         electronic means.

2. Adding Fish to the database is done with one of two commands:  Build
   Database (scans a tree structure, looking for .Product-Info files in the
   format described below) and Import Database (scans a text file and
   extracts information as described below.)  I propose that the public
   listings/announcements (if such are made) use a header/footer marker
   to more clearly delimit the included text from headers and signatures.
   These could be created quickly and easily with KingFisher's Export
   Database command.

   Example:

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

   Furthermore, each entry in the database, as built by and for KingFisher, <@>
   is now defined to BEGIN with the .name field.  In other words, the .name
   field must always be the first field, followed by all other fields in
   any order.  The next .name field specifies a new entry.

3. I have given up on the idea to create a complex and possibly fast index
   because CPU speed will in most cases be quick enough to build a list of
   existing fields on the fly using an arbitrarily sized buffer and suffer
   no noticable loss in speed.  The saving in diskspace (and I/O time for
   such an index) should more than make up for this.



The following describes a list of STANDARD fields for the KingFisher 2.0
database.  Please note that every field begins with a period to distinguish
it from the field contents.  KingFisher has some very specific ideas about
what these STANDARD fields may contain.  It is important, therefore, that
you follow these guidelines.

In most fields, text on multiple physical lines is considered to be the
same as if it was all on one long line.  Newlines are simply treated as a
whitespace.  If you wish to insert special formatting symbols, please refer
to the section below, titled FORMATTING SYMBOLS, for more information.

While it is possible to omit any field, even those not marked OPTIONAL, it
is highly recommended to follow the established guidelines!  If additional
fields are needed because you wish to offer information that does not fit
within the framework of the existing fields, you are perfectly welcome to
create additional fields!  They will always be treated like free format
fields.

================================================================
.name
	PURPOSE:	The proram's name
	FORMAT:		1 line only
	EXAMPLE:	KingFisher
	EXAMPLE:	HomeBase VI
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
	FORMAT:		Any number of lines, treated as one line.
	EXAMPLE:	Joe R. User, Tea Rexx.
	NOTES:		Addresses should be placed in the .address field.
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
	FORMAT:		command[=shellscript]
	EXAMPLE:	HomeBase VI
			HomeBase VI (CLI)=ExecuteMe.HB6
			HomeBase VI Fixer (CLI)=ExecuteMe.HB6Fixer
	EXAMPLE:	FishTub=ExecuteMe
	NOTES:		KingFisher requires that this entry strictly
			follows the above format.  If the line contains
			an EQUAL sign (=) it specifies a CLI command after
			the equal sign, otherwise it represents a Workbench
			command.
			The user is shown all text up to the first equal
			sign (or end of the line, if no equal sign (WB))
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
	NOTES:		Do not specify this yourself.  KingFisher writes
			this entry during a Database Export operation and
			reads it during a Database Import operation.
			KingFisher ignores this field during a Database
			Build operation, so it is a total waste except
			when used during export/import operations!
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

================================================================

EXAMPLES OF "TYPE" WORDS

Animation		Action Game		Strategy Game
Thinking Game		Drawing			Painting
Image Processing	Image Conversion	Printing
Communications		Database		Word Processing
Text Editing		Music Composition	Sound Editing
Sound Playing		...


---> THIS LIST NEEDS TO BE EXPANDED!

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

================================================================

DATABASE FORMAT

Preserving the simplicity of the original KingFisher database, KingFisher
2.0 continues to recognize a line-by-line file.  Whenever a multi-volume
database (such as the one for the nearly 1000 "Fish Disks") is being
handled, a disk-by-disk separator of \0\n is inserted between the disks.
Without this separator, KingFisher will rebuild an index believing that all
entries exist on a single reference volume (such as a CD-ROM.)
	When a CD-ROM is indexed, there will be no such separators in the
database.  If, however, two or more CD-ROMs are indexed, then such a
separator will be placed between the last entry of one disk, and the first
entry of the next.

The textual database for KingFisher 2.0, however, always contains a
header-line that identifies it as a 2.0+ level database (distinct from 1.x
style.)  This key is yet to be determined but always ends with a newline.

PRELIMINARY CHOICE:  KF20DATA\n

#EOT
------------------------------(snip snip)------------------------------
/***************************************************************************
**
**  KingFisher 2.0
**  Copyright ) 1992-1993 Udo Schuermann
**  All rights reserved
**
**  Global Definitions
**
**  These definitions define the message port interface for KingFisher 2.0
**  Any and all applications that wish to interface directly to Kingfisher
**  must take care to follow the proper protocols.
**
**  The message port interface is designed for high speed, flexible, and
**  reliable operation between a client and the KingFisher Master Process.
**  KingFisher must have been started before any client can "talk" with it.
**  In order to terminate the client process, you must either send it a
**  break signal (SIGBREAKF_CTRL_C) or run KingFisher with the parameter
**  QUIT.
**
**  Suggestions should be addressed via electronic mail to
**       Udo Schuermann <walrus@wam.umd.edu>
**  or via standard (snail) mail to
**       Udo Schuermann
**       6000 42nd Avenue, Apt. 405
**       Hyattsville, Maryland 20781
**
**  If you use KingFisher for longer than a 30 day evaluation period, or
**  you wish to use it in a multi-user environment (such as a BBS) or you
**  wish to write client software for KingFisher, please REGISTER THE
**  PROGRAM with the author for the price of $15 US (DM 25 in Europe.)
**
***************************************************************************/

#include <exec/types.h>
#include <exec/ports.h>



/* KingFisher's public message port name.  All messages sent to this port
 * must be of the type (struct KFMsg) as defined below.
 */
#define  KFPortName "KingFisher_2"

struct KFMsg {
  struct Message AmigaMsg;
  UWORD          Error;        /* Non-zero ==> error return (text in *Buffer) */
  UWORD          Command;      /* One of the kfc* commands */
  ULONG          BParam;       /* Binary parameter (may be an address) */
  char           *TParam;      /* Textual parameter */
  void           *Context;     /* see the kfcHELLO command below! */
  ULONG          BufferSize;   /* Originator's buffer size */
  char           *Buffer;      /* Originator's buffer */
};



/*****************************************************************
 * KFMsg.Command values
 * These are issued from a client program to the KingFisher master process.
 * When the KingFisher master process replies to these messages, the issuer
 * must check the .Error field; an error code of 0 indicates that the request
 * was successful.  See below for meanings of error return values.
 */
#define kfcHELLO     0x0001    /* Client announces itself.  KingFisher
				* registers this task as a valid client and
				* allows this client to receive messages from
				* KingFisher in response to a shutdown cmd.
				* Without this command, KingFisher has no way
				* of tracking information for this client.
				* The .BParam field in this message must be
				* filled with the result of the FindTask(NULL)
				* call, i.e. the caller's task ID.
				* If this message is returned with a kfeOK
				* (i.e. no error) then the client must
				* allocate .BParam bytes and store a pointer
				* to them in the .*Context field.  After this
				* the kfcINIT command (q.v.) must be given.
				*/
#define kfcINIT      0x0002    /* Load default settings from the file whose
				* name is given in the *Buffer field.  The
				* .*Context is initialized/updated with this
				* command.  Is a null file is given, the
				* .*Context is initialized with KingFisher's
				* default settings.  KingFisher stores any and
				* all task-specific/private information to the
				* .*Context; as such, the memory associated
				* with this field belongs to KingFisher and
				* not the application.
				* NOTE: It is NOT LEGAL to save this memory
				*       image and restore it at a later time
				*       in order to speed or make superfluous
				*       the kfcINIT step!
				*       This restriction MAY be lifted at a
				*       later time.
				*/
#define kfcBYE       0x0003    /* Client is saying good-bye.  This command is
				* needed when a client task voluntarily shuts
				* down, i.e. it does not shutdown due to such
				* a request by KingFisher itself (see kfcEXIT
				* command.  Without this command, a client's
				* information that KingFisher maintains, will
				* not be freed.  The client is responsible for
				* freeing the memory associated with the
				* .*Context field AFTER the kfcBYE message has
				* been replied to by KingFisher.
				*/
#define kfcQUIT      0x0004    /* Master process is requested to shutdown.
				* A client process should not (be able to)
				* issue this command, as it causes the entire
				* Client-Server structure of KingFisher to be
				* shutdown.  KingFisher, in response to this
				* message will issue kfcEXIT commands to all
				* processes (including the one originating
				* this message.)
				*/
#define kfcEXIT      0x0005    /* Client process is requested to shutdown.
				* The KingFisher master process cannot
				* complete a QUIT operation until all of its
				* current clients have shutdown.  Such a
				* shutdown requires only the acknowledgment
				* of this message (i.e. ReplyMsg()) and
				* should not involve "proper" shutdown with
				* a kfcBYE command.
				*/
#define kfcSTATUS    0x0006    /* Return the *Buffer with status information
				* according to the .BParam; see below for
				* information on what the .BParam values are
				* for this command.
				*/
#define kfcISTATUS   0x0007    /* Internal use only */
#define kfcGETFISH   0x0008    /* Retrieve the current fish, formatted
				* according to the current settings (see the
				* kfcINIT command) into the *Buffer.
				*/
#define kfcRAWFISH   0x0009    /* Retrieve the current fish, unformatted and
				* exactly as found in the database itself,
				* into the *Buffer.  Such a RAW entry can be
				* stored back into the database with the
				* kfcADDFISH command.
				*/

/* The following commands involve selecting new fish, including by search */
#define kfcSETPOS    0x0100    /* Make the indicated fish (1..n) the current
				* entry in the database.
				*/
#define kfcGETPOS    0x0101    /* Retrieve the current position in the data-
				* base; if the returned position is 0 then
				* there are no fish in the database as the
				* position for existing fish is a number 1
				* or greater.  The value is returned in the
				* .BParam field.
				*/
#define kfcSETDSKPOS 0x0102    /* Make the first fish on the indicated disk
				* the current entry in the database.
				*/
#define kfcGETDSKPOS 0x0103    /* Retrieve the current position's disk in
				* the database; see the kfcGETPOS command
				* above for more information.
				*/
#define kfcNEXTFISH  0x0110    /* Move to the next fish */
#define kfcPREVFISH  0x0111    /* Move to the previous fish */
#define kfcNEXTVERS  0x0112    /* Move to the next version */
#define kfcPREVVERS  0x0113    /* Move to the previous version */
#define kfcNEXTDISK  0x0114    /* Move to the next disk */
#define kfcPREVDISK  0x0115    /* Move to the previous disk */

/* The following commands involve searching for fish in the database */
#define kfcSEARCH    0x0200    /* Begin a search according to the settings
				* in effect.  The *Buffer field contains
				* the search expression.  After this
				* command, use the kfcAGAIN command to
				* continue the search operation with the
				* same expression; this is more efficient
				* than having KingFisher recompile the
				* expression with a kfcSEARCH command
				* again and again.
				*/
#define kfcAGAIN     0x0201    /* Continue the search initiated by the
				* previous kfcSEARCH command.
				*/
#define kfcSSET      0x0202    /* Set a search parameter; see below for
				* the format of these parameters as they
				* are passed in the .BParam field.
				*/

/* The following commands involve adding fish to the database. */
#define kfcBLOCK     0x1000    /* Begin blocking access of KingFisher for
				* exclusive access to the database, i.e.
				* update of the database through adding
				* operations.  Further commands will not
				* be accepted unless they have the same
				* Reply Port!
				*/
#define kfcUNBLOCK   0x2000    /* End blocking access to KingFisher for
				* exclusive access;
#define kfcADDFISH   0x3000    /* Parse the fish whose information is in
				* the .Buffer field and add it to the data-
				* base.  Also see the kfcRAWFISH command.
				*/
#define kfcADDFILE   0x4000    /* Parse the file whose name is in the
				* .Buffer field and add whatever fish are
				* stored there to the database.
				*/


/*****************************************************************
 * KFMsg.BParam
 * Various commands make different use of this field:
 */
        /* stat... values may be ORed together into a mask; each bit
	 * causes the kfcSTATUS command to place into the .Buffer field
	 * a line with the respective format as shown below.
	 */
#define statPOSITION  0x00000001  /* POSITION=%d   -- current record */
#define statRECORDS   0x00000002  /* RECORDS=%d    -- total records in database */
#define statCLIENTS   0x00010000  /* CLIENTS=%d    -- number of clients */
        /* srch... values are ORed together into a mask; proper interpretation
	 * is not guaranteed if logically conflicting values are combined, such
	 * as BOTH forward AND backward search direction.
	 */
#define srchFORWARD   0x00000001  /* Set forward direction in search */
#define srchBACKWARD  0x00000002  /* Set backward search direction */
#define srchNAMEONLY  0x00000004  /* Set name-only (quick) search */
#define srchDESCRIPT  0x00000008  /* Set description (comprehensive) search */
#define srchCASEDIFF  0x00000010  /* Set case differentiation */
#define srchCASESAME  0x00000020  /* Set case indifference */


/*****************************************************************
 * KFMsg.Error
 * Error return values
 */
#define kfeOK         0x0000      /* All fine; no error; happiness abounds! */
#define kfeREFUSED    0x0001      /* a kfcHELLO command is refused.  A detailed
				   * explanation (in textual format) can be found
				   * in the .Buffer field.
				   */
#define kfeUNREG      0x0002      /* KingFisher does not recognize you as a
				   * registered client!  Are you sure you used
				   * a kfcHELLO command and didn't get an error
				   * in the form of a kfeREFUSED?
				   */
#define kfeNOMORE     0x0003      /* A request for kfcNEXTFISH, kfcNEXTVERSION,
				   * kfcNEXTDISK (or the ...PREV... versions of
				   * these commands) could not be fulfilled
				   * because the last one had already been
				   * reached.  In most cases this is not an
				   * error that the user should be told of as
				   * an error.
				   */
#define kfeNOTFOUND   0x0004      /* A search (again) request could locate an
				   * entry; this command terminates the search.
				   */
#define kfeBADEXPR    0x0005      /* An invalid expression was given; it could
				   * not be compiled for use.
				   */
#define kfeCONFUSED   0x0006      /* KingFisher is confused about some weird
				   * irregularity with its database, index, etc.
				   * Further operation may not yield reliable
				   * results.
				   */
#define kfeBLOCKED    0x0007      /* This error can be given in response to a
				   * kfcHELLO cmd; how many seconds KingFisher
				   * has already been blocked will be given in
				   * the .BParam field; if this is an excessive
				   * amount of time, then it may be wise to abort
				   * the operation, otherwise try again in a few
				   * seconds!
				   */
#define kfeTRUNC      0x0008      /* The requested information in the *Buffer has
				   * been truncated in length because the size of
				   * the buffer, as indicated by the BufferSize
				   * field, was too small.
				   */
#define kfeMEMORY     0x0009      /* Insufficient memory to complete the operation.
				   */
#define kfeBOGUSMSG   0x000A      /* A message was received in reply from a client
				   * process which KingFisher never allocated or
				   * sent.
				   */
#define kfeVANISHED   0x000B      /* The KingFisher master process vanished while
				   * the slave process was trying to communicate
				   * with it.
				   */
#define kfeFILEOPEN   0x000C      /* The KingFisher server could not open a file
				   * that was needed.  More details are in the
				   * .Buffer field.
				   */
#define kfeBADFISH    0x000D      /* A request was given to KingFisher for a fish
				   * that was out of the known range of stored
				   * fish.
				   */
#define kfeSEEKERROR  0x000E      /* KingFisher is unable to locate the indicated
				   * fish at the offset in the file that its index
				   * specifies.  This problem usually indicates a
				   * corrupted or otherwise dysfunctional index.
				   */
#define kfeREADERROR  0x000F      /* KingFisher is unable to load the indicated
				   * fish (fully or partially) due to some file
				   * input problem.
				   */
#define kfeWRITEERROR 0x0010      /* KingFisher is unable to save the indicated
				   * fish (fully or partially) due to some file
				   * output problem.
				   */
//EOT

--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.

====================================================================
This is part of a mailing list gateway maintained by Carlos Amezaga.
Bugs, Comments, Subscribes and UnSubcribes should be sent to
announce-request@cs.ucdavis.edu.



