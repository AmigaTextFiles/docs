#ifndef _INCLUDE_CLIB_I2C_LIB_H
#define _INCLUDE_CLIB_I2C_LIB_H 
/* Proto-types for functions */

BYTE AllocI2C(UBYTE Delay_Type,char *Name);
void FreeI2C(void);
ULONG SetI2CDelay(ULONG ticks);
void InitI2C(void);
ULONG SendI2C(UBYTE addr, UWORD number, UBYTE i2cdata[]);
ULONG ReceiveI2C(UBYTE addr, UWORD number, UBYTE i2cdata[]);
STRPTR GetI2COpponent(void);
STRPTR I2CErrText(ULONG errnum);
void ShutDownI2C(void);
BYTE BringBackI2C(void);
#endif
