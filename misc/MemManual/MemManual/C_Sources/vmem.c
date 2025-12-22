/*************************************************
 ** vmem                                        **
 **                                             **
 ** sample file-memory mapping using the        **
 ** memory.library                              **
 ** © 2001 THOR Software, Thomas Richter        **
 *************************************************/

/// Includes
#include <exec/types.h>
#include <exec/libraries.h>
#include <utility/tagitem.h>
#include <mmu/mmutags.h>
#include <memory/memory.h>
#include <memory/memtags.h>
#include <dos/rdargs.h>

#include <proto/exec.h>
#include <proto/mmu.h>
#include <proto/dos.h>
#include <proto/memory.h>

#include <strings.h>
#include <math.h>
///
/// Defines
#define TEMPLATE "SWAP/A"

#define ARG_SWAP        0L
#define ARG_NUM         1L
///
/// Statics
char version[]="$VER: vmem 40.1 (9.2.2002) © THOR";
struct ExecBase *SysBase;
struct MemoryLibrary *MemoryBase;
struct MMUBase *MMUBase;
struct DosLibrary *DOSBase;
///
/// Protos
int __asm __saveds main(void);
int PoolTest(struct VMPool *p);
long rangerand(long max);
struct Keeper **indextokp(struct Keeper **first,long index);
int VMemTest(char *name);
///
/// Structures
struct Keeper {
        struct Keeper   *next;
        ULONG            len;
};
///

/// main
int __asm __saveds main(void)
{
struct RDArgs *rd;
LONG args[ARG_NUM];
int rc = 25;

        SysBase = *((struct ExecBase **)(4L));

        memset(args,0,sizeof(args));

        if (DOSBase = (struct DosLibrary *)OpenLibrary("dos.library",37)) {
                if (MMUBase = (struct MMUBase *)OpenLibrary("mmu.library",43)) {
                        if (MemoryBase = (struct MemoryLibrary *)OpenLibrary("memory.library",0)) {
                                Printf("memory.library successfully openend.\n");
                                if (rd = ReadArgs(TEMPLATE,args,NULL)) {
                                        rc = VMemTest((char *)(args[ARG_SWAP]));
                                        FreeArgs(rd);
                                } else {
                                        PrintFault(IoErr(),"vmem failed");
                                }
                                CloseLibrary((struct Library *)MemoryBase);
                        } else {
                                Printf("vmem failed: Failed to open the memory.library.\n");
                        }
                        CloseLibrary((struct Library *)MMUBase);
                } else {
                        Printf("mmap failed: Failed to open the mmu.library V43.");
                }
                CloseLibrary((struct Library *)DOSBase);
        }

        return rc;
}
///
/// VMemTest
int VMemTest(char *name)
{
struct MMUContext *ctx;
struct AdrSpace *adr;
struct VMPool *vmpool;
int rc = 10;
int len;

        /*
         * create a new MMU Context to operate in
         */
        ctx = CreateMMUContext(MCXTAG_SHARE,CurrentContext(NULL),TAG_DONE);

        if (ctx == NULL)
                Printf("Failed to create a new MMU context.\n");

        /*
         * Check whether the user wants a swap file or a swap partition
         */
        len = strlen(name);
        if ((len > 0) && (name[len-1]==':')) {
                char in[256];

                Printf("You selected a swap partition for this test suite.\n"
                       "Remember that all data on partition %s will be erased.\n"
                       "Are you sure that you want to do this?\n"
                       "(yes/no):");
                Flush(Output());

                len = Read(Input(),in,255);
                if (len != 4 || (strcmp(in,"yes\n"))) {
                        Printf("***Aborted***\n");
                        return 5;
                }

                adr = NewAdrSpace(      MEMTAG_MAXSYSMEM,64<<12,
                                        MEMTAG_VMSWAPTYPE,MEMFLAG_SWAPPART,
                                        MEMTAG_SWAPPARTNAME,name,
                                        MEMTAG_VMMAXSIZE,64*1024*1024, // 64MB
                                        MEMTAG_PROVIDESMEM,TRUE,
                                        MEMTAG_CONTEXT,ctx,
                                        TAG_DONE);
        } else {
                adr = NewAdrSpace(      MEMTAG_MAXSYSMEM,25<<12,
                                        MEMTAG_VMSWAPTYPE,MEMFLAG_SWAPFILE,
                                        MEMTAG_SWAPFILENAME,name,
                                        MEMTAG_VMSIZE,64*1024*1024, // 64MB
                                        MEMTAG_PROVIDESMEM,TRUE,
                                        MEMTAG_CONTEXT,ctx,
                                        TAG_DONE);
        }

        if (adr) {
                Printf("Creating the new address space succeeded.\n"
                       "Address space is: %08lx\n",adr);

                if (EnterAddressSpace(adr,NULL)) {
                        Printf("Entered the address space successfully.\n");


                        vmpool = NewVMPool(     MEMTAG_ADRSPACE,adr,
                                                MEMTAG_PROVIDESMEM,TRUE,
                                                //MEMTAG_PUDDLESIZE,5<<12,
                                                //MEMTAG_MEMFLAGS,MEMF_CLEAR,
                                                TAG_DONE);

                        if (vmpool) {
                                Printf("Created the new pool succesfully.\n"
                                       "Pool is: %08lx\n",vmpool);


                                rc = PoolTest(vmpool);

                                DeleteVMPool(vmpool);
                        } else Printf("mmap failed: Could not create new pool.\n");

                        LeaveAddressSpace(NULL);
                } else Printf("mmap failed: Failed to enter the address space.\n");

                DeleteAdrSpace(adr);
        } else Printf("mmap failed: Could not create new address space.\n");

        DeleteMMUContext(ctx);

        return rc;
}
///
/// PoolTest
int PoolTest(struct VMPool *pool)
{
unsigned short seed[3];
long index=0,delta;
struct Keeper **kpp,*kp;
ULONG max;
ULONG total = 0;
ULONG mems = 0;
ULONG meter = 0;
struct Keeper *first[256];
UBYTE fidx = 0;
ULONG acnt = 0;
struct DateStamp orig,ds;

        memset(first,0,sizeof(first));
        DateStamp(&ds);
        /*
        seed[0]=ds.ds_Tick;
        seed[1]=ds.ds_Tick>>16;
        seed[2]=ds.ds_Minute;
        */
        seed[0]=1;
        seed[1]=1;
        seed[2]=2;
        seed48(seed);
        max = 64*1024*1024;

        Printf("Start messing the (virtual) memory....\n");
        DateStamp(&orig);

        do{

                if (((lrand48() & 0x3fff)>((meter>2500)?0x2400:0x1a00)) && (max>0)) {
                        delta=0;
                        switch(lrand48() & 0x7000){
                                case 0x1000:
                                case 0x2000:
                                case 0x3000:
                                        index=rangerand(0x100);
                                        break;
                                case 0x4000:
                                        index=rangerand(0x200);
                                        break;
                                case 0x5000:
                                        index=rangerand(0x800);
                                        delta=lrand48() & 0x03;
                                        break;
                                case 0x6000:
                                        index=rangerand(max);
                                        delta=lrand48() & 0x1f;
                                        break;
                                case 0x7000:
                                        index=rangerand(max);
                                        delta=lrand48() & 0x07;
                                        break;
                        }
                        if (delta)
                                index >>= delta;
                        index &= (~7);
                        if ((index>0) && (index<=max)) {
                                Printf("Allocating");
                                Flush(Output());
                                acnt++;
                                if (kp=AllocVMemory(pool,index)) {
                                        Printf(" %08lx bytes at %08lx.\n",index,kp);
                                        kp->next=first[fidx];
                                        kp->len=index;
                                        first[fidx]=kp;
                                        mems++;
                                        max-=index;
                                        total+=index;
                                        fidx++;
                                } else Printf(" %08lx bytes failed.\n",index);
                        }
                } else {
                        if (mems>0) {
                                index=rangerand(mems);
                                kpp=indextokp(first,index);
                                if (kpp) {
                                        ULONG len;
                                        kp=*kpp;
                                        *kpp=kp->next;
                                        max+=kp->len;
                                        total-=kp->len;
                                        Printf("Releasing ");
                                        len = kp->len;
                                        Flush(Output());
                                        acnt++;
                                        FreeVMemory(pool,kp,kp->len);
                                        Printf(" %08lx bytes at %08lx.\n",len,kp);
                                        mems--;
                                }
                        }
                }

                meter++;
                if (CheckSignal(SIGBREAKF_CTRL_D)) {
                        LONG ticks;

                        DateStamp(&ds);

                        ticks = ds.ds_Days - orig.ds_Days;
                        ticks = (ds.ds_Minute - orig.ds_Minute) + (ticks * 24 * 60);
                        ticks = (ds.ds_Tick - orig.ds_Tick) + (ticks * 60 * 50);
                        if (acnt)       ticks  = (ticks * 100) / acnt;
                        else            ticks  = 0;


                        Printf("Holding 0x%08lx bytes in %ld blocks. Time per allocation: %ld\n",total,mems,ticks);

                        DateStamp(&orig);
                        acnt = 0;
                }
                if (meter>5000)
                        meter=0;

        }while(!CheckSignal(SIGBREAKF_CTRL_C));

        Printf("*** Break\n");

        fidx = 0;
        do {
                while(first[fidx]) {
                        kp=first[fidx];
                        first[fidx]=kp->next;
                        FreeVMemory(pool,kp,kp->len);
                }
        } while(++fidx);

        Printf("Done.\n");

        return 0;
}
///
/// rangerand
long rangerand(long max)
{
        return (long)(((ULONG)(lrand48()))%((ULONG)(max)));
}
///
/// indextokp
struct Keeper **indextokp(struct Keeper **first,long index)
{
struct Keeper **kpp = first+(index & 0xff);

        index >>= 8;
        while(index>0){
                if (*kpp == NULL)
                        return NULL;

                kpp=&((*kpp)->next);
                index--;
        }

        if (*kpp == NULL)
                return NULL;

        return kpp;
}
///

