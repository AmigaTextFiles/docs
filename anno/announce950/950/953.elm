From errors@megalith.miami.fl.us Sun Oct  9 23:27:59 1994
Received: from relay3.UU.NET by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA10731; Sun, 9 Oct 94 23:25:02 PDT
Received: from uucp7.UU.NET by relay3.UU.NET with SMTP 
	id QQxkyz05977; Mon, 10 Oct 1994 02:24:38 -0400
Received: from megalith.UUCP by uucp7.UU.NET with UUCP/RMAIL
        ; Mon, 10 Oct 1994 02:24:58 -0400
Received: by megalith.miami.fl.us 
	(AmigaSmail3.13 for <zerkle@cs.ucdavis.edu>) 
	id <0l8l@megalith.miami.fl.us>; 
	Mon, 10 Oct 1994 01:48:00 -0400 (EDT)
Sender: CSAA@megalith.miami.fl.us
Errors-To: errors@megalith.miami.fl.us
Warnings-To: errors@megalith.miami.fl.us
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
To: announce@cs.ucdavis.edu (CSAA-Submissions)
X-Newsgatesoftware: Amiga Newsgate V1.6
Reply-To: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz)
Message-Number: 953
Newsgroups: comp.sys.amiga.announce
X-Newssoftware: CSAA NMS 1.2
Organization: 20 minutes into the future.
From: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz) (CSAA)
Subject: (CSAA) AmigaElm v4
Message-Id: <overlord.2kie@megalith.miami.fl.us>
Date: Mon, 10 Oct 1994 01:48:46 -0400
Status: RO

TITLE

     Amiga Elm

VERSION

     4  (4.159)

AUTHOR

     Andreas M. Kirchwitz
     E-Mail: elm-fan@zikzak.in-berlin.de

DESCRIPTION

     AmigaElm is an "Electronic Mail Reader" which allows you to read and
     write mails. Normally you'll need a properly installed UUCP package
     (eg, AmigaUUCP, Feulner-UUCP or Dillon-UUCP) to reveive and send mails
     but AmigaElm is highly configurable so that you can take a mail-folder
     from a UNIX box, answer the mails and bring the answers back to the
     UNIX box.

     AmigaElm is easy to install and to use. The user interface is very
     intuitive and similar to the well-known UNIX-ELM. Beginners can
     control all basic functions with menus and some nice GadTools
     requesters. Advanced users can use aliases, priorized message tagging,
     various filename-offers when saving messages and lots of options to
     configure AmigaElm to fit your needs. In a system with multiple users
     AmigaElm allows separate configuration files for each user.

     AmigaElm can be invoked in a special "terminal mode" (all input/output
     from/to console). This is useful for running AmigaElm in the current
     shell window or over a serial line (eg, with AUX-Handler).

     AmigaElm offers basic internal MIME (multimedia mail) functionality
     (eg, sending 8-bit-texts and binaries over 7-bit-lines) and supports
     "MetaMail" (a full-featured package for handling all kinds of MIME
     messages -- also available on AmiNet, see section "HOST NAME") and
     "ReqTools" library 2.x (reqtools.library is included).

     AmigaElm is one of the very first mail readers that has in-built
     support for cryptographic applications, namely PGP. Henceforth,
     AmigaElm improves your privacy and general living quality
     significantly.

NEW FEATURES

     Changes since version 3:  (summary)

     Enhancements to reply-commands (group-reply, new extended group-
     reply) and encryption/decryption (new scripts, user can set default
     encryption mode, 3 predefined and 3 custom encryption modes).

     New sorting criterion, palette settings support up to 32-Bit-Colors,
     can skip over deleted messages, new config file .elm/smartsignature
     (similar to .elm/smartheader), cleaned up documentation on some
     commands, fixed nasty bug with option -f (FOLDER), smarter handling
     of domainized HOSTNAME, non-empty DOMAINNAME and DOMAINNAME in
     general.

     Very intelligent get-char-handling when started in terminal mode
     (Elm now accepts break signal when in terminal mode); thanks to
     Ralph Babel. Also supports file notification when in terminal mode.
     [...]

     No longer needs env-var LINES/COLUMNS for terminal mode when
     connected to Amiga terminal.

     Various other enhancements to existing commands. Some new commands.
     Miscellaneous bug fixes.

     (see file "History.Txt" for details)

SPECIAL REQUIREMENTS

     AmigaOS 2.0 (or higher)

     And for normal usage: a properly installed UUCP package.
     But can be configured to run without a UUCP package for
     processing ready-made mail-folders (eg, from your work
     or university).

HOST NAME

     FTP/Internet: AmiNet and mirrors

       For example, ftp.wustl.edu [128.252.135.4].

     UUCP/E-Mail : mail-server@cs.tu-berlin.de

       Send mail to the address above and put the
       line "send /pub/aminet/comm/mail/AmigaElm-v4.lha"
       in the body.

DIRECTORY

     pub/aminet/comm/mail

FILE NAMES

     AmigaElm-v4.lha      (binary and documentation)

DISTRIBUTABILITY

     Shareware, Copyright by Andreas M. Kirchwitz
     (concept based on hwr-mail by Heiko W. Rupp).
     Source code only available to registered users.
--
Read all administrative posts before putting your post up.  Mailing list:
announce-request@cs.ucdavis.edu.  Comments to CSAA@megalith.miami.fl.us.
MAIL ALL COMP.SYS.AMIGA.ANNOUNCE ANNOUNCEMENTS TO announce@cs.ucdavis.edu.

============================================================================
This is part of a mailing list gateway maintained by Carlos Amezaga.  Bugs
& comments to CSAA@megalith.miami.fl.us.  Subscribes, UnSubcribes, help and
faq requests should be sent to announce-request@cs.ucdavis.edu.



