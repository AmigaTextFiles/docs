#include "exec/types.h"
#include "exec/execbase.h"
#include "libraries/romboot_base.h"
#include "libraries/expansionbase.h"
#include "libraries/filehandler.h"

#define DE_MAXTRANSFER     13
#define DE_MASK            14
#define DE_BOOTPRI         15
#define DE_DOSTYPE         16

/*#define DEBUG  /**/
/*#define AUTOBOOT /**/

struct DeviceNode *MakeDosNode(ULONG *);
void   Enqueue(struct List *, struct Node *);

extern struct ExpansionBase *ExpansionBase;
extern struct ExecBase *SysBase;
extern char *myName;

struct CurrentBinding md_CBind;
struct BootNode md_BootNode;
char dosName[] = "SFS";
ULONG ParmPkt[30];
char temp[80];

ULONG
config()
   {
#ifdef AUTOBOOT
   struct DeviceNode *md_DevNode, *MakeDosNode();
   int rc;
#endif

   ParmPkt[0] = (ULONG)"SFS";
   ParmPkt[1] = (ULONG)"ahd.device";
   ParmPkt[2] = 1;
   ParmPkt[3] = 0;

   ParmPkt[4 + DE_TABLESIZE] = DE_DOSTYPE;
   ParmPkt[4 + DE_SIZEBLOCK] = 512 >> 2;
   ParmPkt[4 + DE_SECORG] = 0;
   ParmPkt[4 + DE_NUMHEADS] = 4;
   ParmPkt[4 + DE_SECSPERBLK] = 1;
   ParmPkt[4 + DE_BLKSPERTRACK] = 17;
   ParmPkt[4 + DE_RESERVEDBLKS] = 2;
   ParmPkt[4 + DE_PREFAC] = 0;
   ParmPkt[4 + DE_INTERLEAVE] = 0;
   ParmPkt[4 + DE_LOWCYL] = 2;
   ParmPkt[4 + DE_UPPERCYL] = 40;
   ParmPkt[4 + DE_NUMBUFFERS] = 5;
   ParmPkt[4 + DE_MEMBUFTYPE] = 1;
   ParmPkt[4 + DE_MAXTRANSFER] = 65536;
   ParmPkt[4 + DE_MASK] = 0xfffffe;
   ParmPkt[4 + DE_BOOTPRI] = 0;
   ParmPkt[4 + DE_DOSTYPE] = 0x444f5300;

#ifdef DEBUG
   cputstr("Open ExpansionBase: ");
#endif
   ExpansionBase =
      (struct ExpansionBase *)OpenLibrary("expansion.library",0);
#ifdef DEBUG
   cputstr((ExpansionBase) ? "succeeded" : "failed");
   cputstr("\r\n");
#endif
   if(!ExpansionBase)
      return(-1);

   SumLibrary(SysBase);

#ifdef DEBUG
   sprintf(temp, "ChkSum = %x\n\r", SysBase->ChkSum);
   cputstr(temp);
#endif

#ifdef AUTOBOOT
   cputstr("MakeDosNode: ");
   md_DevNode = MakeDosNode(ParmPkt);
   cputstr((md_DevNode) ? "succeeded" : "failed");
   cputstr("\r\n");

   cputstr("AddDosNode: ");
   rc = AddDosNode(0, 0, md_DevNode);
   cputstr((rc) ? "succeeded" : "failed");
   cputstr("\r\n");

   cputstr("Initializing BootNode\n\r");
   md_BootNode.bn_DeviceNode = (CPTR)md_DevNode;
   md_BootNode.bn_Flags = 0;
   md_BootNode.bn_Node.ln_Pri = 0;
   md_BootNode.bn_Node.ln_Type = NT_BOOTNODE;
   md_BootNode.bn_Node.ln_Name = md_CBind.cb_ConfigDev;
   cputstr("Done\n\r");

   Enqueue(&(ExpansionBase->MountList), &md_BootNode);
#endif

   CloseLibrary(ExpansionBase);
#ifdef DEBUG
   cputstr("Exited Config\n\r");
#endif
   return(0);
   }

