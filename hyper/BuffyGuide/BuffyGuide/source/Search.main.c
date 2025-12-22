/* -----------------------------------------------------------
  $VER: main.c 1.0 (20.05.2000)

  startup / argument parser for BuffyGuideSearch

  (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
  amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------ */

#include <stdio.h>
#include <string.h>
#include <time.h>

#include "Search.h" // thats ours

// some defults
int CASE =0; // off
int DEBUG =0; // off
int VERBOSE =0; // off

clock_t start =0;
clock_t end =0;
float total =0;
long int lines =0;
long int nodes =0;
char searchstring[255];
FILE *guide_fp;
FILE *temp_fp;
long int matchesfound =0;

unsigned char *vers = "$VER: BuffyGuideSearch v1.01 - © Matthew J Fletcher";

int main(int argc, char *argv[])
{ // hello
int x=0,n=0,result=0;

    // ----------------------------------
    // first check if we got any arguments
    // ----------------------------------

    if (argc >= 1) // we got some
        { // check all arguments for sane options
        do {
           #if defined (_DCC) || defined (__BORLANDC__) || defined (__VBCC__)
           if ( (stricmp(argv[x],"-h") ==0) ||      // they want help
                (stricmp(argv[x],"--help") ==0) ||  // unix style
                (stricmp(argv[x],"?") ==0) ||       // amiga style
                (stricmp(argv[x],"/?") ==0) )       // msdos style
           #else
           if ( (strcasecmp(argv[x],"-h") ==0) ||
                (strcasecmp(argv[x],"--help") ==0) ||
                (strcasecmp(argv[x],"?") ==0) ||
                (strcasecmp(argv[x],"/?") ==0) )
           #endif
              { display_help(argv);
                exit(0);
              }

           #if defined ( _DCC ) || defined ( __BORLANDC__ ) || defined ( __VBCC__ )
           else if (stricmp(argv[x],"-s") ==0) // smart mode
           #else
           else if (strcasecmp(argv[x],"-s") ==0)
           #endif
                    { if (DEBUG ==1)
                      printf("Case Sensitive mode enabled\n");

                      CASE = 1;}

            #if defined ( _DCC ) || defined ( __BORLANDC__ ) || defined ( __VBCC__ )
            else if (stricmp(argv[x],"-v") ==0) // code extras
            #else
            else if (strcasecmp(argv[x],"-v") ==0)
            #endif
                    { if (DEBUG ==1)
                      printf("Verbose mode enabled\n");

                      VERBOSE = 1;}

            #if defined ( _DCC ) || defined ( __BORLANDC__ ) || defined ( __VBCC__ )
            else if (stricmp(argv[x],"-d") ==0) // DEBUG mode
            #else
            else if (strcasecmp(argv[x],"-d") ==0)
            #endif
                    { if (DEBUG ==1)
                      printf("Debugging enabled\n");

                      DEBUG = 1;}

            x++; // next argument
            } while (x != argc); // argv0 is our path

        } // end if

    // -------------------------------
    // then pop our menu and say hello
    // -------------------------------

     do_search(argv);

     // internally exits

} // end of main

