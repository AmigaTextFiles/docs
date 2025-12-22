/*************************************************
 ** 68040/68060 Swap test                       **
 ** © 2001 THOR-Software                        **
 ** 17.11.2001 by Thomas Richter                **
 *************************************************/

/// Includes
#include <exec/types.h>
#include <exec/nodes.h>
#include <exec/lists.h>
#include <exec/ports.h>
#include <exec/memory.h>
#include <exec/execbase.h>

#include <dos/dos.h>

#include <mmu/mmutags.h>
#include <mmu/context.h>
#include <mmu/exceptions.h>

#include <proto/exec.h>
#include <proto/mmu.h>
#include <proto/dos.h>

#include <m68881.h>
///
/// Defines
///
/// Statics
char version[]="$VER: SwapTest 1.00 (17.11.2001) © THOR";

struct ExecBase *SysBase;
struct DosLibrary *DOSBase;
struct MMUBase *MMUBase;

ULONG props1,props2;
UBYTE *spare;
UBYTE *phys1,*phys2;

ULONG pagesize;

BOOL segfault;
///
/// Protos
long __saveds main(void);
long RunSwapTest(void);
int __asm __saveds __interrupt SwapFunction(register __a0 struct ExceptionData *exd);
int __asm __saveds __interrupt ExceptFunction(register __a0 struct ExceptionData *exd);
double CalcSin(double *x);
void End(void);
BOOL SwapIn(struct MMUContext *ctx,APTR fault);
///

/// main
long __saveds main(void)
{
long rc = 25;

        SysBase = *(struct ExecBase **)(4L);

        if (DOSBase = (struct DosLibrary *)OpenLibrary("dos.library",37)) {
                if (MMUBase = (struct MMUBase *)OpenLibrary("mmu.library",43)) {

                        /*
                        if (SysBase->AttnFlags & (AFF_68040|AFF_68040)) {
                                rc = RunSwapTest();
                        } else {
                                Printf("This program requires an 68040 or 68060\n"
                                       "or, at least, makes little sense for any\n"
                                       "other processor of the MC68K series.\n");
                                rc = 5;
                        }       
                        */

                        rc = RunSwapTest();

                        if (rc > 64) {
                                PrintFault(rc,"SwapTest failed");
                                rc = 10;
                        }
                        CloseLibrary((struct Library *)MMUBase);
                } else {
                        Printf("SwapTest requires V43 of the mmu.library.\n");
                }
                CloseLibrary((struct Library *)DOSBase);
        }

        return rc;
}
///
/// RunSwapTest
long RunSwapTest(void)
{
long rc = ERROR_NO_FREE_STORE;
struct MMUContext *ctx;
struct ExceptionHook *swaphook,*excepthook;
ULONG size;

        ctx = CurrentContext(NULL);
        pagesize = GetPageSize(ctx);
        spare = AllocAligned(pagesize<<1,MEMF_PUBLIC|MEMF_CLEAR,pagesize);
        if (spare == NULL)
                return ERROR_NO_FREE_STORE;

        phys1   = spare;
        size    = pagesize;
        props1  = PhysicalLocation(ctx,(void **)&phys1,&size);
        if (size != pagesize) {
                Printf("Unsupported system memory mapping.\n");
                FreeMem(spare,pagesize<<1);
                return 10;
        }

        phys2   = spare + pagesize;
        size    = pagesize;
        props2  = PhysicalLocation(ctx,(void **)&phys2,&size);
        if (size != pagesize) {
                Printf("Unsupported system memory mapping.\n");
                FreeMem(spare,pagesize<<1);
                return 10;
        }

        segfault = 2;

        if (EnterMMUContext(ctx,FindTask(NULL))) {
                swaphook = AddContextHook(MADTAG_CONTEXT,ctx,
                                          MADTAG_TASK,FindTask(NULL),
                                          MADTAG_TYPE,MMUEH_SWAPPED,
                                          MADTAG_CODE,&SwapFunction,
                                          MADTAG_PRI,100,
                                          TAG_DONE);
                if (swaphook) {
                        excepthook = AddContextHook(MADTAG_CONTEXT,NULL,
                                                    MADTAG_TASK,FindTask(NULL),
                                                    MADTAG_TYPE,MMUEH_SEGFAULT,
                                                    MADTAG_CODE,&ExceptFunction,
                                                    MADTAG_PRI,100,
                                                    TAG_DONE);
                        if (excepthook) {
                                struct MinList *proplist;
                                LockMMUContext(ctx);

                                proplist = GetMapping(ctx);
                                if (proplist) {
                                        if (SetProperties(ctx,MAPP_SWAPPED|MAPP_SINGLEPAGE,~0,(ULONG)spare,pagesize<<1,MAPTAG_BLOCKID,0,TAG_DONE)) {
                                                if (RebuildTree(ctx)) {
                                                                ActivateException(swaphook);
                                                                ActivateException(excepthook);

                                                                /*
                                                                 * trigger the exception!
                                                                 */
                                                                CalcSin((double *)spare);

                                                                if (segfault) {
                                                                        Printf("Your 68040 or 68060.library does not support virtual memory correctly.\n");
                                                                } else {
                                                                        double tmp = 0.0;
                                                                        UBYTE *start,*end;
                                                                        UBYTE *func;

                                                                        Printf("Your 68040 or 68060.library handles virtual memory correctly on data swaps.\n");

                                                                        start = (UBYTE *)(&CalcSin);
                                                                        end   = (UBYTE *)(&End);

                                                                        func = spare + pagesize-4;
                                                                        CopyMem(start,func,end-start);
                                                                        CacheClearU();

                                                                        SetPageProperties(ctx,MAPP_SWAPPED|MAPP_SINGLEPAGE,~0,(ULONG)spare,MAPTAG_BLOCKID,0,TAG_DONE);
                                                                        SetPageProperties(ctx,MAPP_SWAPPED|MAPP_SINGLEPAGE,~0,((ULONG)spare) + pagesize,MAPTAG_BLOCKID,0,TAG_DONE);

                                                                        segfault = 2;

                                                                        (*(double (*)(double *))func)(&tmp);

                                                                        if (segfault) {
                                                                                Printf("Your 68040 or 68060.library does not support virtual memory correctly.\n");
                                                                        } else {
                                                                                Printf("Your 68040 or 68060.library handles virtual memory correctly on instruction swaps.\n");
                                                                        }
                                                                }

                                                                DeactivateException(excepthook);
                                                                DeactivateException(swaphook);

                                                                rc = 0;

                                                }
                                                SetPropertiesMapping(ctx,proplist,(ULONG)spare,pagesize<<1,~0);
                                                RebuildTree(ctx);
                                        }
                                        ReleaseMapping(ctx,proplist);
                                }

                                UnlockMMUContext(ctx);
                                RemContextHook(excepthook);
                        }
                        RemContextHook(swaphook);
                }


                LeaveMMUContext(FindTask(NULL));
        }
        FreeMem(spare,pagesize<<1);

        return rc;
}
///
/// SwapIn
BOOL SwapIn(struct MMUContext *ctx,APTR fault)
{
UBYTE *base;

        base = (UBYTE *)((ULONG)(fault) & (ULONG)(-(LONG)pagesize));
        if (base == spare) {
                return SetPageProperties(ctx,props1,~0,(ULONG)base,MAPTAG_DESTINATION,phys1,TAG_DONE);
        } else if (base == spare + pagesize) {
                return SetPageProperties(ctx,props2,~0,(ULONG)base,MAPTAG_DESTINATION,phys2,TAG_DONE);
        }
        return FALSE;
}
///
/// SwapFunction
int __asm __saveds __interrupt SwapFunction(register __a0 struct ExceptionData *exd)
{
        if (SwapIn(exd->exd_Context,exd->exd_FaultAddress) | SwapIn(exd->exd_Context,exd->exd_NextFaultAddress)) {
                segfault = FALSE;
                return 0;
        }
        return 1;
}
///
/// ExceptFunction
int __asm __saveds __interrupt ExceptFunction(register __a0 struct ExceptionData *exd)
{
        if (SwapIn(exd->exd_Context,exd->exd_FaultAddress) | SwapIn(exd->exd_Context,exd->exd_NextFaultAddress)) {
                segfault = FALSE;
                return 0;
        }
        return 1;
}
///
/// CalcSin
double CalcSin(double *x)
{
        return sin(x[1]);
}
///
/// end marker
void End(void)
{
}
///


