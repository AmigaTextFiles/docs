#include <Amiga.h>
#pragma header

#include "compiler.h"

#include "libraries/LCDDriverBase.h"

ULONG __saveds __stdargs L_OpenLibs(void);
void  __saveds __stdargs L_CloseLibs(void);

extern struct LCDDriverBase *LCDDriverBase;

struct ExecBase		*SysBase			=	NULL;

extern char __aligned ExLibName [];
extern char __aligned ExLibID   [];
extern char __aligned Copyright [];

extern const UBYTE LIB_VERS;
extern const UWORD LIB_REV;

extern ULONG InitTab[];

/*	From assembler RomTag.asm. Try to convince MaxonC++ to not optimize it away :-(	*/
extern struct Resident ROMTag;
extern APTR AsmStub;

/*
extern APTR EndResident;

struct Resident __aligned ROMTag =
{
 RTC_MATCHWORD,
 &ROMTag,
 &EndResident,
 RTF_AUTOINIT,
 LIB_VERS,
 NT_LIBRARY,
 0,
 &ExLibName[0],
 &ExLibID[0],
 &InitTab[0]
};

APTR EndResident;
*/

struct MyDataInit                      /* do not change */
{
 UWORD ln_Type_Init;      UWORD ln_Type_Offset;      UWORD ln_Type_Content;
 UBYTE ln_Name_Init;      UBYTE ln_Name_Offset;      ULONG ln_Name_Content;
 UWORD lib_Flags_Init;    UWORD lib_Flags_Offset;    UWORD lib_Flags_Content;
 UWORD lib_Version_Init;  UWORD lib_Version_Offset;  UWORD lib_Version_Content;
 UWORD lib_Revision_Init; UWORD lib_Revision_Offset; UWORD lib_Revision_Content;
 UBYTE lib_IdString_Init; UBYTE lib_IdString_Offset; ULONG lib_IdString_Content;
 ULONG ENDMARK;
} DataTab =
{
 INITBYTE(OFFSET(Node,         ln_Type),      NT_LIBRARY),
 0x80, (UBYTE) OFFSET(Node,    ln_Name),      (ULONG) &ExLibName[0],
 INITBYTE(OFFSET(Library,      lib_Flags),    LIBF_SUMUSED|LIBF_CHANGED),
 INITWORD(OFFSET(Library,      lib_Version),  LIB_VERS),
 INITWORD(OFFSET(Library,      lib_Revision), LIB_REV),
 0x80, (UBYTE) OFFSET(Library, lib_IdString), (ULONG) &ExLibID[0],
 (ULONG) 0
};

 /* Libraries not shareable between Processes or libraries messing
    with RamLib (deadlock and crash) may not be opened here - open/close
    these later locally and or maybe close them fromout L_CloseLibs()
    when expunging !
 */

ULONG __saveds __stdargs L_OpenLibs(void)
{
	SysBase = (*((struct ExecBase **) 4));
	return TRUE|(&ROMTag?TRUE:FALSE);	//	Some harmless sillyness to trick Maxon into linking in the RomTag
}

void __saveds __stdargs L_CloseLibs(void)
{
}
