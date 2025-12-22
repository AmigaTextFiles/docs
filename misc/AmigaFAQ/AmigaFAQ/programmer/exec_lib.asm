	xdef	_LVOSupervisor
_LVOSupervisor	equ	-30
	xdef	_LVOInitCode
_LVOInitCode	equ	-72
	xdef	_LVOInitStruct
_LVOInitStruct	equ	-78
	xdef	_LVOMakeLibrary
_LVOMakeLibrary	equ	-84
	xdef	_LVOMakeFunctions
_LVOMakeFunctions	equ	-90
	xdef	_LVOFindResident
_LVOFindResident	equ	-96
	xdef	_LVOInitResident
_LVOInitResident	equ	-102
	xdef	_LVOAlert
_LVOAlert	equ	-108
	xdef	_LVODebug
_LVODebug	equ	-114
	xdef	_LVODisable
_LVODisable	equ	-120
	xdef	_LVOEnable
_LVOEnable	equ	-126
	xdef	_LVOForbid
_LVOForbid	equ	-132
	xdef	_LVOPermit
_LVOPermit	equ	-138
	xdef	_LVOSetSR
_LVOSetSR	equ	-144
	xdef	_LVOSuperState
_LVOSuperState	equ	-150
	xdef	_LVOUserState
_LVOUserState	equ	-156
	xdef	_LVOSetIntVector
_LVOSetIntVector	equ	-162
	xdef	_LVOAddIntServer
_LVOAddIntServer	equ	-168
	xdef	_LVORemIntServer
_LVORemIntServer	equ	-174
	xdef	_LVOCause
_LVOCause	equ	-180
	xdef	_LVOAllocate
_LVOAllocate	equ	-186
	xdef	_LVODeallocate
_LVODeallocate	equ	-192
	xdef	_LVOAllocMem
_LVOAllocMem	equ	-198
	xdef	_LVOAllocAbs
_LVOAllocAbs	equ	-204
	xdef	_LVOFreeMem
_LVOFreeMem	equ	-210
	xdef	_LVOAvailMem
_LVOAvailMem	equ	-216
	xdef	_LVOAllocEntry
_LVOAllocEntry	equ	-222
	xdef	_LVOFreeEntry
_LVOFreeEntry	equ	-228
	xdef	_LVOInsert
_LVOInsert	equ	-234
	xdef	_LVOAddHead
_LVOAddHead	equ	-240
	xdef	_LVOAddTail
_LVOAddTail	equ	-246
	xdef	_LVORemove
_LVORemove	equ	-252
	xdef	_LVORemHead
_LVORemHead	equ	-258
	xdef	_LVORemTail
_LVORemTail	equ	-264
	xdef	_LVOEnqueue
_LVOEnqueue	equ	-270
	xdef	_LVOFindName
_LVOFindName	equ	-276
	xdef	_LVOAddTask
_LVOAddTask	equ	-282
	xdef	_LVORemTask
_LVORemTask	equ	-288
	xdef	_LVOFindTask
_LVOFindTask	equ	-294
	xdef	_LVOSetTaskPri
_LVOSetTaskPri	equ	-300
	xdef	_LVOSetSignal
_LVOSetSignal	equ	-306
	xdef	_LVOSetExcept
_LVOSetExcept	equ	-312
	xdef	_LVOWait
_LVOWait	equ	-318
	xdef	_LVOSignal
_LVOSignal	equ	-324
	xdef	_LVOAllocSignal
_LVOAllocSignal	equ	-330
	xdef	_LVOFreeSignal
_LVOFreeSignal	equ	-336
	xdef	_LVOAllocTrap
_LVOAllocTrap	equ	-342
	xdef	_LVOFreeTrap
_LVOFreeTrap	equ	-348
	xdef	_LVOAddPort
_LVOAddPort	equ	-354
	xdef	_LVORemPort
_LVORemPort	equ	-360
	xdef	_LVOPutMsg
_LVOPutMsg	equ	-366
	xdef	_LVOGetMsg
_LVOGetMsg	equ	-372
	xdef	_LVOReplyMsg
_LVOReplyMsg	equ	-378
	xdef	_LVOWaitPort
_LVOWaitPort	equ	-384
	xdef	_LVOFindPort
_LVOFindPort	equ	-390
	xdef	_LVOAddLibrary
_LVOAddLibrary	equ	-396
	xdef	_LVORemLibrary
_LVORemLibrary	equ	-402
	xdef	_LVOOldOpenLibrary
_LVOOldOpenLibrary	equ	-408
	xdef	_LVOCloseLibrary
_LVOCloseLibrary	equ	-414
	xdef	_LVOSetFunction
_LVOSetFunction	equ	-420
	xdef	_LVOSumLibrary
_LVOSumLibrary	equ	-426
	xdef	_LVOAddDevice
_LVOAddDevice	equ	-432
	xdef	_LVORemDevice
_LVORemDevice	equ	-438
	xdef	_LVOOpenDevice
_LVOOpenDevice	equ	-444
	xdef	_LVOCloseDevice
_LVOCloseDevice	equ	-450
	xdef	_LVODoIO
_LVODoIO	equ	-456
	xdef	_LVOSendIO
_LVOSendIO	equ	-462
	xdef	_LVOCheckIO
_LVOCheckIO	equ	-468
	xdef	_LVOWaitIO
_LVOWaitIO	equ	-474
	xdef	_LVOAbortIO
_LVOAbortIO	equ	-480
	xdef	_LVOAddResource
_LVOAddResource	equ	-486
	xdef	_LVORemResource
_LVORemResource	equ	-492
	xdef	_LVOOpenResource
_LVOOpenResource	equ	-498
	xdef	_LVORawDoFmt
_LVORawDoFmt	equ	-522
	xdef	_LVOGetCC
_LVOGetCC	equ	-528
	xdef	_LVOTypeOfMem
_LVOTypeOfMem	equ	-534
	xdef	_LVOProcure
_LVOProcure	equ	-540
	xdef	_LVOVacate
_LVOVacate	equ	-546
	xdef	_LVOOpenLibrary
_LVOOpenLibrary	equ	-552
	xdef	_LVOInitSemaphore
_LVOInitSemaphore	equ	-558
	xdef	_LVOObtainSemaphore
_LVOObtainSemaphore	equ	-564
	xdef	_LVOReleaseSemaphore
_LVOReleaseSemaphore	equ	-570
	xdef	_LVOAttemptSemaphore
_LVOAttemptSemaphore	equ	-576
	xdef	_LVOObtainSemaphoreList
_LVOObtainSemaphoreList	equ	-582
	xdef	_LVOReleaseSemaphoreList
_LVOReleaseSemaphoreList	equ	-588
	xdef	_LVOFindSemaphore
_LVOFindSemaphore	equ	-594
	xdef	_LVOAddSemaphore
_LVOAddSemaphore	equ	-600
	xdef	_LVORemSemaphore
_LVORemSemaphore	equ	-606
	xdef	_LVOSumKickData
_LVOSumKickData	equ	-612
	xdef	_LVOAddMemList
_LVOAddMemList	equ	-618
	xdef	_LVOCopyMem
_LVOCopyMem	equ	-624
	xdef	_LVOCopyMemQuick
_LVOCopyMemQuick	equ	-630
	xdef	_LVOCacheClearU
_LVOCacheClearU	equ	-636
	xdef	_LVOCacheClearE
_LVOCacheClearE	equ	-642
	xdef	_LVOCacheControl
_LVOCacheControl	equ	-648
	xdef	_LVOCreateIORequest
_LVOCreateIORequest	equ	-654
	xdef	_LVODeleteIORequest
_LVODeleteIORequest	equ	-660
	xdef	_LVOCreateMsgPort
_LVOCreateMsgPort	equ	-666
	xdef	_LVODeleteMsgPort
_LVODeleteMsgPort	equ	-672
	xdef	_LVOObtainSemaphoreShared
_LVOObtainSemaphoreShared	equ	-678
	xdef	_LVOAllocVec
_LVOAllocVec	equ	-684
	xdef	_LVOFreeVec
_LVOFreeVec	equ	-690
	xdef	_LVOCreatePool
_LVOCreatePool	equ	-696
	xdef	_LVODeletePool
_LVODeletePool	equ	-702
	xdef	_LVOAllocPooled
_LVOAllocPooled	equ	-708
	xdef	_LVOFreePooled
_LVOFreePooled	equ	-714
	xdef	_LVOAttemptSemaphoreShared
_LVOAttemptSemaphoreShared	equ	-720
	xdef	_LVOColdReboot
_LVOColdReboot	equ	-726
	xdef	_LVOStackSwap
_LVOStackSwap	equ	-732
	xdef	_LVOChildFree
_LVOChildFree	equ	-738
	xdef	_LVOChildOrphan
_LVOChildOrphan	equ	-744
	xdef	_LVOChildStatus
_LVOChildStatus	equ	-750
	xdef	_LVOChildWait
_LVOChildWait	equ	-756
	xdef	_LVOCachePreDMA
_LVOCachePreDMA	equ	-762
	xdef	_LVOCachePostDMA
_LVOCachePostDMA	equ	-768
	xdef	_LVOAddMemHandler
_LVOAddMemHandler	equ	-774
	xdef	_LVORemMemHandler
_LVORemMemHandler	equ	-780
	xdef	_LVOObtainQuickVector
_LVOObtainQuickVector	equ	-786
