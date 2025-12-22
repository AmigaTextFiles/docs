From WOUTER@ALF.LET.UVA.NL Thu Jan 14 08:36:02 1993
Received: from vax3.sara.nl by toadflax.cs.ucdavis.edu (4.1/UCD.CS.2.0)
	id AA17343; Thu, 14 Jan 93 08:35:56 PST
Received: from VAX1.SARA.NL by SARA.NL for announce@cs.ucdavis.edu;
          14 Jan 93 17:36 MET
Received: from ALF.LET.UVA.NL by VAX1.SARA.NL with PMDF#10201; Thu, 14 Jan 1993
 17:35 MET
Date: Thu, 14 Jan 93 17:30 MET
From: Wouter van Oortmerssen <WOUTER@ALF.LET.UVA.NL>
Subject: E Compiler
To: announce@cs.ucdavis.edu
Message-Id: <BACE811D006003C0@VAX1.SARA.NL>
X-Envelope-To: announce@cs.ucdavis.edu
X-Vms-To: IN%"announce@cs.ucdavis.edu"
Comments: Sent using PMDF-822 V3.0, routing is done by SARA5
Status: RO

                                  ANNOUNCEMENT:

                             For release as of today

                +-----------------------------------------------+
                |                                               |
                |                 Amiga E v2.1                  |
                |          Compiler for The E Language          |
                |           By Wouter van Oortmerssen           |
                |                                               |
                +-----------------------------------------------+


E is a procedural higher programming language, mainly influenced by
languages such as C and Modula2. It is an all-purpose programming language,
and the Amiga implementation is specifically targeted at programming
system applications.

Amiga E is a compiler written in assembly (support utilities are all
written in E), that offers enough power to enable (semi-)proffesional
as well as other programmers to produce high quality applications.


The major features of the language/this implementation include:

- Compilation speed of 10.000 to 35.000 lines/minute on a 7mhz Amiga 500,
  25.000 to 85.000 l/m on a 14mhz Amiga 1200 (both _without_ fastram).
  Faster than any of it's commercial opponents

- Produces small and fast executables from sourcecode in one go: linker,
  assembler and other program modules integrated into the compiler.
  Very fast turnaround times even when running from your own editor.

- True Inline Assembly with identifier sharing: a complete assembler
  has been build in to the language that interfaces with E in a
  natural fashion. However, assembly in E is 100% optional.

- Module system for import of library definitions/constants/functions
  (much like TurboPascals UNITs); a large set of pre-compiled modules
  provide for great programming power and extendability.
  _All_ commodore's 2.04 includes available as E modules (E is
  still v1.3 compatible though).

- Large amount of integrated system functions: OpenW(), OpenS(),
  Gadget(), WriteF(), TextF(), and numerous string/list/IO functions.
  For just about any task there's a large library of functions to
  make life easier.

- All librarycalls of Exec, Dos, Intuition and Graphics of 2.04
  integrated as system functions into the compiler: call them without
  opening the library or including files. All other libraries accessible too.

- Flexible and powerfull "type" system: one basic non-complex 32bit
  LONG variable, and datatypes ARRAY, STRING, LIST and OBJECT,
  code-security and generallity through low-level polymorphism.

- LISP functionality, functions like:  Eval(), ForAll(), Exists()
  Implement algorithms that would require lambda-functions.

- immediate lists, typed lists
  Build complex data structures with all sort of data directly
  in expressions, make TagLists, structs, vararg function calls
  on the fly, like: [1,2,3] is a list. For example, this is a _complete_
  program that pops up a requester in E, with the command line
  arguments as text, and returns 0 or WARN to dos, depending on the
  selection:

  PROC main() RETURN EasyRequestArgs(0,[20,0,0,arg,'ok|cancel'],0,NIL)*5

  lists provide for a compact, clear and powerfull style of programming.

- exception handling a la ADA
  provide handlers on all kinds of levels in programs, define
  automatic exception raising for often used functions like
  memory allocations, and implement complex resource allocation
  schemes with ease through recursive calls of handlers.

- compiles compact small programs with SMALL code/data model and large
  applications with LARGE model in seconds.
  the compiler processes sources of 100k and more faster than linkers
  for other systems do, and generates quite good code along the way.

- Managable development system: one executable (the compiler/assembler/
  linker) and optionally a set of Module files is all you will need.


Negative points:
- some features not (yet) implemented, like: OOP, creation of own modules,
  sourcelevel debugger/interface builder etc.
- *very* memory hungry: you're advised to have a minimum memory of 1 meg.
- no 020/030/881 specific code-generation (yet).

much of these "missing features" are scheduled for later versions.

To show what E looks like, here's a complete source code that pops up
the Asl.Library filerequester:

/* AslDemo.e, somewhat shortened */

MODULE 'Asl', 'libraries/Asl'

PROC main()
  DEF req:PTR TO filerequestr
  IF aslbase:=OpenLibrary('asl.library',37)
    IF req:=AllocFileRequest()
      IF RequestFile(req) THEN WriteF('File: "\s" in "\s"\n',req.file,req.dir)
      FreeFileRequest(req)
    ENDIF
    CloseLibrary(aslbase)
  ENDIF
ENDPROC


To get Amiga E v2.1,

- wait for it to appear on the new fishes (any time now)

- get it via FTP. it should be on:

        wuarchive.wustl.edu

                systems/amiga/incoming/programming
                systems/amiga/programming

        amiga.physik.unizh.ch

                amiga/new

  the files must be something like:

        AmigaE21.lha    (207526 bytes)
        AmigaE21.readme

  NOTE WELL: accidentally, a version of 2.1 that contains a small bug
             in the exception-handling routines is also on some
             FTP sites. when up or downloading, see to it that you
             get the version of --> 207526 <-- bytes


if, for some reason you want to contact me:
(preferably the first address)


        Wouter@alf.let.uva.nl    (E-programming support)
or:     Wouter@mars.let.uva.nl   (personal)



