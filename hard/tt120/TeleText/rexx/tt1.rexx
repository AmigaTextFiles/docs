/* TT1.rexx
   demonstrates some arexx functions
   
   Loads a page called 100.tt in catalog 1
   saves it to ram: in all available formats (iff & ansi only subpage 1)
   Then it turns on the ViewScreen, pops it to front and shows the
   subpages
   
   Call it from the directory TeleText/rexx

   Created: 13-12-1993
   (c) Jan Leuverink
*/
options results
address "TeleText"
/* get version string */
version
say result
/* set catalog to 1 */
set_catalog 1
say result 
/* get page called 100.tt from current directory */    
loadpage   "Examples/100.tt"
say result
/* save to ansi */
save_ansi  "ram:100.ansi"
say result
/* save to tt */
save_tt    "ram:100.tt"
say result
/* save to iff */
save_iff   "ram:100.iff"
say result
/* save to ascii */
save_ascii "ram:100.ascii"
say result
/* turn on ViewScreen, subpage 1 is displayed automatically */
view_on
say result
/* ViewScreen to front */
view_to_front
/* display subpage 2 */
set_subpage 2
say result
/* display subpage 3 */
set_subpage 3
say result
exit
