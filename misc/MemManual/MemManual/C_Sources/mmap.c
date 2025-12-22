/*************************************************
 ** mmap                                        **
 **                                             **
 ** sample file-memory mapping using the        **
 ** memory.library                              **
 ** © 2001 THOR Software, Thomas Richter        **
 *************************************************/

/// Includes
#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <utility/tagitem.h>
#include <mmu/mmutags.h>
#include <memory/memory.h>
#include <memory/memtags.h>
#include <dos/dos.h>
#include <dos/rdargs.h>
#include <string.h>

#include <proto/memory.h>
#include <proto/exec.h>
#include <proto/mmu.h>
#include <proto/dos.h>
///
/// Defines
#define TEMPLATE "INPUTFILE/A"

#define ARG_FILE        0L
#define ARG_NUM         1L
///
/// Statics
char version[]="$VER: mmap 40.1 (9.2.2002) © THOR";
struct ExecBase *SysBase;
struct MemoryLibrary *MemoryBase;
struct MMUBase *MMUBase;
struct DosLibrary *DOSBase;
///
/// Protos
int __asm __saveds main(void);
int MMapTest(char *name);
struct MMap *MapFile(char *filename,BOOL readonly);
void UnmapFile(struct MMap *);
///
/// Structures
/*
 * Use this structure to identify an mmap'd memory area
 * Note that this example is only capable to mmap one file into memory,
 * more sophisticated programs will be able to do more.
 */
struct MMap {
        struct AdrSpace         *adr;           /* address space defining the remapping */
        struct MMUContext       *ctx;           /* underlying MMU context */
        struct VMPool           *pool;          /* pool within the address space holding the file */
        APTR                     lower;         /* logical base address of the file */
        ULONG                    size;          /* size of the file in bytes */
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
                                        rc = MMapTest((char *)args[ARG_FILE]);
                                        FreeArgs(rd);
                                } else {
                                        PrintFault(IoErr(),"mmap failed");
                                }
                                CloseLibrary((struct Library *)MemoryBase);
                        } else {
                                Printf("mmap failed: Failed to open the memory.library.\n");
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
/// MapFile
struct MMap *MapFile(char *file,BOOL readonly)
{
struct MMap *map;

/* we first build a new map structure, then fill it out */

        map = AllocVec(sizeof(struct MMap),MEMF_PUBLIC|MEMF_CLEAR);
        if (map) {
                BPTR lock;
                struct FileInfoBlock *fib;
                /*
                 * get now the size of the file
                 * we need the file size. The memory.library cannot provide it
                 * since it has to round to entire page sizes by
                 * construction.
                 */

                lock = Lock(file,SHARED_LOCK);
                if (lock) {
                        fib = AllocDosObject(DOS_FIB,TAG_DONE);

                        if (fib) {
                                if (Examine(lock,fib)) {
                                        map->size = fib->fib_Size;
                                }
                                FreeDosObject(DOS_FIB,fib);
                        }
                        UnLock(lock);
                }

                if (map->size) {
                        /* Build a new MMU context that is shared from the current
                         * context.
                         */
                        map->ctx = CreateMMUContext(MCXTAG_SHARE,DefaultContext(),
                                                    TAG_DONE);

                        if (map->ctx) {
                                /* Build a new address space on top of the context
                                 */
                                map->adr = NewAdrSpace(
                                                /* MEMTAG_VMSWAPTYPE,MEMFLAG_SWAPPART,
                                                 * MEMTAG_SWAPPARTNAME,"ZIP:",
                                                 */
                                                MEMTAG_CONTEXT,map->ctx,
                                                MEMTAG_VMSWAPTYPE,MEMFLAG_SWAPFILE,
                                                MEMTAG_SWAPFILENAME,file,
                                                MEMTAG_KEEPFILE,TRUE,
                                                MEMTAG_FIXEDSIZE,TRUE,
                                                MEMTAG_READONLY,readonly,
                                                MEMTAG_PREDEFINED,TRUE,
                                                TAG_DONE);

                                if (map->adr) {
                                        /*
                                         * now enter the addres space
                                         */
                                        if (EnterAddressSpace(map->adr,NULL)) {

                                                /*
                                                 * build a memory pool within the address space
                                                 */

                                                map->pool = NewVMPool(
                                                        MEMTAG_FIXEDSIZE,TRUE,
                                                        MEMTAG_PREDEFINED,TRUE,
                                                        MEMTAG_READONLY,readonly,
                                                        MEMTAG_PREALLOC,TRUE,
                                                        MEMTAG_PROVIDESMEM,FALSE,
                                                        TAG_DONE);


                                                if (map->pool) {
                                                        /*
                                                         * compute the lower edge of the
                                                         * memory pool
                                                         */
                                                        map->lower = PoolVBase(map->pool);

                                                        return map;
                                                }

                                                LeaveAddressSpace(NULL);
                                        }
                                        DeleteAdrSpace(map->adr);
                                }

                                DeleteMMUContext(map->ctx);
                        }
                }
                FreeVec(map);
        }

        return NULL;
}
///
/// UnmapFile
void UnmapFile(struct MMap *map)
{

        if (map) {
                if (map->pool)  DeleteVMPool(map->pool);
                if (map->adr) {
                        LeaveAddressSpace(NULL);
                        DeleteAdrSpace(map->adr);
                }
                if (map->ctx)   DeleteMMUContext(map->ctx);

                FreeVec(map);
        }
}
///
/// MMapTest
int MMapTest(char *name)
{
int rc = 10;
struct MMap *map;


        if (map = MapFile(name,TRUE)) {
                ULONG len;
                UBYTE *p;

                Printf("MMap base address is: 0x%08lx\n",map->lower);

                p = map->lower;
                len = map->size;

                {
                        UBYTE c = *p;

                        Printf("First character is %lc\n",c);

                        HoldMemory(map->adr,p,2<<12);
                        UnholdMemory(map->adr,p,2<<12,FALSE);
                }

                do {
                        UBYTE buf[256+2];
                        UBYTE *q = buf;
                        ULONG sz = 0L;

                        /* advance the pointer to the next LF
                         * Note that we *MUST* copy the data over
                         * before we pass it out to the Os. Delivering
                         * virtual memory to *ANY* Os function is
                         * illegal.
                         */

                        while(len && sz<256) {
                                UBYTE c;
                                c    = *p++;
                                *q++ = c;
                                len--;
                                sz++;

                                if (c == '\n' || c == '\0')
                                        break;
                        }
                        *q = 0;
                        Printf("%s",buf);
                } while(len);

                rc = 0;

                UnmapFile(map);
        } else Printf("mmap failed: Could not mmap file.\n");

        return rc;
}
///

