/*
  SMIF
  SmartMedia InterFace
  v0.3
  Janne Lumikanta
  22-08-2001

  sc link smif.c

  Usage
    smif getjpg -o <basename>
    smif read -o <outfile> -s <startaddress> -l <length>
    smif write -i <infile> -s <startaddress>



  Hardware info

  BUSY - control /RE & /WE
  POUT - 245 dir
  SEL - 573/245 select

  74HC574 bits

     7     6     5     4     3     2     1     0  
  .-----.-----.-----.-----.-----.-----.-----.-----. 
  |  x  |  x  | /CE | /WP | ALE | CLE | .re | .we | 
  `-----"-----"-----"-----"-----"-----"-----"-----' 
     -     -     0     0     1     1     1     1

*/

// Version string
const char Version[]="$VER: SmartMedia InterFace 0.3   22-08-2001\0";

#include <exec/types.h>
#include <exec/io.h>
#include <exec/memory.h>
#include <dos/dos.h>
#include <devices/parallel.h>

#include <clib/exec_protos.h>
#include <clib/alib_protos.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>



#ifdef LATTICE
int CXBRK(void) { return(0); }     /* Disable Lattice CTRL/C handling */
int chkabort(void) { return(0); }  /* really */
#endif



/*
   Parallel addresses
   ciaa  = d0-d7
   ciaad = d0-d7 direction
   ciab  = BUSY, POUT, SEL
   ciabd = BUSY, POUT, SEL direction
*/

UBYTE *CIAA=(UBYTE *)0xBFE101;
UBYTE *CIAAD=(UBYTE *)0xBFE301;
UBYTE *CIAB=(UBYTE *)0xBFD000;
UBYTE *CIABD=(UBYTE *)0xBFD200;

UBYTE cardsize;
UBYTE buffer[512];



/*
   Usage()
   prints info if no valid arguments were given
*/
void Usage(void)
{
printf("\nUsage\n");
printf("  smif getjpg -o <basename>\n");
printf("  smif read -o <outfile> -s <startaddress> -l <length>\n");
printf("  smif write -i <infile> -s <startaddress>\n");
printf("\nExample\n");
printf("  smif getjpg -o work:digi/pic\n");
printf("       saves all JPEG files as work:digi/picxxxx.JPG\n");
printf("\n  smif read -o PIECE -s 0x24000 -l 0x100000\n");
printf("       grabs 1MB starting from address 0x24000 (dec 147456) to file PIECE\n");
printf("\n  smif write -i Darkwell.jpg -s 262144\n");
printf("       writes Darkwell.jpg to SmartMedia starting from address 0x40000\n");
printf("  WARNING!!! - You can make your SmartMedia incompatible, read WARNING\n");
printf("\n - one SmartMedia block is 16 Kbytes\n");
printf(" - all data stored in standard format starts from address n*16 Kbytes\n");
printf(" - it's possible but not recommended to use any startaddress\n");
printf("   in order to maintain compatibility with other SmartMedia systems\n\n");
}



/*
   FileSize()
   Used to the size of a file
   Entry : FILE *fp = file to be examined
*/
int FileSize(FILE *fp)
{
  long size, pos=ftell(fp);
    fseek(fp,0,2);      /* Goto EOF */
  size=ftell(fp);      /* Read position */
  fseek(fp,pos,0);    /* Goto old position */
  return(size);
}



/*
   BusyTest()
   Used to test if SmartMedia is busy or it takes too long
   Return waittime
*/
int BusyTest()
{
  UBYTE byte=0;
  ULONG temp=0;

  *CIAAD = 0x7F;           // d7 input, check if R/´B is down
  while (temp < 0xFFFFFF && byte != 0x80)
  {
    byte = *CIAA & 0x80;   // mask d7
    temp++;
  }
  return(temp);  
}



/*
   Command()
   Send command to SmartMedia
   Entry : UBYTE byte = command
   Command table
   80 = Serial Data input
   00 = Read Mode (1)
   01 = Read Mode (2)
   50 = Read Mode (3)
   FF = Reset
   10 = Auto Page Program
   60 D0 = Auto Block Erase
   70 = Status Read
   90 = ID Read
*/

VOID Command(UBYTE byte)
{
                           // d0-7 output
  *CIAAD = 0xFF;          // CIAAD = %11111111
                           // disable /RE and /WE
  *CIAB &= 0xFE;          // BUSY=0

                           // 245 out
  *CIAB |= 2;             // POUT=1

                           // enable 573, start command sequence
  *CIAA = 0x30;           // 573 = --110000
  *CIAB |= 4;             // SEL=1
  *CIAA = 0x15;           // 573 = --010101

                           // enable 245, load command
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = byte;           // CIAA = byte

                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // set defaults   
  *CIAA = 0x30;           // 573 = --110000

                           // enable 573 
  *CIAB |= 4;             // SEL=1
}



/*
   ABE()
   Send Auto Block Erase command to SmartMedia
   Entry : ULONG StAddr = startaddress
   Return : status  
*/

UBYTE ABE(ULONG StAddr)
{
  UBYTE Adr1, Adr2, Adr3, Adr4;    // Startaddress pieces
  UBYTE status;
  ULONG temp;

  temp=StAddr & 0x1FE00;           // Adr2 = A9-A16
  temp>>= 9;
  Adr2=temp;
  temp=StAddr & 0x1FE0000;         // Adr3 = A17-A24
  if (cardsize == 0x73)            // set A24 to 0 if 16MB
    temp &= 0xFE0000;
  temp>>= 17;
  Adr3=temp;
  temp=StAddr & 0x2000000;         // Adr4 = A25
  temp>>= 25;
  Adr4=temp;

                           // d0-7 output
  *CIAAD = 0xFF;          // CIAAD = %11111111
                           // disable /RE and /WE
  *CIAB &= 0xFE;          // BUSY=0

                           // 245 out
  *CIAB |= 2;             // POUT=1

                           // enable 573, start command sequence
  *CIAA = 0x30;           // 573 = --110000
  *CIAB |= 4;             // SEL=1
  *CIAA = 0x15;           // 573 = --010101

                           // enable 245, load command
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = 0x60;           // CIAA = 0x60, ABE setup command

                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // enable 573
  *CIAA = 0x19;           // 573 = --011001
  *CIAB |= 4;             // SEL=1
  
                           // en 245, load A9-A16
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = Adr2;           // CIAA = Adr2
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // load A17-A24
  *CIAA = Adr3;           // CIAA = Adr3
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

  if (cardsize >= 0x76)    // only if card >=64MB
  {                        // load A25-
    *CIAA = Adr4;         // CIAA = Adr4
                           // pulse /WE
    *CIAB |= 1;           // BUSY=1
    *CIAB &= 0xFE;        // BUSY=0
  }

                           // enable 573
  *CIAA = 0x15;           // 573 = --010101
  *CIAB |= 4;             // SEL=1

                           // enable 245, load command
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = 0xD0;           // CIAA = 0xD0, Erase Start command
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

  *CIAA = 0;
  BusyTest();              // is card busy

  *CIAAD = 0xFF;           // d0-7 out

                           // enable 573, status read sequence
  *CIAA = 0x15;           // 573 = --010101
  *CIAB |= 4;             // SEL=1

                           // enable 245, load command
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = 0x70;           // CIAA = 0x60, status read command
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // en 573 
  *CIAA = 0x30;           // 573 = --110000
  *CIAB |= 4;             // SEL=1
  *CIAA = 0x12;           // 573 = --010010
  

                           // en 245, 245 in, d0-7 in
  *CIAB &= 0xFB;          // SEL=0
  *CIAB &= 0xFD;          // POUT=0
  *CIAAD = 0;             // CIAAD = %00000000

                           // pulse /RE and get status
  *CIAB |= 1;             // BUSY=1
  status = *CIAA;         // status = CIAA
  *CIAB &= 0xFE;          // BUSY=0

                          // set defaults   
  *CIAA = 0x30;           // 573 = --110000

                           // enable 573 
  *CIAB |= 4;             // SEL=1
  return(status);
}



/*
   IDTest()
   Get cardsize (global) & manufacturer (return value)
*/

UBYTE IDTest(VOID)
{
  UBYTE Maker;
                           // 245 out
  *CIAB |= 2;             // POUT=1
                           // en 573, start cmd seq
  *CIAA = 0x38;           // 573 = --111000
  *CIAB |= 4;             // SEL=1
  *CIAA = 0x19;           // 573 = --011001

                           // en 245, load address (0) 
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = 0;              // CIAA = 0

                           // pulse /WE   
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // en 573 
  *CIAA = 0x38;           // 573 = --111000
  *CIAB |= 4;             // SEL=1
  *CIAA = 0x30;           // 573 = --110000
  *CIAA = 0x12;           // 573 = --010010

                           // en 245, 245 in, d0-7 in
  *CIAB &= 0xFB;          // SEL=0
  *CIAB &= 0xFD;          // POUT=0
  *CIAAD = 0;             // CIAAD = %00000000

                           // pulse /RE and get makercode
  *CIAB |= 1;             // BUSY=1
  Maker = *CIAA;          // maker = CIAA
  *CIAB &= 0xFE;          // BUSY=0

                           // pulse /RE and get cardsize
  *CIAB |= 1;             // BUSY=1
  cardsize = *CIAA;       // cardsize = CIAA
  *CIAB &= 0xFE;          // BUSY=0
  return(Maker);
}



/*
   SeqRead()
   Read data from SmartMedia sequantially
   Entry  : char *OutName = target filename
            ULONG StAddr = startaddress
            ULONG Length = amount of data
   Return : 20 if ok, 0 if error

   I had problems using this part, first byte of new cycle (528 bytes)
   got trashed, too much speed, adding delay caused trashed data
*/
/*
this part disabled
int SeqRead(char *OutName, ULONG StAddr, ULONG Length)
{
  FILE *ofp;                       // outputfile 
  UBYTE byte;
  UBYTE Adr1, Adr2, Adr3, Adr4;    // Startaddress pieces
  ULONG temp;
  ULONG waittime;
  ULONG pos=0;

  int a;                  // used to throw away 16 extra bytes
  a=StAddr % 512;

  // try to open output file
  if ((ofp = fopen(OutName, "wb")) == NULL) 
  {
    printf("Couldn't open %s for writing.\n", OutName);
    return(0);
  }



  temp=StAddr & 0xFF;              // Adr1 = A0-A7
  Adr1=temp;
  temp=StAddr & 0x1FE00;           // Adr2 = A9-A16
  temp>>= 9;
  Adr2=temp;
  temp=StAddr & 0x1FE0000;         // Adr3 = A17-A24
  if (cardsize == 0x73)            // set A24 to 0 if 16MB
    temp &= 0xFE0000;
  temp>>= 17;
  Adr3=temp;
  temp=StAddr & 0xFE000000;         // Adr4 = A25-A31
  if (cardsize == 0x76)            // set A26-A31 to 0 if 64MB
    temp &= 0x2000000;
  if (cardsize == 0x79)            // set A27-A31 to 0 if 128MB
    temp &= 0x6000000;
  temp>>= 25;
  Adr4=temp;
   
                           // 245 out
  *CIAB |= 2;             // POUT=1
                           // en 573, start cmd seq  
  *CIAA = 0x10;           // 573 = --010000
  *CIAB |= 4;             // SEL=1
  *CIAA = 0x19;           // 573 = --011001

                           // en 245, load A0-A7
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = Adr1;           // CIAA = Adr1
                           // pulse /WE   
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // load A9-A16
  *CIAA = Adr2;           // CIAA = Adr2
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // load A17-A24
  *CIAA = Adr3;           // CIAA = Adr3
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

  if (cardsize >= 0x76)    // only if card >=64MB
  {                        // load A25-
    *CIAA = Adr4;         // CIAA = Adr4
                           // pulse /WE
    *CIAB |= 1;           // BUSY=1
    *CIAB &= 0xFE;        // BUSY=0
  }

  waittime=BusyTest();  

  *CIAAD = 0xFF;           // d0-7 out


                           // en 573  
  *CIAA = 0x12;           // 573 = %--010010
  *CIAB |= 4;             // SEL=1

                           // en 245, 245 in, d0-7 in
  *CIAB &= 0xFB;          // SEL=0
  *CIAB &= 0xFD;          // POUT=0
  *CIAAD = 0;             // CIAAD = %00000000
  do                      // repeat readcycle until pos=length
  {
                                            // pulse /RE and read byte
    *CIAB |= 1;                            // BUSY=1
    for (temp=0; temp<waittime; temp++);   // delay
    if (a<512)
    {
      byte = *CIAA;
      putc(byte, ofp);
      pos++;
    }
    *CIAB &= 0xFE;                         // BUSY=0
    a++;
    a %=528;
    temp=0;                  // wait if card is busy or it takes too long
    byte=0;

    *CIAB |= 2;             // POUT=1
    while (temp < 0x1000 && byte != 0x80)
    {
      byte = *CIAA & 0x80;   // mask d7
      temp++;
    }
    *CIAB &= 0xFD;          // POUT=0
  }while (pos<Length);
 
  *CIAAD = 0xFF;          // CIAAD = %11111111
                           // 245 out
  *CIAB |= 2;             // POUT=1
                           // enable 573
  *CIAA = 0x30;           // 573 = --110000
  *CIAB |= 4;             // SEL=1

  fclose(ofp);
  printf("File %s ready\n", OutName);
  return(20);
}
end of seqread
*/


/*
   PageRead()
   Read 512 bytes from SmartMedia
   Entry : ULONG StAddr = startaddress
*/

PageRead(ULONG StAddr)
{
  UBYTE byte;
  UBYTE Adr1, Adr2, Adr3, Adr4;    // Startaddress pieces
  ULONG temp;
  int pos;

  temp=StAddr & 0xFF;              // Adr1 = A0-A7
  Adr1=temp;
  temp=StAddr & 0x1FE00;           // Adr2 = A9-A16
  temp>>= 9;
  Adr2=temp;
  temp=StAddr & 0x1FE0000;         // Adr3 = A17-A24
  if (cardsize == 0x73)            // set A24 to 0 if 16MB
    temp &= 0xFE0000;
  temp>>= 17;
  Adr3=temp;
  temp=StAddr & 0x2000000;         // Adr4 = A25
  temp>>= 25;
  Adr4=temp;
   
                           // 245 out
  *CIAB |= 2;             // POUT=1
                           // en 573, start cmd seq  
  *CIAA = 0x10;           // 573 = --010000
  *CIAB |= 4;             // SEL=1
  *CIAA = 0x19;           // 573 = --011001

                           // en 245, load A0-A7
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = Adr1;           // CIAA = Adr1
                           // pulse /WE   
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // load A9-A16
  *CIAA = Adr2;           // CIAA = Adr2
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // load A17-A24
  *CIAA = Adr3;           // CIAA = Adr3
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

  if (cardsize >= 0x76)    // only if card >=64MB
  {                        // load A25-
    *CIAA = Adr4;         // CIAA = Adr4
                           // pulse /WE
    *CIAB |= 1;           // BUSY=1
    *CIAB &= 0xFE;        // BUSY=0
  }

  BusyTest();              // is card busy

  *CIAAD = 0xFF;           // d0-7 out

                           // en 573  
  *CIAA = 0x12;           // 573 = %--010010
  *CIAB |= 4;             // SEL=1

                           // en 245, 245 in, d0-7 in
  *CIAB &= 0xFB;          // SEL=0
  *CIAB &= 0xFD;          // POUT=0
  *CIAAD = 0;             // CIAAD = %00000000


  for (pos=0; pos<512; pos++)
  {
                                            // pulse /RE and read byte
    *CIAB |= 1;                            // BUSY=1
    byte=*CIAA;
    buffer[pos]=byte;
    *CIAB &= 0xFE;                         // BUSY=0
  }
 
  *CIAAD = 0xFF;          // CIAAD = %11111111
                           // 245 out
  *CIAB |= 2;             // POUT=1
                           // enable 573
  *CIAA = 0x30;           // 573 = --110000
  *CIAB |= 4;             // SEL=1
}



/*
   PageWrite()
   Send 512+16 bytes to SmartMedia
   Entry  : ULONG StAddr = targetaddress
   Return : 20 if ok, 0 if error

*/

int PageWrite(ULONG StAddr)
{
  UBYTE byte;
  UBYTE Adr1, Adr2, Adr3, Adr4;    // Startaddress pieces
  ULONG temp;
  ULONG pos;

  temp=StAddr & 0xFF;              // Adr1 = A0-A7
  Adr1=temp;
  temp=StAddr & 0x1FE00;           // Adr2 = A9-A16
  temp>>= 9;
  Adr2=temp;
  temp=StAddr & 0x1FE0000;         // Adr3 = A17-A24
  if (cardsize == 0x73)            // set A24 to 0 if 16MB
    temp &= 0xFE0000;
  temp>>= 17;
  Adr3=temp;
  temp=StAddr & 0x2000000;         // Adr4 = A25
  temp>>= 25;
  Adr4=temp;
   
                           // 245 out
  *CIAB |= 2;             // POUT=1
                           // en 573, start cmd seq  
  *CIAA = 0x10;           // 573 = --010000
  *CIAB |= 4;             // SEL=1
  *CIAA = 0x19;           // 573 = --011001

                           // en 245, load A0-A7
  *CIAB &= 0xFB;          // SEL=0
  *CIAA = Adr1;           // CIAA = Adr1
                           // pulse /WE   
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // load A9-A16
  *CIAA = Adr2;           // CIAA = Adr2
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

                           // load A17-A24
  *CIAA = Adr3;           // CIAA = Adr3
                           // pulse /WE
  *CIAB |= 1;             // BUSY=1
  *CIAB &= 0xFE;          // BUSY=0

  if (cardsize >= 0x76)    // only if card >=64MB
  {                        // load A25-
    *CIAA = Adr4;         // CIAA = Adr4
                           // pulse /WE
    *CIAB |= 1;           // BUSY=1
    *CIAB &= 0xFE;        // BUSY=0
  }

  BusyTest();              // is card busy

  *CIAAD = 0xFF;           // d0-7 out


                           // en 573  
  *CIAA = 0x11;           // 573 = %--010001
  *CIAB |= 4;             // SEL=1

                           // en 245
  *CIAB &= 0xFB;          // SEL=0

  for (pos=0; pos<512; pos++)
  {
    byte=buffer[pos];          // get byte from buffer
    *CIAA = byte;             // CIAA = byte
                               // pulse /WE and write byte
    *CIAB |= 1;               // BUSY=1
    *CIAB &= 0xFE;            // BUSY=0
  }
  for (pos=0; pos<16; pos++)  // pad those extra 16 bytes with 0
  {
    *CIAA = 0;                // CIAA = 0
                               // pulse /WE and write byte
    *CIAB |= 1;               // BUSY=1
    *CIAB &= 0xFE;            // BUSY=0
  }

  BusyTest();              // is card busy

                           // enable 573
  *CIAA = 0x30;           // 573 = --110000
  *CIAB |= 4;             // SEL=1

  return(20);
}



/*
   GetJPG()
   extract jpeg-files from card, fragmented files won't work
   Entry :  char *name = target file
*/

int GetJPG(char *name)
{
  FILE *fp;
  char outfile[255];
  int pic=0;          // current image
  int ext;            // append nnnn.JPG starting from here
  ULONG pos;          // position on SmartMedia
  int bufpos;         // position inside buffer
  int block;          // block under seek
  int endblock;       // stop here
  int jpgend;         // used in 0xFFD9 searching
  int temp;
  int stopmark;       // 1 after thumbnail, 2 when main image ends

  switch (cardsize)
  {
  case 0x73:
    endblock=0x400;break;
  case 0x75:
    endblock=0x800;break;
  case 0x76:
    endblock=0x1000;break;
  case 0x79:
    endblock=0x2000;break;
  }

  for(ext=0; ((outfile[ext]=name[ext])!='\0'); ext++);

  for (block=0; block<endblock; block++)
  {
    pos=block*0x4000;
    Command(0);                      // read command 0
    PageRead(pos);
    temp=0x100*buffer[0]+buffer[1];
    if (temp==0xffd8)                // jpeg found
    {
      pic++;

      // Make name
      outfile[ext]=((pic/1000) + 48);
      outfile[ext+1]=(((pic%1000)/100) + 48);
      outfile[ext+2]=(((pic%100)/10) + 48); 
      outfile[ext+3]=((pic%10) + 48);          
      outfile[ext+4]='.';
      outfile[ext+5]='J';
      outfile[ext+6]='P';
      outfile[ext+7]='G';
      outfile[ext+8]='\0';

      // Try to open output file
      if ((fp = fopen(outfile, "wb")) == NULL) 
      {
        printf("Couldn't open %s for writing.\n", outfile);
        exit(-1);
      }
      fwrite(buffer, 1, 512, fp);
      stopmark=0;
      jpgend=0;
      do
      {
        pos+=512;
// next line caused problems if there was broken jpeg files
//        if ((pos/0x4000)>block) block++;
        temp=(pos & 0x100) >> 8;
        Command(temp);             // read command, 0 or 1
        PageRead(pos);
        bufpos=0;
        while (bufpos<512 && stopmark<2)
        {
          jpgend<<= 8;
          jpgend+=buffer[bufpos];
          jpgend&=0xffff;
          if (jpgend==0xffd9) stopmark++;
          bufpos++;
        }
        fwrite(buffer, 1, bufpos, fp);
      }while (stopmark<2);
      fclose(fp);
      printf("File %s ready\n", outfile);
    }
  }
  printf("End of card reached.\n");
  return(pic);
}





VOID main();

VOID main(int argc, char *argv[])
{
struct MsgPort *ParallelMP;          /* Define storage for one pointer */
struct IOExtPar *ParallelIO;         /* Define storage for one pointer */

FILE *fp;                            // outputfile 
char outfile[255];
char infile[255];
ULONG staddr;
ULONG length;
ULONG pos;
UBYTE maker;
int temp;

printf("\nSmartMedia InterFace v0.3 - 22.8.2001\n\n");

if (ParallelMP=CreatePort(0,0) )
{
  if (ParallelIO=(struct IOExtPar *)
     CreateExtIO(ParallelMP,sizeof(struct IOExtPar)) )
  {
    if (OpenDevice(PARALLELNAME,0L,(struct IORequest *)ParallelIO,0) )
      printf("%s did not open\n",PARALLELNAME);
    else
    {
      // BUSY out - control /RE & /WE
      // POUT out - 245 dir
      // SEL out - 573/245 select
      *CIABD |= 7;
      *CIAB &= 0xFE;             // set /RE and /WE to 1

      maker=0;
      cardsize=0;

      Command(0xFF);             // reset card
      Delay (10);                // wait .1 secs
      Command(0x90);             // ID read command
      maker=IDTest();            // ID read sub
      Command(0xFF);             // reset card again

      printf("Maker code = 0x%lx\n",maker);
      printf("Device code = 0x%lx\n",cardsize);
      switch (cardsize)
      {
        case 0x73:
          printf("16MB card detected, high address = 0x00FFFFFF\n");
        break;
        case 0x75:
          printf("32MB card detected, high address = 0x01FFFFFF\n");
        break;
        case 0x76:
          printf("64MB card detected, high address = 0x03FFFFFF\n");
        break;
        case 0x79:
          printf("128MB card detected, high address = 0x07FFFFFF\n");
        break;
        default:
          printf("Didn't find any of supported cards\n");
          goto escape;
        break;
      }

      if (argc < 2) Usage();
      else
      {
        if (strcmp(argv[1],"getjpg")==0)
        {
          if (strcmp(argv[2],"-o")==0)
          {
            strncpy(outfile, argv[3], 255);
            outfile[255]="\0";
            temp=GetJPG(outfile);
            if (temp==0) printf("getjpg failed");
            else printf("Saved %ld jpeg-files as %sxxxx.JPG\n", temp, outfile);
          }
          else Usage();
        }
        else if (strcmp(argv[1],"read")==0)
        {
          if (strcmp(argv[2],"-o")==0)
          {
            strncpy(outfile, argv[3], 255);
            outfile[255]="\0";
            if (strcmp(argv[4],"-s")==0)
            {
              staddr=strtol(argv[5],0,0);
              if (strcmp(argv[6],"-l")==0)
              {
                length=strtol(argv[7],0,0);
                if (length<1) Usage();

// PageRead 1st start
                // Try to open output file
                if ((fp = fopen(outfile, "wb")) == NULL) 
                {
                  printf("Couldn't open %s for writing.\n", outfile);
                  goto escape;
                }
                if (staddr % 512!=0)
                {
                  staddr-=staddr % 512;
                  printf("BETA version, address forced to modulo of 512\n");
                  printf("new address = %lx\n", staddr);
                }
// PageRead 1st end

                temp=staddr + length;
                switch (cardsize)
                {
                case 0x73:
                  if (temp>=0x1000000) length=0x1000000 - staddr;break;
                case 0x75:
                  if (temp>=0x2000000) length=0x2000000 - staddr;break;
                case 0x76:
                  if (temp>=0x4000000) length=0x4000000 - staddr;break;
                case 0x79:
                  if (temp>=0x8000000) length=0x8000000 - staddr;break;
                }

// PageRead 2nd start
                for (pos=staddr; pos<staddr + length; pos+=512)
                {
                  temp=(pos & 0x100) >> 8;
                  Command(temp);              // read command, 0 or 1
                  PageRead(pos);
                  fwrite(buffer, 1, 512, fp);
                }
                fclose(fp);
                printf("File %s ready\n", outfile);
// PageRead 2nd end


// seqread part, if you try this, disable PageRead 1st and 2nd
//                temp=(staddr & 0x100) >> 8;
//                Command(temp);                       // read command
//                if (SeqRead(outfile, staddr, length)!=0) goto escape;
// seqread end


              }
              else Usage();
            }
            else Usage();
          }
          else Usage();
        }
        else if (strcmp(argv[1],"write")==0)
        {
          if (strcmp(argv[2],"-i")==0)
          {
            strncpy(infile, argv[3], 255);
            infile[255]="\0";
            if (strcmp(argv[4],"-s")==0)
            {
              staddr=strtol(argv[5],0,0);
              if ((fp = fopen(infile,"rb")) == NULL)
              {
                printf("Can't open %s\n", infile);
                goto escape;
              }
              if (staddr % 0x4000!=0)
              {
                staddr-=staddr % 0x4000;
                printf("BETA version, address forced to modulo of 0x4000\n");
                printf("new address = %lx\n", staddr);
              }
              length=FileSize(fp);
              if (length==0)
              {
                printf("File %s is empty\n", infile);
                goto escape;
              }

              temp=staddr + length;
              switch (cardsize)
              {
              case 0x73:
                if (temp>0x1000000) temp=0;break;
              case 0x75:
                if (temp>0x2000000) temp=0;break;
              case 0x76:
                if (temp>0x4000000) temp=0;break;
              case 0x79:
                if (temp>0x8000000) temp=0;break;
              }
              if (temp==0)
              {
                printf("File %s won't fit\n", infile);
                goto escape;
              }
              pos=0;
              do
              {
                if (pos % 0x4000==0)
                {
                  if (ABE(pos+staddr)!=0xc0) printf("Error while erasing.\n");
                }

                temp=fread(buffer, 1,512, fp);
                if (temp<512) for (;temp<512;temp++) buffer[temp]=0;

                Command(0x80);              // data input command
                if (PageWrite(pos+staddr)!=20)
                {
                  printf("Write failed\n");
                  goto escape;
                }
                Command(0x10);              // auto page program
                BusyTest();
                pos+=512;
              }while (pos<length);
              printf("File %s was written to address 0x%lx\n", infile, staddr);
              fclose(fp);
            }
            else Usage();
          }
          else Usage();
        }
        else Usage();
      }
      escape:               // Jump here if something goes wrong

      AbortIO(ParallelIO);  /* Ask device to abort request, if pending */
      WaitIO(ParallelIO);   /* Wait for abort, then clean up */

      CloseDevice((struct IORequest *)ParallelIO);
    }
    DeleteExtIO(ParallelIO);
  }
  DeletePort(ParallelMP);
}
}
