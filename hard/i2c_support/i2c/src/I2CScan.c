/* I2CScan.c:
 *   Looks who's listening on the I²C bus, using i2c.library.  Usage:
 * I2CScan [options]
 * where options are:
 *   -d<delay> : adjust i2c.library's timing parameter
 *   -v : verbose, try to identify the listening chips by their addresses
 *   -l : lock, force i2c.library to release its hardware
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <proto/exec.h>
#include <proto/i2c.h>
#include <libraries/i2c.h>

struct Library *I2C_Base = NULL;

struct chip {
  UBYTE lower_addr, upper_addr;
  STRPTR description;
};

struct chip chiptab[] = {
  { 0x20, 0x20, "PCF8200: speech synthesizer" },
  { 0x22, 0x22, "SAA5243/SAA5246: teletext decoder" },
  { 0x20, 0x22, "SAF1135/SAA4700: VPS decoder" },
  { 0x40, 0x4E, "PCF8574: 8 bit IO expander" },
  { 0x70, 0x7E, "PCF8574A: 8 bit IO expander" },
  { 0x90, 0x9E, "PCF8591: 8 bit DA/AD converter" },
  { 0x70, 0x76, "SAA1064: LED driver 2-4 × 8" },
  { 0x70, 0x72, "PCF8576: LCD driver 1-4 × 40" },
  { 0x74, 0x74, "PCF8577: LCD driver 1-2 × 32" },
  { 0x76, 0x76, "PCF8577A: LCD driver 1-2 × 32" },
  { 0x7C, 0x7E, "PCF8566: LCD driver 1-4 × 24" },
  { 0x78, 0x7A, "PCF8578: LCD dot matrix driver 32×8, 24×16, 16×24 or 8×32,\n"
              "    possibly with one or more PCF8579 (40 extra columns)" },
  { 0xA0, 0xAE, "PCF8570/PCF8571: 256/128 byte SRAM" },
  { 0xA0, 0xAE, "PCF8581/PCF8582: 256/128 byte EEPROM" },
  { 0xB0, 0xBE, "PCF8570C: 256 byte SRAM" },
  { 0xD0, 0xD6, "PCF8573: clock/calendar" },
  { 0xA0, 0xA2, "PCF8583: clock/calendar and 256 byte SRAM" },
  { 0x80, 0x86, "SAA1300: power output 5 × 85 mA" },
  { 0x88, 0x88, "TDA8442: DAC & switch for color decoder" },
  { 0x90, 0x9E, "TDA8440: AV input selector" },
  { 0x40, 0x4E, "TDA8444: 8 × 6 bit D/A converter" },
  { 0x48, 0x4A, "PCD3311/PCD3312: DTMF/modem/musical tone generator" }
} ;


void identify(UBYTE addr)
/* Tries its best to "identify" a chip address, but most I²C addresses
 * are ambiguous. 
 */
{
  int i;

  printf(", might be:\n");
  for (i = 0; i < (sizeof chiptab / sizeof chiptab[0]); i++)
    if (addr >= chiptab[i].lower_addr && addr <= chiptab[i].upper_addr)
      printf("%s\n", chiptab[i].description);
}


int report(ULONG code)
/* analyze an i2clib return code, returns TRUE if it indicates an error */
{
  static ULONG lastcode = 0;
  STRPTR s;
  
  if (code & 0xFF)  /* indicates OK */
    return FALSE;
  else {
    if (code != lastcode) {
      lastcode = code;
      if ((code >> 8) > I2C_NO_REPLY) {
        printf("I²C bus: error 0x%06lx, %s\n", code, I2CErrText(code));
        s = GetI2COpponent(); 
        if (s)  printf("\"%s\" has got our hardware\n", s);
      }
    }
    return TRUE;
  }
}


void scan(int verbose)
{
  int rd=0, wr=0, i;
  char dummy;

  for (i=0; i<128; i++) {
    wr = !report(SendI2C(2*i, 0, &dummy));
    rd = !report(ReceiveI2C(2*i+1, 1, &dummy));
    if (rd || wr) {
      if (verbose)  printf("\n");
      printf("Chip address ");
      if (rd && wr)
        printf("0x%02x/0x%02x: R/W", 2*i, 2*i+1);
      else if (rd) 
        printf("0x%02x: R only", 2*i+1);
      else
        printf("0x%02x: W only", 2*i);
      if (verbose)
        identify(2*i);
      else
        printf("\n");
    }
  }
}


void help(char *badarg)
{
  printf("Illegal option '%s', usage:\n", badarg);
  printf("  I2CScan [-d<delay>] [-v[erbose]] [-l[ock]]\n");
}


void cleanup()
{
  if (I2C_Base) {
    CloseLibrary(I2C_Base); I2C_Base = NULL;
  }
}


int main(int argc, char *argv[])
{

  ULONG busdelay;
  int i, verbose=FALSE, lockit=FALSE;

  atexit(cleanup);   /* make sure library will be closed upon Ctrl-C */
  I2C_Base = OpenLibrary("i2c.library", 39);
  if (!I2C_Base) {
    printf("Can't open i2c.library V39+\n");
    return 10;
  }
  busdelay = SetI2CDelay(I2CDELAY_READONLY);
  for (i=1; i<argc; i++)                 
    if (*argv[i] == '-') {
      switch (argv[i][1]) {
        case 'd': busdelay = atol(argv[i]+2); break;
        case 'v': verbose = TRUE; break;
        case 'l': lockit = TRUE; break;
        default: help(argv[i]); exit(10);
      }                             
    } else {
      help(argv[i]); exit(10);
    }
  if (lockit) {
    ShutDownI2C();
    printf("I²C activity halted, hit <Return> to continue... ");
    getchar();
    BringBackI2C();
    printf("\e[A\e[49Cthanks.\n");
  } else {
    SetI2CDelay(busdelay);
    printf("Delay value for I²C bus timing is %ld, ", busdelay);
    printf("scanning for listeners ...\n");
    scan(verbose);
  }
  cleanup();
  
  return 0;
}

