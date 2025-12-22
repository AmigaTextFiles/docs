#ifndef PRAGMAS_ENVOY_LIB_H
#define PRAGMAS_ENVOY_LIB_H

#ifndef CLIB_ENVOY_PROTOS_H
#include <clib/envoy_protos.h>
#endif

#pragma amicall(EnvoyBase,0x1e,HostRequestA(a0))
#pragma amicall(EnvoyBase,0x24,LoginRequestA(a0))
#pragma amicall(EnvoyBase,0x2a,UserRequestA(a0))

#endif  /*  PRAGMAS_ENVOY_LIB_H  */
