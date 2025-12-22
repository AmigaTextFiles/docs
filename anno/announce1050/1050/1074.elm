From zerkle Mon Mar  6 14:23:26 1995
Received: by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA03723; Mon, 6 Mar 95 14:23:25 PST
Received: from methan.chemie.fu-berlin.de by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA03531; Mon, 6 Mar 95 14:15:51 PST
Received: by methan.chemie.fu-berlin.de (Smail3.1.28.1)
	  from zikzak.in-berlin.de with uucp
	  id <m0rll5a-0002lSC>; Mon, 6 Mar 95 23:17 MET
Received: by zikzak.in-berlin.de
	  (using \/<>\/ SmailAmiga 1.02j20 with rerouting enabled)
	  for cs.ucdavis.edu!announce (via fub)
	  id <m0rliNh-00008O5>; Mon, 6 Mar 1995 19:23:49 +0100
X-Mailer: //\\miga Electronic Mail (AmiElm 6.5)
Organization: 20 minutes into the future.
Message-Id: <204f223d.222e0-amk@zikzak.in-berlin.de>
Date: Mon, 6 Mar 1995 19:23:49 +0100
From: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz)
To: announce@cs.ucdavis.edu
Subject: REVISE AmigaElm v5 available for ftp
Errors-To: zerkle@cs.ucdavis.edu
X-Server: Zserver v0.90beta
Status: RO

revise dan
Hello Dan,

> The biggest problem with your announcement is that it is just too
> long.

Uh, sorry...  I'll clean up the announcement as recommended.
Now it's about 1 kB shorter.  I hope it's okay.

> There are some small problems with English diction.  I can fix
> those for you if you like.

Yes, please. Your help is welcome!

Appended is my revised version of the announcement for AmigaElm v5.

        Regards,
                Andreas

                                    -----



Subject: AmigaElm v5 available for ftp
Followup-To: comp.sys.amiga.uucp
Reply-To: elm-fan@zikzak.in-berlin.de

TITLE

     Amiga Elm

VERSION

     5  (5.42)

AUTHOR

     Andreas M. Kirchwitz
     E-Mail: elm-fan@zikzak.in-berlin.de

DESCRIPTION

     AmigaElm is an "Electronic Mail Reader" which allows you to read and
     write mails. Normally you'll need a properly installed UUCP or IP
     package (eg, AmigaUUCP, Feulner-UUCP, Dillon-UUCP, wUUCP or AmiTCP
     plus InetUtils) to receive and send mails, but AmigaElm is highly
     configurable so that you can take a mail-folder from a UNIX box,
     answer the mails and bring the answers back to the UNIX box.

     AmigaElm is easy to install and to use. The user interface is very
     intuitive and similar to the well-known UNIX "elm". Beginners can
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
     messages -- also available on AmiNet, see section "AVAILABILITY") and
     "ReqTools" library 2.x (reqtools.library is included).

     AmigaElm has builtin support for cryptographic applications (eg, PGP).
     Encryption and decryption of messages is user-configurable.

NEW FEATURES

     Changes since version 4:  (summary)
      - Now when launching programs, AmigaElm checks return code.
      - New script "DecodeNeXTmail" decodes NeXTmail.
      - Some experimental RFC1522 handling for incoming and outgoing mail
        to use special chars (eg, Umlaute, 8-bit-chars) within header.
      - Improved ^L (formfeed, ctrl-l) handling.
      - Title bar displays current page number and total number of pages.
      - Improved handling of lines beginning with "From " and ">From "
        (useful for some mailing list software).
      - Keeping of old UID/GID of folder had never worked. Works now!
      - Fixed bug: "Send-off Window" didn't always open on same screen
        as Elm's main window (but on default screen).

     (see file "History.Txt" for complete list of changes)

SPECIAL REQUIREMENTS

     AmigaOS 2.0 (or higher)

     And for normal usage: a properly installed UUCP or IP package.
     But can be configured to run without a UUCP or IP package for
     processing ready-made mail-folders (eg, from your work or
     university).

AVAILABILITY

     FTP/Internet: AmiNet and mirrors

       ftp://ftp.wustl.edu/pub/aminet/comm/mail/AmigaElm-v5.lha (360856)

     UUCP/E-Mail : mail-server@cs.tu-berlin.de

       Send mail to the address above and put the
       line "send /pub/aminet/comm/mail/AmigaElm-v5.lha"
       in the body.

DISTRIBUTABILITY

     Shareware, Copyright by Andreas M. Kirchwitz
     (concept based on hwr-mail by Heiko W. Rupp).
     Source code only available to registered users.

-- 
 Andreas M. Kirchwitz, Seesener Str. 69, D-10709 Berlin, Germany
 +49 (0)30 8623376, amk@{zikzak.in|cs.tu|fu}-berlin.de, IRC bonzo

