/*
** Simple demo of MMU PhyiscalLocation/LogicalLocation functions
** © 2021 Thomas Richter, THOR Software
** Compile without startup-code, runnable from Shell only.
**
*/
#include <dos/stdio.h>
#include <mmu/context.h>
#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#include <clib/mmu_protos.h>
#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <pragmas/mmu_pragmas.h>

LONG __asm __saveds main(void)
{
struct ExecBase *SysBase = *((struct ExecBase **)(4L));
struct DosLibrary *DOSBase;
struct Library *MMUBase;
LONG rc = 20;

        if (DOSBase = (struct DosLibrary *)OpenLibrary("dos.library",37L)) {
                if (MMUBase = OpenLibrary("mmu.library",47L)) {
                        struct MMUContext *ctxt = DefaultContext();
                        if (ctxt) {
                                void *logical = (void *)4;
                                ULONG size    = 8000;
                                ULONG props;

                                Printf("Physical location of 0x%08lx size %ld ",logical,size);
                                props = PhysicalLocation(ctxt,&logical,&size);
                                Printf("0x%08lx size %ld, properties: 0x%08lx\n",logical,size,props);

                                Printf("Logical location of 0x%08lx size %ld ",logical,size);
                                props = LogicalLocation(ctxt,&logical,&size);
                                Printf("0x%08lx size %ld, properties: 0x%08lx\n",logical,size,props);

                                logical = (void *)(0x00f80000);
                                size    = 32000;

                                Printf("Physical location of 0x%08lx size %ld ",logical,size);
                                props = PhysicalLocation(ctxt,&logical,&size);
                                Printf("0x%08lx size %ld, properties: 0x%08lx\n",logical,size,props);

                                Printf("Logical location of 0x%08lx size %ld ",logical,size);
                                props = LogicalLocation(ctxt,&logical,&size);
                                Printf("0x%08lx size %ld, properties: 0x%08lx\n",logical,size,props);

                                logical = (void *)(0x10000);
                                size    = 0xff000000;

                                Printf("Physical location of 0x%08lx size %ld ",logical,size);
                                props = PhysicalLocation(ctxt,&logical,&size);
                                Printf("0x%08lx size %ld, properties: 0x%08lx\n",logical,size,props);

                                Printf("Logical location of 0x%08lx size %ld ",logical,size);
                                props = LogicalLocation(ctxt,&logical,&size);
                                Printf("0x%08lx size %ld, properties: 0x%08lx\n",logical,size,props);

                                rc = 0;
                        }
                        CloseLibrary(MMUBase);
                } else Printf("This program requires the mmu.library v47 or better.\n");
                CloseLibrary((struct Library *)DOSBase);
        }

        return rc;
}

