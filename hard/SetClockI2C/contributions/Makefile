#
## use with: make "CC=gcc -fbaserel"
#

TARGET = SetClock

RM	= rm -f
CC	= gcc
CFLAGS	= -O2 -fomit-frame-pointer -msmall-code
LDFLAGS	= -s -noixemul

OBJS	= SetClockI2C.o rtcI2C.o

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	-$(RM) $(TARGET) $(OBJS)

# dependencies

SetClockI2C.o: SetClockI2C.c rtcI2C.h clockpref.h
rtcI2C.o: rtcI2C.c rtcI2C.h clockpref.h
