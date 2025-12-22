From fnf@cygnus.com Tue Jan 12 08:42:21 1993
Received: from relay1.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.0)
	id AA08888; Tue, 12 Jan 93 08:42:16 PST
Received: from cygnus.com by relay1.UU.NET with SMTP 
	(5.61/UUNET-internet-primary) id AA15902; Tue, 12 Jan 93 11:41:19 -0500
Received: from fishpond.cygnus.com by cygnus.com (4.1/SMI-4.1)
	id AA04268; Tue, 12 Jan 93 08:41:17 PST
Received: by fishpond.cygnus.com (4.1/SMI-4.1)
	id AA16534; Tue, 12 Jan 93 09:01:44 MST
From: fnf@cygnus.com (Fred Fish)
Message-Id: <9301121601.AA16534@fishpond.cygnus.com>
Subject: Disks 791-800 now available
To: announce@cs.ucdavis.edu (comp.sys.announce moderator)
Date: Tue, 12 Jan 93 9:01:43 MST
X-Mailer: ELM [version 2.3 PL11]
Status: R

Disks 791-800 are now available.  Shipping to all those who have preordered
is now complete as of 12-Jan-92.

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

1.	Don't submit bootable disks or disks with any other sort of
	proprietary material included, since I then have to go examine
	each file to decide if it is distributable or not, and if not,
	what effect removing it might have.  Unless the material is
	particularly interesting, I frequently just toss such disks
	into the recycling bin.

2.	Organize the distribution in a manner similar to my disks.  I.E,
	place all files related to a particular submission under a single
	directory on the disk.  If there is more than one submission per
	disk, place each submission in its own directory.

3.	Try to write a simple entry for my "Contents" listing that
	summarizes your submission.  It should be about 3-10 lines, and
	include the current version number, the version and disk number
	of the most recent version (if any) that was last included in the
	library, whether or not source is included, and an "Author" list.

4.	Ensure that your submission will run correctly from its sub-
	directory and if necessary, supply a script runnable from workbench
	(via :c/xicon or c:iconx) that makes all necessary assigns, copies
	fonts and libraries, etc.

5.	Send your submission in a sturdy envelope with sufficient padding.

Thanks!!!

======================================================================

CONTENTS OF DISK 791
--------------------

HSV		A small color palette utility that contains both RGB and HSV
		sliders for adjusting your screens colors.  If the screen has
		4 bitplanes or less, you can also save the palette to 'ENVARC:
		palette.prefs'.  Requires AmigaOS2.xx, version 0.99, includes
		source.
		Author:  Frank Ederveen

RADBack		A shareware utility that can make a backup of a RAD disk to a
		normal 880K Amiga disk, regardless of its length - bigger RADs
		are saved on more disks.  Can be started from the Workbench as
		well as from CLI.  Version 1.0, binary only.
		Author:  Sandi Tomsic

Replex		REPLace EXecutable. This handy patch substitutes program names
		that are about to be executed, e.g. if an icon default tool
		specifies ":c/MuchMore" and you prefer to use "c:TextRead",
		you can have it defined as such, so you never have to change
		the icon.  Intuition interface allows up to 8 such definitions.
		Compatible with all known OS versions.  This is version 1.0,
		binary only.
		Author:  Ekke Verheul

ScsiTape	A Scsi-Direct tape handler that implements fully asynchronous
		double-buffered read and write operations.  If you have disk /
		tape drives which support reselection then the handler will be
		able to operate on the tape concurrently with disk accesses
		meaning that an archiver such as Tar will not 'freeze' while
		tape operations are in progress.  Includes source.
		Author:  Matthew Dillon

SKsh		A Unix ksh like shell for the Amiga.  Some of its features
		include command substitution, shell functions, aliases, local
		variables, emacs and vi style editing, I/O redirection, pipes,
		Unix wildcards, a large variety of commands, and coexistence
		with scripts from other shells.  Well documented.  Version 2.1,
		an update to version 2.0 on disk 672.  New features in version
		2.1 include true piping between internal and external commands,
		background functions, aliases, and other shell constructs,
		enforcer clean, several new commands, cross filesystem file
		and directory moves, and more.  Binary only.  Requires Amiga
		Dos 2.04.
		Author:  Steve Koren

CONTENTS OF DISK 792
--------------------

AmigaBase	A hierachical, programmable, in-core database.  Features
		include two display methods, filter datasets, search datasets,
		print datasets, and many more.  Nearly everything can be real-
		ized by programming AmigaBase.  Datatypes can be Integer, Real,
		Boolean, String, Memo (Text), Date and Time.  Number of data-
		sets is only limited by available memory.  Lacking documenta-
		tion, (available with shareware submission) but full Intuition
		interface make many operations quite obvious.  Also includes
		some example projects.  Runs under OS 1.3 and 2.0, shareware,
		binary only.
		Author:  Steffen Gutmann

DragIt		Allows you to move or size a window without having to use the
		drag bar or sizing gadget.  Press on  the configurable quali-
		fier, while holding it, press  your selected  mouse button,
		and move the mouse.  You'll  see the  window  border appear,
		and  you'll be able to drag or size it.  Requires OS 2.0,
		supports localization with locale.library and the new style
		2.1 (or 3.0) preference.  Version 2.01, binary only.
		Author:  Steve Lemieux

ModHPLJD	A Rexx program that creates a modified version of the HP_Laser
		Jet driver.  The modification changes the 'initialize' string
		so that the font chosen from the printer menu (rather than
		12pt Courier) can be used and the number of lines per inch can
		be specified.  Version 1.01.
		Author:  Michael Tanzer

TClass		An "Intelligent" file identifier.  Has the ability to "learn"
		new types of files by simply scanning groups of known types of
		files, and checking the first 20 bytes for similiarities.  It
		then reports on the matching accuracy and adds a "definition"
		for the filetype to a brain file.  Version 2.9, binary only.
		Author:  Sam Hulick

WBPat		Creates random 3D patterns for your 2.04 WorkBench windows.
		A pattern can be shifted or changed, tested, used and saved.
		Version 1.0, includes source in C.
		Author:  Ekke Verheul

CONTENTS OF DISK 793
--------------------

DateCheck	A Rexx program that validates the system date by comparing it
		to the date stored when DateCheck was last executed.  If the
		system date is earlier or too much later than the stored date,
		the user is notified by a requester.  Version 1.01.
		Author:  Michael Tanzer

ReflexFinal	A game which tests your addition, subtraction, division, mul-
		tiplication, percentage, and algebra skills.  The goal is to
		answer several math questions in the shortest possible time.
		A continuation to "ReflexTest" on disk number 751.  Binary
		only.
		Author:  Jason Lowe

Snap		A tool for clipping text or graphics from the screen, using
		the clipboard device.  Snap finds out character coordinates
		automatically, handles different fonts, keymaps, accented
		characters, and more.  Version 1.63, contains a small bug fix
		to version 1.62 on disk number 524.  Includes source.
		Author:  Mikael Karlsson

SOUNDEffect	Sound sample editing program.  Special features include:
		temporary buffers, frequency and amplitude modulation (tremolo
		and vibrato), echo, special reverb effect, chorus effect,
		mixer, free hand editing, low and high pass filter, compresser,
		expander, limiter, distortion and all usual functions (copy,
		paste, insert, cut, looping, zooming etc.).  Version 1.30,
		shareware, binary only.
		Author:  Sven B|hling

CONTENTS OF DISK 794
--------------------

MCAnim		A special animplayer. Plays LORES 4-plane ANIM5 anims in a
		HIRES-LACE screen.  The result is a FULLspeed, small (1/4)
		animation with a high resolution.  The anim can be placed
		anywhere on the screen.  One of nine copperlists can be added
		in one register without loss of speed. Version 0.8, binary
		only.
		Author:  Ekke Verheul

ReqTools	A standard Amiga shared runtime library which makes it a lot
		quicker and easier to build standard requesters into your pro-
		grams.  Designed with CBM's style guidelines in mind, so that
		the resulting requesters have the look and feel of AmigaDOS
		2.0.  Version 2.1a, lots of enhancements since release 1.0d on
		disk 623.  Includes a demo and glue/demo sources.
		Author:  Nico Francois

CONTENTS OF DISK 795
--------------------

PSTools		Part 1 of a two part distribution of DVIPS ported from a Unix
		environment.  DVIPS is a program that takes TeX .DVI files and
		converts them to PostScript files.  If you don't have access to
		a PostScript printer, you can still take advantage of the vast
		amount of useful documentation in TeX .dvi or PostScript .ps
		format using the incredibly excellent POST program from FF669.
		This portion of the distribution contains the DVIPS binary,
		source and config files; DVIPS documentation; the Adobe Font
		Metric Files, TeX vf font files and LaTeX files.  Part 2 of the
		distribution can be found on disk number 796.  Includes DICE
		C-source.
		Author:  Originally from DECUS, Amiga port by Jonathan Hudson

UnDelete	Restores deleted files and (empty) directories with a fast
		deleted-file-find routine.  It is often as fast as "delete".
		Works on all OFS and FFS disk devices, but from Shell only.
		Version 1.02, binary only.
		Author:  Ekke Verheul

CONTENTS OF DISK 796
--------------------

PSTools		Part 2 of a two part distribution of DVIPS ported from a Unix
		environment.  DVIPS is a program that takes TeX .DVI files and
		converts them to PostScript files.  If you don't have access to
		a PostScript printer, you can still take advantage of the vast
		amount of useful documentation in TeX .dvi or PostScript .ps
		format using the incredibly excellent POST program from FF669.
		This portion of the distribution contains the TeX pk font files
		and the TeX tfm font files.  Part 1 of the distribution can be
		found on disk number 795.
		Author:  Originally from DECUS, Amiga port by Jonathan Hudson

CONTENTS OF DISK 797
--------------------

A2ps		Another "oldie but goodie" I found poking around the net.  This
		seemed like an appropriate place to put it.  A2Ps formats an
		ascii file for printing on a postscript printer, adds borders,
		headers etc.  Lots of command line options.  Includes source.
		Author:  Miguel Santana, amiga port by Daniel Barrett

BBBF		The Bootblock.library/brainfile is an attempt to make life a
		little bit easier for programmers of anti-virus utilities,
		diskcopy programs, directory utilities, disk packers and for
		whoever who wants to check the bootblock of some device
		The library has some easy-to-use functions to read the brain-
		file, and to check a bootblock with it.  Version 0.95 beta,
		brainfile recognizes 158 different viruses.  Includes sample
		source.
		Author:  Johan Eliasson, SHI member.

BIGMec		A shareware utility that displays the current available amount
		of memory, the memory available when BIGMec was started and the
		difference between those.  The amounts can be displayed in HEX/
		DEC and BYTE/KILO/MEGA.  BIGMec can be started from Workbench
		as well as from CLI.  Version 1.0, binary only.
		Author:  Sandi Tomsic

DVI2LJ		A cli utility to convert TeX .DVI files into HP PCL files
		suitable for printing on the HP Laser Jet series printers.
		Author:  Gustaf Neumann, amiga port by Daniel Barrett

HP3ps		An intuitionized utility for changing modes on a Pacific Page
		Postscript Emulation cartridge.  Allows you to select HP-PCL
		or POSTSCRIPT mode by simply clicking on a gadget.  Version
		92.02.09, binary only.
		Author:  Scott Dhomas Trenn

PSUtils		Some cli utilities for the manipulation of PostScript files.
		Includes: psbook - rearranges pages into signatures; psnup -
		uses pstops to merge multiple pages per sheet; psselect -
		selects pages and page ranges; pstops - performs general page
		rearrangement and selection; and epsffit - fits an EPSF file
		to a given bounding box.  Includes source.
		Author:  Angus Duggan, amiga port by Jonathan Hudson

Spots		A useless but pretty 24-bit-RGB and HAM spot-paint-program.
		Handles scripts to render animations. It needs arp.library or
		WorkBench 2.0.  Check out the examples to see if you like the
		effect.  Version 1.10, binary only.
		Author:  Ekke Verheul

CONTENTS OF DISK 798
--------------------

AddressitDEMO	Demo version of a very powerful small business and personal
		mail manager that includes many extras.  You can define up to
		15 flags, export data to ProWrite and Wordperfect, and print
		rosters, mailing lists, labels, envelopes plus a whole lot
		more.  Works with 1.2/1.3 and 2.0.
		Author:  Legendary Design Technologies Inc.

ASwarmII	A "high security" Screenblanker commodity (will not burn-in
		the phosphor even when the CPU is really busy).  Based loosely
		upon Jeff Buterworth's "xswarm" for X11 Windowing System, it
		shows from 1-10 "wasps" beeing chased by 1-500 "bees".  Screen
		will blank entirely under periods of high CPU usage.  Requires
		Amiga OS 2.04 or better, version 1.3, includes source.
		Author:  Markus Illenseer

If2.0		A CLI/Shell command, which decides whether your Amiga is run-
		ning OS v2.x or OS v1.x - and then executes a corresponding
		command line/argument.  Especially useful for zKick-using
		Amigas.  Version 1.2, includes C-Source.
		Author:  Thomas Arnfeldt

LockIt		A simple commodity to protect files or drawers from any access.
		Uses a WorkBench AppIcon and allows selection of files via ASL-
		Requester.  Requires OS2.0.  Version 2.1, binary only.
		Author:  Andreas Linnemann

NewMode		A tool for changing the screenmode of any screen by manipula-
		ting the OpenScreen pointer.  Includes new "ModeNames" file
		for the screenmodes (like HAM...).  Requires OS2.0.  Version
		1.1. Binary only.
		Author:  Andreas Linnemann

Prism		An ANSI editor that allows animations and complete colour con-
		trol.  It is used on many BBS's to create animated screens.
		Includes a configuration editor, font control, and variable
		playback speed.  New features include automatic line and box
		drawing, and a special "Quick Pick" option for accessing
		extend characters codes.  Version 1.5, an update to version
		1.4 on disk number 581.  Binary only.
		Authors:  Syd Bolton, Chris Timmerberg, and Colin Vernon.

Run68017	Provides run time emulation of about 30 of the 68020 instruc-
		tions with a 68000.  Only the emulated instructions can use the
		new 68020 addressing modes.  Uses a gagdet to enable/disable
		emulation.  An upgrade from Run68013 on disk number 756.
		Includes source in assembly.
		Author:  Kamran Karimi

Split		The opposite of the AmigaDos JOIN command.  Use it to split
		textfiles that are too large to edit on your computer, files
		for email-delivery that have a file size maximum... etc.
		The created files have the same name as the original except
		with an extension of two digits.  Version 1.0, binary only.
		Author:  Jonas Svensson

StripANSI	Removes all ANSI codes from a text file so that only the bare
		text remains.  It is useful for editing terminal program cap-
		ture buffers.  Two versions are provided: one for the command
		line (CLI) and one with a full Intuition interface.  You can
		selectively strip certain codes, and generate a report.  New
		features include more codes, better help, and tab expansion.
		Version 1.2, an update to version 1.0 on disk number 581,
		Includes source in 'C'.
		Author:  Syd L. Bolton

CONTENTS OF DISK 799
--------------------

AII		"Archiving Intuition Interface" allows you to access many
		features of the LHa archiver via the WorkBench.  Requires
		reqtools.library.  Version 1.03, first release.  Requires
		KickStart 2.0 or higher.  ShareWare, binary only.
		Author:  Paul Mclachlan.

HackLite	An evolved version of the public domain game Hack, written by
		Jay Fenlason, Andries Brouwer, Don Kneller and various others.
		Hack Lite is a dungeon adventure game in the style of Rogue,
		Hack, Moria, etc.  It uses a customizable graphical dungeon
		display.  The package includes a simple-to-use installation
		program, and a "Preferences"-style configuration editor.  Many
		new objects, traps, monsters and ways to die have been added.
		Saved games are now much smaller, and a "Tournament mode"
		allows several players to compete for the highest score playing
		in identical dungeons.  Utilities included with Hack Lite were
		written by Jim Cooper and Doug Walker.
		Author:  Alan Beale

CONTENTS OF DISK 800
--------------------

ColorSaver	A "pop-up-anywhere" (almost!) color palette commodity with
		several features I could not find in other palette tools.
		Features include:  Load/Save color palettes; Sliders select-
		able between RGB/HSV; Copy, Swap, Range Functions; Complement
		selected color; Left/right shifting of the entire palette;
		Ability to permanently alter (patch) the color tables of execu-
		tables with a statically allocated color table.  Requires
		OS2.04 or greater.  Version 0.84 (alpha release), includes
		source.
		Author:  Dan Fish

DocDump		A print utility that puts 4 pages of text on one sheet of
		paper, including page-headers.  Beside the normal Dump mode,
		a double-sided Booklet mode is also available.  DocDump uses
		its own printer drivers, making one yourself is easy.
		Version 3.6, binary only, shareware.
		Author:  Robert Grob

Enforcer	A tool to monitor illegal memory access for 68020/68851, 68030,
		and 68040 CPUs.  This is a completely new Enforcer from the
		original idea by Bryce Nesbitt.  It contains many new and
		wonderful features and options and no longer contains any
		exceptions for specific software.  Enforcer can now also be
		used with CPU or SetCPU FASTROM or most any other MMU-Kick-
		start-Mapping tool.  Major new output options such as local
		output, stdout, and parallel port.  Highly optimized to be as
		fast as possible.  This is version 37.28, an update to version
		37.26 on disk number 773.  Requires V37 of the OS or better
		and an MMU.
		Author:  Michael Sinz

IffBoot		Inspired from BOOTLOGO by Markus Illenseer, allows you to show
		any IFF file during bootup that will exit when the WB appears.
		Version 1.0, requires OS 2.04 or greater, binary only, includes
		some sample pictures.
		Author:  Colin Bell, some IFF pics by Justin Trevena

Least		A small, handsome, text displayer that only supports those
		functions most frequently used.  String searching is performed
		with the very fast Boyer-Moore algorithm.  Also checks itself
		for link viruses.  Runs from both WorkBench and CLI.  Separate
		version - LeastP - also deals with powerpacked files. Has
		been tested under both Kickstart 1.3 and 2.0.  Version 0.04,
		binary only.
		Author:  Thorsten Koschinski

Moontool	A port of John Walker's moontool program for UNIX. It gives a
		variety of statistics about the moon, including phase, dist-
		ance, angular, size and time to next full moon.  A schematic
		of the current phase is also shown as a picture.  This is
		illustrative only; the accurate phase is shown in the text.
		Version 1.0, binary only.
		Author:  John Walker, Amiga port by Eric G. Suchanek

MungWall	Munges memory and watches for illegal FreeMem's.  Especially
		useful in combination with Enforcer.  Output can go to either
		the serial or parallel port.  Includes a new MungList program
		that examines used memory areas for MungWall tag info, and
		outputs a list of who owns the various pieces of allocated
		memory, their sizes, etc.  Can even identify the owner of the
		memory by task name.  This is version 37.58, an update to
		version 37.54 on disk 707.  Binary only.
		Author:  Commodore Amiga; submitted by Carolyn Scheppner

======================================================================
|\/ o\  Fred Fish, 1835 E. Belmont Drive, Tempe, AZ 85284,  USA
|/\__/  1-602-491-0048 {asuvax,mcdphx,cygint,amix}!fishpond!fnf
======================================================================

