/* TT3.rexx
   demonstrates some arexx functions

   load a page from disk and get's some information about it   

   Created: 13-12-1993
   (c) Jan Leuverink
*/

options results
address "TeleText"
file = "Examples/100.tt"

/* set catalog to 1 */
set_catalog 2
SAY "Setting catalog to:" result 

/*load file */
loadpage file

/* if no errors then continue */
IF result==0 THEN
DO
  /* what's the first subpage ? */
  get_minsub
  min=result
  SAY "The first subpage is:" min
  
  /* what's the last subpage ? */
  get_maxsub
  max=result
  SAY "The last subpage is:" max
  
  /* go through all subpages */
  DO i=min to max
  
   /* select subpage */
   set_subpage i
   
   /* what's the number ? */
   get_cursub
   SAY "Current subpage:" result
   
   /* is it valid ? */
   get_subvalid
   IF result==0 THEN SAY "The subpage is valid"
  END i
  
  /* what's the current catalog ? */
  get_curcat
  SAY "Current catalog is:" result
  
  /* what's the current page ? */
  get_curpage
  SAY "Current page is:" result
END
ELSE
  SAY "Could not load page"
