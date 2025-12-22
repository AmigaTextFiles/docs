VER = 2              #  Program version (revision controlled by SetRev)
CSH = csh -n -N -M -c   #  CShell script call
TILDE = ~            #  for DOS wildcard matching
D = distrib/LCDaemon

#distrib: nodebug all
#   $(CSH) "cd lcdecho;nodebug.sh;smake -a"
#   $(CSH) "cd lcdtest;nodebug.sh;smake -a"
#   $(CSH) "cd sysmon;nodebug.sh;smake -a"
#  $(CSH) "cd EC:/Amiga_E_3/source/reset;smake distrib"
#  copy LCDaemon t:LCDaemon ALL QUIET
#  copy LCDaemon.info t: QUIET
#  copy lcd lcd_ami lcd_pit lcd_mfc3 t:LCDaemon/ QUIET
#  copy doc/ t:LCDaemon/Docs/ ALL QUIET
#  Type History.h >t:LCDaemon/Docs/History
#  copy lcdecho/lcdecho t:LCDaemon/Utilities/ QUIET
#  copy lcdtest/lcdtest t:LCDaemon/Utilities/ QUIET
#  copy handle/handle t:LCDaemon/Utilities/ QUIET
#  copy lcdhandler/LCD lcdhandler/lcd-handler t:LCDaemon/Utilities QUIET
#  copy sysmon/SysMon t:LCDaemon/Utilities/ QUIET
#  copy mdev:demo/sysmon/sysinfo t:LCDaemon/Utilities/ QUIET
#  copy EC:/Amiga_E_3/source/reset/ResetIntercept.lha t:LCDaemon/Utilities/ QUIET
#  copy \#?.rexx t:LCDaemon/Rexx/ QUIET
#  copy lcd.o lcd.h parallel.c pit.c mfc3.c mfc3bits.h pitbits.h t:LCDaemon/Programmer/ QUIET
#  copy lcdecho/$(TILDE)(lcdecho|lcdecho.o) t:LCDaemon/Programmer/LCDecho QUIET
#  copy lcdtest/$(TILDE)(lcdtest|lcdtest.o) t:LCDaemon/Programmer/LCDtest QUIET
#  copy handle/$(TILDE)(handle|handle.o) t:LCDaemon/Programmer/handle QUIET
#  $(CSH) cls
#  lha a -r t:LCDaemon.lha t:LCDaemon t:LCDaemon.info
#  Delete t:LCDaemon ALL QUIET
#  copy t:LCDaemon.lha ""
#   Delete t:LCDaemon.lha t:LCDaemon.info QUIET

dist :
	copy lcd $D/lcd
	copy lcd.h $D/Programmer/
	copy history.h $D/Docs/History
	$(CSH) copy -u DriverLib/.../lcd*.library $D/Programmer/Driver/
	$(CSH) copy -u DriverLib/*.(h\|asm\|c) $D/Programmer/Driver/
	$(CSH) copy -u DriverLib/Guppy/*.(h\|i\|c) $D/Programmer/Driver/Guppy
	$(CSH) copy -u DriverLib/Window/*.(h\|i\|c) $D/Programmer/Driver/Window
	copy DriverLib/include/ $D/Programmer/Driver/include/ ALL
	copy apps/ $D/Programmer/ ALL
	copy apps/lcdecho/lcdecho apps/lcdhandler/lcd-handler apps/lcdhandler/LCD apps/sysmon/sysmon /SysMon/SysInfo $D/Utilities

#all:		$D/Docs/History				\
#			$D/Programmer/Driver/		\
#			$D/Programmer/lcd.h			\
#			$D/Programmer/mfc3bits.h	\
#			$D/Programmer/pitbits.h		\
#			$D/Utilities/SysInfo		\
#			$D/Programmer/LCDaemon.o	\
#			$D/Programmer/SysInfo.cpp	\
#			$D/lcd_win					\
#			$D/lcd_par					\
#			$D/Programmer/handle/handle.c	\
#			$D/Utilities/handle			\
#			$D/Programmer/lcdecho/lcdecho.c	\
#			$D/Utilities/lcdecho		\
#			$D/Utilities/sysmon			

$D/Docs/History				:	history.h
	copy $? $@
$D/Programmer/Driver		:	
	copy $? $@
$D/Programmer/lcd.h			:	lcd.h
	copy $? $@
$D/Programmer/mfc3bits.h	:	mfc3bits.h
	copy $? $@
$D/Programmer/pitbits.h		:	pitbits.h
	copy $? $@
$D/Utilities/SysInfo		:	/SysMon/SysInfo
	copy $? $@
$D/Programmer/SysInfo.cpp	:	/SysMon/SysInfo.cpp
	copy $? $@
$D/lcd						:	lcd
	copy $? $@
$D/Programmer/handle/handle.c	:	apps/handle/handle.c
	copy $? $@
$D/Utilities/handle			:	apps/handle/handle
	copy $? $@
$D/Programmer/lcdecho/lcdecho.c	:	apps/lcdecho/lcdecho.c
	copy $? $@
$D/Utilities/lcdecho		:	apps/lcdecho/lcdecho
	copy $? $@
$D/Utilities/sysmon			:	apps/sysmon/sysmon
	copy $? $@


#distrib	:	all
#	@-delete lcdaemon.lha
#	lha a -r LCDaemon.lha LCDaemon LCDaemon.info LCDaemon.readme

bump:
   SetRev SHOWREV NOANSI NOASM VER $(VER) OBJ LCDaemon DEP lcd.c lcd_version
