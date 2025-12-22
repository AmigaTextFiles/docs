/* -----------------------------------------------------------
  $VER: Search.core.c 1.1 (21.05.2000)

  core rotines for the BuffyGuideSearch

  (C) Copyright 2000 Matthew J Fletcher - All Rights Reserved.
  amimjf@connectfree.co.uk - www.amimjf.connectfree.co.uk
 ------------------------------------------------------------ */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>
#include <ctype.h>

#include "Search.h" // thats ours


// --------------------------
// top level search procedure
// --------------------------
void do_search(char *argv[])
{
    // ------------------------------
    // does all event handeling, for
    // menu operations and quit events
    // ------------------------------

    // delete file
    remove("BuffyResults.guide");

    printf("#-----------------------------#\n");
    printf("#     BuffyGuideSearch        #\n");
    printf("#      version 1.0.2          #\n");
    printf("#-----------------------------#\n");
    printf("\n");

    // get search string (picky)
    do {
        printf("Enter search string:\n");
        gets(searchstring);
        if (searchstring == NULL) // dough !!
            printf("Please enter a valid search string !\n");

    } while (searchstring == NULL);

    printf("Searching for (%s) in Buffy.guide...\n",searchstring);

    // start timeing search
    start = clock(); // the beginning

    // create break handeler
    signal(SIGINT, brkfunc);
    // tell user
    printf("Press ctrl-c to abort, search will be saved\n");
                                                   
    // ------------------------------------------------
    // Open files (Buffy.guide and T:BuffyResults.guide
    // ------------------------------------------------

    // they should be in our path
    guide_fp = fopen(argv[1],"r");
        if (guide_fp == NULL) { // not found
            printf("Buffy.guide not found in progdir:\n");
            exit(0);
            }

    temp_fp = fopen("BuffyResults.guide","w");
        if (temp_fp == NULL) { // not found
            printf("Could not create search results file:\n");
            exit(0);
            }

    // writes search result file headers
    write_header();

    // ----------------------------
    // this is where it all happens
    // ----------------------------
    parse_guide();

    // thats all buffy !! -stop search

} // end do_search


// --------------------
// if processing broken
// --------------------
void brkfunc(int signo)
{

    if (DEBUG ==1) // no need to tell user
    printf("signal %d occured\n", signo);

    printf("Search Aborted !!\n");

    // generic closedown proc
    end_search();
} // end brkfunc


// -----------------
// parses guide file
// -----------------
void parse_guide(void)
{
char *token;
char stuff[1000];
char junkstr[1000];

// even long lines are no problem now !!
char buffer[3000];
int eof,catch,i=0,x=0,dup;

// from arexx
char resultnode[1000];
char resultnodename[1000];
char resultstring[1000];

    // ----------------------------
    // search file for string, make
    // links to all found items
    // ----------------------------

    // begin guide search
    do {
        if (fgets(buffer,sizeof(buffer),guide_fp) == NULL) {
            eof = 1;
            if(DEBUG==1)
            printf("EOF at line %d\n",lines);

            // break here
            end_search();
            }

    // begin string search - finds first element
    strtok(buffer," "); // delimiter is space

    catch=0,dup=0;
    do { // check for search string

        // get next element of string buffer
        token = strtok(NULL," ");

        if ((strstr(buffer,"@node")!=NULL) ||
            (strstr(buffer,"@NODE")!=NULL)) {
            if (catch==0) {
            // one more
            nodes++;
            // node link is next
            strcpy(resultnode,token); // node link

            // remove "" quotes
            i=0,x=0;
            do {
                 if (resultnode[x] != '"') {
                    junkstr[i] = resultnode[x];
                    i++; x++;
                    }
                 else x++;

            } while (resultnode[x] != NULL);

            // copy null
            junkstr[i] = 0;
            strcpy(resultnode,junkstr);


            token = strtok(NULL,"\"");
            strcpy(resultnodename,token); // node title

            // fiddles,...
            token = strtok(NULL," ");
            catch=1; // no need to do something twice
            }

            if(DEBUG==1)
            printf("(%s) (%s) on line %d\n",resultnode,resultnodename,lines);
            }

        
        if ((CASE ==1) && (dup ==0)) // sensitive
            if (strcmp(token,searchstring) == 0) {

                dup=1; // dont search same line twice
                strcpy(resultstring,token); // matched string
                matchesfound++;

                // write link to file
                sprintf(stuff," \"%s\"   in @{\"%s\" LINK \"Buffy.guide/%s\"} @{b}(Match %d / line %d)@{ub}\n",resultstring,resultnodename,resultnode,matchesfound,lines);
                fputs(stuff,temp_fp);


                if(DEBUG==1) {
                    printf("Search String (%s) found on line %d\n",token,lines);
                    printf("%s LINK Buffy.guide/%s\n",resultnodename,resultnode);
                    }
                }

        if ((CASE ==0) && (dup ==0))// insensitive
            #if defined ( _DCC ) || defined ( __BORLANDC__ ) || defined ( __VBCC__ )
            if (stricmp(token,searchstring) ==0) {
            #else
            if (strcasecmp(token,searchstring) ==0) {
            #endif

                dup=1; // dont search same line twice
                strcpy(resultstring,token); // matched string
                matchesfound++;

                // write link to file
                sprintf(stuff," \"%s\"   in @{\"%s \" LINK \"Buffy.guide/%s\"} @{b}(Match %d / line %d)@{ub}\n",resultstring,resultnodename,resultnode,matchesfound,lines);
                fputs(stuff,temp_fp);

                if(DEBUG==1) {
                    printf("Search String (%s) found on line %d\n",token,lines);
                    printf("%s LINK Buffy.guide/%s\n",resultnodename,resultnode);
                    }
                }

    } while (token != NULL);
    // end string search

    lines++; // counting lines
    } while (eof != 1);
    // end guide search

} // end parse guide


// -------------------------------
// stops searching and generates
// correct AmigaGuide at that time
// -------------------------------
int end_search(void)
{
    end = clock(); // the end
    total = (end - start); // time diffrence

    // puts all stuff needed to complete AmigaGuide file
    write_end();
    // Close files
    fclose(guide_fp);
    fclose(temp_fp);

    // Multiview results
    if (system("sys:Utilities/MultiView Buffy:BuffyResults.guide") == -1) // error
        printf("Could Not Run Multiview on BuffyResults.guide\n");

    exit(0);

} // end end_search


