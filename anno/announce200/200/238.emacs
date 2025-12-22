From dgay@litsun.epfl.ch Fri Oct  2 10:39:09 1992
Received: from chx400.switch.ch by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.0)
	id AA26833; Fri, 2 Oct 92 10:39:05 PDT
X400-Received: by mta chx400.switch.ch in /PRMD=switch/ADMD=arcom/C=CH/;
               Relayed; Fri, 2 Oct 1992 18:38:22 +0100
X400-Received: by /PRMD=SWITCH/ADMD=ARCOM/C=CH/; Relayed;
               Fri, 2 Oct 1992 18:36:12 +0100
Date: Fri, 2 Oct 1992 18:36:12 +0100
X400-Originator: dgay@litsun.epfl.ch
X400-Recipients: announce@cs.ucdavis.edu
X400-Mts-Identifier: [/PRMD=SWITCH/ADMD=ARCOM/C=CH/;9210021736.AA02164]
X400-Content-Type: P2-1984 (2)
From: "(Gay David)" <dgay@litsun.epfl.ch>
Message-Id: <9210021736.AA02164@litsun.epfl.ch>
To: announce@cs.ucdavis.edu
Cc: dgay@di.epfl.ch
Subject: GNU Emacs 18.58, Amiga RELEASE 1.26, available for download
Received: from litsun.epfl.ch by SIC.Epfl.CH via INTERNET ;
          Fri, 2 Oct 92 18:36:18 N
Received: from litsun32.epfl.ch by litsun.epfl.ch (4.1/Epfl-3.1/MX) id AA02164;
          Fri, 2 Oct 92 18:36:12 +0100
Status: RO

TITLE
	GNU Emacs

VERSION
	RELEASE 1.26 of GNU Emacs 18.58
	(replaces RELEASE 1.25)

AUTHOR
	David Gay (dgay@di.epfl.ch)

DESCRIPTION

Emacs is a very powerful, but sometimes cryptic, text editor. Its basic
features are similar to those of the MEmacs editor which comes with 
AmigaDOS (in the Tools directory), but has numerous other facilities:
- unlimited undo.
- language specific editing, with automatic (re)indentation.
- a dialect of lisp as extension language, leading to extreme 
  reconfigurability.
- abbreviations for commonly typed words.
- complete on-line manual.
- powerful search & replace facilities (including wildcards).

In this Amiga version, I have tried to make it easier to use with menus, 
mouse, clipboard, rexx and workbench support.

Since the previous release (1.25), two main features have been added:
- complete process support (so you can now run compilations, shells, etc
inside emacs).
- workbenchification: emacs can now create icons, be run from the workbench,
etc.

System requirements:
- AmigaDOS 2.04
- At least 2MB of memory (emacs uses about 750k + memory for the files
  being edited).
- 2.5MB of free disk space for the binary version, 8MB for the 
  source version (but you can remove some of the files once it has been
  installed).
- Emacs works with a 68000 (A500,A2000), but is a bit slow. It is very
  pleasant to use with a 68030/25MHz ...

This port was originally based on that of Mark Henning (gnuemacs
v1.10), but after having made rather extensive modifications, added
numerous features and ported 18.57 (and now 18.58), I decided to
release it myself. 

The following distributions are available:

o binary only:
  All the files necessary to use emacs. Has only a subset of the lisp files,
  the rest may be got from a standard emacs distribution.

o full amiga version:
  All the files necessary to compile emacs, all the lisp files, etc.
  Some of the source files of the Unix or VMS versions are not included.
  This source is written for SAS C 5.10b.

LOCATION
	amiga.physik.unizh.ch	130.60.80.80	amiga/util/gnu
	and any of its mirrors

FILE NAMES

	a1.26-emacs-18.58-bin.LHA	The binary only distribution
	a1.26-emacs-18.58-src.LHA	The 'full amiga version'
	sas-unix-lib.LHA		A C library needed to compile the 
					source

DISTRIBUTABILIY

Emacs is covered by the GNU Genereal Public License, ie it is freely
distributable but not in the public domain. See the file COPYRIGHT in the
distribution for details.

The C library needed to compile emacs is mostly in the public domain.
However, some parts are Copyright (c) 1987, 1989 Regents of the University
of California, hence the following notice:

  This product includes software developed by the University of
  California, Berkeley and its contributors.

David Gay
dgay@di.epfl.ch
Ecole Polytechnique Federale de Lausanne, Switzerland.
Laboratoire d'Informatique Technique.



