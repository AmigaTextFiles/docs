/*
   pardemo.h
   Parallel Port Input/Output Demo
   v1.5
   Tom Handley
   15 Apr 93
   Compiled with Manx v5.20a. To compile and link:
      cc pardemo.c
      ln pario.o pardemo.o -lc
*/

#include    <stdio.h>
#include    <exec/types.h>
                                        
/* Define some console control macros */

#define     CLS      (putchar(0x0C))             /* Clear screen */
#define     CXY(x,y) (printf("\x9B%d;%dH",y,x))  /* Move cursor to x,y */
#define     EOL      (printf("\x9BK"))           /* Erase to end of line */

/* Define menu, choice, data prompt, and data display, cursor references */

#define     MENUX     1    /* Menu x */
#define     MENUY     2    /* Menu y */
#define     CHOICEX   20   /* Choice x */
#define     CHOICEY   19   /* Choice y */
#define     PROMPTX   3    /* Data prompt x */
#define     PROMPTY   21   /* Data prompt y */
#define     DATAX     43   /* Data display x */
#define     DATAY     4    /* Data display y (y = choice + DATAY) */

/* Define menu choice range */

#define     MENUMIN   0    /* Minimum choice */
#define     MENUMAX   13   /* Maximum choice */

#ifdef LATTICE
int    CXBRK(void)    { return(0); }  /* Disable Lattice CTRL/C handling */
int    chkabort(void) { return(0); }
#endif

#ifdef AZTEC_C
extern int Enable_Abort;              /* Manx CTRL-C abort enable */
#endif

/* External assembly routines from "pario.asm". See "pario.doc" */

extern  LONG    getport(void);  /* Get   parallel port access      */
extern  void    freeport(void); /* Free  parallel port access      */
extern  void    portdir(UBYTE); /* Set   port data direction (0/1) */
extern  void    portddr(UBYTE); /* Set   port data direction bits  */
extern  UBYTE   rdport(void);   /* Read  port data                 */
extern  void    wrport(UBYTE);  /* Write port data                 */
extern  void    busydir(UBYTE); /* Set   BUSY data direction (0/1) */
extern  UBYTE   rdbusy(void);   /* Read  BUSY state (0/1)          */
extern  void    setbusy(UBYTE); /* Set   BUSY state (0/1)          */
extern  void    poutdir(UBYTE); /* Set   POUT data direction (0/1) */
extern  UBYTE   rdpout(void);   /* Read  POUT state (0/1)          */
extern  void    setpout(UBYTE); /* Set   POUT state (0/1)          */
extern  void    seldir(UBYTE);  /* Set   SEL  data direction (0/1) */
extern  UBYTE   rdsel(void);    /* Read  SEL  state (0/1)          */
extern  void    setsel(UBYTE);  /* Set   SEL  state (0/1)          */

/* Data types for input (STATE = 0/1, HEX = $00-$FF) */

enum  {STATE, HEX} datatype;

/* State types for state display labels (Input, Output, Low, High) */

enum  {DIRECTION, LEVEL} statetype;

/* State display labels [state type][state data] */

static char *statelabel[2][2] =
{  {"Input","Output"},
   {"Low","High"}
};

/* Menu Text */

static char menutxt[] =
{  "      Parallel Port Input/Output Demo\n"
   "\n"
   "   0. Quit\n"
   "   1. Set   Data Port Data Direction --->\n"
   "   2. Set   Data Port Direction Bits --->\n"
   "   3. Read  Data Port ------------------>\n"
   "   4. Write Data Port ------------------>\n"
   "   5. Set   BUSY Direction Bit --------->\n"
   "   6. Read  BUSY State ----------------->\n"
   "   7. Set   BUSY State ----------------->\n"
   "   8. Set   POUT Direction Bit --------->\n"
   "   9. Read  POUT State ----------------->\n"
   "  10. Set   POUT State ----------------->\n"
   "  11. Set   SEL  Direction Bit --------->\n"
   "  12. Read  SEL  State ----------------->\n"
   "  13. Set   SEL  State ----------------->\n"
   "  =======================================\n"
   "  Choice (0 - 13)?"
};

/* Prompt Text */

static char *prompt[14] =
{  "Quit\n",
   "Port Data Direction (0 = Input, 1 = Output) [0/1]? ",
   "Port Data Direction Bits (0 = Input, 1 = Output) [00 - FF]? ",
   0,
   "Port Data [00 - FF]? ",
   "BUSY Direction (0 = Input, 1 = Output) [0/1]? ",
   0,
   "BUSY State (0 = Low, 1 = High) [0/1]? ",
   "POUT Direction (0 = Input, 1 = Output) [0/1]? ",
   0,
   "POUT State (0 = Low, 1 = High) [0/1]? ",
   "SEL Direction (0 = Input, 1 = Output) [0/1]? ",
   0,
   "SEL State (0 = Low, 1 = High) [0/1]? "
};

/* Current data storage */

static UBYTE currentdata[14];

