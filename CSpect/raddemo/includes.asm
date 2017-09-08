; ************************************************************************
;
;	General equates and macros
;
; ************************************************************************

; Hardware
Kempston_Mouse_Buttons	equ	$fadf
Kempston_Mouse_X	equ	$fddf
Kempston_Mouse_Y	equ	$ffdf
Mouse_LB		equ	1			; 0 = pressed
Mouse_RB		equ	2
Mouse_MB		equ	4
Mouse_Wheel		equ	$f0

SpriteReg		equ	$57
SpriteShape		equ	$5b



; memory locations
SpriteData	equ	$7800
Sprites		equ	$7800
MapData		equ	$c000
CharData:	equ	$8000



LoadFile	macro
		ld	hl,\0
		ld	ix,\1
		call	Load
		endm
		
File		macro
		dw	Filesize(\0)
		db	\0
		db	0
		Message "file='",\0,"'  size=",Filesize(\0)
		endm

NREG		macro
		push	bc
		push	af
		ld	bc,$243B
		ld	a,\0
		out	(c),a
		ld	bc,$253B
		pop	af
		out	(c),a
		pop	bc
		endm


