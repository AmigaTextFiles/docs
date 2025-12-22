; ASM Headerfile created by SetRev 1.42 on 23.11.97 at 11:29:52

VERSION		EQU	37
REVISION	EQU	1
;DATE	MACRO
;		dc.b	'23.11.97'
;	ENDM
;TIME	MACRO
;		dc.b	'11:29:52'
;	ENDM
VERS	MACRO
		dc.b	'lcdwindow.library 37.1'
	ENDM
VSTRING	MACRO
		dc.b	'lcdwindow.library 37.1 (23.11.97)',13,10,0
	ENDM
VSTRING2	MACRO
		dc.b	'lcdwindow.library 37.1 (23.11.97)',0
	ENDM
VERSTAG	MACRO
		dc.b	0,'$VER: lcdwindow.library 37.1 (23.11.97)',0
	ENDM
