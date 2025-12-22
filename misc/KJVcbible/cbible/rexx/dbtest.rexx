/*******************************************************************
  ARexx program to illustrate the use of THINKER as a database
********************************************************************/

/*  OPTIONS RESULTS is needed because THINKER returns result strings */

options results
address command

/*   Start THINKER with NO default file and NO window */

'run >NIL: thinker:thinker -now'

/*    THINKER takes a while to load  */

'wait 15 sec'
WaitForPort 'Thinker' 

/*  Switch the Host to THINKER for the next commands */

address 'Thinker'
    
/*  The next commands are commented on the right */

create 'thinker:db1'                      /* create a database */
get origin 'thinker:db1'                  /* set the default file */
add origin '(software) Computer Programs' /* ORIGIN is a place to add */
add origin '(computer) Calculating machines'
add after down 'The Amiga is an example'  /* add a subordinate statement */
add origin '(programs) Detailed instructions'
add origin '(programs) Long range plans'
get label first programs                  /* get first instance of label */
if rc = 0 then say result
get label next                            /* get next instance of label */
if rc = 0 then say result
get succeeding                     /* get next statement at same level */
if rc = 0 then say result
get label first computer           /* get first instance of label */
get down                           /* get subordinate statement */
if rc = 0 then say result
get up                             /* get parent statement */
if rc = 0 then say result
get preceding                    /* get previous statement at same level */
if rc = 0 then say result
close                            /* terminate THINKER and save file */
