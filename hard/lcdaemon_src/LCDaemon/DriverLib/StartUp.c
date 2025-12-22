#include "Amiga.h"
#pragma header

#include "libraries/LCDDriverBase.h"
#include "clib/LCDDriver_protos.h"
#include "guppy/guppy_version.h"

ULONG	L_OpenLibs(void);
void	L_CloseLibs(void);

struct LCDDriverBase * InitLib( register __a6 struct ExecBase *sysbase,
                    register __a0 struct SegList       *seglist,
                    register __d0 struct LCDDriverBase *lcddrvb);
struct LCDDriverBase * OpenLib( register __a6 struct LCDDriverBase *LCDDriverBase);
struct SegList * CloseLib( register __a6 struct LCDDriverBase *LCDDriverBase);
struct SegList * ExpungeLib( register __a6 struct LCDDriverBase *lcddrvb);
ULONG ExtFuncLib(void);

extern char ExLibName [];
extern char ExLibID   [];
extern char Copyright [];

const UBYTE LIB_VERS=VERSION;
const UWORD LIB_REV=REVISION;

const struct MyDataInit
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
 0x80, (UBYTE) OFFSET(Node,    ln_Name),      (ULONG) ExLibName,
 INITBYTE(OFFSET(Library,      lib_Flags),    LIBF_SUMUSED|LIBF_CHANGED),
 INITWORD(OFFSET(Library,      lib_Version),  LIB_VERS),
 INITWORD(OFFSET(Library,      lib_Revision), LIB_REV),
 0x80, (UBYTE) OFFSET(Library, lib_IdString), (ULONG) ExLibID,
 (ULONG) 0
};

/*
extern APTR *FuncTab;
*/
/*
const struct {
	APTR	open;
	APTR	close;
	APTR	expunge;
	APTR	extfunc;
	APTR	alloclcd;
	APTR	freelcd;
	APTR	lcdputchar;
	APTR	lcddelayfor;
	APTR	lcdpremessage;
	APTR	lcdpostmessage;
	APTR	endmarker;
} FuncTab = {
	OpenLib,
	CloseLib,
	ExpungeLib,
	ExtFuncLib,

	AllocLCD,
	FreeLCD,
	LCDPutChar,
	LCDDelayFor,
	LCDPreMessage,
	LCDPostMessage,

	(APTR) ((LONG)-1)
};

const struct InitTable
{
	ULONG              LibBaseSize;
	APTR               FunctionTable;
	struct MyDataInit *DataTable;
	APTR               InitLibTable;
} InitTab =
{
	sizeof(struct LCDDriverBase),
	&FuncTab,
	&DataTab,
	InitLib
};
*/

extern struct LCDDriverBase *LCDDriverBase;

struct LCDDriverBase * InitLib( register __a6 struct ExecBase      *sysbase,
                    register __a0 struct SegList       *seglist,
                    register __d0 struct LCDDriverBase *lcddrvb)
{
 GetBaseReg();
 InitModules();

 LCDDriverBase = lcddrvb;

 LCDDriverBase->lcddrvb_SysBase = sysbase;
 LCDDriverBase->lcddrvb_SegList = seglist;

 if(L_OpenLibs()) return(LCDDriverBase);

 L_CloseLibs();

 return(NULL);
}

struct LCDDriverBase * OpenLib( register __a6 struct LCDDriverBase *LCDDriverBase)
{
 GetBaseReg();

 LCDDriverBase->lcddrvb_LibNode.lib_OpenCnt++;

 LCDDriverBase->lcddrvb_LibNode.lib_Flags &= ~LIBF_DELEXP;

 return(LCDDriverBase);
}

struct SegList * CloseLib( register __a6 struct LCDDriverBase *LCDDriverBase)
{
 GetBaseReg();

 LCDDriverBase->lcddrvb_LibNode.lib_OpenCnt--;

 if(!LCDDriverBase->lcddrvb_LibNode.lib_OpenCnt)
  {
   if(LCDDriverBase->lcddrvb_LibNode.lib_Flags & LIBF_DELEXP)
    {
     return( ExpungeLib(LCDDriverBase) );
    }
  }

 return(NULL);
}

struct SegList * ExpungeLib( register __a6 struct LCDDriverBase *lcddrvb)
{
 struct LCDDriverBase *LCDDriverBase = lcddrvb;
 struct SegList       *seglist;

 GetBaseReg();

 if(!LCDDriverBase->lcddrvb_LibNode.lib_OpenCnt)
  {
   ULONG negsize, possize, fullsize;
   UBYTE *negptr = (UBYTE *) LCDDriverBase;

   seglist = LCDDriverBase->lcddrvb_SegList;

   Remove((struct Node *)LCDDriverBase);

   L_CloseLibs();

   negsize  = LCDDriverBase->lcddrvb_LibNode.lib_NegSize;
   possize  = LCDDriverBase->lcddrvb_LibNode.lib_PosSize;
   fullsize = negsize + possize;
   negptr  -= negsize;

   FreeMem(negptr, fullsize);

   CleanupModules();

   return(seglist);
  }
  
 LCDDriverBase->lcddrvb_LibNode.lib_Flags |= LIBF_DELEXP;

 return(NULL);
}

ULONG ExtFuncLib(void)
{
 return(NULL);
}

struct LCDDriverBase *LCDDriverBase = NULL;

extern struct LCDDriverBase *LCDDriverBase;

struct ExecBase		*SysBase			=	NULL;

/*extern ULONG InitTab[];*/

/*	From assembler RomTag.asm. Try to convince MaxonC++ to not optimize it away :-(	*/
extern struct Resident ROMTag;
extern APTR AsmStub;

ULONG L_OpenLibs(void)
{
	SysBase = (*((struct ExecBase **) 4));
	return TRUE|(&ROMTag?TRUE:FALSE);	//	Some harmless sillyness to trick Maxon into linking in the RomTag
}

void L_CloseLibs(void)
{
}

