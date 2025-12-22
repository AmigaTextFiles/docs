From errors@megalith.miami.fl.us Sat Oct  8 23:47:14 1994
Received: from relay2.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA23826; Sat, 8 Oct 94 23:44:41 PDT
Received: from uucp5.UU.NET by relay2.UU.NET with SMTP 
	id QQxkvi08550; Sun, 9 Oct 1994 02:44:37 -0400
Received: from megalith.UUCP by uucp5.UU.NET with UUCP/RMAIL
        ; Sun, 9 Oct 1994 02:45:02 -0400
Received: by megalith.miami.fl.us 
	(AmigaSmail3.13 for <zerkle@cs.ucdavis.edu>) 
	id <0l47@megalith.miami.fl.us>; 
	Sun, 09 Oct 1994 02:36:00 -0400 (EDT)
Sender: CSAA@megalith.miami.fl.us
Errors-To: errors@megalith.miami.fl.us
Warnings-To: errors@megalith.miami.fl.us
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
To: announce@cs.ucdavis.edu (CSAA-Submissions)
X-Newsgatesoftware: Amiga Newsgate V1.6
Reply-To: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz)
Message-Number: 952
Newsgroups: comp.sys.amiga.announce
X-Newssoftware: CSAA NMS 1.2
Organization: 20 minutes into the future.
From: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz) (CSAA)
Subject: (CSAA) C-Shell (csh) 5.39
Message-Id: <overlord.2k22@megalith.miami.fl.us>
Date: Sun, 09 Oct 1994 02:36:20 -0400
Status: RO

TITLE

     C-Shell (csh)

VERSION

     5.39

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

      - New builtin variable "_timeout" (in microseconds) sets maximum
         response time for terminal to answer WINDOW STATUS REQUEST (for
         window bounds). Defaults to 1 (for local usage), must be set to
         higher value for remote connections. Only used, if window pointer
         is not available.
      - Removed command line length limitation (140 chars) for ARexx scripts
         that ends with ".rexx" but are started without the trailing ".rexx".
      - Removed command line length limitation (518 chars) for ARexx scripts
         and external shells (#! in first line), this was a limitation in
         AmigaOS' System() function.  DOS scripts still have this limitation,
         because you cannot RunCommand() "execute".
      - Not only "*" and "?" but also "[" and "]" recognized as AmigaDOS
         pattern. (that means, to use "[" and "]" you must quote (") or
         escape (\) them!)
      - ... and much more workarounds for serious bugs in DateToStr() and
         Locale.
      - Fixed bug: making an assign to an executable and calling the
         executable by its assign crashed machine.
      - Fixed bug: builtin command "cp" sometimes used already freed memory
         for generating error messages (resulted in some strange error
         messages).
      - New flag for for command abbreviation ($_abbrev):
         8, search DOS path-list if command wasn't found in Cshell's
         internal program hash list (see "rehash" command)
      - CTRL-D now shows matching files if current word is not a directory.
         (if directory then shows contents of directory -- as usual)
         In its current implementation this may have unexpected side effects
         if current word is already a pattern.
      - Class definition for AmigaE in class.sh
      - Now internal timer (eg, %e in the titlebar) not set to zero when a
         null command is encountered. (same for return code, %x in titlebar)
      - The idea of always using the variable "_dirformat" for "dir" wasn't
         a good idea.  So, "_dirformat" is only used if option -z is given
         (when "_dirformat" is unset then use first argument as format
         string).
      - New control-code for line-editing: "^V" (ctrl-v) quotes next char.
      - New builtin variable "_kick" holds version number of Operating
         System.
      - Builtin command "assign" now prints volume name if assign points to
         an unmounted volume (eg, a removed floppy disk) and doesn't pop up
         a requester "Please replace volume ..."
      - It was a stupid idea to force redirecting of all Cshell-related
         system requesters to CSH's screen, because requester windows
         inherit the window title of their "initiator". They appear now
         again on your default public screen.
      - Fixed serious bug (crashed machine) with redirection and launching
         programs into background. (files closed twice)
         Known bug: it's still not possible to run pipes into background...
      - When running programs into background (run, rback, &), internal
         commands and aliases are recognized and executed with "csh -c".
         Aliases WON'T be resolved on this level so they must be declared 
         in .cshrc to run them into background.
      - Execution of Rexx-Scripts (without trailing ".rexx") and any other
         program with "#! my_prog" or ";! my_prog" in first line of script
         now possible also from DOS search path and not only $_path.
      - New builtin variable "_mappath" (see manual), enables pathname-
         mapping for commands if script starts with "#!" or ";!" in first
         line.  Converts Unix pathes like "/usr/..." to "usr:...".
      - New option "-w" for Cshell, don't use window pointer (useful for
         KingCON).
      - New option "-V" for Cshell, send only VT100 compatible control
         sequences.
      - Internal variable "o_vt100" now used (if option -t or -V is set),
         don't send control sequences that are not VT100 compatible (eg,
         special Amiga control sequences).
      - Various changes/enhancements to existing commands.
      - Miscellaneous bug fixes.

     See file "HISTORY" in archive csh539.lha for complete listing
     of changes and new features.

SPECIAL REQUIREMENTS

     AmigaOS 2.0 (or higher)

HOST NAME

     FTP/Internet: AmiNet and mirrors

       For example, ftp.wustl.edu [128.252.135.4].

     UUCP/E-Mail : mail-server@cs.tu-berlin.de

       Send mail to the address above and put the
       line "send /pub/aminet/util/shell/csh539.lha"
       in the body.

DIRECTORY

     pub/aminet/util/shell

FILE NAMES

     csh539.lha      (binary and documentation)
     csh539src.lha   (source code for SAS/C 6)

DISTRIBUTABILITY

     Freely distributable, Copyright by the individual authors.

-- 
 Andreas M. Kirchwitz, Seesener Str. 69, D-10709 Berlin, Germany
 +49 (0)30 8623376, amk@{zikzak.in|cs.tu|fu}-berlin.de, IRC bonzo

--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.

============================================================================
This is part of a mailing list gateway maintained by Carlos Amezaga.  Bugs
& comments to CSAA@megalith.miami.fl.us.  Subscribes, UnSubcribes, help and
faq requests should be sent to announce-request@cs.ucdavis.edu.



