OBJS = prep.o /glue.o /hdif.o /devbug.o
CFLAGS = -ce -v -b0

prep : $(OBJS)
        blink lib:c.o $(OBJS) TO prep LIB lib:lc.lib lib:amiga.lib lib:debug.lib SC SD ND
        copy prep /bin

clean :
        delete \#?.o
        -delete prep


