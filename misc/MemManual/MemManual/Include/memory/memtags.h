/*****************************************************************
 ** The memory.library                                          **
 **                                                             **
 ** A mmu lib based virtual memory application                  **
 **                                                             **
 ** © 2002 THOR-Software                                        **
 **                                                             **
 **-------------------------------------------------------------**
 ** Module: tag definitions for the memory.library              **
 ** Release 40.1        29.01.2002                              **
 *****************************************************************/

#ifndef MEMORY_MEMTAGS_H
#define MEMORY_MEMTAGS_H

#ifndef UTILITY_TAGITEM_H
#include <utility/tagitem.h>
#endif

#define MEMTAG_DUMMY            ( TAG_USER + 0x03e10000 )

/* Tags for creating new address spaces */

/* target context to link the address space to */
#define MEMTAG_CONTEXT          ( MEMTAG_DUMMY + 0x01 )

/* target task for this address space */
#define MEMTAG_TASK             ( MEMTAG_DUMMY + 0x02 )

/* call thru this hook in case swapping in failed. */
#define MEMTAG_SWAPFAILHOOK     ( MEMTAG_DUMMY + 0x03 )

/* size of the virtual memory maintained by this address space */
#define MEMTAG_VMSIZE           ( MEMTAG_DUMMY + 0x10 )

/* maximum amount of system memory an address space may allocate
 */
#define MEMTAG_MAXSYSMEM        ( MEMTAG_DUMMY + 0x11 )

/* maximal size the virtual memory pool may have
 * default is no limit.
 */
#define MEMTAG_VMMAXSIZE        ( MEMTAG_DUMMY + 0x12 )


/*
 * size of the write cache in bytes. Default is sixteen pages.
 */
#define MEMTAG_CACHESIZE        ( MEMTAG_DUMMY + 0x13 )

/* a pointer to a window pointer that defines where possible
 * error requesters will appear. If this points (!) to a -1,
 * no requesters will be generated, if it points to NULL,
 * requesters will appear on the workbench. Default is NULL,
 * or the pr_WindowPtr of the MEMTAG_TASK if available.
 */
#define MEMTAG_WINDOWPTRPTR     ( MEMTAG_DUMMY + 0x14 )

/* hook for swapping the virtual memory */
#define MEMTAG_VMHOOK           ( MEMTAG_DUMMY + 0x20 )

/* alternatively: A hook type for partition/file/device swapping,
   mutually exclusive to the above
*/
#define MEMTAG_VMSWAPTYPE       ( MEMTAG_DUMMY + 0x30 )

#define MEMFLAG_SWAPFILE        1L
#define MEMFLAG_SWAPPART        2L
#define MEMFLAG_SWAPDEVICE      3L

/* for the file type swapping: The file name to swap to */
#define MEMTAG_SWAPFILENAME     ( MEMTAG_DUMMY + 0x40 )

/* lock to the directory. Default is current dir */
#define MEMTAG_SWAPFILELOCK     ( MEMTAG_DUMMY + 0x41 )

/* do not delete the file, use its contents */
#define MEMTAG_KEEPFILE         ( MEMTAG_DUMMY + 0x42 )

/* for the partition type swapping: DeviceNode * to swap to */
#define MEMTAG_SWAPDEVICENODE   ( MEMTAG_DUMMY + 0x50 )

/* alternatively: The name of the device node */
#define MEMTAG_SWAPPARTNAME     ( MEMTAG_DUMMY + 0x51 )

/* for the device type swapping: device name */
#define MEMTAG_DEVICENAME       ( MEMTAG_DUMMY + 0x60 )

/* and unit number */
#define MEMTAG_DEVICEUNIT       ( MEMTAG_DUMMY + 0x61 )

/* and flags for OpenDevice() */
#define MEMTAG_DEVICEFLAGS      ( MEMTAG_DUMMY + 0x62 )

/* and BufMemType() */
#define MEMTAG_BUFMEMTYPE       ( MEMTAG_DUMMY + 0x63 )

/* and Mask */
#define MEMTAG_MASK             ( MEMTAG_DUMMY + 0x64 )

/* and MaxTransfer */
#define MEMTAG_MAXTRANSFER      ( MEMTAG_DUMMY + 0x65 )

/* still for the device hook: size of the device in bytes. 4GB is the limit
 * since we don't have a larger address space anyhow.
 */
#define MEMTAG_DEVICESIZE       ( MEMTAG_DUMMY + 0x66 )

/* still for the device hook: pointer to a QUAD (big-endian) containing the
 * origin of the device, i.e. where the first sector shall be allocated.
 * Defaults to 0, i.e. start at first offset.
 */
#define MEMTAG_DEVICEORIGIN     ( MEMTAG_DUMMY + 0x67 )

/* still for the device hook: size of a sector from the device. Defaults
 * to 512 bytes.
 */
#define MEMTAG_SECTORSIZE       ( MEMTAG_DUMMY + 0x68 )

/* tags for creating new virtual memory pools */
#define MEMTAG_ADRSPACE         ( MEMTAG_DUMMY + 0x1001 )

/* pre-allocate the user requested size from the virtual memory space */
#define MEMTAG_PREALLOC         ( MEMTAG_DUMMY + 0x1002 )

/* memory type pool allocations are taken from */
#define MEMTAG_MEMFLAGS         ( MEMTAG_DUMMY + 0x1003 )

/* caching flags for the allocated memory region */
#define MEMTAG_CACHEFLAGS       ( MEMTAG_DUMMY + 0x1004 )

/* set which caching flags for the allocated memory region */
#define MEMTAG_CACHEMASK        ( MEMTAG_DUMMY + 0x1005 )

/* reserve as much as this in bytes if run out of virtual space */
#define MEMTAG_PUDDLESIZE       ( MEMTAG_DUMMY + 0x1006 )

/*
 * The threshold for building single puddles
 */
#define MEMTAG_PUDDLETHRES      ( MEMTAG_DUMMY + 0x1007 )

/* set the priority of the memory pool: Lower priority pools
 * are swapped out first.
 */
#define MEMTAG_POOLPRI          ( MEMTAG_DUMMY + 0x1008 )

/* the pool must not be enlarged over the initial size.
 * only available if PREALLOC has been specified as well.
 * Default is FALSE
 */
#define MEMTAG_FIXEDSIZE        ( MEMTAG_DUMMY + 0x1009 )

/* the pool provides virtual memory that can be allocated.
 * Defaults to TRUE, can be set to FALSE only if PREALLOC
 * is set. Implies FIXEDSIZE as the pool cannot grow.
 */
#define MEMTAG_PROVIDESMEM      ( MEMTAG_DUMMY + 0x100a )

/* the pool contents will not be cleared, but is pre-defined by
 * the external swap file. Defaults to FALSE.
 */
#define MEMTAG_PREDEFINED       ( MEMTAG_DUMMY + 0x100b )

/*
 * do not care about writes into the pages, don't swap data out.
 * Requires PREDEFINED
 */
#define MEMTAG_READONLY         ( MEMTAG_DUMMY + 0x100c )

#endif

