/*
**     $Author: Bipsen $
**     $Filename: i2c_library.h $
**     $Release: 2.00 $
**     $Revision: 39.2 $
**     $Date: 1996/02/27 12:54:48 $
**
**     Headerfile to include in programs using i2c.library
** 
*/

#include <exec/libraries.h>
#include <exec/types.h>

extern struct Library *I2C_Base;

/* Definitions for return-codes etc. */

/* If you call SetI2CDelay only to read the delay, not change it: */
#define I2CDELAY_READONLY 0xffffffff

/* Type of delay to pass to AllocI2C (obsolete in V39, see docs): */
#define DELAY_TIMER 1   /* Use timer.device for SCL-delay  */
#define DELAY_LOOP  2   /* Use for/next-loop for SCL-delay */

/* Allocation Errors */
/* (as returned by AllocI2C, BringBackI2C, or found in the middle high */
/* byte of the error codes from V39's SendI2C/ReceiveI2C) */
enum {I2C_OK=0, I2C_PORT_BUSY, I2C_BITS_BUSY, I2C_NO_MISC_RESOURCE,
      I2C_ERROR_PORT, I2C_ACTIVE, I2C_NO_TIMER };

/* I2C_OK                Operation was OK                    */
/* I2C_PORT_BUSY         Could not allocate parallel-port    */
/* I2C_BITS_BUSY         Could not allocate the needed bits  */
/* I2C_NO_MISC_RESOURCE  Could not get misc.resource         */
/* I2C_ERROR_PORT        Could not open messageport          */
/* I2C_ACTIVE            I2C-bus already active              */
/* I2C_NO_TIMER          Cannot get timer                    */

/* I/O Errors */
/* (as found in the middle low byte of the error codes from V39's */
/* SendI2C/ReceiveI2C) */
enum { /*I2C_OK=0,*/ I2C_REJECT=1, I2C_NO_REPLY, SDA_TRASHED, SDA_LO, 
       SDA_HI, SCL_TIMEOUT, SCL_HI, I2C_HARDW_BUSY };

/* I2C_OK          Last send/receive was OK                  */
/* I2C_REJECT      Data not acknowledged (i. e. unwanted)    */
/* I2C_NO_REPLY    Chip address apparently invalid           */
/* SDA_TRASHED     SDA randomly trashed. Wrong interface attached? */
/* SDA_LO          SDA always LO \_no interface              */
/* SDA_HI          SDA always HI / attached at all?          */
/* SCL_TIMEOUT     \_Might make sense for interfaces that can read the */
/* SCL_HI          / clock line, but none of the known interfaces can. */
/* I2C_HARDW_BUSY  Hardware allocation failed                */

