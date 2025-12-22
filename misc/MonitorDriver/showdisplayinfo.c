/*
** This is a small file that lists the contents of the
** graphics library display info database in raw form.
**
** Beware, this program does not follow good programming practice;
** it's mere purpose is to demonstrate how the graphics data is
** (dis-)organized internally. Do not use the algorithms in this
** program for your own work, but follow the documented interfaces of
** graphics, in specific GetDisplayInfoData().
**
*/

#include <exec/resident.h>
#include <graphics/gfxbase.h>
#include <graphics/displayinfo.h>
#include <graphics/gfx.h>
#include <utility/tagitem.h>
#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/utility_pragmas.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/utility_protos.h>

struct ExecBase *SysBase;
struct DosLibrary *DOSBase;
struct Library *UtilityBase;
struct GfxBase *GfxBase;

struct RecordNode 
{
    struct RecordNode *rcn_Succ;    /* next sibling */
    struct RecordNode *rcn_Pred;    /* previous sibling */
    struct RecordNode *rcn_Child;   /* subtype of record */
    struct RecordNode *rcn_Parent;  /* supertype of record */
};

struct DisplayInfoRecord 
{
    struct RecordNode  rec_Node;
    UWORD	       rec_MajorKey;
    UWORD	       rec_MinorKey;
    struct TagItem     rec_Tag;     /* { TAG_DONE, 0 } or { TAG_MORE, &data } */
    ULONG	       rec_Control;
    ULONG              (*rec_get_data)();
    ULONG              (*rec_set_data)();
    struct Rectangle   rec_ClipOScan;
    ULONG	       reserved[2];
};

/* the "private" internal definition of datachunk types */

struct RawDisplayInfo
{
	struct	QueryHeader Header;
	UWORD	NotAvailable;
	ULONG	PropertyFlags;
	Point	Resolution;
	UWORD	PixelSpeed;
	UWORD	NumStdSprites;
	UWORD	PaletteRange;
	Point	SpriteResolution;
	ULONG	ModeID;
	UBYTE	RedBits;
	UBYTE	GreenBits;
	UBYTE	BlueBits;
	UBYTE	pad2[5];
	ULONG	reserved[2];    /* tag end substitute */
};

struct RawNameInfo
{
	struct	QueryHeader Header;
	UBYTE	Name[DISPLAYNAMELEN];
	ULONG	reserved[2];    /* tag end substitute */
};

struct RawDimensionInfo
{
	struct	QueryHeader Header;
	UWORD	MaxDepth;
        UWORD   MinRasterWidth;
        UWORD   MinRasterHeight;
        UWORD   MaxRasterWidth;
        UWORD   MaxRasterHeight;
	struct  Rect32	Nominal;
	struct  Rect32	MaxOScan;
	struct  Rect32	VideoOScan;
	UBYTE	HWMaxDepth;
	UBYTE   pad[5];
	ULONG	reserved[2];    /* tag end substitute */
};

struct RawMonitorInfo
{
	struct	QueryHeader   Header;
	struct	MonitorSpec  *Mspc;
        Point   ViewPosition;
        Point   ViewResolution;
        struct  Rectangle ViewPositionRange;
        UWORD   TotalRows;
        UWORD   TotalColorClocks;
        UWORD   MinRow;
	WORD	Compatibility;
	struct  Rect32	TxtOScan;
	struct  Rect32	StdOScan;
	Point	MouseTicks;
	Point	DefaultViewPosition;
	ULONG	PreferredModeID;
	ULONG	reserved[2];    /* tag end substitute */
};

struct RawVecInfo
{
	struct	QueryHeader Header;
	APTR	Vec;
	APTR	Data;
	UWORD	Type;
	UWORD	pad[3];
	ULONG	reserved[2];
};

typedef ULONG __stdargs MakeFunc(struct View *v, struct ViewPort *vp, struct ViewPortExtra *vpe);

struct VecTable
{
  void __asm (*MoveSprite)(register __a0 struct ViewPort *,register __a1 struct SimpleSprite *,
			   register __d0 UWORD x,register __d1 UWORD y);
  void __asm (*ChangeSprite)(register __a0 struct ViewPort *,register __a1 struct SimpleSprite *,
			     register __a2 USHORT *);
  void __asm (*ScrollVP)(register __a0 struct ViewPort *);
  MakeFunc    **BuildVP; 
  void __asm (*PokeColors)(register __a2 struct ViewPort *);
  /* extendable */
};

struct ProgInfo
{
	UWORD	bplcon0;	/* minimum needed for this mode */
	UWORD	bplcon2;	/* has KILLEHB flag, PF2PRI, and SOGEN */
	UBYTE	ToViewX;	/* convert from VP horizontal resoliution to View */
	UBYTE	pad;
	UWORD	Flags;		/* see below */
	UWORD	MakeItType;
	UWORD	ScrollVPCount;
	UWORD	DDFSTRTMask;	/* for 1x, 2x or 4x */
	UWORD	DDFSTOPMask;
	UBYTE	ToDIWResn;	/* convert from the stored DisplayWindow resolution to hardware resolution */
	UBYTE	Offset;		/* for calculating offsets */
};

/*
** Print information on gfxbase and bootmenu
*/
void PrintResidentInfo(void);
/*
** Print the contents of the display info database
*/
void PrintDisplayInfo(void);

LONG __asm __saveds Startup(void)
{
  LONG rc = 25;
  
  SysBase = *((struct ExecBase **)(4L));

  if (DOSBase = (struct DosLibrary *)OpenLibrary("dos.library",37L)) {
    if (UtilityBase = OpenLibrary("utility.library",37L)) {
      if (GfxBase = (struct GfxBase *)OpenLibrary("graphics.library",40L)) {
	PrintResidentInfo();
	PrintDisplayInfo();
	CloseLibrary((struct Library *)GfxBase);
	rc = 0;
      } else {
	Printf("This program requires graphics V40\n");
      }
      CloseLibrary(UtilityBase);
    }
    CloseLibrary((struct Library *)DOSBase);
  }

  return rc;
}

void PrintResidentInfo(void)
{
  struct Resident *resident;

  resident = FindResident("bootmenu");
  if (resident) {
    Printf("BootMenu ID: %s\n",resident->rt_IdString);
  } else {
    Printf("BootMenu not found in resident list!\n");
  }

  resident = FindResident("graphics.library");
  if (resident) {
    Printf("Graphics ID: %s\n",resident->rt_IdString);
  } else {
    Printf("Graphics not found in resident list!\n");
  }
}

const char *Indent(LONG indent)
{
  static const char *in = "        ";

  if (indent > 8)
    indent = 8;
  
  return &in[8 - indent];
}

void PrintRawDisplayInfo(struct RawDisplayInfo *rdi,LONG indent)
{
  Printf("%sNotAvailable           : %lu\n",Indent(indent),rdi->NotAvailable);
  Printf("%sPropertyFlags          : 0x%08lx\n",Indent(indent),rdi->PropertyFlags);
  Printf("%sResolution.x           : %ld\n",Indent(indent),rdi->Resolution.x);
  Printf("%sResolution.y           : %ld\n",Indent(indent),rdi->Resolution.y);
  Printf("%sPixelSpeed             : %ldns\n",Indent(indent),rdi->PixelSpeed);
  Printf("%sSprites                : %ld\n",Indent(indent),rdi->NumStdSprites);
  Printf("%sPaletteRange           : %ld\n",Indent(indent),rdi->NumStdSprites);
  Printf("%sSpriteRes.x            : %ld\n",Indent(indent),rdi->SpriteResolution.x);
  Printf("%sSpriteRes.y            : %ld\n",Indent(indent),rdi->SpriteResolution.y);
  Printf("%sModeID                 : 0x%08lx\n",Indent(indent),rdi->ModeID);
  Printf("%sRedBits                : %ld\n",Indent(indent),rdi->RedBits);
  Printf("%sGreenBits              : %ld\n",Indent(indent),rdi->GreenBits);
  Printf("%sBlueBits               : %ld\n",Indent(indent),rdi->BlueBits);
}

void PrintRawMonitorInfo(struct RawMonitorInfo *rmi,LONG indent)
{
  Printf("%sViewPosition.x         :%ld\n",Indent(indent),rmi->ViewPosition.x);
  Printf("%sViewPosition.y         :%ld\n",Indent(indent),rmi->ViewPosition.y);
  Printf("%sViewResolution.x       :%ld\n",Indent(indent),rmi->ViewResolution.x);
  Printf("%sViewResolution.y       :%ld\n",Indent(indent),rmi->ViewResolution.y);
  Printf("%sViewPositionRange.MinX :%ld\n",Indent(indent),rmi->ViewPositionRange.MinX);
  Printf("%sViewPositionRange.MinY :%ld\n",Indent(indent),rmi->ViewPositionRange.MinY);
  Printf("%sViewPositionRange.MaxX :%ld\n",Indent(indent),rmi->ViewPositionRange.MaxX);
  Printf("%sViewPositionRange.MaxY :%ld\n",Indent(indent),rmi->ViewPositionRange.MaxY);
  Printf("%sTotalRows              :%lu\n",Indent(indent),rmi->TotalRows);
  Printf("%sTotalColorClocks       :%lu\n",Indent(indent),rmi->TotalColorClocks);
  Printf("%sMinRow                 :%lu\n",Indent(indent),rmi->MinRow);
  Printf("%sCompatibility          :%ld\n",Indent(indent),rmi->Compatibility);
  Printf("%sTextOverscan.MinX      :%ld\n",Indent(indent),rmi->TxtOScan.MinX);
  Printf("%sTextOverscan.MinY      :%ld\n",Indent(indent),rmi->TxtOScan.MinY);
  Printf("%sTextOverscan.MaxX      :%ld\n",Indent(indent),rmi->TxtOScan.MaxX);
  Printf("%sTextOverscan.MaxY      :%ld\n",Indent(indent),rmi->TxtOScan.MaxY);
  Printf("%sStdOverscan.MinX       :%ld\n",Indent(indent),rmi->StdOScan.MinX);
  Printf("%sStdOverscan.MinY       :%ld\n",Indent(indent),rmi->StdOScan.MinY);
  Printf("%sStdOverscan.MaxX       :%ld\n",Indent(indent),rmi->StdOScan.MaxX);
  Printf("%sStdOverscan.MaxY       :%ld\n",Indent(indent),rmi->StdOScan.MaxY);
  Printf("%sMouseTicks.x           :%ld\n",Indent(indent),rmi->MouseTicks.x);
  Printf("%sMouseTicks.y           :%ld\n",Indent(indent),rmi->MouseTicks.y);
  Printf("%sDefaultViewPosition.x  :%ld\n",Indent(indent),rmi->DefaultViewPosition.x);
  Printf("%sDefaultViewPosition.y  :%ld\n",Indent(indent),rmi->DefaultViewPosition.y);
  Printf("%sPreferredModeID        :0x%08lx\n",Indent(indent),rmi->PreferredModeID);
}

void PrintRawDimensionInfo(struct RawDimensionInfo *rdi,LONG indent)
{
  Printf("%sMaxDepth               :%ld\n",Indent(indent),rdi->MaxDepth);
  Printf("%sMinRasterWidth         :%lu\n",Indent(indent),rdi->MinRasterWidth);
  Printf("%sMinRasterHeight        :%lu\n",Indent(indent),rdi->MinRasterHeight);
  Printf("%sMaxRasterWidth         :%lu\n",Indent(indent),rdi->MaxRasterWidth);
  Printf("%sMaxRasterHeight        :%lu\n",Indent(indent),rdi->MaxRasterHeight);
  Printf("%sNominal Overscan.MinX  :%ld\n",Indent(indent),rdi->Nominal.MinX);
  Printf("%sNominal Overscan.MinY  :%ld\n",Indent(indent),rdi->Nominal.MinY);
  Printf("%sNominal Overscan.MaxX  :%ld\n",Indent(indent),rdi->Nominal.MaxX);
  Printf("%sNominal Overscan.MaxY  :%ld\n",Indent(indent),rdi->Nominal.MaxY);
  Printf("%sMaximal Overscan.MinX  :%ld\n",Indent(indent),rdi->MaxOScan.MinX);
  Printf("%sMaximal Overscan.MinY  :%ld\n",Indent(indent),rdi->MaxOScan.MinY);
  Printf("%sMaximal Overscan.MaxX  :%ld\n",Indent(indent),rdi->MaxOScan.MaxX);
  Printf("%sMaximal Overscan.MaxY  :%ld\n",Indent(indent),rdi->MaxOScan.MaxY);
  Printf("%sVideo   Overscan.MinX  :%ld\n",Indent(indent),rdi->VideoOScan.MinX);
  Printf("%sVideo   Overscan.MinY  :%ld\n",Indent(indent),rdi->VideoOScan.MinY);
  Printf("%sVideo   Overscan.MaxX  :%ld\n",Indent(indent),rdi->VideoOScan.MaxX);
  Printf("%sVideo   Overscan.MaxY  :%ld\n",Indent(indent),rdi->VideoOScan.MaxY);
  Printf("%sHWMaxDepth             :%lu\n",Indent(indent),rdi->HWMaxDepth);
}

void PrintRawNameInfo(struct RawNameInfo *rni,LONG indent)
{
  Printf("%sName                   :%s\n",Indent(indent),rni->Name);
}

void PrintRawVecInfo(struct RawVecInfo *rvi,LONG indent)
{
  struct VecTable *vt = (struct VecTable *)(rvi->Vec);
  struct ProgInfo *pinfo = (struct ProgInfo *)(rvi->Data);
							
  Printf("%sVec                    :0x%08lx\n",Indent(indent),rvi->Vec);
  if (rvi->Vec) {
    Printf("%s MoveSprite            :0x%08lx\n",Indent(indent),vt->MoveSprite);
    Printf("%s ChangeSprite          :0x%08lx\n",Indent(indent),vt->ChangeSprite);
    Printf("%s ScrollVP              :0x%08lx\n",Indent(indent),vt->ScrollVP);
    Printf("%s BuildVPFunctions      :0x%08lx\n",Indent(indent),vt->BuildVP);
    Printf("%s PokeColors            :0x%08lx\n",Indent(indent),vt->PokeColors);
  }
  Printf("%sData                   :0x%08lx\n",Indent(indent),rvi->Data);
  if (pinfo) {
    Printf("%s bplcon0               :0x%04lx\n",Indent(indent),pinfo->bplcon0);
    Printf("%s bplcon2               :0x%04lx\n",Indent(indent),pinfo->bplcon2);
    Printf("%s ToViewX               :%ld\n",Indent(indent),pinfo->ToViewX);
    Printf("%s Flags                 :0x04%lx\n",Indent(indent),pinfo->Flags);
    Printf("%s MakeItType            :0x04%lx\n",Indent(indent),pinfo->MakeItType);
    Printf("%s ScrollVPCount         :%ld\n",Indent(indent),pinfo->ScrollVPCount);
    Printf("%s DDFStartMask          :0x%04lx\n",Indent(indent),pinfo->DDFSTRTMask);
    Printf("%s DDFStopMask           :0x%04lx\n",Indent(indent),pinfo->DDFSTOPMask);
    Printf("%s ToDIWResn             :%ld\n",Indent(indent),pinfo->ToDIWResn);
    Printf("%s Offset                :%ld\n",Indent(indent),pinfo->Offset);
  }
  Printf("%sType                   :0x%04lx\n",Indent(indent),rvi->Type);
}

void PrintDisplayInfoTags(struct TagItem *tag,LONG indent)
{
  if (tag == NULL)
    Printf("%sNULL\n",Indent(indent));
  
  while (tag) {
    switch(tag->ti_Tag) {
    case TAG_DONE:
      Printf("%sTAG_DONE\n",Indent(indent));
      return;
      break;
    case TAG_MORE:
      Printf("%sTAG_MORE\n",Indent(indent));
      tag = (struct TagItem *)(tag->ti_Data);
      continue;
    case TAG_SKIP:
      Printf("%sTAG_SKIP %ld\n",Indent(indent),tag->ti_Data);
      tag += tag->ti_Data;
      break;
    case TAG_IGNORE:
      Printf("%sTAG_IGNORE\n",Indent(indent));
      break;
    case DTAG_DISP:
      Printf("%sDTAG_DISP 0x%08lx\n",Indent(indent),tag->ti_Data);
      PrintRawDisplayInfo((struct RawDisplayInfo *)tag,indent+1);
      break;
    case DTAG_DIMS:
      Printf("%sDTAG_DIMS 0x%08lx\n",Indent(indent),tag->ti_Data);
      PrintRawDimensionInfo((struct RawDimensionInfo *)tag,indent+1);
      break;
    case DTAG_MNTR:
      Printf("%sDTAG_MNTR 0x%08lx\n",Indent(indent),tag->ti_Data);
      PrintRawMonitorInfo((struct RawMonitorInfo *)tag,indent+1);
      break;
    case DTAG_NAME:
      Printf("%sDTAG_NAME 0x%08lx\n",Indent(indent),tag->ti_Data);
      PrintRawNameInfo((struct RawNameInfo *)tag,indent+1);
      break;
    case DTAG_VEC:
      Printf("%sDTAG_VEC 0x%08lx\n",Indent(indent),tag->ti_Data);
      PrintRawVecInfo((struct RawVecInfo *)tag,indent+1);
      break;
    default:
      Printf("%sTag 0x%08lx Value 0x%08lx\n",Indent(indent),
	     tag->ti_Tag,tag->ti_Data);
      break;
    }
    tag++;
  }
}

void PrintDisplayInfoRecord(struct DisplayInfoRecord *record,LONG indent)
{
  if (record == NULL) {
    Printf("%s(None)\n",Indent(indent));
  }
  
  while (record) {
    Printf("%sDisplayInfoRecord at 0x%08lx\n",Indent(indent),record);
    Printf("%sMajor Key: 0x%04lx\n",Indent(indent),record->rec_MajorKey);
    Printf("%sMinor Key: 0x%04lx\n",Indent(indent),record->rec_MinorKey);
    Printf("%sControl  : 0x%08lx\n",Indent(indent),record->rec_Control);
    Printf("%sRecGet   : 0x%08lx\n",Indent(indent),record->rec_get_data);
    Printf("%sRecSet   : 0x%08lx\n",Indent(indent),record->rec_set_data);
    Printf("%sMinX     : %ld\n",Indent(indent),record->rec_ClipOScan.MinX);
    Printf("%sMinY     : %ld\n",Indent(indent),record->rec_ClipOScan.MinY);
    Printf("%sMaxX     : %ld\n",Indent(indent),record->rec_ClipOScan.MaxX);
    Printf("%sMaxY     : %ld\n",Indent(indent),record->rec_ClipOScan.MaxX);
    Printf("%sTagList  :\n",Indent(indent));
    PrintDisplayInfoTags(&(record->rec_Tag),indent+1);
    Printf("%sChildren :\n",Indent(indent));
    PrintDisplayInfoRecord((struct DisplayInfoRecord *)(record->rec_Node.rcn_Child),indent+1);
    record = (struct DisplayInfoRecord *)(record->rec_Node.rcn_Succ);
  }
}

void PrintDisplayInfo(void)
{
  struct DisplayInfoRecord *record =  (struct DisplayInfoRecord *)GfxBase->DisplayInfoDataBase;

  PrintDisplayInfoRecord(record,0);
}
