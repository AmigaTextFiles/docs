#ifndef PRAGMAS_NIPC_LIB_H
#define PRAGMAS_NIPC_LIB_H

#ifndef CLIB_NIPC_PROTOS_H
#include <clib/nipc_protos.h>
#endif

#pragma amicall(NIPCBase,0x72,AllocTransactionA(a0))
#pragma amicall(NIPCBase,0x78,FreeTransaction(a1))
#pragma amicall(NIPCBase,0x7e,CreateEntityA(a0))
#pragma amicall(NIPCBase,0x84,DeleteEntity(a0))
#pragma amicall(NIPCBase,0x8a,FindEntity(a0,a1,a2,a3))
#pragma amicall(NIPCBase,0x90,LoseEntity(a0))
#pragma amicall(NIPCBase,0x96,DoTransaction(a0,a1,a2))
#pragma amicall(NIPCBase,0x9c,BeginTransaction(a0,a1,a2))
#pragma amicall(NIPCBase,0xa2,GetTransaction(a0))
#pragma amicall(NIPCBase,0xa8,ReplyTransaction(a1))
#pragma amicall(NIPCBase,0xae,CheckTransaction(a1))
#pragma amicall(NIPCBase,0xb4,AbortTransaction(a1))
#pragma amicall(NIPCBase,0xba,WaitTransaction(a1))
#pragma amicall(NIPCBase,0xc0,WaitEntity(a0))
#pragma amicall(NIPCBase,0xc6,GetEntityName(a0,a1,d0))
#pragma amicall(NIPCBase,0xcc,GetHostName(a0,a1,d0))
#pragma amicall(NIPCBase,0xd2,NIPCInquiryA(a0,d0,d1,a1))
#pragma amicall(NIPCBase,0xd8,PingEntity(a0,d0))
#pragma amicall(NIPCBase,0xde,GetEntityAttrsA(a0,a1))
#pragma amicall(NIPCBase,0xe4,SetEntityAttrsA(a0,a1))
#pragma amicall(NIPCBase,0xea,AllocNIPCBuff(d0))
#pragma amicall(NIPCBase,0xf0,AllocNIPCBuffEntry())
#pragma amicall(NIPCBase,0xf6,CopyNIPCBuff(a0,a1,d0,d1))
#pragma amicall(NIPCBase,0xfc,CopyToNIPCBuff(a0,a1,d0))
#pragma amicall(NIPCBase,0x102,CopyFromNIPCBuffer(a0,a1,d0))
#pragma amicall(NIPCBase,0x108,FreeNIPCBuff(a0))
#pragma amicall(NIPCBase,0x10e,FreeNIPCBuffEntry(a0))
#pragma amicall(NIPCBase,0x114,NIPCBuffLength(a0))
#pragma amicall(NIPCBase,0x11a,AppendNIPCBuff(a0,a1))
#pragma amicall(NIPCBase,0x120,NIPCBuffPointer(a0,a1,d0))

#endif  /*  PRAGMAS_NIPC_LIB_H  */
