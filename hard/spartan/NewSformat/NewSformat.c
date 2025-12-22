/*   SFormat version 2.0 by Paul Harker....written in Manx C v3.6    */
/*	Mike Lundberg added delay after select line is de-asserted, 
        compileable on Lattice */
       
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

typedef unsigned char byte;

byte RESET  = 128;        /*define CONTROL flags*/
byte BUSY    = 64;
byte REQUEST = 32;
byte MSG     = 16;
byte COMMAND  = 8;
byte INPUT    = 4;

byte ACK     = 16;        /*define cmd flags*/
byte PHASE    = 8;
byte SELECT   = 4;
byte BUS      = 1;


byte *data;		/*pointer to SCSI data register*/
byte *initCMD;		/*pointer to SCSI ICR register*/
byte *targetCMD;     	/*pointer to SCSI TCR register*/
byte *control;		/*pointer to SCSI control register*/
byte *status;		/*pointer to SCSI status register*/


byte inbuff[100], outbuff[100], cmdbuff[10], statin, msg; /* SCSI IO storage */

unsigned int address, intrlv;

void main()
{
    void errorCHECK();
    void readERROR();
    void reZERO();
    void unitRDY();
    void modeSEL();
    void doFORMAT();
    void clearCMD();
    void clearOUT();
    void clearIN();
    void goodmorning();
    void scsi();
    void doIO();
    void waitREQ();
    void doBASE();


    int dummy;
    int c;

 					/* define base offsets of registers*/ 

    data = 0x000001;
    initCMD = 0x000003;
    targetCMD = 0x000007;
    control = 0x000009;
    status = 0x00000B;

    printf("\n\n               New SFormat, with a delay after SEL \n");
    printf("                          Spartan-SCSI Formatter\n");
    printf("                            © 1991 Paul Harker\n");
    printf("\n  This utility will perform a low-level format of the hard");
    printf(" drive. ALL data\n  will be destroyed.\n\n  Continue? (Y/N) :");


    c = getchar();			/* Change for Lattice */
    c = toupper(c);
    if(c != 'Y')
       exit(200);

/*
        if(toupper(getchar()) != 'Y')
	{
	  printf("exiting program!\n");
          exit(200);
        }
*/
    printf("\n   Base Address of interface :");
      doBASE();

    			      /*  Toss a Null  */
    gets(dummy);

    printf("\n  SCSI address :");
      address = getNumber(0,6);
/*

    printf("  Interleave :");
      intrlv = getNumber(1,27); 
      intrlv = 2; */
    printf("\n  Ready to format.\n\n  Continue? (Y/N) :");

    c = getchar();		/* Change for Lattice */
    c = toupper(c);
    if(c != 'Y')
       exit(200);
/*
        if (toupper(getchar()) != 'Y')
            exit(200);
*/
     printf("  Zeroing Drive..........");
     fflush(stdout);	
     reZERO();
     errorCHECK();

     printf("  Checking Drive Ready...");
     fflush(stdout);
     unitRDY();
     errorCHECK();


     printf("  Selecting Mode.........");
     fflush(stdout);
     modeSEL();
     errorCHECK();

     printf("  Formatting.............");
     fflush(stdout);
     doFORMAT();
     errorCHECK();
     printf("\n Format Complete.\n");
     Execute("wait 4",0,0);
}

void errorCHECK()    /* Check Status Byte and Report Error Data */
{
int count;

if (statin)
    {  
    if (statin == 8)
       printf("\n SCSI Device Busy Error\n");
    else 
       {
       readERROR();
       printf("\n Completion Status Error #%d:",statin);
       for (count = 0;count < 27 ;count ++) 
           if (inbuff[count])
               printf("\n Sense Error Byte #%d: %d",count,inbuff[count]);
       }
    Execute("wait 4",0,0);
    exit(700);
    }
printf("OK\n");
}

void readERROR()   /* Request Sense Command */
{
clearCMD();
clearIN();
cmdbuff[0] = 3;
cmdbuff[4] = 27;       /* Read all possible sense data */
scsi();
}

/*  
   future stuff eh dude?
clearBUFF(&buff,elements)    /  Clear Specified Buffer  /
int elements;
byte buff[elements];
{
int count;

while (count = 0; count < elements; count++)
    buff[count] = 0;
}
*/

getNumber(lower,upper)   /* get a number between -32k to 32k  */

int lower, upper;
{
char input[10];
int test = 0xffff;

while((test > upper) || (test < lower)){
      gets(input);
        test = atoi(input);
          if ((test > upper) || (test < lower))
             printf("\n  Bad Entry. Please try again  :");
      }
return test;
}



void reZERO()
{
    clearCMD();
    cmdbuff[0] = 1;
    scsi();
}    


void unitRDY()
{
    clearCMD();
    scsi();
}


void modeSEL()
{
    clearCMD();
    clearOUT();

    cmdbuff[0] = 21;
    cmdbuff[4] = 12;  /* parameter list length */

    outbuff[3] = 8;
    outbuff[10] = 2;  /* high byte of block size -512 bytes- */

    scsi();
}


void doFORMAT()
{

    clearCMD();
    clearOUT();

    cmdbuff[0] = 4;
    cmdbuff[4] = (byte) intrlv;

    scsi();   
}



void clearCMD()   /*   Clear command buffer   */
{
int count;

   for(count=0;count <= 10 ;count++)
       cmdbuff[count] = 0;

}


void clearOUT()      /*   Clear output buffer    */
{
int count;

  for(count=0;count <= 100;count++)
       outbuff[count] = 0;
}

 
void clearIN()       /*   Clear Input Data Buffer    */
{
int count;

   for(count = 0;count < 100;count++)
      inbuff[count] = 0;
}

void goodmorning()    /*wake up the controller*/
{
byte initiator = 128, target = (1 << address);
long count;
        
    *initCMD = 0;                            /*clear the controller chip*/
    *(initCMD + 2) = 0;
    *control = 0;
 
    for(count = 0; *control & BUSY; count++){  /*if bus is busy, wait*/
       if (count >= 100000){                /*wait for bus*/
           printf("\n  SCSI bus BUSY error.\n\n");   
           Execute("wait 4",0,0);
           exit(100);
           }
       }
 
    *data = initiator | target;                   /*load scsi addresses */
    *initCMD |= BUS;                         /*assert bus*/
 
    for(count = 0;count <60;count++);        /*wait 2 * 45 nanoseconds*/
 
    *initCMD |= SELECT;                      /*assert select*/
 
    for(count = 0; !(*control & BUSY); count++){
        if (count >= 100000){            /*wait for busy from controller*/
           printf("\n  No response from SCSI address #%d.\n\n",address);   
           Execute("wait 4",0,0);  
           exit(100);
           }
        }
    for(count = 0;count < 60;count++);
    *initCMD &= ~SELECT;                     /*deassert select*/
    for(count = 0;count < 60;count++);	   /* mod by Mike Lundberg */
}




void scsi()          /* send Command and handle I/O */
{
byte dataout = 0, datain = 1, cmdout = 2,
     instat = 3, msgin = 7;

    goodmorning();

    while (*control & BUSY){

       waitREQ();

       if (*control & COMMAND){                    /*cmd I/O?*/
           if (*control & MSG){                    /*message?*/
               if (*control & INPUT)              /*if message in*/
                   doIO(msgin,&msg);             /*read it..msg out invalid*/
           }

           else {                                 /*not msg..status or cmd*/
               if (*control & INPUT)
                   doIO(instat,&statin);          /*get status*/
               else
                   doIO(cmdout,cmdbuff);            /*send command*/
          }
       }

       else {                                    /*controller requests data I/O*/
           if (*control & INPUT)                    /* input or output? */
              doIO(datain,inbuff);                  /* input */
           else
              doIO(dataout,outbuff);                /* output */
       }
    }
}



void doIO(mode,buffer)        /* Read-Send whatever the controller desires */
byte mode, buffer[];
{
int index, count;

    *targetCMD = mode;                             /*what mode are we in*/

    for (index = 0;(*status & PHASE);index++){    /*while phase unchanged*/

         waitREQ();

         if (mode == 1 || mode == 3 || mode == 7)             /*if input*/
            *(buffer + index) = *data;       /*get data*/

         else                                /*if output*/
            *data = *(buffer + index);       /*write it*/

         *initCMD |= ACK;                  /*Perform ack*/

         while(*control & REQUEST);        /*wait for dropped req*/

         *initCMD &= ~ACK;                 /*drop ack*/

         for(count=0;count<4000;count++);  /*kill some time*/
    }
   *targetCMD = 0;
}

void waitREQ()           /* Wait for REQ to be asserted */
{
    while(!(*control & REQUEST))
        if(!(*control & BUSY) || !(*control & PHASE))
            return;
}
			
getADD(hex)
char *hex;
{
int low, high, address;

high = unhex(*hex);
low = unhex(*(hex+1));
address = (high*16 + low);
if (high < 0 || low < 0)
	address = -1;
return address;
}

void doBASE()
{
char hex[20];
int address = -1;
unsigned long base;

while (address < 0)
	{
	scanf("%s",hex);
	address = getADD(hex);
	if (address < 0)
		printf("\n  Bad Entry. Please try again  :");
	}
base = (address * 0x10000);
data += base;          /*pointer to SCSI data register*/
initCMD += base;       /*pointer to SCSI ICR register*/
targetCMD += base;     /*pointer to SCSI TCR register*/
control += base;       /*pointer to SCSI control register*/
status += base;        /*pointer to SCSI status register*/
}

unhex(ascii)
char ascii;
{
int value;
/*char tmp;*/

int c, tmp;

c = (int)ascii;
tmp = toupper(c);

/*tmp = toupper(ascii);*/
if (isalpha(tmp))
	value = tmp-55;
else if (isdigit(tmp))
	value = tmp - 48;
if (value > 15 || value < 0)
	value = -1;
return value;
}
