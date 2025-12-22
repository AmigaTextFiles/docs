#ifndef PRAGMAS_ASL_PRAGMAS_H
#define PRAGMAS_ASL_PRAGMAS_H

#ifndef CLIB_ASL_PROTOS_H
#include <clib/asl_protos.h>
#endif

extern struct Library *AslBase;

#pragma libcall AslBase AllocFileRequest 1e 00
#pragma libcall AslBase FreeFileRequest 24 801
#pragma libcall AslBase RequestFile 2a 801
#pragma libcall AslBase AllocAslRequest 30 8002
#pragma libcall AslBase FreeAslRequest 36 801
#pragma libcall AslBase AslRequest 3c 9802

#endif  /*  PRAGMAS_ASL_PRAGMAS_H  */
