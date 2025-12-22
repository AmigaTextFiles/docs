/*
 * timer.c
 *
 * Orignal : Copyright (C) 2001 Ken Tyler.  All rights reserved.
 * Permission is granted to use, modify, or redistribute this software
 * so long as it is not sold or exploited for profit.
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

#include "timer.h"

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

struct MsgPort *tm_mp = NULL;
struct timerequest *tm_request = NULL;
int tm_error;

int get_timer()
{
  if (!(tm_mp)) {				/* don't get timer twice */

    if (!(tm_mp = CreatePort(NULL, 0)))
      return -1;

    if (!(tm_request = (struct timerequest *)CreateExtIO(tm_mp, sizeof(struct timerequest))))
      return -1;

    if (tm_error = OpenDevice(TIMERNAME, UNIT_MICROHZ, (struct IORequest *)tm_request ,0))
      return -1;

    tm_request->tr_node.io_Command = TR_ADDREQUEST;
    tm_request->tr_time.tv_micro = 0;
    tm_request->tr_time.tv_secs = 0;

  }
  return 0;
}

void free_timer()
{
  if (!tm_error)
    CloseDevice((struct IORequest *)tm_request);

  if (tm_request)
    DeleteExtIO((struct IORequest *)tm_request);

  if (tm_mp)
    DeletePort(tm_mp);
}

void us_delay(unsigned long u_secs)
{
    if (u_secs == 0 )
	return;

   tm_request->tr_node.io_Command = TR_ADDREQUEST;
   tm_request->tr_time.tv_micro = u_secs;
   tm_request->tr_time.tv_secs = 0;

   DoIO((struct IORequest *)tm_request);
}
