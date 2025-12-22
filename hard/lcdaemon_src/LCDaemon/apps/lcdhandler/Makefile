VER=1
LINKOPTS=NOVER NOSTARTUP
LCD-handler:	includes.gst lcd-handler.c
	SC lcd-handler.c

clean:
	@-delete lcd-handler *.o *.lnk *.dec QUIET >NIL:
bump:
	SetRev SHOWREV NOANSI NOASM VER $(VER) OBJ LCD-handler DEP lcd-handler.c lcdh_version

includes.gst: includes.h
	SC RESETOPTIONS NOLINK OBJNAME=T:void MAKEGST includes.gst includes.h DEFINE=__USE_SYSBASE
