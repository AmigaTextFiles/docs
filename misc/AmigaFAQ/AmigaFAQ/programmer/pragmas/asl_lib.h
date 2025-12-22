#ifndef PRAGMAS_ASL_LIB_H
#define PRAGMAS_ASL_LIB_H

#ifndef CLIB_ASL_PROTOS_H
#include <clib/asl_protos.h>
#endif

#pragma amicall(AslBase,0x1e,AllocFileRequest())
#pragma amicall(AslBase,0x24,FreeFileRequest(a0))
#pragma amicall(AslBase,0x2a,RequestFile(a0))
#pragma amicall(AslBase,0x30,AllocAslRequest(d0,a0))
#pragma amicall(AslBase,0x36,FreeAslRequest(a0))
#pragma amicall(AslBase,0x3c,AslRequest(a0,a1))

#endif  /*  PRAGMAS_ASL_LIB_H  */
