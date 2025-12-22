#include <exec/memory.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>
#include <clib/misc_protos.h>
#include <clib/timer_protos.h>
#include <pragmas/exec_sysbase_pragmas.h>
#include <pragmas/timer_pragmas.h>
#include <pragmas/misc_pragmas.h>
#include <pragmas/dos_pragmas.h>
#include <resources/misc.h>
#include <utility/tagitem.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
#include <dos/dostags.h>


#define ARGTMPL "W=WRITE/K,R=READ/K,V=VERIFY/S,E=ERASE/S,L=LOCK/S,HELP/S"


#define DATA_PORT *((STRPTR)0xBFE101)
#define DATA_DIR  *((STRPTR)0xBFE301)
#define AUX_PORT  *((STRPTR)0xBFD000)
#define AUX_DIR   *((STRPTR)0xBFD200)
#define INPUTS  0x00
#define OUTPUTS 0xFF


#define WR_LO   AUX_PORT&=0xFD
#define WR_HI   AUX_PORT|=0x02
#define RD_LO   AUX_PORT&=0xFE
#define RD_HI   AUX_PORT|=0x01
#define WREG_LO AUX_PORT&=0xFB
#define WREG_HI AUX_PORT|=0x04


#define ATMEL      0x1E

#define AT89C51    0x51
#define AT89C52    0x52

#define AT89C1051  0x11
#define AT89C1051U 0x12
#define AT89C2051  0x21
#define AT89C4051  0x41

#define AT_5v      0x05


// some global definitions
struct Library * DOSBase, * SysBase;
BPTR inp,outp;

// this will be filled with args
struct
{
	STRPTR write;
	STRPTR read;
	ULONG  verify;
	ULONG  erase;
	ULONG  lock;
	ULONG  help;
} ares = { NULL, NULL, 0, 0, 0, 0 };


// some common chip-related functons
struct
{
	ULONG addr;
	UBYTE found;
	UBYTE expected;
}	ferr;

UBYTE * buffer;
struct chipinfo * chippy;

struct chipinfo *	chip_Identify(void);
ULONG             chip_Read(void);
ULONG             chip_Erase(void);
ULONG             chip_Write(void);
ULONG             chip_Lock(void);

// specific functions for every supported chip
ULONG rdsig_at89cx051(void);
void  rdflash_at89cx051(UBYTE *,ULONG);
void  erase_at89cx051(void);
void  vrflash_at89cx051(UBYTE *,ULONG);
void  prgflash_at89cx051(UBYTE *,ULONG);
void  lock_at89cx051(void);

ULONG rdsig_at89c5x(void);
void  rdflash_at89c5x(UBYTE *,ULONG);
void  erase_at89c5x(void);
void  vrflash_at89c5x(UBYTE *,ULONG);
void  prgflash_at89c5x(UBYTE *,ULONG);
void  lock_at89c5x(void);


// chipinfo structure - contains all info about supported chips
struct chipinfo // definition
{
	ULONG id_mask;// id_mask==0 - end of chipinfo array
	ULONG id;// therefore, maximum id (signature) size - 4 bytes

	ULONG flashsize;// size of flash memory in bytes

	STRPTR name;

	ULONG (*rdsig)(void);
	void  (*rdflash)(UBYTE *,ULONG);
	void  (*erase)(void);
	void  (*vrflash)(UBYTE *,ULONG);
	void  (*prgflash)(UBYTE *,ULONG);
	void  (*lock)(void);
};

struct chipinfo known_chips[] = // actual description
{
	{
		0xFFFF0000,((ATMEL<<24)+(AT89C1051<<16)),
		1024,
		"at89c1051",
		rdsig_at89cx051,
		rdflash_at89cx051,
		erase_at89cx051,
		vrflash_at89cx051,
		prgflash_at89cx051,
		lock_at89cx051
	},

	{
		0xFFFF0000,((ATMEL<<24)+(AT89C1051U<<16)),
		1024,
		"at89c1051u",
		rdsig_at89cx051,
		rdflash_at89cx051,
		erase_at89cx051,
		vrflash_at89cx051,
		prgflash_at89cx051,
		lock_at89cx051
	},

	{
		0xFFFF0000,((ATMEL<<24)+(AT89C2051<<16)),
		2048,
		"at89c2051",
		rdsig_at89cx051,
		rdflash_at89cx051,
		erase_at89cx051,
		vrflash_at89cx051,
		prgflash_at89cx051,
		lock_at89cx051
	},

	{
		0xFFFF0000,((ATMEL<<24)+(AT89C4051<<16)),
		4096,
		"at89c4051",
		rdsig_at89cx051,
		rdflash_at89cx051,
		erase_at89cx051,
		vrflash_at89cx051,
		prgflash_at89cx051,
		lock_at89cx051
	},

	{
		0xFFFFFF00,((ATMEL<<24)+(AT89C51<<16)+(0xFF<<8)), // 12v programming
		4096,
		"at89c51",
		rdsig_at89c5x,
		rdflash_at89c5x,
		erase_at89c5x,
		vrflash_at89c5x,
		prgflash_at89c5x,
		lock_at89c5x
	},

	{
		0xFFFFFF00,((ATMEL<<24)+(AT89C52<<16)+(0xFF<<8)), // 12v programming
		8192,
		"at89c52",
		rdsig_at89c5x,
		rdflash_at89c5x,
		erase_at89c5x,
		vrflash_at89c5x,
		prgflash_at89c5x,
		lock_at89c5x
	},

	{
		0,0,0,"",NULL,NULL,NULL,NULL,NULL,NULL
	}
};





// some important functions
void main_job(void);
void print_help(void);


// misc.resource related
struct Library * MiscBase;

ULONG misc_Init(void);
void  misc_Free(void);


// timer related
struct Library * TimerBase;
struct MsgPort * tmrport;
struct timerequest * tmr_rq;

ULONG timer_Init(void);
void  timer_Free(void);
void  timer_Wait(ULONG);
void  timer_Start(ULONG);
void  timer_BadWaitEnd(void);
void  timer_WaitEnd(void);
void  timer_Prep(ULONG);



// hardware related
ULONG hard_Init(void);
void  hard_deInit(void);
void  hard_ShutDown(void);
void  hard_SelChipReg(UBYTE,UBYTE);
void  hard_Write(UBYTE);
UBYTE hard_Read(void);
void  hard_IO(UBYTE);



/* =-=-=-=-=-=-=-=-=-=-= **
**    main() function    **
** -=-=-=-=-=-=-=-=-=-=- */

__saveds main()
{
	struct RDArgs * argstru;
	ULONG misc_res=0,timer_res=0;
	
  SysBase = *((struct Library **)4L);
	if(DOSBase = OpenLibrary("dos.library",36))
	{
		Printf("\n%s\n\n",6+"$VER: Atmel programmer. © ® LVD, v 2.0 "__AMIGADATE__);

		inp=Input();
		outp=Output();

		if( !(argstru=ReadArgs(ARGTMPL,(LONG *)&ares,NULL)) )
		{
			Printf("aprg: Error in arguments! Try 'aprg ?' for possible args, 'aprg HELP' for help.\n");
		}
		else if( ares.help )
		{
			print_help();
    }
		else
		{
			misc_res=misc_Init();
			if( misc_res )
			{
				timer_res=timer_Init();
			}

			if( misc_res && timer_res )
			{
				main_job();// do main job
			}
		}

		if( timer_res ) timer_Free();
		if( misc_res ) misc_Free();
		if( argstru ) FreeArgs(argstru);

    CloseLibrary(DOSBase);
	}
	return 0;
}





/* =-=-=-=-=-=-=-=-=-=-=-= **
**    main job function    **
** -=-=-=-=-=-=-=-=-=-=-=- */

void main_job(void)
{
	UBYTE estr[5], * ystr="yes\n";
	ULONG nolock;

	buffer=NULL;

	if( !hard_Init() )
	{
		Printf("aprg: Bad or missing hardware!\n");
		hard_deInit();
		hard_ShutDown();
		return;
	}

  Flush(inp);
	Printf("Insert chip [enter]...\n");
	FGetC(inp);

	if( !(chippy=chip_Identify()) )
	{
		Printf("No chip or bad or unsupported chip!\n");
	}
	else
	{
		Printf("Found chip: %s, flash size: %ld\n\n",chippy->name,chippy->flashsize);

		if( !(buffer=(UBYTE *)AllocVec(chippy->flashsize,MEMF_CLEAR)) )
		{
			Printf("aprg: Can't allocate memory for buffer!\n");
		}
		else
		{

		// main sequence
		if( chip_Read() )
			if( chip_Erase() )
				if( chip_Write() )
					if( ares.lock )
					{
						Flush(inp);
						Printf("You're going to set lock on chip.\nProbably you won't be able to remove it after.\n");
						Printf("Refer to datasheet for such possibility.\nType 'yes[enter]' for continue.\n");
						FGets(inp,estr,5);

						for(nolock=0;nolock<5;nolock++)
						{
							if( (!ystr[nolock]) && (nolock<4) )
								break;

							if( estr[nolock]!=ystr[nolock] )
								break;
						}
					
						if( nolock!=5 )
						{
							Printf("No lock set!\n\n");
						}
						else
						{
							chip_Lock();
						}
					}
    }
	}

	if( buffer ) FreeVec(buffer);

	hard_deInit();

  Flush(inp);
	Printf("Remove chip [enter]...\n");
	FGetC(inp);

	hard_ShutDown();

}






/* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- **
**    functions for working with chips    **
** -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */

// some common functions
struct chipinfo * chip_Identify(void)
{
	struct chipinfo * curchip;

	curchip=known_chips;

	while( curchip->id_mask )
	{
		if( ( (*(curchip->rdsig))() & curchip->id_mask ) == curchip->id ) // try to read signature
		{
			return curchip;// found!
		}
		curchip++;// try next chip
	}

	return NULL;// found no (suitable) chips
}


// read procedure
ULONG chip_Read(void)
{
	ULONG success=1;
	BPTR file;

	if( ares.read!=NULL )
	{
		if( (file=Open(ares.read,MODE_NEWFILE))!=0 )
		{
			Printf("Reading flash...");Flush(outp);
			(*(chippy->rdflash))(buffer,chippy->flashsize);
			Printf(" Done!\n");
			if( chippy->flashsize!=Write(file,buffer,chippy->flashsize) )
			{
				Printf("aprg: Can't successfully write to file <%s>!\n",ares.read);
				success=0;
			}
			Close(file);
		}
		else
		{
			Printf("aprg: Can't open file <%s> for saving flash content!\n",ares.read);
			success=0;
		}
		Printf("\n");
	}
	return success;
}

// erase procedure
ULONG chip_Erase(void)
{
	ULONG success=1;
	ULONG temp;
	
  if( ares.erase!=0 )
	{
		Printf("Erasing chip...");Flush(outp);
		(*(chippy->erase))();
		Printf(" Done!\n");

		if( ares.verify!=0 ) // verify erasing
		{
			for(temp=0;temp<chippy->flashsize;temp++)
			{
				buffer[temp]=0xFF;
			}
			Printf("Verifying erase...");Flush(outp);
			(*(chippy->vrflash))(buffer,chippy->flashsize);
			if( ferr.addr==0xFFFFFFFF )
			{
				Printf(" All O.K.!\n");
			}
			else
			{
				Printf(" Failed!\nFirst err at %lx:",ferr.addr);
				Printf(" expected %lx, found %lx.\n",(ULONG)ferr.expected,(ULONG)ferr.found);
				success=0;
			}
		}
		Printf("\n");
	}
	return success;
}

// programming procedure
ULONG chip_Write(void)
{
	ULONG success=1;
	BPTR file;
	struct FileInfoBlock fib;
	
  if( ares.write!=NULL )
	{
		if( (file=Open(ares.write,MODE_OLDFILE))!=0 )
		{
			if( ExamineFH(file,&fib) )
			{
				if( fib.fib_Size>chippy->flashsize )
				{
					Printf("File <%s> (%ld bytes) is larger than flash memory size (%ld bytes)!\n",ares.write,fib.fib_Size,chippy->flashsize);
					success=0;
				}
				else
				{
					if( fib.fib_Size!=Read(file,buffer,fib.fib_Size) )
					{
						Printf("aprg: Can't successfully read from file <%s>!\n",ares.write);
						success=0;
					}
					else
					{
						Printf("Programming chip flash...");Flush(outp);
						(*(chippy->prgflash))(buffer,fib.fib_Size);
						Printf(" Done!\n");

						if( ares.verify!=0 )
						{
							Printf("Verifying program...");Flush(outp);
							(*(chippy->vrflash))(buffer,fib.fib_Size);
							if( ferr.addr==0xFFFFFFFF )
							{
								Printf(" All O.K.!\n");
							}
							else
							{
								Printf(" Failed!\nFirst err at $%lx:",ferr.addr);
								Printf(" expected $%lx, found $%lx.\n",(ULONG)ferr.expected,(ULONG)ferr.found);
								success=0;
							}
						}
					}
				}
			}
			else
			{
				Printf("aprg: Can't examine file <%s>!\n",ares.write);
				success=0;
			}
			Close(file);
		}
		else
		{
			Printf("aprg: Can't open file <%s> for reading flash content!\n",ares.write);
			success=0;
		}
		Printf("\n");
	}
	return success;
}

// setting lock procedure
ULONG chip_Lock(void)
{
	if( ares.lock!=0 )
	{
		Printf("Setting lock...");Flush(outp);
		(*(chippy->lock))();
		Printf(" Done!\n\n");
	}
	return 1;
}


// specific functions for every chip

// at89cx051
ULONG rdsig_at89cx051(void)
{
	ULONG signature=0;
	ULONG counter;

	hard_SelChipReg(1,3);
	hard_Write(0x90);// chip 1: PA - input

	hard_SelChipReg(1,1);
	hard_Write(0);
	hard_SelChipReg(1,2);
	hard_Write(0);// address - 0 (no conflicts with at89c51/52)

	hard_SelChipReg(0,2);
	hard_Write(0x02);// turn on chip

	hard_SelChipReg(0,1);
	hard_Write(0x82);
	hard_Write(0x02);// reset chip

	for(counter=0;counter<4;counter++)
	{
		hard_SelChipReg(1,0);
		signature=(signature<<8)+(ULONG)hard_Read();

		hard_SelChipReg(0,1);
		hard_Write(0x03);
		hard_Write(0x02);//pulse XTAL1 to increment addr
	}

	return signature;
}

void rdflash_at89cx051(UBYTE * from,ULONG bytecount)
{
	ULONG actualadr;

	hard_SelChipReg(1,3);
	hard_Write(0x90);// chip 1: PA - input

	hard_SelChipReg(0,2);
	hard_Write(0x02);// power on chip

	hard_SelChipReg(0,1);
	hard_Write(0xB2);
	hard_Write(0x32);// reset chip

	for(actualadr=0;actualadr<bytecount;actualadr++)
	{
		hard_SelChipReg(1,0);
		from[actualadr]=hard_Read();

		hard_SelChipReg(0,1);
		hard_Write(0x33);
		hard_Write(0x32);// pulse XTAL1 to increment addr
	}
}

void erase_at89cx051(void)
{
	hard_SelChipReg(1,3);
	hard_Write(0x90);// chip 1: PA - input

	hard_SelChipReg(0,2);
	hard_Write(0x02);// power on chip

	hard_SelChipReg(0,1);
	hard_Write(0x06);//0b00000110 - /PROG high
	hard_Write(0x46);//0b01000110 - raise Vpp to 12v

  Forbid();	//since any other task can make Forbid();while(1); or something like,
						//erase pulse can become VERY long, & this can damage chip.
						//so we make Forbid() then waiting in loop for timer request complete :-E

	hard_Write(0x44);//0b01000100 - begin /PROG pulse
	timer_Start(10*1000);// start waiting 10ms
	timer_BadWaitEnd();// wait
	hard_Write(0x46);//0b01000110 - end /PROG pulse

	Permit();

	timer_WaitEnd();// complete timer waiting

	timer_Wait(10*1000);// wait another 10ms
	
	
  hard_Write(0x06);// turn off +12v
}

void vrflash_at89cx051(UBYTE * from,ULONG bytecount)
{
	ULONG actualadr;

	ferr.addr=0xFFFFFFFF;

	hard_SelChipReg(1,3);
	hard_Write(0x90);// chip 1: PA - input

	hard_SelChipReg(0,2);
	hard_Write(0x02);// power on chip

	hard_SelChipReg(0,1);
	hard_Write(0xB2);
	hard_Write(0x32);// reset chip

	for(actualadr=0;actualadr<bytecount;actualadr++)
	{
		hard_SelChipReg(1,0);

		if( (ferr.expected=from[actualadr])!=(ferr.found=hard_Read()) )
		{
			ferr.addr=actualadr;
			return;
		}

		hard_SelChipReg(0,1);
		hard_Write(0x33);//pulse XTAL1 to increment addr
		hard_Write(0x32);
  }
}

void prgflash_at89cx051(UBYTE * from,ULONG bytecount)
{
	ULONG actualadr;

	hard_SelChipReg(1,3);
	hard_Write(0x90);// chip 1: PA - inputs

	hard_SelChipReg(0,2);
	hard_Write(0x02);// power on chip

	hard_SelChipReg(0,1);
	hard_Write(0xBA);
	hard_Write(0x3A);// reset chip

	hard_SelChipReg(1,3);
	hard_Write(0x80);// chip 1: PA - outputs

	hard_Write(0x7A);//0b01111010 - Raise Vpp to 12v

	for(actualadr=0;actualadr<bytecount;actualadr++)
	{
		hard_SelChipReg(1,0);
		hard_Write(from[actualadr]);

		hard_SelChipReg(0,1);

		Forbid();
    hard_Write(0x78);//0b01111000
		hard_Write(0x7A);//0b01111010 - pulse /PROG
		Permit();

		hard_SelChipReg(0,2);
		while( !(hard_Read()&0x80) ); // wait until prog cycle done

    hard_SelChipReg(0,1);
		hard_Write(0x7B);//pulse XTAL1 to increment addr
		hard_Write(0x7A);
	}

  hard_Write(0x3A);//turn off 12v

	hard_SelChipReg(1,3);
	hard_Write(0x90);// chip 1: PA - inputs

	hard_SelChipReg(0,1);
	hard_Write(0x80);// all pins to GND
	
  hard_SelChipReg(0,2);
	hard_Write(0x03);// power-off
	timer_Wait(1000);// small delay
	hard_Write(0x02);// power-on
}

void lock_at89cx051(void)
{
	hard_SelChipReg(1,3);
	hard_Write(0x90);// chip 1: PA - inputs

	hard_SelChipReg(0,2);
	hard_Write(0x02);// power on chip

	hard_SelChipReg(0,1);
	hard_Write(0xBE);//0b10111110 - prepare for 1st lock bit programming
	hard_Write(0x3E);//0b00111110

	hard_Write(0x7E);//0b01111110 - Raise Vpp to 12v

	Forbid();
	hard_Write(0x7C);//0b01111100
	hard_Write(0x7E);//0b01111110 - pulse /PROG
	Permit();

	timer_Wait(3*1000);// delay

  hard_Write(0x4E);//0b01001110 - 2nd bit programming

	Forbid();
	hard_Write(0x4C);
	hard_Write(0x4E);// pulse /PROG
	Permit();

	timer_Wait(3*1000);

  hard_Write(0x0E);// turn off 12v
}

// at89c5x
ULONG rdsig_at89c5x(void)
{
	ULONG signature=0;
	ULONG address;

	hard_SelChipReg(1,3);
	hard_Write(0x90);// chip 1: PA - inputs

	hard_SelChipReg(0,2);
	hard_Write(0x02);// turn on chip

	hard_SelChipReg(0,1);
	hard_Write(0x0A); //pb3 aka p2.7 - /enable = 1

	timer_Wait(50*1000); // quartz stabilization

	for(address=0x30;address<0x34;address++)
	{
		hard_SelChipReg(1,1);
		hard_Write(address&0xFF);
		hard_SelChipReg(1,2);
		hard_Write((address>>8)&0xFF);// write address

		hard_SelChipReg(0,1);
		hard_Write(0x02);// /enable = 0

		timer_Wait(20);

		hard_SelChipReg(1,0);
		signature=(signature<<8)+(ULONG)hard_Read();

		hard_SelChipReg(0,1);
		hard_Write(0x0A);
	}

	return signature;
}

void rdflash_at89c5x(UBYTE * from,ULONG bytecount)
{
	ULONG actualadr;

	hard_SelChipReg(1,3);
	hard_Write(0x90);

	hard_SelChipReg(0,2);
	hard_Write(0x02);

	hard_SelChipReg(0,1);
	hard_Write(0x3A); //pb3 aka p2.7 - /enable == 1

	timer_Wait(50*1000); // quartz stabilization

	for(actualadr=0;actualadr<bytecount;actualadr++)
	{
		hard_SelChipReg(1,1);
		hard_Write(actualadr&0xFF);
		hard_SelChipReg(1,2);
		hard_Write((actualadr>>8)&0xFF);
		hard_SelChipReg(0,1);
		hard_Write(0x32);

		timer_Wait(20);

		hard_SelChipReg(1,0);
		from[actualadr]=hard_Read();

		hard_SelChipReg(0,1);
		hard_Write(0x3A);
	}
}

void erase_at89c5x(void)
{
	hard_SelChipReg(1,3);
	hard_Write(0x90);

  hard_SelChipReg(0,2);
	hard_Write(0x02);

	hard_SelChipReg(0,1);
	hard_Write(0x06);//0b00000110 - ALE/PROG high

	timer_Wait(50*1000);

  hard_Write(0x46);//0b01000110 - raise Vpp to 12v

	timer_Wait(50*1000);

	Forbid();
	hard_Write(0x44);//0b01000100 - begin /PROG pulse
	timer_Start(10*1000);
	timer_BadWaitEnd();
	hard_Write(0x46);//0b01000110 - end /PROG pulse
	Permit();

	timer_WaitEnd();

	timer_Wait(50*1000);// this strange wait must be here, otherwise c52 won't erase (c51 will)

	hard_Write(0x06);// turn off +12v
}

void vrflash_at89c5x(UBYTE * from,ULONG bytecount)
{
	ULONG actualadr;

	ferr.addr=0xFFFFFFFF;
	
  hard_SelChipReg(1,3);
	hard_Write(0x90);

	hard_SelChipReg(0,2);
	hard_Write(0x02);

	hard_SelChipReg(0,1);
	hard_Write(0x3A); //pb3 aka p2.7 - /enable == 1

	timer_Wait(50*1000); // quartz stabilization

	for(actualadr=0;actualadr<bytecount;actualadr++)
	{
		hard_SelChipReg(1,1);
		hard_Write(actualadr&0xFF);
		hard_SelChipReg(1,2);
		hard_Write((actualadr>>8)&0xFF);
		hard_SelChipReg(0,1);
		hard_Write(0x32);

		timer_Wait(20);

		hard_SelChipReg(1,0);
		ferr.found=hard_Read();

    hard_SelChipReg(0,1);
		hard_Write(0x3A);

		if( (ferr.expected=from[actualadr])!=ferr.found )
		{
			ferr.addr=actualadr;
			return;
		}
	}
}

void prgflash_at89c5x(UBYTE * from,ULONG bytecount)
{
	ULONG actualadr;

	hard_SelChipReg(1,3);
	hard_Write(0x90);

	hard_SelChipReg(0,2);
	hard_Write(0x02);

	hard_SelChipReg(0,1);
	hard_Write(0x3A);// 0b00111010

	timer_Wait(50*1000);

  hard_SelChipReg(1,3);
	hard_Write(0x80);

  hard_SelChipReg(0,1);
	hard_Write(0x7A);// 0b01111010 - Vpp ON

	timer_Wait(20);
	
  for(actualadr=0;actualadr<bytecount;actualadr++)
	{
		hard_SelChipReg(1,1);
		hard_Write(actualadr&0xFF);
		hard_SelChipReg(1,2);
		hard_Write((actualadr>>8)&0xFF);
		hard_SelChipReg(1,0);
		hard_Write(from[actualadr]);

		timer_Wait(20);

		hard_SelChipReg(0,1);

		Forbid();
		hard_Write(0x78);// 0b01111000 - ALE/PROG
		hard_Write(0x7A);// 0b01111010
		Permit();

		hard_SelChipReg(0,2);
		while( !(hard_Read()&0x80) ); // wait until prog cycle done
  }

	timer_Wait(50*1000);
	
  hard_SelChipReg(0,1);
	hard_Write(0x3A);
}

void lock_at89c5x(void)
{
	hard_SelChipReg(1,3);
	hard_Write(0x90);

	hard_SelChipReg(0,2);
	hard_Write(0x02);

  hard_SelChipReg(0,1);
	hard_Write(0x3E);// 1st lockbit

	timer_Wait(50*1000);

	hard_Write(0x7E);// Vpp

	timer_Wait(20);

	Forbid();
	hard_Write(0x7C);
	hard_Write(0x7E);
	Permit();

	timer_Wait(3*1000);// wait while bit is programming

	hard_Write(0x4E);// 2nd lockbit

	timer_Wait(20);

	Forbid();
	hard_Write(0x4C);
	hard_Write(0x4E);
	Permit();

	timer_Wait(3*1000);

	// 3rd lockbit - no external prog execution - left unprogrammed

	hard_Write(0x0E);// Vpp off
}







/* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- **
**    hardware related functions    **
** -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */

ULONG	hard_Init(void)
// init & test hardware
{
	//configure amiga parallel port hardware
  hard_IO(INPUTS);
	WR_HI;
	RD_HI;
	WREG_LO;
  AUX_DIR|=0x07;	//make BUSY, SEL, POUT pins outputs

	//configure 8255 chips
	hard_SelChipReg(0,3);// chip 0: PA-output (not used), PB-output, PC0-3 - output, PC4-7 - input
	hard_Write(0x88);    // 0b10001000

	hard_SelChipReg(1,3);
	hard_Write(0x9B);

	hard_SelChipReg(0,0);
	hard_Write(0xA5);    //really doesn't matter: this port isn't used

	hard_SelChipReg(0,1);
	hard_Write(0x80);    //HV1=1 - Vpp tied to GND

	hard_SelChipReg(0,2);
	hard_Write(0x01);    //turn on green LED, power off

	hard_SelChipReg(1,3);
	hard_Write(0x80);
	
  hard_SelChipReg(1,0);
	hard_Write(0);
	hard_SelChipReg(1,1);
	hard_Write(0);
	hard_SelChipReg(1,2);
	hard_Write(0);       //all zeroes in chip 1


	//check if init ok: read back all values
	hard_SelChipReg(0,0);
	if( hard_Read()!=0xA5 ) return 0;

	hard_SelChipReg(0,1);
	if( hard_Read()!=0x80 ) return 0;

	hard_SelChipReg(0,2);
	if( (hard_Read()&0xF)!=0x1 ) return 0;// skip high nibble - configured as input

	hard_SelChipReg(1,0);
	if( hard_Read()!=0x00 ) return 0;

	hard_SelChipReg(1,1);
	if( hard_Read()!=0x00 ) return 0;

	hard_SelChipReg(1,2);
	if( hard_Read()!=0x00 ) return 0;

	return 1;
}

void hard_deInit(void)
//prepare for chip removing
{
	hard_SelChipReg(0,1);
	hard_Write(0x80);//HV1=1 - RST/Vpp tied to GND
  hard_SelChipReg(0,2);
	hard_Write(0x01);//turn off power, turn on green LED

	hard_SelChipReg(1,3);
	hard_Write(0x80);// chip1: all pins - outputs

	hard_SelChipReg(1,0);
	hard_Write(0);
	hard_SelChipReg(1,1);
	hard_Write(0);
	hard_SelChipReg(1,2);
	hard_Write(0);
}

void hard_ShutDown(void)
//shutdown hardware - after chip removing
{
	hard_SelChipReg(0,2);
	hard_Write(0x03);//turn off LEDs & power

	hard_SelChipReg(0xFF,0);// deselect chips: /CS=1
}


void hard_SelChipReg(UBYTE chipnum,UBYTE regnum)
// selects chip & reg by writing to flipflops
{
	UBYTE flipflops;

	if( chipnum<2 )
	{
		flipflops=(0x04<<chipnum)^0xFF;
	}
	else
	{
		flipflops=0xFF;
	}

	flipflops=(flipflops&0xFC)|(regnum&0x03);
	
  hard_IO(OUTPUTS);
	DATA_PORT=flipflops;
	WREG_HI;
	WREG_LO;
}

void hard_IO(UBYTE newmode)
{
	static UBYTE oldmode=1; // modes are either 0 or 0xff, so first init will occur always

	if( (newmode==INPUTS) || (newmode==OUTPUTS) )
	{
		if( oldmode!=newmode )
		{
			oldmode=newmode;
			DATA_DIR=newmode;
		}
	}
}

void hard_Write(UBYTE byte)
{
	hard_IO(OUTPUTS);
	DATA_PORT=byte;
	WR_LO;
	WR_HI;
}

UBYTE hard_Read(void)
{
	UBYTE read;
	hard_IO(INPUTS);
	RD_LO;
	read=DATA_PORT;
	RD_HI;
	return read;
}





/* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- **
**    functions for allocating parallel port    **
** -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */

ULONG misc_Init(void)
{
	STRPTR pportowner;
	
  MiscBase=OpenResource(MISCNAME);
	if( !MiscBase )
	{
		Printf("aprg: Can't open %s!\n",MISCNAME);
		return 0;
	}

	pportowner=AllocMiscResource(MR_PARALLELPORT,"aprg: Atmel programmer");
	if( pportowner )
	{
		Printf("aprg: Can't allocate parallel port - already owned by '%s'!\n",pportowner);
		return 0;
	}

	return 1;
}

void  misc_Free(void)
{
	FreeMiscResource(MR_PARALLELPORT);
}


/* =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- **
**    functions for working with timer    **
** -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= */

ULONG timer_Init(void)
{

	tmrport=CreateMsgPort();
	if( !tmrport )
	{
		Printf("aprg: Can't create msgport!\n");
		return 0;
	}

	tmr_rq=(struct timerequest *)CreateIORequest(tmrport,sizeof(struct timerequest));
	if( !tmr_rq )
	{
		Printf("aprg: Can't create IORequest!\n");
		DeleteMsgPort(tmrport);
		return 0;
	}

	if( OpenDevice(TIMERNAME,UNIT_MICROHZ,(struct IORequest *)tmr_rq,0) )
	{
		Printf("aprg: Can't open %s!\n",TIMERNAME);
		DeleteIORequest(tmr_rq);
		DeleteMsgPort(tmrport);
		return 0;
	}

	TimerBase=(struct Library *)tmr_rq->tr_node.io_Device;

	return 1;
}

void timer_Free(void)
{
	CloseDevice((struct IORequest *)tmr_rq);
	DeleteIORequest(tmr_rq);
	DeleteMsgPort(tmrport);
}

void timer_Wait(ULONG usecs)
{
	timer_Prep(usecs);

	DoIO( (struct IORequest *)tmr_rq );
}

void timer_Start(ULONG usecs)
{
	timer_Prep(usecs);

	SendIO( (struct IORequest *)tmr_rq );
}

void timer_BadWaitEnd(void)
// timer_WaitEnd() MUST be used after this function
{
	ULONG sigmask;
	
	sigmask=1<<(tmrport->mp_SigBit);

	while( !(SetSignal(0L,sigmask)&sigmask) );
}

void timer_WaitEnd(void)
{
	WaitIO( (struct IORequest *)tmr_rq );
}

void timer_Prep(ULONG usecs)
{
	ULONG us;

  us=usecs;
	if( us>999999 ) us=999999;// won't wait more than 1 sec

  tmr_rq->tr_node.io_Command = TR_ADDREQUEST;
	tmr_rq->tr_time.tv_secs    = 0;
	tmr_rq->tr_time.tv_micro   = us;
}




/* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= **
**    function that just prints help    **
** =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- */

void print_help(void)
{
	static char * helplines[] = {
" Short help:\n",
"\n",
"command line:\n",
" READ <filename>  - read previous contents of chip to file\n",
" WRITE <filename> - program chip with new data\n",
" VERIFY           - check programmed data\n",
" ERASE            - erase flash memory of chip\n",
" LOCK             - lock chip\n",
" HELP             - print this :)\n\n",
"You can specify several options at once. They will be processed in correct order:\n",
"READ,ERASE,WRITE,VERIFY,LOCK\n",
"No options specified will force just chip identification to be performed\n",
"\n",
"You can remove/insert chips while green LED is on\n",
"Red LED indicates that programming/etc. is in progress\n",
"\n",NULL };

	int i=0;

	while( helplines[i] )
	{
		Printf( helplines[i++] );
	}

}

