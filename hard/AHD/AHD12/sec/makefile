OBJS = sec.o /glue.o /hdif.o /devbug.o
CFLAGS = -ce -v -b0

sec : $(OBJS)
        blink lib:c.o $(OBJS) TO sec LIB lib:lc.lib lib:amiga.lib lib:debug.lib SC SD ND
        copy sec /bin

clean :
        delete \#?.o
        -delete sec


