/*****************************************************************
 ** The memory.library                                          **
 **                                                             **
 ** A mmu lib based virtual memory application                  **
 **                                                             **
 ** © 2002 THOR-Software                                        **
 **                                                             **
 **-------------------------------------------------------------**
 ** Module: error code definitions for the memory.library       **
 **             these can be received by IoErr                  **
 ** Release 40.1        29.01.2002                              **
 *****************************************************************/

#ifndef MEMORY_MEMERRORS_H
#define MEMORY_MEMERRORS_H

/*
 * The following error codes can be received by dos.library/IoErr()
 * additionally to the standard result codes of dos/dos.h
 * in case a memory.library function fails.
 */

/* specified context has an address space already */

#define MEMERROR_DOUBLESPACE            0x400

/* the library found no/not enough virtual memory address space to put the
   adress space into */

#define MEMERROR_NO_FREE_SPACE          0x401


/* no device/hook for swapping was specified */

#define MEMERROR_NO_SWAP_HOOK           0x402


/* virtual memory pool puddle size out of range */

#define MEMERROR_INVALID_PUDDLESIZE     0x403


/* swap hook is in defective state */

#define MEMERROR_SWAPHOOK_BROKEN        0x404


/* swap device run out of data */

#define MEMERROR_SWAPHOOK_EOF           0x405

/* device size is invalid */

#define MEMERROR_INVALID_DEVICESIZE     0x406

/* private swap hook w/o FIXEDSIZE */

#define MEMERROR_FLOATING_SIZE          0x407

/* tried to attach an address space to the public
 * context. This does not work.
 */
#define MEMERROR_PUBLIC_SPACE           0x408

/* tried to attach an address space to a
 * supervisor context.
 */
#define MEMERROR_SUPERVISOR_CTX         0x409

#endif

