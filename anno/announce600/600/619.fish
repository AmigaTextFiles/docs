From megalith!overlord@uunet.UU.NET Sun Nov 28 15:33:16 1993
Received: from relay2.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.4)
	id AA17376; Sun, 28 Nov 93 15:33:10 PST
Received: from spool.uu.net (via LOCALHOST) by relay2.UU.NET with SMTP 
	(5.61/UUNET-internet-primary) id AB25011; Sun, 28 Nov 93 18:33:04 -0500
Received: from megalith.UUCP by uucp5.uu.net with UUCP/RMAIL
	(queueing-rmail) id 183154.11643; Sun, 28 Nov 1993 18:31:54 EST
Received: by megalith.miami.fl.us (V1.16/Amiga)
	id AA02zci; Sun, 28 Nov 93 14:48:12 EST
Date: Sun, 28 Nov 93 14:48:12 EST
Message-Id: <9311281948.AA02zch@megalith.miami.fl.us>
Sender: errors@megalith.miami.fl.us
Errors-To: errors@megalith.miami.fl.us
Warnings-To: warnings@megalith.miami.fl.us
Return-Path: errors@megalith.miami.fl.us
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Reply-To: fnf@cygnus.com (Fred Fish)
Message-Number: 619
Newsgroups: comp.sys.amiga.announce
From: fnf@cygnus.com (Fred Fish) (CSAA)
To: announce@megalith.miami.fl.us
Subject: Contents of Oct Fresh Fish CD-ROM
Status: RO

This is the Contents file from the October Fresh Fish CD-ROM.  Yes, it's
a little late, but that is my fault for procrastinating so long and not
sending it out to the moderator.  -Fred

======================================================================


			    CONTENTS OF FFMCD01
			  (first monthly CD-ROM)

This file contains some overview information about the contents of the
CD-ROM, followed by a concatenation of a bunch of individual Contents files
on the CD-ROM.  There wasn't time to set up a better method for this first
CD-ROM to find specific programs or types of programs.  This situation
*will* get better with future CD-ROM's.


STRUCTURE OF THE CD-ROM
-----------------------

The current structure of the CD-ROM closely follows the initial concept for
the monthly CD-ROM's, being divided into roughly three sections: (1) New
material, which includes the material from the new unreleased floppy disks
as well as material which does not appear in the floppy distribution, (2)
useful utilities that can be used directly off the CD-ROM if desired, thus
freeing up the corresponding amount of hard disk space, and (3) older
material from previous released floppy disks or CD-ROM's.

The portion of the disk dedicated to new material that I've not previously
published on a CD-ROM or floppy disk is 84Mb, broken down as follows:

	 7Mb	Archived (bbs ready) contents of disks 911-930
	16Mb	Unarchived (ready-to-run) contents of disks 911-930

	21Mb	Archived "new material" not in floppy distribution
	40Mb	Unarchived "new material" not in floppy distribution

The portion of the disk dedicated to a bunch of useful tools like GNU
utilities, TeX with lots of fonts, and other interesting software that will
be updated on a monthly basis, is 150Mb, broken down as follows:

	  3Mb	Reviews of Amiga software and hardware
          4Mb	Full BSD source for supplied BSD executables.
	  8Mb	Binary executables, libraries, and other "runtime" things.
	 10Mb	Runtime support stuff for GNU emacs and GNU C/C++
	 14Mb	Distributions of various small utilities and libraries.
	 33Mb	PasTeX source, fonts, binaries, etc.
	 78Mb	Full GNU source for supplied GNU executables.

The portion of the disk dedicated to old material is 404Mb, broken down as
follows:

	257Mb	Unarchived contents of floppy disks 600-910.
	147Mb	Archived (bbs-ready) contents of floppy disks 600-910.


GNU CODE
--------

Here are the current GNU distributions which are included in both source
and binary form.  In most cases, they are the very latest distributions
ftp'd directly from the FSF machines and compiled with the version of gcc
included on this CD-ROM.  I have personally compiled all of the GNU
binaries supplied on this CD-ROM, to verify that the compiler (version
2.4.5) is solid and that the binaries are in fact recreatable from the
supplied source code.

bc	    diffutils	flex	    grep	make	    tar
binutils    doschk	gas	    gzip	patch	    termcap
bison	    emacs	gcc	    indent	perl	    texinfo
cpio	    fileutils	gdbm	    ispell	sed	    textutils
dc	    find	gmp	    m4		shellutils  uuencode
	
Here is an "ls -C" of the binary directory which can be added to your path
to make these utilities, as well as utilities from the Useful/dist/other
directories, usable directly off the CD-ROM, once it is mounted:


AD2HT	     bc		  doschk       indent	    paste	 test
ARTM	     bison	  du	       info	    patch	 texi2dvi
AZap	     brik	  echo	       install	    pathchk	 texindex
AmigaGuide   bsd-make	  egrep	       ispell	    pr		 touch
DiskSalv     bsplit	  emacs	       join	    printenv	 tr
ExpungeXRef  c++	  env	       ld	    printf	 true
Installer    cat	  etags	       lha	    protoize	 unexpand
LHArc	     chgrp	  expand       ln	    ranlib	 uniq
LHWarp	     chksum	  expr	       locate	    rm		 unprotoize
LoadXRef     chmod	  false	       logname	    rmdir	 uudecode
MKProto	     chown	  fgrep	       look	    sdiff	 uuencode
MuchMore     cksum	  find	       ls	    sed		 v
NewZAP	     cmp	  flex	       m4	    sh		 vdir
PerfMeter    comm	  flushlibs    make	    size	 wc
RSys	     cp		  fold	       makeinfo	    sleep	 whoami
SD	     cpio	  g++	       mg	    sort	 xargs
SuperDuper   csplit	  gcc	       mkdir	    split	 yes
SysInfo	     cut	  gccv	       mkfifo	    strip	 zcat
WDisplay     d		  gdir	       mknod	    sum		 zoo
Xoper	     dc		  grep	       mv	    tac
[	     dd		  gunzip       nice	    tail
ar	     diff	  gzip	       nl	    tapemon
as	     diff3	  head	       nm	    tar
basename     dirname	  id	       od	    tee


Contents of Floppy Disks 600-910
--------------------------------

Because this is the first monthly CD-ROM, there are no previous monthly
CD-ROM's from which to replicate new material from previous months.  I've
elected to use the contents of floppy disks 600-910 to fill that portion of
the CD-ROM.  The next monthly CD-ROM will contain the new material from the
first one, which will squeeze out a substantial number of the older disks,
probably 600-700.  Then the next monthly after that will contain the new
material from both of the previous monthly disks, squeezing out another
batch of older disks, etc.


New/AmigaLibDisks/Disk911/Contents
----------------------------------

GadLayout	A system for laying out gadgets in a dynamic font and locale
		sensitive manner.  Note that it is not a graphical editor, but
		a set of routines for programmers to use for much greater con-
		trol in the laying out of gadgets.  Version 36.22 release 1.6
		beta, includes source and an example program.
		Author:  Timothy J. Aston

GadOutline	A shared library intended to provide programmers with a means
		of describing the general layout of a GUI in a font-independant
		manner, taking care of the details of determining the exact
		placement of the individual elements of the display and the
		drudgery of creating and managing all of the gadgets.  In addi-
		tion, it provides a very generalized mechanism for tracking
		the state of all of its gadgets to support automatic resizing
		and closing and opening of a window without loss of context.
		Includes automatic hotkey support and a vector based drawing
		module that can be used for everything from drawing frames
		around groups of gadgets to creating custom images for BOOPSI
		gadgets.  Version 2.0, includes the library, programmer support
		files and some examples.
		Author:  Dianne Hackborn

PSM		Yet Another Public Screen Program.  It was primarily written as
		a demonstration of the gadoutline.library, and is thus current-
		ly very GUIcentric - it does no command line parsing for CLI
		users or even look at its Workbench tooltypes.  On the other
		hand, it does have a very sophisticated multi-window user
		interface and allows almost complete control over the creation
		of screens.  Version 1.0, binary only.
		Author:  Dianne Hackborn.


New/AmigaLibDisks/Disk912/Contents
----------------------------------

Enforcer	A tool to monitor illegal memory access for 68020/68851, 68030,
		and 68040 CPUs.  This is a completely new Enforcer from the
		original idea by Bryce Nesbitt.  It contains many new and
		wonderful features and options and no longer contains any
		exceptions for specific software.  Enforcer can now also be
		used with CPU or SetCPU FASTROM or most any other MMU-Kick-
		start-Mapping tool.  Major new output options such as local
		output, stdout, and parallel port.  Highly optimized to be as
		fast as possible.  This is version 37.52, an update to version
		37.28 on disk number 773.  Requires V37 of the OS or better
		and an MMU.
		Author:  Michael Sinz

UUArc		UUArc is an archiving system designed to enable easy trans-
		mission of binary files/archives over communcation links only
		capable of using ASCII, such as Electronic Mail.  It encodes
		binary files into files containing only printable standard
		ASCII characters.  Written primarily for use with GuiArc to
		add UUEncoding/UUDecoding facilities to it, it takes similar
		command line options to other commonly used archiving programs.
		Version 1.1, public domain, includes source.
		Author:  Julie Brandon

UUxT		Makes the task of uuencoding and decoding simple.  You can even
		lha and uuencode multiple files in a single step!  (And vice
		versa)  Also, UUxT will decode uuencoded files that have mult-
		iple mail files and other garbage in them!  Includes UUxT-GUI,
		an intuition frontend for UUxT.  It offers all the power of
		UUxT, but from the workbench!  It has a slick, WB 2.0 style
		look, even under 1.3.  UUxT version 2.1, UUxT-GUI version 1.0.
		Binary only.
		Author:  Asher Feldman

Task		An "Expert-User" type tool for changing any tasks' priority or
		signalling a task.  C:ChangeTaskPri cannot change task priori-
		ties of non-DOS-processes and C:Break cannot signal a non-DOS
		process - 'Task' can! Requires Kickstart 2.04+.  Version 1.06,
		binary only.  Assembly source available from author.
		Author:  Tobias Ruland

Yak		"Yet Another Kommodity".  Features a sunmouse that only acti-
		vates when mouse stops, KeyActivate windows, Click windows
		to front or back, Cycle screens with mouse, Mouse and Screen
		blanking, Close/Zip/Shrink/Enlarge windows with programmable
		hotkeys, Activate Workbench by hotkey (to get at menus when
		WB obscured), Pop up a palette on front screen, Insert date
		(in various formats), KeyClick with adjustable volume, Pop-
		Command key for starting a command (like PopCLI), Gadtools
		interface.  All settings accessible from Workbench tooltypes.
		Version 1.52, an update to version 1.2 on disk number 782.
		Author:  Martin W. Scott


New/AmigaLibDisks/Disk913/Contents
----------------------------------

AssignManager	A new prefs editor which handles your custom assigns in a
		friendly, all-encompassing way.  No more fiddling with Assign
		commands in User-Startups.  Now you can use AssignManager to
		edit your list of assigns to your heart's content.  Version
		1.00, binary only.
		Author:  Matt Francis

AssignPrefs	Another program to simplify the assignments done in the startup
		sequence.  The assignment list can be edited with AssignPrefs
		and then stored for later use.  Version 1.02, includes source.
		Author:  Thomas Frieden

Moontool	A port of John Walker's moontool program for UNIX.  It gives a
		variety of statistics about the moon, including phase, dist-
		ance, angular, size and time to next full moon.  A schematic
		of the current phase is also shown as a picture.  This is
		illustrative only; the accurate phase is shown in the text.
		Now font-sensitive and will automatically use the user-defined
		system font (non-proportional).  If the font is too large, the
		program will fall-back to Topaz 8.  Version 1.1, an update to
		version 1.0 on disk number 800.  Binary only.
		Author:  John Walker, Amiga port by Eric G. Suchanek

PickStartup	Allows you to select a startup-sequence of your liking.
		Requires AmigaDOS 2.04+, includes source.
		Author:  Bill Pierpont

StickIt		A computer replacement for the ol' Post-It note.  It allows
		you to stick notes onto your screen which will be displayed
		every time you re-boot; useful to remind you of things to do.
		Features: Unlimited number of notes on screen; Notes remember
		where you left them; User-defined font name/size; User-defined
		note size; User-defined text/background colour (yep, they can
		be yellow if you want !); User-defined delay at startup to
		avoid disk thrashing; User-defined filename for note infor-
		mation.  Requires AmigaDOS 2.04+, version 1.02, includes
		source.
		Author:  Andy Dean

VirusChecker	A virus checker that can check memory, disk bootblocks, and
		all disk files for signs of most known viruses.  Can remember
		nonstandard bootblocks that you indicate are OK and not bother
		you about them again.  Includes an ARexx port.  Now supports
		SHI's Bootblock.library.  By using this library and its brain-
		file you have the ability to add new Bootblock viruses as SHI
		release new brainfiles.  Version 6.30, an update to version
		6.22 on disk 825.  Binary only.
		Author:  John Veldthuis

VoiceShell	A replacement for VCLI by Richard Horne.  It doesn't have the
		fancy graphics etc. but it seems to eat less CPU time and
		should be faster overall.  It also has some extra options.
		Version 1.11, binary only.
		Author:  Tomi Blinnikka, voice.library by Richard Horne


New/AmigaLibDisks/Disk914/Contents
----------------------------------

MainActor	A modular animation package with many features.  Modules
		included in this release are IFF-Anim 5/7/8, IFF-AnimBrush,
		PCX,IFF.  The features include playing from harddisk, playing
		animations in windows (OS3.0), timing of animations and much
		more.  The PicassoII gfx board is supported.  Version 1.16, an
		update to Version 1.0 on disk number 888.  Binary only.
		Author:  Markus Moenig


New/AmigaLibDisks/Disk915/Contents
----------------------------------

Blitz2Demo	A next generation BASIC with features borrowed from PASCAL,
		C and others.  Blitz2 can be used to program any type of
		software, from valuable applications to entertaining arcade
		games.  Features:  Full implementation of extended BASIC
		(Select..Case While..wend etc.); Support for standard IFF
		graphics, sound and animations; NewTypes similar to C Struct-
		ures making Blitz2 more than just another BASIC; In-line macro
		assembler for advanced users; Linked list support for quick
		database type programming; Standard Amiga screen, window, menu
		and gadget management commands; Full access to the internal
		Amiga libraries and structures; Power-Windows type user inter-
		face generator... and much, much more!  Demo version with the
		the "create executable" option disabled.  Lots of examples,
		but very little documentation.  Version 1.00, binary only.
		Author:  Mark Sibly

ScreenSelect	A commodity to change screen order by selecting a screen name
		from a listview.  Also allows binding of hotkeys to any screen
		with a proper name.  Supports automatic activation of windows
		(remembers last activations) when changing to new screen, is
		configurable with Preferences program, has a full intuition
		interface and is font sensitive (including proportional fonts).
		Documentation in AmigaGuide, ASCII and DVI formats.  Requires
		AmigaOS 2.04 or later.  Version 2.0, binary only, freeware.
		Author:  Markus Aalto

StatRam		A very fast, very recoverable ram drive.  It works on any Amiga
		using V2.04 or greater of the OS.  It maintains the remarkable
		recoverability of the original VD0:, but has now been totally
		re-written to handle any DOS filesystem, be named what you like
		and give back memory from deleted files instantly.  Based on
		ASDG's 'VD0:'.  Version 2.1, an update to version 1.5 on disk
		number 871.  Binary only.
		Author:  Richard Waspe, Nicola Salmoria


New/AmigaLibDisks/Disk916/Contents
----------------------------------

ChangeMode	A utility for people who would like to change the mode (screen-
		type) and displaysize (overscan) of a picture or animation.  An
		animation, made in f.i. a doubblescan resolution, can be forced
		into any other (genlock-compatible?) mode, and complete direc-
		tories of pictures can be changed to any mode available.  This
		utility uses the information from the graphics database to be
		able to ease your choice.  Version 1.0, binary only.
		Author:  Ekke Verheul

ChemBalance	An ARexx script to balance unbalanced chemical equations.  With
		ChemBalance in ram, enter "rx ram:ChemBalance" from a CLI or
		Shell window.  A prompt should appear from which you can enter
		an unbalanced chemical equation for ChemBalance to try to
		balance.  Version 2.0, an update to version 1.0 on disk number
		759.  Requires ARexx.
		Author:  Patrick Reany

MathPlot	A function plotter with lin/log plot, a complete KS 2.0 inter-
		face, and ARexx support.  Needs Kickstart/WorkBench 2.0 and
		mtool.library (included).  Version 2.07, an update to version
		2.01 on disk 849.  Shareware, source available from author.
		Author:  Ruediger Dreier

Rego		Registration Manager.  A style of AddressBook/Database that
		allows you to keep track of multiple registrations.  Useful
		for Shareware authors, for example.  Also allows an optional
		comment.  Version 1.01, shareware, binary only.  Source
		available from the author.
		Author:  Paul Mclachlan

ScreenMode	A ready-to-link SAS-objectfile with a nice ScreenModeRequester.
		Features include programmable property-lists, font-sensitivity,
		screensize-sensitivity and autocenter.  Easy to use and pretty.
		Freeware for WB2.0+ Public Domain software.  Includes the
		object, headerfile, C-example and autodocs.  Source available
		from author.  Version 1.0, tested with WB2.0 - WB3.1.
		Author:  Ekke Verheul

TrashMaster	A Workbench 2.x AppIcon to "drag-and-drop" delete files.
		Deletes any files and directories (and the files in them)
		who's icon(s) are dropped into the Trashmaster AppIcon.  Files
		can be deleted interactively, with confirmation on each file
		(delete, all, abort, and skip).  Disks will be formatted.
		Version 1.6, binary only.
		Author:  Aric R Caley

WBrain		A thinking game for the WorkBench.  The player must reproduce
		a random pattern by filling in a grid in the correct order.
		The difficulty ranges from moderately easy to impossible.  Uses
		very little CPU time and very little memory, so is ideal for
		playing while raytracing, etc.  Requires OS2.0+, Version 1.2,
		Amiga_E source code included.
		Author:  Sean Russell.

Worms		A monitor-polite ScreenBlanker and InputBlocker.  Very useful
		where the (WB2.0+) Amiga resides in a public place.  Blanking
		is not automatically activated by elapsed time, instead, it
		must be activated and de-activated by hand.  While blanking
		(the program's name "Worms" will become obvious) and all input
		will be blocked until the secret key combination is pressed.
		Version 1.0, source available from author.
		Author:  Ekke Verheul


New/AmigaLibDisks/Disk917/Contents
----------------------------------

AUSH		A command line interpreter for the Amiga.  Features include
		file name completion, pattern expansion, expression computa-
		tion, command history, for...done loops, full support of Ami-
		gaDOS 2.0, and much more.  Almost fully compatible with ARP
		and Commodore shells.  This is version 3.15, an update from
		version 1.52 on disk 747.  Binary only.
		Author:  Denis Gounelle

CardPack	Two IFF pictures of a nicely drawn standard playing deck of
		52 cards, for evaluation purposes (640x400) format.  Usage in
		your own programs requires registration which also entitles
		you to the Joker plus the (640x200) set of cards.  Version 1.0.
		Author:  Jim Schwartz

MandelMania	A fast Mandelbrot Set and Julia Set calculation program.  The
		main features are: Create animations automatically via ARexx
		script file; 2.5 times faster than MandFXP; On-line help using
		amigaguide.library; Supports all Amiga graphic modes, incl.
		AGA modes and autoscroll screens; Loading and saving using IFF
		format.  Picture parameters are stored in a special chunk;
		Supports Mandelbrot Set LSM, Julia Set LSM, Mandelbrot Set CPM
		(two- and three- dimensional), Julia Set CPM (two- and three-
		dimensional), Lyapunov Space;  Colormap can be changed; Built
		in colorcycling; Easy scrolling by pressing the cursor keys.
		Version 4.1, requires Kickstart 2.1 (V38+ of asl.library),
		binary only.
		Author:  Markus Zehnder

PhoneBill	A logfile analyser.  What it basically does is scan the log-
		file(s) generated by a terminal program or a mailer, extract
		all information about calls you have made by using your modem,
		and stores it in its own (short) format.  Features:  User-
		definable callrates;  Supports logfiles generated by MagiCall,
		NComm, TrapDoor, Term, and Terminus;  Automatic logfile trun-
		cating; Generates miscellaneous reportsm statistics, total
		costs.  Requires Kickstart 2.04 or higher, nice GUI and sup-
		ports new 3.0 features (new look menus, ...).  Version 1.08,
		binary only.
		Author:  Raymond Penners

PiCalDemo	Demo version of a  calendar program which allows you to view
		a selected month and year.  What makes PiCalDemo unique is the
		ability to display pictures.  Since this is a demo, only one
		picture is displayed.  The fully working version, PiCal, dis-
		plays a different picture for each month of the year.  Version
		1.00, binary only.
		Author:  Greg Suire

VTimer		A simple stopwatch timing display that can be used to time
		video events if genlocked over a scene.  Version 1.00, binary
		only.
		Author:  Greg Suire


New/AmigaLibDisks/Disk918/Contents
----------------------------------

Multiplot	An intuitive data plotting program featuring flexible input
		options, arbitrary text addition, automatic scaling, zoom
		and slide with clipping at boundaries, a range of output file
		formats and publication quality printed output.  Workbench
		printers are supported via transparent use of the PLT: device.
		Postscript and HP Laserjet printers are directly supported.
		Version XLNf v1.06, an update to version XLNe on disk 572.
		Binary only.
		Author:  Alan Baxter, Tim Mooney, Rich Champeaux, Jim Miller

WBVerlauf	Allows the owners of AGA machines to create a nice Copper
		background for a selectable color, using the whole 16 million
		color range of the AGA chips.  By specifying the color of the
		first and the last line of the screen, WBVerlauf will make a
		smooth color change by setting a new color value on every
		scanline.  Now a commodity and allows editing 24-bit rainbow
		copperlists in realtime.  Requires Kickstart 3.0 and AGA.
		Version 2.0, binary only.
		Author:  Christian A. Weber


New/AmigaLibDisks/Disk919/Contents
----------------------------------

BBBF		The Bootblock.library and brainfile is now used by several
		programs e. g.: D-Copy 3.1, X-Copy from april 93 and Virus-
		Checker from version 6.29.  Intended for use by programmers
		of anti-virus utilities, diskcopy program, directory utili-
		ties, disk packers and for whoever who wants to check the
		bootblock of some device.  The library has some easy-to-use
		functions to read the brain-file, and to check a bootblock
		with it.  Version 101_31, an update to version 0.95 beta on
		disk 797.  This brainfile now recognizes 163 different boot
		viruses and about 70 boot virus clones.  Includes sample
		source.
		Author:  Johan Eliasson, Safe Hex International member.

Look		A powerful program for creating and showing disk magazines.
		Supports IFF pictures, IFF brushes, ANSI, fonts, PowerPacker,
		and many more features.  Programmed in assembly language to
		be small and fast.  German language only.  Version 2.0, an
		update to version 1.9 on disk 892.  Shareware, binary only.
		Author:  Andri Voget

Qdir		Enhanced replacement for AmigaDOS' LIST and DIR commands.
		Qdir lists files in alphabetical order displaying all file
		and directory statistics like the LIST command.  The result
		is a nice orderly listing that makes it easy to find what
		you are looking for.  Version 1.36, requires AmigaDOS 2.0,
		Kickstart version 37 or higher.  Binary only.
		Author:  Gregg Scholfield

QuickFile	A flexible, fast and easy to use flat file database using
		random access with intelligent buffering to minimize disk
		access, multiple indices for fast access to records, form
		and list style screens and reports, and fast sorting and
		searching.  Files are quickly and easily defined, and fields
		can be added, changed or deleted at any time.  Now supports
		up to 255 fields per record, date data types and ASCII file
		import and export.  Version 1.3.3, an update to version 1.2
		on disk number 820.  Binary only, shareware.
		Author:  Alan Wigginton

Touch		Another Amiga version of the Unix utility with the same name.
		Touch changes the date and time stamp of all specified files
		to the current date and time.  This version will also create
		an empty file (like the Unix version) if the specified file
		does not exist.  Version 1.0, public domain, includes source.
		Author:  Kai Iske

TxtCvt		Converts PC text document (Microsoft Word for DOS/Windows or
		Windows Write) to pure ASCII format.  Version 1.0, includes
		source.
		Author:  Njel Fisketjxn


New/AmigaLibDisks/Disk920/Contents
----------------------------------

AmigaGuide	Archive distribution of the AmigaGuide hypertext utility direct
		from Commodore.  Contains developer examples and tools for
		AmigaGuide under V34/V37 and V39, plus a new free print/sign/
		send-in distribution license for AmigaGuide, amigaguide.lib-
		rary, WDisplay, and their icons.  An update to the version on
		disk number 870, contains: AmigaGuide 34.3, amigaguide.library
		34.11, AD2AG 39.2 and WDisplay 34.1.
		Author:  Commodore Business Machines

BBSGuard	A program which will monitor the phone ringing, monitor carrier
		detect, disable Guru Meditations, auto-cancel all requesters,
		and if a volume is validating, pause the system until it is
		done.  Version 2.03, binary only.
		Author:  Darrell Grainger

BigAnim		An animation player capable of "direct from disk" playback,
		with user selectable buffer size and playback speed.  BigAnim
		can display IFF ANIM animations of types 5 and 7, and makes
		use of the new graphics.library double-buffering routines when
		run on an Amiga with Kickstart 3.0 or later.  Version 3.3,
		requires Kickstart 2.04 or higher.  Binary only.
		Author:  Christer Sundin

PcRestore	A utility for those people who want to transfer files between
		MSDOS-machines and the Amiga.  Handles disks  'BACKUP'ed under
		DOS 3.30, 4.X, 5.X.  (Perhaps lower version's but untested)
		Requires OS2.0, ReqTools.library, and a method to read MS-DOS
		disks (Crossdos filesystem or similar).  Version 2.40, binary
		only.
		Author:  Mikael Nordlund

Report		The Amiga "Report" program is to be used for generating all
		Amiga bug reports and enhancement requests.  V40.1 adds sub-
		system changes (to match our current database) and also some
		automatic detection of debugging tools running on your system
		for insertion into bug reports (you may change this list to
		match the tools you were running at the time the bug happened).
		Author:  Commodore Business Machines

TypeSmithDemo	A sneak peek at Soft-Logik's new font editor.  All features
		are enabled except Save, Save As and Export.  TypeSmith can
		create and edit PostScript, Compugraphic and Soft-Logik out-
		line fonts (the three primary font systems used on the Amiga).
		TypeSmith has powerful drawing tools to allow you to create
		new fonts.  You can also import characters and symbols from
		structured drawing programs such as Art Expression.  With
		these powerful features, you can create custom fonts and
		include your logo in your favorite fonts.
		Author:  Soft-Logik Publishing Corp.


New/AmigaLibDisks/Disk921/Contents
----------------------------------

CapShift	Simple commodity which turns the shift key into a 'capslock-
		toggle' key: if capslock is off, the shift key + an alphabetic
		key produces an uppercase character, as usual; if capslock is
		on, the shift key + an alphabetic key produces a lowercase
		character.  Can also disable capslock when a function key or a
		qualifier is pressed.
		Author:  Alessandro Sala

MiniGames	Two little Workbench games; MiniPac, an "Pacman" type game,
		and MiniIsola, "a head 'em off at the pass and box 'em in"
		type game.  Version 1.0, binary only.
 		Author:  Philippe Banwarth.

MiniMorph	A little morphing package written in assembler, based on VMorph
		Version 2 beta by Lee Wilkie (but nearly 50 times faster (un-
		compiled amos vs compiled (?!) assembler)).  Currently limited
		to 16-color, greyscale images.  Version 1.0, binary only.
		Includes a sample morph anim and iff files.
		Author:  Philippe Banwarth, Lee Wilkie, Michael W. Hartman


New/AmigaLibDisks/Disk922/Contents
----------------------------------

Designer	A program to create intuition interfaces for programs, at
		present producing code in Pascal and C is possible.  This
		is a demo version with a partially disabled save option.
		The program has on-line help and can create windows and
		menus, supporting all gadtools gadgets in V37.  It can also
		import IFF ILBM pictures for inclusion in your programs.
		It requires Release V37+.  Version 1.0, binary only.
		Author:  Ian OConnor

WBSearch	A multi-tasking Workbench AppMenuItem file search utility.
		The search pattern does not support pattern matching symbols,
		only matches letters in the filename in continuous order.
		Version 1.0, binary only.
		Author:  Mike Austin


New/AmigaLibDisks/Disk923/Contents
----------------------------------

bBaseIII	An easy to use, versatile, yet full featured database program
		that will run on any Amiga.  Search or sort on any field,
		print mailing labels, (un)delete records, mail merge, get
		reports in many formats, scramble files, flag records, and
		more.  Fields are user-configurable, so bBase can be used
		to keep track of addresses, tape or video collections, reci-
		pe files, or anything else you can think of - one program
		does it all!  bBaseIII is a greatly enhanced successor to
		bBaseII.  This is version 1.4, an update to V1.3 on disk 878.
		Shareware.  Binary only.
		Author:  Robert Bromley

CryptoKing	A game for those who like to solve Cryptograms; those coded
		sentences that have to be decoded to be read.  Operate with
		keyboard or mouse.  This is Version 1.3, an update to Version
		1.1 on disk 710.  Shareware, binary only.
		Author:  Robert Bromley

MagicClip	A shell utility for accessing clipboard text.  Text can be
		written to or read from any clipboard unit.  Supports multi-
		hunk text and can be configured with two environment vari-
		ables.  Version 1.2, includes source in Oberon-2.
		Author:  Franz Schwarz

MagicPubName	A powerful 'getpubname' utility, that prints the name of the
		default, frontmost, or shanghai public screen to the console,
		or checks whether a public screen is frontmost, or at least
		partially visible, or whether it exists at all.  Any public
		screen may also be popped to the front.  Can also find the
		public screen of an arbitrary console.  Needs Amiga-OS 2.04
		or better.  Version 1.3a, includes source in Oberon-2.
		Author:  Franz Schwarz

OberonPrefs	A preferences editor for manipulating the compiler and linker
		options of A+L Amiga-Oberon.  Manipulates both the global
		options as well as project specific options and includes a
		comfortable interactive GUI, a powerful commandline and Tool-
		Types interface, Localization and more.  Requires Amiga-OS
		2.04 or better, takes advantage of Amiga-OS 2.1 and 3.0 if
		present.  Version 1.11d, giftware, binary only.
		Author:  Franz Schwarz

RawInsert	A utility to insert text or any other input events into the
		input stream.  Data can be either raw ascii text or commodi-
		ties input description sequences.  Requires Amiga-OS 2.04 or
		later.  Version 1.0, includes source in Oberon-2.
		Author:  Franz Schwarz

SetEnv39	A compatible substitute for Commodore's SetEnv shell command
		that takes advantage of the new OS3.0 GVF_GLOBAL_ONLY flag
		with a new SAVE/S switch which makes SetEnv39 affect global
		vars in the ENVARC: directory if you run OS3.0 or later.  Re-
		quires OS 2.04, new SAVE/S feature requires OS 3.0 to work.
		Version 39.0, includes source in Oberon-2.
		Author:  Franz Schwarz


New/AmigaLibDisks/Disk924/Contents
----------------------------------

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
		based editor (like NewZap).  Version 4.0 is a demonstration
		release and is placed in the Public Domain (binary only).
		Author:  Martin Reddy

HD_Frequency	A 'professional' hard disk recording system with many fea-
		tures.  Sampling rates as 60 khz on A1200 or 35 khz on stan-
		dard A500 are no problem any longer.  The program includes
		a 4 track hd-sequencer that manages replaying 4 tracks at
		the same time from HD.  Limited, demo version only.  This
		is version 37.142, shareware, binary only.
		Author:  Michael Bock

P-Reader	An all-purpose reader that displays texts,pictures, anima-
		tions and sounds, which may be uncompressed or compressed by
		P-Compress or PCompress2.  Texts can contain embedded static
		or animated illustrations and sounds.  Version 7.1, an
		update to V6.2 on disk 744.  Freeware, binary only.
		Author: Chas A.Wyndham

S_Anim5		Turns Anim5 animations (DPaint, Videoscape, P-Animate etc.)
		into self-contained, self-displaying, compressed files call-
		able from the Workbench or CLI.  Version 1.3, an update to
		V1.1 on disk number 885.  Freeware, binary only.
		Author:  Chas A.Wyndham

S-Exec		A simple program to turn executable command files into self-
		executing compressed (imploded) commands, functioning exactly
		as the uncompressed original.  Freeware, binary only.
		Author:  Chas A.Wyndham

S-Omni		Will turn almost anything into a self-contained self-execut-
		ing compressed file, including virtually any combination of
		a data file and an appropriate tool.  Scripts (with all the
		files called in the script), installation files, demonstra-
		tions, tutorials, can all be made completely self-contained,
		needing no special libraries or external support.  Freeware,
		binary only.
		Author:  Chas A.Wyndham

WB-Version	A "Version" command for the WorkBench.  Meant for use with
		ToolManager, allows you to see the version of a library,
		executable, etc. without having to resort to the CLI.  Ver-
		sion 1.2, now recognizes libraries, devices and is generally
		a lot more robust than the previous releases. Includes source
		in Amiga E.
		Author:  Hekan Hellberg


New/AmigaLibDisks/Disk925/Contents
----------------------------------

DonsGenies	A collection of nearly seventy "genies" (ARexx scripts) for
		use with Professional Page, plus some supporting material.
		Also includes a French language version with some additional
		material.  Version 2.0, update of Version 1.0 on Disk 724.
		Shareware, includes source.
		Author:  Don Cox, french translations by Fabien Larini

SoundMachine	Allows you to load, save, and play various sound file formats
		including RAW, IFF, VOC, and WAV.  Two versions are included:
		one with an Intuition interface and a smaller CLI version.
		Very useful for those who frequent BBS's and have access to
		these type of sound files.  Version 1.0, binary only.
		Author:  Syd L. Bolton, Legendary Design Technologies.


New/AmigaLibDisks/Disk926/Contents
----------------------------------

JcGraph		Business grapher with Intuition interface.  JcGraph can show
		your data as bar,line, planes, stack, blocks, 2D and 3D, etc.
		Features: Real-time rotation around X, Y, Z axis, on-line
		help, professionnal looking 2D and 3D graphs output.  ARexx
		interface with 40+ commands.  User manual on disk in French
		and English versions.  Can output: EPS, 3D GEO, IFF ILBM, and
		AegisDraw2000.  Version 1.13, an upgrade to version 1.100 on
		disk 760.  Now Freely redistributable (Save enabled and >3X3
		charts).  Binary Only.
		Author:  Jean-Christophe Climent

TreeTool	A public-domain link library toolkit for working with non-
		balanced, acyclic, n-ary trees.  Provides many useful func-
		tions and an easy to use, yet powerful API.  Version 1.0,
		includes full sources in 'C'.
		Author:  Jean-Christophe Clement.


New/AmigaLibDisks/Disk927/Contents
----------------------------------

EquiLog		A Master-Mind type game.  Version 1.5, an update to version
		1.36 on disk number 590.  Binary only.
		Author:  Pierre-Louis Mangeard

Finger		A quick and dirty port the unix finger utility for AmiTCP.
		Includes binary and source.
		Author:  Regents of the University of California,
			 Amiga port by William Wanders
		
FTP		A port of BSD FTP code, which runs under AmiTCP and AS225
		release 2.  Includes source for SAS-C (version 6) or Aztec
		C (version 5.2).  Binary included for AmiTCP.
		Author:  Regents of the University of California,
			 Amiga port by Mark Tomlinson & Geoff McCaughan

Telnet		A port of BSD TELNET code, which runs under AmiTCP and AS225
		release 2.  Includes source for SAS-C (version 6) or Aztec
		C (version 5.2).  Binary included for AmiTCP.
		Author:  Regents of the University of California,
			 Amiga port by Mark Tomlinson & Geoff McCaughan


New/AmigaLibDisks/Disk928/Contents
----------------------------------

AddTools	Allows you to add your own items to the "Tools" menu of Amiga
		OS 2.04's Workbench Screen.  Unlike other menu utilities,
		which only add the ability to run programs by menu, AddTools
		can also pass them some parameters on "the fly" in the form
		of icons, selected before choosing the desired menu item.
		You can also provide default values if no icons are selected,
		and you can decide if the the program must be run in either
		synchronous or asynchronous mode when multiple icon parame-
		ters are selected.  Requires OS2.04+, Version 1.11, binary
		only, freeware.
		Author:  Alessandro Sala

Annotate 	A text editor written for ADos 2.0 and up.  Takes advantage
		of Public screens and the system default font.  Features in-
		clude folding, shifting, full clipboard support, macros,
		scroll bar, editor buffering, printing, text locking, tools
		menu, and a full Arexx Port.  Fixes a bug with AmigaDos 3.0
		and the file requester.  Version 2.0, an update to version
		1.8 on disk number 751.  Binary only.
		Author:  Doug Bakewell

DefPubScreen	A little wedge that makes the front-most screen the default 
		public screen.  If the front-most screen isn't a public
		screen, nothing changes.  It wedges into the vertical blank-
		ing interrupt server chain and watches Intuition's record of
		the front most screen.  When the front-most screen changes,
		the main task is signaled and responds by making the front-
		most screen the default public screen if possible.  This is
		all totally transparent and happens very quickly, and is
		very handy for people who have separate screens for Shell
		windows etc.  Version 3.00, an update to version 2.00 on
		disk number 909.  Binary only.
		Author:  Matt Francis

MiserPrint	A print utility that puts up to 8 normal pages of text on
		one sheet of paper. You are able to save paper and time.
		MiserPrint uses the small built-in fonts (Courier and
		Letter Gothic) of the HP-Deskjet printers.  Version 1.0,
		requires Kickstart 2.04 or higher, binary only.
		Author:  Heinz-Guenter Boettger

MRChoice	MultiRequestChoice is a requester utility designed as a
		powerful and comfortable replacement for ASK and other
		present requester utilities.  It is very useful for both
		batch files and ARexx scripts.  MultiRequestChoice supports
		multi-gadget requesters, multi-line bodytext in the reques-
		ter with a center option and opening requesters on public
		screens with a position control option.  Version 1.0, re-
		quires OS2.x or higher and the reqtools.library V38+.
		FreeWare version, binary only.
		Author:  Rainer Scharnow

PriMan		A Task Priority Manager along the same lines as	TaskX, but
		fully Style Guide compliant, font-sensitive, and configur-
		able.  Requires OS2.0 or greater.  Includes C source, free-
		Ware.
		Author:  Barry McConnell

TeXFormat	Enables you to select TeX format files easily.  Scans the
		directory where your TeX format files reside and creates an
		array of radiobuttons of the appropriate size.  Moreover, 
		shows the filenotes of the format files making it easier to
		remember the purposes of the format files.  Two versions of
		the program, A very flexible one based an Stefan Stuntz's
		MagicalUserInterface (MUI) and a less nice non-MUI version
		(of the same functionality, however).  Version 2.00, includes
		source.  Also included is a 68000 version executable of
		TeXPrt that was left off of disk number 892 by mistake. 
		Author:  Richard A. Bvdi


New/AmigaLibDisks/Disk929/Contents
----------------------------------

MegaD		A full-featured directory utility.  Supports multiple direct-
		ories, multiple text/HEX reader, multiple source directories,
		multiple destination directories and disk copy.  User defined
		gadgets will launch internal, external and ARexx Commands.
		Full ARexx support with 123 commands plus user added ARexx
		commands.  User defined Menus.  User defined screen layout of
		all objects such as Gadget Sets and Directory Windows.
		Version 3.0, binary only.  Part 1 of a 2 part distribution,
		AmigaGuide documentation can be found in lha'rced form in the
		MegaD_Docs directory on disk number 930.
		Author:  John L. Jones.

WBvwm		With Workbench 2.04 we got the ability to use a bigger Work-
		bench screen than fits on the display (virtual Workbench
		screen).  Biggest problem is that scrolling around with the
		mouse is too slow, so the author decided to make a program
		like X-window's olvwm, which also has virtual screens and
		windows.  WBvwm opens up a small window representing the
		entire Workbench area.  Within the window, "objects" repre-
		sent all open windows.  By moving an object, the correspond-
		ing window can be placed anywhere within the Workbench area.
		You may also instantly move to any part of the Workbench
		area by double-clicking in the corresponding area of the
		WBvwm window.  Version 2.0, requires OS 2.04 or higher.
		Binary only.
		Author:  Juhani Rautiainen


New/AmigaLibDisks/Disk930/Contents
----------------------------------

Fonts		Two fixed-pitch fonts designed for high resolution screens.
		More readable than the standard topaz-fonts.  Public domain.
		Author:  Gerhard Radatz

MegaD_Docs	AmigaGuide documentation in lha'rced form for MegaD, a full-
		featured directory utility.  Includes script files to unpack
		to HD or floppy.  Part 2 of a 2 part distribution.  Part 1
		includes the MegaD binary and support files and can be found
		on disk number 929.
		Author:  John L. Jones.

QuadraComp	An intuition based music tracker that uses the internal sound
		capabilities of the Amiga.  Handles both Noisetracker modules
		and Extended modules.  Features: 128 kb x 256 samples; 256
		rows x 256 patterns; Uses any screenmode; Realtime spectrum
		analyser.  Requires OS 2.0+.  Version 2.0, binary only,
		shareware.
		Author:  Bo Lincoln & Calle Englund

RCON		A replacement for the CON:-Handler of Amiga-OS 2.x / 3.x.
		Has many new features including scrolling back text which
		has disappeared, enhanced copy & paste support and much
		more...  This is the demonstration distribution of a share-
		ware product.  Version 1.0, binary only.
		Author:  Gerhard Radatz


New/CLI_Util/Contents
---------------------

AddCR		Yet another Amiga/IBM text file converter, which (surprise,
		surprise) converts Amiga style end-of-lines characters ($0a)
		to IBM format ($0d,$0a) or vice versa.  Features: Should
		work on all amigas (or at least > wb1.2); Relatively small
		(11k); Extremely fast (main loop is written in optimized
		assembly); Works in low memory situations (min. memory
		requirement = 12288 bytes); Progress indicator; When con-
		verting to Amiga format, only ($0d,$0a) characters are
		converted to $0a (all $xx,$0a are left alone - where $xx
		<> $0d); When converting to IBM format, ($0d,0a) pairs are
		left alone.  Version 1.0, includes source, public domain.
		Author:  Son Le

Cout		A program that replaces the Echo command, Special characters
		(\n, \t, \f.. like in C) control the output.  In addition to
		that bold, underlined, italic and inverse text is supported.
		Version 1.00, includes source in C++.
		Author:  Harald Pehl

Dirs		A powerful new DIR command with 23 options.  Files and
		Directories can be sorted by name, size or date (ascending
		and descending), information about the size, protection-bits,
		date or comment can be hidden.  Options you use in everyday
		work can be stored in an environment variable.  The hidden
		flag is supported...  Version 1.00, includes source in C++.
		Author:  Harald Pehl

IFF2Icon	Converts an IFF/ILBM file of any size into a Icon-File or
		optionally, to the default Icon.  Requires OS2.04+.  Version
		1.0b, includes assembly source.
		Author:  Hanns Holger Rutz

Man		A simple MAN command, known from UNIX systems.  The advantage
		is that it recognizes .guide files to be AmigaGuide docu-
		ments.  MAN then uses a different viewer in order to display
		the AmigaGuide document.  You may configure MAN using envir-
		onment variables.  Configuration can be done for:  Direct-
		ories, where to look for man pages (.doc|.man|.guide), ASCII
		Textviewer, AmigaGuide Textviewer.  Version 1.2, includes
		source, public domain.
		Author:  Kai Iske

Move		Moves files from here to there.  You may issue as many source
		files as will fit on one command line, even including pat-
		terns.  Issuing directory names will cause Move to create a
		directory of the same name within the destination directory
		(if not already present) and move all the files from the
		source directory to the destination,  with all subdirect-
		ories.  Several command line options for specifying cloning,
		verbosity, replace existing, etc.  Requires OS2.x, includes
		SAS 6.3 C-source, public domain.
		Author:  Kai Iske

SplUU		A UUEncoding file splitter for emailing large files.  It
		takes a file and UUEncodes it, and then it cuts it up in
		2000 line blocks.  It also gives each block a header and
		a tail.  Includes SplUUi, a GUI version of SplUU.  Version
		1.07, binary only.
		Author:  Psilocybe Systems, Inc

Text2Guide	Text2Guide converts plain ASCII text into AmigaGuide (c)
		format.  Sticking to some simple organization of the text
		file, one can have a well structured guide file while still
		having an easily readable text file.  Version 2.00, binary
		only.
		Author:  Stephan S|rken


New/Comm/Contents
-----------------

4D-BBSDemo	A preliminary demo release of the shareware 4D-BBS V2.89d.
		In this demo version, everything works, but you are limited
		to only 5 message bases and 5 file transfer sections.  There
		is also a 30 minute time limit of being logged onto the BBS.
		Author:  CornerStone Software.

CarbonCopy	A FidoNet Technical Networks utility that will create FSC-
		0039 style packets, given a plain ASCII text file and a list
		of nodes to send netmails to.  You'll need a TrapList parsed
		NodeList to accomplish this...  Version 34.8, binary only.
		Author:  Klaus Seistrup

DCDD		Direct Connect Demon Dialer, an ARexx/BaudBandit Auto BBS
		dialer/logger.  80 BBses per phonebook.  Unlimited phone-
		books.  Selectable Auto BBS dialing.  Arexx script control
		PER BBS.  Many features and safety controls.  DCDD will
		automatically dial your chosen batch of local or distant
		BBSes, and will go through your selections as many times
		as you like, repeatedly dialing the BBSes until it connects
		with one, at which time it will beep and bring BaudBandit's
		screen to the front.  Version 1.8
		Author:  Jerry Smith

EazyBBS		A Bulletin Board System (aka Mailbox) with UUCP Network
		support.  Online help, very easy to use for sysops and
		users.  Fullscreen oriented input masks, batch-upload and
		download.  Up to 9 languages.  Requires AmigaOS 2.0+.
		Currently has only german documentation.  Version 2.11,
		binary only.
		Author:  Andreas M. Kirchwitz

EMS		Electronic Mail System.  An attempt to manage in an easy
		and uniform way an Electronic Mail System.  Unlike other
		products, EMS can be used with FIDONET technology networks
		AND with USENET-kind networks, with the same kind of inter-
		action.  The software takes care of the differences between
		networks.  Version 1.0, binary only.
		Author:  Davide Massarenti

GRn		A full-featured Intuition based Newsreader for the Amiga
		running 2.04 or above.  GRn works with AmigaUUCP, with C
		News, with TCP/IP using the C= socket.library (via NNTP),
		with DNet, with direct-connect serial connections, and with
		NFS mounted news partitions.  GRn requires release 2.04 of
		AmigaDOS, and works with 2.1, 3.0 and 3.1.  Version 2.0,
		binary only.
		Author:  Michael B. Smith, Michael H. Schwartz.

Modem		Some sample source showing how to configure modems, etc.
		without having to load a terminal program.  It can be used
		on any device or unit which acts like a serial.device.  I
		also use it for dialing up to my slip account...  Version
		1.1, includes source.
		Author:  Stephen Norris

Timer		A small utility that allows you to monitor online time with
		your favorite terminal program or really any other amount
		of time you want.  It has a logging function to keep you
		informed about former logons and can open its window on any
		screen.  V1.04, freeware.  Source in C and and AREXX script
		to start Timer from Vlt are included.
		Author:  Uwe "hoover" Schuerkamp.

TWC		Two Way Chat & Send enables you to make use of your modem's
		full-duplex feature in fact, it can save you up to 50% trans-
		mission time.  With TWC you can connect to another guy run-
		ning TWC, then you may transmit file-AND chat-data at the
		same time in both directions.  GUI-driven, requires OS2.04+.
		Version 3.22, an update to version 3.101 on disk number 904.
		Binary only, shareware.
		Author:  Lutz Vieweg


New/Develop/Contents
--------------------

fd2AsmInc       Creates assembler-includefiles  from .fd-files (I. E. the
		original Commodore .fd-files).  Features several ways to
		format the output-file.  Version 1.0b, an update to version
		1.0a on disk number 802.  Requires OS 2.04+, freeware,
		includes source in assembly.
		Author:  Hanns Holger Rutz

MAGIC		Multi-Application Graphic Image Communications.  A system of
		sharing 24-bit image data between MAGIC-aware applications.
		For example, you have loaded an image into Application A for
		editing.  You decide you need to do a special glitzy effect
		on the image, a task at which Application B excels.  Rather
		than saving the image to disk and then loading it into Appli-
		cation B, you simply run Application B, select it's "Open
		MAGIC" menu option, choose your image by name, and the image
		appears in Application B ready for your effect.  When you're
		done, you simply quit Application B and you may return to
		Application A where the image sits, glitzed and effected.
		Author:  Nova Design, Inc

Math68hc11	A set of PD math functions for the 68HC11.  Includes real
		FFT, Floating point, Long divide.
		Author:  John Moran, Ron Williams, James C. Shultz, D G Weiss

MCX11		A MicroController eXecutive for the MC68HC11.  MCX11 is
		an efficient software framework for embedded real-time
		applications using the Motorola MC68HC11 microcontroller.
		Features include: Multitasking for up to 126 tasks; Pre-
		emptive task scheduling by priority; Intertask communica-
		tion and synchronization via semaphores, messages, and
		queues; Support for timed operations; Fast context switch;
		Very small RAM and ROM requirements; Fifteen Executive
		Service Request functions.  Version 1.3, Includes source
		in AS11 form.
		Author:  A.T. Barrett & Associates

MUI		An object oriented system to create and maintain graphical
		user interfaces.  From a programmers point of view, using
		MUI saves a lot of time and makes life much easier.  Think-
		ing about complicated terms like window resizing or font
		sensitivity is simply not neccesary.  On the other hand,
		users of MUI based applications have the ability to custom-
		ize nearly every pixel of a program's interface according
		to their personal taste.  Version 1.3, includes developers
		support package and several demos.  Shareware.
		Author:  Stefan Stuntz

UMBScheme	A port of UMB Scheme 2.5 to the Amiga.  Scheme is a Lisp-
		like programming language with procedures as first class
		data, static scoping etc.  UMB Scheme 2.5 supports long
		integers of (almost) arbitrary length.  Compiled using DICE
		C 2.07.54R with the dynamic stack feature of DICE.  The
		interpreter will allocate stack space automatically.
		Author:  Various, amiga port by Thorsten Greiner

Yacc		This is a port of Berkeley Yacc for the Amiga.  This Yacc
		has been made as compatible as possible with the AT&T Yacc,
		and is completely public domain.  Note that it is NOT the
		so-called Decus Yacc, which is/was simply a repackaging of
		the proprietary AT&T Yacc.  Specialties of this version:
		compiled with DICE 2.07.54R (doesn't need ixemu.library);
		AmigaDOS version string; dynamic stack.  Version 1.9, an
		update to the version on disk number 419.
		Author:  Bob Corbett, Ingo Wilken, et. al.


New/DiskTools/Contents
----------------------

AntiRaBB	This program installs a bootblock that displays the text
		'Against racism' or 'Gegen Rassismus' (German version)
		along with a Yin & Yang symbol.  Version 1.0d, an update
		to version 1.0b included in the AntiRascism package on
		disk number 894.  Freeware, includes both English and
		German version.
		Author:  Hanns Holger Rutz

CDTV-Player	A utility for all those people, who'd like to play Audio
		CD's, while multitasking on workbench.  It's an emulation
		of CDTV's remote control.  Recognizes CDs automatically.
		AREXX-Port for usage in other programs.  Program, Shuffle
		and Karaoke.  Enhanced features for adding CDs.  Now uses
		less processing time.  Version 2.20, an update to version
		2.05 on disk 894.  Docs in English, Frangais & Deutsch.
		Supports CDTV, AMIGA CD 32 & XETEC-Drives.  FISH-WARE,
		binary only.
		Author:  Daniel Amor

ReOrg		ReOrg is a fast disk optimizer that can be used for floppy
		disks and hard disks.  Supports new Kickstart 2.04 features
		including hard and soft links and High-Density drives.
		Includes program versions in English and German for use
		with Kickstart 2.04 only.  In addition to optimizing a disk,
		ReOrg can also convert the filesystem of a disk during the
		optimization, e.g. from OFS to DC-FFS.  Version 3.1, many
		new features since version 2.33 on disk 716.  Shareware,
		binary only.
		Author:  Holger Kruse

TSO_II		TSO II can be used to optimize (defragment) floppy disks and
		hard disks in order to speed up directory and file accesses.
		Contains a German and an English version of the executable
		and a timer.  Version 2.03, requires KickStart 2.04+.
		Binary only, shareware.
		Author:  Jan Hesse


New/Games/Contents
------------------

BackGammon	The computer version of the game.  This is a tiny little
		game which runs on Workbench.  Works on all Amigas, and OS
		versions from 1.2 to 3.1.  Version 0.99, an update to
		version 0.9 on disk number 849.  Freeware, binary only.
		Author:  Igor Druzovic and Daniel Amor

Chaos		The Chess HAppening Organisation System, a program that
		manages single-player chess-tournaments using a font-
		adaptive full-Intuition-GUI.  Available pairing modes are:
		Swiss pairing; Round Robin (FIDE-System); Round Robin
		(Shift-System).  Available output:  List of players (short
		or long); Results; Table (all players or special groups,
		juniors for example);  Table of progress aor Cross Tables
		(all games of all rounds); Internal ratings and German DWZ
		(close to USCF-rating or ELO)
		Author:  Jochen Wiedmann

PBSwitch	Another clone of the board game Othello.  Game play is
		standard Othello on an 8 x 8 grid of push-button switches.
		Game operations are via the mouse or the keyboard.
		Play against a friend or a 3 level computer opponent.
		A Champions Table is maintained for each of the 3 levels.
		Your selected menu options and colour scheme can be saved.
		Vocal comments are available via Amiga's narrator device.
		First release, freeware, version 1.5, binary only.
		Author:  Les E. Lamb

SkidDemo	A playable demo of the viewed-from-above driving game
		"SkidMarks", not unlike "Offroad racers", but technically
		impressive, to say the least.  Written in Blitz Basic!!!
		The demo is just the first track.
		Author:  Vision Software

WhiteLion	A new Othello (Reversi) playing program.  Strong and fast, it
		explains the rules and plays different strategies depending
		on the selected level.  Supports interLaced resolutions.
		Version 1.3, an update to version 1.2_FD on disk number 811.
		Shareware, C sources and special version available when
		registering.
		Author:  Martin Grote

Zerberk		A freeware arcade game like Berzerk, but with more features.
		Supports the 4 player adapter for the parallel port, uses
		soft stereo where possible, doesn't stop multitasking and
		saves highscores to disk.  This is version 1.3, binary only.
		Author:  Matthias Bock


New/Graphics/Contents
---------------------

Clouds		A program which creates random cloud scenery.  You may save
		the pictures as IFF-files and use them as background for
		your workbench.  Uses new AGA-features.  Operational on all
		AMIGAS with all Workbench-Versions, but needs at least 2.1
		to gain access to all features.  Version 3.0, an update to
		version 2.9 on disk number 893.  Public domain, includes
		complete source in KICK-PASCAL.
		Author:  Daniel Amor

Graphtal	A tool for manipulating  spT0L-systems  (context free, table
		oriented L-systems with stochastic productions).  Graphtal
		reads a file containing an L-system description and starts
		the interpretation.  In addition, graphtal is able to inter-
		pret the result graphically, producing different kinds of
		output.  Includes source.
		Author:  Christoph Streit, Amiga Port by Lucas Ammon

MP		An MPEG player for ECS/AGA/OpalVision/PicassoII,  It is
		derived from the UNIX/X11 MPEG decoder version 2.0 by the
		Berkeley Plateau Research Group.  Many thanks to Lawrence
		A. Rowe, Ketan Patel and Brian Smith for publishing that
		decoder, without them I wouldn't even know how MPEG works.
		Requires an 020+, 2MB, OS2.04.  Version 1.03, binary only.
		Author:  Michael van Elst

PPMQVGA		Quantizes PPM files to 8 planes, with optional Floyd-
		Steinberg dithering.  Input is a PPM file from the file
		named, or standard input if no file is provided.  Also
		includes PPMtoILBM, a PPM to IFF converter by Jef Poskanzer
		and Ingo Wilken.
		Author:  Lyle Rains, enhancements by Bill Davidsen

QMJ		A program to generate Mandelbrot, Julia and Quaternion Julia
		slice images.  Features of this version; specify with the
		mouse which part of an image to enlarge; save an image
		(compressed or uncompressed ILBM); reload an image (compres-
		sed/uncompressed ILBM format); continue a saved, but unfin-
		ished image, edit the colours used for drawing, load only
		the palette from another image; control the complete math-
		ematical process; choose the method for colouring the image;
		send the image to the printer; choose IEEE or FFP maths;
		choose low or medium resolution modes.  Version 5.4, binary
		only, shareware.
		Author:  Chris Baxter

ReadDCTV	Converts DCTV pictures to 24-bit ILBM IFF's.  Should work on
		pre-2.0 systems, but does require iffparse.library.  It also
		requires at least V3 of dctv.library.  Version 1.0, includes
		source.
		Author:  Garrick Meeker

Show_2024	A program for displaying IFF ILBM pictures on a Commodore
		A2024 grey scale monitor.  Pictures may either be shown in
		their original resolution or converted for the special A2024
		high resolution mode.  Pictures with more than 8 colors (4
		colors for high resolution mode) will be dithered.  Requires
		OS2.0+, A2024 monitor recommended.  Version 37.8, binary
		only, shareware.
		Author:  Daniel Wicke

ShowVIC		A utility that converts and displays Commodore 64 picture
		files.  A number of different formats are supported, which
		ShowVIC will automatically identify and convert.  These
		include: Koala; Artist 64; Art Studio; Advanced Art Studio;
		Image System (multi-colour and hires); Blazing Paddles;
		Vidcom 64; Doodle; FLI; Hi-Eddi; Amica-Paint and PageFox.
		Requies OS2.04+, version 3.06, binary only.
		Author:  Matt Francis

TSMorph		A morphing package consisting of three programs: TSMorph to
		edit the Morph parameters; TSMorph-render to generate the
		morphed images; and TSMorph-prefs, a Preferences editor.
		Morphs and Warps can be performed on static images or a
		series of images.  All processing is done using 24-bit
		colour internally.  Images in most ILBM formats, GIF, JPG
		and PPM can be read, and ILBM 24, Greyscale (16 and 256),
		PPM, HAM6 and HAM8 format images saved.  OpalVision and
		DCTV format files are also catered for.  Version 2.2,
		binary only.
		Author:  Topicsave Limited


New/Hardware/Contents
---------------------

2MegAgnus	The Two Meg Agnus Project increases the amount of "chip" RAM
		in an Amiga 500 or 2000 to 2 megabytes.  Chip RAM is where
		the graphics and sound data are stored.  Even though you may
		have plenty of "fast" RAM, if you run out of "chip" RAM then
		you will not be able to open any more windows or screens and
		hence, no more programs.  Revision 5.0D
		Author:  Neil Coito and Michael Cianflone

MiscHacks	A collection of various hardware hacks for the Amiga.
		Author:  Various, posted by Hans Luyten.

OptMouse	Software and hardware instructions on how you can modify a
		Mouse Systems M3 optical serial mouse for use on the Amiga.
		Also included are instructions which allow a serial mouse
		to be modified to plug directly into the Amiga mouse port.
		Author:  J. Edward Hanway

RomSwitcher	A Multi-Kickstart Board Project that allows the user of
		an Amiga 500, 2000, or 2500 to switch between different
		versions of the operating system, called Kickstart.  Some
		older software, and even some new software, is not compat-
		ible with Commodore's latest version of the operating
		system.  This hardware project will let you use the new
		version of the operating system (it is *tons* better than
		1.3 and below), and still remain compatible with the soft-
		ware that won't work under the new operating system.
		Revision 3.1.
		Author:  Neil Coito and Michael Cianflone

SpeedRamsey	Sets the skip bit in rev G Ramsey chips.  The skip mode
		speeds up RAM access from five clocks each to four clocks
		each by skipping the last cycle.  Some people call this
		60-ns-mode because you need 60 ns DRAM or faster to ensure
		that this works and doesn't crash your Amiga.  Requires
		Rev G Ramsey chip (A4000).  Version 1.2a, includes source.
		Author:  Holger Lubitz


New/Misc/Contents
-----------------

cP		A data viewing program capable of plotting two dimensional
		data in both linear or log space with or without symbols.
		Only runs from the CLI, requires Kickstart 37 or higher.
		Number of data points limited only by system ram.
		Version 2.206, binary only.
		Author:  Chris Conger

DASModPlayer	A module player for ProTracker/NT modules.  Lots of features
		including: XPK, Powerpacker, and LHA support (In theory, all
		external archivers supported, zip, zoo, shrink, etc.);
		Commodity with AppIcon, AppWindow and ToolType support;
		Configuration, Keyboard shortcut, Screen Jumping, and ARexx
		support;  Auto detach from the CLI.  Version 1.61, binary
		only.
		Author:  Pauli Porkka

HebrewArabic	Hebrew and Arabic fonts.  These fonts can be accessed using
		the Rashumon multi-lingual word processor for the Amiga.
		With these fonts, one can access both Hebrew/Arabic and
		Latin characters using the same font.  Shareware.
		Author:  Michael Haephrati, John Hajjer

HebrewFont	This is a scalable vector font.  It contains the Hebrew
		character set and Hebrew looking Latin characters.  This
		font is available in Adobe, IntelliFont, PageStream & Pro-
		Page format.  It contains a special Hebrew keymap.  Version
		1.0, shareware.  Designed with FontDesigner.
		Author:  Daniel Amor

OPlot 		One of the strongest plot-programs for the Amiga.  Some
		of its features: Multiple function, parametric or data
		plots at one time including auto-scaling and data sorting;
		Cubic/basic splines; Multiple plotstyles: lines, points,
		boxes and impulses; Free pointsizing, 12 pointtypes, 3
		pointmodes; logarithmic scales with base 2, e or 10; Auto-
		/custom-tic-marks; All text is drawn using my own Vector-
		charset featuring freesizing, tracking and rotating, special
		characters like 'dv|$%?_#^{}[]()' are supported, of course.
		You can have as many open displays (plots) as you want; 6
		screenmodes, overscan, 16 colors; ILBM-output; Powerful
		online-help; Batchfile support.  Version 1.0, binary only.
		Author:  A. Maschke

PageDemo	A fully working version of PageStream v2.22 except you will
		not be able to save any work and when printing, and the
		program will print a banner across the page saying "Printed
		with PageStream".  Also, we have not included everything the
		full version of PageStream contains.  This version does not
		include a spelling dictionary, but the hyphenation dictionary
		is included.
		Author:  Soft-Logik Publishing Corporation

PGSdrivers	A complete set of PageStream Import modules current as of
		July 24, 1993.
		Author:  Soft-Logik Publishing Corporation

PGSprinters	A complete set of the latest PageStream printer drivers
		as of July 26, 1993.
		Author:  Soft-Logik Publishing Corporation

JukeBox		JukeBox is a program to play compact digital audio discs by
		emulating a graphical user interface similar to common CD
		players.  It provides a command line oriented, fully program-
		mable ARexx user interface as well.  Works on CD-ROM players
		plugged to a scsi-hostadapter or CDTV.  Opens its windows on
		the WorkBench (or any other public screen) and does its best
		to allow a font sensitive layout.  Version 1.2530, binary
		only.
		Author:  Franz-Josef Reichert

PowerTracker	Module-Replayer supporting more than 20 formats.  A music
		player that goes back to the basics.  It supports a wide
		range of music formats without the need for many external
		libraries and players.  PowerTracker is a complete music
		player in one tidy package!  Version 1.3b, binary only,
		public domain.
		Author:  Wai Hung Liu


New/OS30/Contents
-----------------

JPEGDataType	Converts jpegs to 8 bit data for multiview and other
		programs.  It's SLOW and memory hungry, but does quite
		a reasonable job.  This is V39.1 of the JPEG datatype.
		It will ONLY work under >=WB3.0 of the OS using >=68020.
		Binary only.
		Author:  Steve Goddard

TPD		Tron's PCX DataType V39.1, TPD is a datatype for OS 3.0
		or newer.  This datatype enables your system to read PCX
		files.  PCX is an image file format invented by the pro-
		grammers of the program "PaintBrush" and one of the most
		common image formats on MS-DOS computers.  With this data-
		type you will be able to display such PCX files with
		"MultiView" or load them as patterns or pictures with
		"WBPattern".  Binary only.
		Author:  Matthias Scheler

ZGIFDataType	A much faster replacement gif.datatype, coded using the
		same lightning assembler as seen in ZGif04 (only _faster_).
		Main points: Very fast, pictures usually load at the same
		speed as equivalent depth ILBM's! (use it with viewtek105
		for faster gif loading :); Supports almost all gifs (all
		self-contained gifs); async file reading dramatically boosts
		floppy performance; It's free!  Requires and 020+ and OS3.0+.
		Version 39.3, binary only.
		Author:  Michael Zucchi


New/Pics&Anim/Contents
----------------------

Asm93_gfx	Various pics from Asm93 gfx compo.
		Author:  Various

Barfly-Prev	A small preview of the Barfly Assembler/Debugger enviroment.
		The picture of bdebug shows 2 debug sessions on an A2024 and
		the guide file is an old file I wrote for the devcon, so it
		doesn't represent the current state but it's still quite
		accurate.  The only *major* thing missing in that guide is
		that the debugger can also stop on enforcer hits.
		Author:  Ralph Schmidt

Butterfly	A 3D Imagine trace of an electronic butterfly.
		Author:  Chris Short

Creature	A 60 frame test animation of a hideous creature that leans
		in and snaps at the camera...ooooh, creapy stuff :-)  Created
		with the new 3.0 LW Modeler and animated with bones in Light-
		Wave.  Rendered with motion blur and field rendering enabled
		then post converted to a HAM animation.
		Author:  Mark Thompson

Parasaur	HAM and JPEG of a Parasaurolophus.  (That's okay... I can't
		pronounce it either!)
		Author:  Andrew Denton

RachelRaccoon	Two new hand-drawn "Eric Schwartz" style" pictures of a car-
		toon raccoon.  The pictures are overscanned hi-res interlace
		NTSC and are provided in 256, 16, and 8 color versions suit-
		able for use as Workbench backdrop pictures.  Included are
		"Karate Rachel" and "AmiCUE Rachel".  An included bonus is
		a picture of Rachel by Eric Schwartz.
		Author:  Leslie Dietz (and Eric Schwartz)

Thunder		Another "hungry-looking" dinosaur.  HAM and JPEG formats.
		Author:  Andrew Denton

TShirt		These are two pictures which I have printed on my TShirt.
		Front: Amicon5  Flip the Frog & Clarisse Cat by Eric W.
		Schwartz.  Back : Green Smily & Don't Panic known from the
		cover of some DNA-books.
		Author:  Eric W. Schwartz and an unknown artist,
			 submitted by Martin Schulze

Windmill	This is a 100 frame test animation I did as a proof of a
		concept for a technique I developed to simulate tall grass
		blowing in the wind.  The method used to create it is des-
		cribed in articles I wrote for Amiga Video/Graphics and a
		new publication, LightWave Pro (put out by the VTU people).
		It was done with LightWave 3.0 and took about 10mins per
		frame with antialiasing at 752x480 resolution on a 33MHz
		Zeus equipped 2000.
		Author:  Mark Thompson


New/Printer/Contents
--------------------

DviHp		A printer driver for HP LaserJet (trademark of the Hewlett
		Packard Company) and compatible printers.  It translates DVI
		files, usually generated by TeX, to a code understood by HP-
		LJ (PCL printer control language).  DviHp supports download-
		ing fonts, which gives you extremely fast output.  It allows
		you to include IFF ILBM files into your documents.  Version
		1.1, an update to version 1.0 on disk number 892.  Binary
		only, shareware.
		Author:  Ales Pecnik

HP4Lsetter	HP LaserJet 4L printer setup utility.  Allows you to set
		things like Page Setup, Type Styles, Print Quality, Memory,
		Copies, Lines/Page, Paper Size, Orientation, Feed, etc.
		Note:  Some items disabled in this unregistered version.
		Version 2.01, binary only.
		Author:  Quentin Snow

VirtPrinters	Two new printer drivers.  One shows the printer output on
		a screen and the other saves it as IFF pictures.  These
		drivers emulate a page-mode printer, like a laser printer.
		They both support color and b&w modes.  Color mode uses
		three bitplanes, while b&w uses only one.  Several density
		settings available, some correspond to the Amiga's aspect
		ratio, but most are just 1 to 1.  Screen_Printer requires
		a great deal of chip ram at the higher density settings.
		Both require AmigaDOS 2.04.  Includes source.
		Author:  Garrick Meeker


New/Text/Contents
-----------------

Amiga-FAQ	Lists some frequently asked questions and trys to give
		answers.  Its intention is to help new users and to reduce
		the amount of news that most experienced users don't like
		to read anymore.  Sections on Hardware, Software, Program-
		ming, Applications, Graphics and more.  Formatted in plain
		ascii, AmigaGuide, DVI, and texinfo.  Version dated August
		30, 1993.
		Author:  Jochen Wiedmann

ARexxAppList	The ARexx Application List.  A list (plain text) of approx-
		imately 309 Amiga programs that support ARexx, with brief
		descriptions of their capabilities.  Updates are posted in
		the USENET newsgroup comp.sys.amiga.applications.  Version
		dated August 18, 1993, update to the version on disk number
		754.
		Author:  Daniel J. Barrett

Guide2Inet	Big Dummy's AmigaGuide to INet, an excellent introduction to
		the Net.  This revised edition corrects some mistakes in the
		original and adds some additional information.  The index to
		the AmigaGuide version has been extended.  Revision 1.1.
		Author:  Electronic Freedom Foundation, AmigaGuide format
			 by Robin Evans


New/Util/Contents
-----------------

ALock		A little hack inspired by an earlier one by Mike Sinz, which
		appeared on one of the DevCon disks.  It's purpose is quite
		obvious: alock grabs all inputevents and thus protects your
		Amiga from any unwanted access by the keyboard or the mouse
		until you enter the correct password.  Version 1.1, includes
		source.
		Author:  Michael Kaiser

AmiLock		A console lock program which is system friendly.  Amilock is
		a series of programs which demonstrates inter-process comm-
		unication, as well as the use of interrupt handlers.  The
		interrupt handlers are used to disable/limit keyboard and
		mouse inputs, thereby allowing the console to be 'frozen'.
		The mouse can still move, but no mouse clicks are possible.
		Does not blank the screen, but any blanker can be run in
		the background and will function properly.  Version 1.0.1,
		includes source.
		Author:  Michael Nielsen

InfoWin		A simple little program written to use MUI.  MUI stands
		for 'Magical User Interface', an awesome package by Stefan
		Stuntz.  InfoWin keeps track of messages sent to it via its
		ARexx port.  I wrote it to track messages from my Caller ID
		ARexx script so that I would have an easy way of seeing my
		new calls.  It's not complete yet (ie. it's not as fully
		featured as I hope to make it eventually) but it is already
		in use on my system.  Version 1.0, binary only.
		Author:  Nick MacDonald

MagicIcons	Standard icons are just so boooring... After installing
		MagicWB I disliked my old icons even more and I  started
		to fiddle around with the existing material to produce
		something more in line with the new 'magic' look of my
		system. And this is the result.  Nothing really original,
		since I just took a set of MagicWB icons, another set of
		my old icons and stir-fried them using Deluxe Paint.
		Author:  Thomas Baetzler

MFRinCED35	Allows the usage of Stefan Stuntz's Magic-File-Requester in
		CED3.5, which doesn't work with MFR directly (probably out
		of a change in CED3.5's file-loading-mechanisms).  Uses a
		small program to set the default public screen and Arexx
		scripts.  Requires OS2.0+, version 1.0, includes source.
		Public Domain
		Author:  Benjamin Lear

MouseShift	Translates the middle mouse button into the left shift key.
		This allows easy multiple selection.  Note that programs
		that use the middle mouse button directly will no longer
		recognize it.  MouseShift requires at least AmigaDOS 1.2
		to run, but will run as a commodity under AmigaDOS 2.04
		or greater.  Binary only, public domain.
		Author:  Garrick Meeker

NoteIt!		Another Post-It) style utility.  Can be started by either
		the CLI, or from the Workbench.  Several parameters (or
		ToolTypes) supported.  Requires OS2.x,  version 1.3a,
		binary only.
		Author:  Ryan J. Bruner

Quip		"The Fortune Cookie Program From Hell", or quite simply,
		the most flexible fortune cookie program ever created on
		any platform.  It even has its own scripting 'language'
		(QuipScript).  Documentation in both ASCII and Guide
		formats.  Requires OS 2.04+, version 0.07e, includes
		source in Amiga E.  Public domain.
		Author:  Joseph Edwards Van Riper III

Recall		The ultimate reminder-utility for the absent-minded!  Can
		remind you of events with requsters, alerts or practically
		anything that can be displayed on an Amiga monitor.  Version
		1.4, binary only, public domain.
		Author:  Ketil Hunn

RunLame		A smart degrader, more lame programs work, fixes the follow-
		ing lame coding:  not considering caches; not considering
		the location of the vbr; assuming screenmode is an old chip-
		set mode; assuming sprite resolution is lores; turning off
		sprite DMA in the wrong way.  Comes with a GUI and lots of
		user-friendly features.  Also includes RunLameInfiltrator,
		which enables you to permanently fix lame programs.  Version
		1.28, has passed an extremely careful beta-testing.
		Author:  Bilbo the first

SysInfo		A brand new release of this popular program.  It reports
		interesting information about the configuration of your
		Amiga, including some speed comparisons with other config-
		urations, versions of the OS software, and much more.
		Version 3.22, an update to version 3.18 on disk 860.
		Binary only.
		Author:  Nic Wilson

TimeCalc	Well, I never found a decent timecode calculator, so here is
		one that works correctly (For me at any rate) with EBU and
		SMPTE timecodes (SMPTE DropFrame is not currently supported).
		It has clever string gadgets that make timecode entry a
		breeze.  Timecode entry routines are part of the "Diamond
		Edit" package which is a single frame recorder for the PAL
		environment (soon for NTSC) that is a very powerful and cost
		effective means of recording hires 24bit animations to video
		tape for playback at a full frame rate (for professional
		VTRs only).  Version 1.0, binary only, requires OS2.x.
		Author:  Paul Huxham

Unpacker	An appicon utility for extracting archives.  It chooses the
		archiver to use by the suffix, eg. '.lha', '.zip' or '.zoo'.
		You can configure UnPacker for any other arc-program you
		want to use by changing the tooltypes of the icon.  Version
		1.1, binary only.
		Author:  Erik Sagalara

WindowDaemon	Gives extended control to intuition windows and screens
		through HotKeys and Arexx.  Features:  Commodities Support;
		HotKey and Arexx support to manipulate the currently active
		window and screen.  Standard window controls are avalable
		such as Zip, Close, Size, ToFront, ToBack, NextScreen, etc.
		Able to close the parent window of a drawer when opened on
		"Workbench" if CONTROL is held down.  (Only available under
		kickstart V39 or higher); Specialized options to forcefully
		close windows and screens, and also to remove tasks that own
		the active window.  Version 1.0, binary only.
		Author:  David Swasbrook

xpkdisk   	`xpkdisk.device' is an exec-style device that looks like
		trackdisk.device and similar disks.  The difference is that
		it compresses its data and stores it in multiple files in
		an existing filesystem.  It uses the XPK (eXternal PacKer)
		standard to do the actual compression.  Version 37.2,
		includes source.
		Author:  Olaf Seibert




--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.

====================================================================
This is part of a mailing list gateway maintained by Carlos Amezaga.
Bugs, Comments, Subscribes and UnSubcribes should be sent to
announce-request@cs.ucdavis.edu.



