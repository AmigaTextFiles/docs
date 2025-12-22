#ifndef PRAGMAS_NIPC_PRAGMAS_H
#define PRAGMAS_NIPC_PRAGMAS_H

#ifndef CLIB_NIPC_PROTOS_H
#include <clib/nipc_protos.h>
#endif

extern struct Library *NIPCBase;

#pragma libcall NIPCBase AllocTransactionA 72 801
#pragma libcall NIPCBase FreeTransaction 78 901
#pragma libcall NIPCBase CreateEntityA 7e 801
#pragma libcall NIPCBase DeleteEntity 84 801
#pragma libcall NIPCBase FindEntity 8a BA9804
#pragma libcall NIPCBase LoseEntity 90 801
#pragma libcall NIPCBase DoTransaction 96 A9803
#pragma libcall NIPCBase BeginTransaction 9c A9803
#pragma libcall NIPCBase GetTransaction a2 801
#pragma libcall NIPCBase ReplyTransaction a8 901
#pragma libcall NIPCBase CheckTransaction ae 901
#pragma libcall NIPCBase AbortTransaction b4 901
#pragma libcall NIPCBase WaitTransaction ba 901
#pragma libcall NIPCBase WaitEntity c0 801
#pragma libcall NIPCBase GetEntityName c6 09803
#pragma libcall NIPCBase GetHostName cc 09803
#pragma libcall NIPCBase NIPCInquiryA d2 910804
#pragma libcall NIPCBase PingEntity d8 0802
#pragma libcall NIPCBase GetEntityAttrsA de 9802
#pragma libcall NIPCBase SetEntityAttrsA e4 9802
#pragma libcall NIPCBase AllocNIPCBuff ea 001
#pragma libcall NIPCBase AllocNIPCBuffEntry f0 00
#pragma libcall NIPCBase CopyNIPCBuff f6 109804
#pragma libcall NIPCBase CopyToNIPCBuff fc 09803
#pragma libcall NIPCBase CopyFromNIPCBuffer 102 09803
#pragma libcall NIPCBase FreeNIPCBuff 108 801
#pragma libcall NIPCBase FreeNIPCBuffEntry 10e 801
#pragma libcall NIPCBase NIPCBuffLength 114 801
#pragma libcall NIPCBase AppendNIPCBuff 11a 9802
#pragma libcall NIPCBase NIPCBuffPointer 120 09803

#endif  /*  PRAGMAS_NIPC_PRAGMAS_H  */
