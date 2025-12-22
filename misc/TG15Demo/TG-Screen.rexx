/*SET SCREENMODE FOR TREK-THE.GUIDE v1.0 */

if ~show('L','rexxreqtools.library') then
        call addlib("rexxreqtools.library", 0, -30, 0)

NL = '0a'x

sm:
screenmode = rtscreenmoderequest( "Pick screentype", ,,
              "rtsc_flags = screqf_sizegads", screen)

if screenmode ~= "" then do
	open(dfile, 'envarc:Trekguide.prefs', 'w')
	writeln(dfile, screen.width'|'screen.height)
	close(dfile)

/*say 'the screenwidth is' screen.width
say 'the screenheigh is' screen.height
*/
end

if screenmode = "" then do
  call rtezrequest( "You MUST pick a screen mode before running" || NL || "Trek-the.Guide for the first time", " OK ", , )
/*  call sm()*/
end
call rtfreefilebuffer()
address command 'copy envarc:trekguide.prefs env:'
