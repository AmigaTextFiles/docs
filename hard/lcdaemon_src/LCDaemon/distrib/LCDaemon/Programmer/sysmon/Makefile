VER = 1
DEPEND =  SysMon_locale.o SysMon.o

SysMon: $(DEPEND)
	$(CC) $(COPTS) LINK $(DEPEND) TO SysMon

SysMon_locale.o : SysMon_locale.c

SysMon_locale.c: SysMon.cd
	flexcat SysMon.cd SysMon_locale.c=C_c_V21.sd  SysMon_locale.h=C_h.sd

bump:
	SetRev SHOWREV NOANSI NOASM VER $(VER) OBJ SysMon DEP SysMon.c SysMon_version

clean:
	Delete *.o *.lnk sysmon_locale* QUIET
