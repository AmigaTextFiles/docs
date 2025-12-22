From megalith!overlord@uunet.UU.NET Fri Jan  7 11:35:01 1994
Received: from relay2.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.4)
	id AA05196; Fri, 7 Jan 94 11:34:38 PST
Received: from spool.uu.net (via LOCALHOST) by relay2.UU.NET with SMTP 
	(5.61/UUNET-internet-primary) id AA00767; Fri, 7 Jan 94 14:34:20 -0500
Received: from megalith.UUCP by uucp5.uu.net with UUCP/RMAIL
	(queueing-rmail) id 143253.28635; Fri, 7 Jan 1994 14:32:53 EST
Received: by megalith.miami.fl.us (V1.16.20/w5, Dec 29 1993, 21:22:55)
	  id <04p4@megalith.miami.fl.us>; Fri, 7 Jan 94 12:48:41 EST -0500
Date: Fri, 7 Jan 94 12:48:41 EST -0500
Message-Id: <9401071247.04p3@megalith.miami.fl.us>
Sender: errors@megalith.miami.fl.us
Errors-To: errors@megalith.miami.fl.us
Warnings-To: warnings@megalith.miami.fl.us
Return-Path: errors@megalith.miami.fl.us
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Reply-To: fnf@cygnus.com (Fred Fish)
Message-Number: 655
Newsgroups: comp.sys.amiga.announce
Message-Id: <overlord.04oj@megalith.miami.fl.us>
From: fnf@cygnus.com (Fred Fish) (CSAA)
To: announce@megalith.miami.fl.us
Subject: Contents of Dec FreshFish CD-ROM
Status: RO

The December Fresh Fish CD-ROM is done.  The tape was sent off to the
CD-ROM pressing plant on 12/24/93, however they are shutdown for 10
days over the holidays, so production is not expected to occur until
about 1/3/94.

There was no November CD-ROM because I had to deal with producing the
replacement October CD-ROM's, and I was out of town for almost 3 weeks
total between Nov 2 and Dec 14.  It is expected that the next Fresh
Fish CD-ROM will be available about the middle of February.

Here are the "README-FIRST" and "Contents" files from the December
CD-ROM, followed by an order form.

-Fred

===========================================================================

		   IMPORTANT INFORMATION FOR THIS CD-ROM
			    (Updated 12-24-93)

This file contains important information that applies to this particular
CD-ROM.  For general information about the Amiga Library CD-ROM's, infor-
mation about the contents of this particular CD-ROM, and other important
information, read the various files in the "Information" directory.  The
files "Changes" and "Feedback" may be of particular interest.  Also be sure
to read the LEGAL-NOTICE, COPYRIGHT, WARRANTY, and SHAREWARE if you have
not done so before.

This is the second CD-ROM in my "Fresh Fish" series, which is intended to
eventually be a monthly production.  A combination of factors conspired to
keep this CD-ROM from being produced in mid December, including dealing
with the virus on the first CD-ROM and being out of town for almost 3 weeks
total between early November and mid December.  Then the unexpected (on my
part) shutdown of the CD-ROM pressing plant that I normally use, from
12/23/93 to 1/2/94 torpedoed plans to get the CD-ROM out before the end of
December.  It's still called the December CD-ROM though, because it was
basically created and ready to go in December, it just couldn't be pressed
until after the holidays.

Progress is being made on a system to make browsing the contents of the
CD-ROM much easier, and for finding specific things on each CD-ROM and
across a series of CD-ROM's.  I hoping to have all the pieces in place in
time to include it on the next CD-ROM.  Users have also asked for an easy
way to make floppy disk copies from the contents of the floppy disks
included on the CD-ROM, and I am pursuing several different possibilities
for filling this need.

This CD-ROM contains approximately 107Mb of new material, 215Mb of useful
tools including gcc 2.5.7, emacs 18.59, PasTeX, etc, and 278Mb of older
material (such as floppy distributions).  All of the source to the supplied
GNU binaries is provided and I have personally built all the supplied
binaries from the supplied source (except GNU emacs) to verify that the
binaries are in fact recreatable from the supplied source code.  For more
information about the contents of the CD-ROM see the files in the
"Information" directory.


INSTALLATION

This CD-ROM contains lots of utilities that are ready to run directly off
the CD-ROM.  This will be slower than running off a hard drive, but CD-ROM
drives are improving constantly, so if you have one of the newer double,
triple, or quad speed drives, this should not be too painful.  You may be
able to save as much as a 200Mb of disk space by running directly off the
CD-ROM.

For this CD-ROM all of the setup necessary to run most things off the
CD-ROM is for you to run the script FreshFish-Dec93:Useful/s/FFCD-Startup
from your S:User-Startup file, like this:

	if exists FreshFish-Dec93:Useful/s/FFCD-Startup
	    echo "Running FreshFish-Dec93:Useful/s/FFCD-Startup..."
	    execute FreshFish-Dec93:Useful/s/FFCD-Startup
	endif

This should be added to your S:User-Startup before the LoadWB command, so
that the WorkBench will know about the directories added to the command
search path.  Once you have added this to your S:User-Startup, you will
need to reboot for it to take effect.

If you want a more customized environment, you can look at what the
FFCD-Startup script is doing and use appropriate bits and pieces in your
own S:User-Startup or S:FFCD-Startup.  Future disks may have a more
sophisticated method of customizing the environment to allow things to run
off the CD-ROM.

			   *** IMPORTANT ***

	Some of the GNU utilities, gcc in particular, require a
	very large stack.  You need to arrange that the CLI/Shell
	or whatever you run these programs from has a large stack
	set.  In a CLI you can set this with a command of the
	form "stack 100000" (100000 is what I use).  You can also
	put this command in your S:Shell-Startup file to get large
	stacks for all CLI/Shell startups, without having to 
	remember to manually set the stack each time.  Really huge
	compiles, like recompiling the compiler itself, may require
	even more stack space (like 300Kb or more).

			

GNU UTILITIES

    *	This CD-ROM contains ports of various GNU utilities that are in
	various stages of stability.  See Useful/dist/gnu/README for
	further information.

    *	I am very picky about adhering completely to the conditions of the
	GNU Public License, so all of the GNU code that goes on one of the
	CD-ROM's has to be build and tested the first time it is included
	and each time it is updated.  Expect this portion of the CD-ROM to
	continually grow with each CD-ROM release, as more ports of GNU
	code are added.

SAS C INCOMPATIBILITY

    *	The assign of lib: used by this CD-ROM conflicts with Lattice/SAS
	C, which wants to use the same assign.  I don't have a recommended
	way of dealing with this conflict yet.  I have some ideas though,
	and hopefully this won't be an issue for future CD-ROMs.

    *	The simplest solution for now may be to patch your SAS C
	executables to look for SLB: instead of LIB:.  However this
	will cause problems with Makefiles and other such files that
	reference LIB:.


USER FEEDBACK NEEDED

    *	I am always interested in hearing about things that might make
	this CD-ROM more useful for users.  It is particularly important
	at this stage that I get feedback from users about problems that
	need fixing, or suggestions on how to make the CD-ROM more useful.

    *	You can FAX your comments to me at (602) 917-0917, however
	please understand that I may not be able to respond to, or even
	acknowledge receipt of, every problem report and suggestion that
	arrives.


CHANGES SINCE LAST FRESH FISH CD-ROM

    *	See the file Information/Changes for a summary of changes since
	the last Fresh Fish CD-ROM.

-Fred Fish  ><>

===========================================================================

				CONTENTS OF
		      December 1993 Fresh Fish CDROM

This file contains some overview information about the contents of the
CD-ROM, followed by a concatenation of a bunch of individual Contents files
on the CD-ROM.  Note that not all the material on the CD-ROM appears in a
Contents file somewhere, so the list of programs found in this file is only
a subset of what is actually on the CD-ROM.  As an example, none of the
180Mb or so of material under useful/dist appears here.  I'm still working
on a better method for finding specific programs or types of programs.


STRUCTURE OF THE CD-ROM
-----------------------

The CD-ROM is divided into roughly three sections: (1) New material,
which includes the material from the new unreleased floppy disks as
well as material which does not appear in the floppy distribution, (2)
useful utilities that can be used directly off the CD-ROM if desired,
thus freeing up the corresponding amount of hard disk space, and (3)
older material from previous released floppy disks or CD-ROM's.

The portion of the disk dedicated to new material that I've not
previously published on a CD-ROM or floppy disk is 107Mb, broken down
as follows:

	11Mb	Archived (BBS ready) contents of disks 931-950
	17Mb	Unarchived (ready-to-run) contents of disks 931-950

	22Mb	Archived "new material" not in floppy distribution
	57Mb	Unarchived "new material" not in floppy distribution

The portion of the disk dedicated to a bunch of useful tools like GNU
utilities, TeX with lots of fonts, and other interesting software that will
be updated for each Fresh Fish CD-ROM, is 215Mb, broken down as follows:

	  2Mb	Content lists of floppy disks 1-950.
	  4Mb	Reviews of Amiga software and hardware
          4Mb	Full BSD source for supplied BSD executables.
	  4Mb	CBM header files, libraries, and developer tools.
         22Mb	Misc useful tools, libraries, etc.
	 25Mb	Binary executables, libraries, and other "runtime" things.
	 33Mb	PasTeX source, fonts, binaries, etc.
	121Mb	Full GNU source for supplied GNU executables.

The portion of the disk dedicated to old material is 278Mb, broken
down as follows:

	 12Mb	Archived (BBS ready) contents of material from Oct
		Fresh Fish CD-ROM that was not in floppy distribution.
	 28Mb	Unarchived contents of material from Oct Fresh Fish CD-ROM
		that was not included in the floppy distribution.

	130Mb	Archived (BBS ready) contents of floppy disks 650-930.
	108Mb	Unarchived contents of floppy disks 800-930.


GNU CODE
--------

Here are the current GNU distributions which are included in both source
and binary form.  In most cases, they are the very latest distributions
ftp'd directly from the FSF machines and compiled with the version of gcc
included on this CD-ROM.  I have personally compiled all of the GNU
binaries supplied on this CD-ROM, to verify that the compiler is solid and
that the binaries are in fact recreatable from the supplied source code.

bash	    diffutils	gas	    groff	make	    tar
bc	    doschk	gawk	    gzip	patch	    termcap
binutils    emacs	gcc	    indent	perl	    texinfo
bison	    fileutils	gdbm	    ispell	rcs	    textutils
cpio	    find	gmp	    libg++	sed	    uuencode
dc	    flex	grep	    m4		shellutils

Here is an "ls -C" of the binary directory which can be added to your path
to make these utilities, as well as utilities from the Useful/dist/other
directories, usable directly off the CD-ROM, once it is mounted:

AD2HT	       c++	      gawk	     lha	    sed
ARTM	       cat	      gcc	     lkbib	    sh
AZap	       chgrp	      gcc-2.3.3	     ln		    size
AmigaGuide     chksum	      gcc-2.5.7	     locate	    sleep
DiskSalv       chmod	      gccv	     logname	    sort
ExpungeXRef    chown	      gccv-2.3.3     look	    split
IView	       ci	      gccv-2.5.7     ls		    strip
Installer      cksum	      gdir	     m4		    sum
LHArc	       cmp	      genclass	     make	    tac
LHWarp	       co	      geqn	     makeinfo	    tail
Less	       comm	      gindxbib	     merge	    tapemon
LoadXRef       cp	      ginfo	     mg		    tar
MKProto	       cpio	      ginstall	     mkdir	    tee
MuchMore       csplit	      glookbib	     mkfifo	    test
MuchMore.info  cut	      gneqn	     mknod	    testdbm
NewZAP	       date	      gnroff	     mv		    testgdbm
PerfMeter      dc	      gperf	     nice	    testndbm
RSys	       dd	      gpic	     nl		    texi2dvi
SD	       df	      grefer	     nm		    texindex
SnoopDos       diff	      grep	     nroff	    tfmtodit
SuperDuper     diff3	      grodvi	     od		    touch
SysInfo	       dirname	      groff	     paste	    tr
Viewtek	       doschk	      grog	     patch	    true
WDisplay       du	      grops	     pathchk	    unexpand
XIcon	       echo	      grotty	     pfbtops	    uniq
Xoper	       egrep	      gsoelim	     pr		    unprotoize
[	       emacs	      gtbl	     printenv	    uudecode
addftinfo      env	      gtroff	     printf	    uuencode
afmtodit       etags	      gunzip	     protoize	    vdir
ar	       expand	      gzip	     psbb	    vt
as	       expr	      head	     ranlib	    wc
awk	       false	      id	     rcs	    who
basename       fgrep	      ident	     rcsdiff	    whoami
bc	       find	      indent	     rcsmerge	    xargs
bison	       flex	      ispell	     rlog	    yes
brik	       flushlibs      join	     rm		    zcat
bsd-make       fold	      ksh	     rmdir	    zoo
bsplit	       g++	      ld	     sdiff

Contents of Floppy Disks 650-930
--------------------------------

Because there is only one previous Fresh Fish CD-ROM from which to rep-
licate material from previous months, I've elected to use the contents of
floppy disks 650-930 to fill that portion of the CD-ROM.  Some of these
are only available in the archived (BBS ready) form.

Contents of new/AmigaLibDisks/Disk931
-------------------------------------

Comgraph	A powerful function plotter.  You can administer up to ten
		functions at the same time, plot functions and their deriva-
		tives, zoom these and calculate symbolic derivatives, zero
		points, extreme points, turning points and saddle points,
		poles and gaps.  Furthermore, you can calculate integrals
		(integral, area, curve length, rotation volume, rotation
		surface).  Contains a simple scientific calculator, linear
		equation solver, prime factor reduction, and prime number
		calculator.  High print quality.  English and German version
		coexistant in one program.  Binary only, shareware.
		Author:  Andre Wiethoff

DynamiteWar	A tiny game for 2-5 players who fight against each other.
		It is similar to the commercial Dynablaster or Bomberman,
		except a 1-player mode is not available.  On the other hand,
		there are a great number of extras.  To win the game, one
		player has to disintegrate all other players by exploding
		bombs.  Binary only, shareware.
		Author:  Andre Wiethoff

Modules		Command extensions for the M2Amiga V4.xx Modula-II Compiler
		of A+L AG.  In about 13 Modules are over 410 importable
		objects with 311 commands and functions, for programming
		devices, graphics and intuition.  The are four Modules alone
		covering graphics (GraphicsSupport, Copper, Fonts,
		Simple3D), with a total of 140 commands.  Most modules
		contain one or two demo programs showing sample usage.
		Author:  Andre Wiethoff

Contents of new/AmigaLibDisks/Disk932
-------------------------------------

DynamicSkies	A big toolbox for astronomy that has, for an ultimate goal,
		to answer with speed any question that may arise on celes-
		tial objects.  For example, suppose you have an urge to
		observe Jupiter tonight from your window; You may consult
		rise/set times of Jupiter, ask when it crosses south-west
		(supposing your window faces south-west), and with just a
		mouse click have a glance at the simulated sky at this
		time.  You may even animate Jupiter's path across the sky
		with a time-step animation.  Of course, if you're a real
		star gazer, don't forget your binoculars or telescope for
		the real thing!  Version 1.0, binary only.
		Author:  Patrick DeBaumarche

Fleuch		A little game with more than five extra large stages.  The
		object is to pickup up your cargo and climb safely to the 
		next stage, without being shot or running into anything, 
		(including your cargo!).  Scrolling, shooting, some gravi-
		tation, similar to Thrust (C64).  Version 2.0, and update
		to version 1.0 on disk number 760.  Binary only.
		Author:  Karsten Gvtze, title music by Andreas Spreen

StackMon	A program to monitor the stack use of other programs or
		tasks.  Has a convenient GadTools front end.  Requires
		AmigaDOS 2.04 or higher.  Version 1.0, includes source
		in E.
		Author:  David Kinder

Contents of new/AmigaLibDisks/Disk933
-------------------------------------

ConvertHAM	A utility to convert HAM picture files to ordinary ILBM
		files, with 2 to 256 colours (2 to 32 on non-AGA machines).
		Version 1.2, binary only.
		Author:  David Kinder

EditKeys	A keymap editor.  Supports editing of string, dead and modi-
		fiable keys, as well as control of repeatable and capsable
		status of each key.  New test mode, plus LoadKeymap support
		utility.  Version 1.4, an update to version 1.3 on disk 817.
		Binary only.
		Author:  David Kinder

GuiArc		A graphical user interface for cli-based archivers like lha,
		arc, ape, zoo, etc.  It has the 'look & feel' of a directory
		tool and can perform all basic actions on archives, such as
		Add, Extract, List, Test, Delete, etc.  You can enter arch-
		ives as if they were directories.  You don't have to know
		anything about archivers.  Fully configurable.  Archivers
		not included, requires AmigaDOS 2.0+.  Version 1.22, an
		update to v1.10 on disk number 863.  Binary only, freeware.
		Author:  Patrick van Beem.

PhxAss		PhxAss is a complete macro assembler, which supports the
		instruction-set and addressing modes of all important Moto-
		rola processors (MC68000, 68010, 68020, 68030, 68040, 6888x
		and 68851).  It understands all common assembler-directives
		(Seka, Devpac, Metacomco, etc.) and can generate linkable
		Amiga-DOS object files or absolute code.  In both cases the
		user has the opportunity to choose between the large and
		small code/data	model.  PhxAss is written entirely in
		assembly language and works with Kickstart 1.2/1.3, OS2.x
		and OS3.x.  Version V3.60, an update to version V3.30 on
		disk number 905.  Binary only, with documentation in
		English.
		Author:  Frank Wille

PhxLnk		Linker for Amiga-DOS object files, which also supports the
		small-code/data model.  Version V2.03, an update to version
		V1.35 on disk number 853.  Binary only, with documentation
		in English.
		Author:  Frank Wille

ShellMenus 	A program to help Shell users be more prolific and save
		time.  Shell Menus creates user definable menus that attach
		to the Shell window.  Offers an intuition interface to edit
		your menus instead of a text editor and many other features
		not found in other programs that use menus.  Requires OS
		2.04+, version 2.7, binary only.
		Author:  Mark Ritter

Contents of new/AmigaLibDisks/Disk934
-------------------------------------

ABackup 	A very powerful backup utility.  Has a full Intuition inter-
		face, a "batch" mode, can save/load file selection, handle
		HD floppies, use any external compression program, etc...
		This new version adapts itself to the default font and
		screen mode, and may be up to 40% faster than previous ver-
		sions.  Includes French, German, and English versions.
		Version 4.03, an update to v2.43 on disk 871.  Shareware,
		binary only.
		Author:  Denis Gounelle.

AZap		A "new generation" binary editor, able to edit files, memory
		or devices like floppy or hard disks.  It can open several
		windows at the same time, is localized, and handles all OS
		3.0 file systems.  Includes both French and English docu-
		mentation.  Version 2.11, an update to version 2.04 on disk
		number 875.  Binary only.
		Author:  Denis Gounelle

PublicManager	Public screen tool which opens public screens that are
		freely configurable (depth, size, font, ...) and have their
		own menu (palette, quit, tools,...) Requires Kickstart 2.04
		or later.  Version 1.4, an update to version 1.2 on disk
		685.  Binary only.
		Author:  Michael Watzl

ToolType	A program to make it easier to edit tooltypes in icons.
		ToolType will read the tooltypes from an icon file and let
		you use your favorite text editor to change or add to the
		tooltypes.  Includes an option to sort the tooltypes alpha-
		betically.  Version 37.206, requires OS2.0+, binary only.
		Author:  Michael J Barsoom

Contents of new/AmigaLibDisks/Disk935
-------------------------------------

AmiCDROM	A CDROM disk filing system for the Amiga.  It supports the
		ISO-9660 standard and the Rock Ridge Interchange Protocol.
		The CDROM drive is mounted as a DOS device (e.g. CD0:).  You
		can access files and directories on a CDROM disk by the
		usual syntax, e.g. "type cd0:foo/readme.txt".  Version 1.7,
		includes source.
		Author:  Frank Munkert

Badger		An icon management utility.  When you throw files on
		Badger's appicon they get a new icon depending on which
		pattern in Badger's list they match.  Version 1.1.
		Author:  Erik Sagalara.

ClipWindow	A program that makes it easy to put frequently used text on
		the clipboard.  It opens an AppWindow on the Workbench which
		accepts Project icons and associated text files.  The text
		is copied to the clipboard ready for pasting.  Text may be
		in a separate disk file or directly entered as Tool Types
		in the Project icon.  Also included is ConPaste, a Commod-
		ity by Carolyn Scheppner which allows pasting clipboarded
		text almost anywhere.  AmigaDOS 2.0 or higher required.
		Version 1.0, includes source
		Author:  Jim Harvey

LazyBench	A little utility for lazy people with a hard disk crammed
		full of goodies which are too difficult to reach because
		they are buried away in drawers inside drawers inside
		drawers inside drawers...  LazyBench installs itself as a
		commodity, adds an item under the Workbench "Tools" menu
		and waits in the background.  Use its hot key combination
		to pop up its window and then select an item.  Now OS 2.xx
		only and fully "User Interface Style Guide" compliant.
		Font sensitive (uses the Default Screen Font) and each
		gadget has a single key equivalent.  Version 1.12, an
		update to version 1.10 on disk number 894.  Binary only.
		Author:  Werther 'Mircko' Pirani

MuchMore	Another program like "more", "less", "pg", etc.  This one
		uses its own screen to show the text using a slow scroll.
		Includes built-in help, commands to search for text, and
		commands to print the text.  Supports 4 color text in bold,
		italic, underlined, or inverse fonts.  Can load xpk crunch-
		ed files, has a display mode requester and is localized
		(german catalog included).  Version 3.6, an update to ver-
		sion 3.3 on disk number 895.  Includes source in Oberon-2.
		Author:  Fridtjof Siebert, Christian Stiens

VirusChecker	A virus checker that can check memory, disk bootblocks, and
		all disk files for signs of most known viruses.  Can remem-
		ber nonstandard bootblocks that you indicate are OK and not
		bother you about them again.  Includes an ARexx port, sup-
		ports SHI's Bootblock.library.  By using this library and
		its brainfile you have the ability to add new Bootblock
		viruses as SHI release new brainfiles.  Version 6.33, an
		update to version 6.30 on disk 913.  Binary only.
		Author:  John Veldthuis

Contents of new/AmigaLibDisks/Disk936
-------------------------------------

BaseConvert	GUI program to convert a number from one base to another.
		Shows conversions between Decimal/Hex/Octal/Binary all
		simultaneously.  Requires Kickstart 2.0 or higher.  Version
		1.1, binary only.
		Author:  Johan Vande Ginste.

Spooler		Prints textfiles in the background.  Copying a file to the
		SPOOL: directory is all that is required.  The program shows
		you a list of files to be printed and gives you a report on
		the file currently being printed.  Requires Kickstart 2.0
		or higher.  Version 2.3, binary only.
		Author:  Johan Vande Ginste.

TKEd		TKEd is a very comfortable Intuition-based ASCII editor with
		an english and german user-interface.  It can read texts
		packed with PowerPacker, has user-definable menus, a com-
		fortable AREXX interface with 116 commands, an interface to
		some errortools for programmers, macros, undo, wordwrap,
		supports foldings, has an online help mode, and many other
		features.  TKEd is reentrant and can be made resident.
		It's Kickstart 1.3/2.04 compatible, supports the new
		ECS-screenmodes, an application window and checks itself
		for linkviruses.  Version 1.17a, an update to version 1.11
		on disk 781.  Evaluation version, with editing limited to
		files 9999 lines and less.  Binary only, shareware.
		Author:  Tom Kroener

Contents of new/AmigaLibDisks/Disk937
-------------------------------------

64Door		A Commodore 64 Terminal emulator program which allows you to
		call Commodore 64 BBS systems in the C64-specific color
		terminal mode commonly referred to as C/G mode.  Written in
		100% 68000 Assembly language.  Version 1.0, binary only,
		public domain.
		Author:  Clay Hellman

Galactoid	A one or two player shoot-em-up game that resembles the old
		arcade classics Galaga and Galaxian.  You must avoid and
		destroy waves of dive-bombing enemies.  Written in 100%
		68000 assembly language using direct hardware access for
		maximum smoothness and playability.  Binary only, shareware.
		Author:  Clay Hellman

KingCON		A console-handler that optionally replaces the standard
		'CON:' and 'RAW:' devices.  It is 100% compatible, but adds
		some VERY useful features, such as: Filename-completion
		(TAB-expansion); A review-buffer; Intuition menus; Jump-
		scroll.  (FAAST output!)  Cursor-positioning using the
		mouse; MC68020-optimized version; And more...  Version 1.0,
		requires OS2.x, binary only.
		Author:  David Larsson

Knit		Converts an IFF picture (8-colors or less) into a knitting
		pattern.  For a specified stitch size, Knit will tell you
		how many stitches per row are needed and how many rows are
		used.  Knit bases all of its calculations on the size of a
		standard monitor screen which means that your finished knit-
		ting should be about the size of your screen.  (Thus, if you
		have a extra large or small monitor, you may need to make
		adjustments.)  Version 1.01, binary only.
		Author:  Don Finlay

Megasquad	A two player game with two modes of gameplay:  Tag and Duel.
		Features many different play boards, has music, sound, and
		is very smooth.  Written in 100% 68000 assembly language
		using direct hardware access.  Binary only, public domain.
		Author:  Clay Hellman

WhereK		A highly configurable hard drive utility.  Features an auto-
		matic disk cataloger with 3 modes, turns directories into
		ascii files that can be saved and searched, allows other
		programs to run while continuing in the background, creates
		lists with versions of the libraries on your hard drive and
		disks.  All files created can be saved.  Features 2 help
		modes, individual help for keys and a comprehensive help
		mode, both accessible from the program.  Runs on WB2.0+
		except for the Library Versions Bulk Lister which requires
		WB3.0 and above.  Version 3.0, binary only, freeware.
		Author:  Kenneth J. McCormick.

Contents of new/AmigaLibDisks/Disk938
-------------------------------------

Angie		ANother Great Intuition Enhancer commodity that offers about
		100 Intuition related actions you may assign to multiple
		arbitrary hotkeys.  Arbitrary DOS commands and input event
		data may be assigned to the hotkeys too.  Furthermore, Angie
		includes automatic window hunting, auto ActiveWinTask pri-
		ority increment, 'TWA' type window remembering, auto Def-
		PubScreen definition, etc.  Angie comes with a comfortable
		Intuition user interface.  This is version 1.6, giftware,
		includes source in Oberon-2.
		Author:  Franz Schwarz

AppISizer	New, localized version of the AppIcon utility that gets the
		size of disks, directories or files.  Gives the size in
		bytes, blocks and the actual size occupied.  Supplied with
		a French catalog.  Includes English documentation in Amiga-
		Guide format and French documentation.  Also offers several
		new enhancements.  Requires KickStart 37.175 or higher.
		Version 0.68, an update to version 0.61 on disk 853.
		Binary only.
		Author:  Girard Cornu.

DPU		Disk Peek and Update, a hex disk and file editor.  Functions
		include show device info, show bitmap, check disk, zap file,
		zap disk, zap filesystem and zap rigid disk blocks.  Version
		1.5, an update to version 1.2 on disk number 721.  Binary
		only, freeware.  Requires Release 2.04 or higher.
		Author:  Frans Zuydwijk

Filters		A GUI-based RC Filter design program.  Allows you to set the
		desired characteristics for either a high or low pass fil-
		ter, calculate the required values, and display/print the
		resultant phase/frequency graphs.  Version 1.2, binary only,
		shareware.  Requires OS2.0+.
		Author:  Wim Van den Broeck

MN3A		An antenna design program used to calculate currents, imped-
		ance, and fields of wire antennas.  The wires may contain
		lumped-constant loads.  Environment may be free space or
		various groundtypes.  Version 1.0, binary only, freeware.
		Author:  Jim Martin.

PicCon		An aid for graphics programmers.  PicCon will use the data-
		types library to load any picture format you've got support
		for, and you will then be able to extract any part of the
		picture and save it in your desired format.  Ordinary bit-
		planes, "blitterlines", chunky pixels and various sprite
		formats are supported.  The raw data can be saved as binary,
		assembly or C source.  Saving of the palette entries in a
		variety of formats is also supported.  Requires OS3.0.
		Version 1.06, binary only, shareware.
		Author:  Morten Eriksen.

TurboLeusch	With the help of "Turbo-Leuschner" you are able to create
		your own  menus for Workbench-based windows or expand
		already existing menus.  Turbo-Leuschner supplies ALL
		functions of the Workbench-Menu-System.  With Turbo-
		Leuschner, you supply the name of the window and the menu
		file to attach to it, thus you can attach menus to the
		"AmigaShell" window, your favorite GUI-based utility, or
		simply the WorkBench Window itself.  Binary only, shareware.
		Author:  Thomas Hvlle

Contents of new/AmigaLibDisks/Disk939
-------------------------------------

AddPower	A utility that adds some miscellaneous useful features to
		the 2.0+ OS.  Includes:  file requesters in any program,
		stop drive clicking, fix menus and pen colors of pre-2.0
		programs, wildcard * = #?, make screen borders black, open
		any window on front screen.  All features are independantly
		configurable.  Workbench and AmigaDOS interfaces with online
		AmigaGuide documentation.  Version 37.6, binary only.
		Author:  Ian J. Einman

AlertHelp	A little tool that helps you to interpret the alertmessages.
		When an alert occurs, the program displays a window with a
		little description of the alert.  This is version 0.55.
		Freeware, includes source.
		Author:  Jan Hagqvist

ARexxSuper	An all-purpose mouse-controlled ARexx communication program.
		All done via a nice GadTools interface, documentation in
		AmigaGuide format, useful for testing and debugging ARexx
		interfaces.  Requires reqtools library V38+ and Kickstart
		2.0+.  Version 1.0, binary only, shareware.
		Author:  Fridiric Delacroix

CloseWB		This program attempts to close the WorkBench screen after
		"n" seconds.  It is useful to put into startup-sequences
		that start an application and no longer need the WorkBench
		screen (such as Imagine).  The closing of the WorkBench
		screen will save some chip RAM.  Will work with any Amiga
		running KickStart 2.0 or higher.  Version 1.0, binary and
		source included.
		Author:  Daniel Bachmann

ExtraCmds	A set of 18 AmigaDOS commands, chiefly inspired by UNIX,
		written to augment the collection distributed as part of
		the System Software Release 2.04 (V37) and will not run
		under older releases.  This is the second  public release
		consisting of the commands Common, Compare, Concat, Copy-
		right, Count, DirTree, Find, Head, Lower, Prepare, SCD,
		Split, Splitname, Tee, Testbits, TimeCom, Unique and Usage.
		Includes an English User's Reference Manual in LaTeX format
		and source code.
		Author:  Torsten Poulin

IanUtils	A collection of some small but useful Assembly language
		tools.  Included are:  Colors, a kickstart 3.0 palette
		editor.  Edit any screen's palette by percents, rather than
		fixed integers; Output, an AppIcon that will call your
		text/picture/sound/etc. viewer.  Customizable for any IFF
		type; SetColor, Allows setting screen colors from the shell,
		useful for scripts; SetDepth, a command to change screen
		depth.  Give your WB1.3 8 colors; EMenu, adds key equiv-
		alents to WB1.2/1.3 menus.  Lays out the menus "prettier."
		Source included for SetColor, SetDepth and EMenu.
		Author:  Ian J. Einman

Upcat		Disk catalog program.  Read file information from disks,
		store it in a catalog in memory, save/load catalogs to/from
		disk, display catalog in several ways, select files to be
		displayed, print (selection of) catalog, 32 user definable
		categories, add comment to records in catalog, ARexx inter-
		face, user definable macro menu.  Version 1.2, an update to
		version 1.0 on disk number 854.  Binary only, freeware.
		Requires Release 2.04 or higher.
		Author:  Frans Zuydwijk

Contents of new/AmigaLibDisks/Disk940
-------------------------------------

AltTab		A small Commodity that successively displays the screens
		titles at the press of 'Alt-Tab' and allows you to choose
		which screen to bring to the front.  Requires Kickstart
		37.175 or higher.  Version 0.2, binary only.
		Author:  Girard Cornu.

BootMan		A boot manager program that allows you to select a startup-
		sequence at boot time using the mouse or keyboard.  Also
		allows password protection and a timer to load a default
		startup if none is selected.  Includes a preference editor
		for easy modification and startup.  Will work with any Amiga
		running KickStart 2.0 or higher.  Version 1.1, binary only.
		Author:  Daniel Bachmann

VideoMaxe	A video database that satisfies all needs of a private video
		user.  With full OS 2.1+ and environmental support (local-
		ization, application icon, installer, font-sensitive runtime
		gadget layout, layout saving, guide documentation, ...) the
		program handles record suggestions, spool informations, free
		amount of additional data per tape or title, comfortable
		search routines, printing, etc.  Requires OS 2.1.  Version
		04.20, update to version 03.22 on disk number 637.  Binary
		only, Shareware.
		Author:  Stephan Suerken

Contents of new/AmigaLibDisks/Disk941
-------------------------------------

CardZ		Patience card games.  Includes two version of Klondike, The
		Wall and Up/Down.  Version 1.0, binary only, freeware.
		Requires Release 2.04 and needs a 640x256 PAL HighRes
		screen.
		Author:  Frans Zuydwijk

FlipPrefs	With this program, you can  create several preferences
		files, (The "DEVS:system-configuration" type) of different
		names and switch between them on command.  A sample usage
		would be to customize the startup script to set different
		preferences depending on the operating system booted into.
		Could also be useful in different development environments
		or for machines with multiple users.  Version 1.0, binary
		only, freeware,
		Author:  Thorsten Stocksmeier

Guide2Doc	Converts AmigaGuide. file to a normal document without any
		"@{xxx}"'s, but full ANSI-support!  CLI-ONLY, optional
		table-of-contents-generation and page-numbering.  Output
		goes to StandardOut, so you may redirect it, eg. ">prt:",
		or read the guide in CLI.  V1.0, freeWare, includes C
		source.
		Author:  Bernd (Koessi) Koesling

Mine		A Modula-2 implementation of an old computer game.  You
		have an N * N square with mines hidden in some fields.
		Your job is to mark them with a flag as fast as possible.
		Version 2.0, an update to version 1.8 on disk number 835.
		Contains some bug fixes and improvements.  Most important:
		now always uses the default public screen and does not open
		it's own  multitasking and-chipmem-goodbye-screen.  Re-
		quires AmigaDOS 2.0, Source in M2Amiga Modula-2 and
		(newest) 68020 version are available from the author.
		Author:  Thomas Ansorge

SOUNDEffect	Sound sample editing program.  Special features include:
		temporary buffers, frequency and amplitude modulation
		(tremolo and vibrato), echo, special reverb effect, chorus
		effect, mixer, free hand editing, low and high pass filter,
		compresser, expander, limiter, distortion and all the usual
		functions (copy, paste, insert, cut, looping, zooming etc.).
		All effects are available in stereo.  This is no update
		to V1.32!, the program has been completely re-written and
		has a new user interface.  Runs with OS1.3 or above.
		Version 2.10, binary only, shareware.
		Author:  Sven B|hling

YAMFG		Yet Another Mine Field Game.  This is a big classic.  Your
		tank must move through the variable-width and height mine
		field to a target.  Mainly designed to help beginners cope
		with assembly.  Uses reqtools.library ) Nico Frangois.
		Version 1.0, includes heavily commented source.
		Author:  Fridiric Delacroix

Contents of new/AmigaLibDisks/Disk942
-------------------------------------

ACalc		A small calculator with floating point, hexadecimal and
		decimal modes.  Has 10 memories, saves the last result in
		the clipboard, may be used with the mouse or keyboard.
		With OS 2.x and 3.0, may be installed as a Commodity.
		Includes both French and English versions.  Binary only.
		Author:  Denis Gounelle

AS65		A comfortable and efficient 2 pass cross assembler for the
		Whole 6502 processor family.  Version 2.3d, contains docu-
		mentation in both english and german.  Binary only.
		Author:  Thomas Lehmann

LibraryGuide    An AmigaGuide file that lists about 170 different "librar-
		ies" often found in the LIBS: directory and a simple one or
		two line description of their purpose along with version
		info and where to get them, etc.  May help you determine
		whether or not you actually "need" some of these space-
		consuming things.  Version 1.0.
		Author:  Dan Elgaard

WBMenu		A simple CLI-only tool that allows you to add new menu-
		entries to the "Tools" menu of the Workbench.  Useful for
		scripts and batch files, simple to use.  Requires OS2.04+.
		Version 3.4, includes source in assembler for both English
		and german versions.  Shareware.
		Author:  Thorsten Stocksmeier

Contents of new/AmigaLibDisks/Disk943
-------------------------------------

Clock		A simple Clock program but with the handy feature that you
		can "snapshot" the clock to stay with any screen or it can
		be free to pop to the frontmost screen automatically.  Up
		to 4 alarm times can be set, which can simply put up a re-
		quester or cause some program to run in background.  Hourly
		chimes can also be made to run a program (I.E. a sound sam-
		ple player).  Uses locale.library with OS2.1+.  Version
		2.20, an update to version 2.00 on disk number 869.  Binary
		only.
		Author:  Bernd Grunwald

IRMaster	A package for the substitution of remote controls by the
		Amiga.  You can learn and send nearly any infra red command.
		That means you can control e.g. your tv set from the work-
		bench.  With an editor you can create remote controls and
		with a runner you can use them on your wb.  Version 1.0,
		binary only.
		Author:  J|rgen Frank & Michael Watzl

JIStoJi		A program to read and print Japanese electronic text.
		JIStoJi automatically identifies electronic texts written
		in Old-JIS, New-JIS, Shift-JIS, or EUC-JIS (as well as, of
		course, ASCII) and displays them on screen, or prints them
		to dot-matix printers.  Version 1.5, binary only.
		Author:  Gerald B. Mathias

MCMaster	Another music cassette cover printing utility which should
		work together with any printer that supports pica and fine.
		Other features are a search function and a list function
		which allow you to put, for example, all the song names in
		a list gadget to scroll around.  Requires Kickstart >2.04!
		Version 1.2, an update to version 1.1 on disk 685.  Binary
		only.
		Author:  Michael Watzl

Mkfont		Converts standard Amiga fonts into softfonts for the Hewlett
		Packard II (compatible) laser printers.  It is entirely
		written in assembly and is quite fast.  It can double the
		softfonts in size and smooth's them automatically.  Version
		1.0, binary only, freeware,  Runs from CLI only.
		Author:  Tonio Voerman

WBflash		A small program that nicely flashes (or color-cycles) the
		active window or Workbench background.  With some simple
		gadget clicks you can generate and save your own custom
		flash-patterns.  Written in assembler.  Includes both
		English and Swedish versions.  Requires OS2.0+.  Version
		1.12, binary only.
		Author:  Thomas Pettersson

Contents of new/AmigaLibDisks/Disk944
-------------------------------------

AngusTitler	A program to create videotitles for (e.g.) your holiday
		films.  It is possible to scroll 350 lines up the screen.
		Of course, the colors, fonts, fontstyles, border etc. can
		be changed.  It is also possible to load a background
		picture.  This is only a demo-version that is limited to 10
		lines, all other options are enabled, even saving and
		loading.  The full version can be obtained from the author
		for $35 US or 45 DM.  Version 4.0, binary only.
		Author:  Andreas Gun_er.

ARegress	A program for stistical evaluation of measurements.  You can
		use it to estimate different kinds of regression, and to
		print graphs of the regressions.  Version 2.0, binary only,
		freeware.
		Author:  Sven B|hling

BlockEd		Disk block editor, simple but very easy to use.  Compatible
		with 1.3 and up. Version 1.4, initial release.  Contains
		most source (in C) for light reading.
		Author:  Andrew Kemmis

Lhf		A dir-utility and archiver with CLI and intuition interface.
		Enables you to copy, move, delete or rename archive files as
		if they were ordinary files.  Extraction and compression is
		automatically performed as needed.  With the configuration
		program 'LhfEd' you can customize it to perform external
		commands.  Version 1.03, binary only, freeware.
		Author:  Stefan Pampin

Parcheese	Like the classic board game.  The aim of the game is to get
		all of your markers safely around the board to your home
		base.  Three levels of play, players selectable between
		human/computer.  Includes documentation in english and
		spanish.  Version 1.7g, binary only.
		Author:  Xavier Egusquiza

PhoneDir	Personal Phonedirectory (PPD) was designed to remember
		addresses and phone numbers for you, and also dial the
		numbers automaticly.  PPD was designed especially with
		multitasking in mind. When you are doing something else,
		its window can be minimized, and when you need to, you
		can call someone just by a click on the mouse. PPD uses
		almost no system power when not used.  Version 1.0,
		binary only.
		Author:  Hallvard Korsgaard

Contents of new/AmigaLibDisks/Disk945
-------------------------------------

EmacsStarter	A good Emacs starter.  With it you can load files into a
		running Emacs.  Has an option to use a public screen
		(requires "ScreenManager"), full WB support, double-click
		icons into a running Emacs, new icon creating scheme, use
		different icons depending on what type of file you are
		editing, sticky flag, the script doesn't terminate until
		the requested buffers are terminated.  Release 1, includes
		ARexx and C source.
		Author:  Anders Lindgren, Bo Liljegren

IFFConvert	A program to convert the different compression methods of
		IFF ILBM files.  It supports the normal compression, a new
		compression method that compresses column by column instead
		of row by row, and uncompressed files.  Version 1.12, an
		update to version 1.11 on disk number 699, includes source.
		Author: Matthias Meixner

MineRunner	A freeware game like Lode Runner, but with more features.
		Supports the 4 player adapter for the parallel port, uses
		soft stereo where possible, doesn't stop multitasking and
		saves highscores to disk.  Version 1.0, binary only.
		Author:  Matthias Bock

Orm		An improved version of PD "Snake" game on disk number 810 by
		Michael Warner.  You control an "orm" (Danish for worm or
		snake), living in a small window on the default public
		screen, which grows by eating "frogs" and avoiding obsta-
		cles.  This version tries to be smart about its window
		borders and the screen mode (Interlace, Superhires, etc.).
		Supports locale library if present.  English, German,
		Italian, and Swedish catalogs are supplied.  Default lang-
		uage is Danish.  Includes the catalog description file and
		full DICE and SAS/C (Lattice) compatible source.  Version
		1.4,  Public Domain.  Requires AmigaDOS 2.04 or higher.
		Author:  Torsten Poulin

PrtSc		Have you ever noticed that there is a PrtSc-key on the nu-
		meric keypad?  This program makes it work!  By pressing the
		PrtSc key on your keypad, you get a screen dump to your
		printer.  Version 1.52, an update to version 1.08 on disk
		number 897.  Freeware, includes source.
		Author:  Jan Hagqvist

Reminder	A utility to remind you about events.  It consists of an
		event editor and a small program that is put in your
		WBStartup (or run from S:user-startup).  Every time you
		boot your machine, this program checks the event database
		and puts up a requester (and optionally calls an ARexx
		script) if there are events that you need to be reminded
		about.  Version 1.20, freeware, C source included for DICE
		and SAS6.x.
		Author:  Matti Rintala

Contents of new/AmigaLibDisks/Disk946
-------------------------------------

AmiQWK		QWKMail format offline message system.  Allows reading of
		QWKMail format offline message packets popular with many
		bulletin board systems (BBSes).  Replies can be edited using
		any text editor and packed for transfer at a later time.
		AmiQWK has been tested with many QWKMail systems for IBM and
		Amiga based BBSes.  Requires Workbench 2.04 or higher. 
		Release 2 version 2.2, an update to Release 2 version 1.0
		on disk number 907. Binary only, shareware.
		Author:  Jim Dawson

DMon		DMon is a multi-purpouse utility written for the author's
		personal use during program development.  It is a Monitor,
		Dissassembler, Debugger and development system.  You may
		find similarities to Amiga Monitor by Timo Rossi, but DMon
		is different, it can dissassemble and debug 68xxx software
		in User and Supervisor Mode.  If you do not know what that
		means, then do not use DMon!  Version 1.86, binary only.
		Author:  Andreas Smigielski

fd2pragma	A small utility to create prototypes for the Aztec C com-
		piler or the Aztec Assembler from FD files as they are
		distributed from Commodore with the Include files.  Inclu-
		des C-source.
		Author:  Jochen Wiedmann

PriMan 		A configurable, Style Guide compliant task priority manager.
		Along the same lines as TaskX, PriMan is font-sensitive,
		resizeable,  uses a slider gadget to change the priority of
		any task, and has buttons for sending a Ctrl-C signal to a
		task, or removing it from memory.  Version 1.1, an update to
		version 1.0 on disk number 928.  FreeWare, includes C
		source.
		Author:  Barry McConnell

TrashIcon	A WorkBench 2.x application icon to delete files.  Puts an
		icon at a user defined position on the WorkBench screen,
		then deletes all files that are dragged onto it.  Version
		2.3, an update to version 1.4 on disk number 871.  Binary
		only.
		Author:  Mark McPherson

Yass		Yet Another Screen Selector, a commodity with several nice
		features such as: Completely controllable via keyboard (of
		course you can use your mouse, if you really want to);
		Shows Screens and Windows (option); Shows PublicScreenname
		or ScreenTitle (option); Ability to change the default
		Public screen; Opens window even on non-public screens
		(option).  Font-sensitive; Resizeable window.  Version 1.1,
		binary only.
		Author:  Albert Schweizer

Contents of new/AmigaLibDisks/Disk947
-------------------------------------

Mand2000D	Demo version of a revolutionary fractal program that makes
		it far easier to explore the Mandelbrot set.  Mand2000 is
		compatible with all Amigas.  It has separate calc routines
		that have been optimized for the 68000, 68020, 68030, 68040
		and 68881 processors respectively.  It automatically detects
		these to ensure maximum performance.  Mand2000 also makes
		full use of AGA graphics when available.  A number of
		enhancements since the original demo version.  Version
		1.102, binary only.  Requires OS 2.04.
		Author:  Cygnus Software

NewTool		A program that will quickly replace the default tool in
		project icons.  You can specify the tool to use, use a file
		requester to pick the tool, or allow NewTool to automatic-
		ally choose the proper tool depending on the file type.
		Version 37.195.  WB 2.0+ required.  Binary only.
		Author:  Michael J Barsoom.

ScreenSelect	A commodity to change screen order by selecting a screen
		name from a listview.  Also allows binding of hotkeys to
		any screen with a proper name.  Supports automatic activa-
		tion of windows (remembers last activations) when changing
		to new screen, is configurable with Preferences program,
		has a full intuition interface and is font sensitive (incl-
		uding proportional fonts).  Documentation in AmigaGuide,
		ASCII and DVI formats.  Requires AmigaOS 2.04 or later.
		Version 2.1, an update to version 2.0 on disk number 915.
		Binary only, freeware.
		Author:  Markus Aalto

SMaus		A highly configurable "SUN-mouse" utility, implemented as a
		commodity with a graphical user interface.  It activates the
		window under the mouse pointer if you move or after you have
		moved the mouse or if you press a key.  You can specify
		titles of windows which shall not be deactivated using
		wildcards.  Uses local.library if available, requires at
		least AmigaOS 2.04.  Includes english and german docs,
		german and swedish catalog file (english language built
		in).  Version 1.24, an update to V1.17 on disk 868.  Share-
		ware, binary only.
		Author:  Stefan Sticht

SteamyWindows	A small yet very useful commodity that increases the prior-
		ity of the owner task of the active window, and restores
		the task's priority when the window becomes inactive unless
		someone else modified the task's priority meanwhile.  This
		is version 1.0, includes source in Oberon-2.
		Author:  Franz Schwarz

Contents of new/AmigaLibDisks/Disk948
-------------------------------------

ADis		A 68000+ disassembler which can automatically recognize data
		and strings put into the code segment.  It also generates
		only those labels that are really referenced.  The genera-
		ted file will often be reassemblable.  In V1.1, ADis is
		capable of recognizing all 68020 and 68881 instructions
		even with the 68020's extended addressing modes.  ADis will
		also try to resolve addressing relative to a4, which many
		C compilers use in a small memory model.  Version 1.1,
		binary only.
		Author:  Martin Apel

Snoopy		Enables you to monitor library function calls - of any
		library you wish.  The idea of course came from SnoopDos by
		Eddy Carroll, but Snoopy is different in approach and pur-
		pose.  Snoopy has no specific patches for specific func-
		tions - it is an all-purpose tool to monitor *ANY* library
		call in *ANY* system library.  Version 1.4, includes assem-
		bly source.
		Author:  Gerson Kurz, FH Muenchen

VirusZII	Release II of this popular virus detector that recognizes
		many boot and file viruses.  The filechecker can also de-
		crunch files for testing.  The memory checker removes all
		known viruses from memory without 'Guru Meditation' and
		checks memory for viruses regularly.  VirusZ has easy to
		use intuitionized menus including keycuts for both begin-
		ners and experienced users.  Release II versions of VirusZ
		require OS2.O+.  This is Release II Version 1.00, an up-
		grade to Release I version 3.07 on disk number 902.  Binary
		only, shareware.
		Author:  Georg Hvrmann

Contents of new/AmigaLibDisks/Disk949
-------------------------------------

BBBBS		Baud Bandit Bulletin Board System.  Written entirely in
		ARexx using the commercial terminal program "BaudBandit".
		Features include up to 99 file libraries with extended
		filenotes, up to 99 fully threaded message conferences,
		number of users, files, messages, etc. are only limited
		by storage space, controlled file library and message con-
		ference access for users and sysops, interface to extra
		devices like CD-ROM and others, all treated as read only,
		complete Email with binary mail and multiple forwarding,
		user statistics including messages written, files uploaded
		or downloaded, time, etc, plus much more.  Now includes a
		complete offline reader/answer called bbsQUICK.rexx, and
		Call Back Verification for local callers.  Version 6.5, an
		update to version 5.9 on disk 883.  Includes complete ARexx
		source.
		Author:  Richard Lee Stockton

TitleClock	A little commodity (about 3k) that throws up a clock in the
		top right corner of a screen's titlebar.  It may be set up
		to display itself on one or more screens without running 
		multiple copies of the program.  It may also be set to fol-
		low your default public screen and also to always display
		on the frontmost screen.  Version 2.7, binary only.
		Author:  Anders Hammarquist

Contents of new/AmigaLibDisks/Disk950
-------------------------------------

BBDoors		A collection of rexxDoors adjusted to work with BBBBS 6.5.
		Includes complete ARexx source.
		Author:  Richard Lee Stockton and various others.
 
bbsQUICK	An offline read/reply/upload/download module for BBBBS.
		Complete GUI with support for multiple BBBBS systems.
		Version 6.4 and update to version 5.9 on disk number 883.
		Includes complete ARexx source.
		Author:  Richard Lee Stockton

BusyPointers    A collection of busy pointers for use with 'NickPrefs'.
		(NickPrefs can be found on disk number 780).
		Author:  Dan Elgaard

ClockTool	A simple CLI utility do perform operations on the battery-
		backed-up and/or system clock, e.g. display either/both,
		set one from the other, increment, and log. Most of these
		features, particularly those accessing the battery-backed-
		up clock, are not available using current AmigaDos com-
		mands.  Version 1.0, includes source.
		Author:  Gary Duncan

Enforcer	A tool to monitor illegal memory access for 68020/68851,
		68030, and 68040 CPUs.  This is a completely new Enforcer
		from the original idea by Bryce Nesbitt.  It contains many
		new and wonderful features and options and no longer
		contains any exceptions for specific software.  Enforcer
		can now also be used with CPU or SetCPU FASTROM or most
		any other MMU-Kick-start-Mapping tool.  Major new output
		options such as local output, stdout, and parallel port.
		Highly optimized to be as fast as possible.  Version 37.55,
		an update to version 37.52 on disk number 912.  Requires
		V37 of the OS or better and an MMU.  Binary only. 
		Author: Michael Sinz

PayAdvice	Easy-to-use pay analysis program which is easily configured
		to deal with the way deductions are made from your salary.
		Useful for investigating just how large a slice of your
		hard earned cash ends up in the hands of the tax man, or to
		make sure that your employer isn't deducting more from your
		wages than he should.  Version 3.00, binary only, shareware.
		Authors:  Richard Smedley, Andy Eskelson, Robert Hart

Sushi		A tool to intercept the raw serial output of Enforcer 2.8b,
		Enforcer.megastack 26.f, Mungwall, and all other tool and 
		application debugging output that uses kprintf.  This makes
		it possible to use serial debugging on a single Amiga,
		without interfering with attached serial hardware such as
		modems and serial printers.  Sushi also provides optional
		signalling and buffer access to an external display/watcher
		program.  Version 37.10, an update to version 37.7 on disk
		number 733.  Binary only.
		Author:  Carolyn Scheppner

Contents of new/biz/dbase
-------------------------

AFile		A database manager, documentation in French, but program
		is localized.  English with French catalog.  Version 1.4,
		binary only.
		Author:  Denis Gounelle

CarCosts	Version 3 of the program "AutoKosten", now called CarCosts.
		This version uses MUI and supports locale.library, if avail-
		able.  Without locale.library, the interface uses german
		text.  An english catalog and all needed files are included.
		A program to convert 2.0 data files to version 3 data files
		is also included.  Binary only.
		Author:  R|diger Dreier

Genealogist	ArJay Genealogist is a specialized database for keeping
		track of genealogical information.  It features a full,
		easy to use Intuition interface.  The program is totally
		non-sexist and secular in nature, and correctly handles
		multiple marriages, "unconventional" marriages, adopted
		children, and unmarried parents.  The printed reports
		include descendant and pedigree charts, personal details
		reports, family group sheets, and index lists of people
		and families.  Free-form note files can be created using
		any editor, and IFF pictures can be viewed using any IFF
		viewer, from within the program.  Other features include
		dynamic on-screen ancestor and descendant charts, extensive
		online context-sensitive help, flexible "regular expression"
		searching, and multiple ARexx ports with an extensive
		command set.  Up to 1000 people per database, with data-
		bases held in RAM for maximum speed and responsiveness.
		PAL or NTSC, AmigaDOS 2.04+ required.  1 Meg RAM recom-
		mended.  Version 3.06, an update to version 3.04 on disk
		number 865.  Binary only.
		Author:  Robbie J. Akins

VideoMaxe	A video database that satisfies all needs of a private video
		user.  With full OS 2.1+ and environmental support (local-
		ization, application icon, installer, font-sensitive runtime
		gadget layout, layout saving, guide documentation, ...) the
		program handles record suggestions, spool informations, free
		amount of additional data per tape or title, comfortable
		search routines, printing, etc.  Requires OS 2.1.  Version
		4.30_beta, a major update to version 04.20 on disk number
		940.  Binary only, Shareware.
		Author:  Stephan Suerken

Contents of new/biz/demo
------------------------

ExcelsiorDemo	Demonstration version of a professional bulletin board
		system. Jam-packed with features not found on other BBS
		systems, EXCELSIOR! was in the  beta-test stage for over
		one year.  Its enthusiatic beta-testers have helped make
		it a very stable system.  Very little "hands-on" mainten-
		ance is needed to keep a system running smoothly.  However,
		you have complete control over the day-to-day activity of
		the BBS allowing for complete customization to your require-
		ments.  The BBS has been tested on Amiga 1000's through
		Amiga 4000's.  It also runs fine under AmigaDOS Release 3+
		as well.  Release 1.0, binary only.
		Author:  Sycom Design Software

Contents of new/biz/misc
------------------------

HomeBudget	A home budgeting system consisting of five major areas:
		Checking account; Savings account; Budgeting system;
		Miscellaneous accounts; Automatic account entries.  Features
		fast reconciliation; Checking account tied to Budget section
		for budget updates.  Budget section: uses 2 char codes for
		accounts; prioritize accounts for auto payment; optional
		automatic payments for fixed expenses; reports & charts
		available.  Version 1.3, binary only.
		Author:  Mike Huttinger

ShareManager	A personal share stock portfolio manager.  If you have
		trouble keeping track of your shares, then this is for you.
		It is not  however for very large portfolios with huge
		amounts of money involved.  $10,000,000 is the limit for
		this little package.  Version 2.3, binary only.
		Author:  Ben Muller

Contents of new/comm/fido
-------------------------

Spot		A FidoNet tosser/editor for all Amiga points (with WB 2.0+)
		Some features:  Supports new 3.0 features (newlook menus,
		memory pools,...); Fully localized (OS 2.1+); Font
		sensitive; Keyboard shortcuts; All settings can be easily
		changed from within Spot; Fast importing/exporting; Auto-
		matically creates new areas for you, no tedious work;
		Special fast message base format with only a few files
		per area; Optional - fully transparent - message base
		crunching; Message list with powerful functions (e.g.
		search body text); Excellent support for multiple character
		sets (LATIN-1, IBM,...);  Built-in, fully asynchronous,
		Fido file request; ARexx port... plus much more!
		Evaluation version 1.2b, binary only, shareware.
		Author:  Nico Francois

Contents of new/comm/mail
-------------------------

Smail		UUCP mail transport mechanism, based on Unix Smail V2.5.
		A complete substitute for Dillon's sendmail program.
		Features: re-routing of addresses according to the paths
		file; mail forwarding for users (~/.forward and uumail:
		<user>); nearly command line compatible with Dillon's
		sendmail (except -raw); Return-To-Receipt recognition;
		returning undeliverable mails to sender and postmaster
		of your host; support of the standard Getty, MultiUser-
		FileSystem and AXSh passwd files; smarthost option if
		your map files are not perfect; extended log files...
		and much more!  Requires OS2.04+, and a DillonUUCP or
		AUUCP+ environment.  Version 1.10, includes source.
		Author:  Aussem

SplUU		A UUEncoding file splitter for emailing large files.  It
		takes a file and UUEncodes it, and then it cuts it up in
		2000 line blocks.  It also gives each block a header and
		a tail.  Version 1.16_, binary only.
		Author:  Psilocybe Systems, Inc

Contents of new/comm/misc
-------------------------

ElCheapoFax	A very cheap and simple package to send and receive faxes
		using your Amiga and a suitable (Class 2) Fax modem.  It
		is not particulary user-friendly, nor is it blazingly fast.
		It just does everything I need.  In fact, as you and I don't
		need facsimile at all, it does a lot more.
		Version 24.10.93, includes source.
		Author:  Olaf 'Rhialto' Seibert

Contents of new/comm/net
------------------------

AmiTCP		AmiTCP/IP is the first publicly available TCP/IP protocol
		stack for the SANA-II interface.  AmiTCP/IP provides an
		application level socket interface to the Internet protocol
		suite as an Amiga shared library.  New Features in 2.2:
		AmiTCP:  The interactive sessions have now a higher priority
		when using rh(c)slip.device; arp: Arp table dumping is now
		working; netstat: Routing table can be dumped.  Version 2.2,
		includes source.
		Author:  AmiTCP/IP Group, others, see COPYRIGHTS

AmiTCP_POP	AmiPOP for AmiTCP/IP.  A POP 3 client for AmigaDOS 2.04+,
		and Requires AmiTCP/IP release 2 or higher.  Supports
		commodites, and is AUISG compliant.  Version 1.6, includes
		source.
		Author:  Scott Ellis

FtpDaemon	An ftpd for AmiTCP v2.0 and up (we use AmiTCP v2.2 ).  It
		has Multi-User support (we use MultiUser v1.5).  Version
		1.0, includes source.
		Author:  Joran Jessurun

ParBENCH	A ParNET installation kit put together by Vernon Graner of
		Commodore Business Machines.  It uses the CBM Installer and
		is fully documented.  ParNET itself is copyrighted by The
		Software Distillary and Doug Walker, John Toebes, and Matt
		Dillon.  The main improvements between this ParBENCH and the
		standard ParNET is the ease of installation and routine
		startup of the NET: device.  This package contains a set of
		WorkBench tools to boot the network and fix up and display
		remote node icons, etc.  Version 3.1, binary only.
		Author:  Vernon Graner, Doug Walker, John Toebes, Matt
			 Dillon

Contents of new/comm/term
-------------------------

HFT		A very small ANSI terminal program.  Small, reliable, with
		just the bare essentials.  Main features:  Console support
		with cut & paste; Reliable ANSI terminal emulation; Compat-
		ible with all serial.device clones.  HFT was tested on
		serial, baudbandit, uw, and nullmodem devices.  Opens on
		the default public screen.  Version 38.30, binary only.
		Author:  Herbert West

Terminus	A highly capable and flexible, if not seasoned telecom-
		munications tool for the Amiga.  Terminus is a completely
		rewritten replacement for JR-Comm 1.02a.  It is not an
		update.  Terminus conforms, where possible, to the recom-
		mendations outlined in the "Commodore Amiga Style Guide"
		for Release 2 of the Amiga operating system while still
		retaining compatibility with the 1.3 release.  However,
		all future releases of Terminus will be compatible with
		the 2.0 (or later) operating system release only.  Version
		2.0d, binary only, shareware.
		Author:  John P. Radigan

XprZmodem	An Amiga shared library which provides ZModem file transfer
		capability to any XPR-compatible communications program.
		This is version 3.1, an update to version 2.1 on disk 459.
		Includes source.
		Author:  Ranier Hess, William M. Perkins, Rick Huebner and
			 others.  See documentation.

Contents of new/comm/uucp
-------------------------

AGetty		AGetty is similar to the well-known Getty included in Matt
		Dillon's AmigaUUCP package.  It hangs on the specified
		serial port waiting for connections via the connected
		modem.  Once a connection is detected, AGetty provides
		a Login: request to the caller.  Getty disconnects any
		caller who cannot provide a legal login and Password
		within 60 seconds.  It also allows only 3 login attempts
		before disconnecting.  Any attempt to login with an illegal
		password will be written to the logfile.  Upon receiving
		a legal Login and Password, verified via the passw-file,
		AGetty will execute a specified program, usually UUCICO
		or PMail, and stay off the line until the program returns.
		Then, AGetty will disconnect the caller and reset the
		modem, returning to its original state.  Version 0.218,
		binary only.
		Author:  Peter Simons

Contents of new/dev/asm
-----------------------

TBSource	A collection of Tomi Blinnikka's A68k source files.  In-
		cludes assembler source to various programs, some finished,
		others are not.  The large list of programs includes such
		things as VoiceShell, ShellTerm and RingDetect.
		Author:  Tomi Blinnikka

Contents of new/dev/cross
-------------------------

CAZ		A Z80 cross-assembler.  Some people never stop building
		their own hardware projects!  The Z80 processor is old,
		right, but a really cheap one!  So design your own Pro-
		cessor Board and do all your software development on the
		Amiga.  Version 1.24b, includes source.
		Author:  Carsten Rose

Dis6502		A disassembler for the 6502-family of microprocessors.  It
		will turn C64 (or any other 6502-based computer's) binaries
		into listings of CPU opcodes.  Supports all officially docu-
		mented opcodes on the 6502-compatible processor family.
		Future versions will support undocumented opcodes (option-
		ally), hardware register recognition for the C64 hardware
		registers, relative offset disassembling, and a lot more.
		Version 1.0, binary only, shareware.
		Author:  Morten Eriksen

Contents of new/dev/docs
------------------------

AsmKURS		Some documentation on assembly language coding for the
		68020/68881 or better combination.  In addition you will
		find docs for the FPU, along with source for a nice, fast
		Julia fractal plotter that utilizes the FPU.  The files
		also contains some hints about optimizing your code for
		an 020, too.
		Author:  Erik H. Bakke

Contents of new/dev/gui
-----------------------

DesignerDemo	Demo version of a gadget source creator for C & HSPascal.
		With Designer, you can create and edit windows and menus
		for applications.  It supports many features:  All gadtools
		gadgets possible;  Commented source produced;  IFF images
		imported;  Edit any created window;  Standard interface;
		Flexible code producing options.  Version 1.0, binary only.
		Author:  Ian OConnor

Contents of new/dev/misc
------------------------

CWeb		A programming tool that allows you to program top down,
		by splitting your program into many small, and under-
		standable modules which `ctangle' tangles into a compiler 
		understandable file.  By applying `cweave' to the program
		you can produce a pretty-printed listing for processing
		with `TeX'.  This is version 3.0, an update to version
		2.7 on disk number 848.  Includes source.
		Author:  Donald Knuth, Silvio Levy, port by Andreas Scherer

Data2Object	Sometimes you want to have a large text file in your code.
		For example a built-in helpfile.  d2o gives an easy way to
		do just that.  It takes the textfile as an argument and
		produces a standard object file.  Includes an option to
		force the data into chip ram for graphics and sound data.
		Version 1.1, binary only.
		Author:  Matthijs Luger

FlexCat 	FlexCat is a utility like CatComp (which is available for
		registered developers only), KitCat or MakeCat, which
		creates catalogs and source to handle them.  The goal in
		writing FlexCat was to be flexible in the source that is
		created.  This is done by using external template files
		(so called source descriptions) which can be edited by the
		programmer.  Any programming language or individual needs
		can be satisfied.  This is V1.01 (some minor bug fixes)
		and includes examples for Assembler, C and Oberon, an
		example for handling catalogs in Workbench 2.0, german and
		italian catalogs, source and docs in AmigaGuide, Ascii and
		DVI format.
		Author:  Jochen Wiedmann

LibraryTimer	GUI based attempt to figure out what library functions
		take most of the processor time in an application, and
		thus what functions should deserve more attention when
		time-optimizing the program.  Does this by patching the
		functions in the selected library, then calling ReadEClock
		in the timer.device before and after the function is
		executed.  Requires OS2.04+. Version 1.1, binary only.
		Author:  Jesper Skov

P2C		A tool for translating Pascal programs into C.  It supports
		the following Pascal dialects: HP Pascal, Turbo/UCSD Pascal,
		DEC VAX Pascal, Oregon Software Pascal/2, Macintosh Program-
		mer's Workshop Pascal, Sun/Berkeley Pascal.  Modula-2 syntax
		is also supported.  Most reasonable Pascal programs are con-
		verted into fully functional C which will compile and run
		with no further modifications.  Version 1.20, includes
		source.
		Author:  Dave Gillespie, AMIGA port by G|nther Rvhrich

Contents of new/disk/cache
--------------------------

FastCache	A disk-caching program with the following features: Fully
		associate cache (one of the best algorithms); LRU cache
		replacement policy (one of the best); Can handle multiple
		drives; Can handle removable media; All cache settings are
		determined at run time; Optional write retention; Does not
		require large continuous chunks of memory; Uses a hashing
		system to locate data (one of the best); Performs both for-
		ward and reverse prefetching; Will utilize the blitter to
		move data, if possible.  Requires OS2.04+, version 1.1,
		binary only.
		Author:  Philip D'Ath

Contents of new/disk/cdrom
--------------------------

PlayCDDA	A program for owners of Toshiba 3401 CDROM drives.  These
		drives are capable of transferring CD-DA (digital audio)
		data over the SCSI bus.  PlayCDDA reads this data and repro-
		duces the corresponding sounds on the Amiga's audio.device.
		PlayCDDA communicates with the user over a simple graphical
		interface.  Version 1.0, includes source.
		Author:  Frank Munkert

Contents of new/disk/misc
-------------------------

DevBlocks	Two CLI programs for the low-level direct reading/writing/
		dumping of disk blocks of a DOS structured device.  Use with
		care and only if you know what you are doing!  (Else you can
		easily trash a disk/hard-drive partition!).
		Author:  Christian Wasner

FileLogger	Demo version of a floppy disk cataloging utility.  Allows
		you to log disks and selected files.  You may specify a
		filetype and remarks for each file which can be queried on
		later.  Remarks will be read by default from the file com-
		ments (if present).  Optionally guesses file types.  (Over
		30 file types are currently recognized).  Wildcard searches
		on disk name, file name, file type or remarks.  Multilevel
		sorting by diskname, filename, filetype and remarks.  Print
		out the full log or the Selected/sorted part of it.  Number
		of files limited by memory.  (Some functions disabled and
		number of files limited to 500 in this demo version).  Ver-
		sion 1.31, binary only.
		Author:  Arun Kumar

StatRam		A very fast, very recoverable ram drive. It works on any
		Amiga using V2.04 or greater of the OS. It maintains the 
		remarkable recoverability of the original VD0:, but has
		now been totally re-written to handle any DOS filesystem,
		be named what you like and give back memory from deleted
		files instantly. Based on ASDG's 'VD0:'. Version 2.2, an
		update to version 2.1 on disk number 915. Binary only.
		Author:  Richard Waspe, Nicola Salmoria

Contents of new/disk/moni
-------------------------

DED		A new disk editor with many features including: Edit sectors
		on disk in binary form or in DOS structures (including
		bitmap); Find file of FFS datablock; Scan for DOS structure
		references to any block;  Edit rigid disk blocks in struct-
		ure form; Export or import bytes from/to disk; Memory access
		of all sectors until written to the disk (Allows you to try
		anything without risking integrity of your disk); Protection
		option - no sector can be formatted or written to the disk;
		All menuitems have help; Built-in calculator.  Version 1.1,
		binary only.
		Author:  Michal Kara

Contents of new/game/demo
-------------------------

Frontier	Non-playable preview (Self-running demo) of the upcoming
		sequel to the space-trading game Elite.
		Author:  David Braben.

JetStrike	A 10 level sample of the full Jetstrike game, a commercial
		product.  The full version of Jetstrike contains: Over 100
		different missions, 40 different aircraft, 40 weapons
		systems, Auto enhancement for systems with more memory,
		Hard disk installation, Fully compatible with all Amigas
		(automatically resizes for NTSC and PAL displays).  Mission
		disks to be released in 1994 to add further missions, air-
		craft and weapons.  Binary only.
		Author:  Rasputin Software

Contents of new/game/misc
-------------------------

AMOSAlley	A shoot-em-up "don't-hit-the-good-guys hit-the-bad-guys-
		instead" type shooting gallery reaction game.  Programmed
		and compiled with AMOS PRO.  Requires at least 1 meg Ram.
		Author:  Dean Prunier

MegaBall	All-new version 3.0 of this classic amiga action game!
		Comes with two graphics files, one that lets it run on
		older Amigas (even ones running WB 1.2!), and another that
		lets it take advantage of dazzling 24-bit AGA graphics if
		ya got 'em!  Packed with a whole bunch of exciting new
		features, music and boards.  Documentation in AmigaGuide
		format.  Binary only, shareware.
		Author:  Ed Mackey, with new music by Al Mackey

ScorchedT	Scorched Tanks is a tank warfare game where 2 to 4 players
		take turns buying weapons and shooting them at each other.
		The more damage a player causes another, the more money they
		get.  The more money a player receives, the larger the
		weapons they can buy.  This is a very simple concept, but
		extremely addictive! Similar to a very popular game called
		Scorched Earth on MS-Dos machines.  Version 0.95, binary
		only.
		Author:  Michael Welch

Contents of new/game/patch
--------------------------

MarblePatch	A patch allows you to run Marble Madness under OS 2.x
		(and probably higher).  It also includes the old copy
		protection hack which allows you to run it from a hard
		disk.  Includes source.
		Author:  Derek Noonburg

Contents of new/game/think
--------------------------

CrazyClock	For those of you who know about Mr.R.'s cube.  (well-known),
		This program is inspired by Mr.R.'s clock (almost unknown)
		which is a much easier alternative for everyone who couldn't
		solve the cube through intuition.  Version 1.1, Requires
		OS2.04+, includes source.
		Author:  Holger Brunst

HangMan		A GUI Hangman game in six different languages !!  Features:
		A full GUI interface (both keyboard and mouse can be used);
		Partly localized (on OS 2.1/3.0) for defaulting to a partic-
		ular language; User can specify his own data file.  English,
		French, German, Spanish, Swedish and Dutch data files
		included.  A useful Hint and Show All feature when you are
		stuck with a word.  AmigaGuide Online Help also available.
		Version 1.2, requires OS2.0+, binary only.
		Author:  Arun Kumar G.P.

IGNUChess	An intuition driven interface to GNUChess version 1.51.  I
		know, this is an old one.  There are a few  advantages,
		though:  IGNUChess is freely distributable;  Full source
		(SAS/C 6.3) is included;  Chess piece images are provided
		as an IFF ILBM file (Figuren.ilbm) for free use;  Needs
		only ~200K memory (+some chip mem for the graphics) and
		thus runs on small machines (A500) without memory expansion.
		Special version optimized for 68020/30 + 68881/2 included.
		Runs in NTSC Interlaced mode.  The graphics are designed to
	  	minimize noticable flicker, so this might be the first
		interlaced GUI most 1084 Monitor users like.
		Author:  FSF, amiga port by Michael Bvhnisch

MasterMind	This new version of Mastermind has the following features:
		Point-n-click interface; Difficult level using 8 color
		choices; Normal level uses 5 color choices; Background
		music; Sound effects; Animated "win" effects.  Version 1.3.
		binary only.
		Author:  Patrick Giesbergen

Minefield	Based on the classic thinking game, Minefield features
		various sized squares ensuring that it looks good on Hi-res
		to Super-hi-res-laces screen modes.  Other features include
		timer count up/down option, nice WB2.+ colour scheme, custom
		minefield and hall of fame history.  Version 1.0, binary
		only.
		Author:  Richard Bemrose

Solit		Solit is a freely-distributable, shareware non-Klondike
		solitaire card game for the Amiga under Workbench 2.x.
		This is version 1.11 which contains some enhancements
		to version 1.06 found on FF882.  Binary only.
		Author:  Felix R. Jeske

SMMind		SuperMeisterMind is a MasterMind clone which uses colors
		and shapes to form the hidden code.  This results in a
		completely new level of difficulty.  Features:  OS 2 look;
		up to 7 colors and 7 shapes; code-length up to 6 symbols;
		almost anything may be configured by the user; online-help.
		German version only, but game not difficult to figure out
		for those familiar with MasterMind.
		Author:  Holger Voss

UChess		A powerful version of the program GnuChess version 4 for
		the Amiga.  Plays a very strong game of chess.  Code has
		been rewritten and data structures re-organized for optimal
		efficiency on 32 bit 68020 and better Amiga systems. Fully
		multitasking, automatically detects and supports 640X480X256
		color AGA mode machines, and does not at any time BUSY wait.
		Requires a 68020/030/040 based Amiga computer system with
		AmigaOS 2.04 or later and 4 Meg of ram minimum.  Special "L"
		version optimized for 68040 and requires 10 Meg of ram min-
		imum.  Supports a variety of standard features such as load,
		save, edit board, autoplay, swap sides, force move, undo,
		time limits, hints, show thinking, and a supervisor mode
		that will allow two humans to play with the computer acting
		as a "supervisor".  Version 2.33, an update to Version 2.04
		on disk number 790, includes source.
		Author:  FSF, Amiga Port by Roger Uzun

Contents of new/gfx/3d
----------------------

RDSGen		A "SIRDS" generator.  SIRDS are Single-Image-Random-Dot-
		Stereograms and are "real" three-dimensional pictures.
		The dots (which seem random) are calculated in such a way
		that if you focus "behind" the picture (monitor, etc), you
		will see a 3D pic with a real feeling of "depth".  It can
		be hard to see the pics the first time, but don't give up!
		Most people succeed in seeing them, though it may take some
		time.  Version 1.0, binary only.
		Author:  Martin Rebas

Contents of new/gfx/anim
------------------------

AA-Spot 	A little animation which shows some abilities of the new
		AA-Chipset.  Supports only the PAL-mode.
		Author:  Markus Poellmann

AmysHistory	A graphical history of Amy the Squirrel, in Deluxe Video
		animated format.
		Author:  Eric Schwartz

Contents of new/gfx/edit
------------------------

Digillus	Digital Illusions is a highly professional image processing
		program.  Not only is it capable of processing still pix,
		but it will also let you create stunning animations from
		ordinary flat pictures using a powerful 'In between' tech-
		nique.  Version 1.0a, binary only, shareware.
		Author:  Tonny Espeset

TSMorph		A morphing package consisting of three programs: TSMorph to
		edit the Morph parameters; TSMorph-render to generate the
		morphed images; and TSMorph-prefs, a Preferences editor.
		Morphs and Warps can be performed on static images or a
		series of images.  All processing is done using 24-bit
		colour internally.  Images in most ILBM formats, GIF, JPG
		and PPM can be read, and ILBM 24, Greyscale (16 and 256),
		PPM, HAM6 and HAM8 format images saved.  OpalVision and
		DCTV format files are also catered for.  Version 2.3,
		includes source.
		Author:  Topicsave Limited

Contents of new/gfx/misc
------------------------

ADProRunner	ADPro is a great program, but it requires alot of memory.
		Sometimes you need 3 MB or more to convert a picture.  It
		is possible to specify memory-usage in the ADPro icon or
		from the shell but this can be awkward.  If you do not
		specify memory size, ADPro takes the largest free hunk of
		memory, and leaves you with only small hunks left.  This
		may result in loaders, savers and operators being loaded
		into chip memory, which is dead slow on an accelerated
		Amiga.  With ADProRunner you can easily control ADPro's
		memory usage each time you run it.  Version 1.0, binary
		only.
		Author:  Xyvind Falch & Morten Johnsen

GROBSaver	A saver module for GVP's ImageFX Image Processing package.
		It allows you to save an image in Hewlett Packard's GROB
		(GRaphical OBject) format, suitable to be downloaded into
		any of Hewlett Packard's HP48-series calculators.  If you
		don't own an HP48(s,sx,g,gx) this program won't do anything
		useful for you.  Version 1.03, binary only.
		Author:  Greg Simon

ImageDex	A utility program that will take a series of image files
		(any format) and create an image index of scaled down
		"thumb-nail" pictures, labelled appropriately.  The program
		acts as a graphic front-end to Art Department Professional
		2.2 (or higher).  Useful for catalogging images, textures
		and anim frames, allowing them to be stored off the main
		system.
		Author:  Zach Williams, Precision Imagery

PatchDT	        A program that patches a few functions in the datatypes
		library in order to speed up the Workbench screen update
		when using datatypes objects as backdrops in the workbench
		windows.  This is only useful with graphics cards such as
		the Piccolo or GVP Spectrum; you will see no speedup when
		using the native Amiga graphics.  Requires 68020+ and
		WB3.0+.  Includes source.
		Author:  Stefan Boberg

Contents of new/gfx/opal
------------------------

Wacom		This Commodity enables you to use a pressure sensitive
		digitizer tablet from Wacom with your Commodore Amiga.
		The tablet can be used together with the mouse (or with-
		out it) as a direct input medium.  Therefore the driver
		can be used together with (nearly) any software.  Further-
		more the (pressure-sensitive) data provided by the tablet
		can be exported in custom applications using a documented
		software interface.  Version 1.0, requires AmigaOS 2.04+.
		English and German documentation.  Localized.  Binary only,
		but includes some sample source in C that shows the usage
		of the software interface.  Shareware.
		Author:  Roland Schwingel

Contents of new/gfx/show
------------------------

EGSdvi		A program which runs under the EGS window system.  It is
		used to preview DVI files, such as are produced by TeX.
		EGSDVI requires EGS version 6 or higher.  This program
		has the capability of showing the file shrunken by various
		(integer) factors, and also has a `magnifying glass' which
		allows one to see a small part of the unshrunk image momen-
		tarily.  Version 1.0, binary only.
		Author:  Dietmar Heidrich

EGSPrint	This program prints the contents of the frontmost screen,
		no matter what depth it has or if it's a true EGS screen
		or a screen of an EGS workbench emulation.  This even works
		if there's no EGS at all or if the screen has a colour
		resolution of 24 bits (but then, only 12 bits are printed
		as the printer device supports no more than that).  EGSPrint
		needs a lot of memory, especially for EGS screens, and
		requires EGS version 6 or higher.  Binary only.
		Author:  Dietmar Heidrich

EGSShow		A viewing program for GIF and JPEG files on the EGS window
		system.  This program is able to read the JPEG format as
		well as the GIF formats GIF87a,  GIF89a and all future GIF
		files compatible with both of the above.  The format of the
		file is detected automatically.  EGSShow needs a lot of
		memory for bigger pictures ( > 640 x 480) and requries EGS
		version 6 or higher.  Binary only.
		Author:  Dietmar Heidrich

Contents of new/gfx/view
------------------------

MegaView	A "Multi-View" kind of program for use with Workbench 2.0+.
		It uses the whatis.library (included) to recognize the file
		type then invoke a filetype-specific program.  MegaView can
		be used from the Shell, from Workbench, as Default Tool in
		project icons, as an AppIcon or as an App-MenuItem.  Version
		2.0, an update to version 1.03 on disk number 908, public
		domain, includes source.  Enhancements include localization
		and a GUI-based FileActions editor.
		Author:  Hans-Jvrg and Thomas Frieden, Whatis.library by
			 Sylvain Rougier and Pierre Carette

Contents of new/hard/drivr
--------------------------

ZeusSCSI	Some programs that attempt to apply a patch to the
		Progressive Peripherals Incorporated Zeus SCSI driver.
		This patch includes a patch to use the Wait/Signal mech-
		anism to wait for the completion of SCSI I/O instead of
		the "busy-wait" poll method used by the driver.  (These
		programs will only patch the 2.98 version of the Zeus ROM.)
		Author:  Michael L. Hitch

Contents of new/hard/misc
-------------------------

AutoXA		Loads a small program into your system that automatically
		adds the memory that you have installed on a MicroBotics
		M1230XA card every time you reboot, this routine survives
		a reboot, and makes the memory available to the system
		software *much* earlier in the boot-up process.  This
		results in almost all of the system's data being loaded
		into much faster XA memory, rather than Chip memory.  It
		also frees up about 245 kilobytes of Chip memory that
		graphic or music programs might need.  Version 1.00,
		binary only.
		Author:  Mike Pinson, MicroBotics, Inc.

EPROMmer	New software (use WB2.0 or higher) for a hardware project
		originally by Bob Blick and Udi Finkelstein.  EPROMmer
		programs 2716 - 27512 and can also load SRAM's 6216,6264,
		62256.  Capable of reading/writing binary data and INTELHEX
		Files.  Supports all amiga models.  This version of the
		software contains a new GUI and timing was changed to handle
		Amigas faster than 7Mhz.  Version 3.2d, includes source.
		Author:  Bob Blick, Udi Finkelstein, Carsten Rose

GALer		GALs (Generic Array Logic) are programmable logic devices.
		"GALer" is the software and the hardware which is necessary
		to program your own GALs.  The supported GAL-types are
		GAL16V8, GAL16V8A, GAL16V8B and GAL20V8, GAL20V8A, GAL20V8B.
		The circuit diagram for the GAL device programmer is avail-
		able from the author.  Version 1.41, an update to version
		1.4 on disk number 882.  Includes both English and German
		versions.  Shareware, requires OS2.1+.  Includes source.
		Author:  Christian Habermann

ParTest		A little GUI-based utility that allows you to individually
		set/clear the data lines of the parallel port.  Binary only.
		Author:  Carsten Rose

Contents of new/icon/utility
----------------------------

ScaleIcon	An MUI application that enables you to scale your Workbench
		icons in a simple and convenient manner.  It supports scal-
		ing by fraction (in percent), by absolute sizes, halving and
		doubling and to use an icon (size) as template.  Any of
		these actions may be performed on any one or both axes.
		Version 1.5, binary only.  Requires MUI.
		Author:  Frode Fjeld

Contents of new/misc/edu
------------------------

Dinosaurs	With lots of hi-res graphics, this demo version introduces
		you to all type of dinosaurs from different gealogical
		time periods.  Give recreation, skeletal view, geographic
		locations, taxonomic information and general descriptions.
		Demo version 2.0, requires a minimum of 3 Meg ram.  Binary
		only.
		Author:  Bob Burdett

OurSolarSys	Using the HELM multimedia authoring software package from
		Eagle Tree Software,  this "book" is a small guide to our
		solar system "The Milky Way".  It contains facts, pictures,
		and commentary about each planet.  The information used in
		this "book" was provided by "The Planetary Society" a non-
		profit,tax-exempt membership organization dedicated to the
		exploration of the solar system.
		Author:  Joe Korczynsk, ABCUG User Group

Contents of new/misc/emu
------------------------

TransNib	A fast, simple parallel data transfer protocol.  It was
		designed to make linking any type of machine to any other
		type as easy as possible.  All that is required is six 5V
		I/O lines at each end.  It doesn't matter how fast or slow
		each machine is, as the protocol uses a two-line handshake
		procedure, ensuring the two machines cannot possibly go out
		of sync.  Any two computers supporting the TransNib V1.00
		protocol can be linked.  So far, front-ends exist for Amiga
		and the Commodore 64.  Version 1.0, binary only.
		Author:  Matt Francis

Z80		Zilog Z80 CPU emulator package for the Motorola M68000
		family.  It is coded entirely in 680x0 assembler, and is
		probably the fastest existing Z80 emulator for this pro-
		cessor family, while retaining complete generality.  It
		was developed on an Amiga, but should be possible to use
		on any 680x0-based computer without any modifications.
		Version 0.99b, freeware, includes source.
		Author:  Richard Carlsson

Contents of new/misc/sci
------------------------

cP		A data viewing program capable of plotting two dimensional
		data in both linear or log space with or without symbols.
		Only runs from the CLI, requires Kickstart 37 or higher.
		Number of data points limited only by system ram.
		Version 2.206, binary only.
		Author:  Chris Conger

Contents of new/os20/cdity
--------------------------

CatchDisk	A simple commodity for "auto-formating" bad/unformatted
		disks.  Each time a disk is inserted into a drive, it checks
		to see if it is properly formatted.  If not, CatchDisk
		executes the Format program and asks the user if he wishes
		to format the disk.  Version 1.1, binary only.
		Author:  Alessandro Sala

MagicMenu	Replaces all Intuition menus, supporting both "pull-down"
		and "pop-up" menus.  Menus can be displayed in either the
		Standard look, or the modern AmigaOS 2.0 style 3D-Look, and
		controlled exclusively using the keyboard, (no need to grab
		the mouse anymore!)  Configurable handling and appearance.
		Remembers every menu's last selected item, displaying Pop-Up
		menus the next time at a position allowing quick selection
		of the same or neighboring items.  Automatically brings the
		currently active screen (if not visible) to the front for
		menu selection then returns it to the back after a selection
		is made.  Input timeouts, plus much more!  Version 1.29, an
		update to version 1.27 on disk number 906.  Binary only.
		Author:  Martin Korndvrfer

Yak		"Yet Another Kommodity".  Features a sunmouse that only
		activates when mouse stops, KeyActivate windows, Click
		windows to front or back, Cycle screens with mouse, Mouse
		and Screen blanking, Close/Zip/Shrink/Enlarge windows with
		programmable hotkeys, Activate Workbench by hotkey (to get
		at menus when WB obscured), Pop up a palette on front
		screen, Insert date (in various formats), KeyClick with
		adjustable volume, Pop-Command key for starting a command
		(like PopCLI), Gadtools interface.  All settings accessible
		from Workbench tooltypes.  Version 1.55, an update to ver-
		sion 1.52 on disk number 912.
		Author:  Martin W. Scott and Gakl Marziou

Contents of new/os20/cli
------------------------

FCD 		"Fast-Change-Directory" a useable replacement for the CD
		command.  Uses an index file to store paths for the spec-
		ified device.  So if you want to change to a dir lying in
		the deepest jungle of your HD (f.e. bla/hi/jo/here/is/right)
		you can just type "FCD right".  Version 1.0, binary only,
		freeware.
		Author:  Nico Max

Inf		An extended AmigaDOS INFO command, displays more file system
		information than the standard INFO command.  Supported file
		system "Type"s are MSDOS, OFS, FFS, INOFS, INFFS, DCOFS,
		DCFFS, NDOS, KICK, CUST, and BAD.  Where the "IN" prefix
		is for international and "DC" is for directory cache.
		Version 1.32, binary only.
		Author:  Trevor Andrews

MJUtils		A collection of useful CLI utilities.  Included are AFD,
		an ascii file dumper;  Stat, measures the execution time
		and memory requirements of a command;  MakeCol, make a
		text file multi-column;  Print, prints a 640x512x1 IFF
		picture on Epson 9-pin printers in a special "equal-
		density" mode;  WordCount, counts frequencies of all words
		in a file; FastCmp, a fast byte-to-byte comparison of two
		files;  FType, search for strings in a binary file;
		SetMPos, set the mouse position to a given XY coordinate;
		Exe, reads lines from the standard input and executes
		them... plus more!  Binary only.
		Author:  Martin Mares, MJSoft System Software

PS		A cli utility that gives you process and task status infor-
		mation.  You may specify a task name, or information about
		all tasks and processes currently in the system will be
		displayed.  Version 1.34, binary only.
		Author:  Trevor Andrews

SSearch		Does nearly the same thing as the AmigaDOS's search command
		but faster.  Example: searching for "foobar" in the C=
		Autodocs (plus some other Autodocs, 82 files, 1937 KBytes)
		requires 78 seconds with search and 14 seconds with ssearch
		on the author's machine (A3000/030-25).  SSearch has two
		additional features compared to search:  you  can  search
		case sensitive, which is even faster than case insensitive,
		and you can switch off printing of file names.  Version
		1.0, binary only.
		Author:  Stefan Sticht

SSplit		A small utility that allows you to split one big file into
		several small files.  Useful for splitting up large files
		for transporting or storing on floppies.  Includes templates
		to split files to the exact size for storing on OFS, FFS,
		and low and high density MSDOS disks.  Version 1.1, binary
		only.
		Author:  Stefan Sticht

Contents of new/os20/util
-------------------------

AssignManager	A new prefs editor which handles your custom assigns in a
		friendly, all-encompassing way.  No more fiddling with
		Assign commands in User-Startups.  Now you can use Assign
		Manager to edit your list of assigns to your heart's con-
		tent.  Version 1.24, an update to version 1.00 on disk
		number 913.  Binary only.
		Author:  Matt Francis

MeMon		An intuition-based utility that allows you to monitor or
		change specific memory addresses.  User may select byte,
		word, or long word alignment.  Displays in binary, hex,
		and signed or unsigned decimal.  Also useful for displaying
		ascii codes of various character key mappings and/or as a
		hex/binary/decimal converter.  Version 1.1, an update to
		version 1.0 on disk number 769.  Binary only.
		Author:  David Ekholm

MFRhelp		If you are user of the great MagicFileRequester v2.0(d/e)
		by Stefan Stuntz and of the new CygnusEd 3.5 you probably
		have noticed, that the CygnusEd 3.5 refuses to load a single
		file if the MagicFileRequester is installed.  Now, to get
		rid of this problem you can do the following things:  remove
		the MagicFileRequester  (probably the worst idea you ever
		had...:-) ); open always more than one file at the same
		time (not a good solution); install MFRHelp (that would be
		fine!).  Version 0.20, includes assembler source.
		Author:  Daniel Weber

MuiEnv		An MUI application for the manipulation of environment
		variables.  MuiEnv can edit, save, load, delete, and
		rename environment variables, and supports subdirectories.
		Requires AmigaOS 2.04+ and MagicUserInterface by Stefan
		Stuntz.  Binary only.
		Author:  Michael Suelmann

MultiUser	Allows you to create a Unix-like environment where several
		users live together in harmony, unable to delete each others
		files, unable to read those private love-letters of other
		users... And this even if several users are working on the
		machine at the same time (on a terminal hooked up to the
		serial port) Version 1.5, an update to version 1.4 on disk
		number 905, requires OS2.04+ and a hard drive, binary only.
		Author:  Geert Uytterhoeven

PPrefs		A screen mode promotion utility,  Features: supports general
		screen promotion rules; keeps lists of exceptions (screens
		and tasks); exceptions could be promoted differently or
		kept; can use BestModeID() under 3.0 to determine best
		suitable screen mode (offers some options to control);
		preferences editor with font-sensitive, localized GUI;
		saves preferences to IFF file.  Version 1.1, binary only.
		Author:  Olaf Gschweng

Recall		Do you keep forgetting about birthdays, anniversaries and
		other important events?  Well, there are plenty of public
		domain products on the market that will prevent that from
		happening.  But, do you also want to: Keep track of the re-
		maining days to important events? Keep track of the days
		since important events happened? Autostart certain programs
		depending on the date and time?  Be reminded every # day
		(eg. every 14th day)?  Be reminded # days in advance or
		after the event?  Be reminded with requesters, alerts or
		practically anything that can be displayed on a Amiga
		monitor? Display unlimited lines of text in the same
		requester/alert?  Recall does all this plus much more.
		Version 1.7, includes source.
		Author:  Ketil Hunn

SSL		Special Support Library.  A library designed to simplify
		development of assembly programs.  Version 3.0, binary
		only, example source included.  Requires V37 or higher.
		Author:  Martin Mares, MJSoft System Software

StickIt		A computer replacement for the ol' Post-It note.  It allows
		you to stick notes onto your screen which will be displayed
		every time you re-boot; useful to remind you of things to
		do.  Features: Unlimited number of notes on screen; Notes
		remember where you left them; User-defined font name/size;
		User-defined note size; User-defined text/background colour
		(yep, they can be yellow if you want !); User-defined delay
		at startup to avoid disk thrashing; User-defined filename
		for note information.  Requires AmigaDOS 2.04+.  Version
		1.03, an update to version 1.02 on disk number 913.
		Includes source.
		Author:  Andy Dean

TM2Ascii	Have you ever tried to move your ToolManager-icons directory
		to another place?  Did you rename your Harddisk or get a
		bigger one? Did your index finger get tired of endless
		clicking only to change the path of 42 icons?  The solution
		is TM2Ascii.  It will read a ToolManager configfile and
		translate it to an ASCII (readable!) file.  Use your fav-
		orite editor to globally change everything you want and then
		use TM2Ascii to change the file back into ToolManger format.
		Version 1.0, includes source.
		Author:  Michael Illgner

Contents of new/os20/wb
-----------------------

PMontre		A FreeWare digital clock for the WB.  Features:  Digital
		Clock (naturally); Date; Calendar (for French language
		only); English/French/German languages; Free memory Chip/
		Fast/Total in only one bargraph; PubScreen option; WB
		toolstypes and Shell options supported; Alarm with re-
		quester; Borderless option.  Version 1.1, binary only.
		Author:  Pascal Pensa

ToolsDaemon	Allows you to run programs simply by selecting a menu item
		from the menu strip of Workbench 2.0.  Shell and Workbench
		programs are supported, including arguments and tool types
		for both of these.  The menu items can be arranged in
		several menus, with sub-items and keyboard shortcuts.
		Version 2.1, binary only.
		Author:  Nico Francois

Contents of new/os30/gfx
------------------------

CPK		An AGA & Picasso compatible molecular rendering program.
		This version sports a number of new enhancements including
		an AREXX port, lightsource  positioning window, asynchronous
		file I/O, fast rendering mode, and most importantly, AGA
		and Picasso graphics compatibility.  Version 2.0, binary
		only.  Requires OS3.x.
		Author:  Eric G. Suchanek, Ph.D.

Contents of new/os30/util
-------------------------

HFK		Yet another TitleBar clock that tries to look like part of
		your Workbench title bar.  It actually opens a very small,
		nondraggable window in the upper right corner of the screen.
		HFK opens on the default public screen, which will usually
		be Workbench.  HFK uses almost 0% of CPU time, as it is
		written very efficiently in C, taking advantage of the
		timer.device, and only once a minute to render the time.
		Version 39.45, an update to version 39.35 on disk number
		908.  Requires Workbench 3.0, binary only.
		Author:  Herbert West

Promotor	Allows you to promote screens to any mode you wish.  You
		can give instructions for specific screens, give general
		promotion rules, promote depending on the mode requested
		by the program, or depending on: the task requesting the
		screen, the title of the screen or the public screen name
		for the requested screen.  You can also do more than simply
		change the mode, You can change the DriPens for the screens,
		the number of colors in the ColorMap,  and a lot more (check
		out the tags for OpenScreenTags, most of them  can  be
		changed using the Promotor).
		Version 1.9, binary only.
		Author:  Kurt Haenen

SCR		An AGA Screen Color Requester.  The standard Amiga 3.0
		Preferences Palette Requester is very limited in that it
		only operates on the first eight screen colors.  Screen
		Color Requester solves this problem for AGA Amigas by
		providing palette controls that allow you to change, copy,
		swap, spread, and cycle all individual colors of the work-
		bench or any public screen.  You can also load and save
		modified screen palettes for various applications.  AmigaDOS
		3.0 is required.  If you are a programmer, you can link the
		included object file with your own programs and save your-
		self the work of programming a color requester of your own.
		Author:  Richard Horne

Contents of new/os30/wb
-----------------------

ProcurePens	Uses the V39 graphics.library function ObtainPen() to lock,
		or procure, a pen.  The idea here is that you call this
		program from your user-startup, so that it gets run every
		time you boot.  This way, you can have a standard setup for
		colors beyond the eight that Palette Preferences allows.
		You can lock all available pens for exclusive use, if you
		wanted to.  With the pens locked and set on startup, you can
		use those extra colors in Workbench icons (though you may
		have to use IconEdit 2.x to get them to work in 16 colors),
		Dock icons, console escape colors (multicolor CLI prompts),
		and other cool stuff.  Version 1.0, binary only.
		Author:  Joseph Luk

Contents of new/pix/illu
------------------------

TVPreview	A screen grab of a yet-to-be-released interactive 24-bit
		picture viewer called TowerView.
		Author:  Christoph Feck

Contents of new/pix/misc
------------------------

NewFromCBM	New from Commodore!  Well, ok, not quite new... But it was
		at one time... :-).  I knew that CBM used to make watches
		and calulators but I had no idea they made these things.
		Imagine my surprise when I was looking through some old
		instructions for a car computer my dad bought way back when
		and seeing this advertisement... :-)
		Author:  Geoff Seeley

Contents of new/pix/wb
----------------------

SpectrumShot	Screen shot of the author's workbench, after installing his
		new EGS Spectrum card.  It is a 1024x768 workbench screen
		with 256 colours, as you will be able to see from the open
		screenmode preferences screen.  It also has a nice pic of a
		supermodel's face in a window, has a neat WB backdrop and
		uses MagicWB icons.
		Author:  Darren Eveland  

Contents of new/text/docs
-------------------------

AGAGuide	A hardware reference manual for the AGA Chipset in Amiga-
		Guide format.  Version 1.0
		Author:  T.F.A.

Amiga-FAQ	Lists some frequently asked questions and trys to give
		answers.  Its intention is to help new users and to reduce
		the amount of news that most experienced users don't like
		to read anymore.  Sections on Hardware, Software, Program-
		ming, Applications, Graphics and more.  Formatted in plain
		ascii, AmigaGuide, DVI, and texinfo.  Version dated October
		13, 1993.  Drawer also contains some useful text files on
		ftp sites, newgroups, hardware tips and one on the history
		of the amiga.
		Author:  Jochen Wiedmann, text files from various sources

MC68060		A product brief on the MC68060 fourth-generation 32-bit
		Microprocessor.
		Author:  Motorola, Inc.

Contents of new/text/font
-------------------------

MetaFont	MetaFont is the name of a computer font generation system
		invented by Prof. Donald E. Knuth of Stanford University.
		It reads text files prepared with `programs' that specify
		the outline of characters in fonts of type, graphical
		symbols, or other elements for printing high quality docu-
		ments.  Typesetting systems like 'TeX' make use of the font
		metric information produced by MetaFont and printer drivers
		or screen previewers make use of the pixel information as
		to where to put the `ink.'  The usage of the associated
		programs is described to some detail, but no introduction
		to the MetaFont language itself is given.  Version 2.71,
		binary only.
		Author:  Donald E. Knuth, amiga port by Andreas Scherer

TimesFont	A 3-D font for Reflections 2.03+, in ready to use alpha1
		format.  Contains only the capital letters.  The full
		version including small letters, numbers and German special
		icons is available from the author.  Binary only, shareware.
		Author:  Karin Siegmann

Contents of new/text/misc
-------------------------

JemTeX		Some programs to enable Japanese typesetting.  "fontable"
		produces a Japanese file (fontable.jem) which contains all
		the available Japanese fonts in a tabular style. It has to
		be run through "Jem2tex" which produces the TeX-file
		"fontable.tex".  Finally, "jis2mf" produces .mf-sourcecode
		for Metafont and affiliated tools to generate printer-fonts
		for TeX. jis2mf reads the data from the jis24 bitmap-file.
		Version 2.00, includes source.
		Author:  Francois Jalbert, amiga port by Wilfried Solbach

JISConvert	This simple mouse driven conversion program can convert
		Japanese language text between a variety of formats.
		Formats supported are: EUC (Extended Unix Code), New JIS,
		Old JIS, NEC JIS, and Shift JIS.  Program also has options
		to convert half width katakana to full size and to repair
		New JIS files that have had the ESC characters stripped
		off.  Version 1.02E, binary only.  Requires OS2.0+.
		Author:  Dwight Hubbard

Contents of new/text/print
--------------------------

2Print		A simple little utility for HP Laserjets and other printers
		that support the HP-PCL language.  It's only goal in life is
		to print either one 166 chars x 66 line page, or two 80 x 66
		line pages per sheet.  Does not go through printer.device,
		but rather the output from 2Print is redirected to a file
		or PAR: for faster printing.  Version 1.0, binary only.
		Author:  Rajesh Goel

ADInlay		Cassette Inlay card maker, very simple and easy to use.
		Up to 12 tracks per side, optional numbering and Auto-
		capitalization.  Requires OS2.x+.  Version 1.06, binary
		only.
		Author:  Andrew Dowds

CassLabel	An MUI based application to print out cassette covers in
		ASCII format or directly with LaTeX.  Supports locale
		library.  Version 1.2, binary only.  Requires MagicUser-
		Interface, by Stefan Stuntz.
		Author:  Dirk Nehring

FishCover	A 1536 by 1536 pixel 16 color bitmap that you can print out
		and place inside the cover of the FreshFish CDROM.
		Author:  Iljitsch van Beijnum

HP4Driver	An HP LaserJet 4 printer driver with support for 600 dpi
		and bitmap compression.  Version 35, version 8.  Binary
		only.
		Author:  Kelly Jordan

VirtPrinters	Two new printer drivers.  One shows the printer output on
		a screen and the other saves it as IFF pictures.  These
		drivers emulate a page-mode printer, like a laser printer.
		They both support color and b&w modes.  Color mode uses
		three bitplanes, while b&w uses only one.  Several density
		settings available, some correspond to the Amiga's aspect
		ratio, but most are just 1 to 1.  Screen_Printer requires
		a great deal of chip ram at the higher density settings.
		Both require AmigaDOS 2.04.  Version 2, won't crash under
		3.0 anymore.  Includes source.
		Author:  Garrick Meeker

Contents of new/text/show
-------------------------

TextRead	A fast but quite simple ascii reader, which was designed
		to replace More or PPMore.  The text output is very fast,
		since the program writes directly into it's screen memory.
		The program supports printing, different tabsizes, fonts
		and screen modes.  The search routines uses local.library,
		if present, so the case insensitive search works in Sweden
		too... Requires OS 2.04, ReqTools.library v37+ and Power-
		Packer.library v35+.  The two libraries are included.
		Version 37.20 release 1.04_, an update to version 37.16
		release 1.03, on disk number 767.  Binary only, freeware.
		Example usage given with reading the doc file, instead
		of using the standard "More" file reader.
		Author:  Martin Blom

xMore		xMore is another replacement for "More" with the following
		features: Very small; Fast!; Can read XPK-packed textfiles;
		Can read PowerPacked textfiles; Can read HEX-files and
		can toggle between HEX and ASCII modes.  Version 1.1,
		requires OS2.04+, binary only.  Example usage given with
		reading the doc file, instead of using the standard "More"
		file reader.
		Author:  Jorma Oksanen

Contents of new/util/arc
------------------------

UnTar		A very simple CLI utility to unpack archives generated by
		the Unix TAR program or equivalent.  It has not been
		extensively tested, but should work for most, if not all,
		TAR files.  Includes source.
		Author:  Andrew Church

uuInOut		A pair of very rapid uuencode/decoders.  They beat anything
		currently available on aminet by a good margin, especially
		on decoding.  Very fast, pure, small and 100% assembly.
		Automatically detects and takes advantage of 68020+.
		Requires Workbench 2.04+.  Version 1.01, binary only.
		Author:  Nicolas Dade

Contents of new/util/blank
--------------------------

GBlanker	Garshneblanker is a complete modular screen blanking package
		designed with AmigaDOS 2.04+ in mind.  This software takes
		advantage of all the new features of ADOS 2.04+ in order to
		make it as upwardly compatible with new releases as pos-
		sible.  Features:  Screen Mode Database use in each module;
		Full Commodities interface; Font sensitive window; Public
		screen support; GadTools interface; IFF Preferences files;
		Use of tool types to support global and local prefs;
		AppWindow support; AGA Support in all modules! (Beautiful
		256 color displays)  Release 2.7, includes source.
		Author:  Michael D. Bayne

SuperDark	A screen blanker with some special features.  It is similar
		to the AfterDark screen blanker in the PC and Mac worlds.
		Features include a lot of different screen effects via
		"modular" screen blankers, a screen locker, and more.
		Version 2.0B, and update to version 1.5 on disk number 858.
		Requires OS2.04+.  Includes example screenblanker source.
		Author:  Thomas Landspurg

Contents of new/util/cli
------------------------

ADoc		A help utility for the Amiga.  Features include automatic
		search of any work on which you clicked, ability to use
		Auto-Doc and AmigaGuide files, support of locale.library,
		an AREXX port, and more.  Version 3.05. an update to ver-
		sion 3.01 on disk number 875.  Binary only.
		Author:  Denis Gounelle

ReqASK		A powerful mouse-driven replacement for the shell command
		ASK.  ReqASK gives you a large palette of features to
		customize to fit your needs, by allowing you use ReqTools
		requesters from scripts.  Aside from the normal features
		known from other requester ask commands such as body text,
		gadgets, font and similar things, ReqASK offers you two
		unique special features: Timeout (your requester will close
		automatically when the time limit expires) and IDCMP
		(requester can close on IDCMP events such as DISKINSERTED
		and DISKREMOVED).  Version 1.0, binary only, shareware.
		Author:  Marc Heuler

Splitter	Can split any file into a given number of files with equal
		size or several files with given size and can join those
		automatically to the original file again.  Works now with
		MS-DOS computers.  Binaries for amiga, MS-DOS and SUN sparc
		included.  Version 1.21, includes source.
		Author:  Martin Schlodder

Contents of new/util/conv
-------------------------

Convert		A flexible file conversion utility.  It covers the appli-
		cation domain of any ASCII file conversion tool between the
		Amiga and any other computer system.  In addition, Convert
		is freely configurable, so that it can be used for any
		conversion problem.  Includes scripts for Amiga, Mac, PC
		and Commodore 64 & 128 machines.  Version 2.01, binary only.
		Author:  Rainer Koppler

Contents of new/util/dir
------------------------

ABCDir		A versatile and easy to use directory utility.  It goes into
		LHA archives, it makes good use of file comments, it has
		definable filetypes, it's quick, it has a shell, it slices,
		it dices and it even makes soup!  Version 3.0, binary only,
		shareware.
		Author:  Marc Dionne

Contents of new/util/edit
-------------------------

EdWordPro	A fully featured and fully operational text editor which
		offers all the standard features of any decent editor as
		well as the ability to hold up to 15 documents in memory,
		a Macro facility, Keyword Text Casing (i.e. editor will
		automatically force keywords into upper/lower case etc);
		The ability to send AmigaDOS commands; 12 possible screen
		resolutions; A full ASCII table; Powerful search routines;
		Vertical Blocks; A built in calculator; A Word Count; The
		ability to sort a piece of text alphabetically .. and much
		more.  EdWord can be used to edit binary files as well as
		plain vanilla texts and as such becomes a competent file-
		based editor (like NewZap).  Version 4.1 is a demonstration
		release and is an update to demo release 4.0 on disk number
		924.  Binary only.
		Author:  Martin Reddy

Contents of new/util/libs
-------------------------

PPLib		A shared library to make life easy for people who wish to
		write programs that support PowerPacker.  Loading crunched
		files from C or assembly is made fast, short and easy.  This
		is release 1.6, an update to release 1.5 on disk number 678.
		Includes example source.
		Author:  Nico Francois

Contents of new/util/misc
-------------------------

AboutClock	A little WorkBench clock giving you "About" the right time!
		Do you remember the good old days when you asked someone the
		time and they  said, "It's nearly five" and not "It's 4:57
		and 28 seconds" ?  Well now there is a Workbench clock that
		does just that!  Now able to tell the time in a number of
		different European languages thanks to the efforts of Daniel
		Amor who provided the idea and translations.  Version 3.00,
		binary only.
		Author:  Stuart Davis

ACTool		An integer conversion tool from/to hexadecimal/decimal/octal
		/binary.  Both Workbench and CLI interface.  Compatible with
		OS 1.3/2.x/3.x.  Includes documentation in both french and
		english.  Version 1.0, binary only.
		Author:  Laurent Papier

AudioScope	A real-time audio spectrum analyzer for the Amiga.
		AudioScope uses a 512 point Fast Fourier Transform
		(FFT) to process audio data received through your
		audio digitizer to produce a high resolution display
		of audio signal amplitude vs frequency.  AudioScope
		can be used to evaluate the frequency content of sounds
		of all kinds.  Version 3.0, binary only.
		Author:  Richard Horne

Columns		A GUI-based "paper-saving" utility.  Allows you to print
		text in columns and use various compression modes (up to
		160 characters per line and 180 lines per standard DIN A4
		page).  5.6 times more characters than in usual modes, but
		still readable.  Written completely in assembly.  Kickstart
		2.0 and 3.0 compatible, Kickstart 2.0 look, Keyboard con-
		trols and saveable settings.  Version 2.6, an update to
		version 2.5 on disk number 900.  Binary only.
		Author:  Martin Mares, Tomas Zikmund

FileX		A binary file editor which offers the following features:
		The Editwindow can be opened on any public screen and sized
		to any dimension you want;  Fontsensitivity;  Locale-support
		if you have OS 2.1 or higher.  (Englisch and German catalogs
		available at the moment);  Undo and Redo (only limited to
		your free memory);  Search and replace;  Extensive block
		functions;  Clipboardsupport;  ARexxport with more than 66
		commands and commandshell;  Printing as hexdump; `Grab
		memory' to show and modify;  Iconifies into AppWindow from
		which files can simply be dropped into and edited.  Version
		1.1, binary only, shareware.
		Author:  Klaas Hermanns

Man		Man is a program to view texts and docs from Shell or WB.
		Includes a commodity version.  Localization under OS2.1+.
		Version 2.5, binary only.
		Author:  Markus Hillenbrand

RSYS		Very comprehensive system monitor.  Provides information on
		just about everything you could possibly want information
		on! (Plus some...)  Documentation in German, but program
		speaks english.  Version 1.3, includes source.
		Author:  Rolf Bvhme

RunLame		A smart degrader, more lame programs work, fixes the follow-
		ing lame coding:  not considering caches; not considering
		the location of the vbr; assuming screenmode is an old chip-
		set mode; assuming sprite resolution is lores; turning off
		sprite DMA in the wrong way.  Comes with a GUI and lots of
		user-friendly features.  Also includes RunLameInfiltrator,
		which enables you to permanently fix lame programs.  Version
		1.32, has passed an extremely careful beta-testing.
		Author:  Bilbo the first

Set040		A 68040 MMU Mapping & Cache Control program.  The program
		is now fully capable of surviving a reboot on a KICKROM
		setup.  It is able to trap attempted writes to kickstart,
		and completely recover and prevent the software failure.
		The various help and info options are now much easier to
		remember and understand, and are also much more informative.
		Version 2.41, binary only.
		Author:  Nic Wilson

VCLI		Voice Command Line Interface will execute CLI commands,
		ARexx commands, or ARexx Scripts by voice command.  VCLI
		allows you to launch multiple applications or control any
		program with an ARexx capability entirely by spoken voice
		command.  Many improvements requested by users are now
		included.  VCLI now has its own ARexx port so that its
		internal options and functions can be controlled by ARexx
		command.  Documentation is provided in AmigaGuide format.
		Audio digitizer support includes Perfect Sound 3, Sound
		Magic (Sound Master), DSS 8, and Generic digitizers.  Runs
		well under either AmigaDOS 2.0 or 3.0.  Version 7.04, An
		update to version 7.0 on disk number 898.  Binary only.
		Author:  Richard Horne

Contents of new/util/moni
-------------------------

IconTrace	Allows you to monitor what the icon library is doing when
		you start a program using the Workbench.  It's main use lies
		in discovering undocumented ToolTypes and debugging your
		existing ToolTypes by watching if the program finds them
		correctly.  You are also shown what icons/tooltypes your
		programs look for.  Currently monitors the following
		functions: FindToolType; GetIcon; GetDiskObject; MatchTool
		Value; GetDiskObjectNew; PutDiskObject; GetDefDiskObject;
		PutDefDiskObject; PutIcon.  You can specify which functions
		IconTrace should monitor.  Version 2.00, binary only.
		Author:  Peter Stuer

Contents of new/util/mouse
--------------------------

MouseShift	Translates the middle mouse button into the left shift key.
		This allows easy multiple selection.  Note that programs
		that use the middle mouse button directly will no longer
		recognize it.  MouseShift requires at least AmigaDOS 1.2
		to run, but will run as a commodity under AmigaDOS 2.04
		or greater.  Version 2.1, contains a bug fix that allows
		it to now work under OS3.0.  Public domain, includes source.
		Author:  Garrick Meeker

Contents of new/util/pack
-------------------------

xpkdisk   	`xpkdisk.device' is an exec-style device that looks like
		trackdisk.device and similar disks.  The difference is that
		it compresses its data and stores it in multiple files in
		an existing filesystem.  It uses the XPK (eXternal PacKer)
		standard to do the actual compression.  Version 37.5,
		includes source.
		Author:  Olaf Seibert

xpkHFMN		A dynamic Huffman xpk compression library, a rewrite of
		xpkHUFF.library.  It's 100% 68000 and pc-relative & re-
		entrant, and it's FAST, and when I say fast, I mean REALLY
		fast.  It is not a replacement for HUFF but a further
		library called HFMN because the algorithm used is not 100%
		identical to the one of HUFF, therefore the HFMN data will
		not decrunch with HUFF and vice versa.  Version 1.16, binary
		only.
		Author:  Martin Hauner

xpkSHRI		An XPK packer sub-library that implements a high compression
		rate, optimized compressor.  The compressor uses offset/len
		encoding with adaptive arithmetic aftercoding for best comp-
		ression results.  Its compression rate is better than that
		of most other packers, e.g. lha, zoo or powerpacker.
		Version 1.0, binary only.
		Author:  Matthias Meixner

Contents of new/util/wb
-----------------------

TauIcons	28 new icons for MagicWB users.  Icons in MagicWB scheme for
		ASwarm, Spliner, Rotor, Yak, Lacepointer, ToolManager Prefs,
		Reqtools Prefs, BattMem Prefs, SunClock, TopCPU, DSD, Lens,
		MultiPlayer, MTool, CatEdit, FileX, EditKeys, CyberCron,
		X-Comm, HDToolBox, Degrader, DiskSalv, SuperDuper, ReOrg,
		HFT and UChess.
		Author:  Osma Ahvenlampi
============================================================================

Name and	____________________________________________________________

Address		____________________________________________________________

		____________________________________________________________

		____________________________________________________________

		____________________________________________________________



Phone Numbers:	Home: ________________________ Work: _______________________
(optional)
		FAX:  ________________________

Email Address:  ____________________________________________________________


============================================================================

QUANTITY    DESCRIPTION					UNIT COST      TOTAL


________    Previous CDROM(s): _______________________     $29.95    _______
	    (quantity limited)

________    Fresh Fish CDROM(s);   ______ each release	   $19.95    _______
	    Start with: [ ] next
			[ ] other:_______________

________    Quarterly "On-line Edition" CDROM(s)	   $19.95    _______
	    (available starting approximately Feb 1994)

________    1000 disk "On-line Edition" CDROM		   $19.95    _______
	    (available approximately Feb 1994)

________    Hypermedia Version 1.7 CDROM		   $19.95    _______
	    (floppy disks 1-900, quantity limited)

						     SUB-TOTAL =>  _________

Add $3 per CDROM for shipping and handling if within USA,
  Canada, or Mexico.					       =>   +_______
Add $5 per CDROM for other destinations (sent airmail).

						         TOTAL =>  _________


============================================================================

SELECT PAYMENT METHOD DESIRED:

[]  Cash, check, money order, or international bank draft enclosed.
    (Must be payable in U.S. dollars)

[]  VISA or

    Full Name on Card:  ____________________________________________________

    Amount to Charge:  $__________

    I understand that the total amount shown above will be charged to
    the above described account upon receipt of order, and that in the
    event that not all of the requested CDROMs are received in a timely
    manner, any unused portion will be fully refundable upon demand.

    Sign Here: __________________________________________


============================================================================

Send or FAX your completed order to:	Amiga Library Services
					610 N. Alma School Road, Suite 18
FAX: (602) 917-0917			Chandler, AZ  85224-3687
(no voice phone orders, FAX only)	USA

============================================================================

--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.

====================================================================
This is part of a mailing list gateway maintained by Carlos Amezaga.
Bugs, Comments, Subscribes and UnSubcribes should be sent to
announce-request@cs.ucdavis.edu.



