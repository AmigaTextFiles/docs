AHD = ahd.o hdif.o div32.o devbug.o auto.o cdeb.o
CFLAGS = -ce -v -l -b0
ASFLAGS = -d

all : ahd.device glue.o /hdif.o /glue.o /devbug.o
#   copy hdif.o /hdif.o
#   copy glue.o /glue.o
#   copy devbug.o /devbug.o

ahd.device : $(AHD)
   blink $(AHD) TO $@ LIB lib:amiga.lib lib:debug.lib SC SD
   copy ahd.device /bin

ahd.s : mydev.i messages.i
hdif.s : messages.i

/hdif.o : hdif.o
        copy hdif.o /hdif.o

/glue.o : glue.o
        copy glue.o /glue.o

/devbug.o : devbug.o
        copy devbug.o /devbug.o

#
# Removes everything that can be built from sources

clean:
   delete \#?.o
   -delete ahd.device

