/*SET SCREENMODE FOR TREK-THE.GUIDE v1.0 */


if ~show('L','rexxreqtools.library') then
        call addlib("rexxreqtools.library", 0, -30, 0)

NL = '0a'x

screenmode = rtscreenmoderequest( "Pick Screen Resolution", ,,
              "rtsc_flags = screqf_sizegads", screen)

if screenmode ~= "" then do
	open(sm, 'envarc:Trekguide.prefs', 'w')
	writeln(sm, screen.width'|'screen.height)
	close(sm)
	address command 'copy envarc:trekguide.prefs env:trekguide.prefs'
	call rtezrequest( "You MUST shut down Trek-The Guide" || NL || "and restart it.", " OK ", , )
end
exit

if screenmode = "" then do
end

call rtfreefilebuffer()
address command 'copy envarc:trekguide.prefs env:'
