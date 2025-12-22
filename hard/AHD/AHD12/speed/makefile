OBJS = speed.o
CFLAGS = -ce -v

speed : $(OBJS)
        blink lib:c.o $(OBJS) TO speed LIB lib:lcm.lib lib:lc.lib lib:amiga.lib SC SD ND
        copy speed /bin

clean :
        delete \#?.o
        -delete speed


