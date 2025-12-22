/****************************************************************************\
**																			**
\****************************************************************************/
#include <proto/exec.h>
#include <proto/misc.h>
#include <proto/expansion.h>
#include <devices/timer.h>
#include <resources/misc.h>
#include <libraries/configvars.h>
#include "pitbits.h"
#include "lcd.h"
#define MINDELAY	80			/* delay for device to complete request */

struct pit *pit=NULL;
extern struct timerequest *timereq;
struct ConfigDev *device;
extern char *startup;
int pitunit=0;
BOOL portopen=FALSE,bitsopen=FALSE;

/****************************************************************************\
**	Allocate everything needed for port access								**
**																			**
**	Return 0 for success.													**
\****************************************************************************/
long lcd_alloc(struct lcdparams *param){
	BOOL success=FALSE;
	if(startup){
		switch(*startup){
			case '0':
				pitunit=0;
				break;
			case '1':
			default:
				pitunit=1;
		}
	}
	if((device=FindConfigDev(NULL,2092,16))||(device=FindConfigDev(NULL,2092,17))||(device=FindConfigDev(NULL,2092,18))){
		pit=(struct pit *)((ULONG)(device->cd_BoardAddr)+0x100);
		pit->pit_pcdr&=~0x50;
		pit->pit_pcddr|=0x50;
		success=TRUE;
	}
	return(success);
}

/****************************************************************************\
**	Free everything allocated.												**
**																			**
**	lcd_free() is called even when lcd_alloc() failed, to allow for			**
**	freeing the successful allocations in lcd_alloc()						**
\****************************************************************************/
void lcd_free(void){
}

/****************************************************************************\
**	AmigaDOS Delay(), but using microseconds								**
\****************************************************************************/
void lcd_delayfor(int micros){
	timereq->tr_node.io_Command=TR_ADDREQUEST;
	timereq->tr_time.tv_micro=micros%1000000;
	timereq->tr_time.tv_secs=micros/1000000;
	DoIO((struct IORequest *)timereq);	
}

/****************************************************************************\
**	Send code to LCD, with pause for LCD to comply							**
**																			**
**	Hardware:																**
**																			**
**	Centronics			LCD													**
**	D0...D7		->		d0...d7												**
**	BUSY		->		Enable												**
**	POUT		->		Register Select										**
**																			**
\****************************************************************************/
void lcd_putchar(UBYTE code,BOOL data,long micros){
	if(micros<MINDELAY) micros=MINDELAY;

	if(pitunit){
/*	Code for pit.device 1	*/
/* BUSY=PC6 POUT=PC4	*/
		Forbid();
		pit->pit_pbddr=0xff;
		pit->pit_pcddr|=0x50;					/*	Damned pit.device ! Thief!	*/
		pit->pit_pbdr=code;						/*	Put code on data lines		*/
		pit->pit_pcdr&=~0x50;					/*	Disable BUSY and POUT		*/
		if(data){								/*	Adjust Register Select		*/
			pit->pit_pcdr|=0x10;
		}
		Permit();

		lcd_delayfor(1);

		Forbid();
		pit->pit_pcddr|=0x50;					/*	Damned pit.device ! Thief!	*/
		pit->pit_pcdr|=0x40;					/*	Assert E line				*/
		Permit();

		lcd_delayfor(1);

		Forbid();
		pit->pit_pcddr|=0x50;					/*	Damned pit.device ! Thief!	*/
		pit->pit_pcdr&=~0x40;					/*	Disable E after 1000 ns		*/
		Permit();	

		lcd_delayfor(micros);				/*	Wait while LCD processes...		*/

		pit->pit_pbddr=0x00;				/*	float D0-D7 again (saves power)	*/

	}else{
/*	Code for pit.device 0	*/
/* E=BUSY=PC7 RS=POUT=PC2	*/
		Forbid();
		pit->pit_paddr=0xff;
		pit->pit_pcddr|=0x84;					/*	Damned pit.device ! Thief!	*/
		pit->pit_padr=code;						/*	Put code on data lines		*/
		pit->pit_pcdr&=~0x84;					/*	Disable BUSY and POUT		*/
		if(data){								/*	Adjust Register Select		*/
			pit->pit_pcdr|=0x04;
		}
		Permit();

		lcd_delayfor(1);

		Forbid();
		pit->pit_pcddr|=0x84;					/*	Damned pit.device ! Thief!	*/
		pit->pit_pcdr|=0x80;					/*	Assert E line				*/
		Permit();

		lcd_delayfor(1);

		Forbid();
		pit->pit_pcddr|=0x84;					/*	Damned pit.device ! Thief!	*/
		pit->pit_pcdr&=~0x80;					/*	Disable E after 1000 ns		*/
		Permit();	

		lcd_delayfor(micros);				/*	Wait while LCD processes...		*/

		pit->pit_paddr=0x00;				/*	float D0-D7 again (saves power)	*/
	}
}
