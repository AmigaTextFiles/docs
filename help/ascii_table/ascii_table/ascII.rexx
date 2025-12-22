/* saves ascii-table to ram:ascii.txt */


open('outfile','ram:ascii.txt','W')
title='ASCII-Table for AMIGA'
info='Codes marked "<?>" are not known. ( by me.)'
writeln('outfile',title)
writeln('outfile',info)
writeln('outfile','')
say title
say info

DO i=0 TO 63
	ai=i
	bi=i+64
	ci=i+128
	di=i+192
	a=' '||D2C(ai)||' '
	b=' '||D2C(bi)||' '
	c=' '||D2C(ci)||' '
	d=' '||D2C(di)||' '

	IF ai<32 then a='<?>'
	IF ai<11 then a=' <?>'
	IF ci>127 & ci<160 THEN c='<?>'
	IF bi<100 then b=' '||b

/* Add new codes below */
	IF ai=0 THEN a=' NUL'
	IF ai=7 THEN a=' BEL'
	IF ai=8 THEN a=' C<-'
     IF ai=9 THEN a=' TAB'
	IF ai=10 THEN a='NL '
	IF ai=13 THEN a='RET'
	IF ci=155 THEN c='BTb'

	line= ai||'-'||a||'    'bi||'-'||b||'    'ci||'-'||c||'    'di||'-'||d
	say line
	writeln('outfile',line)
END
say 'Saved as ram:ascii.txt'
close('outfile')