From zerkle Fri Apr 14 18:26:55 1995
Received: by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA12649; Fri, 14 Apr 95 18:26:54 PDT
Received: from methan.chemie.fu-berlin.de by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA12638; Fri, 14 Apr 95 18:26:45 PDT
Received: by methan.chemie.fu-berlin.de (Smail3.1.28.1)
	  from zikzak.in-berlin.de with uucp
	  id <m0rzwg8-0003dUC>; Sat, 15 Apr 95 02:29 MET
Received: by zikzak.in-berlin.de (V1.17-beta/Amiga)
	  id <0soc@zikzak.in-berlin.de>; Sat, 15 Apr 95 03:19:35 +0200
Date: Sat, 15 Apr 95 03:19:35 +0200
Message-Id: <2082fc2b.aae61-amk@zikzak.in-berlin.de>
X-Mailer: //\\miga Electronic Mail (AmiElm 7.2)
Organization: 20 minutes into the future.
From: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz)
To: announce@cs.ucdavis.edu
Subject: SUBMIT C-Shell (csh) 5.42 available for ftp
Errors-To: zerkle@cs.ucdavis.edu
X-Server: Zserver v0.90beta
Status: RO

submit
Hello Dan, Hello Carlos,

please post the following text to comp.sys.amiga.announce.

        Regards,
                Andreas

                                    -----



Subject: C-Shell (csh) 5.42 available for ftp
Followup-To: comp.sys.amiga.misc
Reply-To: csh-fan@zikzak.in-berlin.de

TITLE

     C-Shell (csh)

VERSION

     5.42

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

     Changes since version 5.40 (summary):
      - Built-in command "window" doesn't clear screen anymore.
      - Fixed timer bug in _prompt (%e) if start and end time of a program
         were not at the same day. (wrong execution time was displayed)
      - New built-in variable "_promptdep" (prompt path depth) and new
         placeholder "%P" for built-in variable "_prompt". Like "%p", "%P"
         displays the current path. With "_promptdep" the user sets the
         maximum number of directories (path parts) displayed for %P (to
         keep prompt smart and short). Default is 3.
      - New built-in variable "_complete" (DOS pattern). What files should
         match on filename completion. Default is "*". For example, if you
         don't want to see files ending with ".bak", set it to "~(*.bak)".
      - Fixed various bugs in built-in command "window".
      - Finally found (and fixed) rounding bug in "itok()", caused display
         of wrong size for memory or harddisk around 1 GB and 1 TB etc.
         Numbers were rounded down to "0 GB" and "0 TB" instead of rounded
         up to "1 GB" and "1 TB".
         [thanks to Andreas 'Leguan' Geist]
      - Some changes/enhancements to existing commands.

     See file "HISTORY" in archive csh542.lha for complete listing
     of changes and new features.

SPECIAL REQUIREMENTS

     AmigaOS 2.0 (or higher)

AVAILABILITY

     FTP/Internet: AmiNet and mirrors

       ftp://ftp.wustl.edu/pub/aminet/util/shell/csh542.lha (253848)
       ftp://ftp.wustl.edu/pub/aminet/util/shell/csh542src.lha (141376)

     UUCP/E-Mail : mail-server@cs.tu-berlin.de

       Send mail to the address above and put the
       line "send /pub/aminet/util/shell/csh542.lha"
       in the body. (same for "csh542src.lha")

     The archive "csh542.lha" contains binary and documentation,
     while "csh542src.lha" contains C source code (for SAS/C 6).

DISTRIBUTABILITY

     Freely distributable, Copyright by the individual authors.

