From zerkle Sun Feb 12 17:05:01 1995
Received: by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA21622; Sun, 12 Feb 95 17:05:00 PST
Received: from methan.chemie.fu-berlin.de by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA21616; Sun, 12 Feb 95 17:04:54 PST
Received: by methan.chemie.fu-berlin.de (Smail3.1.28.1)
	  from zikzak.in-berlin.de with uucp
	  id <m0rdpEe-00028nC>; Mon, 13 Feb 95 02:05 MET
Received: by zikzak.in-berlin.de
	  (using \/<>\/ SmailAmiga 1.02j20 with rerouting enabled)
	  for cs.ucdavis.edu!announce (via fub)
	  id <m0rdpEO-00007vp>; Mon, 13 Feb 1995 01:05:36 +0100
X-Mailer: //\\miga Electronic Mail (AmiElm 6.3)
Organization: 20 minutes into the future.
Priority: Urgent
Message-Id: <2032715b.61a80-amk@zikzak.in-berlin.de>
Date: Mon, 13 Feb 1995 01:05:36 +0100
From: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz)
To: announce@cs.ucdavis.edu
Subject: SUBMIT AAAAH! Big typo! Please correct! (was: C-Shell (csh) 5.40 available for ftp)
Errors-To: zerkle@cs.ucdavis.edu
X-Server: Zserver v0.90beta
Status: RO

submit
Hello Dan, Hello Carlos,

yesterday I sent you my announcement for Cshell 5.40, but I made
a big typo in the filename (section AVAILABILITY): I wrote "csh539"
instead of "csh540" :-(

Please ignore my previous announcement for Cshell 5.40 and use the
one I appended to this mail (where I corrected the typo) for your
posting to comp.sys.amiga.announce.

I'm very sorry for making this trouble to you.  It's my fault and
I should be more careful in the future when re-using old announcements.

I hope it's not too late to correct the mistake.

        Thanks in advance,
                Andreas

                                    -----



Subject: C-Shell (csh) 5.40 available for ftp
Followup-To: comp.sys.amiga.misc
Reply-To: csh-fan@zikzak.in-berlin.de

TITLE

     C-Shell (csh)

VERSION

     5.40

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

     Changes since version 5.39 (summary):
      - Fixed error message for builtin command "copy": if no special
        error message was available, always the string "(no mem)" was
        output.
      - New placeholders "-1" and "-2" for builtin command "window".
      - Increased maximum value for window dimensions from 1023 to 32767
        for builtin command "window".
      - Environment variables LINES and COLUMNS override window bounds
        from Amiga console.device.
        (if env vars are set, no CSI sequence is sent)
      - Builtin command "mem" now shows size of largest available memory
        block.
      - Various minor changes/enhancements to existing commands.
      - Miscellaneous minor bug fixes.

     See file "HISTORY" in archive csh540.lha for complete listing
     of changes and new features.

SPECIAL REQUIREMENTS

     AmigaOS 2.0 (or higher)

AVAILABILITY

     FTP/Internet: AmiNet and mirrors

       ftp://ftp.wustl.edu/pub/aminet/util/shell/csh540.lha (252386)
       ftp://ftp.wustl.edu/pub/aminet/util/shell/csh540src.lha (140528)

     UUCP/E-Mail : mail-server@cs.tu-berlin.de

       Send mail to the address above and put the
       line "send /pub/aminet/util/shell/csh540.lha"
       in the body. (same for "csh540src.lha")

     The archive "csh540.lha" contains binary and documentation,
     while "csh540src.lha" contains C source code (for SAS/C 6).

DISTRIBUTABILITY

     Freely distributable, Copyright by the individual authors.


-- 
 Andreas M. Kirchwitz, Seesener Str. 69, D-10709 Berlin, Germany
 +49 (0)30 8623376, amk@{zikzak.in|cs.tu|fu}-berlin.de, IRC bonzo

