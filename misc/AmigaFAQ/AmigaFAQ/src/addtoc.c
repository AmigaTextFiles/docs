/*
    addtoc.c	V1.1	25.07.1994

    Copyright (C)   1993    Jochen Wiedmann

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


    This scans a texinfo file and adds a table of contents to the relating
    AmigaGuide and Ascii files. Note that they have to be created first and
    MUST be up to date. Best way to ensure this is using a Makefile.

    Usage:  addtoc TFILE/A,SPLITCHAP/M/N,GFILE/K,DFILE/K,DIFFS/K

    TFILE is the texinfo source, GFILE is the AmigaGuide file and DFILE is
    the Ascii file. Files GFILE.new and DFILE.new are created.

    SPLITCHAP are numbers indicating chapters, after which to split the
    FAQ into different parts. (Each part will be preceded by a toc.) This
    is available for Ascii files only and is used to split FAQs in different
    parts. Note, that these numbers must be adjacent, for example the
    numbers 7 and 11 to split after chapter 6 and 10.

    DIFFS is the name of a file holding diffs to a previous version. This
    must be produced using "gdiff -f new old". When creating the Ascii
    version, changed or added lines will be marked with a "!" or "+",
    respectively, together with the sections they belong to. 

    The texinfo file has to be in a special format: Each node (except the Top
    node) MUST have a following line containing an @chapter, @section,
    @subsection or @unnumbered command. The node commands MUST contain
    nothing else than the node name. Note that @info and @tex commands are
    ignored. In fact anything is ignored, except for the node and sectioning
    commands.

    Author:	  Jochen Wiedmann
		  Am Eisteich 9
	    72555 Metzingen (Germany)
		  Tel. 07123 / 14881


    Computer:	  Amiga 1200 (should run on any Amiga)

    Compiler:	  Dice and Aztec-C (should run through SAS and gcc)


    V1.0        25.08.1993

    V1.1        25.07.1994        Added support of @include
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#ifndef FALSE
#define FALSE 0
#endif
#ifndef TRUE
#define TRUE (!FALSE)
#endif
#ifndef HAVE_STRICMP
#define stricmp strcasecmp
#define strnicmp strncasecmp
#endif


/*
    Maximum length of a line in the source file. Probably works with longer
    lines, but this may not be guaranteed. Even the line numbering WILL
    be damaged.
*/
#define MAXLINE 1024	/*  Maximum length of a node name.  */


/*
    This is used to hold the information we get by scanning the texinfo
    source. Each node is represented by exactly one node structure.
*/
struct node
{ struct node *next;
  char *name;
  char *title;
  int type;
  int changed;
};
#define TYPE_UNNUMBERED 0
#define TYPE_CHAPTER	1
#define TYPE_SECTION	2
#define TYPE_SUBSECTION 3

/*
    This is used to store the diffs information.
*/
struct diffs
{ struct diffs *next;
  int type;
  int from, to;
};
#define DIFFTYPE_DELETED 0
#define DIFFTYPE_CHANGED 1
#define DIFFTYPE_ADDED 2



/*
    The ignorespace() function removes trailing blanks from a line.
*/
char *ignorespace(char *line)

{ while (*line == ' '  ||  *line == '\t')
  { ++line;
  }
  return(line);
}




/*
    The salloc() function allocates memory for a string. Note, that it
    removes trailing Line-Feeds.
*/
char *salloc(char *str)

{ char *ptr;
  int len = strlen(str);

  while (len > 0  &&  str[len-1] == '\n')
  { str[--len] = '\0';
  }
  if ((ptr = malloc(len+1))  !=  NULL)
  { strcpy(ptr, str);
  }
  return(ptr);
}




/*
    The memerror() function reports a memory error and terminates the
    program.
*/
void memerror(void)

{ fprintf(stderr, "Out of memory!\n");
  exit(20);
}




/*
   This is a subfunction of Scan() which is used to support @inclde:
   It calls itself to do this.
*/
void ScanFILE(FILE *fh, char *filename, struct node **first)

{ extern int errno;
  char line[MAXLINE+1];
  char title[MAXLINE+1];
  char *titleptr;
  struct node *node;
  int lineno = 0;

  while (fgets(line, sizeof(line), fh)  !=  NULL)
  { ++lineno;
    if (strnicmp(line, "@include", 8) == 0)
    { char *includefilename = strtok(line+8, " \t\n\r\f");
      FILE *includefh;

      if (!(includefh = fopen(includefilename, "r")))
      { fprintf(stderr, "Cannot open %s as source file!\n", filename);
	exit(10);
      }

      ScanFILE(includefh, includefilename, first);
      fclose(includefh);
    }
    else if (strnicmp(line, "@node", 5)  ==  0           &&
	fgets(title, sizeof(title), fh)  !=  NULL)
    { int type;

      ++lineno;
      type = -1;
      if (strnicmp(title, "@unnumbered", 11)  ==  0)
      { type = TYPE_UNNUMBERED;
	titleptr = title+11;
      }
      else if (strnicmp(title, "@chapter", 8)  ==  0)
      { type = TYPE_CHAPTER;
	titleptr = title+8;
      }
      else if (strnicmp(title, "@section", 8)  ==  0)
      { type = TYPE_SECTION;
	titleptr = title+8;
      }
      else if (strnicmp(title, "@subsection", 11)  ==  0)
      { type = TYPE_SUBSECTION;
	titleptr = title+11;
      }
      else if (strnicmp(title, "@top", 4)  !=  0)
      { fprintf(stderr, "%s, %d, warning: Unknown sectioning command.\n",
		lineno);
	fprintf(stderr, 
		"         Expected @chapter, @section, @subsection, @unnumbered or @top.\n");
      }
      if (type != -1)
      { if ((node = calloc(1, sizeof(*node)))  ==  NULL)
	{ memerror();
	}
	if ((node->name = salloc(ignorespace(line+5)))  ==  NULL   ||
	    (node->title = salloc(ignorespace(titleptr)))  ==  NULL)
	{ memerror();
	}
	node->next = NULL;
	node->type = type;

	/* 
	   Look for the last node in the current list and add the
	   current node.
	*/
	{ struct node **last;

	  for (last = first;  *last != NULL;
	       last = &((*last)->next))
	  {
	  }
	  *last = node;
	}
      }
    }
  }

  if (errno)
  { perror("addtoc");
  }
}




/*
    The Scan() function scans the texinfo source file. It uses
    ScanFILE in order to work recursively.
*/
void Scan(struct node **first, char *tfile)

{ FILE *fh;

  if ((fh = fopen(tfile, "r"))  ==  NULL)
  { fprintf(stderr, "Cannot open %s as source file!\n", tfile);
    exit(10);
  }

  *first = NULL;

  ScanFILE(fh, tfile, first);

  fclose(fh);
}




/*
    The myscan() function scans a string like @{"title" Link "name"} for
    name.
*/
char *myscan(char *line, char *name)

{ line = ignorespace(line);
  if (strncmp(line, "@{\"", 3)  !=  0)
  { return(NULL);
  }
  line += 3;
  while (*line != '\"'  &&  *line != '\0')
  { line++;
  }
  if (*line == '\0')
  { return(NULL);
  }
  ++line;
  line = ignorespace(line);
  if (strnicmp(line, "Link", 4)  !=  0)
  { return(NULL);
  }
  line+=4;
  line = ignorespace(line);
  if (*(line++) != '\"')
  { return(NULL);
  }
  while (*line != '\"'  &&  *line != '\0')
  { *(name++) = *(line++);
  }
  if (strncmp(line, "\"}", 2)  !=  0)
  { return(NULL);
  }
  *name = '\0';
  return(line+2);
}




/*
    The subcmp() function checks for len occurences of c. Result is 0, if
    there are, nonzero otherwise.
*/
int subcmp(char *line, char c, int len)

{ int i;

  for (i = 0;  i < len;  i++)
  { if (line[i] != c)
    { return(line[i]-c);
    }
  }
  return(0);
}




/*
    This function is used to read the diffs. These consist of lines like
        am
        cm n
        dm n
    where a means "following lines added after line m", c equals to "lines
    m to n changed" and d is "lines m to n deleted". (n may be omitted, if
    n == m.)

    a and c lines are followed by the appropriate number of lines to add or
    change, followed by a line with a point only.

    When the lines are read, the doc file is scanned a first time to find,
    which nodes are changed.
*/
void ScanDiffs(struct diffs **first, char *file, char *docfile,
	       struct node *firstnode)

{ FILE *fhin;
  int linenr = 0;
  char line[MAXLINE+1];
  char subline[MAXLINE+1];
  struct diffs *newdiffs;
  struct diffs **first_diff = first;
  struct node *currentnode = NULL;

  /*
     Opening the diffs file.
  */
  if ((fhin = fopen(file, "r"))  ==  NULL)
    { fprintf(stderr, "Cannot open diffs file %s.\n", file);
      exit(10);
    }

  while(fgets(line, sizeof(line), fhin)  !=  NULL)
    { char *ptr2, *ptr = line;

      ++linenr;
      if (*ptr != 'd'  &&  *ptr != 'a'  &&  *ptr != 'c')
	{ fprintf(stderr, 
		  "diffs file %s has inappropriate format in line %d.\n",
		  file, linenr);
	  exit(10);
	}

      if ((newdiffs = calloc(1, sizeof(*newdiffs)))  ==  NULL)
	{ fprintf(stderr, "Out of memory.");
	  exit(10);
	}
      newdiffs->from = strtol(++ptr, &ptr, 10);
      if (ptr == line+1)
	{ fprintf(stderr,
		  "diffs file %s has inappropriate format in line %d.\n",
		  file, linenr);
	  exit(10);
	}
      newdiffs->to = strtol(ptr, &ptr2, 10);
      if (ptr2 == ptr)
	{ newdiffs->to = newdiffs->from;
	}

      switch(line[0])
	{ /*
	     "Delete" chunk
	  */
	  case 'd':
	    newdiffs->type = DIFFTYPE_DELETED;
	    break;
	  /* 
	     "Add" chunk
	  */
	  case 'a':
	    newdiffs->type = DIFFTYPE_ADDED;
	    newdiffs->to = newdiffs->from-1;
	    /*
	       Find, how much lines to add by reading them.
	    */
	    for(;;)
	      { if (fgets(line, sizeof(line), fhin)  ==  NULL)
		  { fprintf(stderr,
			    "Unexpected end of diffs file %s.\n", file);
		    exit(10);
		  }
		if (strcmp(".\n", line)  ==  0)
		  { break;
		  }
		newdiffs->to++;
	      }
	      
	    if (newdiffs->to < newdiffs->from)
	      { fprintf(stderr,
			"Diffs file %s has inappropriate format in line %d.\n",
			file, linenr);
		exit(10);
	      }
	    break;
	  /*
	     "Change" chunk
	  */
	  case 'c':
	    newdiffs->type = DIFFTYPE_CHANGED;
	    
	    /*
	       Skip the following lines
	    */
	    for(;;)
	      { if (fgets(line, sizeof(line), fhin)  ==  NULL)
		  { fprintf(stderr,
			    "Unexpected end of diffs file %s.\n", file);
		    exit(10);
		  }
		if (strcmp(".\n", line)  ==  0)
		  { break;
		  }
	      }
	      break;
	  }
      *first = newdiffs;
      first = &(newdiffs->next);
    }
  fclose(fhin);


  /*
      Opening the doc file.
  */
  if ((fhin = fopen(docfile, "r"))  ==  NULL)
  { fprintf(stderr, "Cannot open %s as input!\n", docfile);
    exit(10);
  }


  /*
      Scanning for nodes
  */
  linenr = 0;
  currentnode = NULL;
  while (fgets(line, sizeof(line), fhin)  !=  NULL)
  { struct diffs *d;

    ++linenr;
    if (firstnode != NULL  &&
	strncmp(line, firstnode->title, strlen(firstnode->title))  ==  0   &&
	fgets(subline, sizeof(subline), fhin)  !=  NULL)
    { char c;
      static char subchar[3] = "*=-";

      ++linenr;
      switch(firstnode->type)
      { case TYPE_UNNUMBERED:
	case TYPE_CHAPTER:
	  c = subchar[0];
	  break;
	case TYPE_SECTION:
	  c = subchar[1];
	  break;
	case TYPE_SUBSECTION:
	  c = subchar[2];
	  break;
      }
      if(subcmp(subline, c, strlen(firstnode->title))  ==  0)
      { /*
	   Node found!
	*/
	currentnode = firstnode;
	firstnode = firstnode->next;
	continue;
      }

    }
    if (currentnode  !=  NULL)
      { for (d = *first_diff;  d != NULL;  d = d->next)
	  { if (d->from <= linenr  &&  d->to >= linenr)
	      { /*
		   Adding of empty lines should not make the section being
		   marked as changed.
		*/
		if (d->type == DIFFTYPE_DELETED)
		  { char *ptr = line;

		    while(*ptr != '\0')
		      { if (*ptr != ' '  &&  *ptr != '\t'  &&
			    *ptr != '\r'  &&  *ptr != '\n')
			  { break;
			  }
			++ptr;
		      }
		    if (*ptr == '\0')
		      { continue;
		      }
		  }
		currentnode->changed = TRUE;
	      }
	  }
      }
  }

  if (firstnode != NULL)
  { fprintf(stderr, "Missing item, probably different text in header "
		    "and menu:\n%s\n", firstnode->title);
  }
  if (errno)
  { perror("addtoc");
  }
  fclose(fhin);
}





/*
    The ScanGuide() function scans the AmigaGuide file, removes the menu
    in the top node and replaces it by the table of contents.
*/
void ScanGuide(struct node *first, char *gtitle)

{ FILE *fhin;
  FILE *fhout;
  char *newtitle;
  struct node *node;
  int InMain;
  int lineno;
  char line[MAXLINE+1];
  char name[MAXLINE+1];

  /*
      Opening files
  */
  if ((newtitle = malloc(strlen(gtitle)+5))  ==  NULL)
  { memerror();
  }
  sprintf(newtitle, "%s.new", gtitle);

  if ((fhin = fopen(gtitle, "r"))  ==  NULL)
  { fprintf(stderr, "Cannot open %s as input!\n", gtitle);
    exit(10);
  }
  if ((fhout = fopen(newtitle, "w"))  ==  NULL)
  { fprintf(stderr, "Cannot open %s as output!\n", newtitle);
    exit(11);
  }

  /*
      Looking for the Top Node
  */
  InMain = FALSE;
  lineno = 0;
  while(fgets(line, sizeof(line), fhin)  !=  NULL)
  { ++lineno;
    if (strnicmp(line, "@Node Main", 10)  ==  0)
    { InMain = TRUE;
    }
    else if (strnicmp(line, "@EndNode", 8)  ==  0)
    { InMain = FALSE;
    }
    if (InMain  &&  strnicmp(ignorespace(line), "@{\"", 3) == 0)
    { if (myscan(line, name)  ==  NULL)
      { fprintf(stderr,
		"Error: Cannot scan line %d of %s (unknown format)!\n",
		lineno, gtitle);
      }
      else
      { int blanks;

	fputs(line, fhout);
	blanks = ignorespace(line)-line;
	for (node = first;  node != NULL;  node = node->next)
	{ if (strncmp(name, node->name, strlen(name)) == 0  &&
	      (node->type == TYPE_CHAPTER  ||  node->type == TYPE_UNNUMBERED))
	  { break;
	  }
	}

	node = node->next;
	while (node != NULL  &&  node->type != TYPE_CHAPTER  &&
	       node->type != TYPE_UNNUMBERED)
	{ switch (node->type)
	  { case TYPE_UNNUMBERED:
	    case TYPE_CHAPTER:
	      break;
	    case TYPE_SECTION:
	      fprintf(fhout, "    ");
	      break;
	    case TYPE_SUBSECTION:
	      fprintf(fhout, "        ");
	      break;
	  }
	  fprintf(fhout, "@{\" %s \" Link \"%s\"}\n", node->title,
		  node->name);
	  node = node->next;
	}
      }
    }
    else
    { fputs(line, fhout);
    }
  }
  if (errno)
  { perror("addtoc");
  }
  fclose(fhin);
  fclose(fhout);
}




/*
   adddoctoc adds the table of contents to the given ascii file.
*/
void adddoctoc(FILE *fhout, struct node *first)
{ int chapter, section, subsection;
  struct node *node;

  chapter = section = subsection = 0;
  for (node = first;  node != NULL;  node = node->next)
  { if (node->type == TYPE_CHAPTER  ||  node->type == TYPE_UNNUMBERED)
    { putc('\n', fhout);
    }
    fprintf(fhout, node->changed ? "! " : "  ");
    switch (node->type)
    { case TYPE_CHAPTER:
	++chapter;
	section = subsection = 0;
	fprintf(fhout, "%d ", chapter);
	break;
      case TYPE_UNNUMBERED:
	break;
      case TYPE_SECTION:
	++section;
	subsection = 0;
	fprintf(fhout, "  %d ", section);
	break;
      case TYPE_SUBSECTION:
	++subsection;
	fprintf(fhout, "    %d ", subsection);
	break;
      }
    fprintf(fhout, "%s\n", node->title);
  }
  fprintf(fhout, "\n\n\n");
}




/*
   diffputs is like fputs, but recognizes diffs.
*/
void diffputs(char *line, FILE *fhout, struct diffs *first_diff, int linenr)

  {
    while (first_diff != NULL)
      { if (first_diff->from <= linenr  &&  first_diff->to >= linenr)
	  { switch(first_diff->type)
	      { case DIFFTYPE_DELETED:
		  fprintf(fhout, "+ %s", line);
		  return;
		case DIFFTYPE_CHANGED:
		  fprintf(fhout, "! %s", line);
		  return;
		default:
		  if (linenr == first_diff->from)
		    { fprintf(fhout, "< %s", line);
		      return;
		    }
		}
	  }
	first_diff = first_diff->next;
      }
    fprintf(fhout, "  %s", line, fhout);
  }



/*
    The ScanDoc function scans the Ascii document and adds the table of
    contents and section numbers.
*/
void ScanDoc(struct node *first, char *dtitle, int *splitchaps,
	     struct diffs *first_diff)

{ FILE *fhin, *fhout;
  struct node *initialfirst = first;
  char *newtitle;
  int lineno;
  int chapter, section, subsection;
  int tocdone;
  int splitnum = 0;
  char line[MAXLINE+1];
  char subline[MAXLINE+1];
  static char subchar[3] = "*=-";
  char c;

  /*
      Opening files
  */
  if ((newtitle = malloc(strlen(dtitle)+20))  ==  NULL)
  { memerror();
  }
  sprintf(newtitle, "%s.%d", dtitle, splitnum+1);

  if ((fhin = fopen(dtitle, "r"))  ==  NULL)
  { fprintf(stderr, "Cannot open %s as input!\n", dtitle);
    exit(10);
  }
  if ((fhout = fopen(newtitle, "w"))  ==  NULL)
  { fprintf(stderr, "Cannot open %s as output!\n", newtitle);
    exit(11);
  }


  /*
      Scanning for nodes
  */
  tocdone = FALSE;
  lineno = 0;
  chapter = section = subsection = 0;
  while (fgets(line, sizeof(line), fhin)  !=  NULL)
  { ++lineno;
    if (first != NULL  &&
	strncmp(line, first->title, strlen(first->title))  ==  0   &&
	fgets(subline, sizeof(subline), fhin)  !=  NULL)
    { ++lineno;
      switch(first->type)
      { case TYPE_UNNUMBERED:
	case TYPE_CHAPTER:
	  c = subchar[0];
	  break;
	case TYPE_SECTION:
	  c = subchar[1];
	  break;
	case TYPE_SUBSECTION:
	  c = subchar[2];
	  break;
      }
      if(subcmp(subline, c, strlen(first->title))  ==  0)
      { /*
	   Node found!
	 */
	int i;
	int level;
	struct node *node;
	char number[128];

	/*
	   Split the file, if its a chapter node with the current splitting
	   number.
	*/
        if (first->type == TYPE_CHAPTER  &&  splitchaps  &&
	    splitchaps[splitnum] == chapter+1)
	{ fclose(fhout);
	  sprintf(newtitle, "%s.%d", dtitle, ++splitnum+1);

	  if ((fhout = fopen(newtitle, "w"))  ==  NULL)
	  { fprintf(stderr, "Cannot open %s as output!\n", newtitle);
	    exit(11);
	  }
	  adddoctoc(fhout, initialfirst);
	}
	  

	/*
	    Add the table of contents, if we have found the first
	    node.
	*/
	if (!tocdone)
	{ adddoctoc(fhout, initialfirst);
	  tocdone = TRUE;
	}

	switch(first->type)
	{ case TYPE_UNNUMBERED:
	    strcpy(number, "");
	    level = 0;
	    break;
	  case TYPE_CHAPTER:
	    ++chapter;
	    section = subsection = 0;
	    sprintf(number, "%d ", chapter);
	    level = 0;
	    break;
	  case TYPE_SECTION:
	    ++section;
	    subsection = 0;
	    sprintf(number, "%d.%d ", chapter, section);
	    level = 1;
	    break;
	  case TYPE_SUBSECTION:
	    ++subsection;
	    sprintf(number, "%d.%d.%d ", chapter, section, subsection);
	    level = 2;
	    break;
	}
	fprintf(fhout, "%s%s%s%s", first->changed ? "! " : "  ",
		number, line, first->changed ? "! " : "  ");
	for (i = 0;  i < strlen(number);  i++)
	{ putc((int) subchar[level], fhout);
	}
	fputs(subline, fhout);
	first = first->next;
      }
      else
      { diffputs(line, fhout, first_diff, lineno-1);
	diffputs(subline, fhout, first_diff, lineno);
      }
    }
    else
    { diffputs(line, fhout, first_diff, lineno);
    }
  }
  if (first != NULL)
  { fprintf(stderr, "Missing item, probably different text in header "
		    "and menu:\n%s\n", first->title);
  }
  if (errno)
  { perror("addtoc");
  }
  fclose(fhin);
  fclose(fhout);
}




/*
    This prints the usage information and terminates.
*/
void Usage(void)

{ fprintf(stderr,
    "Usage: addtoc TFILE/A,SPLITCHAPS/M/N,GFILE/K,DFILE/K\n\n"
    "TFILE is the texinfo source file.\n"
    "GFILE is the AmigaGuide file created from TFILE and DFILE the "
	"corresponding\n"
    "Ascii file. <GFILE>.new and <TFILE>.new, respectively, are created,\n"
    "if the latter options are present.\n"
    "SPLITCHAPS are chapter numbers, before which the file should be "
        "splitted in\n"
    "different parts, for example 7 11 to split after chapters 6 and 10. "
        "(ascii file only)\n\n");
  exit(1);
}




/*
    This is main(). Does nothing except processing the arguments and calling
    the Scan... functions.
*/
void main(int argc, char *argv[])

{ char *tfile, *gfile, *dfile, *diffs_file;
  struct node *first;
  struct diffs *first_diff;
  int i;
  int numsplitchaps;
  int *splitchaps;

#ifdef DEBUG
  tfile = "/Amiga-FAQ.texinfo";
  gfile = "/Amiga-FAQ.guide";
  dfile = "/Amiga-FAQ.doc";
#else
  if (argc < 2)
  { Usage();
  }

  splitchaps = NULL;
  tfile = NULL;
  gfile = NULL;
  dfile = NULL;
  diffs_file = NULL;

  for (i = 1;  i < argc;  i++)
  { if (stricmp(argv[i], "gfile")  ==  0)
    { if (++i == argc  ||  gfile != NULL)
      { Usage();
      }
      gfile = argv[i];
    }
    else if (strnicmp(argv[i], "gfile=", 6)  ==  0)
    { if (gfile != NULL)
      { Usage();
      }
      gfile = &argv[i][6];
    }
    else if (stricmp(argv[i], "dfile")  ==  0)
    { if (++i == argc  ||  dfile != NULL)
      { Usage();
      }
      dfile = argv[i];
    }
    else if (strnicmp(argv[i], "dfile=", 6)  ==  0)
    { if (dfile != NULL)
      { Usage();
      }
      dfile = &argv[i][6];
    }
    else if (tfile == NULL)
    { tfile = argv[i];
    }
    else if (strnicmp(argv[i], "diffs=", 6)  ==  0)
    { if (diffs_file != NULL)
      { Usage();
      }
      diffs_file = &argv[i][6];
    }
    else if (stricmp(argv[i], "diffs") == NULL)
    { if (++i == argc  ||  diffs_file != NULL)
      { Usage();
      }
      diffs_file = argv[i];
    }
    else
    { int *oldsplitchaps = splitchaps;

      if (splitchaps == NULL)
      { numsplitchaps = 0;
      }
      { if ((splitchaps = malloc(sizeof(int)*(numsplitchaps+2)))  ==  NULL)
	{ memerror();
	}
      }
      if (numsplitchaps > 0)
      { memcpy(splitchaps, oldsplitchaps, sizeof(int)*numsplitchaps);
	free(oldsplitchaps);
      }
      if ((splitchaps[numsplitchaps++] = atoi(argv[i]))  <=  0)
      { fprintf(stderr, "Chapter number must be > 0.\n");
	exit(10);
      }
      splitchaps[numsplitchaps] = 0;
    }
  }
  if (tfile == NULL)
  { Usage();
  }
#endif	/*  !DEBUG   */


  Scan(&first, tfile);
  if (gfile)
  { ScanGuide(first, gfile);
  }
  if (dfile)
  { if (diffs_file)
    { ScanDiffs(&first_diff, diffs_file, dfile, first);
    }
    ScanDoc(first, dfile, splitchaps, first_diff);
  }
}
