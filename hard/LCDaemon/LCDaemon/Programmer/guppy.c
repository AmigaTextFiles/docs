/*	(Tab size 4)	*/

/*	Grand Unified Parallel Port driver for LCDaemon	*/
#include <clib/exec_protos.h>
#include <clib/misc_protos.h>
#include <clib/expansion_protos.h>
#include <devices/timer.h>
#include <libraries/configvars.h>
#include <hardware/cia.h>
#include "lcd.h"

#include <resources/misc.h>	/*	Parallel port		*/
#include "mfc3bits.h"		/*	Multifacecard 3	*/
#include "pitbits.h"			/*	Multifacecard 2	*/

/*
** Exported to main driver
*/

STRPTR	lcd_alloc(struct lcdparams *);
void	lcd_free(void);
void	lcd_delayfor(ULONG);
void	lcd_putchar(UBYTE,BOOL,ULONG,ULONG);

/*
** Imported from driver
*/

extern STRPTR startup;	/*	If !=NULL , points to STARTUP parameter*/
extern struct timerequest *timereq;

/*
** Implementation
*/

struct Library *MiscBase=NULL;
extern struct CIA ciaa,ciab;
static STRPTR lcdaemonparname= "LCDaemon parallel port driver";

static BOOL portopen=FALSE,bitsopen=FALSE;
struct mfc3 *mfc3=NULL;
struct pit *pit=NULL;
UBYTE pitunit=1;

UBYTE kind=0;

/*	Allocate anything needed, optionally making use of *startup	*/
STRPTR lcd_alloc(struct lcdparams *param){
	struct ConfigDev *device;

	if(!startup){	/*	Supply default	*/
		startup="";
	}
	/*	If supplied, try to use the first letter of the startup parameter to guide the choice which port to use	*/
	switch(*startup++){
		default:
			startup--;	/*	If unknown, just autodetect	and undo the ++ in the switch()	*/

		case 'M':
		case 'm':
		/*	Check for Multifacecard 3	*/
		if(device=FindConfigDev(NULL,2092,18)){
			mfc3=(struct mfc3 *)((ULONG)(device->cd_BoardAddr)+MFC3_PIA_OFFSET);
			kind=1;
			return("Multifacecard III");
		}

		case 'L':
		case 'l':
		/*	Check for Multifacecard II	*/
		if((device=FindConfigDev(NULL,2092,16))||(device=FindConfigDev(NULL,2092,17))){
			kind=2;
			pit=(struct pit *)((ULONG)(device->cd_BoardAddr)+0x100);
			pit->pit_pcdr&=~0x50;
			pit->pit_pcddr|=0x50;
			if(startup){
				switch(*startup){
					case '0':
						pitunit=0;
						break;
					default:
						pitunit=1;
				}
			}else{
				pitunit=1;
	       }
			return("Multifacecard II");
		}

		case 'P':
		case 'p':
		/*	Fall back to parallel port	*/
		if(!(MiscBase=OpenResource("misc.resource"))) return(NULL);
		if(!(portopen=(BOOL)!AllocMiscResource(MR_PARALLELPORT,lcdaemonparname))) return(NULL);
		if(!(bitsopen=(BOOL)!AllocMiscResource(MR_PARALLELBITS,lcdaemonparname))) return(NULL);
		ciaa.ciaprb=(UBYTE)0x00;
		ciaa.ciaddrb=(UBYTE)0xff;		/*	Put data lines as output		*/
		ciab.ciapra&=~(UBYTE)0x07;
		ciab.ciaddra|=(UBYTE)0x07;		/*	Put control lines as output		*/
		kind=3;
		return("Parallel port");
	}
}

/*	Free anything allocated in lcd_alloc	*/
void lcd_free(void){

	/*	MFC2 : nothing to free	*/

	/*	MFC3 : nothing to free	*/

	/*	Amiga parallel port		*/
	if(bitsopen) FreeMiscResource(MR_PARALLELBITS);
	if(portopen) FreeMiscResource(MR_PARALLELPORT);
}

/****************************************************************************\
**	AmigaDOS Delay(), but using microseconds								**
\****************************************************************************/
void lcd_delayfor(ULONG micros){
	timereq->tr_node.io_Command=TR_ADDREQUEST;
//	if(micros>3000){
//		FPuts(Output(),"??");Flush(Output());
//		micros=1000;
//	}
	timereq->tr_time.tv_micro=micros%1000000;
	timereq->tr_time.tv_secs=micros/1000000;
//	FPuts(Output(),">");Flush(Output());
	DoIO((struct IORequest *)timereq);
//	FPuts(Output(),"<");Flush(Output());
}

/****************************************************************************\
**	Send code to LCD, with pause for LCD to comply							**
**																					**
**	Hardware:																		**
**																					**
**	Centronics				LCD												**
**	D0...D7			->		d0...d7											**
**	BUSY				->		Enable												**
**	POUT				->		Register Select									**
**	SEL				->		Enable 1											**
**																					**
\****************************************************************************/
void lcd_putchar(UBYTE code,BOOL data,ULONG micros,ULONG ctrlmask){
//	FPuts(Output(),"*");Flush(Output());
	switch(kind){
	case 1:
		/*	MFC3 PIA:
		BUSY	=	PA0
		POUT	=	PA1
		SEL	=	PA2
		+5V(14)	=	PA6
		DATA	=	PB
		*/

		Forbid();
		mfc3->mfc_pacr=mfc3->mfc_pbcr=0x0;	/*	Address data direction register	*/
		mfc3->mfc_pb=0xff;					/*	All data lines are outputs		*/
		mfc3->mfc_pa=0x47;					/*	Pin 14, and POUT,BUSY,SEL: output	*/
		mfc3->mfc_pacr=mfc3->mfc_pbcr=0x04;	/*	Output register, no interrupts	*/

		mfc3->mfc_pb=code;						/*	Put code on data lines		*/
		mfc3->mfc_pa=0x40;						/*	Disable BUSY and POUT		*/
		if(data){								/*	Adjust Register Select		*/
			mfc3->mfc_pa|=0x02;
		}
		Permit();

		lcd_delayfor(1);
		Forbid();
		if(ctrlmask&1){
			mfc3->mfc_pa|=0x01;					/*	Assert E0 line				*/
		}
		if(ctrlmask&2){
			mfc3->mfc_pa|=0x04;					/*	Assert E1 line				*/
		}
		Permit();

		lcd_delayfor(1);

		Forbid();
		mfc3->mfc_pa&=~0x05;					/*	Disable E after 1000 ns		*/
		Permit();	

		lcd_delayfor(micros);				/*	Wait while LCD processes...		*/

		break;
	case 2:
		if(pitunit){
			/*	Code for pit.device 1	*/
			/* BUSY=PC6 POUT=PC4	*/
			Forbid();
			pit->pit_pbddr=0xff;
			pit->pit_pcddr|=0x52;					/*	Damned pit.device ! Thief!	*/
			pit->pit_pbdr=code;						/*	Put code on data lines		*/
			pit->pit_pcdr&=~0x52;					/*	Disable SEL, BUSY and POUT		*/
			if(data){								/*	Adjust Register Select		*/
				pit->pit_pcdr|=0x10;
			}
			Permit();

			lcd_delayfor(1);

			Forbid();
			pit->pit_pcddr|=0x52;					/*	Damned pit.device ! Thief!	*/
			if(ctrlmask&1){
				pit->pit_pcdr|=0x40;					/*	Assert E line of controller 1 (BUSY)	*/
			}
			if(ctrlmask&2){
				pit->pit_pcdr|=0x02;					/*	Assert E line of controller 3 (SEL)	*/
			}
			Permit();

			lcd_delayfor(1);

			Forbid();
			pit->pit_pcddr|=0x52;					/*	Damned pit.device ! Thief!	*/
			pit->pit_pcdr&=~0x42;					/*	Disable E after 1000 ns		*/
			Permit();	

			lcd_delayfor(micros);				/*	Wait while LCD processes...		*/

//			pit->pit_pbddr=0x00;				/*	float D0-D7 again (saves power)	*/
		}else{
			/*	Code for pit.device 0	*/
			/* E=BUSY=PC7 RS=POUT=PC2	*/
			Forbid();
			pit->pit_paddr=0xff;
			pit->pit_pcddr|=0x85;					/*	Damned pit.device ! Thief!	*/
			pit->pit_padr=code;						/*	Put code on data lines		*/
			pit->pit_pcdr&=~0x85;					/*	Disable SEL, BUSY and POUT		*/
			if(data){								/*	Adjust Register Select		*/
				pit->pit_pcdr|=0x04;
			}
			Permit();

			lcd_delayfor(1);

			Forbid();
			pit->pit_pcddr|=0x85;					/*	Damned pit.device ! Thief!	*/
			if(ctrlmask&1){
				pit->pit_pcdr|=0x80;					/*	Assert E line	(BUSY)	*/
			}
			if(ctrlmask&2){
				pit->pit_pcdr|=0x01;					/*	Assert E line	(SEL)	*/
			}
			Permit();

			lcd_delayfor(1);

			Forbid();
			pit->pit_pcddr|=0x85;					/*	Damned pit.device ! Thief!	*/
			pit->pit_pcdr&=~0x81;					/*	Disable E after 1000 ns		*/
			Permit();	

			lcd_delayfor(micros);				/*	Wait while LCD processes...		*/

			pit->pit_paddr=0x00;				/*	float D0-D7 again (saves power)	*/
		}
		break;
	case 3:
		ciaa.ciaddrb=0xff;					/*	Parallel lines as output		*/
		ciaa.ciaprb=code;					/*	Put code on parallel data lines	*/
		if(!data){
			ciab.ciapra&=~((UBYTE)0x02);	/*	Data=0	->	RS=1				*/
		} else {
			ciab.ciapra|=(UBYTE)0x02;		/*	Data=1	->	RS=1				*/
		}
		lcd_delayfor(1);

		if(ctrlmask&1){
			ciab.ciapra|=(UBYTE)0x01;			/*	Assert E line	(BUSY)				*/
		}
		if(ctrlmask&2){
			ciab.ciapra|=(UBYTE)0x04;			/*	Assert E line	(SEL)				*/
		}

		lcd_delayfor(1);

		ciab.ciapra&=~((UBYTE)0x05);		/*	Disable E after 1000 ns			*/
	
		lcd_delayfor(micros);				/*	Wait while LCD processes...		*/

		/*	ciaa.ciaddrb=0x00;*/					/*	float D0-D7 again (saves power)	*/
	default:
	}
}

