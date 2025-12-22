/* -----------------------------------------------------------
  $VER: Search.supp.c 1.0 (20.05.2000)

  extra support for BuffyGuideSearch

  (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
  amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------ */

#include <stdio.h>
#include "Search.h"


void display_help(char *argv[])
{ // displays a quick help/about of the program

printf("\nBuffy Guide Search - Version 1.00\n");
printf("© 2000 - Matthew J Fletcher\n");
printf("amimjf@connectfree.co.uk\n");
printf("Compiled on %s, at %s\n\n", __DATE__, __TIME__);

printf("Usage: Spooler Buffy.guide [option/s]\n");
printf("       -h (help/about program)\n");
printf("       -s (case sensitive search - off by defult)\n");
printf("       -v (verbose mode - off by defult)\n");
printf("       -d (dubug mode - off by defult)\n");
printf("Example: %s Buffy.guide -s \n", argv[0]);
} // end help -h option


