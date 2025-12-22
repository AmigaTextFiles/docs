/*
 Trek-The Guide Arexx Front End
 ©1994-1995 Jim Hines All rights Reserved - - - - AmigaGuide Version
 */

NL = '0a'x

if ~show('L','rexxsupport.library') then
	call addlib('rexxsupport.library',0,-30)
if ~show('L','rexxarplib.library') then
	call addlib('rexxarplib.library',0,-30)
/*if ~show('L','rexxreqtools.library') then
	call addlib('rexxreqtools.library',0,-30)*/

if ~exists('env:Trekguide.prefs') then do
call Request(100, 100,"ENV:Trekguide.prefs DOES NOT EXIST\You MUST create it by using the\TG-Screen program." ,, "Live Long and Prosper",,)
exit
end

/* This is the same as above but uses the RexxReqTools.library instead  */
/*if ~exists('env:Trekguide.prefs') then do
	call rtezrequest( "ENV:Trekguide.prefs DOES NOT EXIST" || NL || "You MUST create it by using"||NL||"the TG-Screen program.", " OK ", , )
	exit
	end*/

screenmode = open(sm, 'env:Trekguide.prefs', 'r')
smvar = readln(sm)
close(dfile)
parse var smvar width '|' height
say 'the width is 'width
say 'the height is 'height


call openport(notifyport)
call openscreen(0, 4, hireslace, 'Trek-The.Guide ©1994-1995 Jim Hines', trekguide, , width, height, 0)

/* WORKBENCH COLORS */
	Screencolor(trekguide, 0, 8, 8, 7)
	Screencolor(trekguide, 1, 0, 0, 0)
	Screencolor(trekguide, 2, 0, 15, 15)
	Screencolor(trekguide, 3, 14, 14, 3)
	Screencolor(trekguide, 4, 7, 7, 15)
	Screencolor(trekguide, 5, 15, 15, 15)
	Screencolor(trekguide, 6, 11, 10, 9)
	Screencolor(trekguide, 7, 15, 11, 10)

/*  PIC COLORS */
	Screencolor(trekguide, 8, 0, 0, 0)
	Screencolor(trekguide, 9, 1, 1, 1)
	Screencolor(trekguide, 10, 3, 3, 3)
	Screencolor(trekguide, 11, 5, 5, 5)
	Screencolor(trekguide, 12, 7, 7, 7)
	Screencolor(trekguide, 13, 9, 9, 9)
	Screencolor(trekguide, 14, 10, 10, 10)
	Screencolor(trekguide, 15, 12, 12, 12)

address ARexx "'call CreateHost(hostport, notifyport, trekguide)'"

WaitForPort hostport
WaitForPort hostport
WaitForPort hostport

/* color = rtpaletterequest(, "Change palette", 'rt_pubscrname = trekguide')
if rtresult == -1 then
  call rtezrequest("You canceled." || NL || "No nice colors to be picked ?", ,
        "Nah", , 'rt_pubscrname = trekguide' )
else
  call rtezrequest("You picked color number" color, "Sure did", , ) */

/* ========THESE DIRS & FILES PERTAIN TO THE MARK AND VIEW COMMANDS === */

address command 'makedir >nil: env:TrekGuide'
if exists('envarc:TrekGuide') then do
	address command	'copy envarc:TrekGuide all env:TrekGuide'
	end

/* ========These section is for the opening IFF === */

idcmp = 'CLOSEWINDOW+GADGETUP'
flags = 'BACKFILL+ACTIVATE'

address ARexx "'call CreateHost(hostport, notifyport, trekguide)'"

WaitForPort hostport
WaitForPort hostport

call OpenWindow(hostport, 10, 10, 557, 364, idcmp, flags, 'PLEASE WAIT WHILE LOADING')
call SetNotify(hostport, CLOSEWINDOW, hostport)

call IFFImage(hostport, 'TREKGUIDE:TREKPICS/OPENPIC', 5, 11, 561, 366, nocolor)
closeport(hostport)
call delay(200)
call closewindow(hostport)


/* ======== END IFF SECTION THEN LOAD MAIN GUIDE FILE ===*/

address command 'amigaguide TREKGUIDE:Trek-The.guide pubscreen TREKGUIDE'

/* ========= THIS SECTION IS FOR THE SAVING OF MARKED EPISODES === */
number = FileList('ENV:TREKGUIDE/*', files, , N)
if number = 0 then do 
	call trekexit()
	end

envfiles = Request(200, 50, 'Do you wish to save your\marked episodes for later?', , YES, NO, TREKGUIDE)
	if envfiles = 'OKAY' then do
	address command 'copy >nil: env:trekguide all envarc:TrekGuide'
	end
	else 
	address command 'delete >NIL: envarc:TrekGuide all'
/* ======== END OF MARKED EPISODES SECTION ===*/

trekexit:
closescreen(trekguide)
address command 'delete >NIL: env:TrekGuide all'
address command 'avail flush >nil:' /* flushes the no longer needed libs from memory */
exit
