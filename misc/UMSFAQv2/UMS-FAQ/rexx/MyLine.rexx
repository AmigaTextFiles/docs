/* MyLine by TLC v1.0 3/5/95 */

call open(1,'Work:UMS/rexx/lines','r')
nl=readln(1)

lc=random(1,nl,time('s'))

do i=1 to lc
	z=readln(1)
end

call close(1)
say z
exit
