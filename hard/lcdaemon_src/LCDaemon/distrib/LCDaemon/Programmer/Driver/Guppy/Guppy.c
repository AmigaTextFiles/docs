/*
**	Grand Unified Parallel Port driver for LCDaemon V2.2+
*/

#include </Amiga.h>
#pragma header

#include "//lcd.h"	//	for struct lcdparams *

#include "RegisterA4.h"
#include <resources/misc.h>	/*	Parallel port		*/
#include <libraries/expansion.h>
#include "mfc3bits.h"		/*	Multifacecard 3	*/
#include "pitbits.h"		/*	Multifacecard 2	*/
#include "libraries/LCDDriverBase.h"
#include "libraries/LCDDriverMethod.h"
#include "hardware/cia.h"

extern struct CIA ciaa,ciab;
struct MiscBase		*MiscBase			=	NULL;
struct ExpansionBase	*ExpansionBase	=	NULL;

#include "library_version.h"

char versiontag[]	=	"\0" VERSTAG;
char Copyright[]		=	"© 1997-98 Hendrik De Vloed, VOMIT, inc.";

struct PrivateData {
	struct Library *MiscBase;
	struct Library *ExpansionBase;
	BOOL portopen,bitsopen;
	struct mfc3 *mfc3;
	struct pit *pit;
	UBYTE pitunit;
	UBYTE kind;
	STRPTR	name;
	struct lcdparams	*m_lcdpar;
	STRPTR	m_startup;
	struct timerequest	*m_timereq;
};

STRPTR AllocLCD(
	register __a0 struct lcdparams *lcdpar_a0,
	register __a1 STRPTR startup_a1,
	register __a2 struct timerequest *timereq_a2,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct lcdparams *lcdpar=lcdpar_a0;
	STRPTR startup=startup_a1;
	struct timerequest *timereq=timereq_a2;
	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;
/*	struct PrivateData &Private=*(struct PrivateData *)LCDDriverBase->lcddrvb_PrivateData;*/
	struct ConfigDev *device;
	static char *parportname="Parallel port";
	struct PrivateData *pPrivate;

	StoreA4();
	GetBaseReg();
	InitModules();

	//	Allocate a private handle
	if(pPrivate=(struct PrivateData *)AllocVec(sizeof(struct PrivateData),MEMF_CLEAR|MEMF_PUBLIC)){
		//	Store the incoming parameters in the private handle
	
		pPrivate->m_startup=startup;
		pPrivate->m_timereq=timereq;
		pPrivate->m_lcdpar=lcdpar;
	
		pPrivate->portopen=pPrivate->bitsopen=0;
		pPrivate->MiscBase=pPrivate->ExpansionBase=NULL;
		pPrivate->mfc3=NULL;
		pPrivate->pit=NULL;
		pPrivate->pitunit=0;
		pPrivate->kind=0;
	
		if(ExpansionBase=(struct ExpansionBase*)OpenLibrary(EXPANSIONNAME,37L)){
	
			pPrivate->ExpansionBase=(struct Library *)ExpansionBase;
		
			if(!pPrivate->m_startup){
				pPrivate->m_startup="";
			}
			/*	If supplied, try to use the first letter of the startup parameter to guide the choice which port to use	*/
			switch(*((pPrivate->m_startup)++)){
				default:
					pPrivate->m_startup--;	/*	If unknown, just autodetect	and undo the ++ in the switch()	*/
		
				case 'M':
				case 'm':
				/*	Check for Multifacecard 3	*/
				if(device=FindConfigDev(NULL,2092,18)){
					pPrivate->mfc3=(struct mfc3 *)((ULONG)(device->cd_BoardAddr)+MFC3_PIA_OFFSET);
					pPrivate->kind=1;
					pPrivate->name="Multifacecard III";
					goto success;
				}
		
				case 'L':
				case 'l':
				/*	Check for Multifacecard II	*/
				if((device=FindConfigDev(NULL,2092,16))||(device=FindConfigDev(NULL,2092,17))){
					pPrivate->kind=2;
					pPrivate->pit=(struct pit *)((ULONG)(device->cd_BoardAddr)+0x100);
					pPrivate->pit->pit_pcdr&=~0x50;
					pPrivate->pit->pit_pcddr|=0x50;
					if(pPrivate->m_startup){
						switch(*(pPrivate->m_startup)){
							case '0':
								pPrivate->pitunit=0;
								break;
							default:
								pPrivate->pitunit=1;
						}
					}else{
						pPrivate->pitunit=1;
			       }
					pPrivate->name="Multifacecard II";
					goto success;
				}
		
				case 'P':
				case 'p':
				/*	Fall back to parallel port	*/
				if(pPrivate->MiscBase=OpenResource("misc.resource")){
					MiscBase=(struct MiscBase *)pPrivate->MiscBase;
					if(pPrivate->portopen=(BOOL)!AllocMiscResource(MR_PARALLELPORT,parportname)){
						if(pPrivate->bitsopen=(BOOL)!AllocMiscResource(MR_PARALLELBITS,parportname)){
							ciaa.ciaprb=(UBYTE)0x00;
							ciaa.ciaddrb=(UBYTE)0xff;		/*	Put data lines as output		*/
							ciab.ciapra&=~(UBYTE)0x07;
							ciab.ciaddra|=(UBYTE)0x07;		/*	Put control lines as output		*/
							pPrivate->kind=3;

							pPrivate->name=parportname;
							goto success;
						}
						FreeMiscResource(MR_PARALLELPORT);
					}
				}
			}
			CloseLibrary(pPrivate->ExpansionBase);
		}
		FreeVec(pPrivate);
	}
	pPrivate=NULL;
success:
	RestoreA4();
	return((APTR)pPrivate);
}

VOID FreeLCD(
	register __a0 APTR hndl_a0,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
/*	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;*/
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	StoreA4();
	GetBaseReg();

	if(hndl_a0){
		if(Private.bitsopen)FreeMiscResource(MR_PARALLELBITS);
		if(Private.portopen)FreeMiscResource(MR_PARALLELPORT);
		if(Private.ExpansionBase)CloseLibrary(Private.ExpansionBase);
		FreeVec(&Private)
	}
	CleanupModules();
	RestoreA4();
}

ULONG LCDPreMessage(
	register __a0 APTR hndl_a0,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
/*	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;*/
	return 0;
}

ULONG LCDPostMessage(
	register __a0 APTR hndl_a0,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
/*	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;*/
	return 0;
}

ULONG LCDDelayFor(
	register __a0 APTR hndl_a0,
	register __d0 ULONG micros,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
/*	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;*/
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;

	StoreA4();
	GetBaseReg();

	Private.m_timereq->tr_node.io_Command=TR_ADDREQUEST;
	Private.m_timereq->tr_time.tv_micro=micros%1000000;
	Private.m_timereq->tr_time.tv_secs=micros/1000000;
	DoIO((struct IORequest *)Private.m_timereq);

	RestoreA4();
	return 0;
}

STRPTR LCDDriverName(
	register __a0 APTR hndl_a0,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;

	return Private.name;
}

ULONG LCDPutChar(
	register __a0 APTR hndl_a0,
	register __d0 UBYTE code_d0,
	register __d1 BOOL data_d1,
	register __d2 ULONG micros_d2,
	register __d3 ULONG ctrlmask_d3,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	UBYTE code=code_d0;
	BOOL data=data_d1;
	ULONG micros=micros_d2;
	ULONG ctrlmask=ctrlmask_d3;

	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;

	switch(Private.kind){
	case 1:
		/*	MFC3 PIA:
		BUSY	=	PA0
		POUT	=	PA1
		SEL	=	PA2
		+5V(14)	=	PA6
		DATA	=	PB
		*/

		Forbid();
		Private.mfc3->mfc_pacr=Private.mfc3->mfc_pbcr=0x0;	/*	Address data direction register	*/
		Private.mfc3->mfc_pb=0xff;					/*	All data lines are outputs		*/
		Private.mfc3->mfc_pa=0x47;					/*	Pin 14, and POUT,BUSY,SEL: output	*/
		Private.mfc3->mfc_pacr=Private.mfc3->mfc_pbcr=0x04;	/*	Output register, no interrupts	*/

		Private.mfc3->mfc_pb=code;						/*	Put code on data lines		*/
		Private.mfc3->mfc_pa=0x40;						/*	Disable BUSY and POUT		*/
		if(data){								/*	Adjust Register Select		*/
			Private.mfc3->mfc_pa|=0x02;
		}
		Permit();

		LCDDelayFor(&Private,1,LCDDriverBase);
		Forbid();
		if(ctrlmask&1){
			Private.mfc3->mfc_pa|=0x01;					/*	Assert E0 line				*/
		}
		if(ctrlmask&2){
			Private.mfc3->mfc_pa|=0x04;					/*	Assert E1 line				*/
		}
		Permit();

		LCDDelayFor(&Private,1,LCDDriverBase);

		Forbid();
		Private.mfc3->mfc_pa&=~0x05;					/*	Disable E after 1000 ns		*/
		Permit();	

		LCDDelayFor(&Private,micros,LCDDriverBase);		/*	Wait while LCD processes...		*/

		break;
	case 2:
		if(Private.pitunit){
			/*	Code for pit.device 1	*/
			/* BUSY=PC6 POUT=PC4	*/
			Forbid();
			Private.pit->pit_pbddr=0xff;
			Private.pit->pit_pcddr|=0x52;					/*	Damned pit.device ! Thief!	*/
			Private.pit->pit_pbdr=code;						/*	Put code on data lines		*/
			Private.pit->pit_pcdr&=~0x52;					/*	Disable SEL, BUSY and POUT		*/
			if(data){								/*	Adjust Register Select		*/
				Private.pit->pit_pcdr|=0x10;
			}
			Permit();

			LCDDelayFor(&Private,1,LCDDriverBase);

			Forbid();
			Private.pit->pit_pcddr|=0x52;					/*	Damned pit.device ! Thief!	*/
			if(ctrlmask&1){
				Private.pit->pit_pcdr|=0x40;					/*	Assert E line of controller 1 (BUSY)	*/
			}
			if(ctrlmask&2){
				Private.pit->pit_pcdr|=0x02;					/*	Assert E line of controller 3 (SEL)	*/
			}
			Permit();

			LCDDelayFor(&Private,1,LCDDriverBase);

			Forbid();
			Private.pit->pit_pcddr|=0x52;					/*	Damned pit.device ! Thief!	*/
			Private.pit->pit_pcdr&=~0x42;					/*	Disable E after 1000 ns		*/
			Permit();	

			LCDDelayFor(&Private,micros,LCDDriverBase);		/*	Wait while LCD processes...		*/

//			pit->pit_pbddr=0x00;				/*	float D0-D7 again (saves power)	*/
		}else{
			/*	Code for pit.device 0	*/
			/* E=BUSY=PC7 RS=POUT=PC2	*/
			Forbid();
			Private.pit->pit_paddr=0xff;
			Private.pit->pit_pcddr|=0x85;					/*	Damned pit.device ! Thief!	*/
			Private.pit->pit_padr=code;						/*	Put code on data lines		*/
			Private.pit->pit_pcdr&=~0x85;					/*	Disable SEL, BUSY and POUT		*/
			if(data){								/*	Adjust Register Select		*/
				Private.pit->pit_pcdr|=0x04;
			}
			Permit();

			LCDDelayFor(&Private,1,LCDDriverBase);

			Forbid();
			Private.pit->pit_pcddr|=0x85;					/*	Damned pit.device ! Thief!	*/
			if(ctrlmask&1){
				Private.pit->pit_pcdr|=0x80;					/*	Assert E line	(BUSY)	*/
			}
			if(ctrlmask&2){
				Private.pit->pit_pcdr|=0x01;					/*	Assert E line	(SEL)	*/
			}
			Permit();

			LCDDelayFor(&Private,1,LCDDriverBase);

			Forbid();
			Private.pit->pit_pcddr|=0x85;					/*	Damned pit.device ! Thief!	*/
			Private.pit->pit_pcdr&=~0x81;					/*	Disable E after 1000 ns		*/
			Permit();	

			LCDDelayFor(&Private,micros,LCDDriverBase);	/*	Wait while LCD processes...		*/

			Private.pit->pit_paddr=0x00;				/*	float D0-D7 again (saves power)	*/
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
		LCDDelayFor(&Private,1,LCDDriverBase);

		if(ctrlmask&1){
			ciab.ciapra|=(UBYTE)0x01;			/*	Assert E line	(BUSY)				*/
		}
		if(ctrlmask&2){
			ciab.ciapra|=(UBYTE)0x04;			/*	Assert E line	(SEL)				*/
		}

		LCDDelayFor(&Private,1,LCDDriverBase);

		ciab.ciapra&=~((UBYTE)0x05);		/*	Disable E after 1000 ns			*/
	
		LCDDelayFor(&Private,micros,LCDDriverBase);	/*	Wait while LCD processes...		*/

		/*	ciaa.ciaddrb=0x00;*/					/*	float D0-D7 again (saves power)	*/
	default:
	}

	return 0;	/*	Retval unused for now	*/
}

VOID LCDVisual(
	register __a0 APTR hndl_a0,
	register __d0 ULONG backlight_d0,
	register __d1 ULONG contrast_d1,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	/*	Do nothing for the parallel port driver	*/
}

ULONG LCDMethod(
	register __a0 APTR hndl_a0,
	register __d0 ULONG method_d0,
	register __a1 APTR param_a1,
	register __a6 struct LCDDriverBase *LCDDriverBase_a6
){
	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	APTR	hndl=hndl_a0;
	ULONG	method=method_d0;
	APTR	param=param_a1;

	switch(method){
	case	LCDOM_LIBVERSION:
		*(ULONG *)param=22L;	/*	This is the LCDaemon compliance level, not the (dollar)VER value	*/
		return	LCDOMERR_OK;
		break;
	/*	No user port necessary	*/
	default:
		return	LCDOMERR_UNKNOWN;
	}

}

