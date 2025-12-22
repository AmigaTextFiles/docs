
; Maxon C++ Compiler
; Work:MCPP4.0_PRO/demo/LCDaemon/DriverLib/Guppy/Guppy.c


	XREF	_RestoreA4
	XREF	_StoreA4
	XREF	_GetBaseReg
	XREF	_CleanupModules
	XREF	_InitModules
	XREF	_FreeMiscResource
	XREF	_AllocMiscResource
	XREF	_FindConfigDev
	XREF	_FreeVec
	XREF	_AllocVec
	XREF	_OpenLibrary
	XREF	_OpenResource
	XREF	_DoIO
	XREF	_CloseLibrary
	XREF	_Permit
	XREF	_Forbid
	XREF	_ciaa
	XREF	_ciab

	SECTION ":0",CODE


;STRPTR AllocLCD(
	XDEF	_AllocLCD
_AllocLCD
L52	EQU	-$30
	link	a5,#L52+8
L53	EQU	$880
	movem.l	d7/a3,-(a7)
;	struct lcdparams *lcdpar=lcdpar_a0;
	move.l	a0,-4(a5)
;	STRPTR startup=startup_a1;
	move.l	a1,-$8(a5)
;	struct timerequest *timereq=timereq_a2;
	move.l	a2,-$C(a5)
;	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;
	move.l	a6,-$10(a5)
;	StoreA4();
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_StoreA4
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
;	GetBaseReg();
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_GetBaseReg
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
;	InitModules();
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_InitModules
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
;	if(pPrivate=(struct PrivateData *)AllocVec(sizeof(struct PrivateDa
	move.l	#$10001,-(a7)
	pea	$26.w
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_AllocVec
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	addq.l	#$8,a7
	move.l	d0,-$18(a5)
	beq	L19
;sizeof(struct Pri
;		pPrivate->m_startup=startup;
	move.l	-$18(a5),a3
	move.l	-$8(a5),$1E(a3)
;		pPrivate->m_timereq=timereq;
	move.l	-$C(a5),$22(a3)
;		pPrivate->m_lcdpar=lcdpar;
	move.l	-4(a5),$1A(a3)
;		pPrivate->portopen=pPrivate->bitsopen=0;
	clr.w	$A(a3)
	move.l	a3,-$24(a5)
	move.l	-$18(a5),a3
	move.l	a0,-$1C(a5)
	move.l	-$24(a5),a0
	move.w	$A(a0),$8(a3)
	move.l	-$1C(a5),a0
;		pPrivate->MiscBase=pPrivate->ExpansionBase=NULL;
	move.l	-$18(a5),a3
	clr.l	4(a3)
	move.l	a2,-$28(a5)
	move.l	a3,a2
	move.l	4(a3),(a2)
	move.l	-$28(a5),a2
;		pPrivate->mfc3=NULL;
	clr.l	$C(a3)
;		pPrivate->pit=NULL;
	clr.l	$10(a3)
;		pPrivate->pitunit=0;
	clr.b	$14(a3)
;		pPrivate->kind=0;
	clr.b	$15(a3)
;		if(ExpansionBase=(struct ExpansionBase*)OpenLibrary(EXPANSIONNAM
	pea	$25.w
	pea	L54(pc)
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_OpenLibrary
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	addq.l	#$8,a7
	move.l	d0,_ExpansionBase-$8000(a4)
	beq	L18
;ruct ExpansionBas
;			pPrivate->ExpansionBase=(struct Library *)ExpansionBase;
	move.l	-$18(a5),a3
	move.l	_ExpansionBase-$8000(a4),4(a3)
;			if(!pPrivate->m_startup)
	tst.l	$1E(a3)
	bne.b	L1
;			if(!pPrivate->m_startup)
;				pPrivate->m_startup="";
	move.l	-$18(a5),a3
	move.l	#L55,$1E(a3)
;				pPrivate->m_startup="";
L1
;			switch(*((pPrivate->m_startup)++))
	move.l	-$18(a5),a3
	move.l	a1,-$20(a5)
	move.l	$1E(a3),a1
	addq.l	#1,$1E(a3)
	move.b	(a1),d7
	move.l	-$20(a5),a1
	cmp.b	#$6C,d7
	bhi.b	L56
	beq	L7
	cmp.b	#$4D,d7
	bhi.b	L57
	beq.b	L4
	cmp.b	#$4C,d7
	beq.b	L7
	bra.b	L3
L57
	cmp.b	#$50,d7
	beq	L14
	bra.b	L3
L56
	cmp.b	#$6D,d7
	beq.b	L4
	cmp.b	#$70,d7
	beq	L14
;			switch(*((pPrivate->m_startu
;				
L3
;					pPrivate->m_startup--;
	move.l	-$18(a5),a3
	subq.l	#1,$1E(a3)
;				
L4
;				if(device=FindConfigDev(NULL,2092,18))
	pea	$12.w
	pea	$82C.w
	clr.l	-(a7)
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_FindConfigDev
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	lea	$C(a7),a7
	move.l	d0,-$14(a5)
	beq.b	L7
;				if(device=FindConfigDe
;					pPrivate->mfc3=(struct mfc3 *)((ULONG)(device->cd_BoardAdd
	move.l	-$14(a5),a3
	move.l	$20(a3),d7
	add.l	#$4000,d7
	move.l	-$18(a5),a3
	move.l	d7,$C(a3)
;					pPrivate->kind=1;
	move.b	#1,$15(a3)
;					pPrivate->name="Multifacecard III";
	move.l	#L58,$16(a3)
;					goto 
	bra	L5
;					goto 
L6
;				
L7
;				if((device=FindConfigDev(NULL,2092,16))||(device=FindConfigD
	pea	$10.w
	pea	$82C.w
	clr.l	-(a7)
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_FindConfigDev
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	lea	$C(a7),a7
	move.l	d0,-$14(a5)
	bne.b	L59
	pea	$11.w
	pea	$82C.w
	clr.l	-(a7)
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_FindConfigDev
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	lea	$C(a7),a7
	move.l	d0,-$14(a5)
	beq	L14
L59
;LL,2092,16))||(de
;					pPrivate->kind=2;
	move.l	-$18(a5),a3
	move.b	#2,$15(a3)
;					pPrivate->pit=(struct pit *)((ULONG)(device->cd_BoardAddr)
	move.l	-$14(a5),a3
	move.l	$20(a3),d7
	add.l	#$100,d7
	move.l	-$18(a5),a3
	move.l	d7,$10(a3)
;					pPrivate->pit->pit_pcdr&=~0x50;
	move.l	$10(a3),a3
	and.b	#$AF,$18(a3)
;					pPrivate->pit->pit_pcddr|=0x50;
	move.l	-$18(a5),a3
	move.l	$10(a3),a3
	or.b	#$50,$8(a3)
;					if(pPrivate->m_startup)
	move.l	-$18(a5),a3
	tst.l	$1E(a3)
	beq.b	L11
;					if(pPrivate->m_startup)
;						switch(*(pPrivate->m_startup))
	move.l	-$18(a5),a3
	move.l	$1E(a3),a3
	move.b	(a3),d7
	cmp.b	#$30,d7
	beq.b	L9
	bra.b	L10
;						switch(*(pPrivate->m_start
;							
L9
;								pPrivate->pitunit=0;
	move.l	-$18(a5),a3
	clr.b	$14(a3)
;								
	bra.b	L12
;							
L10
;								pPrivate->pitunit=1;
	move.l	-$18(a5),a3
	move.b	#1,$14(a3)
;								pPrivate->pitunit=1;
L8
;								pPrivate->pitunit=1;
	bra.b	L12
L11
;else
;						pPrivate->pitunit=1;
	move.l	-$18(a5),a3
	move.b	#1,$14(a3)
;						pPrivate->pitunit=1;
L12
;					pPrivate->name="Multifacecard II";
	move.l	-$18(a5),a3
	move.l	#L60,$16(a3)
;					goto 
	bra	L5
;					goto 
L13
;				
L14
;				if(pPrivate->MiscBase=OpenResource("misc.resource"))
	pea	L61(pc)
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_OpenResource
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	addq.l	#4,a7
	move.l	-$18(a5),a3
	move.l	d0,(a3)
	beq	L2
;f(pPrivate->MiscB
;					MiscBase=(struct MiscBase *)pPrivate->MiscBase;
	move.l	-$18(a5),a3
	move.l	(a3),_MiscBase-$8000(a4)
;					if(pPrivate->portopen=(BOOL)!AllocMiscResource(MR_PARALLEL
	move.l	_parportname__833681-$8000(a4),-(a7)
	pea	2.w
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_AllocMiscResource
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	addq.l	#$8,a7
	tst.l	d0
	beq.b	L62
	moveq	#0,d7
	bra.b	L63
L62
	moveq	#1,d7
L63
	move.l	-$18(a5),a3
	move.w	d7,$8(a3)
	beq	L2
;OL)!AllocMiscReso
;						if(pPrivate->bitsopen=(BOOL)!AllocMiscResource(MR_PARALL
	move.l	_parportname__833681-$8000(a4),-(a7)
	pea	3.w
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_AllocMiscResource
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	addq.l	#$8,a7
	tst.l	d0
	beq.b	L64
	moveq	#0,d7
	bra.b	L65
L64
	moveq	#1,d7
L65
	move.l	-$18(a5),a3
	move.w	d7,$A(a3)
	beq.b	L15
;OL)!AllocMiscReso
;							ciaa.ciaprb=(UBYTE)0x00;
	clr.b	_ciaa+$100
;							ciaa.ciaddrb=(UBYTE)0xff;
	move.b	#$FF,_ciaa+$300
;							ciab.ciapra&=~(UBYTE)0x07;
	and.b	#$F8,_ciab
;							ciab.ciaddra|=(UBYTE)0x07;
	or.b	#7,_ciab+$200
;							pPrivate->kind=3;
	move.l	-$18(a5),a3
	move.b	#3,$15(a3)
;							pPrivate->name=parportname;
	move.l	_parportname__833681-$8000(a4),$16(a3)
;							goto 
	bra.b	L5
;							goto 
L15
;						FreeMiscResource(MR_PARALLELPORT);
	pea	2.w
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_FreeMiscResource
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	addq.l	#4,a7
;						FreeMiscResource(MR_PARALLELPORT);
L16
;						FreeMiscResource(MR_PARALLELPORT);
L17
;						FreeMiscResource(MR_PARALLELPORT);
L2
;			CloseLibrary(pPrivate->ExpansionBase);
	move.l	-$18(a5),a3
	move.l	4(a3),-(a7)
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_CloseLibrary
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	addq.l	#4,a7
;			CloseLibrary(pPrivate->ExpansionBase);
L18
;		FreeVec(pPrivate);
	move.l	-$18(a5),-(a7)
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_FreeVec
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
	addq.l	#4,a7
;		FreeVec(pPrivate);
L19
;	pPrivate=NULL;
	clr.l	-$18(a5)
L5
;	RestoreA4();
	move.l	a0,-$1C(a5)
	move.l	a1,-$20(a5)
	jsr	_RestoreA4
	move.l	-$1C(a5),a0
	move.l	-$20(a5),a1
;	return((APTR)pPrivate);
	move.l	-$18(a5),d0
	movem.l	(a7)+,d7/a3
	unlk	a5
	rts

;VOID FreeLCD(
	XDEF	_FreeLCD
_FreeLCD
L66	EQU	-$C
	link	a5,#L66+4
L67	EQU	$400
	move.l	a2,-(a7)
;	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	move.l	a0,a2
;	StoreA4();
	move.l	a0,-$8(a5)
	jsr	_StoreA4
	move.l	-$8(a5),a0
;	GetBaseReg();
	move.l	a0,-$8(a5)
	jsr	_GetBaseReg
	move.l	-$8(a5),a0
;	if(hndl_a0)
	cmp.w	#0,a0
	beq.b	L23
;	if(hndl_a0)
;		if(Private.bitsopen)
	tst.w	$A(a2)
	beq.b	L20
;		if(Private.bitsopen)FreeMiscResource(MR_PARA
	pea	3.w
	move.l	a0,-$8(a5)
	jsr	_FreeMiscResource
	move.l	-$8(a5),a0
	addq.l	#4,a7
L20
;		if(Private.portopen)
	tst.w	$8(a2)
	beq.b	L21
;		if(Private.portopen)FreeMiscResource(MR_PARA
	pea	2.w
	move.l	a0,-$8(a5)
	jsr	_FreeMiscResource
	move.l	-$8(a5),a0
	addq.l	#4,a7
L21
;		if(Private.ExpansionBase)
	tst.l	4(a2)
	beq.b	L22
;		if(Private.ExpansionBase)CloseLibrary(P
	move.l	4(a2),-(a7)
	move.l	a0,-$8(a5)
	jsr	_CloseLibrary
	move.l	-$8(a5),a0
	addq.l	#4,a7
L22
;		FreeVec(&Private)
	move.l	a2,-(a7)
	move.l	a0,-$8(a5)
	jsr	_FreeVec
	move.l	-$8(a5),a0
	addq.l	#4,a7
;		FreeVec(&Private)
L23
;	CleanupModules();
	move.l	a0,-$8(a5)
	jsr	_CleanupModules
	move.l	-$8(a5),a0
;	RestoreA4();
	move.l	a0,-$8(a5)
	jsr	_RestoreA4
	move.l	-$8(a5),a0
	move.l	(a7)+,a2
	unlk	a5
	rts

;ULONG LCDPreMessage(
	XDEF	_LCDPreMessage
_LCDPreMessage
L68	EQU	0
L69	EQU	0
;	return 0;
	moveq	#0,d0
	rts

;		/*	Wait while LCD processes...		*/
	XDEF	_LCDPostMessage
_LCDPostMessage
L70	EQU	0
L71	EQU	0
;	return 0;
	moveq	#0,d0
	rts

;ULONG LCDDelayFor(
	XDEF	_LCDDelayFor
_LCDDelayFor
L72	EQU	-$18
	link	a5,#L72+12
L73	EQU	$C80
	movem.l	d7/a2/a3,-(a7)
;	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	move.l	a0,a2
;	StoreA4();
	move.l	d0,-$8(a5)
	move.l	a0,-$C(a5)
	jsr	_StoreA4
	move.l	-$8(a5),d0
	move.l	-$C(a5),a0
;	GetBaseReg();
	move.l	d0,-$8(a5)
	move.l	a0,-$C(a5)
	jsr	_GetBaseReg
	move.l	-$8(a5),d0
	move.l	-$C(a5),a0
;	Private.m_timereq->tr_node.io_Command=TR_ADDREQUEST;
	move.l	$22(a2),a3
	move.w	#$9,$1C(a3)
;	Private.m_timereq->tr_time.tv_micro=micros%1000000;
	move.l	d0,d7
	move.l	d0,-$8(a5)
	move.l	d7,d0
	move.l	#$F4240,d1
	XREF	uintdiv
	jsr	uintdiv
	move.l	d1,d0
	move.l	$22(a2),a3
	move.l	d0,$24(a3)
	move.l	-$8(a5),d0
;	Private.m_timereq->tr_time.tv_secs=micros/1000000;
	move.l	d0,d7
	move.l	d0,-$8(a5)
	move.l	d7,d0
	move.l	#$F4240,d1
	XREF	lib_div_uint
	jsr	lib_div_uint
	move.l	$22(a2),a3
	move.l	d0,$20(a3)
	move.l	-$8(a5),d0
;	DoIO((struct IORequest *)Private.m_timereq);
	move.l	$22(a2),-(a7)
	move.l	d0,-$8(a5)
	move.l	a0,-$C(a5)
	jsr	_DoIO
	move.l	-$C(a5),a0
	addq.l	#4,a7
	move.l	-$8(a5),d0
;	RestoreA4();
	move.l	d0,-$8(a5)
	move.l	a0,-$C(a5)
	jsr	_RestoreA4
	move.l	-$8(a5),d0
	move.l	-$C(a5),a0
;	return 0;
	move.l	d0,-$8(a5)
	moveq	#0,d0
	movem.l	(a7)+,d7/a2/a3
	unlk	a5
	rts

;STRPTR LCDDriverName(
	XDEF	_LCDDriverName
_LCDDriverName
L74	EQU	4
L75	EQU	$400
	move.l	a2,-(a7)
;	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	move.l	a0,a2
;	return Private.name;
	move.l	$16(a2),d0
	move.l	(a7)+,a2
	rts

;ULONG LCDPutChar(
	XDEF	_LCDPutChar
_LCDPutChar
L76	EQU	-$3C
	link	a5,#L76+24
L77	EQU	$CF0
	movem.l	d4-d7/a2/a3,-(a7)
;	UBYTE code=code_d0;
	move.b	d0,-1(a5)
;	BOOL data=data_d1;
	move.w	d1,d6
;	ULONG micros=micros_d2;
	move.l	d2,d5
;	ULONG ctrlmask=ctrlmask_d3;
	move.l	d3,d4
;	struct LCDDriverBase *LCDDriverBase=LCDDriverBase_a6;
	move.l	a6,-$10(a5)
;	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	move.l	a0,-$14(a5)
;	switch(Private.kind)
	move.l	-$14(a5),a3
	move.b	$15(a3),d7
	cmp.b	#2,d7
	bhi.b	L78
	beq	L29
	cmp.b	#1,d7
	beq.b	L25
	bra	L24
L78
	cmp.b	#3,d7
	beq	L38
	bra	L24
;	switch(Private.kind)
;	
L25
;		Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;		Private.mfc3->mfc_pacr=Private.mfc3->mfc_pbcr=0x0;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	clr.b	$300(a3)
	move.l	-$14(a5),a2
	move.l	$C(a2),a2
	move.b	$300(a3),$100(a2)
;		Private.mfc3->mfc_pb=0xff;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	move.b	#$FF,$200(a3)
;		Private.mfc3->mfc_pa=0x47;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	move.b	#$47,(a3)
;		Private.mfc3->mfc_pacr=Private.mfc3->mfc_pbcr=0x04;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	move.b	#4,$300(a3)
	move.l	-$14(a5),a2
	move.l	$C(a2),a2
	move.b	$300(a3),$100(a2)
;		Private.mfc3->mfc_pb=code;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	move.b	-1(a5),$200(a3)
;		Private.mfc3->mfc_pa=0x40;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	move.b	#$40,(a3)
;		if(data)
	tst.w	d6
	beq.b	L26
;		if(data)
;			Private.mfc3->mfc_pa|=0x02;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	or.b	#2,(a3)
;			Private.mfc3->mfc_pa|=0x02;
L26
;		Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;		LCDDelayFor(&Private,1,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	moveq	#1,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;		Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;		if(ctrlmask&1)
	move.l	d4,d7
	and.l	#1,d7
	beq.b	L27
;		if(ctrlmask&1)
;			Private.mfc3->mfc_pa|=0x01;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	or.b	#1,(a3)
;			Private.mfc3->mfc_pa|=0x01;
L27
;		if(ctrlmask&2)
	move.l	d4,d7
	and.l	#2,d7
	beq.b	L28
;		if(ctrlmask&2)
;			Private.mfc3->mfc_pa|=0x04;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	or.b	#4,(a3)
;			Private.mfc3->mfc_pa|=0x04;
L28
;		Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;		LCDDelayFor(&Private,1,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	moveq	#1,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;		Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;		Private.mfc3->mfc_pa&=~0x05;
	move.l	-$14(a5),a3
	move.l	$C(a3),a3
	and.b	#$FA,(a3)
;		Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;		LCDDelayFor(&Private,micros,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	move.l	d5,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;		
	bra	L24
;	
L29
;		if(Private.pitunit)
	move.l	-$14(a5),a3
	tst.b	$14(a3)
	beq	L33
;		if(Private.pitunit)
;			Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			Private.pit->pit_pbddr=0xff;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	move.b	#$FF,6(a3)
;			Private.pit->pit_pcddr|=0x52;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$52,$8(a3)
;			Private.pit->pit_pbdr=code;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	move.b	-1(a5),$12(a3)
;			Private.pit->pit_pcdr&=~0x52;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	and.b	#$AD,$18(a3)
;			if(data)
	tst.w	d6
	beq.b	L30
;			if(data)
;				Private.pit->pit_pcdr|=0x10;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$10,$18(a3)
;				Private.pit->pit_pcdr|=0x10;
L30
;			Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			LCDDelayFor(&Private,1,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	moveq	#1,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;			Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			Private.pit->pit_pcddr|=0x52;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$52,$8(a3)
;			if(ctrlmask&1)
	move.l	d4,d7
	and.l	#1,d7
	beq.b	L31
;			if(ctrlmask&1)
;				Private.pit->pit_pcdr|=0x40;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$40,$18(a3)
;				Private.pit->pit_pcdr|=0x40;
L31
;			if(ctrlmask&2)
	move.l	d4,d7
	and.l	#2,d7
	beq.b	L32
;			if(ctrlmask&2)
;				Private.pit->pit_pcdr|=0x02;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#2,$18(a3)
;				Private.pit->pit_pcdr|=0x02;
L32
;			Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			LCDDelayFor(&Private,1,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	moveq	#1,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;			Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			Private.pit->pit_pcddr|=0x52;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$52,$8(a3)
;			Private.pit->pit_pcdr&=~0x42;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	and.b	#$BD,$18(a3)
;			Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			LCDDelayFor(&Private,micros,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	move.l	d5,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;			LCDDelayFor(&Private,micros,LCDDriverBase);
	bra	L24
L33
;else
;			Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			Private.pit->pit_paddr=0xff;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	move.b	#$FF,4(a3)
;			Private.pit->pit_pcddr|=0x85;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$85,$8(a3)
;			Private.pit->pit_padr=code;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	move.b	-1(a5),$10(a3)
;			Private.pit->pit_pcdr&=~0x85;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	and.b	#$7A,$18(a3)
;			if(data)
	tst.w	d6
	beq.b	L34
;			if(data)
;				Private.pit->pit_pcdr|=0x04;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#4,$18(a3)
;				Private.pit->pit_pcdr|=0x04;
L34
;			Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			LCDDelayFor(&Private,1,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	moveq	#1,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;			Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			Private.pit->pit_pcddr|=0x85;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$85,$8(a3)
;			if(ctrlmask&1)
	move.l	d4,d7
	and.l	#1,d7
	beq.b	L35
;			if(ctrlmask&1)
;				Private.pit->pit_pcdr|=0x80;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$80,$18(a3)
;				Private.pit->pit_pcdr|=0x80;
L35
;			if(ctrlmask&2)
	move.l	d4,d7
	and.l	#2,d7
	beq.b	L36
;			if(ctrlmask&2)
;				Private.pit->pit_pcdr|=0x01;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#1,$18(a3)
;				Private.pit->pit_pcdr|=0x01;
L36
;			Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			LCDDelayFor(&Private,1,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	moveq	#1,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;			Forbid();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Forbid
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			Private.pit->pit_pcddr|=0x85;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	or.b	#$85,$8(a3)
;			Private.pit->pit_pcdr&=~0x81;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	and.b	#$7E,$18(a3)
;			Permit();
	move.l	d0,-$18(a5)
	move.l	d1,-$1C(a5)
	move.l	a0,-$20(a5)
	jsr	_Permit
	move.l	-$18(a5),d0
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
;			LCDDelayFor(&Private,micros,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	move.l	d5,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;			Private.pit->pit_paddr=0x00;
	move.l	-$14(a5),a3
	move.l	$10(a3),a3
	clr.b	4(a3)
;			Private.pit->pit_paddr=0x00;
L37
;		
	bra	L24
;	
L38
;		ciaa.ciaddrb=0xff;
	move.b	#$FF,_ciaa+$300
;		ciaa.ciaprb=code;
	move.b	-1(a5),_ciaa+$100
;		if(!data)
	tst.w	d6
	bne.b	L39
;		if(!data)
;			ciab.ciapra&=~((UBYTE)0x02);
	and.b	#$FD,_ciab
;			ciab.ciapra&=~((UBYTE)0x02);
	bra.b	L40
L39
; else 
;			ciab.ciapra|=(UBYTE)0x02;
	or.b	#2,_ciab
;			ciab.ciapra|=(UBYTE)0x02;
L40
;		LCDDelayFor(&Private,1,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	moveq	#1,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;		if(ctrlmask&1)
	move.l	d4,d7
	and.l	#1,d7
	beq.b	L41
;		if(ctrlmask&1)
;			ciab.ciapra|=(UBYTE)0x01;
	or.b	#1,_ciab
;			ciab.ciapra|=(UBYTE)0x01;
L41
;		if(ctrlmask&2)
	move.l	d4,d7
	and.l	#2,d7
	beq.b	L42
;		if(ctrlmask&2)
;			ciab.ciapra|=(UBYTE)0x04;
	or.b	#4,_ciab
;			ciab.ciapra|=(UBYTE)0x04;
L42
;		LCDDelayFor(&Private,1,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	moveq	#1,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;		ciab.ciapra&=~((UBYTE)0x05);
	and.b	#$FA,_ciab
;		LCDDelayFor(&Private,micros,LCDDriverBase);
	move.l	a6,-$24(a5)
	move.l	-$10(a5),a6
	move.l	d0,-$18(a5)
	move.l	d5,d0
	move.l	a0,-$20(a5)
	move.l	-$14(a5),a0
	move.l	d1,-$1C(a5)
	bsr	_LCDDelayFor
	move.l	-$1C(a5),d1
	move.l	-$20(a5),a0
	move.l	-$24(a5),a6
	move.l	-$18(a5),d0
;	
L43
;	
L24
;	return 0;
	move.l	d0,-$18(a5)
	moveq	#0,d0
	movem.l	(a7)+,d4-d7/a2/a3
	unlk	a5
	rts

;VOID LCDVisual(
	XDEF	_LCDVisual
_LCDVisual
L79	EQU	4
L80	EQU	$400
	move.l	a2,-(a7)
;	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	move.l	a0,a2
	move.l	(a7)+,a2
	rts

;ULONG LCDMethod(
	XDEF	_LCDMethod
_LCDMethod
L81	EQU	-$20
	link	a5,#L81+12
L82	EQU	$1404
	movem.l	d2/a2/a4,-(a7)
;	struct PrivateData &Private=*(struct PrivateData *)hndl_a0;
	move.l	a0,-4(a5)
;	APTR	hndl=hndl_a0;
	move.l	a0,a4
;	ULONG	method=method_d0;
	move.l	d0,d2
;	APTR	param=param_a1;
	move.l	a1,a2
;	switch(method)
	cmp.l	#1,d2
	beq.b	L45
	bra.b	L46
;	switch(method)
;	
L45
;		*(ULONG *)param=22L;
	move.l	#$16,(a2)
;		return	LCDOMERR_OK;
	move.l	d0,-$14(a5)
	moveq	#2,d0
	movem.l	(a7)+,d2/a2/a4
	unlk	a5
	rts
;		
;	
L46
;		return	LCDOMERR_UNKNOWN;
	move.l	d0,-$14(a5)
	moveq	#3,d0
	movem.l	(a7)+,d2/a2/a4
	unlk	a5
	rts
;		return	LCDOMERR_UNKNOWN;
L44
	movem.l	(a7)+,d2/a2/a4
	unlk	a5
	rts

L55
	dc.b	0
L50
	dc.b	'LCDAEMON',0
L60
	dc.b	'Multifacecard II',0
L58
	dc.b	'Multifacecard III',0
L51
	dc.b	'Parallel port',0
L54
	dc.b	'expansion.library',0
L61
	dc.b	'misc.resource',0
L49
	dc.b	$AB,$AB,' LCD rendezvous ',$BB,$BB,0

	SECTION ":4",DATA,SMALL

_lcdportname
	dc.l	L49
_lcdrexxname
	dc.l	L50
	XDEF	_MiscBase
_MiscBase
	dc.l	0
	XDEF	_ExpansionBase
_ExpansionBase
	dc.l	0
	XDEF	_versiontag
_versiontag
	dc.b	0
	dc.b	0,'$VER: lcdguppy.library 37.1 (15.11.97)',0
	CNOP	0,4
	XDEF	_Copyright
_Copyright
	dc.b	$A9,' 1997-98 Hendrik De Vloed, VOMIT, inc.',0
_parportname__833681
	dc.l	L51

	END
