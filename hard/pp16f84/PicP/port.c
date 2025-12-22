/*
 * port.c
 *
 * Amiga version and Silicon Chip "Pic Programmer and Checkerboard"
 * modifications by Ken Tyler.
 *
 * 26-dec-2001: V-1.0; Amiga version
 *
 * THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT WARRANTY OF ANY KIND,
 * EITHER EXPRESSED OR IMPLIED.
 *
 */

#include "port.h"

#include <proto/misc.h>
#include <resources/misc.h>

#include <clib/exec_protos.h>
#include <clib/misc_protos.h>
#include <clib/alib_protos.h>

struct	Library *MiscBase = NULL;
UBYTE	*my_name = "PIC Programmer";
int	my_port_data = 0;
int	my_port_bits = 0;

int get_port()
{
UBYTE *fail;

    if (!(MiscBase = OpenResource(MISCNAME)))
	return 1;
    
    if ((fail = AllocMiscResource(MR_PARALLELPORT, my_name))) {
	return 2;
    } else
	my_port_data = 1;

    if ((fail = AllocMiscResource(MR_PARALLELBITS, my_name))) {
	FreeMiscResource(MR_PARALLELPORT);
	return 3;
    } else
	my_port_bits = 1;

    return 0;
}

void free_port()
{
    if (my_port_data)
	FreeMiscResource(MR_PARALLELPORT);
    if (my_port_bits)
	FreeMiscResource(MR_PARALLELBITS);
}
