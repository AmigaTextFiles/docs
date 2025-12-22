OBJS = config.o /glue.o /hdif.o /devbug.o
CFLAGS = -ce -v

config : $(OBJS)
        blink lib:c.o $(OBJS) TO config LIB lib:lc.lib lib:amiga.lib lib:debug.lib SC SD ND
        copy config /bin

clean :
        delete \#?.o
        -delete config


