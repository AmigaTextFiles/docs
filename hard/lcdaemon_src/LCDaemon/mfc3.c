/****************************************************************************\
**	Multifacecard 3 driver © 1996 VOMIT, inc.								**
\****************************************************************************/
#include <proto/exec.h>
#include <proto/misc.h>
#include <proto/expansion.h>
#include <devices/timer.h>
#include <resources/misc.h>
#include <libraries/configvars.h>
#include "lcd.h"
#include "mfc3bits.h"
#define MINDELAY	80			/* delay for device to complete request */

struct mfc3 *mfc3=NULL;
extern struct timerequest *timereq;
struct ConfigDev *device;
extern char *startup;
BOOL portopen=FALSE,bitsopen=FALSE;

/****************************************************************************\
**	Allocate everything needed for port access								**
**																			**
**	Return 0 for success.													**
\****************************************************************************/
long lcd_alloc(struct lcdparams *param){
	BOOL success=FALSE;
/*	if(startup){
		switch(*startup){
			case '0':
				pitunit=0;
				break;
			case '1':
			default:
		}
	}*/
	if(device=FindConfigDev(NULL,2092,18)){
		mfc3=(struct mfc3 *)((ULONG)(device->cd_BoardAddr)+MFC3_PIA_OFFSET);
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

/*	MFC3 PIA:
	BUSY	=	PA0
	POUT	=	PA1
	+5V(14)	=	PA6
	DATA	=	PB
*/
	Forbid();
	mfc3->mfc_pacr=mfc3->mfc_pbcr=0x0;	/*	Address data direction register	*/
	mfc3->mfc_pb=0xff;					/*	All data lines are outputs		*/
	mfc3->mfc_pa=0x43;					/*	Pin 14, and POUT,BUSY: output	*/
	mfc3->mfc_pacr=mfc3->mfc_pbcr=0x04;	/*	Output register, no interrupts	*/

	mfc3->mfc_pb=code;						/*	Put code on data lines		*/
	mfc3->mfc_pa=0x40;						/*	Disable BUSY and POUT		*/
	if(data){								/*	Adjust Register Select		*/
		mfc3->mfc_pa|=0x02;
	}
	Permit();

	lcd_delayfor(1);
	Forbid();
	mfc3->mfc_pa|=0x01;						/*	Assert E line				*/
	Permit();

	lcd_delayfor(1);

	Forbid();
	mfc3->mfc_pa&=~0x01;					/*	Disable E after 1000 ns		*/
	Permit();	

	lcd_delayfor(micros);				/*	Wait while LCD processes...		*/

/*		pit->pit_pbddr=0x00;				/*	float D0-D7 again (saves power)	*/

}
