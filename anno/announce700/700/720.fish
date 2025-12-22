Path: NOT-FOR-MAIL
Reply-To: fnf@cygnus.com (Fred Fish)
Message-Number: 720
Followup-To: comp.sys.amiga.misc
Distribution: world
Newsgroups: comp.sys.amiga.announce
Approved: overlord@megalith.miami.fl.us
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
From: fnf@cygnus.com (Fred Fish)
Subject: Contents of Mar/Apr FreshFish CD-ROM
Message-Id: <overlord.0q9l@megalith.miami.fl.us>
Date: Mon, 28 Feb 94 21:33:14 EST

(Note:  I was originally going to call this the February FreshFish CD-ROM,
 but decided to start doing like magazines do, and name the CD-ROM for the
 period over which it is expected to be current.  -Fred)

===========================================================================

				CONTENTS OF
		      March/April 1994 FreshFish CDROM

This file contains some overview information about the contents of the
CD-ROM, followed by a concatenation of a bunch of individual Contents
files on the CD-ROM.  Note that not all the material on the CD-ROM
appears in a Contents file somewhere, so the list of programs found in
this file is only a subset of what is actually on the CD-ROM.  In
particular, the only detailed contents listed here are for material
that is "New" with this CD-ROM.

-----------------------
STRUCTURE OF THE CD-ROM
-----------------------

The 636 Mb on the CD-ROM is divided into roughly three sections: (1)
New material, which includes the material from the new unreleased
floppy disks as well as material which does not appear in the floppy
distribution, (2) useful utilities that can be used directly off the
CD-ROM if desired, thus freeing up the corresponding amount of hard
disk space, and (3) older material from previous released floppy disks
or CD-ROM's.

The portion of the disk dedicated to new material that I've not
previously published on a CD-ROM or floppy disk is 59 Mb, broken down
as follows:

	 8 Mb	Archived (BBS ready) contents of disks 951-975
	20 Mb	Unarchived (ready-to-run) contents of disks 951-975

	 9 Mb	Archived "new material" not in floppy distribution
	22 Mb	Unarchived "new material" not in floppy distribution

The portion of the disk dedicated to a bunch of useful tools like GNU
utilities, TeX with lots of fonts, and other interesting software that will
be updated for each FreshFish CD-ROM, is 284 Mb, broken down as follows:

	  2 Mb	Content lists of floppy disks 1-971.
	  6 Mb	Content lists (file and CRC lists) of previous CD-ROM's.
	  4 Mb  CD-ROM administration files, documentation, etc.
	  4 Mb	Reviews of Amiga software and hardware
          4 Mb	Full BSD source for supplied BSD executables.
	  4 Mb	AmigaGuide versions of GNU "info" files.
	  6 Mb	CBM header files, libraries, and developer tools.
	  3 Mb	Binary executables, libraries, and other "runtime" things.
         27 Mb	Misc useful tools, libraries, etc.
	 33 Mb	PasTeX source, fonts, binaries, etc.
	 39 Mb	GNU binaries, libraries, and other "runtime" things.	
	152 Mb	Full GNU source for supplied GNU executables.

The portion of the disk dedicated to old material is 293 Mb, broken
down as follows:

	 12 Mb	Archived (BBS ready) contents of material from Oct
		FreshFish CD-ROM that was not in floppy distribution.
	 22 Mb	Archived (BBS ready) contents of material from Dec
		FreshFish CD-ROM that was not in floppy distribution.
	 27 Mb	Unarchived contents of material from Oct FreshFish CD-ROM
		that was not included in the floppy distribution.
	 57 Mb	Unarchived contents of material from Dec FreshFish CD-ROM
		that was not included in the floppy distribution.
	175 Mb	Archived (BBS ready) contents of floppy disks 600-975.

--------
GNU CODE
--------

Here are the current GNU distributions which are included in both source
and binary form.  In most cases, they are the very latest distributions
ftp'd directly from the FSF machines and compiled with the version of gcc
included on this CD-ROM.  I have personally compiled all of the GNU
binaries supplied on this CD-ROM, to verify that the compiler is solid and
that the binaries are in fact recreatable from the supplied source code.

bc-1.02		   find-3.8	      grep-2.0		 rcs-5.6.0.1
binutils-1.8.x	   flex-2.4.6	      groff-1.09	 sed-2.03
bison-1.22	   gas-1.38	      gzip-1.2.4	 shellutils-1.9.4
cpio-2.3	   gawk-2.15.4	      indent-1.9.1	 tar-1.11.2
dc-0.2		   gcc-2.3.3	      ispell-4.0	 termcap-1.2
diffutils-2.6	   gcc-2.5.8	      libg++-2.5.3	 texinfo-3.1
doschk-1.1	   gdb-4.12	      m4-1.1		 textutils-1.9
emacs-18.59	   gdbm-1.7.1	      make-3.70		 uuencode-1.0
f2c-1993.04.28	   ghostscript-2.6.1  patch-2.1
fileutils-3.9	   gmp-1.3.2	      perl-4.036

Here is an "ls -C" of the GNU binary directory which can be added to
your path to make these utilities usable directly off the CD-ROM, once
it is mounted:

[	    diff3	geqn	    info	pathchk	    texi2dvi
addftinfo   dir		gindxbib    install	pfbtops	    texindex
afmtodit    dirname	glookbib    ispell	pr	    tfmtodit
ar	    doschk	gneqn	    ixconfig	printenv    touch
as	    du		gnroff	    ixtrace	printf	    tr
awk	    echo	gperf	    join	protoize    true
basename    egrep	gpic	    ksh		ps2ascii    unexpand
bc	    emacs	grefer	    ld		ps2epsi	    uniq
bdftops	    env		grep	    lkbib	psbb	    unprotoize
bison	    etags	grodvi	    ln		ranlib	    uudecode
c++	    expand	groff	    locate	rcs	    uuencode
cat	    expr	grog	    logname	rcsdiff	    v
chgrp	    f2c		grops	    look	rcsmerge    vdir
chmod	    false	grotty	    ls		rlog	    wc
chown	    fgrep	gs	    m4		rm	    who
ci	    find	gsbj	    make	rmdir	    whoami
cksum	    flex	gsdj	    makeinfo	sdiff	    xargs
cmp	    flex++	gslj	    merge	sed	    yes
co	    fold	gslp	    mkdir	sh	    zcat
comm	    font2c	gsnd	    mkfifo	size	    zcmp
cp	    g++		gsoelim	    mknod	sleep	    zdiff
cpio	    gawk	gtbl	    mt		sort	    zforce
csplit	    gcc		gtroff	    mv		split	    zgrep
cut	    gcc-2.3.3	gunzip	    nice	strip	    zmore
d	    gcc-2.5.8	gzexe	    nl		sum	    znew
date	    gccv	gzip	    nm		tac
dc	    gccv-2.3.3	head	    nroff	tail
dd	    gccv-2.5.8	id	    od		tar
df	    gdb		ident	    paste	tee
diff	    genclass	indent	    patch	test

----------------------
Other Useful Utilities
----------------------

Here is an "ls -C" of the Useful/Sys/c binary directory which can be
added to your path to make these utilities usable directly off the
CD-ROM, once it is mounted:

A-Kwic	     ExpungeXRef  LoadLibrary  Play	    Vim		 lha
AD2HT	     Flush	  LoadXRef     PowerSnap    WDisplay	 look
ARTM	     IView	  MKProto      RSys	    XIcon	 mg
AZap	     Installer	  MakeAnim7    SD	    Xoper	 tapemon
AmigaGuide   LHArc	  MuchMore     SnoopDos	    brik	 vt
Degrader     LHWarp	  NewZAP       SuperDuper   bsplit	 zoo
DeviceLock   Less	  PackIt       SysInfo	    chksum
DiskSalv     LoadDB	  PerfMeter    Viewtek	    flushlibs

--------------------------------
Contents of Floppy Disks 600-975
--------------------------------

I've elected to use the BBS ready form of the contents of disks
600-975 to fill the remaining space on the CD-ROM, after everything
else was included.  For each floppy disk, there is a separate archive
of each item listed in the floppy disk contents file, as well as an
archive for the floppy disk "overhead" files and a CRC list of the
entire disk contents.

There is also a beta release of "PufferFish", a utility by Peter
Janes, which can be used to recreate master floppy disks from the
archives and CRC lists, for further duplication and distribution.

-------------------------
New/AmigaLibDisks/Disk951
-------------------------

IconMiser	Intercepts attempts by programs to create icons and substi-
		tutes images or icons you prefer in their place.  Easy to
		configure, works with 1.2 or above.  Supports icon drag-n-
		drop with 2.0 or above.  Version 2.0, binary only.
		Author:  Todd M. Lewis

MaxonMAGIC	Demoversion of the commercial program MaxonMAGIC, an anim-
		ated screenblanker and crazy soundprogram.  The complete
		version includes 15 different blankers and two disks full
		of samples.  The demo is almost completely operational.
		Settings can't be saved and it will also remind the user
		that it is a demo every now and then.
		Author:  Klaus-Dieter Sommer, distributed by MAXON Computer

-------------------------
New/AmigaLibDisks/Disk952
-------------------------

MachV		Release 5.0, version 37.5 of the hotkey/macro/multipurpose
		utility.  You can record keystrokes and mouse events,
		manipulate screens and windows, popup a shell, view the
		clipboard, blank the screen and much more.  This release
		has a complete ARexx interface, so you can execute ARexx
		programs and functions from hotkeys and store results in
		environment variables.  The optional title bar clock is an
		AppWindow.  You can drop an icon in the clock and its name
		is set in a variable for use in macros.  The documentation
		has been rewritten and includes two indices.  This is the
		freely distributable release of 5.0.  It is the same as the
		registered version except this version has a "welcome"
		window and has a limit of 25 macros.  It has been localized
		for deutsch and francais.  Requires OS2.04+.  This is an
		update to MachIV on disk number 624.  Binary only, share-
		ware.
		Author:  Brian Moats, PolyGlot Software

UUArc		UUArc is an archiving system designed to enable easy trans-
		mission of binary files/archives over communcation links
		only capable of using ASCII, such as Electronic Mail.  It
		encodes binary files into files containing only printable
		standard ASCII characters.  Written primarily for use with
		GuiArc to add UUEncoding/UUDecoding facilities to it, it
		takes similar command line options to other commonly used
		archiving programs.  This is version 1.3, an update to
		version 1.1 on disk 912.  Public domain, includes source.
		Author:  Julie Brandon

-------------------------
New/AmigaLibDisks/Disk953
-------------------------

AmigaToNTSC	AmigaToNTSC patches graphics.library so it will think you
		have an NTSC Amiga.  AmigaToPAL will patch it to think you
		have a PAL Amiga.  Custom screens will open in the mode
		selected.  Version 1.2, an update to version 1.0 on disk
		number 575.  Binary only.
		Author:  Nico Francois

AppCon		Declares the actual CON:-window as an AppWindow and lets you
		drop your icons in this window.  Then, the name and path of
		the icon are inserted into the current command line exactly
		as if you typed them with your keyboard, but slightly
		faster!  Version 37.177, includes source.
		Author:  Stephan Fuhrmann

ByteFilter	Lets you to filter out specified bytes from any file, so you
		are able to extract the texts from a binary file, for ex-
		ample.  This is version 1.20 and it uses jhextras.library,
		which is included in the libs drawer.  Freeware, includes
		source.
		Author:  Jan Hagqvist

EasyCatalog	An IFF-CTLG catalog file editor.  From now on, you can just
		enter the text for the catalog and save it.  Existing cata-
		logs can be loaded and changed.  Requires Kickstart 2.x or
		higher.  English and Dutch (Nederlands) catalogs supplied.
		Version 0.8_, binary only.
		Author:  Jeroen Smits

ISAM		A Server/Library.  Even novice programmers can store and/or
		retrieve database records.  Powerful, multi-"user", almost
		unlimited number & size of records/files.  Different users
		may access same file, file and record locking (exclusive or
		shared), multiple keys/file.  Keys may: ascend/descend,
		have unique/repeatable values, be up to 499 bytes.  Many
		record retrieval methods.  Recover Index file if lost or
		corrupt.  Deleted record space reclaimed.  Small: server
		is less than 51K; Resident Library less than 9K.  Usable
		from C/Asm./ARexx/etc.  AmigaDOS V1.2 and up.  Shareware,
		binary only, examples w/source.  Version 1.03, an update
		to version 1.01 on disk number 766.
		Author:  Scott C. Jacobs, RedShift Software

LHA_DOpus	An ARexx script for Directory Opus 4.11 that lists the
		contents of lha-archives in a DOpus window.  Allows extract,
		delete and add operations on specific files of the archive.
		Version 1.0, freeware.
		Author:  Michiel Pelt

-------------------------
New/AmigaLibDisks/Disk954
-------------------------

MFT		Multi-Function Tool.  A little assembly program (just over
		1K) that can perform all of the following DOS commands:
		RENAME, DELETE, MAKEDIR, WAIT, FILENOTE.  Useful for disks
		where every byte counts and you don't want a bunch of bigger
		utilities taking up room.  Current version does not support
		pattern matching.  Version 1.03, includes source in assem-
		bler.
		Author:  Thorsten Stocksmeier

SCAN8800	A specialized database program to store frequencies and
		station names for shortwave transmitters.  It can also
		control a receiver for scanning frequency ranges.  Version
		2.38, an update to version 2.33 on disk number 864.  Binary
		only.
		Author:  Rainer Redweik

-------------------------
New/AmigaLibDisks/Disk955
-------------------------

DlxGalaga	A shoot'em up game.  Deluxe version of an old classic.
		Version 1.0, binary only, shareware.
		Author:  Edgar M. Vigdal

MuroloUtil	Several CLI or script based utilities.  Included are:
		Button - A little utility that opens a requester with
		custom text.  Useful for batch and scripts; C64Saver -
		A utility that reads C64 basic programs, decodes and
		saves them in a readable file; Calendar - A utility
		which prints a monthly calendar and some information
		about the days; CarLost - A utility that causes DTR
		to drop on the serial port; CDPlayer -  A utility to
		play a musical CD on CDTV or A570; FMBadFmt - Intuition
		based utility which formats BAD floppies and makes them
		useable; KickMaker - A utility to create a new KickStart
		disk with the last version of kickstart on it...  For
		A3000 owners only; SerTest - A utility that opens a
		window and shows the status of serial port signals
		Switch - A utility that opens a little centered window,
		that has custom text and two buttons for choice.
		Most programs require OS2.04+, some source included.
		Author:  Felice Murolo

PFS		A filesystem for the Amiga.  Offers higher performance on
		all operations and full compatibility with AmigaDos.
		Requires Kickstart 2.0 or higher.  Shareware release 1.0,
		version 6.11.  Binary only.
		Author:  Michiel Pelt

-------------------------
New/AmigaLibDisks/Disk956
-------------------------

DDBase		A simple database program.  Features:  Up to 1500 records,
		up to 20 fields/record;  Draw up to 10 Bevel/FlipBoxes,
		Box, Circles;  Import/Export data as ASCII or Superbase;
		Uses external fields {ASCII/IFF}.  Installation utility
		provided.  Version 3.00, requires OS2.x or greater.
		Binary only, freeware.
		Author:  Peter Hughes

FMsynth		A program to create sounds with FM synthesis.  It has six
		operators, a realtime LFO and a free editable algorithm.
		The sound can be played on the Amiga keyboard or on a MIDI
		keyboard which is connected to the Amiga.  The sounds can
		be saved in IFF-8SVX (one or five octave) or raw format.
		FMsynth has an AREXX port now.  Included are 230 FM sounds.
		Version 3.3, an update to version 1.1 on disk number 895.
		Shareware.
		Author:  Christian Stiens

SetDefMon	A small utility to set the system's default monitor during
		WBStartup or to zap the default monitor on the fly.  Possi-
		ble default monitors include Pal, Ntsc, Euro36, Super72,
		DblNtsc and DblPal.  Version 1.2, includes source in C.
		Author:  Franz Schwarz

-------------------------
New/AmigaLibDisks/Disk957
-------------------------

PARex		PARex is a program which allows you to process files, mostly
		textfiles, whereby strings can be replaced by another, text
		between two strings can be stripped, strings put in lower or
		upper case.  PARex supports normal text searching, wildcard
		searching, context remembering and word-only searching.
		Using data scripts enables the use of an unlimited number of
		such replace commands.  Each replace command can be indivi-
		dually controlled.  All ASCII codes can be used in the
		search and replace strings, even entire files, dates, times,
		can be inserted in such strings.  Custom formatted hexadeci-
		mal output is also supported.  Over twenty ready to use
		program scripts are included to perform simple tasks as:
		converting files between different computer systems, strip-
		ping comments from source files, finding strings in files,
		converting AmigaGuide files to normal text files,... even
		automatic version updating of source files.  By the way,
		v3.00 is about two to more than twenty times faster than
		the previous versions, and is supplied in english, german,
		french, and dutch.  This is version 3.00, an update to
		version 2.12 on disk number 859.  Binary only (but the
		source is available), shareware.
		Author:  Chris P. Vandierendonck

VChess		Fully functional shareware chess game completely written in
		Amiga Oberon.  Features: selectable screen type (can run
		right on the workbench screen); sizeable board; Two-human,
		Computer-Human and Computer-Computer play modes; Load, save
		games; Load/save/print movelist;  Use/save openings;  Time
		limits; Solve for mate; Selectable fonts;  Setup board;
		Rotate board; Show movelist; Show thinking; ... and more.
		Requires OS2.0+, and should run even on low memory (512K)
		machines if the opening library is not used.  Version 2.0,
		binary only, shareware.
		Author:  Stefan Salewski

-------------------------
New/AmigaLibDisks/Disk958
-------------------------

Alert		A small command to display texts in a recovery-alert.  Works
		on all machines with Kickstart V33 or higher.  Version 1.1,
		includes source.
		Author:  Ketil Hunn

Fed-CASE	A graphical environment to design flowcharts.  The source
		code generator generates directly compilable C source.
		The generated code can be compiled on other computer
		systems.  I.E. you can generate source code for a C com-
		piler on a UNIX operating system or a PC operating system.
		Version 1.0 (demo version), binary only.
		Author:  Christian Joosen, Ron Heijmans

TestMaker	NOT just a test creator for teachers.  Ten years in develop-
		ing, this one makes up tests, review sheets, quizzes, etc.,
		in a variety of formats, and helps the teacher maintain a
		question database for use in most subjects.  Version  3.12,
		binary only (Compiled HiSoft Basic), shareware.
		Author:  Bill Lunquist,  Bob Black

-------------------------
New/AmigaLibDisks/Disk959
-------------------------

AmigaDiary	AmigaDiary is a handy workbench tool of the type that
		currently abound office PC's.  It is a mouse driven diary
		capable of storing all personal events and is the perfect
		solution to all those forgotten birthdays, missed appoint-
		ments etc.  Version 1.13, binary only.
		Author:  Andrew K. Pearson

HQMM		Hero Quest MapMaker.  With HQMM, you can create your own
		missions for Hero Quest, the board game.  You can place
		all objects that are in the Hero Quest set (doors, traps,
		furniture, monsters etc.) on the map and you can write
		your own story to go with it.  All this will be printed
		out in the same style as the original Hero Quest missions.
		Version 1.11, requires OS2.0+.  Binary only, freeware.
		Author:  Camiel Rouweler

IntuiMake	A tool for developers, created with the intention of
		building complex projects, with an easy to use graphics
		user interface.  No further knowledge about conventional
		makes is needed, because Intuimake does not deal with
		script files or things like that.  Requires OS2.0+.
		Version 1.2, binary only.
		Author:  Bjvrn E. Trost and Dirk O. Remmelt

-------------------------
New/AmigaLibDisks/Disk960
-------------------------

Imperial	An oriental game in which you have to remove tiles from a
		layout (like Shanghai or Taipei).  Every game has a solution
		and there's a layout editor.  English NTSC version and
		French PAL version supplied.  Some other versions available
		from the author.  Version 2.0, binary only, shareware.
		Author:  Jean-Marc BOURSOT

Minesweeper	Yet another minesweeper game.  This one forgives the
		player, when he hits a mine, if no useful inferences
		could be made from the exposed information.  The element
		of luck is sharply reduced.  First version, binary only.
		Author:  Donald Reble

PowerPlayer	A very powerful, user friendly and system friendly module
		player.  It can handle nearly all module-formats,
		can read powerpacked & xpk-packed modules and comes along
		with its own powerful cruncher that uses the lh.library.
		Has a simple to use userinterface and an ARexx port,
		has locale-support and a nice installer script for CBM's
		installer utility.  Version 4.0, update to version 3.9 on
		disk number 863.  Binary only, shareware.
		Author:  Stephan Fuhrmann

-------------------------
New/AmigaLibDisks/Disk961
-------------------------

FIVE-STAR	Demo version of a powerful prediction tool for LOTTO,
		POOLS, SWEEP, DIGIT (eg 4d) and HORSE (races) systems
		available worldwide.  The program uses an identical
		framework for all five systems but they are run com-
		pletely individually so that any number of them can
		be used simultaneously.  All records, updates, pre-
		dictions, bets and results are stored separately and
		can be saved to disk or sent to the printer at any time.
		This demo version is supplied with a very basic manual
		and is completely functional except for data input.
		Version 1.0, binary only.
		Author:  Joe Taylor

MPMaster	A useful MIDI program that enables to transmit/receive
		samples via MIDI between the Amiga and any MIDI device
		that supports the MIDI Sample Dump Standard format (such
		as the Yamaha SY85 synthesizer).  It has a WorkBench
		interface, can play samples and all settings of the sample
		can be modified before transmission.  Includes a circuit
		to build a very small MIDI interface.  Distributed in two
		languages: English and Spanish.  Requires WorkBench 2.04
		or higher.  Version 1.2, binary only, freeware.
		Author:  Antonio J. Pomar Rossells

-------------------------
New/AmigaLibDisks/Disk962
-------------------------

EnvTool		A tool for a project icon, born out of a severe need to
		allow users to use their own tools for reading doc files,
		viewing pictures, editing files, etc.  EnvTool will send
		the associated file to either the tool specified by an
		environment variable, or a selected default tool if the
		environment variable is not set.  Version 0.1, includes
		source in C.
		Author:  Dan Fish

EZAsm		Combines 68000 assembly language with parts of C.
		Produces highly optimized code.  Uses C-like function calls
		( supports all 3.0 functions ), taglists, braces, "else",
		".fd" support, and much more.  Comes bundled with A68k
		and Blink, for a complete programming environment.
		This is version 1.8, an update to version 1.7 on disk 699.
		Includes example source and executable files.  Binary only.
		Author:  Joe Siebenmann

MuchMore	Another program like "more", "less", "pg", etc.  This one
		uses its own screen or a public screen to show the text
		using a slow scroll.  Includes built-in help, commands to
		search for text, and commands to print the text.  Supports
		4 color text in bold, italic, underlined, or inverse fonts.
		Can load xpk crunched files.  Has a display mode requester.
		Is localized with German, Italian, French, and Swedish cat-
		alog files.  Supports pipes.  Requires KickStart 2.04 or
		later.  This is version 4.2, an update to version 3.6 on
		disk number 935.  Includes source in Oberon-2.
		Author:  Fridtjof Siebert, Christian Stiens

ToolAlias	Provides  a  mechanism  for rerouting specific programs
		to other programs.  For example, with ToolAlias, you could
		reroute all references to ':c/muchmore'  to use 'sys:util-
		ities/ppmore' instead, so that when browsing documents on
		a Fish disk, you get to use your favourite text viewer,
		rather than loading the one specified in the document's
		ToolTypes.  Requires OS2.0+.  Version 1.02, Includes source.
		Author:  Martin W. Scott

Touch		Another Amiga version of the Unix utility with the same
		name.  Touch changes the date and time stamp of all speci-
		fied files to the current date and time.  This version will
		also create an empty file (like the Unix version) if the
		specified file does not exist.  Version 1.2, an update to
		version 1.0 on disk 919.  Public domain, includes source.
		Author:  Kai Iske

-------------------------
New/AmigaLibDisks/Disk963
-------------------------

BootPic		BootPic shows nearly any IFF picture that you like while
		your system is initialized after a reset.  Additionally,
		it may play a MED-Module.  Requires OS 2.0 or higher.
		Version 3.1, a major update to version 2.1b on disk number
		718.  Binary only.
		Author:  Andreas Ackermann

Codecracker	Another MasterMind clone.  Difficulty level may be set by
		selecting the number of color columns and the number of
		different colors to choose from.  Documentation contained
		within the program.  Version 2.23,  binary only.
		Author:  Michael Reineke

SIOD		An interpreter for the algorithmic language Scheme, a dia-
		lect of LISP developed at MIT.  Siod is a C implementation
		that covers a large part of the standard and can be run
		with a small amount of memory (also runs on old A500 NOT
		expanded).  It is the ideal tool to learn the language or
		for experimenting with functional languages.  Version 2.6,
		includes source and examples.  Based on the original code
		from Paradigm Inc.  An update to version 2.4 on disk number
		525.
		Author:  Scaglione Ermanno

Split!		A high-speed file splitter.  Splits a large file into
		several smaller files (size is user-definable).  Due
		to the use of a 32k buffer, Split! is up to 14 times
		faster than the competition.  CLI interface.  Originally
		created for transporting large documents.  Version 1.0,
		binary only.
		Author:  Dan Fraser.

-------------------------
New/AmigaLibDisks/Disk964
-------------------------

Angie		ANother Great Intuition Enhancer commodity that can be
		used to assign AngieSequences that can consist of dozens
		of Intuition related actions, arbitrary dos commands
		and input event data to an unlimited number of hotkeys.
		Furthermore, these AngieSequences can be executed via
		ARexx.  Angie's capabilities include auto window hunting,
		auto ActiveWinTask priority increment, 'TWA' window
		remembering, auto DefPubScreen definition, etc.  Angie
		comes with a comfortable Intuition user interface and
		is completely localized.  Includes English and German
		documentation and German catalog.  Version 3.6, an update
		to version 1.6 on disk number 938.  Binary only, giftware.
		Author:  Franz Schwarz

NewDate		A replacement for the AmigaDOS command 'Date'.  Besides
		the usual date options, NewDate enables date output in your
		own defined format.  NewDate currently supports 18 lang-
		uages: English, German, French, Dutch, Italian, Spanish,
		Portugese, Danish, Finnish, Swedish, Norwegian, Icelandic,
		Polish, Hungarian, Czech, Romanian, Turkish and Indonesian.
		Version 1.20, an update to version 1.10 on disk number 859.
		Binary only, freeware,
		Author:  Chris Vandierendonck

RIVer		This program searches an embedded version ID in a file.
		Like the 'Version' command you can check the version and
		revision number of a file.  You can also add this embedded
		version ID as a filenote, or print it in a table where each
		field of the ID is clearly stated.  You can also construct
		your own version comment using embedded version ID fields.
		Version 2.30, an update to version 2.00 on disk number 787.
		Binary only, freeware.
		Author:  Chris P. Vandierendonck

Stocks		Demo version of a stocks analysis program.  Provides
		powerful technical analysis using numerous studies
		including Candlesticks, traditional bar charts, 3
		moving averages, MACD, Stochastics, Gann, TrendLines,
		%R, Average Volume and more.  It generates buy/sell
		signals based on customizable trading rules and
		graphs daily, weekly, and monthly charts using a
		simple ASCII data file format compatable with Compu-
		Serve historical data.  Displays on Workbench or Custom
		Public Screen.  Includes on-line AmigaGuide help text.
		Requires OS2.0+.  Version 3.02a, binary only.
		Author:  James Philippou, Bug-Free Development

-------------------------
New/AmigaLibDisks/Disk965
-------------------------

CDPlay		A small CD Player designed for the Xetec CDx Software.
		The program uses a small window that opens on the
		Workbench screen.  Smaller with many more functions
		than those on the player that is supplied with the
		Xetec Software.  Version 2.01, binary only.
		Author:  Nic Wilson

UChess		A powerful version of the program GnuChess version 4 for the
		Amiga.  Plays a very strong game of chess.  Code has been
		rewritten and data structures reorganized for optimal effi-
		ciency on 32 bit 68020 and better Amiga systems.  Fully
		multitasking, automatically detects and supports 640X480X256
		color AGA mode machines, and does not at any time BUSY wait.
		Requires a 68020/030/040 based Amiga computer system with
		AmigaOS 2.04 or later and 4 Meg of ram minimum.  Special "L"
		version optimized for 68040 and requires 10 Meg of ram mini-
		mum.  Supports a variety of standard features such as load,
		save, edit board, autoplay, swap sides, force move, undo,
		time limits, hints, show thinking, and a supervisor mode
		that will allow two humans to play with the computer acting
		as a "supervisor".  Version 2.69.  Source for this version 
		may be found on AmigaLibDisk966. 
		Author:  FSF, Amiga Port by Roger Uzun

-------------------------
New/AmigaLibDisks/Disk966
-------------------------

CDTV-Player	A utility for all those people, who'd like to play Audio
		CD's while multitasking on WorkBench.  It's an emulation of
		CDTV's remote control, but is a little more sophisticated.
		Allows access to the archive even without a CDROM drive
		(i.e. AMIGA 500-4000), although you can't play a CD.  Pro-
		gram and KARAOKE (live on-screen) included.  Recognizes CDs
		automatically.  Works on all CDTVs, AMIGA CD 32 and all CD
		ROM emulating the cdtv.device or cd.device.  Version 2.31,
		an update to version 2.05 on disk 894.  Freeware, binary
		only.
		Author:  Daniel Amor

FHSpread	A Spreadsheet program that uses its own custom screen.  Can
		be switched between hires, laced and PAL, NTSC.  Should work
		on any amiga with at least 1MB.  Version 2.01, an update to
		version 1.71 on disk number 887.  Binary only.
		Author:  Frank Hartog

UChessSrc	Lha archive of all the sources necessary to build UChess 
		version 2.69 as contained on disk number 965.
		Author:  FSF, Amiga Port by Roger Uzun


-------------------------
New/AmigaLibDisks/Disk967
-------------------------

IconTrace	Use this program to find out which tooltypes a program
		supports and which icons it looks for.  KickStart 2.0 or
		higher required.  This is version 2.02, binary only.
		Author:  Peter Stuer

MUI_usr		An object oriented system to create and maintain graphical
		user interfaces.  From a programmer's point of view, using
		MUI saves a lot of time and makes life much easier.  Think-
		ing about complicated terms like window resizing or font
		sensitivity is simply not neccesary.  On the other hand,
		users of MUI based applications have the ability to custom-
		ize nearly every pixel of a program's interface according
		to their personal taste.  Version 1.4, this is part 1 of a
		2 part distribution and contains the user system.  The 
		developers support package can be found on disk number 968.
		Shareware.
		Author:  Stefan Stuntz

-------------------------
New/AmigaLibDisks/Disk968
-------------------------

DiskInfo	A replacement for the AmigaDOS 'Info' command, but can
		additionally give more extensive information on the disk
		(volume) and/or on the device in which the disk is inserted.
		Version 2.00, an update to version 1.00 on disk number 783.
		Binary only, freeware.
		Author:  Chris P. Vandierendonck

JustLook	A collection of routines for controlling the mouse and key-
		board thru generation of 'Input Events'.  Implemented as
		object code to be linked with your programs.  This is for
		application writers who like to include HowToDo programs
		with their applications.  Users can actually see how to do
		things, rather than describing them in document files. This
		is not a recorder, mouse and keyboard events are generated
		in real time and so the software adapts itself to changes
		at a particular execution.  Includes example programs and
		source in C and assembly.
		Author:  Kamran Karimi

MUI_dev		An object oriented system to create and maintain graphical
		user interfaces.  From a programmer's point of view, using
		MUI saves a lot of time and makes life much easier.  Think-
		ing about complicated terms like window resizing or font
		sensitivity is simply not neccesary.  On the other hand,
		users of MUI based applications have the ability to custom-
		ize nearly every pixel of a program's interface according
		to their personal taste.  Version 1.4, this is part 2 of a
		2 part distribution and contains the developer support 
		package.  The user system can be found on disk number 967.
		Shareware.
		Author:  Stefan Stuntz

PowerSnap	A utility that allows you to use the mouse to mark charac-
		ters anywhere on the screen, and then paste them somewhere
		else, such as in another CLI or in a string gadget.  Checks
		what font is used in the window you snap from and will look
		for the position of the characters automatically.  Recog-
		nizes all non-proportional fonts of up to 24 pixels wide
		and of any height.  Works with AmigaDOS 2.0 in both shell
		and WorkBench environments.  This is version 2.2, an up-
		date to version 2.1b on disk 781.  Binary only.
		Author:  Nico Francois

-------------------------
New/AmigaLibDisks/Disk969
-------------------------

ACE		ACE is a FreeWare Amiga BASIC compiler which, in conjunc-
		tion with A68K and Blink, produces standalone executables.
		The language defines a large subset of AmigaBASIC but also
		has many features not found in the latter.  A simple graph-
		ical front-end (Integrated Development Environment) is
		also provided.  This is written in ACE.  Version 2.0,
		freeware, binary only.
		Author:  David Benn

DOSTrace	SnoopDOS clone with a lot more whistles and bells: session
		history, commodity, and can trace a lot more functions than
		SnoopDOS.  KickStart 2.04 or higher required.  This is
		version 2.13, binary only.
		Author:  Peter Stuer

LazyBench	A little utility for lazy people with a hard disk crammed
		full of goodies which are too difficult to reach because
		they are buried away in drawers inside drawers inside
		drawers inside drawers...  LazyBench installs itself as a
		commodity, adds an item under the Workbench "Tools" menu
		and waits in the background.  Use its hot key combination
		to pop up its window and select an item from the list
		displayed, thus launching your favourite application
		without messing around with windows and drawers.  Font
		sensitive, Style Guide compliant and fully configurable.
		Requires AmigaDOS 2.xx or later.  Version 1.14, an update
		to version 1.12 on disk 935.  Binary only.
		Author:  Werther 'Mircko' Pirani

SysInfo		A brand new release of this popular program.  It reports
		interesting information about the configuration of your
		Amiga, including some speed comparisons with other config-
		urations, versions of the OS software, and much more.
		Version 3.23, an update to version 3.18 on disk number 860.
		Binary only.
		Author:  Nic Wilson

-------------------------
New/AmigaLibDisks/Disk970
-------------------------

ADM		A comfortable and flexible address database with font sensi-
		tive windows, commodity support, application window support,
		an ARexx-port, public screen support, and totally control-
		lable from the keyboard.  It includes user flags (grouping),
		email support, and freely configurable label printing.  It
		can fill out letter forms and call your word processor,
		print remittance orders, dial numbers, and has online help.
		Requires AmigaDOS version 2.04 or later.  Version 1.20, an
		update to version 1.01 on disk 847. German version only.
		Shareware, binary only.
		Author:  Jan Geissler

NoNTSC		Converts NTSC-Screens to PAL-Screens.  It links into the
		OpenScreen-Routine and looks at the height of every screen
		opened.  If it has NTSC-Height (200 Pixels), it is converted
		to PAL-Height (256 Pixel).
		Author:  Thorsten Stocksmeier

UUCode		Optimized uuencode/uudecode programs.  Designed to be 
		reliable and fast.  Also includes 68030 based versions.
		V36.6, includes source.
		Author:  Ralph Seichter

-------------------------
New/AmigaLibDisks/Disk971
-------------------------

DiskInfo	A replacement for the AmigaDOS 'Info' command, but can
		additionally give more extensive information on the disk
		(volume) and/or on the device in which the disk is inserted.
		Version 2.00, an update to version 1.00 on disk number 783.
		Binary only, freeware.
		Author:  Chris P. Vandierendonck

QDisk		A WorkBench utility that will monitor the space usage of
		any mounted AMIGA DOS volume, like your hard drive or your
		floppy drive.  QDisk  will also notify you if a volume
		becomes too full.  Comes  with a preference editor to
		customize QDisk to your needs.  Version 2.01, an update
		to version 1.1 on disk 903.  Freeware, binary only.
		Author:  Norman Baccari

Yak		Yet Another Kommodity.  Features a sunmouse that only acti-
		vates when the mouse stops, KeyActivate windows, click win-
		dows to front or back, cycle screens with mouse, mouse and
		screen blanking, close/zip/shrink/enlarge windows with pro-
		grammable hotkeys and a lot of other configurable hotkeys.
		Fully localized English language builtin and provided cata-
		logs for Dutch, French, German, Italian and Swedish.  Docu-
		mentation in English, French, German and Italian.  Includes
		installer scripts and C source.  Version 1.57, an update to
		version 1.52 on disk number 912.
		Author:  Gael Marziou & Martin W. Scott

-------------------------
New/AmigaLibDisks/Disk972
-------------------------

Icons		A bunch of 4-Color Icons from which you may find something
		suitable for your particular WorkBench environment.
		Author:  Magnus Enarsson

IntelInside	A cute little play on the marketing motto of that "other"
		family of microprocessors  ...a WorkBench TrashCan Icon.
		Author:  Unknown... (Unconfessed??)

MoreIcons	Another bunch of Icons (8-Color this time) from which you
		may find something suitable for your particular WorkBench
		environment.
		Author:  Dan Elgaard

QuickFile	QuickFile is a flexible, easy to use flat file database.
		Files can be larger than available ram, but as much of the
		file as possible is kept in ram for fast access.  Features
		include: multiple indexes that are automatically maintained;
		character, date, integer and floating point data types; up
		to 250 characters per field and 250 fields per record; form
		and list style displays and reports;  unlimited number of
		views for each file; fast sorting with multiple sort keys;
		improved search function;  fields can be added, changed, or
		deleted at any time; flexible ascii export/import; flexible
		multi-column label printing.  Runs on WB1.3 or later and
		should be OK with 512K ram.  Version 2.02, an update to
		version 1.3.3 on Disk 919.  Shareware, binary only.
		Author:  Alan Wigginton

RCON		A replacement for the CON:-Handler of Amiga-OS 2.x / 3.x.
		Has many new features including scrolling back text which
		has disappeared, enhanced copy & paste support, window
		iconification, output logging, print window contents, and
		much more.  This is a demo distribution of a shareware
		product.  Version 1.4, an update to version 1.0 on disk
		930.  Binary only.
		Author:  Gerhard Radatz

-------------------------
New/AmigaLibDisks/Disk973
-------------------------

TextPlus	A TeX frontend word processor.  TPP provides facilities
		for tables, lists, mailmerge, footnotes, inclusion of
		iff-graphics, an ARexx-Port (122 commands), printing
		via the printer.device (no TeX needed for this), and
		full OS2.xx/3.xx compatibility.  Makes use of PasTeX,
		Georg Hessmann's Amiga implementation of TeX, or
		AmigaTeX of Radical Eye Software, which is supported
		from now on.  New features: user definable menus,
		keymap, and macros; completely localized (available
		languages: english, deutsch); clipboard support;
		AppWindow, AppIcon; 11 new ARexx commands.  This is
		version 5.01, an update to version 4.10 on disk
		845/846.  Shareware, binary only.
		Author:  Martin Steppler

-------------------------
New/AmigaLibDisks/Disk974
-------------------------

DDLI		The Duniho and Duniho Life Pattern Indicator (DDLI) is a
		program that asks you questions in order to determine your
		Life Pattern.  The Life Patterns correspond to the sixteen
		psychological types measured by the Myers-Briggs Type
		Indicator (MBTI), and they are represented by the same
		abbreviations.  By using knowledge that Terence Duniho has
		added to the study of Type, this program also checks itself
		by asking supplementary questions about other preferences
		that correlate with a person's type.
		Author:  Fergus Duniho

KingCON		A console-handler that optionally replaces the standard
		'CON:' and 'RAW:' devices.  It is 100% compatible, but adds
		some VERY useful features, such as: Filename-completion
		(TAB-expansion); A review-buffer; Intuition menus; Jump
		scroll (FAAST output!).  Cursor-positioning using the mouse;
		MC68020-optimized version; And more... Version 1.1,
		requires OS2.x, binary only.
		Author:  David Larsson

MathPlot	A function plotter with lin/log plot, a complete KS 2.0
		interface, and ARexx support.  Needs Kickstart/WorkBench 2.0
		and mtool.library (included).  Version 2.20, an update to
		version 2.07 on disk number 916.  This is a Demo version
		with some options disabled, requires a key file for full
		functionality.  Shareware, source available from author.
		Author:  R|diger Dreier

-------------------------
New/AmigaLibDisks/Disk975
-------------------------

CLIExchange	A 592 byte CLI replacement for the standard CBM Exchange
		utility.  The only difference is that Exchange has a graph-
		ical user interface while CLIExchange has been designed to
		be called from CLI so it can be used within scripts, menus,
		docks or hotkeys.  You need at least 2.04 system release.
		C source included.
		Author:  Gakl Marziou

DieserZug	A nicely done WorkBench "Worms" type game, where the object
		is to gobble up pieces making yourself longer and longer,
		while avoiding running into the walls or your "tail".
		Features 3 different speeds, high score list, pause and
		help keys.  Version 1.2a, binary only.
		Author:  Juha Vehvildinen

ITF		Amiga port of ITF4.01.  ITF stands for "Infocom Task Force".
		There have been several ports of Infocom interpreters to the
		Amiga, but none of this program.  The interpreter supports
		v1, v2, v3 (Zork1 to Stationfall), v4 (Trinity, Bureaucracy,
		etc.) and v5 (Sherlock, Beyond Zork etc.) games.  This is
		more than any other freely distributable interpreter.  With
		this interpreter you can play ALL the games in the LTOI2
		package for the IBM PC, by copying the datafiles with Cross-
		DOS or similar, then just running this interpreter.  Re-
		quires OS 2.0+.  Binary only.
		Author:  InfoTaskForce, amiga port by David Kinder

PCal		Creates a very nice looking postscript calendar.  By
		default, PCal simply prints an empty calendar.  Its
		real power is in its ability to place ``events'' in
		appropriate days on the calendar, thus allowing the
		user to create personalized calendars.  This is achieved
		through the use of a "calendar.dat" file that has
		extraordinary flexibility.
		Author:  Patrick Wood, Joe Brownlee, Andy Fyfe, et al.

-------------
New/biz/dbase
-------------

DiskCat		DiskCat is a configurable disk librarian.  The files can be
		organized any way you want.  You can make and name any cat-
		egory you care to.  Categories and files can be moved.
		Through menu selection, all disks that are inserted are
		automatically searched and the useful information copied.
		A 45 character comment can be entered for each file.  The
		database can be searched and exported.  Version 2.1, an
		update to version 1.3 on disk 889.  Requires OS 2.04 or
		later.  Shareware, binary only.
		Author:  Kenny Nagy

------------
New/biz/demo
------------

OnTheBall	Demo version of a desktop aid that contains: Calendar, View
		& Print adjustable week, month, and yearly schedules.
		Search forward & backward through appointments.  9 repeat
		modes.  Reminder with snooze.  Addressbook -- Mailing
		labels, autodialer.  Search & sort by any field.  Attach
		notes.  To-Do List -- Sorts by optional due dates.
		Search/Print.  NotePad, Full-featured text editor, have as
		many notes open at one time as you like.  Attach notes to
		any entry in any application.  Multi-lingual, works on all
		Amigas.  Preferences.  ARexx.  Imports Nag(c) files.
		Create personalized "Tags".  Much more.  Version 1.20, an
		update to version 1.10 on disk 890.  Binary only.
		Author:  Jason Freund, Pure Logic Software

TurboCalc	A spreadsheet which was chosen as "spreadsheet of the year"
		for Amiga computers by the readers of one of Germany's most
		important Amiga magazines.  This is a demo version with
		disabled save and print functions.  Has more than 100
		functions and 120 macro commands, include ARexx commands.
		Has an integrated database with search, sort, copy, extract,
		delete, and other database functions such as number of
		matches, average, etc.  Diagrams and charts are included
		and very easy to handle.  This is version 2.0, binary only.
		Author:  Michael Friedrich

------------
New/comm/net
------------

CASIOlink	A program for transmitting data between the Amiga and
		Casio pocketcomputer FX-850P (FX-880P).  Needs OS2.0.
		Version 1.0, includes source in C.
		Author:  Frank Nie_en

Hydra		HYDRA is a bidirectional file transfer protocol designed
		by Joaquim H. Homrighausen and Arjen G. Lentz similar to
		Bimodem, a proprietary file transfer protocol.  It origi-
		nated in the PC world and has been ported to the Atari ST
		and Amiga.  The HYDRA protocol can send and receive data
		at the same time and also adds a chat option.
		Author: Joaquim H. Homrighausen, Arjen G. Lentz
			Amiga port by Olaf Barthel

---------
New/dev/c
---------

DiceConfig	A GUI based fronted for the Dice C compiler.  Version 2.0,
		shareware, binary only.
		Author:  Laurent Faillie

-----------
New/dev/gui
-----------

MUI		An object oriented system to create and maintain graphical
		user interfaces.  From a programmer's point of view, using
		MUI saves a lot of time and makes life much easier.  Think-
		ing about complicated terms like window resizing or font
		sensitivity is simply not neccesary.  On the other hand,
		users of MUI based applications have the ability to custom-
		ize nearly every pixel of a program's interface according
		to their personal taste.  Version 2.0, includes developers
		support package and several demos.  Shareware.
		Author:  Stefan Stuntz

------------
New/dev/misc
------------

CatEdit		A GUI catalog editor/translator, allows you to translate
		localized programs.  You can also remove errors in the
		translation of a program or even the Workbench.  All you
		need to translate a program is a catalog file in a language
		that you understand.  Requires Workbench 2.1 or higher.
		This is version 1.1a, binary only.
		Author:  Rafael D'Halleweyn

SetPatch	Setpatch is designed to improve system operation by fixing
		(patching) various system problems.  Setpatch 37.39 is for
		AmigaDOS 2.04 (V37).  Setpatch 40.14 is for AmigaDOS 2.1
		(V38) through AmigaDOS 3.1 (V40).  Binary only.
		Author:  Commodore Business Machines

--------------
New/disk/cdrom
--------------

CDDA		This program replays digital audio data directly off a
		compact disc using the Amiga audio hardware (in stereo
		where available).  A special type of CD-ROM drive is
		required since this program makes use of a vendor unique
		command supported by Sony drives, such as the CDU-8003A
		or the Apple CD-300 drive.  Version 1.3, includes source
		in C.
		Author:  Olaf Barthel

-------------
New/disk/moni
-------------

DiskMon		A Disk-Monitor that works with most block devices
		(Floppies DFx, PCx, MFH, ... DD and HD, Harddisks inclu-
		ding RDSK-blocks, RAD:, MAP:, etc).  Features: Block-
		Monitor, File-Monitor, MFM-Editor for Floppies, BAM-
		Editor, Track-Repair, Search (ASCII and HEX), and more.
		Full working version with 'pay shareware'-delays.
		Version 2.6t, shareware, binary only.  Works with
		Kickstart 1.2, 1.3, OS 2.x, 3.x.
		Author:  Jvrg Strohmayer

-------------
New/disk/salv
-------------

Val		A disk partition validator that only reads your disk (no
		writes to it).  Should work with any 512 byte block struct-
		ured virtual or physical disk partition which uses the
		Original File System (OFS) or Fast File System (FFS).  Val
		will check out the disk and output error messages and
		warnings according to any problems it may find on the disk,
		with a reasonably concise message about what it thinks is
		wrong.  Val will find errors that the standard Disk-Valida-
		tor will ignore, such as a file header that points to more
		or less blocks than the filesize represents.  Version 2.3,
		includes source in C.
		Author:  Andrew Kemmis

Find		Find is a tool for searching disk partitions and is parti-
		cularly useful with the disk validator tool "Val" by the
		same author.  It should work with any 512 byte block struc-
		tured virtual or physical disk partition i.e. it should
		work with any device that allows you to do any CMD_READ of
		512 bytes at multiples of 512 byte Offsets - sequentially
		from any start block to any end block.  Find by-passes the
		FileSystem running on the device and does direct I/O to the
		device itself.  Version 2.3, includes source in C.
		Author:  Andrew Kemmis

-------------
New/game/role
-------------

SOI		Spheres of Influence is a game of galactic colonization.
		This is a demonstration version that is fully functional
		except that it only allows 40 turns of play.  Requires 1Mb
		of chip RAM and AmigaDOS 2.0 or higher.  Version X.XX,
		binary only.
		Author:  Ed Musgrove

--------------
New/game/think
--------------

Arachnid	A patience game with two deck's of cards.  The object of
		the game is to build a stack of cards in the same suit,
		from King to Ace, and remove the stack from the table to
		the stacks above.  When all eight stacks have been built
		and removed, you have won the game.  A more challenging
		version of this is to leave all eight stacks on the table
		until done, instead of removing those that are complete
		to the stacks above.  Needs OS2.0, PAL interlace screen,
		and it would be nice to have a three-button-mouse.  This
		is version 1.1.  Includes source in C.
		Author:  Frank Nie_en

ColConq		Colonial Conquest is a space-strategy game for one or two
		persons.  The basic idea and concept have been heavily
		influenced by the shareware game "Conquest" and the Micro-
		prose game "Civilization".  The aim of the game is to spread
		your civilization through the 26 earth-like planets of the
		universe map and to defend it from other civilizations by
		building weapons and war ships.  Unfortunately - like all
		half-realistic simulations and strategy games - Colonial
		Conquest will reward primitive destructive behavior and
		colonial instincts without leaving much room for cooperative
		actions and peaceful living.  Version 1.05, binary only.
		Author:  Christian Mumenthaler

Lines		A simple game with the object of drawing as many lines as
		you can on a 2-D grid of points.  Each line can be drawn in
		the horizontal, vertical, or diagonal direction, and is 
		exactly 5 points long.  Each line must include at least
		4 previously unused points.  Version 2.2, binary only.
		Author:  Mika Kortelainen

MasterMind	Master Mind is a simple but interesting game.  The Amiga
		chooses some colors randomly and places them in a row. You
		have to guess not only the colors, but also their places in
		the row. To do this, you guess some colors and place them
		in a row as you see appropriate.  When done, the Amiga
		shows you the results by way of white and black circles.
		You use this information to help make a better guess in the
		next row, until you either find the correct colors and
		their order, or you lose.  Version 1.6, includes source
		in C.
		Author:  Kamran Karimi

UChess		A powerful version of the program GnuChess version 4 for the
		Amiga.  Plays a very strong game of chess.  Code has been
		rewritten and data structures reorganized for optimal effi-
		ciency on 32 bit 68020 and better Amiga systems.  Fully
		multitasking, automatically detects and supports 640X480X256
		color AGA mode machines, and does not at any time BUSY wait.
		Requires a 68020/030/040 based Amiga computer system with
		AmigaOS 2.04 or later and 4 Meg of ram minimum.  Special "L"
		version optimized for 68040 and requires 10 Meg of ram mini-
		mum.  Supports a variety of standard features such as load,
		save, edit board, autoplay, swap sides, force move, undo,
		time limits, hints, show thinking, and a supervisor mode
		that will allow two humans to play with the computer acting
		as a "supervisor".  Version 2.71, includes source.
		Author:  FSF, Amiga Port by Roger Uzun

------------
New/gfx/edit
------------

Duerer		A paint program which is easy to understand and simple to
		use.  All common functions for a paint program are included.
		A special feature is the RAW file format in addition to the
		IFF format.  The RAW format is especially interesting to
		hardware programmers.  Almost all Amiga screen resolutions
		can be used.  The program design is similar to GeoPaint, a
		well-known C64 program.  Version 1.01, binary only, however
		assembly source is available from the author.
		Author:  Stefan Kuwaldt

MainActor	A modular animation package with many features.  Modules
		included in this release are IFF-Anim 5/7/8/AnimBrush, FLI,
		FLC, DL, PCX, GIF, IFF.  The features include playing from
		harddisk, playing animations in windows (OS3.0), timing of
		animations and much much more.  The Picasso-II and Retina
		gfx boards are supported.  Version 1.23, an update to
		version 1.16 on disk number 914.  Binary only.
		Author:  Markus Moenig

------------
New/gfx/misc
------------

Clouds		This program creates random cloud images which you might
		use in your paint program, as a texture in a ray tracing
		program or as a background for your workbench.  Uses all
		ECS and AGA resolutions.  Works with Workbench 1.2 up to
		3.1.  Version 3.1, an update to version 2.9 on disk 893.
		Public domain, includes complete source in KICK-PASCAL.  
		Author:  Daniel Amor

------------
New/misc/edu
------------

Verbes		Ensemble Verbes is a program to help students practice and
		master French verbs in the most common tenses of the lang-
		uage.  It is designed to support classroom work, not to
		replace it.  Features include online context-sensitive help
		via AmigaGuide, close adherence to Amiga User Interface
		Style Guide, sound support, support for international key-
		boards, and locale support for English and French.
		Version 1.1, binary only.
		Author:  Peter Janes

------------
New/misc/sci
------------

Accrete		A program, originally written in Pascal for the Apple ][,
		that generates random star systems based, primarily, on
		Stephen Dole's work, "Habitable Planets for Man".  The
		output is a text file describing the primary attributes of
		a star and its planets, including density, mass, surface
		temperature and pressure, orbit and rotation period and
		even the boiling point of water on the surface.  Version
		1.1, includes SAS/C source.
		Author: Joe Nowakowski and Ethan Dicks

------------
New/mus/misc
------------

HD_Frequency	A 'professional' hard disk recording system with many fea-
		tures.  Sampling rates as 60 khz on A1200 or 35 khz on stan-
		dard A500 are no problem any longer.  The program includes
		a 4 track hd-sequencer that manages replaying 4 tracks at
		the same time from HD.  Also features a module GUI and 
		executables for 68020/68030 systems.  Limited, demo version
		only.  This is version 38.051, an update to version 37.142
		on disk 924.  Shareware, binary only.
		Author:  Michael Bock

--------------
New/os20/cdity
--------------

DeviceLock	Commodity for easy control of the CLI-program 'Lock' via
		GUI.  Extensive preferences, can show current lock status.
		This is version 1.0, includes source in Oberon.
		Author:  Thomas Wagner

SunWindow	A virtual screen/window manager, which makes it a lot easier
		to control windows on (virtual) public screens.  The whole
		screen with its windows can be controlled via a little win-
		dow which re-displays the whole screen.  Lots of hotkeys
		offer you great control over windows and screens.  Requires
		the reqtools.library (provided).  Shareware, version 2.0
		revision 030, binary only.
		Author:  Bernhard Scholz

------------
New/os20/cli
------------

Man		A simple MAN command, known from UNIX systems.  The advan-
		tage is that it recognizes .guide files to be AmigaGuide
		documents.  MAN then uses a different viewer in order to
		display the AmigaGuide document.  You may configure MAN
		using environment variables.  Configuration can be done
		for:  Directories, where to look for man pages (either
		.doc or .man or .guide), ASCII Textviewer, AmigaGuide
		Textviewer.  Version 1.9, public domain, includes source.
		Author:  Kai Iske

Move		Moves files from here to there.  You may give as many source
		files as will fit on one command line, even including pat-
		terns.  Issuing directory names will cause Move to create a
		directory of the same name within the destination directory
		(if not already present) and move all the files from the
		source directory to the destination,  with all subdirect-
		ories.  Several command line options for specifying cloning,
		verbosity, replace existing, etc.  Requires OS2.x, version
		1.8, public domain, includes SAS 6.3 C-source.
		Author:  Kai Iske

------------
New/os20/gfx
------------

FastLife	A fast life program featuring an Intuition interface and
		200+ patterns in text file format.  Runs with AmigaDOS 2.04
		and later, and uses the ReqTools requester package.
		Features include support for all screen modes, screens
		up to 16384 by 16384, run for a specified number of
		generations, stop at a specific generation, CLI and
		ToolTypes support for file name filter and "ON" character
		within Picture files, Tomas Rokicki's ultra-fast life
		routines, a torus option, and random field generation.
		This is version 2.7, an update to version 2.2 on disk 802.
		Binary only.
		Author:  Ron Charlton

-------------
New/os20/util
-------------

MCalc		MUIProCalc is a MUI-based calculator much like Jimmy Yang's
		Calc 3.0.  It still lacks the plotter, but it offers a quite
		flexible history facility for inserting previously entered
		expressions.  Different output formats offered and plenty of
		functions the user may choose from.  Furthermore the look
		of the calculator may be customized.  It offers an ARexx
		port, which may be used to let MUIProCalc calc from within
		an editor for example.  MUIProCalc may return a TeX compa-
		tible output, which may be used within a mathematical TeX
		environment.  Results or inputs may be copied to the Clip-
		board.  Requires MUI (MagicUserInterface by Stefan Stuntz)
		GiftWare, version 1.2, includes source.
		Author:  Kai Iske

-----------
New/os20/wb
-----------

ForceIcon	ForceIcon is an utility mainly for users of CD-ROM drives.
		One cannot snapshot the position of a volume's icon, nor
		replace it by a user-defined one.  ForceIcon allows you
		to set the position of a disk`s icon and/or replace it by
		a different image/icon which doesn't have to be a disk.info
		file.  All types of ".info" files may be selected.  This is
		version 1.2, giftware, includes source.
		Author:  Kai Iske

IconMonger	CLI-only utility for making changes to icons.  Can work on
		single icons or selected icons within a single directory or
		on an entire directory tree or disk.  Select icons by name,
		image, type, stack size and/or default tool, and change
		their image, colors, stacksize, default tool and/or posi-
		tion.  Requires 2.04 or above.  Version 2.0, binary only.
		Author:  Todd M. Lewis

ToolType	A program to make it easier to edit tooltypes in icons.
		ToolType will read the tooltypes from an icon file and let
		you use your favorite text editor to change or add to the
		tooltypes.  ToolType can be run from shell, Workbench, or
		set up as an appicon.  Includes an option to sort the tool-
		types alphabetically.  Requires WB 2.0 or later.  Version
		37.210, an update to version 37.206 on disk number 934.
		Binary only.
		Author:  Michael J. Barsoom

-------------
New/os30/util
-------------

ColorRequester	The standard Amiga 3.0 Preferences Palette Requester is
		very limited in that it only operates on the first eight
		screen colors.  Screen Color Requester solves this prob-
		lem for AGA Amigas by providing palette controls that
		allow you to change, copy, swap, spread, and cycle all
		individual colors of the workbench or any public screen.
		You can also load and save modified screen palettes for
		various applications.  AmigaDOS 3.0 is required.  If you
		are a programmer, you can link the included object file
		with your own programs and save yourself the work of
		programming a color requester of your own.  Binary only.
		Author:  Richard Horne

SwazInfo	SwazInfo replaces WorkBench's icon information window while
		still retaining all the information and options and provid-
		ing several enhancements.  Features added in addition to
		normal Workbench information are: AppWindow, support for
		MultiuserFileSystem, configurable window font, commodities
		support, and ARexx support.  Version 1.0, binary only.
		Author:  David Swasbrook

------------
New/pix/misc
------------

HubblePics	Miscellaneous scanned pictures from the Hubble project.
		Includes pictures of the shuttle crew fixing Hubble,
		and some images that it took after it was fixed.
		Author:  NASA

-------------
New/text/docs
-------------

AmigaFAQ	Lists some frequently asked questions and trys to give
		answers.  Its intention is to help new users and to reduce
		the amount of news that most experienced users don't like
		to read anymore.  Sections on Hardware, Software, Program-
		ming, Applications, Graphics and more.  Formatted in plain
		ascii, AmigaGuide, DVI, and texinfo.  Version dated January
		28, 1994.  Drawer also contains some useful text files on
		ftp sites, newgroups, hardware tips and one on the history
		of the amiga.
		Author:  Jochen Wiedmann, text files from various sources

------------
New/util/arc
------------

AII		The Archiving Intuition Interface is a program that makes
		using archiving software infinitely easier by adding a GUI
		(mouse base interface).  Supports Lha, Zoo, Arc, UnArj,
		Zip, DMS, LhWarp and Shrink.  Requires Reqtools.library,
		OS 2.x supported, 1.3 compatible.  This is version 2.0,
		an update to version 1.38 on disk 884.  Shareware, binary
		only.
		Author:  Paul Mclachlan

S-Pack		One program for all your file-packing requirements inclu-
		ding HD-backup, archiving, data transfer.  Unbeatable
		compression, self-unpacking, multi-volume packs.  Needs
		no special libraries or handlers.  Version 1.1, freeware,
		binary only.
		Author:  Chas A.Wyndham

--------------
New/util/dbase
--------------

A-Kwic		The A-Kwic system provides a facility where users can do
		keyword searches of text data.  A-Kwic creates a database
		of text records.  Each record is scanned for keywords.
		Once the database is created, the user uses a search
		program to do keyword searches to find, and optionally
		display, records that match the specified keyword(s).
		Multiple keywords can be specified.  They can be "anded"
		or "ored", and "wildcard" specifiers can also be used.
		The A-Kwic was originally developed to index "Fish Disk"
		content listings.  It is also handy for indexing the
		contents of CD-ROMs.  Another use is for companies to
		index customer files, based on various keywords, or to
		index customer support trouble reports or product fix
		descriptions.  Version 2.0, binary only.
		Author:  David W. Lowrey

Genie		A GUI-based genealogy data manager and report generator.
		Can generate Ahnentafel, family group record, pedigree, and
		descendancy charts plus listings of all people and spouses.
		Can handle 32K+ people, unlimited spouses and children.
		GEDCOM output has been validated by LDS Church for Ancestral
		File submission.  Requires AmigaDOS 2.0 or later.  This is
		version 2.56, shareware demo, binary only.
		Author:  Everett M. Greene

-------------
New/util/edit
-------------

Vim		Vi IMproved.  A clone of the UNIX text editor "vi".  Very
		useful for editing programs and other plain ASCII text.
		Full Vi compatibility (except Q command) and includes most
		"ex" commands.  Extra features above Vi: Multilevel undo,
		command line history, improved command line editing, com-
		mand typeahead display, command to display yank buffers,
		possibility to edit binary files, file name stack, support
		for Manx QuickFix, shows current file name in window title,
		on-line help, text block operations, etc.  This is version
		2.0, an update to version 1.14 on disk 591.  Includes a few
		bug fixes and new features like tag stack, file marks, jump
		list, visual (first select area, then operator), use of
		cursor keys in insert mode, column mode copy/cut/paste,
		macro programming by example, text formatting, termcap
		support, etc.  Also runs under UNIX and MSDOS.  Includes
		source.
		Author:  Bram Moolenaar, et. al.

-------------
New/util/libs
-------------

ReqTools	A standard Amiga shared runtime library which makes it a lot
		quicker and easier to build standard requesters into your
		programs.  Designed with CBM's style guidelines in mind, so
		that the resulting requesters have the look and feel of
		AmigaDOS 2.0.  Version 2.2, an update to version 2.1a on
		disk 794.  Includes a demo and glue/demo sources.
		Author:  Nico Francois

-------------
New/util/misc
-------------

AudioScope	AudioScope is a real-time audio spectrum analyzer for the
		Amiga which uses a 512 point Fast Fourier Transform (FFT)
		to process audio data received through your audio digitizer.
		AudioScope provides a high resolution display of audio
		signal amplitude vs frequency and can be used to evaluate
		the frequency content of sounds of all kinds.  This is
		version 3.0, an update to the original version on disk 543.
		Now, in addition to the real-time display of signal ampli-
		tude vs. frequency, a display option providing a continuous
		scrolling color display of audio signal amplitude vs. time
		vs. frequency is available.  AudioScope 3.0 requires Amiga-
		DOS 2.0 or higher and an accelerated Amiga because of the
		high computational load.  A 68020 or better microprocessor
		is mandatory.  AGA display is recommended.  An audio digi-
		tizer is also required.  Perfect Sound 3, Sound Magic,
		Sound Master, DSS 8 and many generic digitizers are support-
		ed.  Binary only.
		Author:  Richard Horne

BioRhythm	An intuition based easy-to-use program that shows your 3
		basic BioRhythms plus the average-"rhythm".  Take a look,
		dump it to your printer and make your plans for "when to
		do what".  This is version 3.0, an update to v.2.2 on
		disk 862.  Binary only, PAL version.  Source available
		from author on request.
		Author:  Thomas Arnfeldt

Flush		Flushes unused libraries, devices and fonts from RAM. 
		Options include flush all, flush one type, report but don't
		flush, report which got flushed, and amount of memory
		regained.  Runs from CLI, under AmigaDOS 2.04+.  This is
		version 1.2 and is freeware.  Includes source in C.
		Author:  Gary Duncan

Kalender	A little program which should help you to remember dates.
		Requires AmigaDOS 2.0.  This is version 2.1, includes
		source.
		Author:  Kai Hofmann

VCLI		This is Version 7.04 of Voice Command Line Interface
		(VCLI).  VCLI will execute CLI commands, ARexx commands,
		or ARexx scripts by voice command.  VCLI allows you to
		launch multiple applications or control any program with
		an ARexx capability entirely by spoken voice command.
		VCLI is multitasking and will run in the background,
		listening for your voice command even while other pro-
		grams may be running.  VCLI also has its own ARexx port
		so that internal functions and options can be controlled
		by ARexx command.  This new version fixes a few bugs,
		plugs a memory leak, improves gadget functions by pro-
		viding keyboard alternatives, and increases the sensi-
		tivity of the voice.library recognition functions so
		that you don't always have to speak so loudly.  Documen-
		tation is provided for both AmigaGuide and Multiview.
		This is the fastest and most accurate version of VCLI
		yet, and it fully supports DSS 8, Perfect Sound 3, Sound
		Magic (Sound Master) and many generic audio digitizers.
		This is an update to VCLI version 7.0 on disk 898. Binary
		only.
		Author:  Richard Horne

-------------
New/util/pack
-------------

PackIt		A CLI only PowerPacker data file cruncher/decruncher.
		Will automatically determine if a file is PowerPacked or
		not and then either unpack or pack it.  Allows use of
		wild card to pack/unpack whole directories.  This is
		version 37.110, binary only.
		Author:  Michael Barsoom

--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.
