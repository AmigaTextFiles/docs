From megalith!errors@uunet.uu.net Mon Jun 20 03:37:04 1994
Received: from daffodil.cs.ucdavis.edu by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.5)
	id AA04370; Mon, 20 Jun 94 03:37:02 PDT
Received: from relay3.UU.NET by daffodil.cs.ucdavis.edu (4.1/UCD.CS.2.5)
	id AA22376; Mon, 20 Jun 94 03:31:45 PDT
Received: from uucp5.uu.net by relay3.UU.NET with SMTP 
	(rama) id QQwvcb22310; Mon, 20 Jun 1994 06:29:47 -0400
Received: from megalith.UUCP by uucp5.uu.net with UUCP/RMAIL
        ; Mon, 20 Jun 1994 06:29:49 -0400
Received: by megalith.miami.fl.us (V1.16.20/w5, Dec 29 1993, 21:22:55)
	  id <1oc3@megalith.miami.fl.us>; Mon, 20 Jun 94 02:34:36 EDT -0400
Sender: overlord@megalith.miami.fl.us
Errors-To: errors@megalith.miami.fl.us
Warnings-To: errors@megalith.miami.fl.us
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Reply-To: torsten@diku.dk (Torsten Poulin)
Message-Number: 861
Newsgroups: comp.sys.amiga.announce
X-Newssoftware: CSAA NMS 1.2
Message-Id: <overlord.1o9s@megalith.miami.fl.us>
Date: Mon, 20 Jun 1994 02:34:34 -0400 (EDT)
From: torsten@diku.dk (Torsten Poulin) (CSAA)
To: announce@cs.ucdavis.edu (CSAA-Submissions)
Subject: (CSAA) Awk for Amiga
Status: RO

TITLE

     AT&T awk

VERSION

     Amiga port v1.0 of AT&T source dated April 22, 1994 (no, its
     author(s) didn't give it a version number).

AUTHOR

     Written by AT&T.

     Amiga port by Torsten Poulin (torsten@diku.dk).

DESCRIPTION

     awk is a pattern-directed scanning and processing language
     described in A.V. Aho et al., "The AWK Programming Language",
     Addison-Wesley, 1988.

     It makes it possible to handle tasks like changing the format of
     data, printing reports, finding items with some property, and
     adding up numbers with very short programs, often only one or two
     lines long.  An awk program is a sequence of patterns and actions
     that tell what to look for in the input data and what to do when
     it is found. The patterns can select lines with regular
     expressions, comparison operations on fields, variables, strings,
     etc. or a combination thereof. The actions, which look a lot like
     C without declarations, may perform arbitrary processing on the
     selected data.

     Programs written in awk are generally much smaller than they
     would be in a conventional imperative programming language like
     C. Being terse makes awk quite useful for prototyping larger
     programs, too.

     This is a fully functional version of awk as described in the
     aforementioned book. This means that everything works, including
     "internal" pipes. In addition, AmigaDOS patterns can be used on
     the command line. Compiled with SAS/C 6.51.
     
SPECIAL REQUIREMENTS

     The program runs under all versions of AmigaDOS. If you run
     AmigaDOS 1.x and have arp.library installed, it will be used for
     expanding patterns on the commandline. It is not a requirement,
     though. Under 2.x or 3.x, dos.library handles the expansion.

HOST NAME

     Available on Aminet, e.g., ftp.luth.se (130.240.18.2).

DIRECTORY

     /pub/aminet/util/cli

FILE NAME

     ATT-awk-1_0.lha (158288 bytes)

PRICE

     Free!

DISTRIBUTABILITY

     Copyright (C) AT&T 1993
     All Rights Reserved

     Permission to use, copy, modify, and distribute this software and
     its documentation for any purpose and without fee is hereby
     granted ... [etc., please refer to the documentation accompanying
     the program].

--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.

============================================================================
This is part of a mailing list gateway maintained by Carlos Amezaga.  Bugs
& comments to CSAA@megalith.miami.fl.us.  Subscribes, UnSubcribes, help and
faq requests should be sent to announce-request@cs.ucdavis.edu.



