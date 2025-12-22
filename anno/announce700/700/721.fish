Path: NOT-FOR-MAIL
Reply-To: fnf@cygnus.com (Fred Fish)
Message-Number: 721
Followup-To: comp.sys.amiga.misc
Distribution: world
Newsgroups: comp.sys.amiga.announce
Approved: overlord@megalith.miami.fl.us
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
From: fnf@cygnus.com (Fred Fish)
Subject: Changes file from Mar/Apr FreshFish CD-ROM
Message-Id: <overlord.0q9n@megalith.miami.fl.us>
Date: Mon, 28 Feb 94 21:34:59 EST

		   Changes Since Last FreshFish CD-ROM
			  (Updated 2/27/94)


This file lists significant changes since the last FreshFish CD-ROM,
except for the usual and expected differences like all the new material
submitted since the last FreshFish CD-ROM.

*** PufferFish

The BBS section contains the beta test release of PufferFish, a
utility by Peter Janes, which can be used to recreate disks in the
floppy distribution from archives and CRC lists that are included in
the BBS tree.  This is the utility (or one of the utilities) that will
be included on the GoldFish (1000 disk archive) cdrom to make it
easier for people to create master floppy disks for further
duplication and distribution.

*** A-Kwic

A-Kwic is provided, along with a database of most new programs on this
CD-ROM, to make it easier to find things.  A new version of KingFisher
is in the works, which will also help alleviate the problem of finding
material, when it is ready.

*** Useful/Sys

Many of the directories that used to be in Useful, that supplement the
usual system directories, have been moved to Useful/Sys.  One
particularly noticable side effect of this is that the CD-ROM startup
script (FFCD-Startup) is now in Useful/Sys/S.

*** 3.1 Partial Native Developer Update Kit

The licensable files from the CBM 3.1 Native Developer Update Kit have
been included in Useful/dist/cbm/V40, along with the earlier versions
in Useful/dist/cbm/V37 and Useful/dist/cbm/V36.  The includes and
libraries in the directories searched by the GNU C compiler and linker
have been updated to match.

*** Ports of GNU utilities

The GNU utilities have all moved to the subdirectory GNU.  This
includes sources, binaries, and patch files.

The following new ports of GNU code have been added:

	f2c		1993.04.28
	gdb		4.12		(port incomplete)
	ghostscript	2.6.1

  Note:	GDB 4.12 has been ported to the extent that you can
	build an AmigaDOS executable that knows how to load
	and examine executables from non-AmigaDOS systems.
	Much work remains.  See the gdb-4.12-README file in
	gnu:src/diffs.

The following ports have been updated:

	flex		2.4.5	->	2.4.6
	gawk		2.15.3	->	2.15.4
	gcc		2.5.7	->	2.5.8
	groff		1.08	->	1.09
	indent		1.8	->	1.9.1
	libg++		2.5.2	->	2.5.3
	make		3.69	->	3.70
	shellutils	1.9.2	->	1.9.4

In addition, all ports have been modified to find their files under
the directory assigned to "GNU:".  This means that only one assignment
must be changed when moving the tools to other locations or switching
between tools installed in different locations.

*** AmigaGuide Files For GNU Utilities

For those GNU utilities which have texinfo files, AmigaGuide versions
of the documentation have been produced and are included in GNU:guide.

*** SAS C Incompatibility Removed

Previous releases of various GNU tools wanted to use an assign of LIB:,
which conflicts with Lattice/SAS C, which wants to use the same assign.
This conflict has been removed.  However, note that the Lattice C
distribution contains utilities that have the same name as some GNU
utilities (diff, grep, touch, wc).  If these are found in your search
path before the GNU versions, you may not get the results you expect.
I simply removed them in my version of Lattice C.

*** CDTV/CD32 Bootability Suspended

Because of the relatively high license fees that needed to be paid to
Commodore for each CD-ROM sold (more than the cost of actually
pressing the CD-ROM), and the relatively small numbers of users that
currently actually make use of this feature, I have decided to switch
mastering software and produce royality free CD-ROM's.  The money
previously spent on these fees can be put to better use to improve the
CD-ROM distributions for the vast majority of current users that don't
care about CDTV or CD32 bootability.

This does not mean that the CD-ROM's cannot be used on a CDTV or CD32,
just that users that wish to use them must acquire additional
hardware.  In the case of the CDTV, all that is required is a floppy
disk drive to boot from, and a suitable bootable WorkBench disk.  In
the case of the CD32, an additional requirement is an expansion box
that provides a floppy disk port.  Such expansion boxes are currently
under development by a number of different companies.

It is possible that when I get time I will put together a suitable
WorkBench disk containing all the necessary support for ParNET,
SerNET, ParNFS, etc, and offer this for direct distribution (but not
redistribution) under my current WorkBench licenses.

It is also possible that when demand warrents it, I may do special
versions of the CD-ROM's that are CDTV/CD32 bootable, or else produce
CD-ROM's that are targeted directly for CDTV/CD32 users with
considerably different content than current CD-ROM's.

So these moves do not mean I am abandoning CDTV/CD32 users, or
ignoring their needs, just that I am attempting to make the best use
of available resources, and the payment of license fees on every
CD-ROM was not judged to be cost effective at this time.

--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.
