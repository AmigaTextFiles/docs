/*****************************************************************
 ** The memory.library                                          **
 **                                                             **
 ** A mmu lib based virtual memory application                  **
 **                                                             **
 ** © 2002 THOR-Software                                        **
 **                                                             **
 **-------------------------------------------------------------**
 ** Module: SwapFailHook                                        **
 **             Defines the hook interface in case swap-in      **
 **             failed.                                         **
 ** Release 40.1        29.01.2002                              **
 *****************************************************************/

#ifndef MEMORY_SWAPFAILHOOK_H
#define MEMORY_SWAPFAILHOOK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

struct SwapFailMsg {
        APTR            sfm_AddressSpace;       /* the address space that failed */
        APTR            sfm_Memory;             /* lower memory that failed */
        ULONG           sfm_Size;               /* size of the memory range that failed to swap in */
        LONG            sfm_Error;              /* type of error */
};

/*
 * Possible return values:
 */
#define SWFRET_RETRYSWAP  0     /* repaired the problem, possibly by releasing memory, retry the swap-in */
#define SWFRET_RETRYFAULT 1     /* repaired the problem on the MMU side, retry the exception, do not try to swap-in */
#define SWFRET_DEACTIVATE 2     /* deactivate the exception hook and go guru (default) */

#endif



