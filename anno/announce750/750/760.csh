Path: NOT-FOR-MAIL
Reply-To: csh-fan@zikzak.in-berlin.de (Andreas M. Kirchwitz)
Message-Number: 760
Followup-To: comp.sys.amiga.misc
Distribution: world
Newsgroups: comp.sys.amiga.announce
Approved: overlord@megalith.miami.fl.us
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Organization: 20 minutes into the future.
From: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz)
Subject: C-Shell (csh) 5.37 available for ftp
Message-ID: <overlord.123s@megalith.miami.fl.us>
Date: Sat, 2 Apr 94 02:06:43 EST

TITLE

     C-Shell (csh)

VERSION

     5.37

AUTHOR

     Andreas M. Kirchwitz (csh 5.20+),
     based on csh 5.19 by Urban D. Mueller

     E-Mail: csh-fan@zikzak.in-berlin.de

DESCRIPTION

     C-Shell is a replacement for the AmigaDOS command line interface.
     Many builtin Unix-like commands, very fast script language, file-
     name completion, command-name completion, comfortable command line
     editing, pattern matching, AUX: mode, object oriented file classes,
     abbreviation of internal and external commands.  Supports multiple
     users.

     C-Shell is easy to install and to use.  Online help for all
     commands, functions and various subjects.  ARP-free!

NEW FEATURES

     Changes since version 5.35 (summary):

      - Supports MultiUser (shows current user in titlebar).
      - Builtin command "chmod" (protect) allows setting of
         user/group/others bits in a UNIX-like fashion.
      - New builtin commands "chgrp" and "chown".
      - Fixed bugs in builtin commands "path", "rm", "rehash".
      - Builtin command "diskchange" allows multiple drive names.
      - New builtin function @age_mins(), modifications to @age().
      - Now requesters appear on same screen as CSH's window.
      - New meaning for builtin variable "_abbrev", now ALL commands
         (even those in the DOS search path) can be abbreviated --
         not only builltin commands.
      - Fixed layout bug in "dir -k" and "dir -i" (classes).
      - Builtin command "dir" supports UID/GID and group/others bits.
      - No requester "please insert volume ..." when you press return
         and your current directory is on an "unmounted" volume
         (eg, a removed floppy disk).
      - New meaning for "dir -z" and builtin variable "_dirformat".
      - Source code now "indent" clean.
         (some warnings on first run, but no errors)
      - Builtin command "qsort" allows case-sensitive sorting.
      - Various changes/enhancements to existing commands.
      - Miscellaneous bug fixes.

     See file "HISTORY" in archive csh537.lha for complete listing
     of changes and new features.

SPECIAL REQUIREMENTS

     AmigaOS 2.0 (or higher)

HOST NAME

     FTP/Internet: AmiNet and mirrors

       For example, ftp.wustl.edu [128.252.135.4].

     UUCP/E-Mail : mail-server@cs.tu-berlin.de

       Send mail to the address above and put the
       line "send /pub/aminet/util/shell/csh537.lha"
       in the body.

DIRECTORY

     /pub/aminet/util/shell

FILE NAMES

     csh537.lha      (binary and documentation)
     csh537src.lha   (source code for SAS/C 6)

DISTRIBUTABILITY

     Freely distributable, Copyright by the individual authors.
--
IRC-Nick: | Andreas M. Kirchwitz, Seesener Str. 69, D-10709 Berlin, Germany
  `bonzo' | Phone +49 (0)30 8623376, Mail amk@{zikzak.in|cs.tu|fu}-berlin.de


--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.
