/* -----------------------------------------------------------
  $VER: Search.h 1.1 (20.05.2000)

  Main heaader for BuffyGuideSearch

  (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
  amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------ */

extern int CASE;    // case sensitive search
extern int VERBOSE; // verbose searching
extern int DEBUG;   // debuging info

#include <time.h>

// global vars
extern clock_t start;
extern clock_t end;
extern float total;
extern long int lines;
extern long int nodes;
extern char searchstring[255];
extern FILE *guide_fp;
extern FILE *temp_fp;
extern long int matchesfound;

// PUBLIC function prototypes
void display_help(char *argv[]); // displays some help
void do_search(char *argv[]);    // search top level
void brkfunc(int);               // ctrl-c handeler
void parse_guide(void);          // main guide search
void write_header(void);         // writes AmigaGuide headers
void write_end(void);            // writes final bits
int end_search(void);           // shutdown search





