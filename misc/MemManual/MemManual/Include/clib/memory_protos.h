#ifndef CLIB_MEMORY_PROTOS_H
#define CLIB_MEMORY_PROTOS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

struct AdrSpace *NewAdrSpaceA(struct TagItem *tags);
struct AdrSpace *NewAdrSpace(Tag tag,...);
void DeleteAdrSpace(struct AdrSpace *adr);
struct VMPool *NewVMPoolA(struct TagItem *tags);
struct VMPool *NewVMPool(Tag tag,...);
void DeleteVMPool(struct VMPool *vmp);
struct MMUContext *MMUContextOf(struct AdrSpace *adr);

BOOL LockMemory(struct AdrSpace *adr,APTR mem,ULONG size);
void UnlockMemory(struct AdrSpace *adr,APTR mem,ULONG size,BOOL force);
APTR HoldMemory(struct AdrSpace *adr,APTR mem,ULONG size);
void UnholdMemory(struct AdrSpace *adr,APTR mem,ULONG size,BOOL force);
BOOL SwapMemoryOut(struct AdrSpace *adr,APTR mem,ULONG size);

APTR AllocVMemory(struct VMPool *vmp,ULONG size);
void FreeVMemory(struct VMPool *vmp,APTR adr, ULONG size);
APTR PoolVBase(struct VMPool *vmp);
ULONG PoolVSize(struct VMPool *vmp);

BOOL EnterAddressSpace(struct AdrSpace *adr,struct Task *task);
BOOL LeaveAddressSpace(struct Task *task);
struct AdrSpace *CurrentAddressSpace(struct Task *task);
struct AdrSpace *AdrSpaceOfCtx(struct MMUContext *ctx);

#endif
