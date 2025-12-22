#ifndef PROTO_I2C_H
#define PROTO_I2C_H

#ifndef EXEC_LIBRARIES_H
#include <exec/libraries.h>
#endif

#include <clib/i2c_protos.h>
#ifdef __MAXON__
#include <pragma/i2c_lib.h>
#else
#include <inline/i2c.h>
#endif
#ifndef __NOLIBBASE__
#ifndef __gnuc__
extern struct Library * I2C_Base;
#else
extern struct Library *__CONSTLIBBASEDECL__ I2C_Base;
#endif
#endif
#endif
