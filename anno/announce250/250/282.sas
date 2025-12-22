From jamie@unx.sas.com Fri Nov 27 08:31:00 1992
Received: from lamb.sas.com by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.0)
	id AA23725; Fri, 27 Nov 92 08:30:57 PST
Received: from mozart by lamb.sas.com (5.65c/SAS/Gateway/10-28-91)
	id AA15918; Fri, 27 Nov 1992 11:30:46 -0500
Received: from cdevil.unx.sas.com by mozart (5.65c/SAS/Domains/5-6-90)
	id AA08006; Fri, 27 Nov 1992 11:28:33 -0500
Return-Path: <jamie@cdevil.unx.sas.com>
Received: by cdevil.unx.sas.com (5.65c/SAS/Development Generic/11-9-91)
	id AA21630; Fri, 27 Nov 1992 11:28:33 -0500
From: James Cooper <jamie@unx.sas.com>
Message-Id: <199211271628.AA21630@cdevil.unx.sas.com>
Subject: Re: SAS/C (R) 6.1 Maintenance Release
To: zerkle@cs.ucdavis.edu (Dan Zerkle)
Date: Fri, 27 Nov 1992 11:28:31 -0500 (EST)
In-Reply-To: <9211260832.AA15024@toadflax.cs.ucdavis.edu> from "Dan Zerkle" at Nov 26, 92 00:32:02 am
X-Mailer: ELM [version 2.4 PL11]
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Length: 4002      
Status: RO

> Thanks for the announcement of the compiler update.  I like getting
> information from real corporations, and my readers do, too.
>
> If you announce an ftp upload, you need to give the exact destination
> directory of the file.  This makes life much easier on the people who
> do ftp-by-email.
>
> It would be nice if you would add some more information about what
> sort of things this update adds to the system.  If there are any
> particularly annoying bugs fixed, you might mention those.  Don't
> overdo it, of course.
>
> As mentioned in the guidelines for the group, you should _mail_ your
> posts to announce@cs.ucdavis.edu.  This looks like you tried to post
> it.  Sometimes those get forwarded to me, sometimes not.  Sometimes
> the return address is ok, sometimes not.  Mail is much safer (faster,
> too).
>
> You might wish to upload the archive to a USA ftp site.  I would
> recommend wuarchive.wustl.edu.  The lines across the Atlantic are not
> exactly speedy.
>
> Anyway, just add the info and mail the post in again, and I'll put
> it up.
>
>                                       -Dan

Thanks, Dan.  I just wanted to make sure it was announced, but I've
never read the guidelines for the group.  Sorry for the lapse of
"netiquette".  :-)

Also, between the time the file was uploaded (by someone else), and the
time I tried to post this announcement, the file was moved to a
different directory, anyway.  Well, here's the real scoop:

========================================================================

Subject: SAS/C (R) 6.1 Maintenance Release

TITLE

        SAS/C (R) Maintenance Release

VERSION

        6.1

AUTHOR

        SAS Institute Inc.

DESCRIPTION

This maintenance release patches the Version 6.0 release of the SAS/C
Development System for the Amiga.  Patches are installed via Commodore's
Installer, and the original 6.0 disks are required during the installation
process.

The patch archive is named "sc6_1.lha", and contains both text and
AmigaGuide documents describing all patches made.  Many pieces of the
compiler package are patched with this release.  Though most of the patches
are bug fixes (such as fread() not setting the EOF bit, so that feof()
wouldn't work), a few patches add extra functionality (such as Public
Screen support in SCMSG, etc.).

This patch is freely-redistributable, and has been initially uploaded to
ftp.luth.se (directory aminet/biz/patch), BIX, and various public BBSs.  It
will be uploaded to CompuServe and Portal shortly.  Please, pass this file
as far and wide as possible, that all SAS/C owners may benefit from this
release.

NOTE: The patch has already started to spread to all mirrors of
amiga.physik.unizh.ch, including wuarchive.wustl.edu in directory
mirrors/amiga.physik.unizh.ch/amiga/biz/patch for US access.

The following files will be modified during the 6.1 patch installation
process:

Drawer       Files
------       -----

SC:          read.me

SC:C         smake, slink, se, scopts, scmsg, cpr, cprx, cprk, scompact,
             omd, dumpobj, hypergst, asm, oml, lstat, lprof, sc5, tb,
             lctosc

SC:LIBS      sc1.library, sc2.library, schi.library, scpeep.library,
             sekeymap.library, scdebug.library, sclist.library

SC:ENV       se.dat

SC:LIB       all .lib files and startup modules

SC:INCLUDE   fcntl.h, stat.h, dos.h, mffp.h, mieeedoub.h, m68881.h,
             stdarg.h, sys/dir.h, proto/all.h, proto/layers.h,
             pragmas/intuition_pragmas.h

SC:REXX      findsym.se, showcli.cpr, showprocess.cpr

SC:HELP      sc_prob.guide, sc_lib.guide, sc_change.guide, scmsg.guide,
             sc_util.guide, sc.guide, cpr.guide

SC:SOURCE    autoopenfail.c, _main.c, _oserr.c, intuitlib.c, _cxferr.c,
             c.a, cback.a

SC:EXTRAS    TTX/instructions, CED/rexx/ced/Compile.ced
---------------------------------------------------------------------------

Jim Cooper
Tech Support
SAS/C Development System

(SAS/C is a Registered Trademark of SAS Institute Inc.)

