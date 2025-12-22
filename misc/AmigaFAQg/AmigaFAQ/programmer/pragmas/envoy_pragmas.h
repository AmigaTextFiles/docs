#ifndef PRAGMAS_ENVOY_PRAGMAS_H
#define PRAGMAS_ENVOY_PRAGMAS_H

#ifndef CLIB_ENVOY_PROTOS_H
#include <clib/envoy_protos.h>
#endif

extern struct Library *EnvoyBase;

#pragma libcall EnvoyBase HostRequestA 1e 801
#pragma libcall EnvoyBase LoginRequestA 24 801
#pragma libcall EnvoyBase UserRequestA 2a 801

#endif  /*  PRAGMAS_ENVOY_PRAGMAS_H  */
