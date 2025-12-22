From amiga@cs.unsw.oz.au Mon Feb  8 02:47:19 1993
Received: from usage.csd.unsw.OZ.AU by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.0)
	id AA07211; Mon, 8 Feb 93 02:47:13 PST
Received: by usage.csd.unsw.OZ.AU id AA24757
  (5.65c/IDA-1.4.4 for announce@cs.ucdavis.edu); Mon, 8 Feb 1993 21:47:29 +1100
Return-Path: amiga@cs.unsw.oz.au
Received: From red08 With LocalMail ; Mon, 8 Feb 93 21:46:47 +1100 
From: amiga@cs.unsw.oz.au (Amiga Utilities)
To: announce@cs.ucdavis.edu
Date: Mon, 8 Feb 93 21:46:30 +1100
Message-Id:  <930208104632.5399@cs.unsw.oz.au>
Subject: UNSWProlog announcement
X-Mailer: ELM [version 2.3 PL11]
Status: RO

 This announcement is posted by amiga@cs.unsw.oz.au, which is The
 Amiga Utilities account that I administer, however the contact
 address is given as s1013734@cs.unsw.oz.au, which is my student
 account.  I would appreciate it if you could remove any references
 to amiga@cs.unsw.oz.au from the article header as I don't want
 any mail being directed here in case a new administrator takes
 over.

		Thanks,
			Peter.

     ///    amiga@cs.unsw.oz.au
    ///     The amiga utilities account.
\\\///      University of New South Wales
 \XX/       Sydney, Australia

----- Snip, snip ---------8<------>8--------- snip ,sniP -----

                   Announcing UNSW Prolog 4.2
                       Amiga version 1.0

TITLE
	UNSW Prolog 4.2

VERSION
	Amiga version 1.0

AUTHOR
	Original author: Claude Sammut, University of NSW
	Amiga port:      Peter Urbanec, University of NSW
			 s1013734@cs.unsw.oz.au
			 Union Box 12
			 C/- University of NSW Union
			 P.O. Box 173
			 Kingsford NSW 2032
			 Australia

DESCRIPTION
	UNSW Prolog 4.2 is a Prolog interpreter currently
	in use at the School of Computer Science and Enginnering
	at the University of New South Wales, Sydney, Australia.
	This is the AmigaDos port of this interpreterer.

	Amiga version 1.0 is the first public release. It works
	under Workbench 2.x (it has not been tested with 1.3,
	but does not contain any 2.x specific code) and includes
	an optimized 68030 version of the executable. This 68030
	version does not contain 6888(1|2) code, so users without
	FPU's can benefit as well. This release is Enforcer clean.

SPECIAL REQUIREMENTS
	None

HOST NAME
	ftp.cs.unsw.oz.au (149.171.16.16)

DIRECTORY
	pub/amiga

FILE NAMES
	UNSWProlog.lha
	UNSWProlog.readme

PRICE
	Donation requested, but required.

DISTRIBUTABILITY
	Copyrighted but free.  

OTHER
	I expect this release to filter out to other FTP sites
	eventualy.  Keep an eye on archie.au and wuarchive.wustl.edu
	or ask your nearest archie database if you have problems
	obtaining this file from ftp.cs.unsw.oz.au.


From amiga@cs.unsw.oz.au Mon Feb  8 05:22:19 1993
Received: from usage.csd.unsw.OZ.AU by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.0)
	id AA07923; Mon, 8 Feb 93 05:22:14 PST
Received: by usage.csd.unsw.OZ.AU id AA27734
  (5.65c/IDA-1.4.4 for zerkle@cs.ucdavis.edu); Tue, 9 Feb 1993 00:22:31 +1100
Return-Path: amiga@cs.unsw.oz.au
Received: From red08 With LocalMail ; Tue, 9 Feb 93 00:21:56 +1100 
From: amiga@cs.unsw.oz.au (Amiga Utilities)
To: zerkle@cs.ucdavis.edu (Dan Zerkle)
Date: Tue, 9 Feb 93 0:21:44 +1100
Message-Id:  <930208132147.7496@cs.unsw.oz.au>
Subject: Re:  UNSWProlog announcement
In-Reply-To: <9302081056.AA07260@toadflax.cs.ucdavis.edu>; from "Dan Zerkle" at Feb 8, 93 2:56 am
X-Mailer: ELM [version 2.3 PL11]
Status: RO

Once upon a time Dan Zerkle said:
> 
> Ok, I'll put this up.  Before I do, though, would you like to
> include any more interesting information about the interpreter?
> Basically, all you say is that interprets Prolog.  Is it any better
> than Stony Brook Prolog?

Well, I have not seen the Stony Brook Prolog, all I heard was that
it has some bugs.  I reckon my port is bug free :-)

I suppose another thing to mention would be that it includes a large
amount of on-line help accessible from the interpreter, the ability
to execute other processes either synchronously or asynchronously and
a customizable initialisation file. It also examines environment
variables to use your favourite text editor. Comes with a fair few
example files and a manual in troff format. It has been compiled
with profiling on, which will allow the user to optimize his/her
code. I found the speed adequate for all of my Artificial Inteligence
assignments, which turned out to be quite large. However, I have no
other implementations of Prolog for Amiga to compare the performance.

> Also, Prolog tends to be a memory hog.  How much mem does this take to
> run reasonably well?

Executable is less than 64k and it runs quite hapilly in 1Meg, I pressume
it would work in 512k, but have no machine to test this on.

> I can easily change your contact address.  Why didn't you just post
> from the one you wanted?

The whole department is getting re-organised around here, since the
holidays are almost over and everyone comes back to uni during first
week of March (If it was up to me I'd stay at the beach for the next
3 months, but I got to get this degree out of the way :-) So, anyway,
my student account can only be accessed from 3 labs. One of them is
undergoing reconstruction this week, and the other 2 are closed until
the start of session.

> I'll bet you didn't expect this Yank to be awake at this time in the
> morning (3AM here on the left coast).  I was playing NetHack 3.1 and
> got a little carried away.

Well, it is just after midnight here in Sydney (on the populated coast :-)
and I really should have been out of this lab by 4:30, but since the
security guards haven't found me yet, I am sifting through several
thousands of articles of news. I am even reading groups that I haven't
been to in ages, like comp.sys.amiga.graphics.


     ///    amiga@cs.unsw.oz.au
    ///     The amiga utilities account.
\\\///      University of New South Wales
 \XX/       Sydney, Australia

