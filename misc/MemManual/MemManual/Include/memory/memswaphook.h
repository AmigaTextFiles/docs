/*****************************************************************
 ** The memory.library                                          **
 **                                                             **
 ** A mmu lib based virtual memory application                  **
 **                                                             **
 ** © 2002 THOR-Software                                        **
 **                                                             **
 **-------------------------------------------------------------**
 ** Module: Swap Hook related                                   **
 **             Defines interface functions for the swap-hook   **
 ** Release 40.1        29.01.2002                              **
 *****************************************************************/

#ifndef MEMORY_MEMSWAPHOOK_H
#define MEMORY_MEMSWAPHOOK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

/* the following packet is used for communication with the hook */
struct VMHookPacket     {
        ULONG   vhp_Type;       /* packet type                  */
        APTR    vhp_HookInfo;   /* user defined data            */
        APTR    vhp_Range;      /* physical address             */
        ULONG   vhp_Size;       /* address size                 */
        ULONG   vhp_Offset;     /* ID for swapping in/out       */
};

/* packet types */
#define VMPACK_INIT     'INIT'          /* initialize the hook, hook info */
#define VMPACK_SIZE     'SIZE'          /* get the available space on the device */
#define VMPACK_EXIT     'EXIT'          /* shut the hook down */
#define VMPACK_OPEN     'OPEN'          /* open the hook with given swap space */
#define VMPACK_CLOS     'CLOS'          /* close the hook swap space */
#define VMPACK_READ     'READ'          /* swap data in */
#define VMPACK_WRIT     'WRIT'          /* swap data out */
#define VMPACK_TICK     'TICK'          /* motor activity tick */
#define VMPACK_ALRT     'ALRT'          /* submit a user alert */

#endif

