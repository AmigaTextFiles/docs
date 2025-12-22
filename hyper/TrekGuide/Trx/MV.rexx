/*  MARK, UNMARK, VIEW & WIPE SCRIPT FOR TREK-THE GUIDE v1.5
**  v1.6 added non-specific node addressing and added rexxreq support */

if ~show('L','rexxarplib.library') then
	call addlib('rexxarplib.library',0,-30)

arg title series func .

if func = "MARK" then do
        open(tag, 'env:trekguide/'title, 'w')
	writeln(tag, series)
	close(tag)
	result = PostMsg(180, 200,title'\IS NOW MARKED', TREKGUIDE)
	call delay(30)
	result = PostMsg() /* this closes the message requester */
	end

if title = "VIEW" then do
	eplist = FileList('ENV:TREKGUIDE/*', files, , N)
		if eplist = 0 then do
		envfiles = Request(180, 100, 'There are no marked files to view.\Try marking a file first.', , OKAY, ,TREKGUIDE)
		exit
		end

	pick = requestlist(1, files.0, files, 225, 250, 250, 100, TREKGUIDE, sort)
	open(tag, 'env:trekguide/'pick, 'r')
	linein = readln(tag)
		if linein = TOS then linein = TG_ORIG
		if linein = CAR then linein = TG_CARTOONS
		if linein = TNG then linein = TG_TNG
		if linein = DS9 then linein = TG_DS9		
		if linein = VOY then linein = TG_VOYAGER
		if linein = TMP then linein = TG_STMP
	address amigaguide.1 link linein'/'pick
	/* address showguide.1 LINK 'TG-ORIG/THE_NAKED_TIME */
	end

if title = "CLEAR" then do   /* THIS IS THE WIPE COMMAND */

	eplist = FileList('ENV:TREKGUIDE/*', files, , N)

		if eplist ~= 0 then do
		envfiles = Request(180, 250, 'Do you really want to\DELETE your marked files?', , YES,NO,TREKGUIDE)
		end
		if envfiles = '' then do
		exit
		end

		if eplist = 0 then do
		envfiles = Request(180, 250, 'You have no marked files to delete.', , OKAY,,TREKGUIDE)
		exit
		end

	address command 'delete env:TrekGuide all'
        address command 'delete envarc:TrekGuide all'

	call delay(30)
	address command 'makedir env:TrekGuide'
	exit
	end

if series = "UNMARK" then do

	eplist = FileList('ENV:TREKGUIDE/'title, files, , N)
		if eplist = 0 then do
		envfiles = Request(180, 250, 'THIS EPISODE IS NOT MARKED.', , OKAY,,TREKGUIDE)
		exit
		end

        address command 'delete env:trekguide/'title
	result = PostMsg(180, 200,title'\IS NOW UN-MARKED', TREKGUIDE)
	call delay(40)
	result = PostMsg() /* this closes the message requester */
	exit
	end
