From zerkle Fri Apr 14 18:27:02 1995
Received: by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA12666; Fri, 14 Apr 95 18:27:00 PDT
Received: from methan.chemie.fu-berlin.de by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.6)
	id AA12645; Fri, 14 Apr 95 18:26:51 PDT
Received: by methan.chemie.fu-berlin.de (Smail3.1.28.1)
	  from zikzak.in-berlin.de with uucp
	  id <m0rzwgA-0003ekC>; Sat, 15 Apr 95 02:29 MET
Received: by zikzak.in-berlin.de (V1.17-beta/Amiga)
	  id <0soh@zikzak.in-berlin.de>; Sat, 15 Apr 95 03:19:40 +0200
Date: Sat, 15 Apr 95 03:19:40 +0200
Message-Id: <2082fc34.704e1-amk@zikzak.in-berlin.de>
X-Mailer: //\\miga Electronic Mail (AmiElm 7.2)
Organization: 20 minutes into the future.
From: amk@zikzak.in-berlin.de (Andreas M. Kirchwitz)
To: announce@cs.ucdavis.edu
Subject: SUBMIT AmigaElm v6 available for ftp
Errors-To: zerkle@cs.ucdavis.edu
X-Server: Zserver v0.90beta
Status: RO

submit
Hello Dan, Hello Carlos,

please post the following text to comp.sys.amiga.announce.

        Regards,
                Andreas

                                    -----



Subject: AmigaElm v6 available for ftp
Followup-To: comp.sys.amiga.uucp
Reply-To: elm-fan@zikzak.in-berlin.de

TITLE

     Amiga Elm

VERSION

     6  (6.24)

AUTHOR

     Andreas M. Kirchwitz
     E-Mail: elm-fan@zikzak.in-berlin.de

DESCRIPTION

     AmigaElm is an "Electronic Mail Reader" which allows you to read and
     write mail. Normally you'd need a properly installed UUCP or IP
     package (eg, AmigaUUCP, Feulner-UUCP, Dillon-UUCP, wUUCP or AmiTCP
     plus INetUtils) to receive and send mail, but AmigaElm is highly
     configurable so that you can take a mail-folder from a UNIX box,
     answer the messages and bring the answers back to the UNIX box.

     AmigaElm is easy to install and to use. The user interface is very
     intuitive and similar to the well-known UNIX "elm". Beginners can
     control all basic functions with menus and some nice GadTools
     requesters. Advanced users can use aliases, prioritized message tagging,
     various filename-offers when saving messages and lots of options to
     configure AmigaElm to fit your needs. In a system with multiple users,
     AmigaElm allows separate configuration files for each user.

     AmigaElm can be invoked in a special "terminal mode" (all input/output
     from/to console). This is useful for running AmigaElm in the current
     shell window or over a serial line (eg, with AUX-Handler).

     AmigaElm offers basic internal MIME (multimedia mail) functionality
     (eg, sending 8-bit-text and binaries over 7-bit-lines) and supports
     "MetaMail" (a full-featured package for handling all kinds of MIME
     messages -- also available on AmiNet, see section "AVAILABILITY") and
     "ReqTools" library 2.x (reqtools.library is included).

     AmigaElm has built-in support for cryptographic applications (eg, PGP).
     Encryption and decryption of messages is user-configurable.

NEW FEATURES

     Changes since version 5:  (summary)
      - New section in documentation about AmigaElm and TCP/IP (Internet).
      - S:UUConfig and uulib:Config don't need to exist any longer,
        especially useful for IP-users (AmiTCP, AS225 etc).
      - New config switch: "AppendSignature", do you want to append the
        signature always, never or only if you're not replying to a mail.
      - New config switch: "MetaMail", do you want to start MetaMail on MIME
        messages always, never or should Elm ask before starting MetaMail.
      - A "From " line followed by a second "From " line is now recognized
        as beginning of a new mail message.
      - If started in terminal mode, AmigaElm doesn't run MetaMail in its
        own window (see also "IOWindow").
      - New config switch: "IOWindow" sets characteristics of console I/O
        windows. Better internal defaults for console I/O windows.
      - Improved return code handling when launching external programs.

     (see file "History.Txt" for complete list of changes)

SPECIAL REQUIREMENTS

     AmigaOS 2.0 (or higher)

     And for normal usage: a properly installed UUCP or IP package.
     But can be configured to run without a UUCP or IP package for
     processing ready-made mail-folders (eg, from your work or
     university).

AVAILABILITY

     FTP/Internet: AmiNet and mirrors

       ftp://ftp.wustl.edu/pub/aminet/comm/mail/AmigaElm-v6.lha (365010)

     UUCP/E-Mail : mail-server@cs.tu-berlin.de

       Send mail to the address above and put the
       line "send /pub/aminet/comm/mail/AmigaElm-v6.lha"
       in the body.

DISTRIBUTABILITY

     Shareware, Copyright by Andreas M. Kirchwitz
     (concept based on hwr-mail by Heiko W. Rupp).
     Source code only available to registered users.

