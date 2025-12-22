/*****************************************************************
 ** The memory.library                                          **
 **                                                             **
 ** A mmu lib based virtual memory application                  **
 **                                                             **
 ** © 2002 THOR-Software                                        **
 **                                                             **
 **-------------------------------------------------------------**
 ** Module: alert code definitions for the memory.library       **
 ** Release 40.1        29.01.2002                              **
 *****************************************************************/

#ifndef MEMORY_MEMALERTS_H
#define MEMORY_MEMALERTS_H

#define AN_MEMLib       0x3d000000

#define AN_MEMPageSetup 0xbd000001      /* unexpected error on low-level page modification */

#define AN_MEMQpkt      0xbd000002      /* swap daemon command queue-packet failure */

#define AN_MEMCtxtInv   0xbd000003      /* found an invalid/unhandled context */

#define AN_MEMCmdInv    0xbd000004      /* invalid command to swap daemon */

#define AN_MEMInvFree   0xbd000005      /* invalid freemem */

#define AN_MEMFreeFail  0x3d000006      /* releasing a memory pool failed */

#define AN_MEMDupKey    0xbd000007      /* found duplicate key */

#endif
