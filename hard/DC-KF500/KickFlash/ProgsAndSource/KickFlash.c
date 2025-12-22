/* Routines for using the Kickstart-FlashROM programmer board

 Hardware and software design by Redskull @ Digital Corruption
 
  Flash algorithms developed using material found on AMD's website
  
*/


#include <stdio.h>
#include <exec/types.h>
#include <clib/dos_protos.h>
#include <clib/exec_protos.h>


BOOL WRITE(void);
BOOL ERASE(void);

UWORD far *KICK;

BPTR myfh1;
BPTR myfh2;
BPTR myfh3;

void main(int argc, char *argv[])
{
	int actual=0;
	
	APTR BlockC;
	
	if (argc==2)
	{ 							/* was a kickstart filename passed to the program ? */
		
		if(BlockC=AllocMem(0x80000,0))
				{ /* alloc a block to load our kick image to */
					
					if(myfh3=Open(argv[1],MODE_OLDFILE)) /* open the filename passed to the program */
					{
						
						actual= Read(myfh3,BlockC,0x80000); /* read 512k worth of kickstart image */
						
						if (actual==0x80000)
							{						
							KICK=(UWORD*)BlockC; /* start of kickstart image in memory */

							Disable();	/* stop multi-tasking */

							if (ERASE())	/*	erase the required sectors in the flash chips*/
								{
									printf(" Kickstart erased successfully\n");

									if (WRITE())	/* write the kickstart image */
									{
										printf(" Kickstart image written successfully\n");
									}
									else
									{
										printf(" Kickstart image write failed!!!\n");

									}
								}
							else
								{
									printf(" Kickstart erase failed!!!\n");
								}

							Enable(); /* re-enable multitasking */
							}

						else printf("Incorrect file length read, must be 0x80000\n");		
					Close(myfh3);
					}
					
				FreeMem(BlockC,0x80000);
				}
	}
	
	else printf("usage: Kickflash filename\n"); /* you didn't specify a filname to load dummy! */
}

