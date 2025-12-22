/*****************************************************************
 ** The memory.library                                          **
 **                                                             **
 ** A mmu lib based virtual memory application                  **
 **                                                             **
 ** © 2002 THOR-Software                                        **
 **                                                             **
 **-------------------------------------------------------------**
 ** Module: global memory definititions you need for the	**
 **		library operation				**
 ** Release 40.1        29.01.2002                              **
 *****************************************************************/

#ifndef MEMORY_MEMORY_H
#define MEMORY_MEMORY_H

#ifndef EXEC_NODES_H
#include <exec/nodes.h>
#endif

/*
 * "dummy" structures for objects you'd better not care about
 *
 * Note that the following are "in real" much larger than what you
 * see here.
 * Do not allocate yourself, do not touch.
 */

/*
 * The address space. This is an extension of the MMUContext of
 * the mmu.library. How this extension works is intentionally
 * undocumented.
 */

struct AdrSpace {
        struct MinNode          adr_Node;               /* for linkage  */
	/* more data beyond this point */
};

/*
 * The VMPool administrates a memory pool within an address space
 * using a common caching and memory mode.
 */
struct VMPool {
        struct Node             vmp_Node;               /* links all pools of an AdrSpace */
	/* more data beyond this point */
};

#endif
