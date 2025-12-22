/* Install.rexx

*/
OPTIONS RESULTS
OPTIONS FAILAT 10


open('Button2ascii','CON:60/100/350/200/Button2ascii/cds')

name='IBrowse'
check='IBrowse.prefs'
ok=''
call writeln 'Button2ascii','Press a button and ENTER'
call writeln 'Button2ascii','ENTER twice to quit'
DO FOREVER



/*	open('input','Button2ascii','R') */
	ok=readln('Button2ascii')
	len=LENGTH(ok)
	ok=LEFT(ok,1)

	IF ok~='' THEN call writeln 'Button2ascii',ok||' = '||C2D(ok)
	IF ok='' & oldok='' THEN BREAK
	IF ok='' & len=1 THEN call writeln 'Button2ascii','32 = Space'
	IF ok='' & len=0 THEN call writeln 'Button2ascii','13 = ENTER'
	oldok=ok
END

