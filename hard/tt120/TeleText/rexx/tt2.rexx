/* TT2.rexx
   demonstrates some arexx functions
   
   This script requests 4 pages from TeleText in each
   of the 4 catalogs, with checking the result

   Created: 13-12-1993
   (c) Jan Leuverink
*/
options results
address "TeleText"
/* set catalog to 1 */
set_catalog 1
say "Setting catalog to:" result 
/* get page 100 */    
get_page 100
CALL show_result(result)
set_catalog 2
say "Setting catalog to:" result 
/* get page 704 */    
get_page 704
CALL show_result(result)
/* set catalog to 3 */
set_catalog 3
say "Setting catalog to:" result 
/* get page 205 */    
get_page 205
CALL show_result(result)
/* set catalog to 4 */
set_catalog 4
say "Setting catalog to:" result 
/* get page 101 */    
get_page 101
CALL show_result(result)

exit

/* this procedure tells the user what the result of the get_page was */
show_result: procedure
ARG i
say "Result of get_page:" i
IF i==0 THEN say "Page request completed succesfully"
IF i==1 THEN say "Page request error: invalid pagenumber"
IF i==2 THEN say "Page request error: timeout occurred during search"
IF i==3 THEN say "Page request error: user aborted the search"
IF i==4 THEN say "Page request error: not enough memory"
IF i==5 THEN say "Page request error: parallel port was not allocated"
return 0
