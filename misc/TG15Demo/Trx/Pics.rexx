/*  EPISODE PICS SCRIPT BY JIM HINES- - SURE HOPE IT WORKS */

if ~show('L','rexxarplib.library') then
	call addlib('rexxarplib.library',0,-30)

/* The args are taken from the document itself */
arg pic orent episode port .

if ~showlist(p, NOTIFYPORT) then do
	address command 'trekguide:vt trekguide:trekpics/EP'pic
        exit
	end

if port = '' then do
	hostport = hostport
	address ARexx "'call CreateHost(hostport, notifyport, trekguide)'"
	WaitForPort hostport
	end

if port = 2 then do
	hostport = hostport.2
	address ARexx "'call CreateHost(hostport.2, notifyport, trekguide)'"
	WaitForPort hostport
	end

if port = 3 then do
	hostport = hostport.3
	address ARexx "'call CreateHost(hostport.3, notifyport, trekguide)'"
	WaitForPort hostport
	end

if port = 4 then do
	hostport = hostport.4
	address ARexx "'call CreateHost(hostport.4, notifyport, trekguide)'"
	WaitForPort hostport
	end

idcmp = 'CLOSEWINDOW+GADGETUP'
flags = 'WINDOWCLOSE+WINDOWDRAG+WINDOWDEPTH+WINDOWSIZING+BACKFILL'

if orent = "V" then do

call OpenWindow(hostport, 160, 50, 315, 325, idcmp, flags, episode)
call SetNotify(hostport, CLOSEWINDOW, hostport)
call IFFImage(hostport, 'trekguide:trekpics/EP'pic, 5, 11, 291, 313, nocolor)
closeport(hostport)
end

if orent = "H" then do

call OpenWindow(hostport, 160, 66, 390, 273, idcmp, flags, episode)
call SetNotify(hostport, CLOSEWINDOW, hostport)
call IFFImage(hostport, 'trekguide:trekpics/ep'pic, 5, 11, 367, 258, nocolor)
closeport(hostport)
closeport(hostport.2)
closeport(hostport.3)
closeport(hostport.4)
end
