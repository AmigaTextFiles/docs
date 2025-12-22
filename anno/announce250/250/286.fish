From fnf@cygnus.com Sun Dec  6 13:42:20 1992
Received: from relay1.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.0)
	id AA02414; Sun, 6 Dec 92 13:42:15 PST
Received: from cygnus.com by relay1.UU.NET with SMTP 
	(5.61/UUNET-internet-primary) id AA04391; Sun, 6 Dec 92 16:42:09 -0500
Received: from fishpond.cygnus.com by cygnus.com (4.1/SMI-4.1)
	id AA26554; Sun, 6 Dec 92 13:42:09 PST
Received: by fishpond.cygnus.com (4.1/SMI-4.1)
	id AA19412; Sun, 6 Dec 92 13:10:51 MST
From: fnf@cygnus.com (Fred Fish)
Message-Id: <9212062010.AA19412@fishpond.cygnus.com>
Subject: Disks 771-780 now available
To: announce@cs.ucdavis.edu (comp.sys.announce moderator)
Date: Sun, 6 Dec 92 13:10:48 MST
X-Mailer: ELM [version 2.3 PL11]
Status: R

Disks 771-780 are now available.  Shipping to all those who have preordered
disks should be complete by Tuesday (8-Dec-92).

Note that you can get a copy of the catalog (2 disks) of the complete library
contents by sending $3 for disks, postage, and mailer to:

	Fred Fish
	Catalog Disk Requests
	1835 East Belmont Drive
	Tempe, Arizona  85284
	USA

Thanks to all who submitted new and interesting material.  If you submitted
something in the past and it has not yet appeared in the library, please
feel free to resubmit it, particularly if it was several months ago.  I
sometimes hesitate to include material submitted more than about six
months ago because of some vague feeling that as soon as I include version
1.01 submitted many months ago, I'll see version 5.23 posted on usenet.

For those wishing to submit material for possible inclusion in the library,
here are a few simple guidelines that will make my job of organizing the
material MUCH easier and GREATLY increase your chances of having the material
accepted for inclusion:

1.	Don't submit bootable disks or disks with any other
	sort of proprietary material included, since I then
	have to go examine each file to decide if it is
	distributable or not, and if not, what effect removing
	it might have.  Unless the material is particularly
	interesting, I frequently just toss such disks into
	the recycling bin.

2.	Organize the distribution in a manner similar to my
	disks.  I.E, place all files related to a particular
	submission under a single directory on the disk.  If
	there is more than one submission per disk, it's ok to
	to place each submission in it's own directory.

3.	Try to write a simple entry for my "Contents" listing
	that summarizes your submission.  It should be about
	3-10 lines, and include the current version number,
	the version and disk number of the most recent version
	(if any) that was last included in the library, whether
	or not source is included, and an "Author" list.

4.	Ensure that your submission will run correctly from
	it's subdirectory and if necessary, supply a script
	runnable from workbench (via :c/xicon) that makes all
	necessary assigns, copies fonts and libraries, etc.

5.	Send your submission in a sturdy envelope with sufficient
	padding.

Thanks!!!

======================================================================

CONTENTS OF DISK 771
--------------------

AutoSave	A small program which calls an ARexx script at regular inter-
		vals, controlled through a Workbench window.  Although intended
		to provide an "AutoSave" function for applications, the script
		can do anything.  Includes C source, which demonstrates simple
		use of GadTools and the timer device.  Requires Kickstart 2.0
		or later.
		Author:  Michael Warner

BBBBS		Baud Bandit Bulletin Board System.  Written entirely in ARexx
		using the commercial terminal program "BaudBandit". Features
		include up to 99 file libraries with extended filenotes, up to
		99 fully threaded message conferences, number of users, files,
		messages, etc. are only limited by storage space, controlled
		file library and message conference access for users and sys-
		ops, interface to extra devices like CD-ROM and others, all
		treated as read only, complete Email with binary mail and
		multiple forwarding, user statistics including messages writ-
		ten, files uploaded or downloaded, time, etc, plus much more.
		Works under Amiga OS 1.3 and greater, tested through 3.0.
		This is version 5.7, an update to version 5.5 on disk 729.
		Includes complete ARexx source.
		Author:  Richard Lee Stockton

PubChange	A commodity for AmigaDos 2.04.  It isn't a public screen man-
		ager, but it is useful when used in conjunction with one.  It
		is designed to make public screens easier to use.  Whenever a
		new screen is brought to the front, this screen is examined.
		If it is a public screen, it is made into the default automat-
		ically without having to explicitly do it from within a public
		screen manager.  Thus, the current default public screen is
		always the one which you have most recently brought to the
		front, and applications which use the default public screen
		will appear there.  Version 1.0, binary only.
		Author:  Steve Koren

PKludge		A mode promotion commodity for AmigaDos 3.0.  It allows any
		mode to be promoted to any other mode.  Mode promotion keyed
		from the screen name or title, and resizing and moving screens
		during mode promotion.  It is useful to 1) promote all screens
		to a single scan rate to avoid re-syncing on multisync moni-
		tors during screen flipping, 2) use 800x600 or higher resolu-
		tions with some applications which don't know how to open
		those screens but can otherwise handle bigger screen sizes,
		3) use PAL:Productivity 640x400 mode instead of DblNTSC:High
		Res Lace mode, since the productivity mode tends to be more
		visible on some Amiga 4000's.  Version 1.0, binary only.
		Author:  Steve Koren

NiceMove	Some different examples in C of MOUSEMOVE event handling during
		high CPU or DMA usage.  Version 1.00, first release.  Includes
		source and a sample program.
		Author:  Thies Wellpott

Sing		Sing will read a text file (actually ANY file) and try to
		"sing" the characters in it using internal simple waveforms in
		4 voices.  Binary only.
		Author:  Richard Lee Stockton

Sound		Sound sample player.  Will play ANY file as sound.  Understands
		IFF, stereo, and fibronicci compression.  Can play direct from
		disk.  Uses only 4k of chip ram.  Effects include fade and
		grow.  Works from CLI or WorkBench, all OS thru 3.0.  Includes
		complete C source.
		Author:  Richard Lee Stockton

SourcOpt	A little assembly language source optimizer.  While most assem-
		blers have optimization, they optimize the compiled code.  One
		disadvantage of this however, is when debugging code thru a
		disassembler or monitor, the code you see differs from that
		you have written because of the optimization.  By optimizing
		the source first, you can eliminate some of these differences.
		Version 1.0, binary only, CLI usage only.
		Author:  Alexander Fritsch


CONTENTS OF DISK 772
--------------------

VMB		Demo version of VIDEO MUSIC BOX, a program designed to provide
		an easy to learn and use facility that non-musicians or begin-
		ning musicians can use to compose original background music
		for their Amiga multimedia productions.  No prior music com-
		positional knowledge is required to generate basic musical
		styles from pre-arranged music pattern templates and chord
		progressions.  Individuals having increased musical backgrounds
		can use the many included editors to define new chord-types,
		"revoice" chords, create new chord progressions, perform basic
		sequence editing, and create additional pattern templates.
		Supports both MIDI Format 0 and IFF SMUS music file formats
		for compatibility with all multimedia authoring programs.
		Version 1.6, second major upgrade to version 1.0 on disk number
		660.  This new version is AmigaDOS 2 compatible, allows un-
		limited pattern generation in a single sequence, has improved
		musical dynamics, and expanded MIDI.  Requires 1 Meg.
		Author:  D.T. Strohbeen


CONTENTS OF DISK 773
--------------------

Detache		A very small and simple utility that will detache a file from
		the file system.  Note that this is completely different than
		deleting a file.  In particular, Detache works even if the file
		system did not restart properly because of a failed validation.
		This happens rather frequently if the Amiga crashes during a
		write on a hard disk partition: you get the dreaded "checksum
		error on block xxx" requester, and no writes are allowed to the
		partition.  If you know the name of the guilty file (the file
		the faulty block belongs to) you can simply detache it, and the
		file system will be happy to restart.  Requires OS2.04, binary
		only.
		Author:  Sebastiano Vigna

Enforcer	A tool to monitor illegal memory access for 68020/68851, 68030,
		and 68040 CPUs.  This is a completely new Enforcer from the
		original idea by Bryce Nesbitt.  It contains many new and
		wonderful features and options and no longer contains any
		exceptions for specific software.  Enforcer can now also be
		used with CPU or SetCPU FASTROM or most any other MMU-Kick-
		start-Mapping tool.  Major new output options such as local
		output, stdout, and parallel port.  Highly optimized to be as
		fast as possible.  This is version 37.26, containing a bug fix
		to version 37.25 on disk number 754.  Requires V37 of the OS
		or better and an MMU.
		Author:  Michael Sinz

Ls		An update based wholly but loosely to the version 3.1 of Ls on
		disk number 236 by Justin McCormick.  Includes many enhance-
		ments and bug fixes.  Ls is a popular, UNIX style directory
		lister.  This version features intelligent columnar listing,
		versatile sort options, UNIX-style pattern matching, recursive
		subdirectory listing, customized output formatting and much
		more!  Version 4.7ljr, requires at least OS 2.04, includes
		source.
		Author:  Loren J. Rittle.

NewPop		An upgrade to the original "POPCLI" by John Toebes.  Features
		include a hotkey CLI (of course!), instant or timed screen
		blanking, a discreet informative backdrop window in the title-
		bar region of the WorkBench screen that gives the date, a
		rough indication of CPU usage and SCSI disk I/O and available
		memory.  Also includes a runtime configuration file.  Version
		4.0, includes source.
		Author:  Loren J. Rittle

Quest		General purpose interactive AREXX question/answer routine that
		includes a very funny script ("HackerTest") to rate your
		"computerese" and hacker ability.  Quest can be used for any
		similiar type question-answer script.  The original hackertest
		was created by Felix Lee, John Hayes and Angela Thomas in Sep-
		tember 1989.
		Author:  Erik Lundevall

REXXProgs	Some good, well-commented, examples of REXX programming.
		Includes Palette.rexx, an ARexx tutorial on using the rexx-
		arplib.library to open a window (in this case a color palette)
		on any public screen and send messages to another ARexx pro-
		cess.  ShoList.rexx, displays system lists (libraries, ports,
		tasks, etc.) and Sz.rexx, Displays alphabetically sorted
		directory with filesizes.  CLI only.
		Author:  Richard Lee Stockton
 
Wangle		Very addictive "sliding-block" single player strategy game.
		The object is to group four smaller squares of the same color
		together in such a way as to form a larger square.  Once
		started in a direction, blocks slide until they hit another
		block, a wall, or in some cases, fall through the floor!
		Includes 50 levels and a level editor.  Binary only.
		Author:  Peter Handel


CONTENTS OF DISK 774
--------------------

ExtraCmds	A small set of AmigaDOS commands, chiefly inspired by UNIX,
		written to augment the collection distributed as part of the
		System Software Release 2.04 (V37) and will not run under
		older releases.  This is the first public release consisting
		of the commands Common, Concat, Count, DirTree, Head, Lower,
		Split, Tee, TimeCom, and Unique.  Source code and manual pages
		in both Danish and English are included.
		Author:  Torsten Poulin

HuntWindows	Starting with 2.0 you can make screens bigger than the visual
		size of your monitor.  On a double-size workbench, catching
		windows like requesters etc. can be quite annoying at times.
		This little utility hangs itself on the Vertical Blank inter-
		rupt to find out which window is being activated and moves the
		screen to show the window in full view.  Version 1.4, includes
		source in assembler.
		Author:  Joerg Bublath

ISpell		An "Amigatized" port of a Unix version of a freely distribu-
		table interactive spelling checker.  Two major modes of oper-
		ation: Original Interactive Mode to allow a user spell check
		and correct a text document and ARexx Server Mode that allows
		the end user to hook ISpell up to text editors and other things
		that need a spell checking service.  Regular expression lookup
		of word patterns is also possible in ARexx Server Mode.
		Includes Arexx macros for GUISpell (included), CygnusEd, Mg,
		TurboText, GNU emacs, VLT and WShell.  Version 3.3LJR, an
		update to the version released on disk number 191.  Requires
		AmigaOS 2.04 or later.  Includes source.
		Author:  Many! Current version by Loren J. Rittle

SetAslDim	A very small and simple 2.04-only utility which lets you set
		the position and dimensions that the ASL file, font and screen
		mode requesters will assume as default.  It obtains this result
		by SetFunction()ing the AllocAslRequest() call of the asl.lib-
		rary.  Binary only, CLI usage only.
		Author:  Sebastiano Vigna

SetSystem	A very small and simple 2.04-only utility which forces the
		SYS_UserShell tag on each System() call.  This means that every
		application will use your user shell (for instance, Bill
		Hawes's WShell) instead of the system shell.  Binary only,
		CLI usage only.
		Author:  Sebastiano Vigna


CONTENTS OF DISK 775
--------------------

ICoons		A spline based object modeller which can be used to generate
		objects in TTDDD format.  TTDDD files can be converted to lots
		of different object formats by using the T3DLIB shareware
		package by Glenn Lewis.  Line mode and Flat mode solid render-
		ing as well as Gouraud and Phong shading.  Requires a machine
		with a floating-point co-processer.  Version 1.0, includes
		source.
		Author:  Helge E. Rasmussen

CONTENTS OF DISK 776
--------------------

CopDis		An oldie but goodie I found while poking around the net.
		CopDis is copper list disassembler that can be run from the
		CLI or linked with and run directly from an application
		program.  This is version 34.1, an update to version 0.0a
		on disk number 261.  The code has been cleaned up, some bugs
		fixed and the ECS instructions added.  Includes source.
		Author:  Karl Lehenbauer, enhanced by Sebastiano Vigna

JEd		Yet another programmer's editor.  Lots of features, including:
		total customization, a powerful programming language, multi-
		file/multi-view editing, number of windows is only limited by
		memory, clipboard support (cut/paste on any unit), any window
		can have any (non-proportional) font, an Arexx interface, and
		more.  Version 2.05, (apparently unrelated to the version of
		Jed on disk 297).  Requires OS2.0 or later, includes source.
		Author:  John Harper

XDME		Version 1.54 of Matt's text editor.  XDME is a "not-so-simple"
		WYSIWYG editor designed for programmers.  It is not a WYSIWYG
		word processor in the traditional sense.  Features include
		arbitrary key mapping, FAST scrolling, title-line statistics,
		multiple windows, and ability to iconify windows.  This new
		version has some bug fixes, many new commands and several other
		new enhancements.  Update to version 1.45 on disk number 530,
		includes source.
		Author:  Matt Dillon, Enhanced by Aaron Digulla

WFile		Small but useful tool to interchange ASCII files between
		different operating systems.  Converts foreign symbols and
		adapts linefeed codes.  Can also be used to expand tabs to
		multiple spaces or vice versa.  It has builtin templates for
		interchange between Amiga, MS-DOS, OS/2 and UNIX systems.
		Profiles can be used for common adaptions.  The new version
		contains new templates and the memory management system has
		been revised and optimized.  Version 1.32, an update to
		version 1.11 on disk 536.  Includes source in C.
		Author:  Joerg Fenin


CONTENTS OF DISK 777
--------------------

AGAtest		Two little programs for the (lucky) owners of AGA machines that
		show all 2^24 colors on an AGA HAM8 screen without ever chang-
		ing the 64 base color registers.  Includes source.
		Author:  Loren J. Rittle

Chemesthetics	Chemesthetics uses the calotte model to draw molecules.  It has
		an Intuition user interface, can save pictures as IFF files and
		has many example files.  The new version lets you raise the
		task priority for the painting process to get the results
		faster, shadow and reflection color can now be set to your
		desires, quicktrans.library is used for even faster painting.
		Versions for a math coprocessor and utilties to convert data
		files from Molec3D and to DKBTrace are included.  This is ver-
		sion 2.14, an update to version 2.10 on disk number 574.
		Includes source in C.
		Author:  Joerg Fenin

IncRev		A small program for a makefile or an lmkfile to update a pro-
		gram's revision number after each successful compile process.
		This is version 1.10, an update to version 1.03 on disk number
		536.  Includes source in C.
		Author:  Joerg Fenin

Sizer		A small and pure shell utility that gives the size in bytes,
		blocks, and the total occupied by a directory, device or
		'assign'.  Accepts multiple arguments.  Version 0.36, an update
		to version 0.20 on disk 741.  Now handles control-C and gives
		more accurate results.  French and English docs.  Binary only.
		Author:  Gerard Cornu.


CONTENTS OF DISK 778
--------------------

DungeonMap	A little tool that creates maps of dungeons and towns which
		can be used by a Dungeon Master (DM's) for use in a Dungeons
		& Dragons (D&D) game.  These maps can be saved, edited, and
		printed.  This is version 1.1, an update to version 1.0 on
		disk number 603, binary only.
		Author:  Bill Elliot

EgoMouse	A little hack that makes the mouse pointer turn towards the
		direction you move your mouse.  A popular program on the
		Macintosh.  Version 1.0, binary only.
		Author:  B.J Lehahn, Pointer designed by F. K|ster 

Kurve		Kurve is yet another function plotting tool which provides
		a very fast and easy way of plotting and analysing
		mathematical functions.  The integrated function compiler
		makes this plotter to be the fastest one you've ever seen.
		Version 2.001, compatible with Kickstart 2.0 and 3.0beta.
		Includes source in C.
		Author:  Henning Rink

MultiReq	A FileRequester library, but it's not simply another file
		requester library, cause it's the first really multitasking
		file requester (as far as I know) and above this it also has
		a great number of other features, that make MultiReq superior
		to other file requesters.  Written entirely in assembler to
		be small and fast.  Version 1.20, binary only, shareware.
		Author:  Andreas Krebs

OmtiFroh	A very small "mini-hack" that allows Enforcer to be used with
		some specific SCSI controllers that don't bind an AutoConfig
		node into the ExpansionList.  Enforcer registers the accesses
		to the hardware at 0xee0000 as 'hits'.  This little gem will
		create the AutoConfig node for you.  Includes source.
		Author:  Henning Schmiedehausen


CONTENTS OF DISK 779
--------------------

AAP_AAC		Animation playback and convert programs. (AAP and AAC).  AAP
		can show IFF ILBM pictures, show IFF ANIM_5 and IFF_ANIM_7
		animations.  It can show (long) sequences of animations and/or
		pictures using a script file and can operate from memory
		(preload) and/or disk.  AAC converts between the supported
		anim filetypes and/or sequences of pictures.  AAP version 1.2,
		AAC version 1.1.  Includes source and a small sample sequence
		mix of pictures/animation from script file.
		Author:  Wolfgang Hofer

Plasma		A Plasma Cloud Generator for V39 AGA machines only.  This pro-
		gram will generate Fractal Images called Plasma Clouds, using
		the AGA 256 color modes with full use of the 24 bit palette.
		Includes source.
		Author:  Roger Uzun

RDBInfo		Reads the RigidDiskBlock of the unit and device given as argu-
		ments, then displays the most interesting parts.  Version 0.17,
		Binary only.
		Author:  Gerard Cornu

SANA		The official Commodore developer information package for the
		SANA-II Network Device Drivers.  Includes the SANA-II spec,
		readme files, SANA-II drivers for Commodore's A2065 (Ethernet)
		and A2060 (ARCNET) boards, docs and includes, and some exam-
		ples.  Release version 1.4, update to version on disk number
		673.
		Author:  Commodore-Amiga Networking Group

VPortPatch 	A very small 2.04-only utility that patches the graphics.lib-
		rary function MakeVPort() in such a way to avoid an annoying
		bug that keeps multipalette pictures from being correctly
		scrolled (multipalette pictures contain the new PCHG chunk
		which specifies line-by-line palette changes; hundreds of
		colors can be displayed even in hi-res with multitasking and
		full system compatibility).  Includes source.
		Author:  Sebastiano Vigna


CONTENTS OF DISK 780
--------------------

ABackup		A powerful backup utility, that may be used both for hard
		disk backup and for file archiving.  Has a full Intuition
		interface, a "batch" mode, can save/load file selection,
		handle HD floppies, etc...  This is a *MAJOR* update, with
		support for XPK library, child task for disk write, error
		recovering when writing to a disk and more.  Include both
		French and English versions.  This is version 2.00, an
		update from version 1.60 on disk 759.  Shareware, binary
		only.
		Author:  Denis Gounelle.

MEM		A little memory game where the object is to remember the face
		of a "thief" you are shown for a variable length of time
		depending on the level.  You are then presented with a screen
		in which you have to "recreate" the face using various select-
		ions for eyes, eyebrows, nose and mouth.  Version 1.0, binary
		only.
		Author:  Jason Truong

NickPrefs	An enhancement to IPrefs that manages three new preferences,
		WBPicture allows you to display any IFF picture in the main
		Workbench window, supplanting the original (and boring ;-))
		WBPattern.  BusyPointer lets you edit the clock pointer used
		by programs when they are busy.  You may create an animated
		pointer.  Floppy provides the ability to mess with the public
		fields of trackdisk, that is, the TDPF_NOCLICK flag, step
		delay and the like.  Requires OS2.0, binary only.
		Author:  Nicola Salmoria

RachelRaccoon	A set of hand-drawn "Eric-Schwartz-animation-style" pictures
		of a new cartoon character.  The pictures are overscanned hi-
		res-interlace (704x480) and are provided in 16-color, 8-color,
		and 4-color flavors so you can use them for Workbench backdrop
		pictures.  The colors are arranged so that at least on Work-
		bench 2.x you will have standard looking titlebars.
		Author:  Leslie Dietz

======================================================================

-Fred

