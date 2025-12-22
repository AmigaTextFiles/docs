// pragmas for asl.library
// (c) Maxon Computer 1996
#ifndef _INCLUDE_PRAGMA_ASL_LIB_H
#define _INCLUDE_PRAGMA_ASL_LIB_H

#include <clib/i2c_protos.h>
#ifdef __cplusplus                                                                                         
extern "C" {
#endif

#pragma amicall(I2C_Base, 0x1e, AllocI2C(d0,a1))
#pragma amicall(I2C_Base, 0x24, FreeI2C())
#pragma amicall(I2C_Base, 0x2a, SetI2CDelay(d0))
#pragma amicall(I2C_Base, 0x36, SendI2C(d0,d1,a1))
#pragma amicall(I2C_Base, 0x3c, ReceiveI2C(d0,d1,a1))
#pragma amicall(I2C_Base, 0x42, GetI2COpponent())
#pragma amicall(I2C_Base, 0x48, I2CErrText(d0))
#pragma amicall(I2C_Base, 0x4E, ShutDownI2C())
#pragma amicall(I2C_Base, 0x54, BringBackI2C())
#ifdef __cplusplus
}
#endif
#endif
