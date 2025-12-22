	xdef	_LVOOpen
_LVOOpen	equ	-30
	xdef	_LVOClose
_LVOClose	equ	-36
	xdef	_LVORead
_LVORead	equ	-42
	xdef	_LVOWrite
_LVOWrite	equ	-48
	xdef	_LVOInput
_LVOInput	equ	-54
	xdef	_LVOOutput
_LVOOutput	equ	-60
	xdef	_LVOSeek
_LVOSeek	equ	-66
	xdef	_LVODeleteFile
_LVODeleteFile	equ	-72
	xdef	_LVORename
_LVORename	equ	-78
	xdef	_LVOLock
_LVOLock	equ	-84
	xdef	_LVOUnLock
_LVOUnLock	equ	-90
	xdef	_LVODupLock
_LVODupLock	equ	-96
	xdef	_LVOExamine
_LVOExamine	equ	-102
	xdef	_LVOExNext
_LVOExNext	equ	-108
	xdef	_LVOInfo
_LVOInfo	equ	-114
	xdef	_LVOCreateDir
_LVOCreateDir	equ	-120
	xdef	_LVOCurrentDir
_LVOCurrentDir	equ	-126
	xdef	_LVOIoErr
_LVOIoErr	equ	-132
	xdef	_LVOCreateProc
_LVOCreateProc	equ	-138
	xdef	_LVOExit
_LVOExit	equ	-144
	xdef	_LVOLoadSeg
_LVOLoadSeg	equ	-150
	xdef	_LVOUnLoadSeg
_LVOUnLoadSeg	equ	-156
	xdef	_LVODeviceProc
_LVODeviceProc	equ	-174
	xdef	_LVOSetComment
_LVOSetComment	equ	-180
	xdef	_LVOSetProtection
_LVOSetProtection	equ	-186
	xdef	_LVODateStamp
_LVODateStamp	equ	-192
	xdef	_LVODelay
_LVODelay	equ	-198
	xdef	_LVOWaitForChar
_LVOWaitForChar	equ	-204
	xdef	_LVOParentDir
_LVOParentDir	equ	-210
	xdef	_LVOIsInteractive
_LVOIsInteractive	equ	-216
	xdef	_LVOExecute
_LVOExecute	equ	-222
	xdef	_LVOAllocDosObject
_LVOAllocDosObject	equ	-228
	xdef	_LVOFreeDosObject
_LVOFreeDosObject	equ	-234
	xdef	_LVODoPkt
_LVODoPkt	equ	-240
	xdef	_LVOSendPkt
_LVOSendPkt	equ	-246
	xdef	_LVOWaitPkt
_LVOWaitPkt	equ	-252
	xdef	_LVOReplyPkt
_LVOReplyPkt	equ	-258
	xdef	_LVOAbortPkt
_LVOAbortPkt	equ	-264
	xdef	_LVOLockRecord
_LVOLockRecord	equ	-270
	xdef	_LVOLockRecords
_LVOLockRecords	equ	-276
	xdef	_LVOUnLockRecord
_LVOUnLockRecord	equ	-282
	xdef	_LVOUnLockRecords
_LVOUnLockRecords	equ	-288
	xdef	_LVOSelectInput
_LVOSelectInput	equ	-294
	xdef	_LVOSelectOutput
_LVOSelectOutput	equ	-300
	xdef	_LVOFGetC
_LVOFGetC	equ	-306
	xdef	_LVOFPutC
_LVOFPutC	equ	-312
	xdef	_LVOUnGetC
_LVOUnGetC	equ	-318
	xdef	_LVOFRead
_LVOFRead	equ	-324
	xdef	_LVOFWrite
_LVOFWrite	equ	-330
	xdef	_LVOFGets
_LVOFGets	equ	-336
	xdef	_LVOFPuts
_LVOFPuts	equ	-342
	xdef	_LVOVFWritef
_LVOVFWritef	equ	-348
	xdef	_LVOVFPrintf
_LVOVFPrintf	equ	-354
	xdef	_LVOFlush
_LVOFlush	equ	-360
	xdef	_LVOSetVBuf
_LVOSetVBuf	equ	-366
	xdef	_LVODupLockFromFH
_LVODupLockFromFH	equ	-372
	xdef	_LVOOpenFromLock
_LVOOpenFromLock	equ	-378
	xdef	_LVOParentOfFH
_LVOParentOfFH	equ	-384
	xdef	_LVOExamineFH
_LVOExamineFH	equ	-390
	xdef	_LVOSetFileDate
_LVOSetFileDate	equ	-396
	xdef	_LVONameFromLock
_LVONameFromLock	equ	-402
	xdef	_LVONameFromFH
_LVONameFromFH	equ	-408
	xdef	_LVOSplitName
_LVOSplitName	equ	-414
	xdef	_LVOSameLock
_LVOSameLock	equ	-420
	xdef	_LVOSetMode
_LVOSetMode	equ	-426
	xdef	_LVOExAll
_LVOExAll	equ	-432
	xdef	_LVOReadLink
_LVOReadLink	equ	-438
	xdef	_LVOMakeLink
_LVOMakeLink	equ	-444
	xdef	_LVOChangeMode
_LVOChangeMode	equ	-450
	xdef	_LVOSetFileSize
_LVOSetFileSize	equ	-456
	xdef	_LVOSetIoErr
_LVOSetIoErr	equ	-462
	xdef	_LVOFault
_LVOFault	equ	-468
	xdef	_LVOPrintFault
_LVOPrintFault	equ	-474
	xdef	_LVOErrorReport
_LVOErrorReport	equ	-480
	xdef	_LVOCli
_LVOCli	equ	-492
	xdef	_LVOCreateNewProc
_LVOCreateNewProc	equ	-498
	xdef	_LVORunCommand
_LVORunCommand	equ	-504
	xdef	_LVOGetConsoleTask
_LVOGetConsoleTask	equ	-510
	xdef	_LVOSetConsoleTask
_LVOSetConsoleTask	equ	-516
	xdef	_LVOGetFileSysTask
_LVOGetFileSysTask	equ	-522
	xdef	_LVOSetFileSysTask
_LVOSetFileSysTask	equ	-528
	xdef	_LVOGetArgStr
_LVOGetArgStr	equ	-534
	xdef	_LVOSetArgStr
_LVOSetArgStr	equ	-540
	xdef	_LVOFindCliProc
_LVOFindCliProc	equ	-546
	xdef	_LVOMaxCli
_LVOMaxCli	equ	-552
	xdef	_LVOSetCurrentDirName
_LVOSetCurrentDirName	equ	-558
	xdef	_LVOGetCurrentDirName
_LVOGetCurrentDirName	equ	-564
	xdef	_LVOSetProgramName
_LVOSetProgramName	equ	-570
	xdef	_LVOGetProgramName
_LVOGetProgramName	equ	-576
	xdef	_LVOSetPrompt
_LVOSetPrompt	equ	-582
	xdef	_LVOGetPrompt
_LVOGetPrompt	equ	-588
	xdef	_LVOSetProgramDir
_LVOSetProgramDir	equ	-594
	xdef	_LVOGetProgramDir
_LVOGetProgramDir	equ	-600
	xdef	_LVOSystemTagList
_LVOSystemTagList	equ	-606
	xdef	_LVOAssignLock
_LVOAssignLock	equ	-612
	xdef	_LVOAssignLate
_LVOAssignLate	equ	-618
	xdef	_LVOAssignPath
_LVOAssignPath	equ	-624
	xdef	_LVOAssignAdd
_LVOAssignAdd	equ	-630
	xdef	_LVORemAssignList
_LVORemAssignList	equ	-636
	xdef	_LVOGetDeviceProc
_LVOGetDeviceProc	equ	-642
	xdef	_LVOFreeDeviceProc
_LVOFreeDeviceProc	equ	-648
	xdef	_LVOLockDosList
_LVOLockDosList	equ	-654
	xdef	_LVOUnLockDosList
_LVOUnLockDosList	equ	-660
	xdef	_LVOAttemptLockDosList
_LVOAttemptLockDosList	equ	-666
	xdef	_LVORemDosEntry
_LVORemDosEntry	equ	-672
	xdef	_LVOAddDosEntry
_LVOAddDosEntry	equ	-678
	xdef	_LVOFindDosEntry
_LVOFindDosEntry	equ	-684
	xdef	_LVONextDosEntry
_LVONextDosEntry	equ	-690
	xdef	_LVOMakeDosEntry
_LVOMakeDosEntry	equ	-696
	xdef	_LVOFreeDosEntry
_LVOFreeDosEntry	equ	-702
	xdef	_LVOIsFileSystem
_LVOIsFileSystem	equ	-708
	xdef	_LVOFormat
_LVOFormat	equ	-714
	xdef	_LVORelabel
_LVORelabel	equ	-720
	xdef	_LVOInhibit
_LVOInhibit	equ	-726
	xdef	_LVOAddBuffers
_LVOAddBuffers	equ	-732
	xdef	_LVOCompareDates
_LVOCompareDates	equ	-738
	xdef	_LVODateToStr
_LVODateToStr	equ	-744
	xdef	_LVOStrToDate
_LVOStrToDate	equ	-750
	xdef	_LVOInternalLoadSeg
_LVOInternalLoadSeg	equ	-756
	xdef	_LVOInternalUnLoadSeg
_LVOInternalUnLoadSeg	equ	-762
	xdef	_LVONewLoadSeg
_LVONewLoadSeg	equ	-768
	xdef	_LVOAddSegment
_LVOAddSegment	equ	-774
	xdef	_LVOFindSegment
_LVOFindSegment	equ	-780
	xdef	_LVORemSegment
_LVORemSegment	equ	-786
	xdef	_LVOCheckSignal
_LVOCheckSignal	equ	-792
	xdef	_LVOReadArgs
_LVOReadArgs	equ	-798
	xdef	_LVOFindArg
_LVOFindArg	equ	-804
	xdef	_LVOReadItem
_LVOReadItem	equ	-810
	xdef	_LVOStrToLong
_LVOStrToLong	equ	-816
	xdef	_LVOMatchFirst
_LVOMatchFirst	equ	-822
	xdef	_LVOMatchNext
_LVOMatchNext	equ	-828
	xdef	_LVOMatchEnd
_LVOMatchEnd	equ	-834
	xdef	_LVOParsePattern
_LVOParsePattern	equ	-840
	xdef	_LVOMatchPattern
_LVOMatchPattern	equ	-846
	xdef	_LVOFreeArgs
_LVOFreeArgs	equ	-858
	xdef	_LVOFilePart
_LVOFilePart	equ	-870
	xdef	_LVOPathPart
_LVOPathPart	equ	-876
	xdef	_LVOAddPart
_LVOAddPart	equ	-882
	xdef	_LVOStartNotify
_LVOStartNotify	equ	-888
	xdef	_LVOEndNotify
_LVOEndNotify	equ	-894
	xdef	_LVOSetVar
_LVOSetVar	equ	-900
	xdef	_LVOGetVar
_LVOGetVar	equ	-906
	xdef	_LVODeleteVar
_LVODeleteVar	equ	-912
	xdef	_LVOFindVar
_LVOFindVar	equ	-918
	xdef	_LVOCliInitNewcli
_LVOCliInitNewcli	equ	-930
	xdef	_LVOCliInitRun
_LVOCliInitRun	equ	-936
	xdef	_LVOWriteChars
_LVOWriteChars	equ	-942
	xdef	_LVOPutStr
_LVOPutStr	equ	-948
	xdef	_LVOVPrintf
_LVOVPrintf	equ	-954
	xdef	_LVOParsePatternNoCase
_LVOParsePatternNoCase	equ	-966
	xdef	_LVOMatchPatternNoCase
_LVOMatchPatternNoCase	equ	-972
	xdef	_LVOSameDevice
_LVOSameDevice	equ	-984
	xdef	_LVOExAllEnd
_LVOExAllEnd	equ	-990
	xdef	_LVOSetOwner
_LVOSetOwner	equ	-996
