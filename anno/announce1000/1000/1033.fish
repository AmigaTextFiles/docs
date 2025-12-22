From zerkle Tue Jan 10 21:44:49 1995
Received: by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA19621; Tue, 10 Jan 95 21:44:48 PST
Received: from fishpond.amigalib.com (amigalib.com) by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA19609; Tue, 10 Jan 95 21:44:39 PST
Message-Id: <9501102249.AA04446@fishpond.amigalib.com>
To: announce@cs.ucdavis.edu (comp.sys.announce moderator)
Date: Tue, 10 Jan 1995 22:49:33 +0700 (MST)
From: "Fred Fish" <fnf@fishpond.amigalib.com>
X-Mailer: ELM [version 2.4 PL23]
Content-Type: text
Content-Length: 13477
Subject: SUBMIT Fishing Report - Jan 95
Errors-To: zerkle@cs.ucdavis.edu
X-Server: Zserver v0.90beta
Status: RO

submit


		T H E    F I S H I N G    R E P O R T

			     by Fred Fish

			Amiga Library Services

			     Jan 10, 1995

======================
FLOPPY DISKS 1001 & UP
======================

When we stopped doing floppy distributions last April, we thought we had
made suitable arrangements for the floppy library to be continued by a third
party.  However, after almost 9 months and not seeing any floppies, we have
decided to give this responsibility to someone else.  The new "Keepers of
the Floppies" are Martin Schulze and Thomas Strauss.

As before, the plan is that selected new material will be taken from each
FreshFish CD and organized into floppy sized chunks, and made ready for
distribution before the release of the next FreshFish CD.  We expect an
average release rate of around 20 floppies per month.

One thing that hasn't changed in our plans though is that we will continue
to only distribute material on CD-ROM.  Martin, Thomas, and certainly other
interested third parties, should have no trouble supplying the demand for
copies of the floppy distribution.

===============
MKISOFS UPGRADE
===============

It has recently come to our attention that some people using mkisofs to
master CD-ROM's using RockRidge extensions have experienced problems with
the resulting CD's interoperating with non-Amiga systems.  This may be due
to bugs in the RockRidge support in the current mkisofs port, which is based
on version 1.00, released almost a year ago.  There is also the possibility
that there are other latent bugs in the generated ISO images that may cause
problems under certain circumstances.

In a marathon hacking session yesterday, I not only upgraded our internal
version to the current 1.01 baseline, but leapfrogged ahead to the current
prerelease 1.02 test version.  In the process, about 800 lines of source
code changes were merged, which represents about 25% of the total mkisofs
source code.  Of these 800 lines, a very large percentage was in the
RockRidge support, so I suspect that many bugs have been fixed by the
mkisofs author and other developers.  These fixes should automatically
appear in the next release of the Amiga version, sometime in early February.
We urge anyone that has suggestions for improvements or details about
possible bugs to submit them now, so they can be considered in time for the
next release.

We will also incorporate other useful changes as they become obvious to us,
possibly including a graphical user interface that should make the program
more user friendly.  One useful new feature in our current internal test
version is the capability of the CD-ROM creator to specify the precise name
mapping between ISO level 1 names in the regular ISO data structures, and
the names used in the RockRidge section.  We are also investigating whether
it is feasible or not to use RockRidge attributes to preserve all the normal
AmigaDOS filesystem attributes, such as the script bit, pure bit, etc.  We
are still looking for someone to port cdwrite, a tool for writing ISO images
to a specific CD-R recorder, or else write an AmigaDOS specific equivalent.

============
FRESHFISH CD
============

As we write this we are hard at work on FreshFish Volume 8, which is
expected to go into production in the last week of January and start
shipping the first week of February.

The major piece of news about the FreshFish series is that it will be
expanding to a 2-CD set, starting with Volume 8, with no anticipated
increase in price!  For the last couple of issues we have been cramped for
space (I never thought I'd say a CD is too small), and the only way we can
continue to provide an increased flow of new material and updates to the
useful tools portion is to either expand to a 2-CD set, or change the
structure.  Rather than reducing the usefulness of the CD's by eliminating
the BBS section or only supplying some material in archived form, we have
decided to expand to a 2-CD set.

We expect future issues to continue to be released on a two month cycle.
For this one release cycle, the extra month between Volume 7 and Volume 8
gave us some time to expand the base set of material on the CD by including
more useful tools, programs, libraries, documentation etc that will continue
to be updated with each release.  We have also expanded the "GNU" tree to
include more non-GNU tools and utilities, all with full source and binaries
built directly from that source, to the extent that it now takes almost 24
hours to recompile the binaries on an A4000 equipped with a 40Mhz
WarpEngine, 50 Mb of memory, and several 8ms seek time Seagate Barracuda
drives!

If things proceed as we expect and this section of the CD expands by a
factor of 4 or more, we may have to seriously consider building a cross
development environment on a Risc machine just to get reasonable
recompilation turn around times, with a final compile being done on the
Amiga as a cross check, right before release of the CD.  We could also hope
for fast 68060 accelerators to appear soon.

============
GOLDFISH  CD
============

GoldFish Volume 1, a 2-CD set released in April of 1994, provides a complete
archive of the 1000 "fish disk" floppy library, with all the disks provided
in both archived and ready-to-run form.  It can be used to produce master
floppy disks for further duplication and distribution, using a simple to use
program that is provided on the CD-ROM.  It can also be used by BBS or
anonymous ftp sites to provide convenient electronic access to all the
material from the floppy library.

GoldFish Volume 2, a 2-CD set released in December of 1994, includes all the
new submissions included on the first 7 volumes of the FreshFish CD series,
with all the material updated to the latest available version as of the date
of completion of the GoldFish CD.  As with Volume 1, all of the material is
included in both archived and unarchived form.  It also includes the latest
versions of the "useful tools" included on each FreshFish CD, such as the
GNU utilities, reviews of hardware and software, etc.

Future plans call for GoldFish releases at approximately six month
intervals.

============
LIGHT-ROM CD
============

In cooperation with Lightwave artist Michael Meshew, we now offer a new CD
called "LIGHT-ROM".  This is a 647 Mb CD dedicated to 3D artists all over
the world, and contains Lightwave objects, scene files, textures, bump maps
(JPEG, IFF, & TARGA), fonts, thumbnail renderings, and text files with
advice from the rendering pros.  It also contains a "Showcase Directory",
displaying the talents of selected Lightwave artists from all over the
world.

LIGHT-ROM will be updated at approximately 6 month intervals.  Contributors
will be eligible for a free copy.  The retail price is $39.95 plus $3.95 for
shipping and handling.

=============
FRESHFONTS CD
=============

In cooperation with fonts enthusiast Daniel Amor, we published a new fonts
CD in early November.  This CD was published as an experiment under
conditions similar to the Meeting Pearls CD, whereby users that find the CD
interesting and useful are expected to make a shareware like donation to the
creators of the CD.

Thousands of these CDs were distributed free of charge at the Computer '94
show to customers at Stefan Ossowski's Schatztruhe booth.  We have also
distributed almost all of the CD's that we had allocated for our customers
that receive other CD's during November and December.  So far the results
have been quite disappointing, with at most a few hundred dollars in
donations received.  We will declare the experiment with the share
compilation version officially over on February 1st, 1995, and provide a
summary of the results at that time.

Since there does appear to still be a good demand for this CD, with Daniel's
approval we plan to do another production run in late January.  However
these CD's will not be given away free, instead they will be sold at prices
comparable to our other products.

==============
TURBOCALC V2.0
==============

We are an authorized U.S. distributor of TurboCalc V2.0, a very powerful
Amiga spreadsheet program.  TurboCalc has extensive formatting options,
supports many different font formats, more than 40 different number, time,
and date formats, more than 100 functions covering arithmetic and financial
needs, more than 120 ARexx and macro instructions, integrated database, and
more.  TurboCalc retails for $115 plus $6.95 for shipping and handling.

=========
AMINET CD
=========

We are an authorized U.S. distributor of the new Aminet CD.  Both the Aminet
Gold and the Aminet Share are available.  Subscriptions for both CD's are
also available, at $59.95 per year for the Gold version and $44.95 for the
Share version.  There are expected to be four releases per year, so the
subscription is actually for 4 CD's, regardless of when they actually end up
shipping.

The only physical difference between the Aminet Gold CD and the Aminet Share
CD is the front cover artwork.  Built into the price of the Aminet Gold CD
is an automatic contribution to the creators of the CD and sufficient margin
to make the disk attractive to low volume resellers and retail sales
outlets.  Users who purchase to the Aminet Share version are expected to
make their own contributions directly to the creators if they feel that the
CD is worthwhile and wish to support creation of future Aminet CD's.

We currently have Volume 4 (Nov 1994) in stock.  The next volume is expected
to arrive in early February.

=================
MEETING PEARLS CD
=================

We now have the second pressing of the Meeting Pearls CD in stock.  This CD
contains about 150 high quality and high resolution fractals, a ready to run
version of PasTeX which includes fonts for FAX and 600 DPI printers, a ready
to install version of the Amiga NetBSD port, and many other ready to run
applications including UMS, DaggeX, a lot of utilities, games, etc.

Because the version of NetBSD included on the CD-ROM includes encryption
code that is restricted for U.S export, all imported CD's will only be
available for resale within the U.S.

=================================
SPECIAL BBS VERSION OF FROZENFISH
=================================

By special request from BBS operators, we are issuing a limited number of a
custom version of the April 1994 FrozenFish CD, updated with some new
material, and called "FrozenFish-PC".  This CD has the complete contents of
each floppy disk 1-1000 in a single archive and all directory and file names
are ISO-9660 level 1 compliant (8.3 format, uppercase only, etc).  This
means that the CD is completely compatible with IBM-PC based systems, unlike
our regular Amiga CD's which are closer to ISO-9660 level 2.

For at least the next month or so, each copy of this CD is an individually
created CD-R "gold disk", which is completely compatible with mass
production CD's and CD-ROM drives.  Sometime soon we expect to do a small
production run of this CD and people who received the CD-R versions can
upgrade to the production version for $5 plus shipping costs.  The price of
this CD is $24.95 for either version, because of the lower volumes and thus
higher production costs per CD.

=====================
ATTENTION ALL AUTHORS
=====================

Amiga Library Services is actively looking to expand our CD-ROM offerings.
If you are an Amiga user with a good idea for an Amiga specific CD-ROM,
please consider letting us act as your publisher.  We will handle all
details concerning actual production of the CD-ROM, advertising, sales, and
distribution.  All you have to do is have a good idea and to be willing to
spend the necessary time to create a ready-to-publish master file tree for
the CD.

======================
ELECTRONIC SUBMISSIONS
======================

Material for inclusion in the CD-ROM distribution can now be submitted
electronically via anonymous ftp.  Please upload your submissions as an lha
archive, one archive per submitted program, to the ftp incoming directory on
ftp.amigalib.com.  Please include a "Product-Info" file in the lha archive.
This file describes the material using a standard format that is recognized
by the new version of KingFisher and by tools that we use to automatically
generate information about the CD contents.  If you don't have a copy of the
Product-Info specification, it can be retrieved via anonymous ftp from
ftp.amigalib.com, in directory pub/amiga.

If you do not have access to anonymous ftp, you can still submit material
electronically by mailing a uuencoded lha archive to
"submissions@amigalib.com".

=================
ELECTRONIC ORDERS
=================

You can email orders to be paid via credit card (VISA or MasterCard only) to
"orders@amigalib.com".  All such orders must include the full name of the
card holder, the card number, the expiration date, and a daytime phone
number which can be used to verify the order.  We will attempt to
acknowledge all such received orders via return email, and to verify an
unspecified percentage via phone calls.

Please note that it is considered to be somewhat risky to send credit card
information via electronic mail without encrypting it.  We are not currently
ready to start receiving encrypted orders, but may be able to do so in the
future.  We cannot be responsible for any fraudulent use of credit card info
that is intercepted by a third party during it's transmission.

For an electronic copy of our order form send mail to "orders@amigalib.com".

