*	Storing/restoring of the A4 register which is not auto-stored on the stack in procedures
*	where a GetBaseReg() is made. Thanks, Maxon!

	SECTION	":0",code

	XDEF	_StoreA4
	XDEF	_RestoreA4
_StoreA4
	MOVE.L (A7),-(A7)	;	Duplicate RTS address to make space for A4 storage at the original RTS address location.
	MOVE.L	A4,$4(A7)		;	Store A4 above return address so it is available in the calling function.
	RTS
_RestoreA4
	MOVE.L	4(A7),A4		;	Store the A4 value just above our return value in A4
	MOVE.L (A7)+,(A7)	;	Delete the A4 value on the stack and collapse our return address in the space created
	RTS

	END

