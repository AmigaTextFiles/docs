From dgc3@midway.uchicago.edu Fri Oct  2 18:45:25 1992
Received: from midway.uchicago.edu by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.0)
	id AA05706; Fri, 2 Oct 92 18:45:24 PDT
Received: from ellis.uchicago.edu by midway.uchicago.edu Fri, 2 Oct 92 20:45:18 CDT
Received: from localhost by ellis.uchicago.edu (4.1/UCCO-1.0A)
	id AA26216; Fri, 2 Oct 92 20:45:17 CDT
Message-Id: <9210030145.AA26216@ellis.uchicago.edu>
To: announce@cs.ucdavis.edu
Subject: FTP announcement
Date: Fri, 02 Oct 92 20:45:16 -0500
From: dgc3@midway.uchicago.edu
Status: R

TITLE
	login (a.k.a. OmniLock)

VERSION
	1.00

DESCRIPTION
	Yeah, another Amiga login-screen toy security setup to wow
	your friends.  Features include:

	- custom variant of NDS-DES crypt() password encryption (like
	in Unix) for greater security
	- "nu" for adding new users
	- "passwd" for changing password
	- "chfn" for changing user name
	- "chsh" for changing shell & home directory
	- "finger" for fetching user info, allows .plan and .project
	files
	- "last" for listing logins (all logins or by user-id)
	- GadTools (2.0+ only) login screen
	- login screen dims after user-definable time delay
	- can be run as a console lock after startup
	- modifies environment so you can control scripting
	- customizable for your Amiga's very own name

	Comes equipped with a functional root user, ability to add new
	users, change root, etc. immediately, with no shareware
	registration prerequisite.  Instructions on secure
	installation included.

REQUIREMENTS
	Release 2.0 or greater of the Amiga OS, and an Amiga to run it
	on.

CHANGES
	(from v0.80)
	- commands "last" and "finger" are new
	- now logs all valid logins and incorrect password attempts
	from any member program
	- now dims screen after a period of unuse.  Does not conflict
	with other screensavers.
	- now secures system after startup if Workbench can be closed.
	- a little nicer to look at while running

AVAILABILITY
	anonymous ftp from:

	SITES
	wuarchive.wustl.edu:/systems/amiga/incoming/utils/
	wuarchive.wustl.edu:/systems/amiga/???/
	merlin.etsu.edu:/aminet/new/
	merlin.etsu.edu:/aminet/util/misc/

	FILES
	login100.lha
	
DISTRIBUTABILITY
	freely distributable; DES encryption governed by U.S. export
	law (I think), meaning that it's illegal to export these
	programs by non-automatic means.

AUTHOR
	D. Champion
	dgc3@midway.uchicago.edu

