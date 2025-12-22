OBJS = fmt.o /glue.o /hdif.o /devbug.o
CFLAGS = -ce -v -b0

fmt : $(OBJS)
        blink lib:c.o $(OBJS) TO fmt LIB lib:lc.lib lib:amiga.lib lib:debug.lib SC SD ND
        copy fmt /bin

clean :
        delete \#?.o
        -delete fmt


