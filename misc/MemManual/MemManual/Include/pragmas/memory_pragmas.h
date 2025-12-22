#ifndef PRAGMAS_MEMORY_PRAGMAS_H
#define PRAGMAS_MEMORY_PRAGMAS_H

#ifndef CLIB_MEMORY_PROTOS_H
#include <clib/memory_protos.h>
#endif

/*-----------------------------------------------------------------
*-- memory.library                                               --
*-- © 1998-2002 the mmu.library development group, THOR-Software --
*--                                                              --
*-- Library header file Version 40.1                             --
*--                                                              --
*-- created 07 Jul 1999 THOR,   Thomas Richter                   --
*-- release 29 Jan 2002 THOR,	Thomas Richter			 --
*----------------------------------------------------------------- */
#pragma  libcall MemoryBase NewAdrSpaceA         01e 801
#pragma  libcall MemoryBase DeleteAdrSpace       024 801
#pragma  libcall MemoryBase MMUContextOf         02a 801
#pragma  libcall MemoryBase AdrSpaceOfCtx        030 801
#pragma  libcall MemoryBase NewVMPoolA           036 801
#pragma  libcall MemoryBase DeleteVMPool         03c 801
#pragma  libcall MemoryBase LockMemory           042 09803
#pragma  libcall MemoryBase UnlockMemory         048 109804
#pragma  libcall MemoryBase HoldMemory           04e 09803
#pragma  libcall MemoryBase UnholdMemory         054 109804
#pragma  libcall MemoryBase SwapMemoryOut        05a 09803
#pragma  libcall MemoryBase AllocVMemory         060 0802
#pragma  libcall MemoryBase FreeVMemory          066 09803
#pragma  libcall MemoryBase PoolVBase            06c 801
#pragma  libcall MemoryBase PoolVSize            072 801
#pragma  libcall MemoryBase EnterAddressSpace    078 9802
#pragma  libcall MemoryBase LeaveAddressSpace    07e 901
#pragma  libcall MemoryBase CurrentAddressSpace  084 901
#ifdef __SASC_60
#pragma  tagcall MemoryBase NewAdrSpace          01e 801
#pragma  tagcall MemoryBase NewVMPool            036 801
#endif

#endif	/*  PRAGMAS_MEMORY_PRAGMA_H  */
