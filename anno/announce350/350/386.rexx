From d91ali@csd.uu.se Wed Mar 24 14:11:42 1993
Received: from ida.csd.uu.se ([130.238.13.3]) by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.1)
	id AA20734; Wed, 24 Mar 93 14:11:39 PST
Received: by ida.csd.uu.se id AA25887
  (5.65c8/IDA-1.4.4 for zerkle@cs.ucdavis.edu); Wed, 24 Mar 1993 23:12:13 +0100
Date: Wed, 24 Mar 1993 23:12:13 +0100
From: Anders Lindgren <d91ali@csd.uu.se>
Message-Id: <199303242212.AA25887@ida.csd.uu.se>
To: zerkle@cs.ucdavis.edu
Subject: Me again...
X-Charset: ASCII
X-Char-Esc: 29
Status: RO

Hi! You asked me to rewrite the following text, but my reply seemd to
have disappeare somewhere along the line. I'm posting it again and
hoping for better luck this time.

--- cut --- cut ---

TITLE
	rexx-mode

VERSION
	V1.0

AUTHOR
	Anders Lindgren (d91ali@csd.uu.se)

PURPOSE
	GNU Emacs, the king of editors, has been available for the
	Amiga for some time.  GNU Emacs is a very intelligent editor,
	it knows how to indent and handle C-code, TeX-documents,
	Eiffel-code, Lisp-code etc. 

	However, one big piece of the puzzle was missing. I, as most
	other Amiga freaks, program a lot in ARexx.  Emacs normally
	doesn't have the faintest idea how to indent REXX code.

	This program is "the missing link".  It contains a major
	REXX mode for editing and another major mode which works as
	a front end for the REXX debugger, giving it a more source-
	level look. (A moving arrow shows the current line in the
	code window.)
	
	The indentation of rexx-mode is fully configurable.  All styles
	which I have seen so far can be used.  (Most notably, the END
	can be placed even with the DO-statement or indented to
	the same level as the block).

	Source code in elisp (Emacs Lisp) is supplied.

REQUIREMENTS
	A machine runing GNU Emacs and ARexx, or any other 
	implementation of REXX.

FTP LOCATIONS
	file name: rexxmode10.lha
	Path:      util/rexx

	amiga.physik.unizh.ch (130.60.80.80) or its mirrors.

DISTRIBUTION	
	rexx-mode is distributed under the GNU public license.

