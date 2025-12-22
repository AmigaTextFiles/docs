ALL=	AllocAslRequestTags.o AslRequestTags.o CreateGadget.o CreateMenus.o \
	EasyRequest.o GetVisualInfo.o GT_GetGadgetAttrs.o \
	GT_SetGadgetAttrs.o LayoutMenuItems.o OpenWindowTags.o \
	LayoutMenus.o OpenScreenTags.o stricmp.o \
	OpenCatalog.o SetAttrs.o DoMethod.o SystemTags.o \
	HookEntry.o FPrintf.o CreateNewProcTags.o \
	NewObject.o AllocTransaction.o CreateEntity.o HostRequest.o \
	AllocDosObjectTags.o \
	intuition_lib.o gadtools_lib.o locale_lib.o asl_lib.o dos_lib.o \
	envoy_lib.o nipc_lib.o

ALLL=	AllocAslRequestTags.ol AslRequestTags.ol CreateGadget.ol CreateMenus.ol \
	EasyRequest.ol GetVisualInfo.ol GT_GetGadgetAttrs.ol \
	GT_SetGadgetAttrs.ol LayoutMenuItems.ol OpenWindowTags.ol \
	LayoutMenus.ol OpenScreenTags.ol stricmp.ol \
	OpenCatalog.ol SetAttrs.ol DoMethod.ol SystemTags.ol \
	HookEntry.ol FPrintf.ol CreateNewProcTags.ol \
	NewObject.ol AllocTransaction.ol CreateEntity.ol HostRequest.ol \
	AllocDosObjectTags.ol \
	intuition_lib.ol gadtools_lib.ol locale_lib.ol asl_lib.ol dos_lib.ol \
	envoy_lib.ol nipc_lib.ol

MUI=	MUI_NewObject.o MUI_Request.o MUI_AllocAslRequestTags.o \
	MUI_AslRequestTags.o muimaster_lib.o

MUIL=	MUI_NewObject.ol MUI_Request.ol MUI_AllocAslRequestTags.ol \
	MUI_AslRequestTags.ol muimaster_lib.ol

CC=cc
AS=as
CAT=type

CFLAGS=-wlp
AFLAGS=
CLFLAGS=-wlp -md

.c.ol:
    -$(CC) $(CLFLAGS) -o $*.ol $*.c

.asm.ol:
    -echo "    far data" >t:ass.asm
    -$(CAT) $*.asm >>t:ass.asm
    -$(AS) -zap -o $*.ol t:ass.asm

all: 20.lib 20l.lib mui.lib muil.lib

20.lib: $(ALL)
	-delete 20.lib quiet
	lb 20.lib $(ALL)

20l.lib: $(ALLL)
	-delete 20l.lib quiet
	lb 20l.lib $(ALLL)

mui.lib: $(MUI)
	-delete mui.lib quiet
	lb mui.lib $(MUI)

muil.lib: $(MUIL)
	-delete muil.lib quiet
	lb muil.lib $(MUIL)


clean:
	delete #?.o #?.ol 20.lib 20l.lib quiet
