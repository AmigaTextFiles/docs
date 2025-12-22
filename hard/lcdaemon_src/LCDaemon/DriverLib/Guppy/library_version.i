; ASM Headerfile created by SetRev 1.42 on 15.11.97 at 23:11:03

VERSION		EQU	37
REVISION	EQU	1
;DATE	MACRO
;		dc.b	'15.11.97'
;	ENDM
;TIME	MACRO
;		dc.b	'23:11:03'
;	ENDM
VERS	MACRO
		dc.b	'lcdguppy.library 37.1'
	ENDM
VSTRING	MACRO
		dc.b	'lcdguppy.library 37.1 (15.11.97)',13,10,0
	ENDM
VSTRING2	MACRO
		dc.b	'lcdguppy.library 37.1 (15.11.97)',0
	ENDM
VERSTAG	MACRO
		dc.b	0,'$VER: lcdguppy.library 37.1 (15.11.97)',0
	ENDM
